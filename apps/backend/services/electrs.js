const ElectrumClient = require("@lily-technologies/electrum-client");

const elementsService = require("./elements");
const { ELECTRS_HOST } = require("../utils/const");

function getRpcClient() {
  return new ElectrumClient(50001, ELECTRS_HOST, "tcp");
}

function parseVersion(versionInfo) {
  const rawVersion = Array.isArray(versionInfo) ? versionInfo[0] : versionInfo;

  if (!rawVersion) {
    return "";
  }

  const separatorIndex = rawVersion.indexOf("/");

  return separatorIndex >= 0
    ? rawVersion.substring(separatorIndex + 1)
    : rawVersion;
}

async function getVersion() {
  const rpcClient = getRpcClient();
  const initClient = await rpcClient.initElectrum({
    client: "liquid-electrs",
    version: "1.4",
  });

  return parseVersion(initClient.versionInfo);
}

async function syncPercent() {
  try {
    const blockchainInfo = await elementsService.getBlockchainInfo();

    if (blockchainInfo.initialblockdownload) {
      return -1;
    }

    const rpcClient = getRpcClient();
    const initClient = await rpcClient.initElectrum({
      client: "liquid-electrs",
      version: "1.4",
    });
    const { height: electrsHeight } = await initClient.blockchainHeaders_subscribe();

    if (!blockchainInfo.blocks) {
      return 0;
    }

    return (electrsHeight / blockchainInfo.blocks) * 100;
  } catch (error) {
    return -2;
  }
}

module.exports = {
  getVersion,
  syncPercent,
};

const elementsService = require("./elements");
const { callElectrum } = require("../utils/electrumRpc");

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
  try {
    const versionInfo = await callElectrum("server.version", [
      "liquid-electrs",
      "1.4",
    ]);

    return parseVersion(versionInfo);
  } catch (error) {
    return "";
  }
}

async function syncPercent() {
  try {
    const blockchainInfo = await elementsService.getBlockchainInfo();

    if (blockchainInfo.initialblockdownload) {
      return -1;
    }

    const headerSubscription = await callElectrum("blockchain.headers.subscribe");
    const electrsHeight = Number(headerSubscription && headerSubscription.height);

    if (!blockchainInfo.blocks) {
      return 0;
    }

    if (!Number.isFinite(electrsHeight)) {
      return -2;
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

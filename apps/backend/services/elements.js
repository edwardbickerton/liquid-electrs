const axios = require("axios");

const { getElementsRpcConfig } = require("../utils/elementsRpc");

async function rpc(method, params = []) {
  const { host, password, port, username } = getElementsRpcConfig();
  const rpcClient = axios.create({
    baseURL: `http://${host}:${port}`,
    timeout: 10000,
    auth: {
      username,
      password,
    },
    headers: {
      "Content-Type": "application/json",
    },
  });
  const response = await rpcClient.post("/", {
    jsonrpc: "1.0",
    id: `liquid-electrs-${method}`,
    method,
    params,
  });

  if (response.data.error) {
    throw new Error(
      `Elements RPC ${method} failed: ${response.data.error.message || "unknown error"}`
    );
  }

  return response.data.result;
}

async function getBlockchainInfo() {
  return rpc("getblockchaininfo");
}

module.exports = {
  getBlockchainInfo,
};

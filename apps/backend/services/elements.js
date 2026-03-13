const axios = require("axios");

const {
  APP_ELEMENTS_NODE_IP,
  APP_ELEMENTS_RPC_PASS,
  APP_ELEMENTS_RPC_PORT,
  APP_ELEMENTS_RPC_USER,
} = require("../utils/const");

const rpcClient = axios.create({
  baseURL: `http://${APP_ELEMENTS_NODE_IP}:${APP_ELEMENTS_RPC_PORT}`,
  timeout: 10000,
  auth: {
    username: APP_ELEMENTS_RPC_USER,
    password: APP_ELEMENTS_RPC_PASS,
  },
  headers: {
    "Content-Type": "application/json",
  },
});

async function rpc(method, params = []) {
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

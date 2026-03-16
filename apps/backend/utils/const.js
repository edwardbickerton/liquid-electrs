module.exports = {
  PORT: Number(process.env.PORT || 3006),
  ELEMENTS_CONF_DIR: process.env.ELEMENTS_CONF_DIR || "/mnt/elements",
  ELECTRS_HOST: process.env.ELECTRS_HOST || "electrs",
  ELECTRS_RPC_PORT: Number(process.env.ELECTRS_RPC_PORT || 50001),
  ELECTRS_RPC_TIMEOUT_MS: Number(process.env.ELECTRS_RPC_TIMEOUT_MS || 5000),
  ELECTRUM_LOCAL_SERVICE:
    process.env.ELECTRUM_LOCAL_SERVICE ||
    process.env.DEVICE_DOMAIN_NAME ||
    "umbrel.local",
  ELECTRUM_PORT: Number(process.env.ELECTRUM_PORT || 51001),
};

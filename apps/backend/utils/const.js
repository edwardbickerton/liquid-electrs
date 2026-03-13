function requireEnv(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

module.exports = {
  PORT: Number(process.env.PORT || 3006),
  APP_ELEMENTS_NODE_IP: requireEnv("APP_ELEMENTS_NODE_IP"),
  APP_ELEMENTS_RPC_PORT: Number(requireEnv("APP_ELEMENTS_RPC_PORT")),
  APP_ELEMENTS_RPC_USER: requireEnv("APP_ELEMENTS_RPC_USER"),
  APP_ELEMENTS_RPC_PASS: requireEnv("APP_ELEMENTS_RPC_PASS"),
  ELECTRS_HOST: process.env.ELECTRS_HOST || "electrs",
  ELECTRUM_LOCAL_SERVICE: process.env.ELECTRUM_LOCAL_SERVICE || "umbrel.local",
  ELECTRUM_PORT: Number(process.env.ELECTRUM_PORT || 51001),
};

const { ELECTRUM_LOCAL_SERVICE, ELECTRUM_PORT } = require("../utils/const");

async function getElectrumConnectionDetails() {
  return {
    local: {
      address: ELECTRUM_LOCAL_SERVICE,
      port: ELECTRUM_PORT,
      connectionString: `${ELECTRUM_LOCAL_SERVICE}:${ELECTRUM_PORT}`,
    },
  };
}

module.exports = {
  getElectrumConnectionDetails,
};

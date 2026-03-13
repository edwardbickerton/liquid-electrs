import API from "@/helpers/api";

const state = () => ({
  version: "",
  connectionInfo: {
    local: {
      address: "",
      port: "",
      connectionString: "",
    },
  },
  syncPercent: -2,
});

const mutations = {
  setVersion(state, version) {
    state.version = version;
  },

  setConnectionInfo(state, connectionInfo) {
    state.connectionInfo = connectionInfo;
  },

  setSyncPercent(state, percent) {
    state.syncPercent = percent;
  },
};

const actions = {
  async getConnectionInformation({ commit }) {
    const connectionInfo = await API.get(
      `${process.env.VUE_APP_API_BASE_URL}/v1/electrs/electrum-connection-details`
    );

    if (connectionInfo && connectionInfo.local) {
      commit("setConnectionInfo", connectionInfo);
    }
  },

  async getVersion({ commit }) {
    const version = await API.get(
      `${process.env.VUE_APP_API_BASE_URL}/v1/electrs/version`
    );

    if (typeof version === "string") {
      commit("setVersion", version);
    }
  },

  async getSyncPercent({ commit }) {
    const syncPercent = await API.get(
      `${process.env.VUE_APP_API_BASE_URL}/v1/electrs/syncPercent`
    );

    if (typeof syncPercent === "number") {
      commit("setSyncPercent", syncPercent);
    }
  },
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
};

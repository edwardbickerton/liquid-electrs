import API from "@/helpers/api";

const state = () => ({
  api: {
    operational: false,
    version: "",
  },
});

const mutations = {
  setApi(state, api) {
    state.api = api;
  },
};

const actions = {
  async getApi({ commit }) {
    const api = await API.get(`${process.env.VUE_APP_API_BASE_URL}/ping`);

    commit("setApi", {
      operational: !!(api && api.version),
      version: api && api.version ? api.version : "",
    });
  },
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
};

import axios from "axios";

export default {
  async get(url) {
    try {
      const response = await axios.get(url, {
        timeout: 5000,
      });

      return response.data;
    } catch (error) {
      return null;
    }
  },
};

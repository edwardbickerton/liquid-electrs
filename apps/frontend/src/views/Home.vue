<template>
  <div class="py-14">
    <div class="flex items-center justify-start">
      <div class="mr-6 flex items-center justify-center">
        <img class="h-32 w-32 rounded-3xl" src="@/assets/icon.svg" alt="Liquid Electrs" />
      </div>
      <div>
        <div class="flex items-center">
          <svg
            width="8"
            height="8"
            viewBox="0 0 8 8"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <circle cx="4" cy="4" r="4" fill="#00CD98" />
          </svg>
          <p class="ml-1 text-lg text-green-500">Running</p>
        </div>
        <h3 class="text-5xl font-semibold dark:text-white">Liquid Electrs</h3>
        <div class="mt-2">
          <span class="font-medium text-gray-500">{{ version ? version : "..." }}</span>
        </div>
      </div>
    </div>

    <div class="mb-2 flex justify-end">
      <h3 class="mb-0 font-semibold text-gray-800 dark:text-gray-200">
        <span v-if="syncPercent === -1" class="animate-pulse">
          Waiting for Elements Core to finish syncing...
        </span>
        <span v-else-if="syncPercent >= 0">
          <span>{{ syncPercent >= 99.99 ? 100 : Number(syncPercent).toFixed(0) }}%</span>
          <span class="ml-1">Synchronized</span>
        </span>
        <span v-else class="animate-pulse">
          Connecting to Electrs server...
        </span>
      </h3>
    </div>

    <progress-bar
      :percentage="progressBarPercentage"
      color-class="bg-green-400"
      class="h-2"
    ></progress-bar>

    <connection-information></connection-information>
  </div>
</template>

<script>
import { mapState } from "vuex";

import ConnectionInformation from "@/components/ConnectionInformation";
import ProgressBar from "@/components/Utility/ProgressBar";

export default {
  components: {
    ConnectionInformation,
    ProgressBar,
  },
  computed: {
    ...mapState({
      version: (state) => state.electrs.version,
      syncPercent: (state) => state.electrs.syncPercent,
    }),
    progressBarPercentage() {
      return Math.max(0, Math.min(100, this.syncPercent));
    },
  },
  methods: {
    fetchData() {
      this.$store.dispatch("electrs/getSyncPercent");
      this.$store.dispatch("electrs/getVersion");
    },
  },
  created() {
    this.fetchData();
    this.$store.dispatch("electrs/getConnectionInformation");
    this.dataInterval = window.setInterval(this.fetchData, 10000);
  },
  beforeDestroy() {
    window.clearInterval(this.dataInterval);
  },
};
</script>

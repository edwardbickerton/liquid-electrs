<template>
  <div id="app" class="min-h-full w-full bg-slate-100 dark:bg-neutral-800">
    <div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
      <transition name="loading" mode="out-in">
        <div v-if="isIframe">
          <div class="flex flex-col items-center justify-center py-20">
            <img alt="Liquid Electrs" :src="appIconUrl" class="mb-5 logo" />
            <span class="max-w-md text-center text-gray-500 dark:text-neutral-300">
              <small>For security reasons this app cannot be embedded in an iframe.</small>
            </span>
          </div>
        </div>
        <loading v-else-if="loading" :progress="loadingProgress"></loading>
        <router-view v-else></router-view>
      </transition>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";

import Loading from "@/components/Loading";
import { appIconUrl } from "@/constants/assets";

export default {
  name: "App",
  components: {
    Loading,
  },
  data() {
    return {
      isIframe: window.self !== window.top,
      loading: true,
      loadingProgress: 0,
      loadingPollInProgress: false,
      appIconUrl,
    };
  },
  computed: {
    ...mapState({
      isApiOperational: (state) => state.system.api.operational,
    }),
  },
  methods: {
    async getLoadingStatus() {
      if (this.loadingPollInProgress) {
        return;
      }

      this.loadingPollInProgress = true;

      if (this.loadingProgress <= 40) {
        this.loadingProgress = 40;
        await this.$store.dispatch("system/getApi");

        if (!this.isApiOperational) {
          this.loading = true;
          this.loadingPollInProgress = false;
          return;
        }
      }

      this.loadingProgress = 100;
      this.loadingPollInProgress = false;

      setTimeout(() => {
        this.loading = false;
      }, 300);
    },
  },
  watch: {
    loading: {
      immediate: true,
      handler(isLoading) {
        window.clearInterval(this.loadingInterval);

        if (isLoading) {
          this.loadingInterval = window.setInterval(this.getLoadingStatus, 2000);
        } else {
          this.loadingInterval = window.setInterval(this.getLoadingStatus, 20000);
        }
      },
    },
  },
  beforeDestroy() {
    window.clearInterval(this.loadingInterval);
  },
};
</script>

<style lang="scss">
@import "@/styles/index.scss";
</style>

<style lang="scss" scoped>
.loading-enter-active,
.loading-leave-active {
  transition: opacity 0.4s ease;
}

.loading-enter,
.loading-leave-to {
  opacity: 0;
}

.loading-enter-to,
.loading-leave {
  opacity: 1;
}
</style>

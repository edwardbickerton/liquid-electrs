<template>
  <div class="mt-16">
    <p class="mb-8 text-lg text-neutral-900 dark:text-neutral-300">
      Use the following details to connect your wallet or application to Liquid Electrs.
    </p>
    <div class="flex flex-col md:grid md:grid-cols-12 md:gap-8">
      <div
        class="mt-8 flex justify-center sm:text-center md:col-span-4 md:mx-auto md:mt-0 md:max-w-2xl md:items-center md:text-left"
      >
        <div class="inline-block rounded-lg bg-white p-4 shadow">
          <qr-code
            :value="hasConnectionInfo ? connectionInfo.connectionString : ''"
            :size="220"
            class="qr-image mx-auto"
            show-logo
          ></qr-code>
        </div>
      </div>
      <div class="mt-4 md:col-span-8">
        <div class="flex flex-col items-center space-y-4 md:items-start">
          <div class="w-full">
            <label class="mb-1 block text-sm font-bold uppercase dark:text-slate-300">
              Address
            </label>
            <div v-if="hasConnectionInfo">
              <input-copy
                class="mb-2"
                size="sm"
                :value="connectionInfo.address"
              ></input-copy>
            </div>
            <span v-else class="loading-placeholder loading-placeholder-lg mt-1"></span>
          </div>
          <div class="mt-6 grid w-full grid-cols-1 gap-x-4 gap-y-6 md:grid-cols-6">
            <div class="flex flex-col md:col-span-3">
              <label class="mb-1 block text-sm font-bold uppercase dark:text-slate-300">
                Port
              </label>
              <div v-if="hasConnectionInfo">
                <input-copy
                  class="mb-2"
                  size="sm"
                  :value="connectionInfo.port.toString()"
                ></input-copy>
              </div>
              <span v-else class="loading-placeholder loading-placeholder-lg mt-1"></span>
            </div>
            <div class="flex flex-col md:col-span-3">
              <label class="mb-1 block text-sm font-bold uppercase dark:text-slate-300">
                SSL
              </label>
              <div v-if="hasConnectionInfo">
                <input-copy class="mb-2" size="sm" value="Disabled"></input-copy>
              </div>
              <span v-else class="loading-placeholder loading-placeholder-lg mt-1"></span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div
      class="mt-12 flex space-x-6 whitespace-nowrap border-t border-gray-300 dark:border-slate-200 dark:border-opacity-20"
    >
      <p class="mt-12 whitespace-normal text-lg text-neutral-900 dark:text-neutral-300">
        Looking for step-by-step instructions to connect Blockstream App?
        <a
          class="underline"
          href="https://github.com/edwardbickerton/liquid-electrs#connect-blockstream-app"
          target="_blank"
          rel="noreferrer"
        >
          Click here
        </a>.
      </p>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";

import QrCode from "@/components/Utility/QrCode";
import InputCopy from "@/components/Utility/InputCopy";

export default {
  components: {
    QrCode,
    InputCopy,
  },
  computed: {
    ...mapState({
      connectionInfo: (state) => state.electrs.connectionInfo.local,
    }),
    hasConnectionInfo() {
      return !!(
        this.connectionInfo &&
        this.connectionInfo.address &&
        this.connectionInfo.port &&
        this.connectionInfo.connectionString
      );
    },
  },
};
</script>

<style scoped>
.loading-placeholder {
  display: block;
  width: 100%;
  border-radius: 0.5rem;
  background: rgba(148, 163, 184, 0.2);
}

.loading-placeholder-lg {
  height: 3rem;
}

@media (prefers-color-scheme: dark) {
  .loading-placeholder {
    background: rgba(212, 212, 212, 0.15);
  }
}
</style>

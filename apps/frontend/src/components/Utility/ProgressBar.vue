<template>
  <div class="relative h-1 w-full overflow-hidden rounded-full bg-gray-200 dark:bg-neutral-700">
    <div
      class="progressbar h-full rounded-full"
      :class="colorClass"
      role="progressbar"
      :style="{ width: `${percentage}%` }"
      :aria-valuenow="percentage"
      aria-valuemin="0"
      aria-valuemax="100"
    >
      <span class="flex h-full items-center">
        <slot></slot>
      </span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    percentage: {
      type: Number,
      default: 0,
    },
    colorClass: {
      type: String,
      default: "bg-blue-500",
    },
  },
};
</script>

<style scoped>
.progressbar {
  transition: width 0.25s ease;
}
</style>

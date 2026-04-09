<template>
  <div class="skeleton-wrapper">
    <template v-if="type === 'card'">
      <div class="skeleton skeleton-card" />
    </template>
    <template v-else-if="type === 'chart'">
      <div class="skeleton skeleton-chart" />
    </template>
    <template v-else-if="type === 'kpi'">
      <div class="skeleton-kpi-row">
        <div v-for="i in count" :key="i" class="skeleton skeleton-card" style="height: 100px;" />
      </div>
    </template>
    <template v-else>
      <div v-for="i in count" :key="i" class="skeleton-text-group">
        <div class="skeleton skeleton-text" />
        <div class="skeleton skeleton-text skeleton-text--short" />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  type?: 'text' | 'card' | 'chart' | 'kpi'
  count?: number
}>(), {
  type: 'text',
  count: 4,
})
</script>

<style scoped>
.skeleton-wrapper {
  width: 100%;
}

.skeleton-text-group {
  margin-bottom: 16px;
}

.skeleton-kpi-row {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
}
</style>

<template>
  <div class="heatmap-wrapper">
    <div v-if="label" class="heatmap-label">{{ label }}</div>
    <div class="heatmap-grid" :style="gridStyle">
      <div
        v-for="(cell, i) in cells"
        :key="i"
        class="heatmap-cell"
        :style="{ background: getCellColor(cell.value) }"
        :title="`${cell.label}: ${cell.value}`"
      />
    </div>
    <div class="heatmap-legend">
      <span class="heatmap-legend-label">Меньше</span>
      <div
        v-for="(level, i) in legendLevels"
        :key="i"
        class="heatmap-legend-cell"
        :style="{ background: level }"
      />
      <span class="heatmap-legend-label">Больше</span>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  cells: Array<{ value: number; label: string }>
  columns?: number
  label?: string
  colorStart?: string
  colorEnd?: string
}>(), {
  columns: 7,
  colorStart: 'rgba(139, 126, 200, 0.06)',
  colorEnd: 'rgba(139, 126, 200, 0.6)',
})

const gridStyle = computed(() => ({
  gridTemplateColumns: `repeat(${props.columns}, 1fr)`,
}))

const maxValue = computed(() => Math.max(...props.cells.map(c => c.value), 1))

function getCellColor(value: number) {
  const ratio = value / maxValue.value
  if (ratio === 0) return 'rgba(139, 126, 200, 0.04)'
  const opacity = 0.08 + ratio * 0.52
  return `rgba(139, 126, 200, ${opacity})`
}

const legendLevels = computed(() => {
  return [0, 0.25, 0.5, 0.75, 1].map(r => {
    const opacity = 0.04 + r * 0.56
    return `rgba(139, 126, 200, ${opacity})`
  })
})
</script>

<style scoped>
.heatmap-wrapper {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.heatmap-label {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text-secondary);
}

.heatmap-grid {
  display: grid;
  gap: 3px;
}

.heatmap-cell {
  aspect-ratio: 1;
  border-radius: 3px;
  min-width: 14px;
  min-height: 14px;
  transition: transform var(--transition-fast);
  cursor: default;
}

.heatmap-cell:hover {
  transform: scale(1.2);
}

.heatmap-legend {
  display: flex;
  align-items: center;
  gap: 4px;
  justify-content: flex-end;
}

.heatmap-legend-label {
  font-size: 0.65rem;
  color: var(--color-text-muted);
}

.heatmap-legend-cell {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}
</style>

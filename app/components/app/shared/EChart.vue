<template>
  <div ref="chartRef" class="echart-wrapper" :style="{ height: `${height}px` }" />
</template>

<script setup lang="ts">
import { init as echartsInit } from 'echarts'
import type { EChartsOption, ECharts } from 'echarts'

const props = withDefaults(defineProps<{
  option: EChartsOption
  height?: number
  autoresize?: boolean
}>(), {
  height: 300,
  autoresize: true,
})

const chartRef = ref<HTMLElement>()
let chart: ECharts | null = null

const themeColors = {
  color: ['#8B7EC8', '#E8A0BF', '#A8C8E8', '#F2C4A0', '#7CB8D4', '#E9C46A', '#B8ADE8', '#D4727C'],
  textStyle: {
    fontFamily: 'Inter, system-ui, sans-serif',
    color: '#7B7394',
  },
  title: {
    textStyle: { fontFamily: 'Satoshi, system-ui, sans-serif', fontWeight: 700, color: '#4A4458' },
  },
}

function mergeTheme(opt: EChartsOption): EChartsOption {
  return {
    ...themeColors,
    ...opt,
    textStyle: { ...themeColors.textStyle, ...(opt.textStyle as Record<string, unknown> || {}) },
    grid: { left: 40, right: 16, top: 32, bottom: 32, containLabel: true, ...(opt.grid as Record<string, unknown> || {}) },
  }
}

onMounted(() => {
  if (!chartRef.value) return
  chart = echartsInit(chartRef.value)
  chart.setOption(mergeTheme(props.option))

  if (props.autoresize) {
    window.addEventListener('resize', handleResize)
  }
})

function handleResize() {
  chart?.resize()
}

watch(() => props.option, (opt) => {
  chart?.setOption(mergeTheme(opt), { notMerge: true })
}, { deep: true })

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  chart?.dispose()
  chart = null
})
</script>

<style scoped>
.echart-wrapper {
  width: 100%;
  min-height: 100px;
}
</style>

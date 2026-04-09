<template>
  <div class="analytics-page">
    <div class="page-header">
      <h1 class="page-title font-display">Удержание — когортный анализ</h1>
      <p class="page-desc">Процент семей, остающихся в маршруте через N месяцев после подключения</p>
    </div>

    <div class="chart-card">
      <AppSharedEChart :option="heatmapOption" height="400px" />
    </div>

    <div class="kpi-row">
      <div class="kpi-card">
        <span class="kpi-label">Retention 3 мес</span>
        <span class="kpi-val font-display">92%</span>
        <span class="trend-up">+3% vs пр. квартал</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Retention 6 мес</span>
        <span class="kpi-val font-display">87%</span>
        <span class="trend-up">+4%</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Retention 12 мес</span>
        <span class="kpi-val font-display">78%</span>
        <span class="trend-up">+6%</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Churn rate</span>
        <span class="kpi-val font-display">2.1%</span>
        <span class="trend-down">-0.5%</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const months = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн']
const periods = ['M1', 'M2', 'M3', 'M4', 'M5', 'M6']

// Generate cohort data
const data: [number, number, number][] = []
for (let y = 0; y < months.length; y++) {
  for (let x = 0; x < periods.length; x++) {
    if (x + y >= months.length) continue
    const base = 100 - x * (5 + Math.random() * 4)
    data.push([x, y, Math.round(base)])
  }
}

const heatmapOption = {
  tooltip: {
    formatter: (p: { data: number[] }) => `Когорта ${months[p.data[1]]}: ${p.data[2]}% через ${periods[p.data[0]]}`,
  },
  grid: { top: 40, right: 20, bottom: 40, left: 60 },
  xAxis: {
    type: 'category' as const,
    data: periods,
    axisLabel: { color: '#7B7394' },
    axisLine: { show: false },
    axisTick: { show: false },
  },
  yAxis: {
    type: 'category' as const,
    data: months,
    axisLabel: { color: '#7B7394' },
    axisLine: { show: false },
    axisTick: { show: false },
  },
  visualMap: {
    min: 50,
    max: 100,
    show: false,
    inRange: {
      color: ['#FDE8F0', '#E8A0BF', '#8B7EC8'],
    },
  },
  series: [{
    type: 'heatmap',
    data,
    itemStyle: { borderRadius: 4, borderWidth: 2, borderColor: '#FFFFFF' },
    label: { show: true, color: '#4A4458', fontSize: 11, fontWeight: 600, formatter: (p: { data: number[] }) => `${p.data[2]}%` },
  }],
}
</script>

<style scoped>
.analytics-page { max-width: 1000px; margin: 0 auto; display: flex; flex-direction: column; gap: 20px; }
.page-header { margin-bottom: 4px; }
.page-title { font-size: var(--text-h2); color: var(--color-text-primary); margin: 0 0 4px; }
.page-desc { font-size: var(--text-sm); color: var(--color-text-muted); margin: 0; }
.chart-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-lg); padding: 24px; }
.kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-md); padding: 16px; }
.kpi-label { font-size: var(--text-xs); color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
.kpi-val { display: block; font-size: 1.5rem; font-weight: 800; color: var(--color-primary); margin: 4px 0; }
.trend-up { font-size: var(--text-xs); color: var(--color-success); font-weight: 600; }
.trend-down { font-size: var(--text-xs); color: var(--color-danger); font-weight: 600; }
@media (max-width: 640px) { .kpi-row { grid-template-columns: repeat(2, 1fr); } }
</style>

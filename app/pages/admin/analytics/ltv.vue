<template>
  <div class="analytics-page">
    <div class="page-header">
      <h1 class="page-title font-display">LTV по когортам</h1>
      <p class="page-desc">Lifetime Value семьи по месяцу подключения</p>
    </div>

    <div class="kpi-row">
      <div class="kpi-card">
        <span class="kpi-label">Средний LTV</span>
        <span class="kpi-val font-display">1.8M ₸</span>
        <span class="trend-up">+15% vs пр. квартал</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">LTV / семья</span>
        <span class="kpi-val font-display">×4.2</span>
        <span class="trend-up">к среднему по рынку</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">CAC payback</span>
        <span class="kpi-val font-display">2.3 мес</span>
        <span class="trend-down">-0.4 мес</span>
      </div>
    </div>

    <div class="chart-card">
      <AppSharedEChart :option="ltvOption" height="350px" />
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const months = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек']
const ltvData = [980, 1050, 1120, 1280, 1350, 1480, 1520, 1680, 1720, 1800, 1850, 1920]
const trendLine = ltvData.map((_, i) => 900 + i * 90)

const ltvOption = {
  tooltip: { trigger: 'axis' as const },
  legend: { data: ['LTV (тыс. ₸)', 'Тренд'], top: 0, textStyle: { color: '#7B7394' } },
  grid: { top: 40, right: 20, bottom: 30, left: 60 },
  xAxis: {
    type: 'category' as const,
    data: months,
    axisLabel: { color: '#7B7394' },
    axisLine: { lineStyle: { color: '#E4DFF0' } },
  },
  yAxis: {
    type: 'value' as const,
    axisLabel: { color: '#7B7394', formatter: '{value}' },
    splitLine: { lineStyle: { color: '#F0EDF7' } },
  },
  series: [
    {
      name: 'LTV (тыс. ₸)',
      type: 'bar',
      data: ltvData,
      itemStyle: { color: '#8B7EC8', borderRadius: [4, 4, 0, 0] },
      barWidth: '50%',
    },
    {
      name: 'Тренд',
      type: 'line',
      data: trendLine,
      smooth: true,
      lineStyle: { color: '#E8A0BF', width: 2 },
      itemStyle: { color: '#E8A0BF' },
      symbol: 'none',
    },
  ],
}
</script>

<style scoped>
.analytics-page { max-width: 1000px; margin: 0 auto; display: flex; flex-direction: column; gap: 20px; }
.page-header { margin-bottom: 4px; }
.page-title { font-size: var(--text-h2); color: var(--color-text-primary); margin: 0 0 4px; }
.page-desc { font-size: var(--text-sm); color: var(--color-text-muted); margin: 0; }
.chart-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-lg); padding: 24px; }
.kpi-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-md); padding: 16px; }
.kpi-label { font-size: var(--text-xs); color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
.kpi-val { display: block; font-size: 1.5rem; font-weight: 800; color: var(--color-primary); margin: 4px 0; }
.trend-up { font-size: var(--text-xs); color: var(--color-success); font-weight: 600; }
.trend-down { font-size: var(--text-xs); color: var(--color-success); font-weight: 600; }
@media (max-width: 640px) { .kpi-row { grid-template-columns: 1fr; } }
</style>

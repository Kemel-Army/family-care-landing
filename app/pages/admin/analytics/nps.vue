<template>
  <div class="analytics-page">
    <div class="page-header">
      <h1 class="page-title font-display">NPS — Net Promoter Score</h1>
      <p class="page-desc">Оценка удовлетворённости семей платформой</p>
    </div>

    <div class="nps-grid">
      <div class="chart-card">
        <AppSharedEChart :option="gaugeOption" height="280px" />
      </div>

      <div class="nps-breakdown">
        <div class="nps-group nps-group--promoter">
          <span class="nps-group-label">Промоутеры (9-10)</span>
          <span class="nps-group-val font-mono">72%</span>
          <div class="nps-bar"><div class="nps-bar-fill" style="width: 72%; background: var(--color-success)" /></div>
        </div>
        <div class="nps-group nps-group--passive">
          <span class="nps-group-label">Нейтральные (7-8)</span>
          <span class="nps-group-val font-mono">20%</span>
          <div class="nps-bar"><div class="nps-bar-fill" style="width: 20%; background: var(--color-warning)" /></div>
        </div>
        <div class="nps-group nps-group--detractor">
          <span class="nps-group-label">Критики (0-6)</span>
          <span class="nps-group-val font-mono">8%</span>
          <div class="nps-bar"><div class="nps-bar-fill" style="width: 8%; background: var(--color-danger)" /></div>
        </div>
      </div>
    </div>

    <div class="chart-card">
      <h3 class="card-title">Тренд NPS по месяцам</h3>
      <AppSharedEChart :option="trendOption" height="250px" />
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const gaugeOption = {
  series: [{
    type: 'gauge',
    startAngle: 180,
    endAngle: 0,
    min: -100,
    max: 100,
    center: ['50%', '70%'],
    radius: '90%',
    progress: { show: true, width: 18, itemStyle: { color: '#8B7EC8' } },
    pointer: { show: false },
    axisLine: { lineStyle: { width: 18, color: [[0.5, '#E4DFF0'], [1, '#E4DFF0']] } },
    axisTick: { show: false },
    splitLine: { show: false },
    axisLabel: { show: false },
    detail: {
      valueAnimation: true,
      formatter: '{value}',
      fontSize: 36,
      fontWeight: 800,
      fontFamily: 'Satoshi',
      color: '#8B7EC8',
      offsetCenter: [0, '-10%'],
    },
    title: { show: true, offsetCenter: [0, '20%'], fontSize: 14, color: '#7B7394' },
    data: [{ value: 64, name: 'NPS Score' }],
  }],
}

const months = ['Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек', 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн']
const npsValues = [48, 52, 55, 56, 58, 60, 58, 61, 63, 62, 64, 64]

const trendOption = {
  grid: { top: 20, right: 20, bottom: 30, left: 40 },
  xAxis: {
    type: 'category' as const,
    data: months,
    axisLabel: { color: '#7B7394' },
    axisLine: { lineStyle: { color: '#E4DFF0' } },
  },
  yAxis: {
    type: 'value' as const,
    min: 30,
    max: 80,
    axisLabel: { color: '#7B7394' },
    splitLine: { lineStyle: { color: '#F0EDF7' } },
  },
  series: [{
    type: 'line',
    data: npsValues,
    smooth: true,
    areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(139, 126, 200, 0.2)' }, { offset: 1, color: 'rgba(139, 126, 200, 0)' }] } },
    lineStyle: { color: '#8B7EC8', width: 2.5 },
    itemStyle: { color: '#8B7EC8' },
    symbol: 'circle',
    symbolSize: 6,
  }],
}
</script>

<style scoped>
.analytics-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 20px; }
.page-header { margin-bottom: 4px; }
.page-title { font-size: var(--text-h2); color: var(--color-text-primary); margin: 0 0 4px; }
.page-desc { font-size: var(--text-sm); color: var(--color-text-muted); margin: 0; }
.chart-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-lg); padding: 24px; }
.card-title { font-family: var(--font-display); font-size: 1rem; font-weight: 600; color: var(--color-text-primary); margin: 0 0 16px; }
.nps-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.nps-breakdown { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-lg); padding: 24px; display: flex; flex-direction: column; justify-content: center; gap: 16px; }
.nps-group { }
.nps-group-label { font-size: var(--text-sm); color: var(--color-text-secondary); }
.nps-group-val { font-size: var(--text-body-lg); font-weight: 700; color: var(--color-text-primary); float: right; }
.nps-bar { height: 8px; background: var(--color-border-light); border-radius: 4px; overflow: hidden; margin-top: 6px; }
.nps-bar-fill { height: 100%; border-radius: 4px; }
@media (max-width: 640px) { .nps-grid { grid-template-columns: 1fr; } }
</style>

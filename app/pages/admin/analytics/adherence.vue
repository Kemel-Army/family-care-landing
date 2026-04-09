<template>
  <div class="analytics-page">
    <div class="page-header">
      <h1 class="page-title font-display">Adherence — соблюдение назначений</h1>
      <p class="page-desc">Распределение семей по уровню соблюдения назначений</p>
    </div>

    <div class="kpi-row">
      <div class="kpi-card">
        <span class="kpi-label">Средний adherence</span>
        <span class="kpi-val font-display">87%</span>
        <span class="trend-up">+4% vs пр. месяц</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Семей > 90%</span>
        <span class="kpi-val font-display">142</span>
      </div>
      <div class="kpi-card">
        <span class="kpi-label">Семей < 50%</span>
        <span class="kpi-val font-display kpi-val--danger">12</span>
        <span class="trend-warning">Координаторы уведомлены</span>
      </div>
    </div>

    <div class="chart-card">
      <h3 class="card-title">Распределение adherence по семьям</h3>
      <AppSharedEChart :option="histogramOption" height="300px" />
    </div>

    <!-- Low adherence families alert -->
    <div class="alert-card">
      <div class="alert-header">
        <Icon name="lucide:alert-triangle" size="18" style="color: var(--color-danger)" />
        <h3 class="alert-title">Семьи с adherence &lt; 50%</h3>
        <span class="alert-count">12 семей</span>
      </div>
      <div class="alert-list">
        <div v-for="f in lowAdherenceFamilies" :key="f.name" class="alert-row">
          <span class="alert-name">{{ f.name }}</span>
          <span class="alert-stage">{{ f.stage }}</span>
          <span class="alert-pct font-mono" style="color: var(--color-danger)">{{ f.adherence }}%</span>
          <span class="alert-coord">{{ f.coordinator }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const lowAdherenceFamilies = [
  { name: 'Каримова А.', stage: 'Беременность · 24 нед', adherence: 45, coordinator: 'Динара С.' },
  { name: 'Оспанова М.', stage: 'Малыш · 3 мес', adherence: 38, coordinator: 'Айнур К.' },
  { name: 'Кенесова Д.', stage: 'Беременность · 18 нед', adherence: 42, coordinator: 'Динара С.' },
]

const ranges = ['0-20%', '20-40%', '40-60%', '60-80%', '80-100%']
const counts = [3, 9, 18, 76, 142]

const histogramOption = {
  tooltip: { trigger: 'axis' as const },
  grid: { top: 20, right: 20, bottom: 30, left: 50 },
  xAxis: {
    type: 'category' as const,
    data: ranges,
    axisLabel: { color: '#7B7394' },
    axisLine: { lineStyle: { color: '#E4DFF0' } },
  },
  yAxis: {
    type: 'value' as const,
    axisLabel: { color: '#7B7394' },
    splitLine: { lineStyle: { color: '#F0EDF7' } },
  },
  series: [{
    type: 'bar',
    data: counts.map((v, i) => ({
      value: v,
      itemStyle: {
        color: i < 2 ? '#D4727C' : i === 2 ? '#E9C46A' : '#8B7EC8',
        borderRadius: [4, 4, 0, 0],
      },
    })),
    barWidth: '60%',
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
.kpi-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-md); padding: 16px; }
.kpi-label { font-size: var(--text-xs); color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
.kpi-val { display: block; font-size: 1.5rem; font-weight: 800; color: var(--color-primary); margin: 4px 0; }
.kpi-val--danger { color: var(--color-danger); }
.trend-up { font-size: var(--text-xs); color: var(--color-success); font-weight: 600; }
.trend-warning { font-size: var(--text-xs); color: var(--color-warning); font-weight: 600; }
.alert-card { background: white; border: 1px solid rgba(212,114,124,0.2); border-radius: var(--radius-lg); padding: 20px; }
.alert-header { display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }
.alert-title { font-size: 0.9rem; font-weight: 600; margin: 0; flex: 1; }
.alert-count { font-size: var(--text-xs); color: var(--color-danger); font-weight: 600; }
.alert-list { display: flex; flex-direction: column; gap: 4px; }
.alert-row { display: flex; align-items: center; gap: 12px; padding: 8px 12px; border-radius: 8px; background: rgba(212,114,124,0.03); }
.alert-name { font-weight: 600; font-size: var(--text-sm); min-width: 120px; }
.alert-stage { flex: 1; font-size: var(--text-xs); color: var(--color-text-muted); }
.alert-pct { font-weight: 700; font-size: var(--text-sm); }
.alert-coord { font-size: var(--text-xs); color: var(--color-text-muted); }
@media (max-width: 640px) { .kpi-row { grid-template-columns: 1fr; } }
</style>

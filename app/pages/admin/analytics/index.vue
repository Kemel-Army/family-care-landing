<template>
  <div class="anl-page">
    <!-- Hero -->
    <div class="anl-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="anl-hero-title">Аналитика</h1>
      <p class="anl-hero-sub">Метрики клиники за последние 30 дней</p>
      <div class="nav-sub">
        <NuxtLink to="/admin/analytics/doctors" class="nav-pill">Врачи</NuxtLink>
        <NuxtLink to="/admin/analytics/revenue" class="nav-pill">Доходы</NuxtLink>
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid">
      <div v-for="k in kpis" :key="k.label" class="kpi-card">
        <span class="kpi-label">{{ k.label }}</span>
        <span class="kpi-value">{{ k.value }}</span>
        <span class="kpi-desc">{{ k.desc }}</span>
      </div>
    </div>

    <!-- Adherence Trend Chart -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:trending-up" size="16" /> Адгеренс за 30 дней</h2>
      <AppSharedEChart :option="adherenceChart" height="220px" />
    </div>

    <!-- Doctor Performance -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:stethoscope" size="16" /> Результативность врачей</h2>
      <div class="perf-list">
        <div v-for="d in mock.doctorPerformance" :key="d.name" class="perf-row">
          <div class="perf-avatar">{{ d.name.charAt(0) }}</div>
          <div class="perf-info">
            <span class="perf-name">{{ d.name }}</span>
            <span class="perf-spec">{{ d.specialty }}</span>
          </div>
          <div class="perf-metrics">
            <span class="perf-m"><strong>{{ d.visits }}</strong> визит.</span>
            <span class="perf-m"><strong>{{ d.rating }}</strong> ★</span>
          </div>
          <div class="perf-bar-wrap">
            <div class="perf-bar" :style="{ width: `${d.load}%` }" :class="d.load > 90 ? 'high' : d.load > 70 ? 'normal' : 'low'" />
          </div>
          <span class="perf-pct">{{ d.load }}%</span>
        </div>
      </div>
    </div>

    <!-- Retention Cohort -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:users" size="16" /> Retention когорт</h2>
      <div class="cohort-table">
        <div class="cohort-header">
          <span class="cohort-cell head">Когорта</span>
          <span class="cohort-cell head">M0</span>
          <span class="cohort-cell head">M1</span>
          <span class="cohort-cell head">M2</span>
          <span class="cohort-cell head">M3</span>
        </div>
        <div v-for="c in mock.retentionCohort" :key="c.cohort" class="cohort-row">
          <span class="cohort-cell label">{{ c.cohort }}</span>
          <span class="cohort-cell" :style="cohortStyle(c.m0)">{{ c.m0 }}%</span>
          <span class="cohort-cell" :style="cohortStyle(c.m1)">{{ c.m1 != null ? `${c.m1}%` : '—' }}</span>
          <span class="cohort-cell" :style="cohortStyle(c.m2)">{{ c.m2 != null ? `${c.m2}%` : '—' }}</span>
          <span class="cohort-cell" :style="cohortStyle(c.m3)">{{ c.m3 != null ? `${c.m3}%` : '—' }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const kpis = [
  { label: 'Конверсия маршрутов', value: '74%', desc: 'Завершённых от общего числа' },
  { label: 'Ср. адгеренс', value: '91%', desc: 'Соблюдение назначений' },
  { label: 'NPS', value: String(mock.npsScore), desc: 'Net Promoter Score' },
  { label: 'Активных семей', value: String(mock.adminKpi.activeFamilies.value), desc: 'За последние 30 дней' },
  { label: 'ARPU', value: '28 500 ₸', desc: 'Доход на семью' },
  { label: 'Retention', value: '89%', desc: 'Возврат семей' },
]

const adherenceChart = computed(() => ({
  grid: { top: 10, right: 16, bottom: 24, left: 36 },
  xAxis: { type: 'category', data: mock.adherenceTrend.map((_, i) => `${i + 1}`), axisLabel: { fontSize: 10, color: '#999' }, axisLine: { show: false }, axisTick: { show: false } },
  yAxis: { type: 'value', min: 80, max: 100, axisLabel: { fontSize: 10, color: '#999', formatter: '{value}%' }, splitLine: { lineStyle: { color: '#f0f0f0' } } },
  series: [{
    type: 'line', data: mock.adherenceTrend.map(d => d.value), smooth: true,
    lineStyle: { color: '#8B7EC8', width: 2 },
    areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(139,126,200,0.15)' }, { offset: 1, color: 'rgba(139,126,200,0)' }] } },
    symbol: 'none',
  }],
  tooltip: { trigger: 'axis', formatter: (p: any) => `День ${p[0].name}: ${p[0].value}%` },
}))

function cohortStyle(val?: number) {
  if (val == null) return {}
  const alpha = Math.max(0.05, val / 120)
  return { background: `rgba(139,126,200,${alpha})` }
}
</script>

<style scoped>
.anl-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.anl-hero {
  background: linear-gradient(135deg, rgba(168,200,232,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(168,200,232,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.anl-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.anl-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.nav-sub { display: flex; gap: 8px; margin-top: 12px; }
.nav-pill { padding: 5px 14px; background: rgba(139,126,200,0.08); border: 1px solid rgba(139,126,200,0.15); border-radius: 20px; font-size: 0.75rem; font-weight: 600; color: var(--color-primary); text-decoration: none; transition: all 0.15s; }
.nav-pill:hover { background: rgba(139,126,200,0.14); }

.kpi-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 10px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 14px; }
.kpi-label { font-size: 0.7rem; color: var(--color-text-muted); display: block; }
.kpi-value { font-size: 1.3rem; font-weight: 800; font-family: var(--font-mono); display: block; margin: 2px 0; }
.kpi-desc { font-size: 0.65rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.perf-list { display: flex; flex-direction: column; gap: 10px; }
.perf-row { display: flex; align-items: center; gap: 10px; }
.perf-avatar { width: 32px; height: 32px; border-radius: 50%; background: rgba(139,126,200,0.1); color: var(--color-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.78rem; flex-shrink: 0; }
.perf-info { flex: 1; min-width: 0; }
.perf-name { display: block; font-size: 0.82rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.perf-spec { font-size: 0.68rem; color: var(--color-text-muted); }
.perf-metrics { display: flex; gap: 10px; font-size: 0.72rem; color: var(--color-text-muted); }
.perf-metrics strong { color: var(--color-text); font-family: var(--font-mono); }
.perf-bar-wrap { width: 80px; height: 6px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; flex-shrink: 0; }
.perf-bar { height: 100%; border-radius: 3px; transition: width 0.4s; }
.perf-bar.low { background: rgba(168,200,232,0.5); }
.perf-bar.normal { background: var(--color-primary); }
.perf-bar.high { background: var(--color-danger); }
.perf-pct { font-size: 0.72rem; font-weight: 700; font-family: var(--font-mono); width: 32px; text-align: right; }

.cohort-table { display: flex; flex-direction: column; gap: 2px; }
.cohort-header, .cohort-row { display: grid; grid-template-columns: 100px repeat(4, 1fr); gap: 2px; }
.cohort-cell { padding: 8px 6px; text-align: center; font-size: 0.78rem; font-family: var(--font-mono); border-radius: 4px; }
.cohort-cell.head { font-size: 0.68rem; color: var(--color-text-muted); font-weight: 600; font-family: var(--font-body); }
.cohort-cell.label { text-align: left; font-family: var(--font-body); font-weight: 500; font-size: 0.75rem; }
</style>

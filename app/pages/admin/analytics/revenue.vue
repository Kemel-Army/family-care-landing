<template>
  <div class="rev-page">
    <div class="rev-hero">
      <NuxtLink to="/admin/analytics" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Аналитика</NuxtLink>
      <h1 class="rev-hero-title">Revenue Intelligence</h1>
      <div class="period-row">
        <button v-for="p in periods" :key="p" class="period-btn" :class="{ active: active === p }" @click="active = p">{{ p }}</button>
      </div>
    </div>

    <!-- KPI -->
    <div class="kpi-grid">
      <div class="kpi-card"><span class="kpi-label">MRR</span><span class="kpi-value">2.4M ₸</span><span class="kpi-delta up">+14%</span></div>
      <div class="kpi-card"><span class="kpi-label">ARPU</span><span class="kpi-value">28.5K ₸</span></div>
      <div class="kpi-card"><span class="kpi-label">Avg LTV</span><span class="kpi-value">340K ₸</span></div>
      <div class="kpi-card"><span class="kpi-label">Churn</span><span class="kpi-value">3.2%</span></div>
    </div>

    <!-- Revenue Chart -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:bar-chart-3" size="16" /> Доход по месяцам</h2>
      <AppSharedEChart :option="revenueChart" height="240px" />
    </div>

    <!-- Doctor Revenue -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:stethoscope" size="16" /> Доход по врачам</h2>
      <div class="doc-table">
        <div class="dt-header">
          <span class="dt-cell name">Врач</span>
          <span class="dt-cell">Визиты</span>
          <span class="dt-cell">Рейтинг</span>
          <span class="dt-cell">Загрузка</span>
        </div>
        <div v-for="d in mock.doctorPerformance" :key="d.name" class="dt-row">
          <span class="dt-cell name">{{ d.name }}</span>
          <span class="dt-cell mono">{{ d.visits }}</span>
          <span class="dt-cell mono">{{ d.rating }} ★</span>
          <span class="dt-cell mono">{{ d.load }}%</span>
        </div>
      </div>
    </div>

    <!-- Forecast -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:rocket" size="16" /> Прогноз на 3 месяца</h2>
      <div class="forecast-grid">
        <div v-for="(f, i) in forecasts" :key="i" class="forecast-card">
          <span class="fc-month">{{ f.month }}</span>
          <span class="fc-value">{{ f.value }}</span>
          <span class="fc-lbl">прогноз</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const active = ref('Месяц')
const periods = ['Неделя', 'Месяц', 'Квартал']

const forecasts = [
  { month: 'Май 2026', value: '2.7M ₸' },
  { month: 'Июнь 2026', value: '2.9M ₸' },
  { month: 'Июль 2026', value: '3.1M ₸' },
]

const revenueChart = computed(() => ({
  grid: { top: 10, right: 16, bottom: 24, left: 50 },
  xAxis: { type: 'category', data: mock.revenueMonthly.map(r => r.month), axisLabel: { fontSize: 10, color: '#999' }, axisLine: { show: false }, axisTick: { show: false } },
  yAxis: { type: 'value', axisLabel: { fontSize: 10, color: '#999', formatter: (v: number) => `${(v / 1000000).toFixed(1)}M` }, splitLine: { lineStyle: { color: '#f0f0f0' } } },
  series: [
    { type: 'bar', name: 'Консультации', data: mock.revenueMonthly.map(r => r.consultations), stack: 'rev', itemStyle: { color: '#8B7EC8', borderRadius: [0, 0, 0, 0] } },
    { type: 'bar', name: 'Пакеты', data: mock.revenueMonthly.map(r => r.packages), stack: 'rev', itemStyle: { color: '#E8A0BF' } },
    { type: 'bar', name: 'Лаборатория', data: mock.revenueMonthly.map(r => r.lab), stack: 'rev', itemStyle: { color: '#A8C8E8', borderRadius: [4, 4, 0, 0] } },
  ],
  tooltip: { trigger: 'axis' },
  legend: { show: false },
}))
</script>

<style scoped>
.rev-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.rev-hero {
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.rev-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.period-row { display: flex; gap: 6px; margin-top: 12px; }
.period-btn { padding: 5px 14px; border: 1px solid var(--color-border-light); border-radius: 20px; background: white; font-size: 0.75rem; cursor: pointer; font-family: var(--font-body); transition: all 0.15s; }
.period-btn.active { border-color: var(--color-primary); background: rgba(139,126,200,0.08); color: var(--color-primary); font-weight: 600; }

.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 14px; display: flex; flex-direction: column; gap: 2px; }
.kpi-label { font-size: 0.68rem; color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
.kpi-value { font-size: 1.3rem; font-weight: 800; font-family: var(--font-mono); }
.kpi-delta { font-size: 0.68rem; font-weight: 700; }
.kpi-delta.up { color: var(--color-success); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.doc-table { display: flex; flex-direction: column; }
.dt-header, .dt-row { display: grid; grid-template-columns: 1fr 70px 70px 70px; gap: 8px; padding: 8px 4px; }
.dt-header { border-bottom: 1px solid var(--color-border-light); }
.dt-cell { font-size: 0.78rem; }
.dt-cell.name { font-weight: 600; }
.dt-cell.mono { font-family: var(--font-mono); text-align: center; }
.dt-header .dt-cell { font-size: 0.68rem; color: var(--color-text-muted); font-weight: 600; }

.forecast-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
.forecast-card {
  padding: 18px; text-align: center; border-radius: 12px;
  background: linear-gradient(135deg, rgba(139,126,200,0.06), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.1);
}
.fc-month { font-size: 0.72rem; color: var(--color-text-muted); display: block; }
.fc-value { font-size: 1.1rem; font-weight: 800; font-family: var(--font-mono); display: block; margin: 4px 0; }
.fc-lbl { font-size: 0.62rem; color: var(--color-text-muted); }
</style>

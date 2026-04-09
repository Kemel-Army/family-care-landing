<template>
  <div class="cap-page">
    <div class="cap-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="cap-hero-title">Планирование мощности</h1>
      <p class="cap-hero-sub">Загрузка ресурсов клиники</p>
    </div>

    <!-- KPI -->
    <div class="kpi-grid">
      <div class="kpi-card"><Icon name="lucide:users" size="18" class="kpi-icon" /><span class="kpi-value">47</span><span class="kpi-label">Активных маршрутов</span></div>
      <div class="kpi-card"><Icon name="lucide:calendar" size="18" class="kpi-icon" /><span class="kpi-value">96</span><span class="kpi-label">Слотов/нед</span></div>
      <div class="kpi-card"><Icon name="lucide:trending-up" size="18" class="kpi-icon" /><span class="kpi-value">78%</span><span class="kpi-label">Загрузка</span></div>
      <div class="kpi-card"><Icon name="lucide:alert-triangle" size="18" class="kpi-icon warn" /><span class="kpi-value">2</span><span class="kpi-label">Узкие места</span></div>
    </div>

    <!-- Heatmap -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:grid-3x3" size="16" /> Загрузка по дням</h2>
      <div class="heatmap">
        <div v-for="(day, di) in heatDays" :key="di" class="hm-row">
          <span class="hm-day">{{ day }}</span>
          <div class="hm-cells">
            <div v-for="h in 9" :key="h" class="hm-cell" :class="heatClass(di * 9 + h - 1)" :title="`${day} ${8 + h}:00 — ${mock.capacityHeatmap[di * 9 + h - 1]?.value || 0} записей`" />
          </div>
        </div>
        <div class="hm-hours">
          <span v-for="h in 9" :key="h">{{ 8 + h }}</span>
        </div>
      </div>
      <div class="hm-legend">
        <span class="lg"><span class="lg-box l0" /> 0</span>
        <span class="lg"><span class="lg-box l1" /> 1–3</span>
        <span class="lg"><span class="lg-box l2" /> 4–7</span>
        <span class="lg"><span class="lg-box l3" /> 8+</span>
      </div>
    </div>

    <!-- Forecast -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:calendar-range" size="16" /> Прогноз спроса (4 недели)</h2>
      <div class="fc-list">
        <div v-for="(f, i) in forecasts" :key="i" class="fc-row">
          <span class="fc-week">{{ f.week }}</span>
          <div class="fc-track"><div class="fc-fill" :style="{ width: `${f.pct}%` }" /></div>
          <span class="fc-val">{{ f.visits }} виз.</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const heatDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']

function heatClass(idx: number) {
  const v = mock.capacityHeatmap[idx]?.value || 0
  if (v >= 8) return 'l3'
  if (v >= 4) return 'l2'
  if (v >= 1) return 'l1'
  return 'l0'
}

const forecasts = [
  { week: '14–20 апр', visits: 42, pct: 84 },
  { week: '21–27 апр', visits: 38, pct: 76 },
  { week: '28 апр–4 мая', visits: 46, pct: 92 },
  { week: '5–11 мая', visits: 50, pct: 100 },
]
</script>

<style scoped>
.cap-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.cap-hero {
  background: linear-gradient(135deg, rgba(168,200,232,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(168,200,232,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.cap-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.cap-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 10px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px; text-align: center; }
.kpi-icon { color: var(--color-primary); margin-bottom: 4px; }
.kpi-icon.warn { color: var(--color-warning); }
.kpi-value { display: block; font-size: 1.4rem; font-weight: 800; font-family: var(--font-mono); }
.kpi-label { font-size: 0.7rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.heatmap { display: flex; flex-direction: column; gap: 3px; }
.hm-row { display: flex; align-items: center; gap: 6px; }
.hm-day { width: 22px; font-size: 0.68rem; color: var(--color-text-muted); }
.hm-cells { display: flex; gap: 3px; }
.hm-cell { width: 28px; height: 18px; border-radius: 3px; transition: background 0.2s; }
.hm-cell.l0 { background: var(--color-border-light); }
.hm-cell.l1 { background: rgba(139,126,200,0.2); }
.hm-cell.l2 { background: rgba(139,126,200,0.5); }
.hm-cell.l3 { background: var(--color-primary); }

.hm-hours { display: flex; gap: 3px; padding-left: 28px; margin-top: 2px; }
.hm-hours span { width: 28px; text-align: center; font-size: 0.58rem; color: var(--color-text-muted); }

.hm-legend { display: flex; gap: 12px; margin-top: 10px; }
.lg { display: flex; align-items: center; gap: 4px; font-size: 0.65rem; color: var(--color-text-muted); }
.lg-box { width: 10px; height: 10px; border-radius: 2px; }
.lg-box.l0 { background: var(--color-border-light); }
.lg-box.l1 { background: rgba(139,126,200,0.2); }
.lg-box.l2 { background: rgba(139,126,200,0.5); }
.lg-box.l3 { background: var(--color-primary); }

.fc-list { display: flex; flex-direction: column; gap: 8px; }
.fc-row { display: flex; align-items: center; gap: 12px; }
.fc-week { width: 110px; font-size: 0.78rem; flex-shrink: 0; }
.fc-track { flex: 1; height: 8px; background: var(--color-border-light); border-radius: 4px; overflow: hidden; }
.fc-fill { height: 100%; background: var(--gradient-cta); border-radius: 4px; transition: width 0.4s; }
.fc-val { width: 60px; text-align: right; font-size: 0.78rem; font-family: var(--font-mono); font-weight: 600; }
</style>

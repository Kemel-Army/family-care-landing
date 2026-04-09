<template>
  <div class="sleep-page">
    <!-- Hero -->
    <div class="sleep-hero">
      <div>
        <h1 class="sleep-hero-title">Сон</h1>
        <p class="sleep-hero-sub">{{ mock.children[0].first_name }} · Трекер сна</p>
      </div>
      <div class="sleep-hero-total">
        <Icon name="lucide:moon" size="20" style="color: var(--color-primary)" />
        <span class="sleep-hero-val">{{ avgTotal.toFixed(1) }}ч</span>
        <span class="sleep-hero-lbl">среднее/день</span>
      </div>
    </div>

    <!-- Week chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:bar-chart-3" size="16" /> За неделю</h2>
      </div>
      <AppSharedEChart :option="sleepChartOption" style="height: 200px" />
    </div>

    <!-- Today logs -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:list" size="16" /> Сегодня</h2>
      </div>
      <div class="sleep-logs">
        <div class="sleep-log-row">
          <div class="sleep-log-icon sleep-log-icon--night"><Icon name="lucide:moon" size="14" /></div>
          <div class="sleep-log-info">
            <span class="sleep-log-name">Ночной сон</span>
            <span class="sleep-log-time">21:00 — 06:30</span>
          </div>
          <span class="sleep-log-dur">9ч 30мин</span>
        </div>
        <div class="sleep-log-row">
          <div class="sleep-log-icon sleep-log-icon--nap"><Icon name="lucide:sun" size="14" /></div>
          <div class="sleep-log-info">
            <span class="sleep-log-name">Дневной сон</span>
            <span class="sleep-log-time">12:00 — 14:00</span>
          </div>
          <span class="sleep-log-dur">2ч 0мин</span>
        </div>
      </div>
    </div>

    <!-- Streak -->
    <div class="card sleep-streak">
      <Icon name="lucide:flame" size="20" style="color: var(--color-warning)" />
      <div>
        <span class="streak-val">{{ mock.streaks.sleep.current }} дней</span>
        <span class="streak-lbl">серия записей сна · рекорд {{ mock.streaks.sleep.longest }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const avgTotal = computed(() => {
  const w = mock.sleepWeek
  return w.reduce((s, d) => s + d.night + d.nap, 0) / w.length
})

const sleepChartOption = computed(() => ({
  grid: { top: 20, right: 8, bottom: 24, left: 38 },
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category', data: mock.sleepWeek.map(d => d.date), axisLine: { lineStyle: { color: '#e0dce8' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  yAxis: { type: 'value', name: 'часы', nameTextStyle: { color: '#9690a8', fontSize: 11 }, axisLine: { show: false }, splitLine: { lineStyle: { color: '#f0eef5' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  series: [
    {
      name: 'Ночной', type: 'bar', stack: 'sleep', data: mock.sleepWeek.map(d => d.night),
      itemStyle: { color: '#8B7EC8', borderRadius: [0, 0, 4, 4] }, barWidth: '40%',
    },
    {
      name: 'Дневной', type: 'bar', stack: 'sleep', data: mock.sleepWeek.map(d => d.nap),
      itemStyle: { color: '#E8A0BF', borderRadius: [4, 4, 0, 0] }, barWidth: '40%',
    },
  ],
}))
</script>

<style scoped>
.sleep-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.sleep-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(168,200,232,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.sleep-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.sleep-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.sleep-hero-total { display: flex; align-items: center; gap: 8px; }
.sleep-hero-val { font-size: 1.3rem; font-weight: 700; font-family: var(--font-mono); }
.sleep-hero-lbl { font-size: 0.68rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.sleep-logs { display: flex; flex-direction: column; gap: 6px; }
.sleep-log-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.sleep-log-row:hover { background: rgba(139,126,200,0.04); }
.sleep-log-icon { width: 32px; height: 32px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.sleep-log-icon--night { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.sleep-log-icon--nap { background: rgba(242,196,160,0.12); color: var(--color-text-secondary); }
.sleep-log-info { flex: 1; }
.sleep-log-name { display: block; font-size: 0.85rem; font-weight: 500; }
.sleep-log-time { display: block; font-size: 0.72rem; color: var(--color-text-muted); }
.sleep-log-dur { font-size: 0.85rem; font-weight: 600; font-family: var(--font-mono); color: var(--color-primary); }

.sleep-streak {
  display: flex; align-items: center; gap: 12px;
}
.streak-val { font-size: 0.92rem; font-weight: 700; display: block; }
.streak-lbl { font-size: 0.72rem; color: var(--color-text-muted); }
</style>

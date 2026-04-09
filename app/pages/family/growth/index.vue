<template>
  <div class="grow-page">
    <!-- Hero -->
    <div class="grow-hero">
      <div>
        <h1 class="grow-hero-title">Рост и развитие</h1>
        <p class="grow-hero-sub">{{ mock.children[0].first_name }} · {{ achievedCount }}/{{ mock.milestones.length }} вех</p>
      </div>
      <div class="grow-hero-metrics">
        <div class="grow-metric">
          <span class="grow-metric-val">{{ latestWeight }} <small>кг</small></span>
          <span class="grow-metric-lbl">Вес</span>
        </div>
        <div class="grow-metric">
          <span class="grow-metric-val">{{ latestHeight }} <small>см</small></span>
          <span class="grow-metric-lbl">Рост</span>
        </div>
        <div class="grow-metric">
          <span class="grow-metric-val">{{ latestHead }} <small>см</small></span>
          <span class="grow-metric-lbl">Голова</span>
        </div>
      </div>
    </div>

    <!-- Weight chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:trending-up" size="16" /> Кривая роста (вес)</h2>
      </div>
      <div class="chart-wrap">
        <AppSharedEChart :option="weightChartOption" style="height: 240px" />
      </div>
    </div>

    <!-- Milestones -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:star" size="16" /> Вехи развития</h2>
        <span class="card-badge">{{ achievedCount }}/{{ mock.milestones.length }}</span>
      </div>
      <div class="ms-list">
        <div v-for="ms in mock.milestones" :key="ms.id" class="ms-row" :class="{ 'ms-row--done': ms.achieved }">
          <div class="ms-dot" :class="{ 'ms-dot--done': ms.achieved }">
            <Icon :name="ms.achieved ? 'lucide:check' : ms.icon" size="14" />
          </div>
          <div class="ms-info">
            <span class="ms-name">{{ ms.name }}</span>
            <span class="ms-meta">{{ ms.expected }}{{ ms.achieved ? ' · ' + formatDate(ms.date) : '' }}</span>
          </div>
          <span v-if="ms.achieved" class="ms-badge ms-badge--done">Достигнуто</span>
          <span v-else class="ms-badge ms-badge--pending">Ожидается</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const g = mock.growthData
const latestWeight = g.weight[g.weight.length - 1]
const latestHeight = g.height[g.height.length - 1]
const latestHead = g.head[g.head.length - 1]
const achievedCount = computed(() => mock.milestones.filter(m => m.achieved).length)

const weightChartOption = computed(() => ({
  grid: { top: 30, right: 16, bottom: 30, left: 42 },
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category', data: g.months.map(m => `${m} мес`), axisLine: { lineStyle: { color: '#e0dce8' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  yAxis: { type: 'value', name: 'кг', nameTextStyle: { color: '#9690a8', fontSize: 11 }, axisLine: { show: false }, splitLine: { lineStyle: { color: '#f0eef5' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  series: [
    { name: '3-й перцентиль', type: 'line', data: g.whoWeight3rd, lineStyle: { type: 'dashed', color: '#d4d0e0', width: 1 }, symbol: 'none', itemStyle: { color: '#d4d0e0' } },
    { name: '50-й перцентиль', type: 'line', data: g.whoWeight50th, lineStyle: { type: 'dashed', color: '#b8b0d0', width: 1 }, symbol: 'none', itemStyle: { color: '#b8b0d0' } },
    { name: '97-й перцентиль', type: 'line', data: g.whoWeight97th, lineStyle: { type: 'dashed', color: '#d4d0e0', width: 1 }, symbol: 'none', itemStyle: { color: '#d4d0e0' } },
    { name: 'Вес ребёнка', type: 'line', data: g.weight, lineStyle: { color: '#8B7EC8', width: 3 }, symbol: 'circle', symbolSize: 8, itemStyle: { color: '#8B7EC8', borderColor: '#fff', borderWidth: 2 }, areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(139,126,200,0.18)' }, { offset: 1, color: 'rgba(139,126,200,0)' }] } } },
  ],
}))

function formatDate(iso: string) {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}
</script>

<style scoped>
.grow-page { max-width: 720px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.grow-hero {
  display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(242,196,160,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.grow-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.grow-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.grow-hero-metrics { display: flex; gap: 20px; }
.grow-metric { text-align: center; }
.grow-metric-val { font-size: 1.2rem; font-weight: 700; font-family: var(--font-mono); display: block; }
.grow-metric-val small { font-size: 0.7rem; font-weight: 400; color: var(--color-text-muted); }
.grow-metric-lbl { font-size: 0.68rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.card-badge { font-size: 0.72rem; font-weight: 600; color: var(--color-primary); background: rgba(139,126,200,0.08); padding: 3px 10px; border-radius: var(--radius-full); }
.chart-wrap { margin: 0 -8px; }

.ms-list { display: flex; flex-direction: column; gap: 4px; }
.ms-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.ms-row:hover { background: rgba(139,126,200,0.04); }
.ms-row--done { opacity: 0.65; }

.ms-dot {
  width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  background: rgba(233,196,106,0.12); color: var(--color-warning);
}
.ms-dot--done { background: rgba(124,184,212,0.12); color: var(--color-success); }

.ms-info { flex: 1; min-width: 0; }
.ms-name { display: block; font-size: 0.85rem; font-weight: 500; }
.ms-meta { display: block; font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }

.ms-badge { font-size: 0.62rem; font-weight: 600; padding: 3px 8px; border-radius: var(--radius-full); flex-shrink: 0; }
.ms-badge--done { background: rgba(124,184,212,0.1); color: var(--color-success); }
.ms-badge--pending { background: rgba(233,196,106,0.08); color: var(--color-warning); }
</style>

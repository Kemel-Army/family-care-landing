<template>
  <div class="mood-page">
    <!-- Hero -->
    <div class="mood-hero">
      <div>
        <h1 class="mood-hero-title">Настроение</h1>
        <p class="mood-hero-sub">Отслеживание самочувствия мамы</p>
      </div>
      <div class="mood-hero-score">
        <span class="mood-hero-emoji">{{ avgEmoji }}</span>
        <span class="mood-hero-avg">{{ avgScore.toFixed(1) }}</span>
      </div>
    </div>

    <!-- Quick mood log -->
    <div class="card">
      <h2 class="card-title-sm">Как вы себя чувствуете?</h2>
      <div class="mood-grid">
        <button
          v-for="m in moods" :key="m.value"
          class="mood-btn" :class="{ 'mood-btn--selected': selectedMood === m.value }"
          @click="selectedMood = m.value"
        >
          <span class="mood-emoji">{{ m.emoji }}</span>
          <span class="mood-label">{{ m.label }}</span>
        </button>
      </div>
      <Transition name="slide">
        <div v-if="selectedMood" class="mood-note-area">
          <textarea v-model="notes" placeholder="Заметки..." rows="2" class="mood-textarea" />
          <button class="mood-save-btn" @click="logMood">Сохранить</button>
        </div>
      </Transition>
    </div>

    <!-- EPDS -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:brain" size="16" /> Шкала EPDS</h2>
        <NuxtLink to="/family/mood/epds" class="card-link">Пройти тест →</NuxtLink>
      </div>
      <div class="epds-row">
        <div class="epds-circle" :class="`epds-circle--${mock.lastEpds.risk}`">
          <span class="epds-val">{{ mock.lastEpds.score }}</span>
          <span class="epds-of">/30</span>
        </div>
        <div class="epds-info">
          <span class="epds-risk" :class="`epds-risk--${mock.lastEpds.risk}`">{{ riskLabel(mock.lastEpds.risk) }}</span>
          <span class="epds-date">{{ mock.lastEpds.date }}</span>
        </div>
      </div>
    </div>

    <!-- Mood chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:line-chart" size="16" /> За 14 дней</h2>
      </div>
      <AppSharedEChart :option="moodChartOption" style="height: 180px" />
    </div>

    <!-- History -->
    <div class="card" v-if="mock.moodHistory.length">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:history" size="16" /> История</h2>
      </div>
      <div class="mood-hist">
        <div v-for="e in mock.moodHistory.slice(0, 10)" :key="e.date" class="mood-hist-row">
          <span class="mood-hist-emoji">{{ scoreEmoji(e.score) }}</span>
          <span class="mood-hist-date">{{ formatDate(e.date) }}</span>
          <div class="mood-hist-bar-wrap">
            <div class="mood-hist-bar" :style="{ width: `${e.score * 20}%`, background: scoreColor(e.score) }" />
          </div>
          <span class="mood-hist-score">{{ e.score }}/5</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const selectedMood = ref(0)
const notes = ref('')

const moods = [
  { value: 1, emoji: '😢', label: 'Плохо' },
  { value: 2, emoji: '😔', label: 'Грустно' },
  { value: 3, emoji: '😐', label: 'Нормально' },
  { value: 4, emoji: '🙂', label: 'Хорошо' },
  { value: 5, emoji: '😊', label: 'Отлично' },
]

const avgScore = computed(() => {
  const h = mock.moodHistory
  return h.reduce((s, e) => s + e.score, 0) / h.length
})
const avgEmoji = computed(() => scoreEmoji(Math.round(avgScore.value)))

function scoreEmoji(s: number) { return moods.find(m => m.value === s)?.emoji || '😐' }
function scoreColor(s: number) {
  if (s <= 2) return 'var(--color-danger)'
  if (s === 3) return 'var(--color-warning)'
  return 'var(--color-success)'
}

function riskLabel(r: string) {
  const m: Record<string, string> = { low: 'Низкий риск', medium: 'Средний риск', high: 'Высокий риск' }
  return m[r] || r
}

function logMood() { selectedMood.value = 0; notes.value = '' }

function formatDate(iso: string) {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

const moodChartOption = computed(() => ({
  grid: { top: 16, right: 8, bottom: 24, left: 32 },
  xAxis: { type: 'category', data: mock.moodHistory.map(e => formatDate(e.date)), axisLine: { lineStyle: { color: '#e0dce8' } }, axisLabel: { color: '#9690a8', fontSize: 10, rotate: 45 } },
  yAxis: { type: 'value', min: 1, max: 5, interval: 1, axisLine: { show: false }, splitLine: { lineStyle: { color: '#f0eef5' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  series: [{
    type: 'line', data: mock.moodHistory.map(e => e.score), smooth: true,
    lineStyle: { color: '#E8A0BF', width: 3 }, symbol: 'circle', symbolSize: 7,
    itemStyle: { color: '#E8A0BF', borderColor: '#fff', borderWidth: 2 },
    areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(232,160,191,0.2)' }, { offset: 1, color: 'rgba(232,160,191,0)' }] } },
  }],
}))
</script>

<style scoped>
.mood-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.mood-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(232,160,191,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(232,160,191,0.12); border-radius: 16px; padding: 24px 28px;
}
.mood-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.mood-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.mood-hero-score { display: flex; align-items: center; gap: 8px; }
.mood-hero-emoji { font-size: 2rem; }
.mood-hero-avg { font-size: 1.2rem; font-weight: 700; font-family: var(--font-mono); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.card-title-sm { font-size: 0.88rem; font-weight: 600; margin-bottom: 14px; }
.card-link { font-size: 0.78rem; color: var(--color-primary); text-decoration: none; font-weight: 600; }

.mood-grid { display: flex; gap: 8px; justify-content: center; }
.mood-btn {
  display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 12px 14px;
  border: 2px solid var(--color-border-light); border-radius: 12px;
  background: white; cursor: pointer; transition: all 0.15s; min-width: 64px;
}
.mood-btn:hover { border-color: rgba(232,160,191,0.4); }
.mood-btn--selected { border-color: var(--color-primary); background: rgba(139,126,200,0.04); }
.mood-emoji { font-size: 1.4rem; }
.mood-label { font-size: 0.65rem; color: var(--color-text-muted); }

.mood-note-area { margin-top: 14px; display: flex; flex-direction: column; gap: 8px; }
.mood-textarea { padding: 10px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.82rem; font-family: var(--font-body); resize: none; outline: none; }
.mood-textarea:focus { border-color: var(--color-primary); }
.mood-save-btn { align-self: flex-end; padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-size: 0.82rem; font-family: var(--font-body); }

.epds-row { display: flex; align-items: center; gap: 16px; }
.epds-circle {
  width: 56px; height: 56px; border-radius: 50%; display: flex; flex-direction: column;
  align-items: center; justify-content: center; flex-shrink: 0;
}
.epds-circle--low { background: rgba(124,184,212,0.12); color: var(--color-success); }
.epds-circle--medium { background: rgba(233,196,106,0.12); color: var(--color-warning); }
.epds-circle--high { background: rgba(212,114,124,0.12); color: var(--color-danger); }
.epds-val { font-size: 1.1rem; font-weight: 700; font-family: var(--font-mono); line-height: 1; }
.epds-of { font-size: 0.55rem; }
.epds-info { flex: 1; }
.epds-risk { font-size: 0.85rem; font-weight: 500; display: block; }
.epds-risk--low { color: var(--color-success); }
.epds-risk--medium { color: var(--color-warning); }
.epds-risk--high { color: var(--color-danger); }
.epds-date { font-size: 0.72rem; color: var(--color-text-muted); }

.mood-hist { display: flex; flex-direction: column; gap: 4px; }
.mood-hist-row { display: flex; align-items: center; gap: 10px; padding: 6px 0; }
.mood-hist-emoji { font-size: 1rem; width: 24px; text-align: center; }
.mood-hist-date { font-size: 0.72rem; color: var(--color-text-muted); min-width: 52px; }
.mood-hist-bar-wrap { flex: 1; height: 6px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
.mood-hist-bar { height: 100%; border-radius: 3px; transition: width 0.3s; }
.mood-hist-score { font-size: 0.68rem; font-family: var(--font-mono); color: var(--color-text-muted); min-width: 28px; text-align: right; }

.slide-enter-active, .slide-leave-active { transition: all 0.25s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; transform: translateY(-8px); }
</style>

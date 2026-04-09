<template>
  <div class="ach-page">
    <!-- Hero -->
    <div class="ach-hero">
      <div>
        <h1 class="ach-hero-title">Достижения</h1>
        <p class="ach-hero-sub">{{ unlockedCount }}/{{ mock.achievements.length }} разблокировано</p>
      </div>
      <AppSharedProgressRing :value="Math.round(unlockedCount / mock.achievements.length * 100)" :size="64" :strokeWidth="5" variant="primary" />
    </div>

    <!-- Streaks -->
    <div class="streaks-grid">
      <div v-for="s in streakList" :key="s.key" class="streak-card" :class="{ 'streak-card--active': s.current > 0 }">
        <span class="streak-emoji">{{ s.emoji }}</span>
        <span class="streak-val">{{ s.current }} <small>дн</small></span>
        <span class="streak-label">{{ s.label }}</span>
        <span class="streak-best">рекорд {{ s.longest }}</span>
      </div>
    </div>

    <!-- Achievements grid -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:trophy" size="16" /> Все достижения</h2>
      </div>
      <div class="ach-grid">
        <div v-for="a in mock.achievements" :key="a.id" class="ach-item" :class="{ 'ach-item--locked': !a.unlocked }">
          <div class="ach-icon-wrap" :class="{ 'ach-icon-wrap--unlocked': a.unlocked }">
            <Icon :name="a.icon" size="22" />
          </div>
          <span class="ach-name">{{ a.name }}</span>
          <span v-if="a.unlocked" class="ach-date">{{ formatDate(a.date) }}</span>
          <span v-else class="ach-locked-text">Заблокировано</span>
        </div>
      </div>
    </div>

    <!-- Leaderboard -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:medal" size="16" /> Таблица лидеров</h2>
      </div>
      <div class="lb-list">
        <div v-for="(e, i) in leaderboard" :key="i" class="lb-row" :class="{ 'lb-row--me': e.isMe }">
          <span class="lb-rank" :class="{ 'lb-rank--gold': i === 0, 'lb-rank--silver': i === 1, 'lb-rank--bronze': i === 2 }">{{ i + 1 }}</span>
          <span class="lb-name">{{ e.name }}</span>
          <span class="lb-pts">{{ e.points }} pts</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const unlockedCount = computed(() => mock.achievements.filter(a => a.unlocked).length)

const streakList = [
  { key: 'doses', emoji: '💊', label: 'Лекарства', ...mock.streaks.doses },
  { key: 'mood', emoji: '😊', label: 'Настроение', ...mock.streaks.mood },
  { key: 'sleep', emoji: '🌙', label: 'Сон', ...mock.streaks.sleep },
  { key: 'feeding', emoji: '🍼', label: 'Кормление', ...mock.streaks.feeding },
]

const leaderboard = [
  { name: 'Камила Б.', points: 3200, isMe: false },
  { name: 'Вы', points: 2400, isMe: true },
  { name: 'Айгерим К.', points: 2100, isMe: false },
  { name: 'Дана Н.', points: 1800, isMe: false },
  { name: 'Сара А.', points: 1500, isMe: false },
]

function formatDate(iso: string) {
  if (!iso) return ''
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}
</script>

<style scoped>
.ach-page { max-width: 720px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.ach-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(233,196,106,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(233,196,106,0.12); border-radius: 16px; padding: 24px 28px;
}
.ach-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.ach-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.streaks-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
@media (max-width: 600px) { .streaks-grid { grid-template-columns: repeat(2, 1fr); } }
.streak-card {
  text-align: center; padding: 16px 10px; background: white; border: 1px solid var(--color-border-light);
  border-radius: 14px; display: flex; flex-direction: column; align-items: center; gap: 3px;
}
.streak-card--active { border-color: rgba(139,126,200,0.2); background: linear-gradient(135deg, rgba(139,126,200,0.04), rgba(232,160,191,0.03)); }
.streak-emoji { font-size: 1.6rem; }
.streak-val { font-size: 1.1rem; font-weight: 700; font-family: var(--font-mono); }
.streak-val small { font-size: 0.65rem; font-weight: 400; color: var(--color-text-muted); }
.streak-label { font-size: 0.72rem; color: var(--color-text-secondary); }
.streak-best { font-size: 0.62rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.ach-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
@media (max-width: 500px) { .ach-grid { grid-template-columns: repeat(2, 1fr); } }
.ach-item { text-align: center; padding: 18px 10px; border: 1px solid var(--color-border-light); border-radius: 14px; display: flex; flex-direction: column; align-items: center; gap: 6px; transition: all 0.2s; }
.ach-item:hover { border-color: rgba(139,126,200,0.2); transform: translateY(-2px); }
.ach-item--locked { opacity: 0.4; filter: grayscale(0.5); }
.ach-icon-wrap { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: rgba(139,126,200,0.06); color: var(--color-text-muted); }
.ach-icon-wrap--unlocked { background: rgba(233,196,106,0.12); color: var(--color-warning); }
.ach-name { font-size: 0.78rem; font-weight: 600; }
.ach-date { font-size: 0.62rem; color: var(--color-success); }
.ach-locked-text { font-size: 0.62rem; color: var(--color-text-muted); }

.lb-list { display: flex; flex-direction: column; gap: 4px; }
.lb-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.lb-row:hover { background: rgba(139,126,200,0.04); }
.lb-row--me { background: rgba(139,126,200,0.06); border: 1px solid rgba(139,126,200,0.12); }
.lb-rank { width: 26px; font-weight: 700; font-family: var(--font-mono); color: var(--color-text-muted); text-align: center; }
.lb-rank--gold { color: #F59E0B; }
.lb-rank--silver { color: #94A3B8; }
.lb-rank--bronze { color: #D97706; }
.lb-name { flex: 1; font-size: 0.85rem; font-weight: 500; }
.lb-pts { font-size: 0.82rem; font-weight: 600; font-family: var(--font-mono); color: var(--color-primary); }
</style>

<template>
  <div class="vax-page">
    <!-- Hero -->
    <div class="vax-hero">
      <div>
        <h1 class="vax-hero-title">Прививки</h1>
        <p class="vax-hero-sub">{{ mock.children[0].first_name }} · Национальный календарь</p>
      </div>
      <AppSharedProgressRing :value="completionPercent" :size="72" :strokeWidth="6" variant="success" />
    </div>

    <!-- Summary strip -->
    <div class="vax-strip">
      <div class="vax-chip vax-chip--done">
        <Icon name="lucide:check-circle" size="14" />
        <span>{{ completedVax.length }} выполнено</span>
      </div>
      <div class="vax-chip vax-chip--upcoming">
        <Icon name="lucide:clock" size="14" />
        <span>{{ upcomingVax.length }} впереди</span>
      </div>
    </div>

    <!-- Upcoming -->
    <div class="card" v-if="upcomingVax.length">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:calendar-check" size="16" /> Предстоящие</h2>
      </div>
      <div class="vax-list">
        <div v-for="v in upcomingVax" :key="v.id" class="vax-row">
          <div class="vax-icon vax-icon--upcoming"><Icon name="lucide:syringe" size="16" /></div>
          <div class="vax-info">
            <span class="vax-name">{{ v.name }}</span>
            <span class="vax-meta">Доза {{ v.dose }} · {{ formatDate(v.date) }}</span>
          </div>
          <span class="vax-badge vax-badge--upcoming">Запланирована</span>
        </div>
      </div>
    </div>

    <!-- Completed -->
    <div class="card" v-if="completedVax.length">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:shield-check" size="16" /> Выполненные</h2>
      </div>
      <div class="vax-list">
        <div v-for="v in completedVax" :key="v.id" class="vax-row vax-row--done">
          <div class="vax-icon vax-icon--done"><Icon name="lucide:check" size="16" /></div>
          <div class="vax-info">
            <span class="vax-name">{{ v.name }}</span>
            <span class="vax-meta">Доза {{ v.dose }} · {{ formatDate(v.date) }}</span>
            <span v-if="v.batch" class="vax-batch">Партия: {{ v.batch }}</span>
          </div>
          <span class="vax-badge vax-badge--done">Выполнена</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const completedVax = computed(() => mock.vaccinations.filter(v => v.status === 'completed'))
const upcomingVax = computed(() => mock.vaccinations.filter(v => v.status === 'upcoming'))
const completionPercent = computed(() => Math.round((completedVax.value.length / mock.vaccinations.length) * 100))

function formatDate(iso: string) {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`
}
</script>

<style scoped>
.vax-page { max-width: 720px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.vax-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(124,184,212,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(124,184,212,0.12); border-radius: 16px; padding: 24px 28px;
}
.vax-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.vax-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.vax-strip { display: flex; gap: 10px; }
.vax-chip {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.78rem; color: var(--color-text-secondary);
}
.vax-chip--done { color: var(--color-success); }
.vax-chip--upcoming { color: var(--color-warning); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.vax-list { display: flex; flex-direction: column; gap: 4px; }
.vax-row {
  display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px;
  transition: background 0.15s;
}
.vax-row:hover { background: rgba(139,126,200,0.04); }
.vax-row--done { opacity: 0.7; }

.vax-icon {
  width: 32px; height: 32px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.vax-icon--upcoming { background: rgba(233,196,106,0.12); color: var(--color-warning); }
.vax-icon--done { background: rgba(124,184,212,0.12); color: var(--color-success); }

.vax-info { flex: 1; min-width: 0; }
.vax-name { display: block; font-size: 0.85rem; font-weight: 500; color: var(--color-text-primary); }
.vax-meta { display: block; font-size: 0.72rem; color: var(--color-text-muted); margin-top: 2px; }
.vax-batch { display: block; font-size: 0.68rem; color: var(--color-text-muted); font-family: var(--font-mono); }

.vax-badge { font-size: 0.65rem; font-weight: 600; padding: 3px 8px; border-radius: var(--radius-full); flex-shrink: 0; }
.vax-badge--done { background: rgba(124,184,212,0.1); color: var(--color-success); }
.vax-badge--upcoming { background: rgba(233,196,106,0.1); color: var(--color-warning); }
</style>

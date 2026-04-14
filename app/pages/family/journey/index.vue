<template>
  <div class="journey-page">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="skel skel-hero" />
      <div class="stats-strip"><div v-for="i in 3" :key="i" class="skel skel-chip" /></div>
      <div v-for="i in 5" :key="i" class="skel skel-tl" />
    </template>

    <template v-else>
    <!-- Hero -->
    <div class="journey-hero">
      <div class="journey-hero-info">
        <h1 class="journey-hero-title">Маршрут заботы</h1>
        <p class="journey-hero-sub">{{ stageTitle }}{{ weekLabel ? ` · ${weekLabel}` : '' }}</p>
      </div>
      <AppSharedProgressRing :value="progressPercent" :size="80" :strokeWidth="7" variant="primary" />
    </div>

    <!-- Stats strip -->
    <div class="stats-strip">
      <div class="stat-chip">
        <span class="stat-chip-val">{{ completedCount }}</span>
        <span class="stat-chip-label">выполнено</span>
      </div>
      <div class="stat-chip stat-chip--danger" v-if="overdueCount">
        <span class="stat-chip-val">{{ overdueCount }}</span>
        <span class="stat-chip-label">просрочено</span>
      </div>
      <div class="stat-chip">
        <span class="stat-chip-val">{{ upcomingCount }}</span>
        <span class="stat-chip-label">впереди</span>
      </div>
    </div>

    <!-- Timeline -->
    <div class="timeline">
      <div v-for="ev in events" :key="ev.id" class="tl-item" :class="`tl-item--${ev.status}`">
        <div class="tl-rail">
          <div class="tl-dot">
            <Icon v-if="ev.status === 'completed'" name="lucide:check" size="12" />
            <Icon v-else-if="ev.status === 'overdue'" name="lucide:alert-triangle" size="12" />
          </div>
          <div class="tl-line" />
        </div>
        <div class="tl-card">
          <div class="tl-card-header">
            <span class="tl-type">{{ typeLabel(ev.type) }}</span>
            <span class="tl-date">{{ formatDate(ev.due_date!) }}</span>
          </div>
          <h3 class="tl-title">{{ ev.title }}</h3>
          <p class="tl-desc">{{ ev.description }}</p>
          <div class="tl-footer">
            <span v-if="ev.is_mandatory" class="tl-badge tl-badge--required">Обязательно</span>
            <span v-else class="tl-badge">Рекомендовано</span>
            <button v-if="ev.status === 'due' || ev.status === 'overdue'" class="tl-action" :disabled="completing === ev.id" @click="handleComplete(ev.id)">
              <Icon :name="completing === ev.id ? 'lucide:loader-2' : 'lucide:check'" size="14" />
              {{ completing === ev.id ? '...' : 'Выполнить' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <AppSharedEmptyState v-if="events.length === 0" icon="lucide:map-pin" title="Нет событий в маршруте" />
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const journeyStore = useJourneyStore()
const authStore = useAuthStore()
const appData = useAppData()

const completing = ref<string | null>(null)
const { success: toastSuccess, error: toastError } = useToast()
const loading = ref(true)

onMounted(async () => {
  try {
    if (authStore.familyId) await journeyStore.fetchJourneys(authStore.familyId)
  } finally {
    loading.value = false
  }
})

// ── Real data with fallback ──
const hasReal = computed(() => journeyStore.events.length > 0)
const events = computed(() => hasReal.value ? journeyStore.events : appData.journeyEvents)
const completedCount = computed(() => events.value.filter(e => e.status === 'completed').length)
const overdueCount = computed(() => events.value.filter(e => e.status === 'overdue').length)
const upcomingCount = computed(() => events.value.filter(e => e.status === 'upcoming').length)
const progressPercent = computed(() => hasReal.value ? journeyStore.progressPercent : appData.familyKpi.journeyProgress.value)

const stageTitle = computed(() => {
  const journey = journeyStore.currentJourney ?? journeyStore.activeJourneys[0]
  if (!journey) return 'Маршрут заботы'
  const labels: Record<string, string> = { pregnancy: 'Беременность', postpartum: 'Послеродовой период', infant: 'Наблюдение малыша', child_0_1: 'Первый год', child_1_3: 'Развитие 1–3', toddler: 'Тоддлер' }
  return labels[journey.type] || 'Маршрут заботы'
})

const weekLabel = computed(() => {
  const journey = journeyStore.currentJourney ?? journeyStore.activeJourneys[0]
  if (!journey) return ''
  if (journey.type === 'pregnancy' && authStore.motherProfile?.lmp_date) {
    const weeks = Math.floor((Date.now() - new Date(authStore.motherProfile.lmp_date).getTime()) / (7 * 86400000))
    return `${weeks}-я неделя`
  }
  return ''
})

function typeLabel(type: string) {
  const m: Record<string, string> = { ultrasound: 'УЗИ', analysis: 'Анализ', screening: 'Скрининг', checkup: 'Осмотр', vaccination: 'Вакцинация' }
  return m[type] || type
}

function formatDate(iso: string) {
  if (!iso) return ''
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

async function handleComplete(id: string) {
  completing.value = id
  try {
    const { error } = await journeyStore.completeEvent(id)
    if (error) toastError('Не удалось отметить событие')
    else toastSuccess('Событие выполнено!')
  } catch {
    toastError('Ошибка сети')
  } finally {
    completing.value = null
  }
}
</script>

<style scoped>
.journey-page { max-width: 720px; margin: 0 auto; }

.journey-hero {
  display: flex; align-items: center; justify-content: space-between; gap: 24px;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(168,200,232,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px; margin-bottom: 20px;
}
.journey-hero-title { font-family: var(--font-display); font-size: 1.5rem; font-weight: 700; color: var(--color-text-primary); }
.journey-hero-sub { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 4px; }

.stats-strip { display: flex; gap: 10px; margin-bottom: 28px; }
.stat-chip {
  background: white; border: 1px solid var(--color-border-light); border-radius: 10px; padding: 10px 16px;
  display: flex; flex-direction: column; align-items: center; gap: 2px; flex: 1;
}
.stat-chip--danger { border-color: rgba(212,114,124,0.2); background: rgba(212,114,124,0.03); }
.stat-chip-val { font-size: 1.2rem; font-weight: 700; color: var(--color-text-primary); }
.stat-chip--danger .stat-chip-val { color: var(--color-danger); }
.stat-chip-label { font-size: 0.68rem; color: var(--color-text-muted); }

/* Timeline */
.timeline { display: flex; flex-direction: column; }

.tl-item { display: flex; gap: 16px; }
.tl-rail { display: flex; flex-direction: column; align-items: center; width: 24px; flex-shrink: 0; }
.tl-dot {
  width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
  background: var(--color-border-light); color: var(--color-text-muted); flex-shrink: 0; font-size: 12px;
}
.tl-item--completed .tl-dot { background: var(--color-success); color: white; }
.tl-item--overdue .tl-dot { background: var(--color-danger); color: white; }
.tl-item--due .tl-dot { background: var(--color-primary); color: white; box-shadow: 0 0 0 4px rgba(139,126,200,0.15); }
.tl-line { flex: 1; width: 2px; background: var(--color-border-light); min-height: 16px; }
.tl-item:last-child .tl-line { display: none; }

.tl-card {
  flex: 1; background: white; border: 1px solid var(--color-border-light); border-radius: 12px;
  padding: 16px; margin-bottom: 12px; transition: box-shadow 0.15s ease;
}
.tl-card:hover { box-shadow: 0 2px 10px rgba(0,0,0,0.04); }
.tl-item--overdue .tl-card { border-color: rgba(212,114,124,0.2); background: rgba(212,114,124,0.02); }

.tl-card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
.tl-type { font-size: 0.68rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: var(--color-primary); }
.tl-date { font-size: 0.72rem; color: var(--color-text-muted); }
.tl-title { font-size: 0.9rem; font-weight: 600; color: var(--color-text-primary); margin-bottom: 4px; }
.tl-desc { font-size: 0.78rem; color: var(--color-text-secondary); line-height: 1.4; }
.tl-footer { display: flex; align-items: center; gap: 8px; margin-top: 10px; }
.tl-badge {
  font-size: 0.65rem; font-weight: 600; padding: 3px 8px; border-radius: var(--radius-full);
  background: rgba(139,126,200,0.08); color: var(--color-primary);
}
.tl-badge--required { background: rgba(232,160,191,0.12); color: #C46B8F; }
.tl-action {
  margin-left: auto; display: flex; align-items: center; gap: 4px;
  background: var(--color-primary); color: white; border: none; padding: 5px 12px;
  border-radius: 8px; font-size: 0.75rem; font-weight: 600; cursor: pointer;
  font-family: var(--font-body); transition: opacity 0.15s;
}
.tl-action:hover { opacity: 0.85; }
.tl-action:disabled { opacity: 0.5; cursor: default; }

/* Empty & Skeleton */
.empty-state { text-align: center; padding: 60px 20px; color: var(--color-text-muted); display: flex; flex-direction: column; align-items: center; gap: 12px; }
.skel { background: linear-gradient(90deg, rgba(139,126,200,0.06) 0%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 100%); background-size: 200% 100%; animation: shimmer 1.4s ease infinite; border-radius: 14px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skel-hero { height: 100px; border-radius: 16px; margin-bottom: 20px; }
.skel-chip { height: 56px; flex: 1; border-radius: 10px; }
.skel-tl { height: 100px; margin-bottom: 12px; }

/* Toast */
.toast { position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%); z-index: 9999; display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-radius: 12px; font-size: 0.85rem; font-weight: 500; box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
.toast--success { background: #e8f8ee; color: #1a7a3e; border: 1px solid #c3ecd0; }
.toast--error { background: #fdecea; color: #a63232; border: 1px solid #f5c6c6; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }
</style>

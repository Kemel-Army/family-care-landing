<template>
  <div class="tasks-page">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="tasks-hero"><div class="skel skel-title" /><div class="skel skel-sub" /></div>
      <div class="filter-scroll"><div v-for="i in 5" :key="i" class="skel skel-chip" /></div>
      <div class="task-list"><div v-for="i in 5" :key="i" class="skel skel-card" /></div>
    </template>

    <template v-else>
      <!-- Hero -->
      <div class="tasks-hero">
        <NuxtLink to="/coordinator" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
        <h1 class="tasks-hero-title">Все задачи</h1>
        <p class="tasks-hero-sub">{{ activeTasks.length }} активных задач</p>
      </div>

      <!-- Filter chips -->
      <div class="filter-scroll">
        <button v-for="f in filterOptions" :key="f.value" class="filter-chip"
          :class="{ 'filter-chip--active': filter === f.value }" @click="filter = f.value">
          {{ f.label }}
        </button>
      </div>

      <!-- Task list -->
      <div v-if="filteredTasks.length" class="task-list">
        <div v-for="t in filteredTasks" :key="t.id" class="task-card" :class="{ 'task-card--critical': t.priority === 'critical' }">
          <div class="task-priority-dot" :class="`dot--${t.priority}`" />
          <div class="task-body">
            <span class="task-title">{{ t.title }}</span>
            <span class="task-meta">{{ (t as any).family_name }} · {{ taskTypeLabel(t.type) }} · {{ timeAgo(t.created_at!) }}</span>
          </div>
          <div class="task-actions">
            <button class="btn-action btn-action--done" :disabled="processingId === t.id" @click="completeTask(t.id)">
              {{ processingId === t.id ? '...' : 'Выполнено' }}
            </button>
            <button class="btn-action btn-action--dismiss" :disabled="processingId === t.id" @click="dismissTask(t.id)">Отклонить</button>
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <AppSharedEmptyState v-else icon="lucide:check-circle" title="Все задачи выполнены" />
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const authStore = useAuthStore()
const coordStore = useCoordinatorStore()
const appData = useAppData()
const filter = ref('all')
const loading = ref(true)
const processingId = ref<string | null>(null)
const { success: toastSuccess, error: toastError } = useToast()

onMounted(async () => {
  const cid = authStore.clinicId
  if (cid && coordStore.tasks.length === 0) {
    await coordStore.fetchTasks(cid)
  }
  loading.value = false
})

const hasReal = computed(() => coordStore.pendingTasks.length > 0)

const activeTasks = computed(() => {
  if (hasReal.value) return coordStore.pendingTasks
  return appData.coordinatorTasks.filter((t: any) => t.status === 'pending')
})

const filterOptions = [
  { label: 'Все', value: 'all' },
  { label: 'Срочные', value: 'critical' },
  { label: 'Высокие', value: 'high' },
  { label: 'Средние', value: 'medium' },
  { label: 'Низкие', value: 'low' },
]

const filteredTasks = computed(() => {
  if (filter.value === 'all') return activeTasks.value
  return activeTasks.value.filter((t: any) => t.priority === filter.value)
})

function taskTypeLabel(type: string) {
  const map: Record<string, string> = { missed_appointment: 'Неявка', overdue_followup: 'Просрочено', low_adherence: 'Adherence', vaccination_reminder: 'Прививка', welcome_call: 'Звонок', reactivation: 'Реактивация' }
  return map[type] || type
}

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const h = Math.floor(diff / 3600000)
  if (h < 24) return `${h}ч назад`
  return `${Math.floor(h / 24)}д назад`
}

async function completeTask(id: string) {
  processingId.value = id
  try {
    const { error } = await coordStore.completeTask(id)
    if (error) throw error
    toastSuccess('Задача выполнена')
  }
  catch { toastError('Не удалось завершить задачу') }
  finally { processingId.value = null }
}

async function dismissTask(id: string) {
  processingId.value = id
  try {
    const { error } = await coordStore.dismissTask(id)
    if (error) throw error
    toastSuccess('Задача отклонена')
  }
  catch { toastError('Не удалось отклонить задачу') }
  finally { processingId.value = null }
}
</script>

<style scoped>
.tasks-page { max-width: 760px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.tasks-hero {
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.tasks-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.tasks-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.filter-scroll { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; }
.filter-scroll::-webkit-scrollbar { display: none; }
.filter-chip {
  flex-shrink: 0; padding: 8px 16px; border: 1px solid var(--color-border-light);
  border-radius: 20px; background: white; font-size: 0.78rem; font-weight: 500;
  cursor: pointer; font-family: var(--font-body); white-space: nowrap; transition: all 0.15s;
}
.filter-chip:hover { border-color: rgba(139,126,200,0.2); }
.filter-chip--active { border-color: var(--color-primary); background: rgba(139,126,200,0.08); color: var(--color-primary); font-weight: 600; }

.task-list { display: flex; flex-direction: column; gap: 6px; }
.task-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 18px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px; transition: all 0.2s;
}
.task-card:hover { border-color: rgba(139,126,200,0.15); }
.task-card--critical { border-left: 3px solid var(--color-danger); background: rgba(212,114,124,0.03); }

.task-priority-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot--critical { background: var(--color-danger); }
.dot--high { background: var(--color-warning); }
.dot--medium { background: var(--color-primary); }
.dot--low { background: var(--color-text-muted); }

.task-body { flex: 1; min-width: 0; }
.task-title { font-size: 0.85rem; font-weight: 600; display: block; }
.task-meta { font-size: 0.68rem; color: var(--color-text-muted); }

.task-actions { display: flex; gap: 6px; flex-shrink: 0; }
.btn-action { padding: 6px 12px; border-radius: 8px; font-size: 0.72rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); border: none; transition: all 0.15s; }
.btn-action--done { background: rgba(124,184,212,0.12); color: var(--color-success); }
.btn-action--done:hover { background: rgba(124,184,212,0.2); }
.btn-action--dismiss { background: transparent; color: var(--color-text-muted); border: 1px solid var(--color-border-light); }
.btn-action--dismiss:hover { background: rgba(212,114,124,0.06); color: var(--color-danger); }

.empty-card { text-align: center; padding: 48px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; }
.empty-text { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 8px; }

/* Skeleton */
.skel { background: linear-gradient(90deg, rgba(139,126,200,0.06) 25%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 75%); background-size: 200% 100%; animation: shimmer 1.4s ease infinite; border-radius: 10px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skel-title { height: 24px; width: 200px; }
.skel-sub { height: 14px; width: 140px; margin-top: 8px; }
.skel-chip { height: 36px; width: 80px; border-radius: 20px; flex-shrink: 0; }
.skel-card { height: 64px; }

/* Toast */
.toast { position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%); padding: 12px 20px; border-radius: 12px; font-size: 0.82rem; font-weight: 500; display: flex; align-items: center; gap: 8px; z-index: 100; box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
.toast--success { background: #e8f8ee; color: #1a7a3e; border: 1px solid #c3ecd0; }
.toast--error { background: #fdecea; color: #a63232; border: 1px solid #f5c6c6; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }

.btn-action:disabled { opacity: 0.5; cursor: not-allowed; }
</style>

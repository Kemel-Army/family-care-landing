<template>
  <div class="coord-page">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="skel skel-hero" />
      <div class="kpi-grid"><div v-for="i in 4" :key="i" class="skel skel-kpi" /></div>
      <div class="skel skel-card" /><div class="skel skel-card" />
    </template>

    <template v-else>
    <!-- Hero -->
    <div class="coord-hero">
      <div>
        <h1 class="coord-hero-title">Панель координатора</h1>
        <p class="coord-hero-sub">{{ greetingLine }}. {{ criticalTasks.length > 0 ? `${criticalTasks.length} срочных задач` : 'Нет срочных задач' }}</p>
      </div>
    </div>

    <!-- KPI strip -->
    <div class="kpi-grid">
      <div v-for="k in kpiCards" :key="k.label" class="kpi-card">
        <div class="kpi-top">
          <Icon :name="k.icon" size="16" :style="{ color: k.color }" />
        </div>
        <span class="kpi-val">{{ k.value }}</span>
        <span class="kpi-label">{{ k.label }}</span>
      </div>
    </div>

    <!-- Critical tasks -->
    <div v-if="criticalTasks.length" class="card card--danger">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:alert-triangle" size="16" style="color:var(--color-danger)" /> Требуют внимания</h2>
        <span class="badge badge--danger">{{ criticalTasks.length }}</span>
      </div>
      <div class="task-list">
        <div v-for="t in criticalTasks" :key="t.id" class="task-row task-row--critical">
          <div class="task-dot task-dot--critical" />
          <div class="task-body">
            <span class="task-title">{{ t.title }}</span>
            <span class="task-meta">{{ (t as any).family_name }} · {{ timeAgo(t.created_at!) }}</span>
          </div>
          <button class="btn-sm btn-sm--done" :disabled="completing === t.id" @click="handleComplete(t.id)">
            {{ completing === t.id ? '...' : 'Готово' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Pending tasks -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:clipboard-list" size="16" /> Задачи</h2>
        <NuxtLink to="/coordinator/tasks" class="link-more">Все задачи →</NuxtLink>
      </div>
      <div v-if="pendingTasks.length" class="task-list">
        <div v-for="t in pendingTasks.slice(0, 10)" :key="t.id" class="task-row">
          <div class="task-dot" :class="`task-dot--${t.priority}`" />
          <div class="task-body">
            <span class="task-title">{{ t.title }}</span>
            <span class="task-meta">{{ (t as any).family_name }} · {{ taskTypeLabel(t.type) }}</span>
          </div>
          <button class="btn-sm btn-sm--done" :disabled="completing === t.id" @click="handleComplete(t.id)">✓</button>
        </div>
      </div>
      <AppSharedEmptyState v-else icon="lucide:check-circle" title="Все задачи выполнены" />
    </div>

    <!-- Two column layout -->
    <div class="coord-columns">
      <!-- Left: tasks chart + quick links -->
      <div class="coord-left">
        <div class="card">
          <div class="card-header">
            <h2 class="card-title"><Icon name="lucide:bar-chart-3" size="16" /> Распределение задач</h2>
          </div>
          <AppSharedEChart :option="taskPieOption" height="220px" />
        </div>
        <div class="quick-grid">
          <NuxtLink to="/coordinator/families" class="quick-card">
            <Icon name="lucide:users" size="20" style="color:var(--color-primary)" />
            <span>Все семьи</span>
            <Icon name="lucide:chevron-right" size="14" class="quick-arrow" />
          </NuxtLink>
          <NuxtLink to="/coordinator/tasks" class="quick-card">
            <Icon name="lucide:clipboard-list" size="20" style="color:var(--color-accent-blue)" />
            <span>Все задачи</span>
            <Icon name="lucide:chevron-right" size="14" class="quick-arrow" />
          </NuxtLink>
        </div>
      </div>

      <!-- Right: day timeline + activity feed -->
      <div class="coord-right">
        <div class="card">
          <div class="card-header">
            <h2 class="card-title"><Icon name="lucide:calendar-clock" size="16" /> Расписание на день</h2>
          </div>
          <AppCoordinatorDayTimeline :schedule="daySchedule" />
        </div>
        <div class="card">
          <div class="card-header">
            <h2 class="card-title"><Icon name="lucide:activity" size="16" /> Последние события</h2>
          </div>
          <AppCoordinatorActivityFeed :items="activityItems" />
        </div>
      </div>
    </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import type { EChartsOption } from 'echarts'
definePageMeta({ layout: 'app' })

const coordStore = useCoordinatorStore()
const authStore = useAuthStore()
const appData = useAppData()

const completing = ref<string | null>(null)
const { success: toastSuccess, error: toastError } = useToast()

const clinicId = computed(() => authStore.clinicId)
const loading = computed(() => coordStore.loading && coordStore.tasks.length === 0)

// ── Day schedule from today's appointments (real DB) ──
const daySchedule = ref<Array<{ time: string; event: string; detail?: string | null; active?: boolean; past?: boolean }>>([])

const activityItems = ref<Array<{ id: string | number; text: string; time: string }>>([])

onMounted(async () => {
  if (clinicId.value) {
    await Promise.all([
      coordStore.fetchTasks(clinicId.value),
      coordStore.fetchStats(clinicId.value),
    ])
  }

  // Fetch day schedule from appointments
  const supabase = useSupabaseClient()
  const today = new Date().toISOString().slice(0, 10)
  const nowMinutes = new Date().getHours() * 60 + new Date().getMinutes()

  const { data: todayAppts } = await supabase
    .from('appointments')
    .select('id, start_time, end_time, status, notes, visit_type, child_profiles(name)')
    .eq('appointment_date', today)
    .order('start_time', { ascending: true })
    .limit(20)

  if (todayAppts?.length) {
    daySchedule.value = todayAppts.map((a: any) => {
      const time = a.start_time?.slice(0, 5) || ''
      const child = a.child_profiles as Record<string, unknown> | null
      const name = child?.name || 'Пациент'
      const [h, m] = (a.start_time || '').split(':').map(Number)
      const slotMinutes = (h || 0) * 60 + (m || 0)
      return {
        time,
        event: `${a.visit_type || 'Приём'} — ${name}`,
        detail: a.notes || null,
        active: Math.abs(slotMinutes - nowMinutes) < 30,
        past: slotMinutes < nowMinutes - 30,
      }
    })
  } else {
    // Fallback mock if no appointments
    daySchedule.value = [
      { time: '09:00', event: 'Звонок — Каримова А.', detail: 'УЗИ просрочено', active: true },
      { time: '10:00', event: 'Подключение — Жумабаева К.', detail: 'Новая семья', active: false },
      { time: '11:30', event: 'Напоминание — Нурланова С.', detail: 'Автоматическое', active: false },
      { time: '14:00', event: 'Проверка adherence — 5 семей', detail: null, active: false },
      { time: '16:00', event: 'Отчёт для руководителя', detail: null, active: false },
    ]
  }

  // Fetch recent activity from notifications
  const { data: recentNotifs } = await supabase
    .from('notifications')
    .select('id, title, created_at')
    .order('created_at', { ascending: false })
    .limit(5)

  if (recentNotifs?.length) {
    activityItems.value = recentNotifs.map((n: any) => ({
      id: n.id,
      text: n.title,
      time: timeAgo(n.created_at),
    }))
  } else {
    activityItems.value = [
      { id: 1, text: 'Каримова А. подтвердила запись на УЗИ', time: '2 мин назад' },
      { id: 2, text: 'Push-уведомление отправлено Алиевой Д.', time: '15 мин назад' },
      { id: 3, text: 'Новая семья: Жумабаева К. зарегистрирована', time: '1 час назад' },
      { id: 4, text: 'Нурланова С. отметила приём витамина D3', time: '2 часа назад' },
      { id: 5, text: 'Сулейменова М. загрузила результат ОАК', time: '3 часа назад' },
    ]
  }
})
const greetingLine = computed(() => {
  const name = authStore.profile?.first_name || 'Координатор'
  const h = new Date().getHours()
  const greet = h < 6 ? 'Доброй ночи' : h < 12 ? 'Доброе утро' : h < 18 ? 'Добрый день' : 'Добрый вечер'
  return `${greet}, ${name}`
})

// ── Tasks from store (fallback to appData) ──
const hasRealTasks = computed(() => coordStore.tasks.length > 0)
const criticalTasks = computed(() =>
  hasRealTasks.value
    ? coordStore.criticalTasks
    : appData.coordinatorTasks.filter(t => t.priority === 'critical' && t.status === 'pending'),
)
const pendingTasks = computed(() =>
  hasRealTasks.value
    ? coordStore.pendingTasks.filter(t => t.priority !== 'critical')
    : appData.coordinatorTasks.filter(t => t.priority !== 'critical' && t.status === 'pending'),
)

// ── KPI cards from real stats ──
const kpiCards = computed(() => {
  const s = coordStore.stats
  const hasReal = s.total_families > 0 || coordStore.tasks.length > 0
  return [
    { label: 'Активных семей', value: hasReal ? s.total_families : appData.coordinatorKpi.activeFamilies.value, icon: 'lucide:users', color: 'var(--color-primary)' },
    { label: 'Срочных', value: hasReal ? criticalTasks.value.length : appData.coordinatorKpi.criticalTasks.value, icon: 'lucide:alert-triangle', color: 'var(--color-danger)' },
    { label: 'В работе', value: hasReal ? pendingTasks.value.length : appData.coordinatorKpi.pendingTasks.value, icon: 'lucide:clipboard-list', color: 'var(--color-warning)' },
    { label: 'Записей сегодня', value: hasReal ? s.today_appointments : appData.coordinatorKpi.todayAppointments.value, icon: 'lucide:calendar', color: 'var(--color-accent-sky)' },
  ]
})

// ── Actions ──
async function handleComplete(taskId: string) {
  completing.value = taskId
  try {
    const { error } = await coordStore.completeTask(taskId)
    if (error) toastError('Не удалось завершить задачу')
    else toastSuccess('Задача завершена!')
  } catch {
    toastError('Ошибка сети')
  } finally {
    completing.value = null
  }
}

function taskTypeLabel(type: string) {
  const map: Record<string, string> = { missed_appointment: 'Неявка', overdue_followup: 'Просрочено', low_adherence: 'Adherence', vaccination_reminder: 'Прививка', welcome_call: 'Звонок', reactivation: 'Реактивация' }
  return map[type] || type
}

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const h = Math.floor(diff / 3600000)
  if (h < 1) return 'только что'
  if (h < 24) return `${h}ч назад`
  return `${Math.floor(h / 24)}д назад`
}

// ── Task type distribution from real data ──
const palette = ['#8B7EC8', '#E8A0BF', '#F2C4A0', '#A8C8E8', '#E9C46A', '#D4727C']
const taskPieOption = computed<EChartsOption>(() => {
  let pieData: { name: string; value: number }[]
  if (hasRealTasks.value) {
    const typeCount = new Map<string, number>()
    for (const t of coordStore.tasks) {
      const label = taskTypeLabel(t.type)
      typeCount.set(label, (typeCount.get(label) || 0) + 1)
    }
    pieData = Array.from(typeCount).map(([name, value]) => ({ name, value }))
  } else {
    pieData = appData.tasksByType
  }
  return {
    tooltip: { trigger: 'item' as const },
    series: [{
      type: 'pie' as const, radius: ['45%', '72%'], padAngle: 3, itemStyle: { borderRadius: 6 },
      label: { show: false }, emphasis: { scale: true, scaleSize: 6 },
      data: pieData.map((t, i) => ({ name: t.name, value: t.value, itemStyle: { color: palette[i % palette.length] } })),
    }],
  }
})
</script>

<style scoped>
.coord-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.coord-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(168,200,232,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.coord-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.coord-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
@media (max-width: 640px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px; position: relative; overflow: hidden; }
.kpi-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.kpi-trend { font-size: 0.65rem; font-weight: 600; font-family: var(--font-mono); }
.kpi-trend.up { color: var(--color-success); }
.kpi-trend.down { color: var(--color-danger); }
.kpi-val { font-size: 1.3rem; font-weight: 700; font-family: var(--font-mono); display: block; }
.kpi-label { font-size: 0.68rem; color: var(--color-text-muted); }
.kpi-spark { position: absolute; bottom: 0; left: 0; width: 100%; height: 22px; opacity: 0.2; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card--danger { border-color: rgba(212,114,124,0.2); }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.badge { font-size: 0.65rem; font-weight: 700; padding: 2px 8px; border-radius: 10px; }
.badge--danger { background: rgba(212,114,124,0.12); color: var(--color-danger); }
.link-more { font-size: 0.72rem; color: var(--color-primary); text-decoration: none; font-weight: 500; }

.task-list { display: flex; flex-direction: column; gap: 4px; }
.task-row { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.task-row:hover { background: rgba(139,126,200,0.04); }
.task-row--critical { background: rgba(212,114,124,0.04); }
.task-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.task-dot--critical { background: var(--color-danger); }
.task-dot--high { background: var(--color-warning); }
.task-dot--medium { background: var(--color-primary); }
.task-dot--low { background: var(--color-text-muted); }
.task-body { flex: 1; min-width: 0; }
.task-title { font-size: 0.82rem; font-weight: 600; display: block; }
.task-meta { font-size: 0.65rem; color: var(--color-text-muted); }
.btn-sm { padding: 5px 12px; border-radius: 8px; font-size: 0.72rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); border: none; }
.btn-sm--done { background: rgba(124,184,212,0.12); color: var(--color-success); }

.quick-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
.quick-card { display: flex; align-items: center; gap: 12px; padding: 16px 18px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; text-decoration: none; color: inherit; transition: all 0.2s; }
.quick-card:hover { border-color: rgba(139,126,200,0.2); transform: translateY(-1px); }
.quick-card span { flex: 1; font-size: 0.85rem; font-weight: 500; }
.quick-arrow { color: var(--color-text-muted); }

.coord-columns { display: grid; grid-template-columns: 3fr 2fr; gap: 18px; }
.coord-left, .coord-right { display: flex; flex-direction: column; gap: 18px; }
@media (max-width: 768px) { .coord-columns { grid-template-columns: 1fr; } }

/* ─── Skeleton ─── */
.skel { background: linear-gradient(90deg, rgba(139,126,200,0.06) 0%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 100%); background-size: 200% 100%; animation: shimmer 1.4s ease infinite; border-radius: 14px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skel-hero { height: 80px; border-radius: 16px; }
.skel-kpi { height: 100px; }
.skel-card { height: 200px; margin-bottom: 16px; }
.card-empty { padding: 24px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 8px; font-size: 0.85rem; color: var(--color-text-muted); }

/* ─── Toast ─── */
.toast { position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%); z-index: 9999; display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-radius: 12px; font-size: 0.85rem; font-weight: 500; box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
.toast--success { background: #e8f8ee; color: #1a7a3e; border: 1px solid #c3ecd0; }
.toast--error { background: #fdecea; color: #a63232; border: 1px solid #f5c6c6; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }

.btn-sm:disabled { opacity: 0.5; cursor: default; }
</style>

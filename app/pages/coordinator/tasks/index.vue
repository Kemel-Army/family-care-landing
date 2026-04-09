<template>
  <div class="tasks-page">
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
          <span class="task-meta">{{ t.family_name }} · {{ taskTypeLabel(t.type) }} · {{ timeAgo(t.created_at) }}</span>
        </div>
        <div class="task-actions">
          <button class="btn-action btn-action--done">Выполнено</button>
          <button class="btn-action btn-action--dismiss">Отклонить</button>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="empty-card">
      <Icon name="lucide:check-circle" size="36" style="color:var(--color-success); opacity:0.4;" />
      <p class="empty-text">Все задачи выполнены</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const filter = ref('all')

const filterOptions = [
  { label: 'Все', value: 'all' },
  { label: 'Срочные', value: 'critical' },
  { label: 'Высокие', value: 'high' },
  { label: 'Средние', value: 'medium' },
  { label: 'Низкие', value: 'low' },
]

const activeTasks = computed(() => mock.coordinatorTasks.filter(t => t.status === 'pending'))

const filteredTasks = computed(() => {
  if (filter.value === 'all') return activeTasks.value
  return activeTasks.value.filter(t => t.priority === filter.value)
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
</style>

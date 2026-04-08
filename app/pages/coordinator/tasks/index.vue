<template>
  <div class="tasks-page">
    <header class="page-header">
      <NuxtLink to="/coordinator" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Назад
      </NuxtLink>
      <h1 class="page-title">Все задачи</h1>
      <div class="filter-group">
        <button
          v-for="f in filterOptions"
          :key="f.value"
          class="filter-btn"
          :class="{ active: filter === f.value }"
          @click="filter = f.value"
        >
          {{ f.label }}
        </button>
      </div>
    </header>

    <div v-if="filteredTasks.length" class="task-list">
      <div
        v-for="task in filteredTasks"
        :key="task.id"
        class="task-card"
        :class="{ critical: task.priority === 'critical' }"
      >
        <div class="task-priority" :class="task.priority" />
        <div class="task-content">
          <h3>{{ task.title }}</h3>
          <p v-if="task.notes" class="task-desc">{{ task.notes }}</p>
          <div class="task-meta">
            <span class="task-type">{{ taskTypeLabel(task.type) }}</span>
            <span v-if="task.due_date">· {{ task.due_date }}</span>
          </div>
        </div>
        <div class="task-actions">
          <button class="btn-sm done" @click="coordinatorStore.completeTask(task.id)">Выполнено</button>
          <button class="btn-sm dismiss" @click="coordinatorStore.dismissTask(task.id)">Отклонить</button>
        </div>
      </div>
    </div>

    <div v-else class="empty-state">
      <Icon name="lucide:check-circle" size="40" class="empty-icon" />
      <h3>Все задачи выполнены</h3>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const authStore = useAuthStore()
const coordinatorStore = useCoordinatorStore()
const filter = ref('all')

const filterOptions = [
  { label: 'Все', value: 'all' },
  { label: 'Срочные', value: 'critical' },
  { label: 'Напоминания', value: 'reminder' },
  { label: 'Контроль', value: 'follow_up' },
]

const filteredTasks = computed(() => {
  if (filter.value === 'all') return coordinatorStore.pendingTasks
  if (filter.value === 'critical') return coordinatorStore.criticalTasks
  return coordinatorStore.pendingTasks.filter(t => t.type === filter.value)
})

function taskTypeLabel(type: string) {
  const map: Record<string, string> = {
    reminder: 'Напоминание',
    alert: 'Оповещение',
    follow_up: 'Контроль',
    documentation: 'Документация',
    outreach: 'Аутрич',
  }
  return map[type] || type
}

onMounted(() => {
  if (authStore.clinicId) coordinatorStore.fetchTasks(authStore.clinicId)
})
</script>

<style scoped>
.tasks-page { max-width: 800px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; flex-wrap: wrap; align-items: center; gap: 12px; margin-bottom: 20px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; flex: 1; }

.filter-group { display: flex; gap: 6px; flex-wrap: wrap; width: 100%; }
.filter-btn {
  padding: 6px 12px; border: 1px solid var(--color-border); border-radius: 20px;
  background: var(--color-surface); font-size: 0.8rem; cursor: pointer; font-family: var(--font-body);
}
.filter-btn.active { border-color: var(--color-primary); background: var(--color-primary-ultralight); color: var(--color-primary); font-weight: 600; }

.task-list { display: flex; flex-direction: column; gap: 8px; }
.task-card {
  display: flex; align-items: flex-start; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm);
}
.task-card.critical { border-left: 3px solid var(--color-danger); }

.task-priority { width: 8px; height: 8px; border-radius: 50%; margin-top: 6px; flex-shrink: 0; }
.task-priority.critical { background: var(--color-danger); }
.task-priority.high { background: var(--color-warning); }
.task-priority.medium { background: var(--color-primary); }
.task-priority.low { background: var(--color-text-muted); }

.task-content { flex: 1; }
.task-content h3 { font-size: 0.9rem; font-weight: 600; }
.task-desc { font-size: 0.8rem; color: var(--color-text-secondary); margin-top: 2px; }
.task-meta { font-size: 0.75rem; color: var(--color-text-muted); margin-top: 4px; }
.task-type { font-weight: 500; }

.task-actions { display: flex; flex-direction: column; gap: 4px; flex-shrink: 0; }
.btn-sm {
  padding: 5px 10px; border-radius: 5px; font-size: 0.75rem; font-weight: 600;
  cursor: pointer; font-family: var(--font-body); border: none;
}
.btn-sm.done { background: rgba(124, 184, 212, 0.15); color: var(--color-success); }
.btn-sm.dismiss { background: transparent; color: var(--color-text-muted); border: 1px solid var(--color-border); }

.empty-state { text-align: center; padding: 48px; color: var(--color-text-muted); }
.empty-state h3 { font-size: 1rem; margin-top: 8px; color: var(--color-text-primary); }
.empty-icon { color: var(--color-success); }
</style>

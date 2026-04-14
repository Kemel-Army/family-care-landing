<template>
  <div class="demo-coord">
    <!-- KPI row -->
    <div class="grid-kpi">
      <div class="kpi-card">
        <span class="kpi-overline">Семей в маршруте</span>
        <span class="kpi-val font-display">{{ coordinatorKpi.activeFamilies.value }}</span>
        <span class="trend-up">+{{ coordinatorKpi.activeFamilies.trend }} за неделю</span>
      </div>
      <div class="kpi-card kpi-card--warm">
        <span class="kpi-overline">Срочных задач</span>
        <span class="kpi-val font-display">{{ coordinatorKpi.criticalTasks.value }}</span>
        <span class="trend-down">{{ pendingCritical }} в ожидании</span>
      </div>
      <div class="kpi-card kpi-card--blue">
        <span class="kpi-overline">Задач в очереди</span>
        <span class="kpi-val font-display">{{ coordinatorKpi.pendingTasks.value }}</span>
        <span class="trend-up">+{{ coordinatorKpi.pendingTasks.trend }}% vs пр. мес</span>
      </div>
      <div class="kpi-card kpi-card--success">
        <span class="kpi-overline">Визитов сегодня</span>
        <span class="kpi-val font-display">{{ coordinatorKpi.todayAppointments.value }}</span>
        <span class="trend-neutral">{{ families.filter(f => f.overdue_count > 0).length }} с просрочкой</span>
      </div>
    </div>

    <!-- Two columns: Tasks + Families -->
    <div class="demo-grid-2">
      <!-- Task queue -->
      <section class="demo-panel">
        <div class="panel-header">
          <h2 class="panel-title">Очередь задач</h2>
          <div class="panel-tabs">
            <button
              v-for="tab in taskTabs"
              :key="tab.key"
              class="panel-tab"
              :class="{ active: activeTab === tab.key }"
              @click="activeTab = tab.key"
            >
              {{ tab.label }} <span class="tab-count">{{ tab.count }}</span>
            </button>
          </div>
        </div>
        <div class="task-list">
          <div
            v-for="task in filteredTasks"
            :key="task.id"
            class="task-card"
            :class="[`priority-border--${task.priority}`, { 'task-done': task.status === 'done' }]"
          >
            <div class="task-body">
              <div class="task-header">
                <span class="task-name">{{ task.family_name }}</span>
                <span class="status-badge" :class="`status-badge--${task.priority}`">{{ priorityLabel(task.priority) }}</span>
              </div>
              <p class="task-desc">{{ task.title }}</p>
              <div class="task-meta">
                <span>{{ taskTypeLabel(task.type) }}</span>
                <span class="task-dot" />
                <span>{{ formatDate(task.created_at) }}</span>
              </div>
            </div>
            <div class="task-actions">
              <button class="task-action-btn" @click="completeTask(task.id)" :disabled="task.status === 'done'">
                <Icon :name="task.status === 'done' ? 'lucide:check-circle' : 'lucide:circle'" size="18" />
              </button>
              <button class="task-action-btn">
                <Icon name="lucide:phone" size="16" />
              </button>
              <button class="task-action-btn">
                <Icon name="lucide:calendar-plus" size="16" />
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Family list -->
      <section class="demo-panel">
        <div class="panel-header">
          <h2 class="panel-title">Семьи</h2>
        </div>
        <div class="family-list">
          <div v-for="fam in families" :key="fam.id" class="family-card">
            <div class="family-info">
              <span class="family-name">{{ fam.mother_name }}</span>
              <span class="family-stage">{{ fam.week_or_age }}</span>
            </div>
            <div class="family-meta">
              <span class="family-adherence" :class="adherenceClass(fam.adherence)">
                {{ fam.adherence }}%
              </span>
              <span v-if="fam.overdue_count > 0" class="family-overdue">
                {{ fam.overdue_count }} просроч.
              </span>
              <span class="family-activity">{{ fam.last_activity }}</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'demo' })

const { coordinatorKpi, coordinatorTasks, families } = useMockData()

const tasks = ref(coordinatorTasks.map(t => ({ ...t })))

const activeTab = ref('all')

const pendingCritical = computed(() => tasks.value.filter(t => t.priority === 'critical' && t.status === 'pending').length)

const taskTabs = computed(() => [
  { key: 'all', label: 'Все', count: tasks.value.filter(t => t.status === 'pending').length },
  { key: 'critical', label: 'Срочные', count: tasks.value.filter(t => (t.priority === 'critical' || t.priority === 'high') && t.status === 'pending').length },
  { key: 'done', label: 'Выполнено', count: tasks.value.filter(t => t.status === 'done').length },
])

const filteredTasks = computed(() => {
  if (activeTab.value === 'critical') return tasks.value.filter(t => (t.priority === 'critical' || t.priority === 'high') && t.status === 'pending')
  if (activeTab.value === 'done') return tasks.value.filter(t => t.status === 'done')
  return tasks.value.filter(t => t.status === 'pending')
})

function completeTask(id: string) {
  const task = tasks.value.find(t => t.id === id)
  if (task) task.status = 'done'
}

function priorityLabel(priority: string) {
  const labels: Record<string, string> = { critical: 'Критично', high: 'Высокий', medium: 'Средний', low: 'Низкий' }
  return labels[priority] || priority
}

function taskTypeLabel(type: string) {
  const labels: Record<string, string> = {
    missed_appointment: 'Неявка',
    overdue_followup: 'Просрочено',
    low_adherence: 'Низкий Adherence',
    vaccination_reminder: 'Вакцинация',
    welcome_call: 'Звонок',
    reactivation: 'Реактивация',
  }
  return labels[type] || type
}

function adherenceClass(val: number) {
  if (val >= 80) return 'adherence--success'
  if (val >= 60) return 'adherence--warning'
  return 'adherence--danger'
}

function formatDate(iso: string) {
  const d = new Date(iso)
  const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  return `${d.getDate()} ${months[d.getMonth()]}`
}
</script>

<style scoped>
.demo-coord {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* KPI grid */
.grid-kpi {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.kpi-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 20px;
  position: relative;
  overflow: hidden;
}

.kpi-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1.5px;
  background: var(--gradient-cta);
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: exclude;
  -webkit-mask-composite: xor;
  pointer-events: none;
  opacity: 0.4;
}

.kpi-card--warm::before { background: linear-gradient(135deg, var(--color-accent-warm), var(--color-secondary)); }
.kpi-card--blue::before { background: linear-gradient(135deg, var(--color-accent-blue), var(--color-primary)); }
.kpi-card--success::before { background: linear-gradient(135deg, var(--color-success), var(--color-accent-blue)); }

.kpi-overline {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.kpi-val {
  display: block;
  font-size: clamp(1.5rem, 2.5vw, 2rem);
  font-weight: 800;
  color: var(--color-primary);
  margin: 6px 0 4px;
}

.trend-up { font-size: var(--text-xs); color: var(--color-success); font-weight: 600; }
.trend-down { font-size: var(--text-xs); color: var(--color-danger); font-weight: 600; }
.trend-neutral { font-size: var(--text-xs); color: var(--color-text-muted); font-weight: 600; }

/* Two columns */
.demo-grid-2 {
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 20px;
}

/* Panels */
.demo-panel {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: 20px;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 12px;
}

.panel-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0;
}

.panel-tabs {
  display: flex;
  gap: 4px;
}

.panel-tab {
  padding: 6px 12px;
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  font-weight: 500;
  border: none;
  background: transparent;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all var(--transition-fast);
}

.panel-tab.active {
  background: var(--color-primary-light);
  color: var(--color-primary);
  font-weight: 600;
}

.tab-count {
  opacity: 0.7;
}

/* Tasks */
.task-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.task-card {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 14px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border-light);
  border-left-width: 3px;
  transition: opacity var(--transition-fast);
}

.task-done {
  opacity: 0.5;
}

.priority-border--critical { border-left-color: var(--color-danger); }
.priority-border--high { border-left-color: var(--color-warning); }
.priority-border--medium { border-left-color: var(--color-accent-blue); }
.priority-border--low { border-left-color: var(--color-border); }

.task-body { flex: 1; }

.task-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.task-name {
  font-weight: 600;
  color: var(--color-text-primary);
}

.status-badge {
  font-size: 10px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: var(--radius-full);
}

.status-badge--critical { background: rgba(212, 114, 124, 0.12); color: #B84E5A; }
.status-badge--high { background: rgba(233, 196, 106, 0.15); color: #C4930E; }
.status-badge--medium { background: rgba(168, 200, 232, 0.15); color: var(--color-accent-blue); }
.status-badge--low { background: var(--color-bg-alt); color: var(--color-text-muted); }

.task-desc {
  font-size: var(--text-sm);
  color: var(--color-text-secondary);
  margin: 0 0 6px;
}

.task-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.task-dot {
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: var(--color-text-muted);
}

.task-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
}

.task-action-btn {
  width: 32px;
  height: 32px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border-light);
  background: transparent;
  color: var(--color-text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.task-action-btn:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
  background: var(--color-primary-ultralight);
}

.task-action-btn:disabled {
  color: var(--color-success);
  border-color: transparent;
  cursor: default;
}

/* Schedule → Family list */
.family-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.family-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border-light);
  transition: box-shadow var(--transition-fast);
}

.family-card:hover {
  box-shadow: var(--shadow-sm);
}

.family-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.family-name {
  font-weight: 600;
  font-size: var(--text-sm);
  color: var(--color-text-primary);
}

.family-stage {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.family-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}

.family-adherence {
  font-size: var(--text-xs);
  font-weight: 700;
}

.adherence--success { color: var(--color-success); }
.adherence--warning { color: #C4930E; }
.adherence--danger { color: var(--color-danger); }

.family-overdue {
  font-size: var(--text-xs);
  font-weight: 600;
  color: var(--color-danger);
  background: rgba(212, 114, 124, 0.1);
  padding: 2px 8px;
  border-radius: var(--radius-full);
}

.family-activity {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

/* Responsive */
@media (max-width: 768px) {
  .grid-kpi {
    grid-template-columns: repeat(2, 1fr);
  }
  .demo-grid-2 {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .grid-kpi {
    grid-template-columns: 1fr;
  }
}
</style>

<template>
  <div class="demo-coord">
    <!-- KPI row -->
    <div class="grid-kpi">
      <div class="kpi-card">
        <span class="kpi-overline">Семей в маршруте</span>
        <span class="kpi-val font-display">247</span>
        <span class="trend-up">+8 за неделю</span>
      </div>
      <div class="kpi-card kpi-card--warm">
        <span class="kpi-overline">Срочных задач</span>
        <span class="kpi-val font-display">12</span>
        <span class="trend-down">3 просрочены</span>
      </div>
      <div class="kpi-card kpi-card--blue">
        <span class="kpi-overline">Adherence средний</span>
        <span class="kpi-val font-display">87%</span>
        <span class="trend-up">+4% vs пр. мес</span>
      </div>
      <div class="kpi-card kpi-card--success">
        <span class="kpi-overline">Визитов сегодня</span>
        <span class="kpi-val font-display">18</span>
        <span class="trend-neutral">2 no-show risk</span>
      </div>
    </div>

    <!-- Two columns: Tasks + Schedule -->
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
            :class="[`priority-border--${task.priority}`, { 'task-done': task.done }]"
          >
            <div class="task-body">
              <div class="task-header">
                <span class="task-name">{{ task.family }}</span>
                <span class="status-badge" :class="`status-badge--${task.priority}`">{{ task.priorityLabel }}</span>
              </div>
              <p class="task-desc">{{ task.description }}</p>
              <div class="task-meta">
                <span>{{ task.stage }}</span>
                <span class="task-dot" />
                <span>Adherence {{ task.adherence }}%</span>
              </div>
            </div>
            <div class="task-actions">
              <button class="task-action-btn" @click="task.done = true" :disabled="task.done">
                <Icon :name="task.done ? 'lucide:check-circle' : 'lucide:circle'" size="18" />
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

      <!-- Day schedule -->
      <section class="demo-panel">
        <div class="panel-header">
          <h2 class="panel-title">Расписание на день</h2>
        </div>
        <div class="schedule-timeline">
          <div v-for="slot in schedule" :key="slot.time" class="schedule-slot">
            <span class="schedule-time font-mono">{{ slot.time }}</span>
            <div class="schedule-dot" :class="{ 'dot--active': slot.active }" />
            <div class="schedule-event">
              <span class="schedule-event-name">{{ slot.event }}</span>
              <span v-if="slot.detail" class="schedule-event-detail">{{ slot.detail }}</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'demo' })

const activeTab = ref('urgent')

const taskTabs = [
  { key: 'urgent', label: 'Срочные', count: 12 },
  { key: 'today', label: 'Сегодня', count: 8 },
  { key: 'week', label: 'Неделя', count: 23 },
]

const tasks = ref([
  { id: 1, family: 'Каримова А.', description: 'УЗИ II триместр просрочено 3 дня', stage: 'Беременность · 24 нед', adherence: 45, priority: 'critical', priorityLabel: 'Критично', type: 'urgent', done: false },
  { id: 2, family: 'Алиева Д.', description: 'Неявка на приём гинеколога', stage: 'Беременность · 16 нед', adherence: 72, priority: 'high', priorityLabel: 'Высокий', type: 'urgent', done: false },
  { id: 3, family: 'Жумабаева К.', description: 'Новая семья — подключение, 8 недель', stage: 'Новая · Маршрут не начат', adherence: 0, priority: 'medium', priorityLabel: 'Средний', type: 'urgent', done: false },
  { id: 4, family: 'Нурланова С.', description: 'Напомнить о приёме витаминов', stage: 'Малыш · 6 мес', adherence: 98, priority: 'low', priorityLabel: 'Низкий', type: 'today', done: false },
  { id: 5, family: 'Сулейменова М.', description: 'Проверить результаты ОАК', stage: 'Беременность · 20 нед', adherence: 85, priority: 'medium', priorityLabel: 'Средний', type: 'today', done: false },
])

const filteredTasks = computed(() => {
  if (activeTab.value === 'urgent') return tasks.value.filter(t => t.type === 'urgent')
  if (activeTab.value === 'today') return tasks.value.filter(t => t.type === 'today' || t.type === 'urgent')
  return tasks.value
})

const schedule = [
  { time: '09:00', event: 'Звонок — Каримова А.', detail: 'УЗИ просрочено', active: true },
  { time: '10:00', event: 'Подключение — Жумабаева К.', detail: 'Новая семья', active: false },
  { time: '11:30', event: 'Напоминание — Нурланова С.', detail: 'Автоматическое', active: false },
  { time: '14:00', event: 'Проверка adherence — 5 семей', detail: null, active: false },
  { time: '16:00', event: 'Отчёт для руководителя', detail: null, active: false },
]
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

/* Schedule */
.schedule-timeline {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.schedule-slot {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--color-border-light);
}

.schedule-slot:last-child {
  border-bottom: none;
}

.schedule-time {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  width: 44px;
  flex-shrink: 0;
  padding-top: 2px;
}

.schedule-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--color-border);
  flex-shrink: 0;
  margin-top: 4px;
}

.dot--active {
  background: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(139, 126, 200, 0.2);
}

.schedule-event {
  flex: 1;
}

.schedule-event-name {
  display: block;
  font-weight: 600;
  font-size: var(--text-sm);
  color: var(--color-text-primary);
}

.schedule-event-detail {
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

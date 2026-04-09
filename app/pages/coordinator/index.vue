<template>
  <div class="coord-page">
    <!-- Hero -->
    <div class="coord-hero">
      <div>
        <h1 class="coord-hero-title">Панель координатора</h1>
        <p class="coord-hero-sub">Доброе утро! У вас {{ criticalTasks.length }} срочных задач сегодня</p>
      </div>
    </div>

    <!-- KPI strip -->
    <div class="kpi-grid">
      <div v-for="k in kpiCards" :key="k.label" class="kpi-card">
        <div class="kpi-top">
          <Icon :name="k.icon" size="16" :style="{ color: k.color }" />
          <span class="kpi-trend" :class="k.trendDir">{{ k.trendDir === 'up' ? '+' : '' }}{{ k.trend }}%</span>
        </div>
        <span class="kpi-val">{{ k.value }}</span>
        <span class="kpi-label">{{ k.label }}</span>
        <svg class="kpi-spark" viewBox="0 0 60 20" preserveAspectRatio="none">
          <polyline :points="sparkline(k.sparkline)" fill="none" :stroke="k.color" stroke-width="1.5" stroke-linecap="round" />
        </svg>
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
            <span class="task-meta">{{ t.family_name }} · {{ timeAgo(t.created_at) }}</span>
          </div>
          <button class="btn-sm btn-sm--done">Готово</button>
        </div>
      </div>
    </div>

    <!-- Pending tasks -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:clipboard-list" size="16" /> Задачи</h2>
        <NuxtLink to="/coordinator/tasks" class="link-more">Все задачи →</NuxtLink>
      </div>
      <div class="task-list">
        <div v-for="t in pendingTasks" :key="t.id" class="task-row">
          <div class="task-dot" :class="`task-dot--${t.priority}`" />
          <div class="task-body">
            <span class="task-title">{{ t.title }}</span>
            <span class="task-meta">{{ t.family_name }} · {{ taskTypeLabel(t.type) }}</span>
          </div>
          <button class="btn-sm btn-sm--done">✓</button>
        </div>
      </div>
    </div>

    <!-- Task distribution chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:pie-chart" size="16" /> Распределение задач</h2>
      </div>
      <AppSharedEChart :option="taskPieOption" height="220px" />
    </div>

    <!-- Quick links -->
    <div class="quick-grid">
      <NuxtLink to="/coordinator/families" class="quick-card">
        <Icon name="lucide:users" size="20" style="color:var(--color-primary)" />
        <span>Все семьи</span>
        <Icon name="lucide:chevron-right" size="14" class="quick-arrow" />
      </NuxtLink>
      <NuxtLink to="/coordinator/tasks" class="quick-card">
        <Icon name="lucide:clipboard-list" size="20" style="color:var(--color-accent-peach)" />
        <span>Все задачи</span>
        <Icon name="lucide:chevron-right" size="14" class="quick-arrow" />
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const kpiCards = [
  { label: 'Активных семей', value: mock.coordinatorKpi.activeFamilies.value, trend: mock.coordinatorKpi.activeFamilies.trend, trendDir: 'up', icon: 'lucide:users', color: 'var(--color-primary)', sparkline: mock.coordinatorKpi.activeFamilies.sparkline },
  { label: 'Срочных', value: mock.coordinatorKpi.criticalTasks.value, trend: mock.coordinatorKpi.criticalTasks.trend, trendDir: 'down', icon: 'lucide:alert-triangle', color: 'var(--color-danger)', sparkline: mock.coordinatorKpi.criticalTasks.sparkline },
  { label: 'В работе', value: mock.coordinatorKpi.pendingTasks.value, trend: mock.coordinatorKpi.pendingTasks.trend, trendDir: 'up', icon: 'lucide:clipboard-list', color: 'var(--color-warning)', sparkline: mock.coordinatorKpi.pendingTasks.sparkline },
  { label: 'Записей сегодня', value: mock.coordinatorKpi.todayAppointments.value, trend: mock.coordinatorKpi.todayAppointments.trend, trendDir: 'up', icon: 'lucide:calendar', color: 'var(--color-accent-sky)', sparkline: mock.coordinatorKpi.todayAppointments.sparkline },
]

const criticalTasks = computed(() => mock.coordinatorTasks.filter(t => t.priority === 'critical' && t.status === 'pending'))
const pendingTasks = computed(() => mock.coordinatorTasks.filter(t => t.priority !== 'critical' && t.status === 'pending'))

function sparkline(pts: number[]) {
  const max = Math.max(...pts, 1)
  return pts.map((v, i) => `${(i / (pts.length - 1)) * 60},${20 - (v / max) * 18}`).join(' ')
}

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

const palette = ['#8B7EC8', '#E8A0BF', '#F2C4A0', '#A8C8E8', '#E9C46A', '#D4727C']
const taskPieOption = computed(() => ({
  tooltip: { trigger: 'item' },
  series: [{
    type: 'pie', radius: ['45%', '72%'], padAngle: 3, itemStyle: { borderRadius: 6 },
    label: { show: false }, emphasis: { scale: true, scaleSize: 6 },
    data: mock.tasksByType.map((t, i) => ({ name: t.name, value: t.value, itemStyle: { color: palette[i % palette.length] } })),
  }],
}))
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
</style>

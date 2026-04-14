<template>
  <div class="demo-family">
    <!-- Greeting -->
    <div class="demo-greeting">
      <h1 class="demo-greeting-title font-display">Привет, Айгерим!</h1>
      <p class="demo-greeting-sub">{{ children[0]?.first_name }} · {{ childAge }}</p>
    </div>

    <!-- KPI row -->
    <div class="demo-kpi-row">
      <div class="kpi-card">
        <span class="kpi-label">Adherence сегодня</span>
        <div class="kpi-progress">
          <div class="kpi-progress-track">
            <div class="kpi-progress-fill" :style="{ width: todayAdherencePercent + '%' }" />
          </div>
          <span class="kpi-progress-text font-mono">{{ todayTaken }}/{{ todayTotal }}</span>
        </div>
      </div>
      <div class="kpi-card kpi-card--warm">
        <span class="kpi-label">Streak</span>
        <div class="kpi-val">
          <span class="kpi-number font-display">{{ streaks.doses.current }}</span>
          <span class="kpi-unit">дней подряд</span>
        </div>
      </div>
      <div class="kpi-card kpi-card--blue">
        <span class="kpi-label">Маршрут</span>
        <div class="kpi-val">
          <span class="kpi-number font-display">{{ familyKpi.journeyProgress.value }}%</span>
          <span class="kpi-unit">{{ familyKpi.completedEvents }} из {{ familyKpi.totalEvents }}</span>
        </div>
      </div>
    </div>

    <!-- Today's prescriptions -->
    <section class="demo-section">
      <h2 class="demo-section-title">Назначения на сегодня</h2>
      <div class="demo-doses">
        <div
          v-for="rx in prescriptions"
          :key="rx.id"
          class="rx-card"
        >
          <div class="rx-header">
            <div class="rx-icon" :style="{ background: rxColors[rx.id] || 'var(--color-primary)' }">
              <Icon name="lucide:pill" size="16" />
            </div>
            <div class="rx-info">
              <span class="rx-name">{{ rx.medication }}</span>
              <span class="rx-dosage">{{ rx.dosage }} · {{ rx.frequency }}</span>
            </div>
            <span class="rx-adherence" :class="adherenceClass(rx.adherencePercent)">
              {{ rx.adherencePercent }}%
            </span>
          </div>
          <div class="rx-doses">
            <div
              v-for="dose in rx.todayDoses"
              :key="dose.id"
              class="dose-row"
              :class="{ 'dose-taken': doseStatuses[dose.id] === 'confirmed' }"
            >
              <span class="dose-time font-mono">{{ dose.time }}</span>
              <button
                v-if="doseStatuses[dose.id] !== 'confirmed'"
                class="dose-btn"
                @click="takeDose(dose.id)"
              >
                Принять
              </button>
              <span v-else class="dose-done">
                <Icon name="lucide:check" size="16" />
                Принято
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Upcoming events -->
    <section class="demo-section">
      <h2 class="demo-section-title">Ближайшие события</h2>
      <div class="demo-events">
        <div
          v-for="event in upcomingEvents"
          :key="event.id"
          class="event-card"
          :class="{ 'event-overdue': event.status === 'overdue' }"
        >
          <div class="event-icon" :style="{ background: eventColor(event.status) }">
            <Icon :name="eventIcon(event.type)" size="16" />
          </div>
          <div class="event-body">
            <span class="event-name">{{ event.title }}</span>
            <span class="event-date">{{ event.description }}</span>
          </div>
          <span class="event-badge" :class="`badge--${event.status}`">{{ statusLabel(event.status) }}</span>
        </div>
      </div>
    </section>

    <!-- Vaccinations -->
    <section class="demo-section">
      <h2 class="demo-section-title">Прививки</h2>
      <div class="demo-vaccinations">
        <div
          v-for="v in vaccinations"
          :key="v.id"
          class="vacc-card"
          :class="{ 'vacc-done': v.status === 'completed' }"
        >
          <Icon :name="v.status === 'completed' ? 'lucide:shield-check' : 'lucide:shield'" size="18" class="vacc-icon" />
          <div class="vacc-body">
            <span class="vacc-name">{{ v.name }}</span>
            <span class="vacc-dose">{{ v.dose }}</span>
          </div>
          <span class="vacc-status" :class="`vacc-status--${v.status}`">
            {{ v.status === 'completed' ? formatDate(v.date) : 'Предстоит' }}
          </span>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'demo' })

const {
  familyKpi, prescriptions, journeyEvents, vaccinations,
  children, streaks,
} = useMockData()

// Track dose statuses reactively — initialized from mock data
const doseStatuses = ref<Record<string, string>>({})
for (const rx of prescriptions) {
  for (const dose of rx.todayDoses) {
    doseStatuses.value[dose.id] = dose.status
  }
}

const todayTotal = computed(() => prescriptions.reduce((sum, rx) => sum + rx.todayDoses.length, 0))
const todayTaken = computed(() => Object.values(doseStatuses.value).filter(s => s === 'confirmed').length)
const todayAdherencePercent = computed(() => todayTotal.value ? Math.round((todayTaken.value / todayTotal.value) * 100) : 0)

const upcomingEvents = computed(() => journeyEvents.filter(e => e.status !== 'completed').slice(0, 5))

const childAge = computed(() => {
  if (!children[0]) return ''
  const birth = new Date(children[0].birth_date)
  const now = new Date()
  const months = (now.getFullYear() - birth.getFullYear()) * 12 + now.getMonth() - birth.getMonth()
  const days = now.getDate() - birth.getDate()
  return `${months} мес. ${days >= 0 ? days : 30 + days} дней`
})

function takeDose(id: string) {
  doseStatuses.value[id] = 'confirmed'
}

const rxColors: Record<string, string> = {
  rx1: 'var(--color-primary)',
  rx2: 'var(--color-secondary)',
  rx3: 'var(--color-accent-blue)',
  rx4: 'var(--color-success)',
}

function adherenceClass(val: number) {
  if (val >= 90) return 'adherence--success'
  if (val >= 70) return 'adherence--warning'
  return 'adherence--danger'
}

function eventColor(status: string) {
  const colors: Record<string, string> = {
    overdue: 'var(--color-danger)',
    due: 'var(--color-warning)',
    upcoming: 'var(--color-accent-blue)',
  }
  return colors[status] || 'var(--color-primary)'
}

function eventIcon(type: string) {
  const icons: Record<string, string> = {
    ultrasound: 'lucide:scan',
    analysis: 'lucide:flask-conical',
    screening: 'lucide:scan-search',
    checkup: 'lucide:stethoscope',
    vaccination: 'lucide:shield-check',
  }
  return icons[type] || 'lucide:calendar'
}

function statusLabel(status: string) {
  const labels: Record<string, string> = { overdue: 'Просрочено', due: 'Сегодня', upcoming: 'Скоро' }
  return labels[status] || status
}

function formatDate(iso: string) {
  const d = new Date(iso)
  const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  return `${d.getDate()} ${months[d.getMonth()]}`
}
</script>

<style scoped>
.demo-family {
  max-width: 600px;
  margin: 0 auto;
}

.demo-greeting {
  margin-bottom: 24px;
}

.demo-greeting-title {
  font-size: var(--text-h2);
  color: var(--color-text-primary);
  margin: 0;
}

.demo-greeting-sub {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  margin: 4px 0 0;
}

/* KPI row */
.demo-kpi-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 32px;
}

.kpi-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 16px;
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
  opacity: 0.5;
}

.kpi-card--warm::before {
  background: linear-gradient(135deg, var(--color-accent-warm), var(--color-secondary));
}

.kpi-card--blue::before {
  background: linear-gradient(135deg, var(--color-accent-blue), var(--color-primary));
}

.kpi-label {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.kpi-val {
  display: flex;
  align-items: baseline;
  gap: 6px;
  margin-top: 8px;
}

.kpi-number {
  font-size: clamp(1.25rem, 2vw, 1.5rem);
  font-weight: 800;
  color: var(--color-primary);
}

.kpi-unit {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.kpi-progress {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
}

.kpi-progress-track {
  flex: 1;
  height: 6px;
  background: var(--color-border-light);
  border-radius: 3px;
  overflow: hidden;
}

.kpi-progress-fill {
  height: 100%;
  background: var(--gradient-cta);
  border-radius: 3px;
  transition: width 0.6s ease;
}

.kpi-progress-text {
  font-size: var(--text-sm);
  font-weight: 600;
  color: var(--color-primary);
}

/* Sections */
.demo-section {
  margin-bottom: 32px;
}

.demo-section-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 16px;
}

/* Doses → Rx cards */
.demo-doses {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rx-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 14px 16px;
}

.rx-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.rx-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.rx-info {
  flex: 1;
}

.rx-name {
  display: block;
  font-weight: 600;
  font-size: var(--text-body);
  color: var(--color-text-primary);
}

.rx-dosage {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.rx-adherence {
  font-size: var(--text-xs);
  font-weight: 700;
}

.adherence--success { color: var(--color-success); }
.adherence--warning { color: #C4930E; }
.adherence--danger { color: var(--color-danger); }

.rx-doses {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding-left: 48px;
}

.dose-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 0;
}

.dose-taken {
  opacity: 0.6;
}

.dose-time {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  width: 44px;
}

.dose-btn {
  padding: 6px 16px;
  border-radius: var(--radius-full);
  background: var(--gradient-cta);
  color: white;
  font-size: var(--text-xs);
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: opacity var(--transition-fast);
}

.dose-btn:hover {
  opacity: 0.9;
}

.dose-done {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: var(--text-xs);
  font-weight: 600;
  color: var(--color-success);
}

/* Events */
.demo-events {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.event-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
}

.event-overdue {
  border-left: 3px solid var(--color-danger);
  background: rgba(212, 114, 124, 0.03);
}

.event-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.event-body {
  flex: 1;
}

.event-name {
  display: block;
  font-weight: 600;
  color: var(--color-text-primary);
}

.event-date {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.event-badge {
  font-size: var(--text-xs);
  font-weight: 600;
  padding: 4px 10px;
  border-radius: var(--radius-full);
}

.badge--warning {
  background: rgba(233, 196, 106, 0.15);
  color: #C4930E;
}

.badge--info {
  background: rgba(139, 126, 200, 0.1);
  color: var(--color-primary);
}

.badge--neutral {
  background: var(--color-bg-alt);
  color: var(--color-text-secondary);
}

.badge--overdue {
  background: rgba(212, 114, 124, 0.12);
  color: #B84E5A;
}

.badge--due {
  background: rgba(233, 196, 106, 0.15);
  color: #C4930E;
}

.badge--upcoming {
  background: rgba(139, 126, 200, 0.1);
  color: var(--color-primary);
}

/* Vaccinations */
.demo-vaccinations {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.vacc-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 14px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border-light);
  background: var(--color-surface);
}

.vacc-done {
  opacity: 0.7;
}

.vacc-icon {
  color: var(--color-accent-blue);
  flex-shrink: 0;
}

.vacc-done .vacc-icon {
  color: var(--color-success);
}

.vacc-body {
  flex: 1;
}

.vacc-name {
  display: block;
  font-weight: 600;
  font-size: var(--text-sm);
  color: var(--color-text-primary);
}

.vacc-dose {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.vacc-status {
  font-size: var(--text-xs);
  font-weight: 600;
}

.vacc-status--completed { color: var(--color-success); }
.vacc-status--upcoming { color: var(--color-accent-blue); }

@media (max-width: 480px) {
  .demo-kpi-row {
    grid-template-columns: 1fr;
  }
}
</style>

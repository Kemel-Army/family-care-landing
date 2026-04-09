<template>
  <div class="dashboard">
    <!-- Hero Banner -->
    <section class="hero-banner">
      <div class="hero-content">
        <div class="hero-text">
          <p class="hero-greeting">{{ stageSubtitle }}</p>
          <h1 class="hero-title">{{ stageTitle }}</h1>
          <div class="hero-meta">
            <span class="hero-week">22-я неделя</span>
            <span class="hero-sep">·</span>
            <span class="hero-date">{{ todayFormatted }}</span>
          </div>
        </div>
        <div class="hero-ring">
          <AppSharedProgressRing
            :value="mock.familyKpi.journeyProgress.value"
            :size="100"
            :strokeWidth="8"
            variant="primary"
          />
        </div>
      </div>
      <div class="hero-strip">
        <div class="hero-strip-item">
          <Icon name="lucide:check-circle" size="14" />
          <span>{{ mock.familyKpi.completedEvents }} из {{ mock.familyKpi.totalEvents }} событий</span>
        </div>
        <div class="hero-strip-item">
          <Icon name="lucide:clock" size="14" />
          <span>Следующее через {{ mock.familyKpi.nextEventDays }} дня</span>
        </div>
        <div class="hero-strip-item" v-if="mock.familyKpi.unreadNotifications > 0">
          <Icon name="lucide:bell" size="14" />
          <span>{{ mock.familyKpi.unreadNotifications }} уведомления</span>
        </div>
      </div>
    </section>

    <!-- KPI Row -->
    <section class="kpi-row">
      <AppSharedStatCard
        title="Прогресс маршрута"
        :value="mock.familyKpi.journeyProgress.value"
        suffix="%"
        :trend="mock.familyKpi.journeyProgress.trend"
        :sparkline="mock.familyKpi.journeyProgress.sparkline"
        icon="lucide:route"
        variant="default"
      />
      <AppSharedStatCard
        title="Adherence"
        :value="mock.familyKpi.adherence.value"
        suffix="%"
        :trend="mock.familyKpi.adherence.trend"
        :sparkline="mock.familyKpi.adherence.sparkline"
        icon="lucide:pill"
        variant="warm"
      />
      <AppSharedStatCard
        title="Выполнено"
        :value="mock.familyKpi.completedEvents"
        :trend="0"
        icon="lucide:check-circle"
        variant="blue"
      />
      <div class="streak-stat-wrap" :class="{ 'streak-fire': mock.streaks.doses.current > 3 }">
        <AppSharedStatCard
          title="Серия (дни)"
          :value="mock.streaks.doses.current"
          :trend="0"
          icon="lucide:flame"
          variant="success"
        />
      </div>
    </section>

    <!-- Quick Actions -->
    <section class="quick-actions">
      <button class="qa-btn" @click="navigateTo('/family/prescriptions')">
        <span class="qa-icon qa-icon--lavender"><Icon name="lucide:pill" size="20" /></span>
        <span class="qa-label">Витамины</span>
        <span v-if="prescriptionsStore.pendingDoses.length || mock.prescriptions.flatMap(p => p.todayDoses).filter(d => d.status === 'pending').length" class="qa-badge">{{ prescriptionsStore.pendingDoses.length || mock.prescriptions.flatMap(p => p.todayDoses).filter(d => d.status === 'pending').length }}</span>
      </button>
      <button class="qa-btn" @click="navigateTo('/family/appointments')">
        <span class="qa-icon qa-icon--rose"><Icon name="lucide:calendar-check" size="20" /></span>
        <span class="qa-label">Записи</span>
      </button>
      <button class="qa-btn" @click="navigateTo('/family/vaccinations')">
        <span class="qa-icon qa-icon--peach"><Icon name="lucide:shield-check" size="20" /></span>
        <span class="qa-label">Прививки</span>
      </button>
      <button class="qa-btn" @click="navigateTo('/family/journey')">
        <span class="qa-icon qa-icon--sky"><Icon name="lucide:route" size="20" /></span>
        <span class="qa-label">Маршрут</span>
      </button>
      <button class="qa-btn" @click="navigateTo('/family/documents')">
        <span class="qa-icon qa-icon--lavender"><Icon name="lucide:folder" size="20" /></span>
        <span class="qa-label">Документы</span>
      </button>
      <button class="qa-btn" @click="navigateTo('/family/ai-assistant')">
        <span class="qa-icon qa-icon--rose"><Icon name="lucide:sparkles" size="20" /></span>
        <span class="qa-label">AI</span>
      </button>
    </section>

    <!-- Two columns: left = events, right = prescriptions -->
    <section class="main-grid">
      <!-- Left Column -->
      <div class="main-col">
        <!-- Overdue Alerts -->
        <div v-if="overdueEvents.length" class="card card--danger">
          <div class="card-header">
            <h2 class="card-title card-title--danger">
              <Icon name="lucide:alert-triangle" size="16" />
              Просрочено
            </h2>
            <span class="card-count">{{ overdueEvents.length }}</span>
          </div>
          <div class="events-list">
            <div v-for="ev in overdueEvents" :key="ev.id" class="event-row event-row--overdue">
              <div class="event-dot event-dot--danger" />
              <div class="event-info">
                <span class="event-name">{{ ev.title }}</span>
                <span class="event-desc">{{ ev.description }}</span>
              </div>
              <span class="event-date">{{ formatDate(ev.due_date) }}</span>
            </div>
          </div>
        </div>

        <!-- Today's Events -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:clock" size="16" />
              Сегодня
            </h2>
          </div>
          <div v-if="todayEvents.length" class="events-list">
            <div v-for="ev in todayEvents" :key="ev.id" class="event-row">
              <div class="event-dot event-dot--primary" />
              <div class="event-info">
                <span class="event-name">{{ ev.title }}</span>
                <span class="event-desc">{{ ev.description }}</span>
              </div>
              <button class="event-action" @click="handleComplete(ev.id)">
                <Icon name="lucide:check" size="14" />
              </button>
            </div>
          </div>
          <div v-else class="card-empty">
            <Icon name="lucide:check-circle" size="28" style="color: var(--color-success); opacity: 0.5" />
            <span>На сегодня всё выполнено</span>
          </div>
        </div>

        <!-- Upcoming Events -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:calendar-check" size="16" />
              Ближайшее
            </h2>
            <NuxtLink to="/family/journey" class="card-link">Маршрут →</NuxtLink>
          </div>
          <div class="events-list">
            <div v-for="ev in upcomingEvents.slice(0, 4)" :key="ev.id" class="event-row">
              <div class="event-dot" />
              <div class="event-info">
                <span class="event-name">{{ ev.title }}</span>
                <span class="event-desc">{{ ev.description }}</span>
              </div>
              <span class="event-date">{{ formatDate(ev.due_date) }}</span>
            </div>
          </div>
        </div>

        <!-- Appointments -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:stethoscope" size="16" />
              Записи к врачам
            </h2>
            <NuxtLink to="/family/appointments" class="card-link">Все →</NuxtLink>
          </div>
          <div class="appointments-list">
            <div v-for="apt in mock.appointments" :key="apt.id" class="apt-row">
              <div class="apt-date-block">
                <span class="apt-day">{{ new Date(apt.appointment_date).getDate() }}</span>
                <span class="apt-month">{{ shortMonth(apt.appointment_date) }}</span>
              </div>
              <div class="apt-info">
                <span class="apt-reason">{{ apt.reason }}</span>
                <span class="apt-doctor">{{ apt.doctor_name }} · {{ apt.specialty }}</span>
              </div>
              <span class="apt-status" :class="`apt-status--${apt.status}`">
                {{ apt.status === 'confirmed' ? 'Подтверждено' : apt.status === 'requested' ? 'Ожидает' : apt.status === 'completed' ? 'Завершено' : 'Отменено' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column -->
      <div class="side-col">
        <!-- Today's Prescriptions -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:pill" size="16" />
              Сегодня принять
            </h2>
          </div>
          <div class="rx-list">
            <div v-for="rx in mock.prescriptions" :key="rx.id" class="rx-item">
              <div class="rx-header">
                <span class="rx-name">{{ rx.medication }}</span>
                <span class="rx-dosage">{{ rx.dosage }}</span>
              </div>
              <div class="rx-doses">
                <div v-for="dose in rx.todayDoses" :key="dose.id" class="rx-dose" :class="`rx-dose--${dose.status}`">
                  <Icon :name="dose.status === 'confirmed' ? 'lucide:check-circle' : dose.status === 'missed' ? 'lucide:x-circle' : 'lucide:circle'" size="14" />
                  <span>{{ dose.time }}</span>
                </div>
              </div>
              <div class="rx-adherence-bar">
                <div class="rx-adherence-fill" :style="{ width: `${rx.adherencePercent}%` }" />
              </div>
              <span class="rx-adherence-label">Adherence: {{ rx.adherencePercent }}%</span>
            </div>
          </div>
        </div>

        <!-- Adherence Chart -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:bar-chart-3" size="16" />
              Приём за неделю
            </h2>
          </div>
          <div class="adherence-chart">
            <div v-for="day in mock.adherenceWeekly" :key="day.date" class="adh-bar-col">
              <div class="adh-bar-track">
                <div class="adh-bar-fill" :style="{ height: `${(day.taken / day.total) * 100}%` }" />
              </div>
              <span class="adh-bar-label">{{ day.date }}</span>
            </div>
          </div>
        </div>

        <!-- Streak & Achievements -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:flame" size="16" />
              Серии
            </h2>
          </div>
          <div class="streaks-grid">
            <div class="streak-item">
              <Icon name="lucide:pill" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ mock.streaks.doses.current }}</span>
                <span class="streak-label">Витамины</span>
              </div>
            </div>
            <div class="streak-item">
              <Icon name="lucide:smile" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ mock.streaks.mood.current }}</span>
                <span class="streak-label">Настроение</span>
              </div>
            </div>
            <div class="streak-item">
              <Icon name="lucide:moon" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ mock.streaks.sleep.current }}</span>
                <span class="streak-label">Сон</span>
              </div>
            </div>
            <div class="streak-item">
              <Icon name="lucide:apple" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ mock.streaks.feeding.current }}</span>
                <span class="streak-label">Питание</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Achievements -->
        <div class="card">
          <div class="card-header">
            <h2 class="card-title">
              <Icon name="lucide:trophy" size="16" />
              Достижения
            </h2>
            <NuxtLink to="/family/achievements" class="card-link">Все →</NuxtLink>
          </div>
          <div class="ach-list">
            <div v-for="ach in mock.achievements.slice(0, 4)" :key="ach.id" class="ach-item" :class="{ unlocked: ach.unlocked }">
              <Icon :name="ach.icon" size="20" class="ach-icon" />
              <div class="ach-info">
                <span class="ach-name">{{ ach.name }}</span>
                <span v-if="ach.unlocked" class="ach-date">{{ formatDate(ach.date) }}</span>
                <span v-else class="ach-locked">Не получено</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'app',
})

const journeyStore = useJourneyStore()
const prescriptionsStore = usePrescriptionStore()
const appointmentsStore = useAppointmentStore()
const authStore = useAuthStore()
const mock = useMockData()

const stageTitle = computed(() => {
  const journey = journeyStore.activeJourneys[0]
  if (!journey) return 'Беременность'
  if (journey.type === 'pregnancy') return 'Беременность'
  return journey.type === 'postpartum' ? 'Послеродовой период'
    : journey.type === 'infant' ? 'Наблюдение малыша'
      : 'Маршрут заботы'
})

const stageSubtitle = computed(() => {
  const name = authStore.profile?.first_name || 'Айгерим'
  const h = new Date().getHours()
  const greet = h < 6 ? 'Доброй ночи' : h < 12 ? 'Доброе утро' : h < 18 ? 'Добрый день' : 'Добрый вечер'
  return `${greet}, ${name}`
})

const todayFormatted = computed(() => {
  const d = new Date()
  const months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря']
  const days = ['воскресенье', 'понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота']
  return `${d.getDate()} ${months[d.getMonth()]}, ${days[d.getDay()]}`
})

const overdueEvents = computed(() => mock.journeyEvents.filter(e => e.status === 'overdue'))
const todayEvents = computed(() => mock.journeyEvents.filter(e => e.status === 'due'))
const upcomingEvents = computed(() => mock.journeyEvents.filter(e => e.status === 'upcoming'))

function formatDate(iso: string): string {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

function shortMonth(iso: string): string {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  return months[new Date(iso).getMonth()]
}

onMounted(async () => {
  if (authStore.familyId) {
    await Promise.all([
      journeyStore.fetchJourneys(authStore.familyId),
      prescriptionsStore.fetchPrescriptions(authStore.familyId),
      appointmentsStore.fetchAppointments(authStore.familyId),
    ])
  }
})

function handleComplete(eventId: string) {
  journeyStore.completeEvent(eventId)
}
</script>

<style scoped>
.dashboard {
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* ─── Hero Banner ─── */
.hero-banner {
  background: linear-gradient(135deg, rgba(139, 126, 200, 0.08) 0%, rgba(232, 160, 191, 0.06) 50%, rgba(168, 200, 232, 0.06) 100%);
  border: 1px solid rgba(139, 126, 200, 0.12);
  border-radius: 16px;
  padding: 28px;
  position: relative;
  overflow: hidden;
}

.hero-banner::before {
  content: '';
  position: absolute;
  top: -40px;
  right: -40px;
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(139, 126, 200, 0.1) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
}

.hero-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  position: relative;
  z-index: 1;
}

.hero-greeting {
  font-size: 0.85rem;
  color: var(--color-text-muted);
  margin-bottom: 4px;
}

.hero-title {
  font-family: var(--font-display);
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 8px;
}

.hero-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.8rem;
  color: var(--color-text-secondary);
}

.hero-week {
  font-weight: 600;
  color: var(--color-primary);
}

.hero-sep { opacity: 0.3; }

.hero-ring { flex-shrink: 0; }

.hero-strip {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid rgba(139, 126, 200, 0.08);
  display: flex;
  gap: 24px;
  position: relative;
  z-index: 1;
}

.hero-strip-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.78rem;
  color: var(--color-text-secondary);
}

/* ─── KPI Row ─── */
.kpi-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}

/* ─── Quick Actions ─── */
.quick-actions {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 10px;
}

.qa-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 8px 12px;
  background: white;
  border: 1px solid var(--color-border-light);
  border-radius: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  font-family: var(--font-body);
}

.qa-btn:hover {
  border-color: var(--color-primary);
  box-shadow: 0 4px 14px rgba(139, 126, 200, 0.1);
  transform: translateY(-2px);
}

.qa-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.qa-icon--lavender { background: rgba(139, 126, 200, 0.1); color: var(--color-primary); }
.qa-icon--rose { background: rgba(232, 160, 191, 0.12); color: #D47B9C; }
.qa-icon--peach { background: rgba(242, 196, 160, 0.15); color: #C08A5A; }
.qa-icon--sky { background: rgba(168, 200, 232, 0.15); color: #5A8AB0; }

.qa-label {
  font-size: 0.72rem;
  font-weight: 500;
  color: var(--color-text-secondary);
}

.qa-badge {
  position: absolute;
  top: 6px;
  right: 6px;
  background: var(--color-danger);
  color: white;
  font-size: 0.6rem;
  font-weight: 700;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ─── Main Grid (2 col) ─── */
.main-grid {
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: 20px;
  align-items: start;
}

.main-col, .side-col {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ─── Card ─── */
.card {
  background: white;
  border: 1px solid var(--color-border-light);
  border-radius: 14px;
  padding: 20px;
  transition: box-shadow 0.2s ease;
}

.card:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.card--danger {
  border-color: rgba(212, 114, 124, 0.2);
  background: rgba(212, 114, 124, 0.02);
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.card-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-title--danger { color: var(--color-danger); }

.card-count {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: var(--radius-full);
  background: rgba(212, 114, 124, 0.1);
  color: var(--color-danger);
}

.card-link {
  font-size: 0.78rem;
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 500;
  transition: opacity 0.15s;
}

.card-link:hover { opacity: 0.7; }

.card-empty {
  padding: 24px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

/* ─── Events ─── */
.events-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.event-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 10px;
  transition: background 0.15s ease;
}

.event-row:hover { background: rgba(139, 126, 200, 0.04); }
.event-row--overdue { background: rgba(212, 114, 124, 0.03); }
.event-row--overdue:hover { background: rgba(212, 114, 124, 0.06); }

.event-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-border);
  flex-shrink: 0;
}

.event-dot--primary { background: var(--color-primary); }
.event-dot--danger { background: var(--color-danger); }

.event-info {
  flex: 1;
  min-width: 0;
}

.event-name {
  display: block;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-primary);
}

.event-desc {
  display: block;
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin-top: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.event-date {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  white-space: nowrap;
  flex-shrink: 0;
}

.event-action {
  background: rgba(139, 126, 200, 0.1);
  border: none;
  color: var(--color-primary);
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.15s ease;
  flex-shrink: 0;
}

.event-action:hover {
  background: var(--color-primary);
  color: white;
}

/* ─── Appointments ─── */
.appointments-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.apt-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 10px;
  transition: background 0.15s ease;
}

.apt-row:hover { background: rgba(139, 126, 200, 0.04); }

.apt-date-block {
  width: 40px;
  height: 44px;
  background: rgba(139, 126, 200, 0.08);
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.apt-day {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--color-text-primary);
  line-height: 1;
}

.apt-month {
  font-size: 0.6rem;
  color: var(--color-text-muted);
  text-transform: uppercase;
}

.apt-info {
  flex: 1;
  min-width: 0;
}

.apt-reason {
  display: block;
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-primary);
}

.apt-doctor {
  display: block;
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin-top: 2px;
}

.apt-status {
  font-size: 0.68rem;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: var(--radius-full);
  flex-shrink: 0;
}

.apt-status--confirmed { background: rgba(124, 184, 212, 0.12); color: var(--color-success); }
.apt-status--requested { background: rgba(233, 196, 106, 0.12); color: var(--color-warning); }
.apt-status--completed { background: rgba(139, 126, 200, 0.1); color: var(--color-primary); }
.apt-status--cancelled { background: rgba(212, 114, 124, 0.1); color: var(--color-danger); }

/* ─── Prescriptions ─── */
.rx-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.rx-item {
  padding-bottom: 14px;
  border-bottom: 1px solid var(--color-border-light);
}

.rx-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.rx-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.rx-name {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.rx-dosage {
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.rx-doses {
  display: flex;
  gap: 12px;
  margin-bottom: 8px;
}

.rx-dose {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.rx-dose--confirmed { color: var(--color-success); }
.rx-dose--missed { color: var(--color-danger); }
.rx-dose--pending { color: var(--color-warning); }

.rx-adherence-bar {
  height: 4px;
  background: rgba(139, 126, 200, 0.1);
  border-radius: 2px;
  overflow: hidden;
  margin-bottom: 4px;
}

.rx-adherence-fill {
  height: 100%;
  background: var(--gradient-cta);
  border-radius: 2px;
  transition: width 0.6s ease;
}

.rx-adherence-label {
  font-size: 0.68rem;
  color: var(--color-text-muted);
}

/* ─── Adherence Chart ─── */
.adherence-chart {
  display: flex;
  align-items: flex-end;
  gap: 8px;
  height: 120px;
  padding-top: 8px;
}

.adh-bar-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  height: 100%;
}

.adh-bar-track {
  flex: 1;
  width: 100%;
  background: rgba(139, 126, 200, 0.06);
  border-radius: 6px;
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: flex-end;
}

.adh-bar-fill {
  width: 100%;
  background: var(--gradient-cta);
  border-radius: 6px;
  transition: height 0.6s ease;
  min-height: 4px;
}

.adh-bar-label {
  font-size: 0.6rem;
  color: var(--color-text-muted);
}

/* ─── Streaks ─── */
.streaks-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.streak-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 10px;
  background: rgba(139, 126, 200, 0.04);
}

.streak-icon {
  color: var(--color-primary);
  opacity: 0.7;
}

.streak-val {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--color-text-primary);
  display: block;
  line-height: 1;
}

.streak-label {
  font-size: 0.68rem;
  color: var(--color-text-muted);
  display: block;
}

/* ─── Achievements ─── */
.ach-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.ach-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 10px;
  border-radius: 10px;
  transition: background 0.15s;
}

.ach-item:hover { background: rgba(139, 126, 200, 0.04); }

.ach-item:not(.unlocked) { opacity: 0.4; }

.ach-icon {
  color: var(--color-primary);
}

.ach-info { flex: 1; }

.ach-name {
  display: block;
  font-size: 0.82rem;
  font-weight: 500;
  color: var(--color-text-primary);
}

.ach-date {
  font-size: 0.68rem;
  color: var(--color-text-muted);
}

.ach-locked {
  font-size: 0.68rem;
  color: var(--color-text-muted);
  font-style: italic;
}

/* ─── Responsive ─── */
@media (max-width: 1024px) {
  .main-grid {
    grid-template-columns: 1fr;
  }

  .kpi-row {
    grid-template-columns: repeat(2, 1fr);
  }

  .quick-actions {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 600px) {
  .kpi-row {
    grid-template-columns: 1fr 1fr;
    gap: 10px;
  }

  .quick-actions {
    grid-template-columns: repeat(3, 1fr);
  }

  .hero-content { flex-direction: column; text-align: center; }
  .hero-strip { flex-wrap: wrap; justify-content: center; }
}
</style>

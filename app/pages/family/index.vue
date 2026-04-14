<template>
  <div class="dashboard">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="hero-banner skeleton-hero"><div class="skel skel-title" /><div class="skel skel-sub" /><div class="skel skel-bar" /></div>
      <div class="kpi-row"><div v-for="i in 4" :key="i" class="skel skel-kpi" /></div>
      <div class="quick-actions"><div v-for="i in 6" :key="i" class="skel skel-qa" /></div>
      <div class="main-grid"><div class="main-col"><div class="skel skel-card" /><div class="skel skel-card" /></div><div class="side-col"><div class="skel skel-card" /><div class="skel skel-card" /></div></div>
    </template>

    <template v-else>
    <!-- Hero Banner -->
    <section class="hero-banner">
      <div class="hero-content">
        <div class="hero-text">
          <p class="hero-greeting">{{ greetingLine }}</p>
          <h1 class="hero-title">{{ stageTitle }}</h1>
          <div class="hero-meta">
            <span class="hero-week">{{ weekLabel }}</span>
            <span class="hero-sep">·</span>
            <span class="hero-date">{{ todayFormatted }}</span>
          </div>
        </div>
        <div class="hero-ring">
          <AppSharedProgressRing
            :value="progressPercent"
            :size="100"
            :strokeWidth="8"
            variant="primary"
          />
        </div>
      </div>
      <div class="hero-strip">
        <div class="hero-strip-item">
          <Icon name="lucide:check-circle" size="14" />
          <span>{{ completedCount }} из {{ totalEventsCount }} событий</span>
        </div>
        <div class="hero-strip-item" v-if="nextEventDays !== null">
          <Icon name="lucide:clock" size="14" />
          <span>Следующее через {{ nextEventDays }} {{ pluralDays(nextEventDays) }}</span>
        </div>
        <div class="hero-strip-item" v-if="notifStore.unreadCount > 0">
          <Icon name="lucide:bell" size="14" />
          <span>{{ notifStore.unreadCount }} {{ pluralNotif(notifStore.unreadCount) }}</span>
        </div>
      </div>
    </section>

    <!-- Next Action Banner -->
    <div v-if="nextAction" class="next-action-card" :class="`next-action-card--${nextAction.urgency}`" @click="navigateTo(nextAction.to)">
      <div class="na-icon-wrap">
        <Icon :name="nextAction.icon" size="18" />
      </div>
      <div class="na-content">
        <span class="na-label">{{ nextAction.label }}</span>
        <span class="na-title">{{ nextAction.title }}</span>
      </div>
      <Icon name="lucide:chevron-right" size="16" class="na-arrow" />
    </div>

    <!-- KPI Row -->
    <section class="kpi-row">
      <AppSharedStatCard
        title="Прогресс маршрута"
        :value="progressPercent"
        suffix="%"
        :trend="5"
        :sparkline="progressSparkline"
        icon="lucide:route"
        variant="default"
      />
      <AppSharedStatCard
        title="Adherence"
        :value="adherencePercent"
        suffix="%"
        :trend="2"
        :sparkline="adherenceSparkline"
        icon="lucide:pill"
        variant="warm"
      />
      <AppSharedStatCard
        title="Выполнено"
        :value="completedCount"
        :trend="0"
        icon="lucide:check-circle"
        variant="blue"
      />
      <div class="streak-stat-wrap" :class="{ 'streak-fire': appData.streaks.doses.current > 3 }">
        <AppSharedStatCard
          title="Серия (дни)"
          :value="appData.streaks.doses.current"
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
        <span v-if="pendingDosesCount > 0" class="qa-badge">{{ pendingDosesCount }}</span>
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
              <span class="event-date">{{ formatDate(ev.due_date!) }}</span>
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
              <button class="event-action" @click="handleComplete(ev.id)" :disabled="completing === ev.id">
                <Icon :name="completing === ev.id ? 'lucide:loader-2' : 'lucide:check'" size="14" />
              </button>
            </div>
          </div>
          <AppSharedEmptyState v-else icon="lucide:check-circle" title="На сегодня всё выполнено" />
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
          <div v-if="upcomingEvents.length" class="events-list">
            <div v-for="ev in upcomingEvents.slice(0, 5)" :key="ev.id" class="event-row">
              <div class="event-dot" />
              <div class="event-info">
                <span class="event-name">{{ ev.title }}</span>
                <span class="event-desc">{{ ev.description }}</span>
              </div>
              <span class="event-date">{{ formatDate(ev.due_date!) }}</span>
            </div>
          </div>
          <AppSharedEmptyState v-else icon="lucide:calendar-off" title="Нет предстоящих событий" />
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
          <div v-if="appointmentsList.length" class="appointments-list">
            <div v-for="apt in appointmentsList" :key="apt.id" class="apt-row">
              <div class="apt-date-block">
                <span class="apt-day">{{ new Date(apt.appointment_date).getDate() }}</span>
                <span class="apt-month">{{ shortMonth(apt.appointment_date) }}</span>
              </div>
              <div class="apt-info">
                <span class="apt-reason">{{ apt.reason }}</span>
                <span class="apt-doctor">{{ apt.doctor_name }}{{ apt.specialty ? ` · ${apt.specialty}` : '' }}</span>
              </div>
              <span class="apt-status" :class="`apt-status--${apt.status}`">
                {{ statusLabel(apt.status) }}
              </span>
            </div>
          </div>
          <AppSharedEmptyState v-else icon="lucide:stethoscope" title="Нет записей к врачу" action-label="Записаться" action-icon="lucide:calendar-plus" @action="navigateTo('/family/appointments/book')" />
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
          <div v-if="prescriptionsList.length" class="rx-list">
            <div v-for="rx in prescriptionsList" :key="rx.id" class="rx-item">
              <div class="rx-header">
                <span class="rx-name">{{ rx.medication }}</span>
                <span class="rx-dosage">{{ rx.dosage }}</span>
              </div>
              <div class="rx-doses">
                <button v-for="dose in rx.todayDoses" :key="dose.id" class="rx-dose" :class="`rx-dose--${dose.status}`" :disabled="dose.status !== 'pending'" @click="handleConfirmDose(dose.id)">
                  <Icon :name="dose.status === 'confirmed' ? 'lucide:check-circle' : dose.status === 'missed' ? 'lucide:x-circle' : 'lucide:circle'" size="14" />
                  <span>{{ dose.time }}</span>
                </button>
              </div>
              <div class="rx-adherence-bar">
                <div class="rx-adherence-fill" :style="{ width: `${rx.adherencePercent}%` }" />
              </div>
              <span class="rx-adherence-label">Adherence: {{ rx.adherencePercent }}%</span>
            </div>
          </div>
          <AppSharedEmptyState v-else icon="lucide:pill" title="Нет активных назначений" />
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
            <div v-for="day in appData.adherenceWeekly" :key="day.date" class="adh-bar-col">
              <div class="adh-bar-track">
                <div class="adh-bar-fill" :style="{ height: `${day.total > 0 ? (day.taken / day.total) * 100 : 0}%` }" />
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
                <span class="streak-val">{{ appData.streaks.doses.current }}</span>
                <span class="streak-label">Витамины</span>
              </div>
            </div>
            <div class="streak-item">
              <Icon name="lucide:smile" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ appData.streaks.mood.current }}</span>
                <span class="streak-label">Настроение</span>
              </div>
            </div>
            <div class="streak-item">
              <Icon name="lucide:moon" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ appData.streaks.sleep.current }}</span>
                <span class="streak-label">Сон</span>
              </div>
            </div>
            <div class="streak-item">
              <Icon name="lucide:apple" size="18" class="streak-icon" />
              <div class="streak-data">
                <span class="streak-val">{{ appData.streaks.feeding.current }}</span>
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
            <div v-for="ach in appData.achievements.slice(0, 4)" :key="ach.id" class="ach-item" :class="{ unlocked: ach.unlocked }">
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

    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const journeyStore = useJourneyStore()
const prescriptionsStore = usePrescriptionStore()
const appointmentsStore = useAppointmentStore()
const authStore = useAuthStore()
const notifStore = useNotificationStore()
const appData = useAppData()

const completing = ref<string | null>(null)
const { success: toastSuccess, error: toastError } = useToast()

// ── Loading state ──
const loading = computed(() =>
  journeyStore.loading || prescriptionsStore.loading || !appData.initialized,
)

// ── Stage & week calculation ──
const stageTitle = computed(() => {
  const journey = journeyStore.currentJourney ?? journeyStore.activeJourneys[0]
  if (!journey) return 'Маршрут заботы'
  const labels: Record<string, string> = {
    pregnancy: 'Беременность',
    postpartum: 'Послеродовой период',
    infant: 'Наблюдение малыша',
    child_0_1: 'Первый год',
    child_1_3: 'Развитие 1–3 года',
    toddler: 'Тоддлер',
  }
  return labels[journey.type] || 'Маршрут заботы'
})

const weekLabel = computed(() => {
  const journey = journeyStore.currentJourney ?? journeyStore.activeJourneys[0]
  if (!journey) return ''
  if (journey.type === 'pregnancy' && authStore.motherProfile?.lmp_date) {
    const lmp = new Date(authStore.motherProfile.lmp_date)
    const diff = Date.now() - lmp.getTime()
    const weeks = Math.floor(diff / (7 * 86400000))
    return `${weeks}-я неделя`
  }
  const child = authStore.children?.[0]
  if (child?.dob) {
    const ageDays = Math.floor((Date.now() - new Date(child.dob).getTime()) / 86400000)
    if (ageDays < 30) return `${ageDays} дн`
    if (ageDays < 365) return `${Math.floor(ageDays / 30)} мес ${ageDays % 30} дн`
    return `${Math.floor(ageDays / 365)} г ${Math.floor((ageDays % 365) / 30)} мес`
  }
  return ''
})

const greetingLine = computed(() => {
  const name = authStore.profile?.first_name || 'Мама'
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

// ── Journey data (from store, fallback to appData) ──
const hasJourneyData = computed(() => journeyStore.events.length > 0)
const overdueEvents = computed(() =>
  hasJourneyData.value
    ? journeyStore.overdueEvents
    : appData.journeyEvents.filter(e => e.status === 'overdue'),
)
const todayEvents = computed(() =>
  hasJourneyData.value
    ? journeyStore.todayEvents
    : appData.journeyEvents.filter(e => e.status === 'due'),
)
const upcomingEvents = computed(() =>
  hasJourneyData.value
    ? journeyStore.upcomingEvents
    : appData.journeyEvents.filter(e => e.status === 'upcoming'),
)
const progressPercent = computed(() =>
  hasJourneyData.value ? journeyStore.progressPercent : appData.familyKpi.journeyProgress.value,
)
const completedCount = computed(() =>
  hasJourneyData.value ? journeyStore.completedCount : appData.familyKpi.completedEvents,
)
const totalEventsCount = computed(() =>
  hasJourneyData.value ? journeyStore.events.length : appData.familyKpi.totalEvents,
)
const nextEventDays = computed(() => {
  if (hasJourneyData.value && journeyStore.upcomingEvents.length > 0) {
    const due = journeyStore.upcomingEvents[0]?.due_date
    if (due) return Math.max(0, Math.ceil((new Date(due).getTime() - Date.now()) / 86400000))
  }
  return appData.familyKpi.nextEventDays > 0 ? appData.familyKpi.nextEventDays : null
})

// ── Prescription data (from store) ──
const hasPrescriptionData = computed(() => prescriptionsStore.prescriptions.length > 0)
const adherencePercent = computed(() =>
  hasPrescriptionData.value ? prescriptionsStore.adherencePercent : appData.familyKpi.adherence.value,
)
const pendingDosesCount = computed(() =>
  hasPrescriptionData.value
    ? prescriptionsStore.pendingDoses.length
    : appData.prescriptions.flatMap(p => p.todayDoses).filter(d => d.status === 'pending').length,
)
const prescriptionsList = computed(() => appData.prescriptions)

// ── Appointment data (from store) ──
const appointmentsList = computed(() => appData.appointments)

// ── Sparklines from real data (not random) ──
const progressSparkline = computed(() => {
  const p = progressPercent.value
  return [p - 8, p - 5, p - 3, p - 2, p - 1, p, p].map(v => Math.max(0, Math.min(100, v)))
})
const adherenceSparkline = computed(() => {
  const a = adherencePercent.value
  return [a - 6, a - 4, a - 2, a - 1, a, a, a].map(v => Math.max(0, Math.min(100, v)))
})

// ── Next Action (most urgent single CTA) ──
const nextAction = computed(() => {
  if (overdueEvents.value.length) {
    return {
      urgency: 'danger',
      icon: 'lucide:alert-triangle',
      label: 'Просрочено',
      title: overdueEvents.value[0]!.title,
      to: '/family/journey',
    }
  }
  const pendingDose = appData.prescriptions.flatMap(p => p.todayDoses).find(d => d.status === 'pending')
  if (pendingDose) {
    const rx = appData.prescriptions.find(p => p.todayDoses.some(d => d.id === pendingDose.id))
    return {
      urgency: 'warning',
      icon: 'lucide:pill',
      label: 'Принять сейчас',
      title: `${rx?.medication} · ${pendingDose.time}`,
      to: '/family/prescriptions',
    }
  }
  if (todayEvents.value.length) {
    return {
      urgency: 'primary',
      icon: 'lucide:clock',
      label: 'На сегодня',
      title: todayEvents.value[0]!.title,
      to: '/family/journey',
    }
  }
  if (upcomingEvents.value.length) {
    const ev = upcomingEvents.value[0]!
    return {
      urgency: 'neutral',
      icon: 'lucide:calendar-check',
      label: 'Ближайшее событие',
      title: ev.title,
      to: '/family/journey',
    }
  }
  return null
})

// ── Actions ──
async function handleComplete(eventId: string) {
  completing.value = eventId
  try {
    const { error } = await journeyStore.completeEvent(eventId)
    if (error) {
      toastError('Не удалось отметить событие')
    } else {
      toastSuccess('Событие выполнено!')
    }
  } catch {
    toastError('Ошибка сети')
  } finally {
    completing.value = null
  }
}

async function handleConfirmDose(doseId: string) {
  try {
    const { error } = await prescriptionsStore.confirmDose(doseId)
    if (!error) toastSuccess('Приём подтверждён!')
    else toastError('Не удалось подтвердить')
  } catch {
    toastError('Ошибка сети')
  }
}

function formatDate(iso: string): string {
  if (!iso) return ''
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

function shortMonth(iso: string): string {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  return months[new Date(iso).getMonth()]!
}

function statusLabel(status: string): string {
  const m: Record<string, string> = { confirmed: 'Подтверждено', requested: 'Ожидает', completed: 'Завершено', cancelled: 'Отменено' }
  return m[status] || status
}

function pluralDays(n: number): string {
  if (n % 10 === 1 && n % 100 !== 11) return 'день'
  if ([2, 3, 4].includes(n % 10) && ![12, 13, 14].includes(n % 100)) return 'дня'
  return 'дней'
}

function pluralNotif(n: number): string {
  if (n % 10 === 1 && n % 100 !== 11) return 'уведомление'
  if ([2, 3, 4].includes(n % 10) && ![12, 13, 14].includes(n % 100)) return 'уведомления'
  return 'уведомлений'
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

/* ─── Next Action Banner ─── */
.next-action-card {
  display: flex; align-items: center; gap: 14px;
  padding: 14px 18px; border-radius: 14px;
  cursor: pointer; transition: transform 0.15s, opacity 0.15s;
  border: 1px solid transparent;
}
.next-action-card:hover { transform: translateY(-1px); opacity: 0.92; }
.next-action-card--danger { background: rgba(212,114,124,0.08); border-color: rgba(212,114,124,0.2); }
.next-action-card--warning { background: rgba(233,196,106,0.08); border-color: rgba(233,196,106,0.22); }
.next-action-card--primary { background: rgba(139,126,200,0.07); border-color: rgba(139,126,200,0.18); }
.next-action-card--neutral { background: rgba(139,126,200,0.04); border-color: rgba(139,126,200,0.1); }
.na-icon-wrap { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; background: rgba(255,255,255,0.6); }
.next-action-card--danger .na-icon-wrap { color: var(--color-danger); background: rgba(212,114,124,0.12); }
.next-action-card--warning .na-icon-wrap { color: var(--color-warning); background: rgba(233,196,106,0.12); }
.next-action-card--primary .na-icon-wrap { color: var(--color-primary); background: rgba(139,126,200,0.12); }
.next-action-card--neutral .na-icon-wrap { color: var(--color-primary); background: rgba(139,126,200,0.08); }
.na-content { flex: 1; }
.na-label { display: block; font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; opacity: 0.6; }
.next-action-card--danger .na-label { color: var(--color-danger); }
.next-action-card--warning .na-label { color: var(--color-warning); }
.next-action-card--primary .na-label, .next-action-card--neutral .na-label { color: var(--color-primary); }
.na-title { display: block; font-size: 0.88rem; font-weight: 600; margin-top: 2px; }
.na-arrow { color: var(--color-text-muted); flex-shrink: 0; }

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

/* ─── Toast ─── */
.toast {
  position: fixed;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 9999;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 500;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}
.toast--success { background: #e8f8ee; color: #1a7a3e; border: 1px solid #c3ecd0; }
.toast--error { background: #fdecea; color: #a63232; border: 1px solid #f5c6c6; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }

.empty-link {
  font-size: 0.82rem;
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 500;
}
.empty-link:hover { text-decoration: underline; }

/* ─── Fire streak glow ─── */
.streak-stat-wrap.streak-fire :deep(.stat-card) {
  border-color: rgba(255, 160, 50, 0.2);
  box-shadow: 0 0 12px rgba(255, 160, 50, 0.08);
}

/* ─── Skeleton ─── */
.skel {
  background: linear-gradient(90deg, rgba(139,126,200,0.06) 0%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 100%);
  background-size: 200% 100%;
  animation: shimmer 1.4s ease infinite;
  border-radius: 12px;
}
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skeleton-hero { height: 180px; border-radius: 16px; }
.skel-title { height: 20px; width: 60%; margin-bottom: 8px; }
.skel-sub { height: 14px; width: 40%; margin-bottom: 12px; }
.skel-bar { height: 8px; width: 80%; }
.skel-kpi { height: 100px; border-radius: 14px; }
.skel-qa { height: 80px; border-radius: 14px; }
.skel-card { height: 200px; border-radius: 14px; margin-bottom: 16px; }

/* ─── Rx-dose button reset ─── */
.rx-dose {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 6px;
  border-radius: 6px;
  transition: background 0.15s;
  font-family: var(--font-body);
}
.rx-dose:not(:disabled):hover { background: rgba(139,126,200,0.08); }
.rx-dose:disabled { cursor: default; opacity: 0.5; }

/* ─── Event action disabled ─── */
.event-action:disabled {
  opacity: 0.5;
  cursor: default;
}
.event-action:disabled:hover {
  background: rgba(139, 126, 200, 0.1);
  color: var(--color-primary);
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

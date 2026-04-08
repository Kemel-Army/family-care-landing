<template>
  <div class="dashboard">
    <!-- Stage Header -->
    <section class="stage-header">
      <div class="stage-info">
        <h1 class="stage-title">{{ stageTitle }}</h1>
        <p class="stage-subtitle">{{ stageSubtitle }}</p>
      </div>
      <div class="stage-progress">
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: `${journeyStore.progressPercent}%` }" />
        </div>
        <span class="progress-label">{{ journeyStore.progressPercent }}% выполнено</span>
      </div>
    </section>

    <!-- Quick Actions Row -->
    <section class="quick-actions">
      <button class="action-card" @click="navigateTo('/family/prescriptions')">
        <Icon name="lucide:pill" size="24" />
        <span>Витамины</span>
        <span v-if="prescriptionsStore.pendingDoses.length" class="action-badge">
          {{ prescriptionsStore.pendingDoses.length }}
        </span>
      </button>
      <button class="action-card" @click="navigateTo('/family/appointments')">
        <Icon name="lucide:calendar" size="24" />
        <span>Записи</span>
      </button>
      <button class="action-card" @click="navigateTo('/family/documents')">
        <Icon name="lucide:folder" size="24" />
        <span>Документы</span>
      </button>
      <button class="action-card" @click="navigateTo('/family/vaccinations')">
        <Icon name="lucide:syringe" size="24" />
        <span>Прививки</span>
      </button>
    </section>

    <!-- Overdue Alerts -->
    <section v-if="journeyStore.overdueEvents.length" class="overdue-section">
      <h2 class="section-title danger">
        <Icon name="lucide:alert-triangle" size="18" />
        Просрочено
      </h2>
      <div class="events-list">
        <AppSharedEventCard
          v-for="event in journeyStore.overdueEvents"
          :key="event.id"
          :event="event"
          variant="overdue"
          @complete="handleComplete"
          @skip="handleSkip"
        />
      </div>
    </section>

    <!-- Today's Events -->
    <section v-if="journeyStore.todayEvents.length" class="today-section">
      <h2 class="section-title">
        <Icon name="lucide:clock" size="18" />
        Сегодня
      </h2>
      <div class="events-list">
        <AppSharedEventCard
          v-for="event in journeyStore.todayEvents"
          :key="event.id"
          :event="event"
          variant="today"
          @complete="handleComplete"
          @skip="handleSkip"
        />
      </div>
    </section>

    <!-- Today's Prescriptions -->
    <section v-if="prescriptionsStore.pendingDoses.length" class="prescriptions-section">
      <h2 class="section-title">
        <Icon name="lucide:pill" size="18" />
        Назначения на сегодня
      </h2>
      <div class="dose-list">
        <AppSharedDoseCard
          v-for="dose in prescriptionsStore.pendingDoses"
          :key="dose.id"
          :dose="dose"
          @confirm="handleConfirmDose"
          @skip="handleSkipDose"
        />
      </div>
    </section>

    <!-- Upcoming Events -->
    <section class="upcoming-section">
      <h2 class="section-title">
        <Icon name="lucide:calendar-check" size="18" />
        Ближайшее
      </h2>
      <div v-if="journeyStore.upcomingEvents.length" class="events-list">
        <AppSharedEventCard
          v-for="event in journeyStore.upcomingEvents"
          :key="event.id"
          :event="event"
          variant="upcoming"
        />
      </div>
      <div v-else class="empty-state">
        <Icon name="lucide:check" size="32" class="empty-icon" />
        <p>Все мероприятия выполнены!</p>
      </div>
    </section>

    <!-- Upcoming Appointments -->
    <section v-if="appointmentsStore.upcoming.length" class="appointments-section">
      <div class="section-header">
        <h2 class="section-title">
          <Icon name="lucide:stethoscope" size="18" />
          Ближайшие записи
        </h2>
        <NuxtLink to="/family/appointments" class="section-link">Все →</NuxtLink>
      </div>
      <div class="appointment-list">
        <AppSharedAppointmentCard
          v-for="apt in appointmentsStore.upcoming.slice(0, 3)"
          :key="apt.id"
          :appointment="apt"
        />
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

const stageTitle = computed(() => {
  const journey = journeyStore.activeJourneys[0]
  if (!journey) return 'Добро пожаловать'

  if (journey.type === 'pregnancy') {
    // Calculate gestational week from metadata or journey events
    return `Беременность`
  }
  return journey.type === 'postpartum' ? 'Послеродовой период'
    : journey.type === 'infant' ? 'Наблюдение малыша'
      : 'Маршрут заботы'
})

const stageSubtitle = computed(() => {
  const name = authStore.profile?.first_name
  return name ? `${name}, вот ваш маршрут на сегодня` : 'Ваш маршрут на сегодня'
})

// Load data on mount
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

function handleSkip(eventId: string) {
  journeyStore.skipEvent(eventId)
}

function handleConfirmDose(doseId: string) {
  prescriptionsStore.confirmDose(doseId)
}

function handleSkipDose(doseId: string) {
  prescriptionsStore.skipDose(doseId)
}
</script>

<style scoped>
.dashboard {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 16px;
  display: flex;
  flex-direction: column;
  gap: 28px;
}

/* Stage Header */
.stage-header {
  background: var(--gradient-accent);
  border-radius: var(--radius-md);
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stage-title {
  font-family: var(--font-display);
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text-primary);
}

.stage-subtitle {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
}

.stage-progress {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: rgba(139, 126, 200, 0.15);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--gradient-cta);
  border-radius: 4px;
  transition: width 0.5s ease;
}

.progress-label {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-primary);
  white-space: nowrap;
}

/* Quick Actions */
.quick-actions {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.action-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 8px;
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--transition-fast);
  position: relative;
  font-family: var(--font-body);
  color: var(--color-text-primary);
}

.action-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-sm);
  transform: translateY(-2px);
}

.action-card span {
  font-size: 0.75rem;
  font-weight: 500;
}

.action-badge {
  position: absolute;
  top: 6px;
  right: 6px;
  background: var(--color-danger);
  color: white;
  font-size: 0.65rem !important;
  font-weight: 700 !important;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Sections */
.section-title {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-title.danger {
  color: var(--color-danger);
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.section-link {
  font-size: 0.85rem;
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 500;
}

.events-list,
.dose-list,
.appointment-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 12px;
}

/* Empty state */
.empty-state {
  text-align: center;
  padding: 32px;
  color: var(--color-text-muted);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.empty-icon {
  color: var(--color-success);
}

@media (max-width: 600px) {
  .quick-actions {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>

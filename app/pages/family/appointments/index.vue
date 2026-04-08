<template>
  <div class="appointments-page">
    <header class="page-header">
      <h1 class="page-title">Записи к врачу</h1>
      <NuxtLink to="/family/appointments/book" class="btn-book">
        <Icon name="lucide:plus" size="16" />
        Записаться
      </NuxtLink>
    </header>

    <!-- Upcoming -->
    <section v-if="appointmentsStore.upcoming.length" class="section">
      <h2 class="section-title">Предстоящие</h2>
      <div class="list">
        <AppSharedAppointmentCard
          v-for="apt in appointmentsStore.upcoming"
          :key="apt.id"
          :appointment="apt"
        />
      </div>
    </section>

    <!-- Past -->
    <section v-if="appointmentsStore.past.length" class="section">
      <h2 class="section-title muted">Прошедшие</h2>
      <div class="list">
        <AppSharedAppointmentCard
          v-for="apt in appointmentsStore.past"
          :key="apt.id"
          :appointment="apt"
        />
      </div>
    </section>

    <div v-if="!appointmentsStore.upcoming.length && !appointmentsStore.past.length" class="empty-state">
      <Icon name="lucide:calendar" size="40" class="empty-icon" />
      <h3>Нет записей</h3>
      <p>Запишитесь к врачу через ваш маршрут</p>
      <NuxtLink to="/family/appointments/book" class="btn-primary-sm">Записаться</NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const appointmentsStore = useAppointmentStore()
const authStore = useAuthStore()

onMounted(async () => {
  if (authStore.familyId) {
    await appointmentsStore.fetchAppointments(authStore.familyId)
  }
})
</script>

<style scoped>
.appointments-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 16px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.page-title {
  font-family: var(--font-display);
  font-size: 1.25rem;
  font-weight: 700;
}

.btn-book {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: var(--gradient-cta);
  color: white;
  border-radius: var(--radius-sm);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
}

.section { margin-bottom: 28px; }
.section-title { font-size: 1rem; font-weight: 600; margin-bottom: 12px; }
.section-title.muted { color: var(--color-text-secondary); }
.list { display: flex; flex-direction: column; gap: 8px; }

.empty-state {
  text-align: center;
  padding: 48px 16px;
  color: var(--color-text-muted);
}

.empty-state h3 { font-size: 1rem; margin: 8px 0 4px; color: var(--color-text-primary); }
.empty-state p { font-size: 0.85rem; margin-bottom: 16px; }
.empty-icon { color: var(--color-primary-light); }

.btn-primary-sm {
  display: inline-block;
  padding: 8px 20px;
  background: var(--gradient-cta);
  color: white;
  border-radius: var(--radius-sm);
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
}
</style>

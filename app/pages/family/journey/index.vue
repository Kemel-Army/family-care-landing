<template>
  <div class="journey-list">
    <header class="page-header">
      <h1 class="page-title">Маршруты</h1>
      <p class="page-subtitle">Все маршруты вашей семьи</p>
    </header>

    <div v-if="loading" class="loading-state">
      <Icon name="lucide:loader-2" size="24" class="spin" />
      <p>Загрузка...</p>
    </div>

    <div v-else-if="journeyStore.activeJourneys.length" class="journeys">
      <NuxtLink
        v-for="journey in journeyStore.activeJourneys"
        :key="journey.id"
        :to="`/family/journey/${journey.id}`"
        class="journey-card"
      >
        <div class="journey-icon">
          <Icon :name="journeyIcon(journey.type)" size="24" />
        </div>
        <div class="journey-info">
          <h3 class="journey-name">{{ journeyTypeLabel(journey.type) }}</h3>
          <span class="journey-status" :class="journey.status">{{ statusLabel(journey.status) }}</span>
        </div>
        <Icon name="lucide:chevron-right" size="18" class="journey-arrow" />
      </NuxtLink>
    </div>

    <div v-else class="empty-state">
      <Icon name="lucide:route" size="48" class="empty-icon" />
      <p>Маршруты пока не назначены</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const journeyStore = useJourneyStore()
const authStore = useAuthStore()
const loading = ref(true)

function journeyTypeLabel(type: string) {
  const map: Record<string, string> = {
    pregnancy: 'Беременность',
    postpartum: 'Послеродовой период',
    infant: 'Наблюдение 0-12 мес',
    toddler: 'Наблюдение 12-24 мес',
  }
  return map[type] || type
}

function journeyIcon(type: string) {
  const map: Record<string, string> = {
    pregnancy: 'lucide:baby',
    postpartum: 'lucide:heart-pulse',
    infant: 'lucide:smile',
    toddler: 'lucide:footprints',
  }
  return map[type] || 'lucide:route'
}

function statusLabel(status: string) {
  const map: Record<string, string> = {
    active: 'Активен',
    completed: 'Завершён',
    paused: 'На паузе',
  }
  return map[status] || status
}

onMounted(async () => {
  if (authStore.familyId) {
    await journeyStore.fetchJourneys(authStore.familyId)
  }
  loading.value = false
})
</script>

<style scoped>
.journey-list {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 16px;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-family: var(--font-display);
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text-primary);
}

.page-subtitle {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin-top: 4px;
}

.journeys {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.journey-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm);
  text-decoration: none;
  color: inherit;
  transition: all var(--transition-fast);
}

.journey-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-sm);
}

.journey-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-primary-ultralight);
  border-radius: var(--radius-sm);
  color: var(--color-primary);
}

.journey-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.journey-name {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.journey-status {
  font-size: 0.75rem;
  font-weight: 600;
}

.journey-status.active { color: var(--color-success); }
.journey-status.completed { color: var(--color-primary); }
.journey-status.paused { color: var(--color-warning); }

.journey-arrow {
  color: var(--color-text-muted);
}

.empty-state {
  text-align: center;
  padding: 64px 16px;
  color: var(--color-text-muted);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.empty-icon {
  opacity: 0.4;
}

.loading-state {
  text-align: center;
  padding: 48px;
  color: var(--color-text-muted);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>

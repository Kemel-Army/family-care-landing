<template>
  <div class="prescriptions-page">
    <header class="page-header">
      <h1 class="page-title">Назначения</h1>
      <div class="adherence-meter">
        <Icon name="lucide:activity" size="16" />
        <span>{{ prescriptionsStore.adherencePercent }}%</span>
      </div>
    </header>

    <!-- Today's doses -->
    <section v-if="prescriptionsStore.pendingDoses.length" class="section">
      <h2 class="section-title">Сегодня</h2>
      <div class="list">
        <AppSharedDoseCard
          v-for="dose in prescriptionsStore.pendingDoses"
          :key="dose.id"
          :dose="dose"
          @confirm="handleConfirm"
          @skip="handleSkip"
        />
      </div>
    </section>

    <!-- Active prescriptions -->
    <section v-if="prescriptionsStore.activePrescriptions.length" class="section">
      <h2 class="section-title">Активные назначения</h2>
      <div class="list">
        <div v-for="rx in prescriptionsStore.activePrescriptions" :key="rx.id" class="prescription-card">
          <div class="rx-icon">
            <Icon name="lucide:pill" size="20" />
          </div>
          <div class="rx-content">
            <h3>{{ rx.medication }}</h3>
            <p>{{ rx.dosage }} · {{ rx.frequency }}</p>
            <p v-if="rx.time_of_day?.length" class="rx-times">
              {{ rx.time_of_day.join(', ') }}
            </p>
          </div>
          <NuxtLink :to="`/family/prescriptions/${rx.id}`" class="rx-link">
            <Icon name="lucide:chevron-right" size="16" />
          </NuxtLink>
        </div>
      </div>
    </section>

    <div v-if="!prescriptionsStore.activePrescriptions.length && !prescriptionsStore.pendingDoses.length" class="empty-state">
      <Icon name="lucide:pill" size="40" class="empty-icon" />
      <h3>Нет назначений</h3>
      <p>Ваш координатор или врач добавит назначения в маршрут</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const prescriptionsStore = usePrescriptionStore()
const authStore = useAuthStore()

onMounted(async () => {
  if (authStore.familyId) {
    await prescriptionsStore.fetchPrescriptions(authStore.familyId)
  }
})

function handleConfirm(doseId: string) {
  prescriptionsStore.confirmDose(doseId)
}

function handleSkip(doseId: string) {
  prescriptionsStore.skipDose(doseId)
}
</script>

<style scoped>
.prescriptions-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px 16px;
}

.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.adherence-meter {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 14px; background: rgba(124, 184, 212, 0.1);
  border-radius: 20px; font-size: 0.85rem; font-weight: 600; color: var(--color-success);
}

.section { margin-bottom: 28px; }
.section-title { font-size: 1rem; font-weight: 600; margin-bottom: 12px; }
.list { display: flex; flex-direction: column; gap: 8px; }

.prescription-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); transition: all var(--transition-fast);
}
.prescription-card:hover { box-shadow: var(--shadow-sm); }

.rx-icon {
  width: 40px; height: 40px; border-radius: 50%; background: var(--color-primary-ultralight);
  color: var(--color-primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}

.rx-content { flex: 1; }
.rx-content h3 { font-size: 0.9rem; font-weight: 600; }
.rx-content p { font-size: 0.8rem; color: var(--color-text-secondary); }
.rx-times { font-style: italic; }
.rx-link { color: var(--color-text-muted); text-decoration: none; }

.empty-state { text-align: center; padding: 48px 16px; color: var(--color-text-muted); }
.empty-state h3 { font-size: 1rem; margin: 8px 0 4px; color: var(--color-text-primary); }
.empty-state p { font-size: 0.85rem; }
.empty-icon { color: var(--color-primary-light); }
</style>

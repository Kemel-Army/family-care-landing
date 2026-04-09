<template>
  <div class="rx-page">
    <!-- Header with overall adherence ring -->
    <div class="rx-hero">
      <div>
        <h1 class="rx-hero-title">Назначения</h1>
        <p class="rx-hero-sub">{{ mock.prescriptions.length }} препаратов · {{ pendingCount }} ожидают приёма</p>
      </div>
      <div class="rx-hero-ring">
        <AppSharedProgressRing :value="overallAdherence" :size="72" :strokeWidth="6" variant="primary" />
      </div>
    </div>

    <!-- Adherence week chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:bar-chart-3" size="16" /> Приём за неделю</h2>
      </div>
      <div class="adh-chart">
        <div v-for="day in mock.adherenceWeekly" :key="day.date" class="adh-col">
          <div class="adh-track">
            <div class="adh-fill" :style="{ height: `${(day.taken / day.total) * 100}%` }" />
          </div>
          <span class="adh-label">{{ day.date }}</span>
          <span class="adh-val">{{ day.taken }}/{{ day.total }}</span>
        </div>
      </div>
    </div>

    <!-- Today's Doses grouped by prescription -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:clock" size="16" /> Сегодня</h2>
      </div>
      <div class="rx-list">
        <div v-for="rx in mock.prescriptions" :key="rx.id" class="rx-block">
          <div class="rx-block-header">
            <div class="rx-block-icon"><Icon name="lucide:pill" size="16" /></div>
            <div class="rx-block-info">
              <span class="rx-block-name">{{ rx.medication }}</span>
              <span class="rx-block-dose">{{ rx.dosage }} · {{ rx.frequency }}</span>
            </div>
            <div class="rx-block-adh">
              <div class="rx-adh-bar"><div class="rx-adh-fill" :style="{ width: `${rx.adherencePercent}%` }" /></div>
              <span class="rx-adh-label">{{ rx.adherencePercent }}%</span>
            </div>
          </div>
          <div class="rx-doses-row">
            <div v-for="dose in rx.todayDoses" :key="dose.id" class="rx-dose-chip" :class="`rx-dose-chip--${dose.status}`">
              <Icon :name="dose.status === 'confirmed' ? 'lucide:check-circle' : dose.status === 'missed' ? 'lucide:x-circle' : 'lucide:circle'" size="14" />
              <span>{{ dose.time }}</span>
              <button v-if="dose.status === 'pending'" class="rx-dose-action" @click="handleConfirm(dose.id)">Принять</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Streak -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:flame" size="16" /> Серия приёма</h2>
      </div>
      <div class="streak-row">
        <div class="streak-big">
          <span class="streak-big-val">{{ mock.streaks.doses.current }}</span>
          <span class="streak-big-label">дней подряд</span>
        </div>
        <div class="streak-record">
          Рекорд: <strong>{{ mock.streaks.doses.longest }}</strong> дней
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const prescriptionsStore = usePrescriptionStore()
const authStore = useAuthStore()
const mock = useMockData()

const overallAdherence = computed(() => {
  const arr = mock.prescriptions.map(r => r.adherencePercent)
  return Math.round(arr.reduce((a, b) => a + b, 0) / arr.length)
})

const pendingCount = computed(() =>
  mock.prescriptions.flatMap(p => p.todayDoses).filter(d => d.status === 'pending').length
)

function handleConfirm(doseId: string) {
  prescriptionsStore.confirmDose(doseId)
}

onMounted(async () => {
  if (authStore.familyId) await prescriptionsStore.fetchPrescriptions(authStore.familyId)
})
</script>

<style scoped>
.rx-page { max-width: 760px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.rx-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.rx-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; color: var(--color-text-primary); }
.rx-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.card {
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px;
}
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; color: var(--color-text-primary); }

/* Adherence chart */
.adh-chart { display: flex; gap: 8px; height: 130px; padding-top: 4px; }
.adh-col { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px; height: 100%; }
.adh-track { flex: 1; width: 100%; background: rgba(139,126,200,0.06); border-radius: 6px; display: flex; align-items: flex-end; overflow: hidden; }
.adh-fill { width: 100%; background: var(--gradient-cta); border-radius: 6px; min-height: 4px; transition: height 0.5s ease; }
.adh-label { font-size: 0.6rem; color: var(--color-text-muted); }
.adh-val { font-size: 0.58rem; color: var(--color-text-muted); }

/* Prescription blocks */
.rx-list { display: flex; flex-direction: column; gap: 16px; }
.rx-block { padding-bottom: 16px; border-bottom: 1px solid var(--color-border-light); }
.rx-block:last-child { border-bottom: none; padding-bottom: 0; }

.rx-block-header { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
.rx-block-icon {
  width: 34px; height: 34px; border-radius: 10px; flex-shrink: 0;
  background: rgba(139,126,200,0.08); color: var(--color-primary);
  display: flex; align-items: center; justify-content: center;
}
.rx-block-info { flex: 1; min-width: 0; }
.rx-block-name { font-size: 0.88rem; font-weight: 600; color: var(--color-text-primary); display: block; }
.rx-block-dose { font-size: 0.75rem; color: var(--color-text-muted); }

.rx-block-adh { display: flex; flex-direction: column; gap: 2px; align-items: flex-end; flex-shrink: 0; }
.rx-adh-bar { width: 48px; height: 4px; background: rgba(139,126,200,0.1); border-radius: 2px; overflow: hidden; }
.rx-adh-fill { height: 100%; background: var(--gradient-cta); border-radius: 2px; }
.rx-adh-label { font-size: 0.62rem; color: var(--color-text-muted); }

.rx-doses-row { display: flex; gap: 10px; flex-wrap: wrap; }
.rx-dose-chip {
  display: flex; align-items: center; gap: 6px; padding: 6px 12px;
  border-radius: 10px; font-size: 0.78rem; background: rgba(139,126,200,0.04);
  color: var(--color-text-secondary);
}
.rx-dose-chip--confirmed { color: var(--color-success); background: rgba(124,184,212,0.08); }
.rx-dose-chip--missed { color: var(--color-danger); background: rgba(212,114,124,0.06); }
.rx-dose-chip--pending { color: var(--color-warning); background: rgba(233,196,106,0.08); }
.rx-dose-action {
  background: var(--color-primary); color: white; border: none; padding: 2px 10px; border-radius: 6px;
  font-size: 0.7rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); margin-left: 4px;
}
.rx-dose-action:hover { opacity: 0.85; }

/* Streak */
.streak-row { display: flex; align-items: center; gap: 24px; }
.streak-big { display: flex; flex-direction: column; align-items: center; }
.streak-big-val { font-size: 2rem; font-weight: 700; color: var(--color-text-primary); line-height: 1; }
.streak-big-label { font-size: 0.72rem; color: var(--color-text-muted); }
.streak-record { font-size: 0.82rem; color: var(--color-text-secondary); }
</style>

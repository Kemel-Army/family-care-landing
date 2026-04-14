<template>
  <div class="rx-page">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="skel skel-hero" />
      <div class="skel skel-card" /><div class="skel skel-card" />
    </template>

    <template v-else>
    <!-- Header with overall adherence ring -->
    <div class="rx-hero">
      <div>
        <h1 class="rx-hero-title">Назначения</h1>
        <p class="rx-hero-sub">{{ prescriptions.length }} препаратов · {{ pendingCount }} ожидают приёма</p>
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
        <div v-for="day in appData.adherenceWeekly" :key="day.date" class="adh-col">
          <div class="adh-track">
            <div class="adh-fill" :style="{ height: `${day.total > 0 ? (day.taken / day.total) * 100 : 0}%` }" />
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
      <div v-if="prescriptions.length" class="rx-list">
        <div v-for="rx in prescriptions" :key="rx.id" class="rx-block">
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
              <button v-if="dose.status === 'pending'" class="rx-dose-action" :disabled="confirming === dose.id" @click="handleConfirm(dose.id)">
                {{ confirming === dose.id ? '...' : 'Принять' }}
              </button>
            </div>
          </div>
        </div>
      </div>
      <AppSharedEmptyState v-else icon="lucide:pill" title="Нет активных назначений" />
    </div>

    <!-- Streak -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:flame" size="16" /> Серия приёма</h2>
      </div>
      <div class="streak-row">
        <div class="streak-big">
          <span class="streak-big-val">{{ appData.streaks.doses.current }}</span>
          <span class="streak-big-label">дней подряд</span>
        </div>
        <div class="streak-record">
          Рекорд: <strong>{{ appData.streaks.doses.longest }}</strong> дней
        </div>
      </div>
    </div>
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const prescriptionsStore = usePrescriptionStore()
const authStore = useAuthStore()
const appData = useAppData()

const confirming = ref<string | null>(null)
const { success: toastSuccess, error: toastError } = useToast()
const loading = ref(true)

onMounted(async () => {
  try {
    if (authStore.familyId) await prescriptionsStore.fetchPrescriptions(authStore.familyId)
  } finally {
    loading.value = false
  }
})

const prescriptions = computed(() => appData.prescriptions)

const overallAdherence = computed(() => {
  const hasReal = prescriptionsStore.prescriptions.length > 0
  if (hasReal) return prescriptionsStore.adherencePercent
  const arr = appData.prescriptions.map(r => r.adherencePercent)
  return arr.length ? Math.round(arr.reduce((a, b) => a + b, 0) / arr.length) : 0
})

const pendingCount = computed(() => {
  const hasReal = prescriptionsStore.pendingDoses.length > 0
  if (hasReal) return prescriptionsStore.pendingDoses.length
  return appData.prescriptions.flatMap(p => p.todayDoses).filter(d => d.status === 'pending').length
})

async function handleConfirm(doseId: string) {
  confirming.value = doseId
  try {
    const { error } = await prescriptionsStore.confirmDose(doseId)
    if (!error) toastSuccess('Приём подтверждён!')
    else toastError('Не удалось подтвердить')
  } catch {
    toastError('Ошибка сети')
  } finally {
    confirming.value = null
  }
}
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

/* Skeleton & Toast & Empty */
.skel { background: linear-gradient(90deg, rgba(139,126,200,0.06) 0%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 100%); background-size: 200% 100%; animation: shimmer 1.4s ease infinite; border-radius: 14px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skel-hero { height: 80px; border-radius: 16px; margin-bottom: 18px; }
.skel-card { height: 180px; margin-bottom: 16px; }
.card-empty { padding: 24px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 8px; font-size: 0.85rem; color: var(--color-text-muted); }
.rx-dose-action:disabled { opacity: 0.5; cursor: default; }
.toast { position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%); z-index: 9999; display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-radius: 12px; font-size: 0.85rem; font-weight: 500; box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
.toast--success { background: #e8f8ee; color: #1a7a3e; border: 1px solid #c3ecd0; }
.toast--error { background: #fdecea; color: #a63232; border: 1px solid #f5c6c6; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }
</style>

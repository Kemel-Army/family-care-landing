<template>
  <div class="prescription-detail">
    <header class="page-header">
      <NuxtLink to="/family/prescriptions" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Назначения
      </NuxtLink>
      <h1 class="page-title">{{ rx?.medication || 'Назначение' }}</h1>
    </header>

    <div v-if="rx" class="detail-card">
      <div class="rx-header">
        <div class="rx-icon">
          <Icon name="lucide:pill" size="28" />
        </div>
        <div>
          <h2>{{ rx.medication }}</h2>
          <p class="rx-dosage">{{ rx.dosage }} · {{ rx.frequency }}</p>
        </div>
      </div>

      <div class="info-grid">
        <div class="info-item">
          <span class="info-label">Начало</span>
          <span class="info-value">{{ formatDate(rx.start_date) }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">Окончание</span>
          <span class="info-value">{{ rx.end_date ? formatDate(rx.end_date) : 'Бессрочно' }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">Часы приёма</span>
          <span class="info-value">{{ rx.time_of_day?.join(', ') || '—' }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">Статус</span>
          <span class="info-value" :class="rx.is_active ? 'active' : 'inactive'">{{ rx.is_active ? 'Активно' : 'Завершено' }}</span>
        </div>
      </div>

      <p v-if="rx.instructions" class="rx-notes">{{ rx.instructions }}</p>
    </div>

    <!-- Dose history -->
    <section class="section">
      <h2 class="section-title">История приёмов (7 дней)</h2>
      <div v-if="doses.length" class="dose-list">
        <div v-for="d in doses" :key="d.id" class="dose-row">
          <span class="dose-time">{{ formatDoseTime(d.scheduled_at) }}</span>
          <span class="dose-status" :class="d.status">{{ doseLabel(d.status) }}</span>
        </div>
      </div>
      <AppSharedEmptyState v-else size="sm" icon="lucide:pill" title="Нет данных" />

      <div class="adherence-summary">
        <span>Adherence за 7 дней:</span>
        <span class="adherence-pct" :class="adherenceClass">{{ adherencePct }}%</span>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'
import type { Prescription, DoseLog } from '~/types/database'

definePageMeta({ layout: 'app' })

const route = useRoute()
const supabase = useSupabaseClient()

const rxId = route.params.id as string
const rx = ref<Prescription | null>(null)
const doses = ref<DoseLog[]>([])

function formatDate(d: string) { return dayjs(d).format('DD.MM.YYYY') }
function formatDoseTime(dt: string) { return dayjs(dt).format('DD.MM HH:mm') }

function doseLabel(status: string) {
  const map: Record<string, string> = { confirmed: 'Принято', missed: 'Пропущено', skipped: 'Пропущено', scheduled: 'Ожидается', pending: 'Ожидается' }
  return map[status] || status
}

const adherencePct = computed(() => {
  if (!doses.value.length) return 100
  const confirmed = doses.value.filter(d => d.status === 'confirmed').length
  return Math.round((confirmed / doses.value.length) * 100)
})

const adherenceClass = computed(() => adherencePct.value >= 80 ? 'good' : adherencePct.value >= 50 ? 'warn' : 'bad')

onMounted(async () => {
  const { data } = await supabase
    .from('prescriptions')
    .select('*')
    .eq('id', rxId)
    .single()

  if (data) rx.value = data as unknown as Prescription

  const sevenDaysAgo = dayjs().subtract(7, 'day').toISOString()
  const { data: doseData } = await supabase
    .from('dose_logs')
    .select('*')
    .eq('prescription_id', rxId)
    .gte('scheduled_at', sevenDaysAgo)
    .order('scheduled_at', { ascending: false })

  if (doseData) doses.value = doseData as DoseLog[]
})
</script>

<style scoped>
.prescription-detail { max-width: 600px; margin: 0 auto; padding: 24px 16px; }

.page-header { display: flex; flex-direction: column; gap: 8px; margin-bottom: 20px; }
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.85rem; color: var(--color-primary); text-decoration: none; font-weight: 500; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.detail-card {
  padding: 20px; background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md); margin-bottom: 24px;
}

.rx-header { display: flex; align-items: center; gap: 14px; margin-bottom: 16px; }
.rx-icon { width: 48px; height: 48px; border-radius: var(--radius-sm); background: var(--color-primary-ultralight); display: flex; align-items: center; justify-content: center; color: var(--color-primary); flex-shrink: 0; }
.rx-header h2 { font-size: 1.1rem; font-weight: 700; }
.rx-dosage { font-size: 0.85rem; color: var(--color-text-secondary); margin-top: 2px; }

.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
.info-item { display: flex; flex-direction: column; }
.info-label { font-size: 0.75rem; color: var(--color-text-muted); font-weight: 500; }
.info-value { font-size: 0.9rem; font-weight: 600; margin-top: 2px; }
.info-value.active { color: var(--color-success); }
.info-value.inactive { color: var(--color-text-muted); }

.rx-notes { font-size: 0.85rem; color: var(--color-text-secondary); font-style: italic; padding-top: 8px; border-top: 1px solid var(--color-border-light); }

.section { margin-bottom: 24px; }
.section-title { font-size: 0.95rem; font-weight: 600; margin-bottom: 12px; }

.dose-list { display: flex; flex-direction: column; gap: 6px; }
.dose-row {
  display: flex; align-items: center; justify-content: space-between; padding: 10px 14px;
  background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-sm);
}
.dose-time { font-size: 0.85rem; font-family: var(--font-mono); color: var(--color-text-secondary); }
.dose-status { font-size: 0.8rem; font-weight: 600; padding: 2px 10px; border-radius: 12px; }
.dose-status.confirmed { background: rgba(124, 184, 212, 0.12); color: var(--color-success); }
.dose-status.missed, .dose-status.skipped { background: rgba(231, 111, 81, 0.1); color: var(--color-danger); }
.dose-status.scheduled, .dose-status.pending { background: rgba(139, 126, 200, 0.1); color: var(--color-primary); }

.adherence-summary { display: flex; align-items: center; justify-content: space-between; padding: 12px 14px; margin-top: 12px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-sm); font-size: 0.9rem; font-weight: 500; }
.adherence-pct { font-weight: 700; font-family: var(--font-mono); }
.adherence-pct.good { color: var(--color-success); }
.adherence-pct.warn { color: #F59E0B; }
.adherence-pct.bad { color: var(--color-danger); }

.empty-mini { font-size: 0.9rem; color: var(--color-text-muted); text-align: center; padding: 20px; }
</style>

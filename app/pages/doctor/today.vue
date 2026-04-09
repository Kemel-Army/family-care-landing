<template>
  <div class="today-page">
    <div class="today-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Панель</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Сегодня</h1>
          <p class="hero-sub">{{ formattedDate }} · {{ appointments.length }} {{ pluralize(appointments.length) }}</p>
        </div>
        <div class="hero-stat">
          <span class="stat-num">{{ confirmedCount }}</span>
          <span class="stat-label">подтв.</span>
        </div>
      </div>
    </div>

    <div v-if="pending" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <template v-else-if="appointments.length">
      <!-- Timeline -->
      <div class="timeline">
        <div
          v-for="(a, i) in appointments"
          :key="a.id"
          class="tl-item"
          :class="{ active: isNow(a), done: a.status === 'completed' }"
        >
          <div class="tl-gutter">
            <div class="tl-time">{{ a.time }}</div>
            <div class="tl-dot" />
            <div v-if="i < appointments.length - 1" class="tl-line" />
          </div>

          <div class="tl-card">
            <div class="tl-card-top">
              <h3 class="tl-patient">{{ a.patient_name }}</h3>
              <span class="tl-status" :class="a.status">{{ statusLabel(a.status) }}</span>
            </div>
            <p class="tl-reason">{{ a.reason }}</p>
            <div class="tl-meta">
              <span v-if="a.child_age" class="tl-chip"><Icon name="lucide:baby" size="11" /> {{ a.child_age }}</span>
              <span class="tl-chip"><Icon name="lucide:stethoscope" size="11" /> {{ specLabel(a.doctor_specialty) }}</span>
              <span class="tl-chip"><Icon name="lucide:clock" size="11" /> {{ a.time }}–{{ a.end_time }}</span>
            </div>
          </div>
        </div>
      </div>
    </template>

    <AppSharedEmptyState
      v-else
      icon="lucide:calendar-check"
      title="Нет записей на сегодня"
      description="Все слоты свободны — отличный день для документации"
    />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

interface Appointment {
  id: string
  time: string
  end_time: string
  status: string
  reason: string
  visit_type: string
  family_id: string
  patient_name: string
  child_age: string | null
  doctor_name: string | null
  doctor_specialty: string | null
}

const { data, pending } = await useFetch<{ appointments: Appointment[]; date: string }>('/api/appointments/today')

const appointments = computed(() => data.value?.appointments ?? [])
const confirmedCount = computed(() => appointments.value.filter(a => a.status === 'confirmed').length)

const formattedDate = computed(() => {
  const d = new Date()
  return d.toLocaleDateString('ru-RU', { weekday: 'long', day: 'numeric', month: 'long' })
})

function pluralize(n: number) {
  if (n % 10 === 1 && n % 100 !== 11) return 'запись'
  if ([2, 3, 4].includes(n % 10) && ![12, 13, 14].includes(n % 100)) return 'записи'
  return 'записей'
}

function statusLabel(s: string) {
  return { confirmed: 'Подтверждён', completed: 'Завершён', no_show: 'Неявка', requested: 'Запрос', cancelled: 'Отменён' }[s] || s
}

function specLabel(s: string | null) {
  return { gynecologist: 'Гинеколог', pediatrician: 'Педиатр', neonatologist: 'Неонатолог', ultrasound: 'УЗИ', lab: 'Лаборатория' }[s ?? ''] || s
}

function isNow(a: Appointment) {
  const now = new Date()
  const h = now.getHours()
  const m = now.getMinutes()
  const current = `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
  return current >= a.time && current < (a.end_time || '23:59')
}
</script>

<style scoped>
.today-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.today-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; text-transform: capitalize; }
.hero-stat { text-align: center; }
.stat-num { display: block; font-size: 1.5rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); }
.stat-label { font-size: 0.68rem; color: var(--color-text-muted); }

/* Loading */
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 40px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

/* Timeline */
.timeline { display: flex; flex-direction: column; }

.tl-item { display: flex; gap: 16px; }
.tl-item.active .tl-card { border-color: var(--color-primary); box-shadow: 0 0 0 2px rgba(139,126,200,0.12); }
.tl-item.done .tl-card { opacity: 0.6; }

.tl-gutter { display: flex; flex-direction: column; align-items: center; width: 56px; flex-shrink: 0; padding-top: 14px; }
.tl-time { font-size: 0.78rem; font-weight: 600; font-family: var(--font-mono); color: var(--color-text-muted); margin-bottom: 8px; white-space: nowrap; }
.tl-dot { width: 10px; height: 10px; border-radius: 50%; border: 2px solid var(--color-border-light); background: white; flex-shrink: 0; z-index: 1; }
.tl-item.active .tl-dot { border-color: var(--color-primary); background: var(--color-primary); }
.tl-item.done .tl-dot { border-color: #4a9960; background: #4a9960; }
.tl-line { width: 2px; flex: 1; background: var(--color-border-light); min-height: 20px; }

.tl-card {
  flex: 1; background: white; border: 1px solid var(--color-border-light); border-radius: 14px;
  padding: 14px 16px; margin-bottom: 8px; transition: all 0.2s;
}
.tl-card:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }

.tl-card-top { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.tl-patient { font-size: 0.92rem; font-weight: 600; }
.tl-reason { font-size: 0.8rem; color: var(--color-text-muted); margin-top: 4px; }

.tl-meta { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 10px; }
.tl-chip {
  display: inline-flex; align-items: center; gap: 3px;
  padding: 2px 8px; border-radius: 8px; font-size: 0.68rem; font-weight: 500;
  background: rgba(139,126,200,0.06); color: var(--color-text-muted);
}

/* Status */
.tl-status { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; white-space: nowrap; }
.tl-status.confirmed { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.tl-status.completed { background: rgba(100,180,120,0.12); color: #4a9960; }
.tl-status.no_show { background: rgba(217,79,79,0.12); color: #d94f4f; }
.tl-status.requested { background: rgba(232,184,77,0.12); color: #b08a2a; }
.tl-status.cancelled { background: rgba(150,150,150,0.12); color: #888; }
</style>

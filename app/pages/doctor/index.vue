<template>
  <div class="doc-page">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="skel skel-hero" />
      <div class="kpi-grid"><div v-for="i in 4" :key="i" class="skel skel-kpi" /></div>
      <div class="skel skel-card" /><div class="skel skel-card" />
    </template>

    <template v-else>
    <!-- Hero -->
    <div class="doc-hero">
      <div>
        <h1 class="doc-hero-title">Панель врача</h1>
        <p class="doc-hero-sub">{{ greetingLine }}. Сегодня {{ kpi.todayAppointments }} записей, {{ kpi.freeSlots }} свободных слотов</p>
      </div>
      <div class="rating-chip">
        <Icon name="lucide:star" size="14" /> {{ kpi.avgRating }}
      </div>
    </div>

    <!-- KPI strip -->
    <div class="kpi-grid">
      <div class="kpi-card">
        <Icon name="lucide:calendar" size="16" style="color:var(--color-primary)" />
        <span class="kpi-val">{{ kpi.todayAppointments }}</span>
        <span class="kpi-label">Записей</span>
      </div>
      <div class="kpi-card">
        <Icon name="lucide:users" size="16" style="color:var(--color-accent-rose)" />
        <span class="kpi-val">{{ kpi.totalPatients }}</span>
        <span class="kpi-label">Пациентов</span>
      </div>
      <div class="kpi-card">
        <Icon name="lucide:clock" size="16" style="color:var(--color-accent-sky)" />
        <span class="kpi-val">{{ kpi.freeSlots }}</span>
        <span class="kpi-label">Свободно</span>
      </div>
      <div class="kpi-card">
        <Icon name="lucide:star" size="16" style="color:var(--color-warning)" />
        <span class="kpi-val">{{ kpi.avgRating }}</span>
        <span class="kpi-label">Рейтинг</span>
      </div>
    </div>

    <!-- Today's schedule -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:calendar" size="16" /> Расписание на сегодня</h2>
      </div>
      <div v-if="schedule.length" class="schedule-list">
        <div v-for="s in schedule" :key="s.id" class="slot-row" :class="{ 'slot-row--free': !s.is_booked }">
          <span class="slot-time">{{ s.start_time }}</span>
          <template v-if="s.is_booked">
            <div class="slot-patient">
              <span class="slot-name">{{ s.patient_name }}</span>
              <span class="slot-reason">{{ s.reason }}</span>
            </div>
          </template>
          <span v-else class="slot-free-label">Свободно</span>
        </div>
      </div>
      <AppSharedEmptyState v-else icon="lucide:calendar-off" title="Нет записей на сегодня" />
    </div>

    <!-- Weekly load chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:bar-chart-3" size="16" /> Загрузка на неделю</h2>
      </div>
      <AppSharedEChart :option="weeklyLoadOption" height="180px" />
    </div>

    <!-- Quick links -->
    <div class="quick-grid">
      <NuxtLink to="/doctor/patients" class="quick-card">
        <Icon name="lucide:users" size="20" style="color:var(--color-primary)" />
        <span>Все пациенты</span>
        <Icon name="lucide:chevron-right" size="14" class="quick-arrow" />
      </NuxtLink>
      <NuxtLink to="/doctor/schedule" class="quick-card">
        <Icon name="lucide:calendar" size="20" style="color:var(--color-accent-peach)" />
        <span>Управление расписанием</span>
        <Icon name="lucide:chevron-right" size="14" class="quick-arrow" />
      </NuxtLink>
    </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import type { EChartsOption } from 'echarts'
definePageMeta({ layout: 'app' })

const authStore = useAuthStore()
const appData = useAppData()

const loading = ref(true)
const realKpi = ref<{ todayAppointments: number; totalPatients: number; freeSlots: number; avgRating: number } | null>(null)
const realSchedule = ref<any[] | null>(null)
const realWeeklyLoad = ref<any[] | null>(null)

// ── Fetch real doctor data ──
onMounted(async () => {
  try {
    const [kpiRes, scheduleRes, loadRes] = await Promise.allSettled([
      $fetch('/api/doctor/kpi'),
      $fetch('/api/doctor/schedule'),
      $fetch('/api/doctor/weekly-load'),
    ])
    if (kpiRes.status === 'fulfilled') realKpi.value = kpiRes.value as any
    if (scheduleRes.status === 'fulfilled') realSchedule.value = scheduleRes.value as any
    if (loadRes.status === 'fulfilled') realWeeklyLoad.value = loadRes.value as any
  } catch { /* use appData fallback */ }
  finally { loading.value = false }
})

const greetingLine = computed(() => {
  const name = authStore.profile?.first_name || 'Доктор'
  const h = new Date().getHours()
  const greet = h < 6 ? 'Доброй ночи' : h < 12 ? 'Доброе утро' : h < 18 ? 'Добрый день' : 'Добрый вечер'
  return `${greet}, ${name}`
})

const kpi = computed(() => realKpi.value || appData.doctorKpi)
const schedule = computed(() => realSchedule.value || appData.todaySchedule)
const weeklyLoad = computed(() => realWeeklyLoad.value || appData.weeklyLoad)

const weeklyLoadOption = computed<EChartsOption>(() => ({
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category' as const, data: weeklyLoad.value.map((d: any) => d.day), axisLabel: { fontSize: 11 } },
  yAxis: { type: 'value' as const, max: 12, axisLabel: { fontSize: 10 } },
  grid: { top: 10, right: 10, bottom: 24, left: 36 },
  series: [
    { type: 'bar' as const, data: weeklyLoad.value.map((d: any) => d.booked), barWidth: 20, itemStyle: { borderRadius: [6, 6, 0, 0], color: '#8B7EC8' }, name: 'Занято' },
    { type: 'bar' as const, data: weeklyLoad.value.map((d: any) => d.total - d.booked), barWidth: 20, itemStyle: { borderRadius: [6, 6, 0, 0], color: '#E8E8ED' }, name: 'Свободно', stack: 'load' },
  ],
}))
</script>

<style scoped>
.doc-page { max-width: 760px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.doc-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(168,200,232,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(168,200,232,0.12); border-radius: 16px; padding: 24px 28px;
}
.doc-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.doc-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.rating-chip { display: flex; align-items: center; gap: 4px; padding: 6px 14px; border-radius: 20px; background: rgba(233,196,106,0.12); color: var(--color-warning); font-size: 0.82rem; font-weight: 700; font-family: var(--font-mono); }

.kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
@media (max-width: 500px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
.kpi-card { text-align: center; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px 10px; display: flex; flex-direction: column; align-items: center; gap: 4px; }
.kpi-val { font-size: 1.2rem; font-weight: 700; font-family: var(--font-mono); }
.kpi-label { font-size: 0.68rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.schedule-list { display: flex; flex-direction: column; gap: 4px; }
.slot-row { display: flex; align-items: center; gap: 14px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.slot-row:hover { background: rgba(139,126,200,0.04); }
.slot-row--free { opacity: 0.5; }
.slot-time { font-size: 0.88rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); width: 44px; flex-shrink: 0; }
.slot-patient { flex: 1; min-width: 0; }
.slot-name { font-size: 0.82rem; font-weight: 600; display: block; }
.slot-reason { font-size: 0.68rem; color: var(--color-text-muted); }
.slot-free-label { font-size: 0.78rem; color: var(--color-text-muted); font-style: italic; }

.quick-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
.quick-card { display: flex; align-items: center; gap: 12px; padding: 16px 18px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; text-decoration: none; color: inherit; transition: all 0.2s; }
.quick-card:hover { border-color: rgba(139,126,200,0.2); transform: translateY(-1px); }
.quick-card span { flex: 1; font-size: 0.85rem; font-weight: 500; }
.quick-arrow { color: var(--color-text-muted); }

/* ─── Skeleton ─── */
.skel { background: linear-gradient(90deg, rgba(139,126,200,0.06) 0%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 100%); background-size: 200% 100%; animation: shimmer 1.4s ease infinite; border-radius: 14px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skel-hero { height: 80px; border-radius: 16px; }
.skel-kpi { height: 90px; }
.skel-card { height: 200px; margin-bottom: 16px; }
.card-empty { padding: 24px; text-align: center; font-size: 0.85rem; color: var(--color-text-muted); }
</style>

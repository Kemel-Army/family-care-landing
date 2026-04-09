<template>
  <div class="doc-page">
    <!-- Hero -->
    <div class="doc-hero">
      <div>
        <h1 class="doc-hero-title">Панель врача</h1>
        <p class="doc-hero-sub">Сегодня {{ mock.doctorKpi.todayAppointments }} записей, {{ mock.doctorKpi.freeSlots }} свободных слотов</p>
      </div>
      <div class="rating-chip">
        <Icon name="lucide:star" size="14" /> {{ mock.doctorKpi.avgRating }}
      </div>
    </div>

    <!-- KPI strip -->
    <div class="kpi-grid">
      <div class="kpi-card">
        <Icon name="lucide:calendar" size="16" style="color:var(--color-primary)" />
        <span class="kpi-val">{{ mock.doctorKpi.todayAppointments }}</span>
        <span class="kpi-label">Записей</span>
      </div>
      <div class="kpi-card">
        <Icon name="lucide:users" size="16" style="color:var(--color-accent-rose)" />
        <span class="kpi-val">{{ mock.doctorKpi.totalPatients }}</span>
        <span class="kpi-label">Пациентов</span>
      </div>
      <div class="kpi-card">
        <Icon name="lucide:clock" size="16" style="color:var(--color-accent-sky)" />
        <span class="kpi-val">{{ mock.doctorKpi.freeSlots }}</span>
        <span class="kpi-label">Свободно</span>
      </div>
      <div class="kpi-card">
        <Icon name="lucide:star" size="16" style="color:var(--color-warning)" />
        <span class="kpi-val">{{ mock.doctorKpi.avgRating }}</span>
        <span class="kpi-label">Рейтинг</span>
      </div>
    </div>

    <!-- Today's schedule -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:calendar" size="16" /> Расписание на сегодня</h2>
      </div>
      <div class="schedule-list">
        <div v-for="s in mock.todaySchedule" :key="s.id" class="slot-row" :class="{ 'slot-row--free': !s.is_booked }">
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
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const weeklyLoadOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category', data: mock.weeklyLoad.map(d => d.day), axisLabel: { fontSize: 11 } },
  yAxis: { type: 'value', max: 12, axisLabel: { fontSize: 10 } },
  grid: { top: 10, right: 10, bottom: 24, left: 36 },
  series: [
    { type: 'bar', data: mock.weeklyLoad.map(d => d.booked), barWidth: 20, itemStyle: { borderRadius: [6, 6, 0, 0], color: '#8B7EC8' }, name: 'Занято' },
    { type: 'bar', data: mock.weeklyLoad.map(d => d.total - d.booked), barWidth: 20, itemStyle: { borderRadius: [6, 6, 0, 0], color: '#E8E8ED' }, name: 'Свободно', stack: 'load' },
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
</style>

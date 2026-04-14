<template>
  <div class="demo-doctor">
    <!-- KPI row -->
    <div class="grid-kpi">
      <div class="kpi-card">
        <span class="kpi-overline">Пациентов</span>
        <span class="kpi-val font-display">{{ doctorKpi.totalPatients }}</span>
      </div>
      <div class="kpi-card kpi-card--warm">
        <span class="kpi-overline">Визитов сегодня</span>
        <span class="kpi-val font-display">{{ doctorKpi.todayAppointments }}</span>
      </div>
      <div class="kpi-card kpi-card--blue">
        <span class="kpi-overline">Свободных слотов</span>
        <span class="kpi-val font-display">{{ doctorKpi.freeSlots }}</span>
      </div>
    </div>

    <!-- Today's schedule -->
    <section class="demo-panel">
      <h2 class="panel-title">Расписание на сегодня</h2>
      <div class="doctor-schedule">
        <div
          v-for="slot in todaySchedule"
          :key="slot.id"
          class="visit-card"
          :class="{ 'visit-free': !slot.is_booked }"
        >
          <div class="visit-time font-mono">{{ slot.start_time }}</div>
          <div v-if="slot.is_booked" class="visit-body">
            <div class="visit-header">
              <span class="visit-name">{{ slot.patient_name }}</span>
              <span class="visit-type-badge">{{ slot.reason }}</span>
            </div>
            <div class="visit-actions">
              <button class="visit-btn">
                <Icon name="lucide:route" size="14" />
                Маршрут
              </button>
              <button class="visit-btn">
                <Icon name="lucide:folder-open" size="14" />
                Документы
              </button>
              <button class="visit-btn">
                <Icon name="lucide:pill" size="14" />
                Назначения
              </button>
            </div>
          </div>
          <div v-else class="visit-body">
            <span class="visit-free-label">Свободный слот</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Patients -->
    <section class="demo-panel">
      <h2 class="panel-title">Мои пациенты</h2>
      <div class="doctor-patients">
        <div v-for="p in doctorPatients" :key="p.id" class="patient-card">
          <div class="patient-info">
            <span class="patient-name">{{ p.mother_name }}</span>
            <span class="patient-journey">{{ p.journey_type }}</span>
          </div>
          <div class="patient-meta">
            <span class="patient-visit">Посл. визит: {{ formatDate(p.last_visit) }}</span>
            <span class="patient-next">След.: {{ formatDate(p.next_visit) }}</span>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'demo' })

const { doctorKpi, todaySchedule, doctorPatients } = useMockData()

function formatDate(iso: string) {
  const d = new Date(iso)
  const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  return `${d.getDate()} ${months[d.getMonth()]}`
}
</script>

<style scoped>
.demo-doctor {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* KPI */
.grid-kpi {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.kpi-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 20px;
  position: relative;
  overflow: hidden;
}

.kpi-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1.5px;
  background: var(--gradient-cta);
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: exclude;
  -webkit-mask-composite: xor;
  pointer-events: none;
  opacity: 0.4;
}

.kpi-card--warm::before { background: linear-gradient(135deg, var(--color-accent-warm), var(--color-secondary)); }
.kpi-card--blue::before { background: linear-gradient(135deg, var(--color-accent-blue), var(--color-primary)); }

.kpi-overline {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.kpi-val {
  display: block;
  font-size: clamp(1.5rem, 2.5vw, 2rem);
  font-weight: 800;
  color: var(--color-primary);
  margin-top: 6px;
}

/* Panel */
.demo-panel {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: 24px;
}

.panel-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 20px;
}

/* Schedule */
.doctor-schedule {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.visit-card {
  display: flex;
  gap: 16px;
  padding: 16px;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-light);
  transition: box-shadow var(--transition-smooth);
}

.visit-card:hover {
  box-shadow: var(--shadow-md);
}

.visit-free {
  border: 1px dashed var(--color-border);
  background: var(--color-bg-alt);
  opacity: 0.7;
}

.visit-free-label {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  font-style: italic;
}

.visit-time {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  width: 48px;
  flex-shrink: 0;
  padding-top: 2px;
}

.visit-body { flex: 1; }

.visit-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.visit-name {
  font-weight: 700;
  color: var(--color-text-primary);
}

.visit-type-badge {
  font-size: 10px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: var(--radius-full);
  background: var(--color-primary-light);
  color: var(--color-primary);
}

.visit-info {
  font-size: var(--text-sm);
  color: var(--color-text-secondary);
  margin: 0 0 6px;
}

/* Patients */
.doctor-patients {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.patient-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border-light);
  transition: box-shadow var(--transition-fast);
}

.patient-card:hover {
  box-shadow: var(--shadow-sm);
}

.patient-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.patient-name {
  font-weight: 600;
  font-size: var(--text-sm);
  color: var(--color-text-primary);
}

.patient-journey {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.patient-meta {
  display: flex;
  gap: 12px;
  flex-shrink: 0;
}

.patient-visit,
.patient-next {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.visit-actions {
  display: flex;
  gap: 6px;
}

.visit-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  font-weight: 500;
  border: 1px solid var(--color-border-light);
  background: transparent;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all var(--transition-fast);
}

.visit-btn:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
  background: var(--color-primary-ultralight);
}

/* Responsive */
@media (max-width: 768px) {
  .grid-kpi {
    grid-template-columns: 1fr;
  }
  .visit-card {
    flex-direction: column;
    gap: 8px;
  }
  .visit-time {
    width: auto;
  }
}
</style>

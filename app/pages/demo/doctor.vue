<template>
  <div class="demo-doctor">
    <!-- KPI row -->
    <div class="grid-kpi">
      <div class="kpi-card">
        <span class="kpi-overline">Пациентов</span>
        <span class="kpi-val font-display">34</span>
      </div>
      <div class="kpi-card kpi-card--warm">
        <span class="kpi-overline">Визитов сегодня</span>
        <span class="kpi-val font-display">8</span>
      </div>
      <div class="kpi-card kpi-card--blue">
        <span class="kpi-overline">Средний Adherence</span>
        <span class="kpi-val font-display">91%</span>
      </div>
    </div>

    <!-- Today's schedule -->
    <section class="demo-panel">
      <h2 class="panel-title">Расписание на сегодня</h2>
      <div class="doctor-schedule">
        <div
          v-for="visit in visits"
          :key="visit.id"
          class="visit-card"
          :class="{ 'visit-warning': visit.warning }"
        >
          <div class="visit-time font-mono">{{ visit.time }}</div>
          <div class="visit-body">
            <div class="visit-header">
              <span class="visit-name">{{ visit.patient }}</span>
              <span class="visit-type-badge">{{ visit.type }}</span>
            </div>
            <p class="visit-info">{{ visit.info }}</p>
            <div class="visit-meta">
              <span class="visit-adherence" :class="visit.adherenceClass">
                Adherence {{ visit.adherence }}%
                <Icon :name="visit.adherence >= 80 ? 'lucide:check' : 'lucide:alert-triangle'" size="12" />
              </span>
              <span v-if="visit.note" class="visit-note">{{ visit.note }}</span>
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
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'demo' })

const visits = [
  {
    id: 1,
    time: '09:00',
    patient: 'Каримова А.',
    type: 'УЗИ',
    info: 'Беременность 24 нед · II триместр скрининг',
    adherence: 45,
    adherenceClass: 'adherence--danger',
    warning: true,
    note: 'Пропустила 2 визита',
  },
  {
    id: 2,
    time: '10:30',
    patient: 'Алиева Д.',
    type: 'Плановый осмотр',
    info: 'Беременность 16 нед',
    adherence: 92,
    adherenceClass: 'adherence--success',
    warning: false,
    note: 'Всё по графику',
  },
  {
    id: 3,
    time: '12:00',
    patient: 'Нурланова С.',
    type: 'АКДС #3',
    info: 'Малыш 6 мес · Вакцинация',
    adherence: 98,
    adherenceClass: 'adherence--success',
    warning: false,
    note: 'Вес/рост в норме',
  },
  {
    id: 4,
    time: '14:00',
    patient: 'Байтурсынова Г.',
    type: 'Первичный',
    info: 'Малыш 1 мес · Первый осмотр',
    adherence: 100,
    adherenceClass: 'adherence--success',
    warning: false,
    note: null,
  },
  {
    id: 5,
    time: '15:30',
    patient: 'Оразова Л.',
    type: 'Консультация',
    info: 'Беременность 32 нед · Результаты анализов',
    adherence: 78,
    adherenceClass: 'adherence--warning',
    warning: false,
    note: 'Пропустила приём железа',
  },
]
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

.visit-warning {
  border-left: 3px solid var(--color-danger);
  background: rgba(212, 114, 124, 0.03);
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

.visit-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.visit-adherence {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: var(--text-xs);
  font-weight: 600;
}

.adherence--success { color: var(--color-success); }
.adherence--warning { color: #C4930E; }
.adherence--danger { color: var(--color-danger); }

.visit-note {
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

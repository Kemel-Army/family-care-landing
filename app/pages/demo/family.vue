<template>
  <div class="demo-family">
    <!-- Greeting -->
    <div class="demo-greeting">
      <h1 class="demo-greeting-title font-display">Привет, Айгерим!</h1>
      <p class="demo-greeting-sub">Алиса · 4 мес. 12 дней</p>
    </div>

    <!-- KPI row -->
    <div class="demo-kpi-row">
      <div class="kpi-card">
        <span class="kpi-label">Adherence сегодня</span>
        <div class="kpi-progress">
          <div class="kpi-progress-track">
            <div class="kpi-progress-fill" style="width: 66%" />
          </div>
          <span class="kpi-progress-text font-mono">2/3</span>
        </div>
      </div>
      <div class="kpi-card kpi-card--warm">
        <span class="kpi-label">Streak</span>
        <div class="kpi-val">
          <span class="kpi-number font-display">12</span>
          <span class="kpi-unit">дней подряд</span>
        </div>
      </div>
      <div class="kpi-card kpi-card--blue">
        <span class="kpi-label">Маршрут</span>
        <div class="kpi-val">
          <span class="kpi-number font-display">68%</span>
          <span class="kpi-unit">34 из 50</span>
        </div>
      </div>
    </div>

    <!-- Today's prescriptions -->
    <section class="demo-section">
      <h2 class="demo-section-title">Назначения на сегодня</h2>
      <div class="demo-doses">
        <div
          v-for="dose in doses"
          :key="dose.id"
          class="dose-card"
          :class="{ 'dose-taken': dose.taken }"
        >
          <div class="dose-icon" :style="{ background: dose.color }">
            <Icon name="lucide:pill" size="16" />
          </div>
          <div class="dose-body">
            <span class="dose-name">{{ dose.name }}</span>
            <span class="dose-time">{{ dose.time }}</span>
          </div>
          <button
            v-if="!dose.taken"
            class="dose-btn"
            @click="takeDose(dose.id)"
          >
            Принять
          </button>
          <span v-else class="dose-done">
            <Icon name="lucide:check" size="16" />
            Принято
          </span>
        </div>
      </div>
    </section>

    <!-- Upcoming events -->
    <section class="demo-section">
      <h2 class="demo-section-title">Ближайшие события</h2>
      <div class="demo-events">
        <div v-for="event in events" :key="event.id" class="event-card">
          <div class="event-icon" :style="{ background: event.color }">
            <Icon :name="event.icon" size="16" />
          </div>
          <div class="event-body">
            <span class="event-name">{{ event.name }}</span>
            <span class="event-date">{{ event.date }}</span>
          </div>
          <span class="event-badge" :class="event.badgeClass">{{ event.badge }}</span>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'demo' })

const doses = ref([
  { id: 1, name: 'Витамин D3', time: '08:00', color: 'var(--color-primary)', taken: true },
  { id: 2, name: 'Железо', time: '14:00', color: 'var(--color-secondary)', taken: false },
  { id: 3, name: 'Магний B6', time: '20:00', color: 'var(--color-accent-blue)', taken: false },
])

const events = [
  { id: 1, name: 'Педиатр — осмотр', date: 'Сегодня, 14:00', icon: 'lucide:stethoscope', color: 'var(--color-secondary)', badge: 'Сегодня', badgeClass: 'badge--warning' },
  { id: 2, name: 'АКДС #2', date: 'Через 5 дней', icon: 'lucide:shield-check', color: 'var(--color-accent-blue)', badge: 'Скоро', badgeClass: 'badge--info' },
  { id: 3, name: 'Общий анализ крови', date: 'Через 8 дней', icon: 'lucide:flask-conical', color: 'var(--color-success)', badge: 'Плановый', badgeClass: 'badge--neutral' },
]

function takeDose(id: number) {
  const dose = doses.value.find(d => d.id === id)
  if (dose) dose.taken = true
}
</script>

<style scoped>
.demo-family {
  max-width: 600px;
  margin: 0 auto;
}

.demo-greeting {
  margin-bottom: 24px;
}

.demo-greeting-title {
  font-size: var(--text-h2);
  color: var(--color-text-primary);
  margin: 0;
}

.demo-greeting-sub {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  margin: 4px 0 0;
}

/* KPI row */
.demo-kpi-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 32px;
}

.kpi-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 16px;
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
  opacity: 0.5;
}

.kpi-card--warm::before {
  background: linear-gradient(135deg, var(--color-accent-warm), var(--color-secondary));
}

.kpi-card--blue::before {
  background: linear-gradient(135deg, var(--color-accent-blue), var(--color-primary));
}

.kpi-label {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.kpi-val {
  display: flex;
  align-items: baseline;
  gap: 6px;
  margin-top: 8px;
}

.kpi-number {
  font-size: clamp(1.25rem, 2vw, 1.5rem);
  font-weight: 800;
  color: var(--color-primary);
}

.kpi-unit {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.kpi-progress {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
}

.kpi-progress-track {
  flex: 1;
  height: 6px;
  background: var(--color-border-light);
  border-radius: 3px;
  overflow: hidden;
}

.kpi-progress-fill {
  height: 100%;
  background: var(--gradient-cta);
  border-radius: 3px;
  transition: width 0.6s ease;
}

.kpi-progress-text {
  font-size: var(--text-sm);
  font-weight: 600;
  color: var(--color-primary);
}

/* Sections */
.demo-section {
  margin-bottom: 32px;
}

.demo-section-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 16px;
}

/* Doses */
.demo-doses {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.dose-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  transition: all var(--transition-smooth);
}

.dose-taken {
  opacity: 0.6;
}

.dose-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.dose-body {
  flex: 1;
}

.dose-name {
  display: block;
  font-weight: 600;
  font-size: var(--text-body);
  color: var(--color-text-primary);
}

.dose-time {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.dose-btn {
  padding: 8px 20px;
  border-radius: var(--radius-full);
  background: var(--gradient-cta);
  color: white;
  font-size: var(--text-sm);
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: opacity var(--transition-fast);
}

.dose-btn:hover {
  opacity: 0.9;
}

.dose-done {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: var(--text-sm);
  font-weight: 600;
  color: var(--color-success);
}

/* Events */
.demo-events {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.event-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
}

.event-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.event-body {
  flex: 1;
}

.event-name {
  display: block;
  font-weight: 600;
  color: var(--color-text-primary);
}

.event-date {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.event-badge {
  font-size: var(--text-xs);
  font-weight: 600;
  padding: 4px 10px;
  border-radius: var(--radius-full);
}

.badge--warning {
  background: rgba(233, 196, 106, 0.15);
  color: #C4930E;
}

.badge--info {
  background: rgba(139, 126, 200, 0.1);
  color: var(--color-primary);
}

.badge--neutral {
  background: var(--color-bg-alt);
  color: var(--color-text-secondary);
}

@media (max-width: 480px) {
  .demo-kpi-row {
    grid-template-columns: 1fr;
  }
}
</style>

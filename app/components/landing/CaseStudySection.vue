<template>
  <LandingUiSectionWrapper
    badge="Истории успеха"
    title="Реальные результаты клиник"
    subtitle="Как UMAI Health меняет показатели бизнеса"
    alternate
  >
    <div class="cases-grid" data-stagger="fade-up">
      <div v-for="cs in cases" :key="cs.clinic" class="case-card landing-card">
        <div class="case-header">
          <div class="case-logo" :style="{ background: cs.logoBg }">
            <Icon :name="cs.icon" class="case-logo-icon" />
          </div>
          <div>
            <h3 class="case-clinic">{{ cs.clinic }}</h3>
            <p class="case-location">{{ cs.location }}</p>
          </div>
        </div>

        <p class="case-story">{{ cs.story }}</p>

        <div class="case-metrics">
          <div v-for="m in cs.metrics" :key="m.label" class="metric-item">
            <div class="metric-row">
              <span class="metric-before">{{ m.before }}</span>
              <Icon name="lucide:arrow-right" class="metric-arrow" />
              <span class="metric-after font-display">{{ m.after }}</span>
            </div>
            <span class="metric-label">{{ m.label }}</span>
          </div>
        </div>

        <div class="case-timeline">
          <div class="timeline-label">
            <Icon name="lucide:clock" class="tl-icon" />
            Срок внедрения: <strong>{{ cs.timeline }}</strong>
          </div>
        </div>

        <button class="case-toggle" @click="cs.expanded = !cs.expanded">
          {{ cs.expanded ? 'Скрыть подробности' : 'Подробнее' }}
          <Icon :name="cs.expanded ? 'lucide:chevron-up' : 'lucide:chevron-down'" class="toggle-icon" />
        </button>

        <Transition name="expand">
          <div v-if="cs.expanded" class="case-details">
            <h4>Процесс внедрения</h4>
            <ol>
              <li v-for="step in cs.steps" :key="step">{{ step }}</li>
            </ol>
            <blockquote class="case-quote">
              <Icon name="lucide:quote" class="quote-icon" />
              {{ cs.quote }}
              <cite>— {{ cs.quoteAuthor }}</cite>
            </blockquote>
          </div>
        </Transition>
      </div>
    </div>
  </LandingUiSectionWrapper>
</template>

<script setup lang="ts">
import { reactive } from 'vue'

const cases = reactive([
  {
    clinic: 'Клиника «Мать и Дитя»',
    location: 'Алматы, Казахстан',
    icon: 'lucide:heart-pulse',
    logoBg: 'var(--gradient-cta)',
    story: 'Крупнейшая частная клиника материнства и детства Алматы. 3 филиала, 12 координаторов, 2000+ семей в год. До внедрения — 67% семей уходили после родов.',
    timeline: '3 недели',
    expanded: false,
    metrics: [
      { before: '33%', after: '61%', label: 'Удержание' },
      { before: '180K ₸', after: '540K ₸', label: 'Доход на семью' },
      { before: '40', after: '180', label: 'Семей на координатора' },
    ],
    steps: [
      'Демо и настройка клиники (2 дня)',
      'Брендинг под вашу клинику: логотип, цвета, маршруты (3 дня)',
      'Обучение 4 координаторов (1 день)',
      'Пилот на 25 семьях (4 недели)',
      'Масштабирование на все 3 филиала (2 недели)',
    ],
    quote: 'Мы наконец видим, на каком этапе каждая семья. Удержание выросло почти вдвое за 4 месяца.',
    quoteAuthor: 'Айгерим С., директор клиники',
  },
  {
    clinic: 'MedPark Family',
    location: 'Астана, Казахстан',
    icon: 'lucide:building-2',
    logoBg: 'linear-gradient(135deg, #A8C8E8, #8B7EC8)',
    story: 'Современный медицинский центр с фокусом на семейную медицину. 1 филиал, 5 координаторов, 800 семей в год. Проблема: хаос в WhatsApp и потеря документов.',
    timeline: '2 недели',
    expanded: false,
    metrics: [
      { before: '28%', after: '52%', label: 'Удержание' },
      { before: '0', after: '94%', label: 'Прививки вовремя' },
      { before: '6 ч/д', after: '1.5 ч/д', label: 'Время координатора' },
    ],
    steps: [
      'Онлайн демо и принятие решения (1 день)',
      'Настройка клиники + маршруты (2 дня)',
      'Обучение 5 координаторов (0.5 дня)',
      'Пилот на 15 семьях (3 недели)',
      'Полный запуск (1 неделя)',
    ],
    quote: 'Координаторы перестали тонуть в WhatsApp. Теперь каждая задача — в системе, с дедлайном и приоритетом.',
    quoteAuthor: 'Марат А., руководитель педиатрии',
  },
])
</script>

<style scoped>
.cases-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
}

.case-card {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.case-header {
  display: flex;
  align-items: center;
  gap: 14px;
}

.case-logo {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.case-logo-icon {
  width: 24px;
  height: 24px;
  color: white;
}

.case-clinic {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  color: var(--color-text-primary);
}

.case-location {
  font-size: 13px;
  color: var(--color-text-muted);
  margin: 0;
}

.case-story {
  font-size: 14px;
  line-height: 160%;
  color: var(--color-text-secondary);
  margin: 0;
}

.case-metrics {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.metric-item {
  text-align: center;
  padding: 12px 8px;
  background: var(--color-bg-alt);
  border-radius: var(--radius-sm);
}

.metric-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-bottom: 4px;
}

.metric-before {
  font-size: 14px;
  color: var(--color-text-muted);
  text-decoration: line-through;
}

.metric-arrow {
  width: 14px;
  height: 14px;
  color: var(--color-primary);
}

.metric-after {
  font-size: 20px;
  font-weight: 700;
  color: var(--color-primary);
}

.metric-label {
  font-size: 11px;
  color: var(--color-text-secondary);
}

.case-timeline {
  padding: 10px 16px;
  background: var(--color-primary-ultralight);
  border-radius: var(--radius-sm);
}

.timeline-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--color-text-secondary);
}

.tl-icon {
  width: 16px;
  height: 16px;
  color: var(--color-primary);
}

.case-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 20px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--color-primary);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);
  align-self: center;
}

.case-toggle:hover {
  background: var(--color-primary-light);
}

.toggle-icon {
  width: 16px;
  height: 16px;
}

.case-details {
  overflow: hidden;
}

.case-details h4 {
  font-size: 15px;
  font-weight: 600;
  margin: 0 0 12px;
  color: var(--color-text-primary);
}

.case-details ol {
  padding: 0 0 0 20px;
  margin: 0 0 16px;
}

.case-details li {
  font-size: 13px;
  line-height: 170%;
  color: var(--color-text-secondary);
  margin-bottom: 4px;
}

.case-quote {
  font-size: 14px;
  font-style: italic;
  line-height: 160%;
  color: var(--color-text-secondary);
  border-left: 3px solid var(--color-primary-light);
  padding: 12px 16px;
  margin: 0;
  background: var(--color-primary-ultralight);
  border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
  position: relative;
}

.quote-icon {
  width: 18px;
  height: 18px;
  color: var(--color-primary-light);
  display: block;
  margin-bottom: 6px;
}

.case-quote cite {
  display: block;
  margin-top: 8px;
  font-style: normal;
  font-weight: 600;
  font-size: 13px;
  color: var(--color-primary);
}

.expand-enter-active,
.expand-leave-active {
  transition: all 0.3s ease;
  max-height: 500px;
  opacity: 1;
}

.expand-enter-from,
.expand-leave-to {
  max-height: 0;
  opacity: 0;
}

@media (max-width: 768px) {
  .cases-grid {
    grid-template-columns: 1fr;
  }
  .case-metrics {
    grid-template-columns: 1fr;
  }
}
</style>

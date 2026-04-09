<template>
  <LandingUiSectionWrapper
    id="clinic-problems"
    badge="Проблема"
    title="Что теряет ваша клиника сегодня"
    alternate
  >
    <!-- Top: Pains with FLIP cards + BurningMoney -->
    <div class="problems-layout">
      <div class="pains-list" data-stagger="fade-up">
        <div
          v-for="pain in pains"
          :key="pain.title"
          class="pain-card"
          :class="{ 'is-flipped': flippedCards.has(pain.title) }"
          @mouseenter="flipCard(pain.title)"
          @mouseleave="unflipCard(pain.title)"
        >
          <!-- Front: problem -->
          <div class="pain-face pain-front">
            <Icon :name="pain.icon" size="24" class="pain-icon pain-icon--danger" />
            <h4 class="pain-title font-heading">{{ pain.title }}</h4>
            <p class="pain-desc">{{ pain.desc }}</p>
            <span class="pain-cost font-mono">{{ pain.cost }}</span>
          </div>
          <!-- Back: solution -->
          <div class="pain-face pain-back">
            <Icon :name="pain.solIcon" size="24" class="pain-icon pain-icon--success" />
            <h4 class="pain-title font-heading">{{ pain.solution }}</h4>
            <p class="pain-desc">{{ pain.solDesc }}</p>
          </div>
        </div>
      </div>

      <div class="burning-visual" data-reveal="fade-left">
        <LandingSvgBurningMoney />
      </div>
    </div>

    <!-- Bottom: Loss Funnel integrated -->
    <div class="funnel-section">
      <h3 class="funnel-heading font-heading" data-reveal="fade-up">Воронка потерь: от 100 семей остаётся 5</h3>

      <div class="funnel-visual" data-reveal="fade-up">
        <div v-for="(step, i) in funnelSteps" :key="step.label" class="funnel-step">
          <div
            class="funnel-bar"
            :style="{ width: `${step.width}%`, background: step.bg }"
          >
            <span class="funnel-count font-display">{{ step.count }}</span>
            <span class="funnel-label">{{ step.label }}</span>
          </div>
          <div v-if="i < funnelSteps.length - 1" class="funnel-loss">
            <Icon name="lucide:arrow-down" class="loss-arrow" />
            <span class="loss-text">−{{ step.loss }} семей: {{ step.lossReason }}</span>
          </div>
        </div>
      </div>

      <div class="revenue-loss" data-reveal="scale-in">
        <div class="loss-card landing-card">
          <Icon name="lucide:trending-down" class="loss-icon" />
          <div>
            <div class="loss-amount font-display">
              <LandingUiAnimatedCounter :target="43" suffix=" млн ₸/год" />
            </div>
            <p class="loss-desc">Потерянный доход средней клиники из-за оттока семей после родов</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Comparison table: Before vs After -->
    <div class="compare-section">
      <h3 class="compare-heading font-heading" data-reveal="fade-up">Как меняются метрики с платформой</h3>
      <div class="compare-table" data-reveal="fade-up">
        <div class="ct-row ct-header">
          <div class="ct-metric">Метрика</div>
          <div class="ct-before">Без платформы</div>
          <div class="ct-after">С Family Care OS</div>
        </div>
        <div v-for="row in compareRows" :key="row.metric" class="ct-row">
          <div class="ct-metric"><span class="ct-icon">{{ row.icon }}</span> {{ row.metric }}</div>
          <div class="ct-before"><span class="ct-val ct-val--bad">{{ row.before }}</span></div>
          <div class="ct-after">
            <span class="ct-val ct-val--good">{{ row.after }}</span>
            <span v-if="row.delta" class="ct-delta">{{ row.delta }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Day of coordinator Dinara -->
    <div class="day-section">
      <h3 class="day-heading font-heading" data-reveal="fade-up">День координатора Динары: до и после</h3>
      <div class="day-split" data-reveal="fade-up">
        <div class="day-column">
          <div class="day-label day-label--bad"><span class="day-emoji">😫</span> Без платформы</div>
          <div class="day-timeline">
            <div v-for="ev in dayWithout" :key="ev.time" class="dt-event">
              <span class="dt-time font-mono">{{ ev.time }}</span>
              <div class="dt-card" :class="'dt-' + ev.mood">
                <span class="dt-icon">{{ ev.icon }}</span>
                <div><strong class="dt-title">{{ ev.title }}</strong><p class="dt-desc">{{ ev.desc }}</p></div>
              </div>
            </div>
            <div class="day-result day-result--bad">
              <span class="result-label">Итог:</span> 4 семьи потеряны · 6 ч на звонки · 0 аналитики
            </div>
          </div>
        </div>
        <div class="day-divider"><div class="dv-line" /><span class="dv-vs font-display">VS</span><div class="dv-line" /></div>
        <div class="day-column">
          <div class="day-label day-label--good"><span class="day-emoji">😊</span> С платформой</div>
          <div class="day-timeline">
            <div v-for="ev in dayWith" :key="ev.time" class="dt-event">
              <span class="dt-time font-mono">{{ ev.time }}</span>
              <div class="dt-card" :class="'dt-' + ev.mood">
                <span class="dt-icon">{{ ev.icon }}</span>
                <div><strong class="dt-title">{{ ev.title }}</strong><p class="dt-desc">{{ ev.desc }}</p></div>
              </div>
            </div>
            <div class="day-result day-result--good">
              <span class="result-label">Итог:</span> 0 потерь · 1.5 ч экономии · KPI в реальном времени
            </div>
          </div>
        </div>
      </div>
    </div>
  </LandingUiSectionWrapper>
</template>

<script setup lang="ts">
const flippedCards = ref(new Set<string>())

function flipCard(title: string) {
  flippedCards.value.add(title)
  flippedCards.value = new Set(flippedCards.value)
}

function unflipCard(title: string) {
  flippedCards.value.delete(title)
  flippedCards.value = new Set(flippedCards.value)
}

const pains = [
  {
    title: 'Путь беременная → педиатрия',
    desc: '67% семей уходят после родов. Вы теряете 12–18 мес дохода каждой семьи.',
    cost: '–12-18 мес LTV',
    icon: 'lucide:user-x',
    solution: 'Автоматический маршрут',
    solDesc: 'Платформа ведёт семью от беременности через роды в педиатрию — без потерь.',
    solIcon: 'lucide:route',
  },
  {
    title: 'Контроль назначений',
    desc: 'Соблюдение назначений без системы ~45%. Пациенты пропускают прививки, анализы, витамины.',
    cost: '45% соблюдение, ↓NPS',
    icon: 'lucide:pill',
    solution: 'Умные назначения',
    solDesc: 'Ежедневные напоминания + подтверждения. Соблюдение растёт до 94%.',
    solIcon: 'lucide:check-circle',
  },
  {
    title: 'Координация вручную',
    desc: '50% времени координатора — обзвон и напоминания. 4+ часа в день на рутину.',
    cost: '–50% времени координатора',
    icon: 'lucide:phone-off',
    solution: 'Панель координатора',
    solDesc: 'Очередь задач с приоритетами. Координатор видит кого и зачем обзвонить.',
    solIcon: 'lucide:list-checks',
  },
  {
    title: 'Аналитика пациентов',
    desc: 'Нет данных для решений — удержание, соблюдение назначений, конверсия неизвестны. Решения «на глаз».',
    cost: 'Решения «на глаз»',
    icon: 'lucide:eye-off',
    solution: 'Аналитика',
    solDesc: 'Удержание, LTV, NPS — когортная аналитика для управленческих решений.',
    solIcon: 'lucide:bar-chart-3',
  },
  {
    title: 'Повторные визиты',
    desc: 'Каждый пропущенный визит — потеря 10–30K ₸. Клиника реактивна, а не проактивна.',
    cost: '–10-30K ₸ за пропуск',
    icon: 'lucide:calendar-x',
    solution: 'Умная запись',
    solDesc: 'Автозапись из маршрута, напоминания за 24ч и 2ч. Неявки снижаются на 40%.',
    solIcon: 'lucide:calendar-check',
  },
]

const funnelSteps = [
  { count: '100', label: 'Семей начинают наблюдение', width: 100, bg: 'var(--gradient-accent)', loss: 45, lossReason: 'уходят в 1 триместре' },
  { count: '55', label: 'Доходят до родов', width: 55, bg: 'linear-gradient(90deg, #E8E4F5, #E8A0BF)', loss: 22, lossReason: 'не возвращаются после выписки' },
  { count: '33', label: 'Остаются после родов', width: 33, bg: 'linear-gradient(90deg, #E8A0BF, #F2C4A0)', loss: 18, lossReason: 'теряются к 6 месяцам ребёнка' },
  { count: '15', label: 'Наблюдаются до года', width: 15, bg: 'linear-gradient(90deg, #F2C4A0, #D4727C)', loss: 10, lossReason: 'уходят после 1 года' },
  { count: '5', label: 'Остаются до 2 лет', width: 8, bg: 'rgba(212,114,124,0.3)' },
]

const compareRows = [
  { icon: '👨‍👩‍👦', metric: 'Retention семей (6 мес)', before: '33%', after: '87%', delta: '+54%' },
  { icon: '📞', metric: 'Время координатора на обзвоны', before: '4–6 ч/день', after: '1–1.5 ч/день', delta: '–70%' },
  { icon: '💉', metric: 'Вакцинация по графику', before: '45%', after: '98%', delta: '+53%' },
  { icon: '📊', metric: 'Видимость в аналитику', before: 'Excel / нет', after: 'Real-time дашборд', delta: '' },
  { icon: '💰', metric: 'LTV на семью (24 мес)', before: '~600K ₸', after: '~1.8M ₸', delta: '×3' },
  { icon: '⏱', metric: 'Время до первого визита', before: '3–5 дней', after: '< 2 часов', delta: '–80%' },
  { icon: '🔔', metric: 'Пропущенные визиты', before: '30–40%', after: '6%', delta: '–85%' },
]

const dayWithout = [
  { time: '08:00', icon: '📋', title: 'Открывает Excel', desc: 'Ищет кого обзвонить. 142 строки, без фильтров.', mood: 'bad' },
  { time: '09:00', icon: '📞', title: 'Обзвон вчерашних', desc: '20 номеров. 8 не берут. 3 ушли в другую клинику.', mood: 'bad' },
  { time: '10:30', icon: '😰', title: 'Вопрос от мамы', desc: '«Когда прививка?» — ищет карту 15 мин.', mood: 'bad' },
  { time: '12:00', icon: '📝', title: 'Ручная запись', desc: 'Звонит в регистратуру, ждёт окно. 5 мин на 1 запись.', mood: 'bad' },
  { time: '14:00', icon: '🤷', title: 'Потерянная семья', desc: 'Каримова А. не пришла на УЗИ 3 дня назад. Никто не заметил.', mood: 'bad' },
  { time: '16:00', icon: '📊', title: 'Отчёт', desc: '«Сколько семей?» — «Нужно посчитать...» Нет данных.', mood: 'bad' },
]

const dayWith = [
  { time: '08:00', icon: '💻', title: 'Открывает панель', desc: '2 просрочено, 4 сегодня, 8 завтра — всё на экране.', mood: 'good' },
  { time: '08:15', icon: '🔴', title: 'Просроченные', desc: 'Каримова А. — клик → звонок. 2 мин → записана.', mood: 'good' },
  { time: '09:00', icon: '🔔', title: 'Автоуведомления', desc: '12 семей получили push. 9 подтвердили. 0 звонков.', mood: 'good' },
  { time: '10:30', icon: '💬', title: 'Ответ маме', desc: 'Карта за 3 сек. АКДС через 2 недели. Ответ за 30 сек.', mood: 'good' },
  { time: '12:00', icon: '📅', title: 'Автозапись', desc: 'Клик «Записать» → окно выбрано → готово.', mood: 'good' },
  { time: '14:00', icon: '📊', title: 'Дашборд', desc: 'Retention 87%. Визиты 94%. NPS 4.8. PDF за 1 клик.', mood: 'good' },
]
</script>

<style scoped>
.problems-layout {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 48px;
  align-items: center;
}

.pains-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* FLIP card */
.pain-card {
  perspective: 800px;
  min-height: 120px;
  cursor: default;
}

.pain-face {
  padding: 20px;
  border-radius: var(--radius-lg);
  backface-visibility: hidden;
  transition: transform 0.5s ease;
}

.pain-front {
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
}

.pain-back {
  background: var(--color-primary-light);
  border: 1px solid var(--color-primary);
  position: absolute;
  inset: 0;
  transform: rotateY(180deg);
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.pain-card {
  position: relative;
}

.is-flipped .pain-front {
  transform: rotateY(180deg);
}

.is-flipped .pain-back {
  transform: rotateY(0deg);
}

.pain-icon {
  margin-bottom: 8px;
}

.pain-icon--danger {
  color: var(--color-danger);
}

.pain-icon--success {
  color: var(--color-success);
}

.pain-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 4px;
}

.pain-desc {
  font-size: 14px;
  line-height: 1.55;
  color: var(--color-text-secondary);
  margin: 0;
}

.pain-cost {
  display: inline-block;
  margin-top: 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--color-danger);
  letter-spacing: var(--tracking-wide);
}

.burning-visual {
  display: flex;
  justify-content: center;
}

/* ---- Funnel integrated ---- */
.funnel-section {
  margin-top: 64px;
  padding-top: 48px;
  border-top: 1px solid var(--color-border-light);
}

.funnel-heading {
  font-size: 24px;
  font-weight: 600;
  color: var(--color-text-primary);
  text-align: center;
  margin: 0 0 36px;
}

.funnel-visual {
  max-width: 700px;
  margin: 0 auto 40px;
}

.funnel-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 4px;
}

.funnel-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 14px 24px;
  border-radius: var(--radius-md);
  transition: transform var(--transition-fast);
  min-height: 48px;
}

.funnel-bar:hover {
  transform: scale(1.02);
}

.funnel-count {
  font-size: 22px;
  font-weight: 700;
  color: var(--color-text-primary);
}

.funnel-label {
  font-size: 13px;
  color: var(--color-text-secondary);
}

.funnel-loss {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 0;
}

.loss-arrow {
  width: 14px;
  height: 14px;
  color: var(--color-danger);
}

.loss-text {
  font-size: 12px;
  color: var(--color-danger);
  font-weight: 500;
}

.revenue-loss {
  margin-bottom: 0;
}

.loss-card {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px 32px;
  max-width: 600px;
  margin: 0 auto;
  border-left: 4px solid var(--color-danger);
}

.loss-icon {
  width: 32px;
  height: 32px;
  color: var(--color-danger);
  flex-shrink: 0;
}

.loss-amount {
  font-size: 26px;
  font-weight: 700;
  color: var(--color-danger);
  margin-bottom: 4px;
}

.loss-desc {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0;
  line-height: 150%;
}

@media (max-width: 768px) {
  .problems-layout {
    grid-template-columns: 1fr;
  }
  .burning-visual { order: -1; }
  .loss-card {
    flex-direction: column;
    text-align: center;
    padding: 20px;
  }
  .funnel-bar {
    padding: 10px 14px;
  }
  .funnel-count {
    font-size: 18px;
  }
}

/* ---- Comparison Table ---- */
.compare-section {
  margin-top: 64px;
  padding-top: 48px;
  border-top: 1px solid var(--color-border-light);
}
.compare-heading {
  font-size: 24px;
  font-weight: 600;
  color: var(--color-text-primary);
  text-align: center;
  margin: 0 0 32px;
}
.compare-table {
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--color-border);
  max-width: 800px;
  margin: 0 auto;
}
.ct-row {
  display: grid;
  grid-template-columns: 1.4fr 1fr 1.2fr;
}
.ct-row:not(:last-child) {
  border-bottom: 1px solid var(--color-border-light);
}
.ct-header {
  background: var(--color-primary-ultralight);
}
.ct-header > div {
  padding: 14px 20px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--color-text-secondary);
}
.ct-metric,
.ct-before,
.ct-after {
  padding: 14px 20px;
  font-size: 14px;
}
.ct-metric {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
  color: var(--color-text-primary);
}
.ct-icon { font-size: 18px; flex-shrink: 0; }
.ct-before { background: rgba(212, 114, 124, 0.04); }
.ct-after { display: flex; align-items: center; gap: 8px; }
.ct-val { font-weight: 600; }
.ct-val--bad { color: var(--color-danger); }
.ct-val--good { color: var(--color-primary); }
.ct-delta {
  font-size: 12px; font-weight: 700; padding: 2px 8px;
  border-radius: var(--radius-full);
  background: var(--color-primary-light); color: var(--color-primary);
}

/* ---- Day in Life ---- */
.day-section {
  margin-top: 64px;
  padding-top: 48px;
  border-top: 1px solid var(--color-border-light);
}
.day-heading {
  font-size: 24px;
  font-weight: 600;
  color: var(--color-text-primary);
  text-align: center;
  margin: 0 0 32px;
}
.day-split {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 24px;
  align-items: start;
}
.day-label {
  display: flex; align-items: center; gap: 8px;
  font-size: 16px; font-weight: 700;
  padding: 12px 20px; border-radius: var(--radius-sm); margin-bottom: 16px;
}
.day-label--bad { background: rgba(212, 114, 124, 0.08); color: var(--color-danger); }
.day-label--good { background: var(--color-primary-light); color: var(--color-primary); }
.day-emoji { font-size: 20px; }
.day-timeline { display: flex; flex-direction: column; gap: 10px; }
.dt-event { display: flex; gap: 10px; align-items: flex-start; }
.dt-time { flex-shrink: 0; width: 44px; font-size: 11px; color: var(--color-text-muted); padding-top: 10px; }
.dt-card {
  flex: 1; display: flex; gap: 10px; padding: 10px 14px;
  border-radius: var(--radius-sm); border: 1px solid var(--color-border-light);
  background: var(--color-surface);
}
.dt-card.dt-bad { border-left: 3px solid var(--color-danger); }
.dt-card.dt-good { border-left: 3px solid var(--color-success); }
.dt-icon { font-size: 18px; flex-shrink: 0; padding-top: 2px; }
.dt-title { font-size: 13px; color: var(--color-text-primary); display: block; margin-bottom: 2px; }
.dt-desc { font-size: 12px; color: var(--color-text-secondary); line-height: 1.5; margin: 0; }
.day-result {
  margin-top: 8px; padding: 12px 16px;
  border-radius: var(--radius-sm); font-size: 13px;
}
.day-result--bad { background: rgba(212, 114, 124, 0.06); border: 1px solid rgba(212, 114, 124, 0.15); }
.day-result--good { background: var(--color-primary-light); border: 1px solid rgba(139, 126, 200, 0.2); }
.result-label { font-weight: 700; color: var(--color-text-primary); margin-right: 4px; }
.day-divider { display: flex; flex-direction: column; align-items: center; gap: 8px; padding-top: 60px; }
.dv-line { width: 2px; height: 80px; background: linear-gradient(180deg, var(--color-border), var(--color-primary), var(--color-border)); }
.dv-vs { font-size: 18px; color: var(--color-primary); padding: 8px; }

@media (max-width: 900px) {
  .ct-row { grid-template-columns: 1fr; }
  .ct-header { display: none; }
  .ct-metric, .ct-before, .ct-after { padding: 8px 16px; }
  .ct-before::before { content: 'Без: '; font-size: 11px; color: var(--color-text-muted); }
  .ct-after::before { content: 'С платформой: '; font-size: 11px; color: var(--color-text-muted); }
  .day-split { grid-template-columns: 1fr; }
  .day-divider { flex-direction: row; padding-top: 0; padding: 16px 0; }
  .dv-line { width: 80px; height: 2px; }
}
</style>

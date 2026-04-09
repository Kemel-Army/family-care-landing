<template>
  <LandingUiSectionWrapper
    id="clinic-testimonials"
    badge="Кейсы клиник"
    title="Результаты, которые говорят сами"
    subtitle="Клиники, которые подключили платформу — и увидели разницу в цифрах"
    alternate
  >
    <div ref="gridRef" class="testimonials-grid" data-stagger="fade-up">
      <div v-for="t in testimonials" :key="t.clinic" class="tcard landing-card" data-tilt>
        <!-- KPI strip -->
        <div class="tcard-kpis">
          <div v-for="kpi in t.kpis" :key="kpi.label" class="tcard-kpi">
            <span class="kpi-val font-mono" :style="{ color: kpi.color }">{{ kpi.val }}</span>
            <span class="kpi-label">{{ kpi.label }}</span>
          </div>
        </div>
        <!-- Quote -->
        <blockquote class="tcard-quote">
          <span class="quote-mark">"</span>
          {{ t.quote }}
        </blockquote>
        <!-- Author -->
        <div class="tcard-author">
          <div class="author-avatar" :style="{ background: t.avatarBg }">
            {{ t.initials }}
          </div>
          <div>
            <strong class="author-name">{{ t.name }}</strong>
            <span class="author-role">{{ t.role }}</span>
          </div>
        </div>
        <!-- Clinic info -->
        <div class="tcard-clinic">
          <span class="clinic-name">{{ t.clinic }}</span>
          <span class="clinic-meta">{{ t.meta }}</span>
        </div>
      </div>
    </div>

    <!-- Bottom note -->
    <p class="testimonials-note" data-reveal="fade-up">
      * Ожидаемые результаты на основе пилотных данных. Имена анонимизированы.
    </p>
  </LandingUiSectionWrapper>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useGsap } from '~/composables/useGsap'

const { gsap, ScrollTrigger } = useGsap()
const gridRef = ref<HTMLElement | null>(null)

onMounted(() => {
  if (!gridRef.value) return
  // Stagger card entrance  
  const cards = gridRef.value.querySelectorAll('.tcard')
  gsap.fromTo(cards,
    { opacity: 0, y: 40, rotateX: 4 },
    { opacity: 1, y: 0, rotateX: 0, stagger: 0.15, duration: 0.7, ease: 'power3.out',
      scrollTrigger: { trigger: gridRef.value, start: 'top 85%', once: true } }
  )
  // Animate KPI values scale-in
  const kpis = gridRef.value.querySelectorAll('.kpi-val')
  gsap.fromTo(kpis,
    { scale: 0.5, opacity: 0 },
    { scale: 1, opacity: 1, stagger: 0.06, duration: 0.5, ease: 'back.out(1.7)', delay: 0.3,
      scrollTrigger: { trigger: gridRef.value, start: 'top 85%', once: true } }
  )
})
const testimonials = [
  {
    clinic: 'Частная клиника',
    meta: 'Алматы · 200+ семей/мес',
    name: 'А. Н.',
    role: 'Директор клиники',
    initials: 'АН',
    avatarBg: 'var(--color-primary-light)',
    quote:
      'Раньше мы теряли 60% семей после роддома. За 4 месяца retention вырос до 82%. Координаторы перестали сидеть на телефоне — панель задач заменила 40 звонков в день.',
    kpis: [
      { val: '82%', label: 'Retention', color: 'var(--color-primary)' },
      { val: '×3.2', label: 'LTV / семья', color: 'var(--color-primary-dark)' },
      { val: '–65%', label: 'Ручная работа', color: 'var(--color-success)' },
    ],
  },
  {
    clinic: 'Медицинский центр',
    meta: 'Астана · 120+ семей/мес',
    name: 'Д. С.',
    role: 'Координатор',
    initials: 'ДС',
    avatarBg: 'var(--color-secondary-light)',
    quote:
      'Я вела 90 семей в Excel и каждый день тратила 5 часов на обзвоны. Сейчас панель показывает кому звонить первым, а push-уведомления делают половину работы за меня. Я стала успевать домой к ужину.',
    kpis: [
      { val: '94%', label: 'Визиты по плану', color: 'var(--color-primary)' },
      { val: '1.5ч', label: 'Время на звонки', color: 'var(--color-success)' },
      { val: '98%', label: 'Вакцинация', color: 'var(--color-accent-blue)' },
    ],
  },
  {
    clinic: 'Перинатальный центр',
    meta: 'Шымкент · 300+ семей/мес',
    name: 'Б. О.',
    role: 'Зам. директора по развитию',
    initials: 'БО',
    avatarBg: 'var(--color-accent-blue-light)',
    quote:
      'ROI посчитали за 3 месяца пилота: платформа окупилась в 2.8 раза. Но главное — директор впервые видит retention в реальном времени. Больше не нужно просить «посчитайте вручную».',
    kpis: [
      { val: '280%', label: 'ROI за 3 мес', color: 'var(--color-primary)' },
      { val: '87%', label: 'Retention', color: 'var(--color-primary-dark)' },
      { val: '4.9', label: 'NPS', color: 'var(--color-accent-warm)' },
    ],
  },
]
</script>

<style scoped>
.testimonials-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.tcard {
  padding: 28px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  transition: transform 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94), box-shadow 0.4s ease;
}
.tcard:hover {
  box-shadow: var(--shadow-hover), 0 0 40px rgba(139, 126, 200, 0.06);
}

/* KPI strip */
.tcard-kpis {
  display: flex;
  gap: 16px;
}
.tcard-kpi {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.kpi-val {
  font-size: 22px;
  font-weight: 700;
  line-height: 1;
  transform-origin: center;
  display: inline-block;
}
.kpi-label {
  font-size: 11px;
  color: var(--color-text-muted);
  font-weight: 500;
}

/* Quote */
.tcard-quote {
  font-size: 14px;
  line-height: 1.65;
  color: var(--color-text-secondary);
  margin: 0;
  position: relative;
  padding-left: 0;
  flex: 1;
}
.quote-mark {
  font-family: 'Satoshi', serif;
  font-size: 48px;
  line-height: 0;
  position: relative;
  top: 16px;
  margin-right: 4px;
  background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  opacity: 0.6;
}

/* Author */
.tcard-author {
  display: flex;
  align-items: center;
  gap: 12px;
}
.author-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  color: var(--color-primary);
  flex-shrink: 0;
}
.author-name {
  display: block;
  font-size: 14px;
  color: var(--color-text-primary);
}
.author-role {
  display: block;
  font-size: 12px;
  color: var(--color-text-muted);
}

/* Clinic info */
.tcard-clinic {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid var(--color-border-light);
}
.clinic-name {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text-primary);
}
.clinic-meta {
  font-size: 11px;
  color: var(--color-text-muted);
}

/* Note */
.testimonials-note {
  text-align: center;
  font-size: 12px;
  color: var(--color-text-muted);
  margin-top: 32px;
}

/* Responsive */
@media (max-width: 1024px) {
  .testimonials-grid {
    grid-template-columns: 1fr;
    max-width: 600px;
    margin: 0 auto;
  }
}
</style>

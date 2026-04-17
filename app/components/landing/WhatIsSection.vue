<template>
  <LandingUiSectionWrapper
    id="what-is"
    badge="Платформа"
    title="Что такое UMAI Health"
    subtitle="Три ключевых возможности, которые меняют работу клиники с семьями"
    alternate
  >
    <div class="cards-grid" data-stagger="fade-up">
      <div
        v-for="card in cards"
        :key="card.title"
        class="product-card landing-card"
        data-tilt
        @mouseenter="card.onEnter"
        @mouseleave="card.onLeave"
      >
        <div class="card-svg-wrap" :ref="(el) => (card.svgRef.value = el as HTMLElement)">
          <!-- Journey Engine — path with running marker -->
          <svg v-if="card.id === 'journey'" viewBox="0 0 220 60" fill="none" class="card-svg">
            <path
              d="M10 50 Q55 50 55 30 Q55 10 110 10 Q165 10 165 30 Q165 50 210 50"
              stroke="var(--color-border)"
              stroke-width="2"
              fill="none"
            />
            <circle
              v-for="(cx, i) in [10, 55, 110, 165, 210]"
              :key="i"
              :cx="cx"
              :cy="[50, 30, 10, 30, 50][i]"
              r="4"
              :fill="card.color"
              opacity="0.3"
              class="milestone"
              :data-index="i"
            />
            <circle ref="journeyMarkerRef" cx="10" cy="50" r="5" :fill="card.color" class="marker" />
          </svg>

          <!-- Coordinator Panel — task list -->
          <svg v-if="card.id === 'coordinator'" viewBox="0 0 180 80" fill="none" class="card-svg">
            <g v-for="(task, i) in 3" :key="i" :class="`task-row task-row-${i}`">
              <rect :x="10" :y="8 + i * 26" width="130" height="20" rx="4" fill="var(--color-surface-hover)" />
              <text :x="18" :y="22 + i * 26" font-size="9" fill="var(--color-text-secondary)">{{ ['Осмотр 32 нед', 'Звонок Аида Т.', 'УЗИ результат'][i] }}</text>
              <circle :cx="158" :cy="18 + i * 26" r="6" stroke="var(--color-border)" stroke-width="1.5" fill="none" class="status-circle" :data-index="i" />
            </g>
          </svg>

          <!-- Family App — mini phone with scrolling content -->
          <svg v-if="card.id === 'app'" viewBox="0 0 100 140" fill="none" class="card-svg">
            <rect x="10" y="5" width="80" height="130" rx="12" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)" />
            <rect x="35" y="9" width="30" height="4" rx="2" fill="var(--color-border)" />
            <clipPath id="app-clip"><rect x="14" y="18" width="72" height="108" rx="4" /></clipPath>
            <g clip-path="url(#app-clip)">
              <g class="scroll-content">
                <rect x="18" y="22" width="64" height="16" rx="3" fill="var(--color-primary-light)" />
                <rect x="18" y="42" width="64" height="12" rx="3" fill="var(--color-surface-hover)" />
                <rect x="18" y="58" width="64" height="12" rx="3" fill="var(--color-surface-hover)" />
                <rect x="18" y="74" width="64" height="12" rx="3" fill="var(--color-surface-hover)" />
                <rect x="18" y="90" width="64" height="12" rx="3" fill="var(--color-secondary-light)" />
                <rect x="18" y="106" width="64" height="12" rx="3" fill="var(--color-surface-hover)" />
                <rect x="18" y="122" width="64" height="12" rx="3" fill="var(--color-surface-hover)" />
              </g>
            </g>
          </svg>
        </div>

        <div class="card-icon" :style="{ background: card.bg }">
          <Icon :name="card.icon" size="22" :style="{ color: card.color }" />
        </div>
        <h3 class="card-title font-heading">{{ card.title }}</h3>
        <p class="card-desc">{{ card.desc }}</p>
      </div>
    </div>
  </LandingUiSectionWrapper>
</template>

<script setup lang="ts">
const { gsap } = useGsap()

interface ProductCard {
  id: string
  icon: string
  title: string
  desc: string
  bg: string
  color: string
  svgRef: Ref<HTMLElement | null>
  onEnter: () => void
  onLeave: () => void
}

const journeySvgRef = ref<HTMLElement | null>(null)
const coordinatorSvgRef = ref<HTMLElement | null>(null)
const appSvgRef = ref<HTMLElement | null>(null)

const cards: ProductCard[] = [
  {
    id: 'journey',
    icon: 'lucide:route',
    title: 'Умный маршрут здоровья',
    desc: 'Платформа автоматически строит персональный план для каждой семьи: анализы, осмотры, прививки, назначения. 50+ событий за 2 секунды — ничего не нужно помнить.',
    bg: 'var(--color-primary-light)',
    color: 'var(--color-primary)',
    svgRef: journeySvgRef,
    onEnter: () => animateJourney(),
    onLeave: () => resetJourney(),
  },
  {
    id: 'coordinator',
    icon: 'lucide:smartphone',
    title: 'Всё в одном приложении',
    desc: 'Семья получает push-напоминания о витаминах и приёмах, записывается к врачу в одно касание, хранит все документы и анализы. Без звонков и WhatsApp-хаоса.',
    bg: 'var(--color-secondary-light)',
    color: 'var(--color-secondary)',
    svgRef: coordinatorSvgRef,
    onEnter: () => animateCoordinator(),
    onLeave: () => resetCoordinator(),
  },
  {
    id: 'app',
    icon: 'lucide:bar-chart-3',
    title: 'Полная видимость для клиники',
    desc: 'Координатор видит кто выпал из маршрута и кому пора звонить. Руководитель видит удержание, конверсию и доходность — каждый показатель в реальном времени.',
    bg: 'var(--color-accent-blue-light)',
    color: 'var(--color-accent-blue)',
    svgRef: appSvgRef,
    onEnter: () => animateApp(),
    onLeave: () => resetApp(),
  },
]

/* Journey Engine: marker runs along path, milestones light up */
function animateJourney() {
  const el = journeySvgRef.value
  if (!el || !gsap) return
  const path = el.querySelector('path') as SVGPathElement | null
  const marker = el.querySelector('.marker') as SVGCircleElement | null
  const milestones = el.querySelectorAll('.milestone')
  if (!path || !marker) return

  const length = path.getTotalLength()
  gsap.to({ t: 0 }, {
    t: 1,
    duration: 1.2,
    ease: 'power2.inOut',
    onUpdate() {
      const progress = this.targets()[0].t as number
      const pt = path.getPointAtLength(progress * length)
      gsap.set(marker, { attr: { cx: pt.x, cy: pt.y } })
      milestones.forEach((m, i) => {
        gsap.set(m, { opacity: progress >= (i / 4) ? 1 : 0.3 })
      })
    },
  })
}

function resetJourney() {
  const el = journeySvgRef.value
  if (!el || !gsap) return
  gsap.set(el.querySelector('.marker'), { attr: { cx: 10, cy: 50 } })
  el.querySelectorAll('.milestone').forEach(m => gsap.set(m, { opacity: 0.3 }))
}

/* Coordinator: top task slides out, others shift up */
function animateCoordinator() {
  const el = coordinatorSvgRef.value
  if (!el || !gsap) return
  const rows = el.querySelectorAll('.task-row')
  const circles = el.querySelectorAll('.status-circle')
  if (rows.length < 3) return

  // Checkmark top task
  gsap.to(circles[0]!, { attr: { fill: 'var(--color-primary)' }, duration: 0.2 })
  gsap.to(rows[0]!, { x: 30, opacity: 0, duration: 0.4, delay: 0.2 })
  // Shift remaining up
  gsap.to(rows[1]!, { y: -26, duration: 0.3, delay: 0.4 })
  gsap.to(rows[2]!, { y: -26, duration: 0.3, delay: 0.5 })
}

function resetCoordinator() {
  const el = coordinatorSvgRef.value
  if (!el || !gsap) return
  const rows = el.querySelectorAll('.task-row')
  const circles = el.querySelectorAll('.status-circle')
  gsap.to(rows, { x: 0, y: 0, opacity: 1, duration: 0.3 })
  gsap.to(circles, { attr: { fill: 'none' }, duration: 0.2 })
}

/* Family App: content scrolls up inside clip */
function animateApp() {
  const el = appSvgRef.value
  if (!el || !gsap) return
  const content = el.querySelector('.scroll-content')
  if (!content) return
  gsap.to(content, { y: -60, duration: 1.5, ease: 'power1.inOut' })
}

function resetApp() {
  const el = appSvgRef.value
  if (!el || !gsap) return
  const content = el.querySelector('.scroll-content')
  if (!content) return
  gsap.to(content, { y: 0, duration: 0.4, ease: 'power2.out' })
}
</script>

<style scoped>
.cards-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

@media (max-width: 1024px) {
  .cards-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

.product-card {
  padding: 0;
  overflow: hidden;
  cursor: default;
  transition: transform 0.3s var(--ease-out), box-shadow 0.3s;
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
}

.card-svg-wrap {
  background: var(--color-bg-alt);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px 20px;
  border-bottom: 1px solid var(--color-border-light);
  min-height: 160px;
}

.card-svg {
  width: 100%;
  max-width: 220px;
  height: 140px;
  object-fit: contain;
}

.card-icon {
  width: 44px;
  height: 44px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 24px 24px 12px;
}

.card-title {
  font-size: var(--text-card-title);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 24px 8px;
}

.card-desc {
  font-size: var(--text-sm);
  line-height: 1.55;
  color: var(--color-text-secondary);
  margin: 0 24px 24px;
}

@media (max-width: 768px) {
  .cards-grid {
    grid-template-columns: 1fr;
  }
}
</style>

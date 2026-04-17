<template>
  <section class="clinic-hero hero-gradient-mesh">
    <LandingUiGradientBlob
      top="-10%"
      left="-5%"
      size="500px"
      color="var(--color-primary-light)"
      :opacity="0.35"
      animated
      :duration="20"
      data-speed="-0.3"
    />

    <div class="clinic-hero-inner landing-container">
      <div class="clinic-hero-content">
        <span class="hero-overtitle font-heading" data-reveal="fade-up">ДЛЯ КЛИНИК И МЕДИЦИНСКИХ ЦЕНТРОВ</span>

        <h1 ref="clinicTitleRef" class="hero-title font-display">
          Семьи уходят после родов. Платформа&nbsp;их&nbsp;удерживает.
        </h1>

        <p class="hero-body" data-reveal="fade-up" data-reveal-delay="100">
          UMAI Health — платформа, названная в честь древней покровительницы матерей — превращает разовый визит в&nbsp;2&#8209;летний цифровой маршрут наблюдения. Больше повторных визитов, меньше ручной работы, полная видимость в&nbsp;аналитику.
        </p>

        <div class="hero-kpis" data-stagger="fade-up">
          <div v-for="kpi in kpis" :key="kpi.label" class="kpi-card">
            <span class="kpi-value font-display" :style="{ color: kpi.color }">{{ kpi.value }}</span>
            <span class="kpi-label">{{ kpi.label }}</span>
          </div>
        </div>

        <div class="hero-actions" data-reveal="fade-up" data-reveal-delay="300">
          <NuxtLink to="/demo" class="hero-cta-primary font-heading">
            Попробовать демо
            <Icon name="lucide:arrow-right" size="18" />
          </NuxtLink>
          <a href="#clinic-cta" class="hero-cta-secondary font-heading">
            Обсудить подключение
            <Icon name="lucide:message-circle" size="16" />
          </a>
        </div>
      </div>

      <div class="hero-visual" data-reveal="fade-left">
        <LandingSvgLossFunnel />
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const clinicTitleRef = ref<HTMLElement | null>(null)

const kpis = [
  { value: '50+', label: 'Событий в маршруте', color: 'var(--color-primary)' },
  { value: '3 роли', label: 'Мама · Координатор · Руководитель', color: 'var(--color-secondary)' },
  { value: 'White-label', label: 'Под брендом клиники', color: 'var(--color-accent-blue)' },
  { value: 'Real-time', label: 'Аналитика и дашборд', color: 'var(--color-accent-warm)' },
]

useSplitText(clinicTitleRef, {
  type: 'words',
  from: { y: '100%', opacity: 0, rotateX: -45 },
  stagger: 0.05,
  duration: 0.9,
  ease: 'power4.out',
  scroll: false,
  delay: 0.15,
})
</script>

<style scoped>
.clinic-hero {
  position: relative;
  overflow: hidden;
  padding: 140px 0 80px;
  min-height: 80vh;
  display: flex;
  align-items: center;
}

.clinic-hero-inner {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 48px;
  align-items: center;
  position: relative;
  z-index: 2;
}

.clinic-hero-content {
  max-width: 560px;
}

.hero-overtitle {
  display: inline-block;
  font-size: 13px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: var(--tracking-wide);
  color: var(--color-text-muted);
  margin-bottom: 16px;
}

.hero-title {
  font-size: clamp(32px, 5vw, 52px);
  font-weight: 900;
  line-height: 1.15;
  color: var(--color-text-primary);
  margin: 0 0 20px;
  letter-spacing: -0.02em;
}

.hero-body {
  font-size: var(--text-body-lg);
  line-height: 1.55;
  color: var(--color-text-secondary);
  margin: 0 0 32px;
  max-width: 520px;
}

.hero-kpis {
  display: flex;
  gap: 16px;
  margin-bottom: 32px;
  flex-wrap: wrap;
}

.kpi-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 20px;
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border-light);
  min-width: 120px;
}

.kpi-value {
  font-size: 28px;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.kpi-label {
  font-size: 13px;
  color: var(--color-text-secondary);
  margin-top: 4px;
  text-align: center;
}

.hero-actions {
  display: flex;
  gap: 16px;
  align-items: center;
}

.hero-cta-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 14px 32px;
  border-radius: var(--radius-full);
  background: var(--gradient-cta);
  color: white;
  font-size: 16px;
  font-weight: 600;
  text-decoration: none;
  transition: opacity 0.2s, transform 0.2s;
  box-shadow: 0 4px 20px rgba(139, 126, 200, 0.3);
}

.hero-cta-primary:hover {
  opacity: 0.92;
  transform: translateY(-1px);
}

.hero-cta-secondary {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 15px;
  font-weight: 600;
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: color 0.2s;
}

.hero-cta-secondary:hover {
  color: var(--color-primary);
}

.hero-visual {
  display: flex;
  justify-content: center;
}

@media (max-width: 1024px) {
  .clinic-hero-inner {
    grid-template-columns: 1fr;
    text-align: center;
  }
  .hero-body { margin-inline: auto; }
  .hero-kpis { justify-content: center; }
  .hero-actions { justify-content: center; }
  .hero-visual { order: -1; }
}

@media (max-width: 480px) {
  .clinic-hero { padding: 110px 0 64px; min-height: auto; }
  .kpi-card { min-width: 100px; }
  .hero-actions { flex-direction: column; }
}
</style>

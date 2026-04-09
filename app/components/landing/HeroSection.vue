<template>
  <section ref="heroRef" class="hero hero-gradient-mesh grain-overlay">
    <!-- Animated orbs -->
    <div class="hero-orbs" aria-hidden="true">
      <div class="orb orb-1" />
      <div class="orb orb-2" />
      <div class="orb orb-3" />
    </div>

    <div class="hero-inner landing-container">
      <div class="hero-content" ref="heroContentRef">
        <h1 ref="heroTitleRef" class="hero-title font-display">
          Family Care OS
        </h1>

        <p ref="heroSubRef" class="hero-subtitle font-body">
          Цифровая платформа сопровождения семьи от&nbsp;зачатия до&nbsp;2&nbsp;лет&nbsp;—
          <span class="hero-typewriter" :class="{ 'typewriter-active': isTyping, 'typewriter-done': isDone }">{{ displayText }}</span>
        </p>

        <div class="hero-stats">
          <div class="hero-stat">
            <span ref="stat1Ref" class="hero-stat-number font-display">87%</span>
            <span class="hero-stat-label">удержание семей</span>
          </div>
          <div class="hero-stat-divider" />
          <div class="hero-stat">
            <span ref="stat2Ref" class="hero-stat-number font-display">94%</span>
            <span class="hero-stat-label">соблюдение назначений</span>
          </div>
          <div class="hero-stat-divider" />
          <div class="hero-stat">
            <span ref="stat3Ref" class="hero-stat-number font-display">×4.2</span>
            <span class="hero-stat-label">рост LTV на семью</span>
          </div>
        </div>

        <!-- Smart segment banner -->
        <div class="hero-segment-banner">
          <NuxtLink to="/for-clinics" class="segment-link segment-link--clinic">
            <Icon name="lucide:building-2" size="16" />
            <span>Вы руководитель клиники?</span>
            <Icon name="lucide:arrow-right" size="14" class="segment-arrow" />
          </NuxtLink>
          <NuxtLink to="/for-families" class="segment-link segment-link--family">
            <Icon name="lucide:heart" size="16" />
            <span>Вы ждёте малыша?</span>
            <Icon name="lucide:arrow-right" size="14" class="segment-arrow" />
          </NuxtLink>
        </div>

        <div ref="heroActionsRef" class="hero-actions">
          <a href="#contact" class="hero-cta-primary font-heading btn-shimmer magnetic-btn">
            Запросить демо
            <Icon name="lucide:arrow-right" size="18" class="cta-arrow" />
          </a>
          <a href="#how-it-works" class="hero-cta-secondary font-heading magnetic-btn">
            Как это работает
            <Icon name="lucide:chevron-down" size="18" />
          </a>
        </div>

        <p class="hero-auth-hint font-body">
          Уже есть аккаунт?
          <NuxtLink to="/auth/login" class="hero-auth-link">Войти</NuxtLink>
          или
          <NuxtLink to="/auth/register" class="hero-auth-link">Зарегистрироваться</NuxtLink>
        </p>
      </div>

      <!-- ====== NEW: CSS 3D Phone + Floating Cards ====== -->
      <div
        ref="heroVisualRef"
        class="hero-visual"
        @mousemove="onMouseMove"
        @mouseleave="onMouseLeave"
      >
        <!-- Phone wrapper: CSS 3D perspective -->
        <div ref="phoneWrapperRef" class="phone-scene">
          <div ref="phoneBodyRef" class="phone-body">
            <!-- Glossy reflection overlay -->
            <div class="phone-gloss" />
            <!-- Phone frame -->
            <div class="phone-frame">
              <!-- Dynamic Island -->
              <div class="phone-island" />
              <!-- Screen content -->
              <div class="phone-screen" ref="phoneScreenRef">
                <!-- Status bar -->
                <div class="screen-statusbar">
                  <span class="statusbar-time font-mono">09:41</span>
                  <div class="statusbar-icons">
                    <Icon name="lucide:signal" size="10" />
                    <Icon name="lucide:wifi" size="10" />
                    <Icon name="lucide:battery-full" size="10" />
                  </div>
                </div>
                <!-- App header -->
                <div class="screen-header">
                  <span class="screen-title font-heading">Мой маршрут</span>
                  <span ref="weekBadgeRef" class="screen-week font-mono">{{ phoneWeek }} неделя</span>
                </div>
                <!-- Progress -->
                <div class="screen-progress">
                  <div class="progress-track">
                    <div ref="progressFillRef" class="progress-fill" />
                  </div>
                  <span class="progress-pct font-mono">68%</span>
                </div>
                <!-- Timeline items -->
                <div class="screen-items">
                  <div class="s-item">
                    <div class="s-item-icon s-item-icon--pill">
                      <Icon name="lucide:pill" size="13" />
                    </div>
                    <div class="s-item-body">
                      <span class="s-item-name">Витамин D3</span>
                      <span class="s-item-meta">Ежедневно, 08:00</span>
                    </div>
                    <span class="s-item-tag s-item-tag--action">Принять</span>
                  </div>
                  <div class="s-item">
                    <div class="s-item-icon s-item-icon--visit">
                      <Icon name="lucide:calendar" size="13" />
                    </div>
                    <div class="s-item-body">
                      <span class="s-item-name">Педиатр — осмотр</span>
                      <span class="s-item-meta">Завтра, 10:30</span>
                    </div>
                  </div>
                  <div class="s-item">
                    <div class="s-item-icon s-item-icon--lab">
                      <Icon name="lucide:flask-conical" size="13" />
                    </div>
                    <div class="s-item-body">
                      <span class="s-item-name">Анализ крови</span>
                      <span class="s-item-meta">Результат готов</span>
                    </div>
                    <span class="s-item-tag s-item-tag--new">Новый</span>
                  </div>
                  <div class="s-item">
                    <div class="s-item-icon s-item-icon--vaccine">
                      <Icon name="lucide:shield-check" size="13" />
                    </div>
                    <div class="s-item-body">
                      <span class="s-item-name">АКДС — 1-я доза</span>
                      <span class="s-item-meta">Через 5 дней</span>
                    </div>
                  </div>
                </div>
                <!-- Bottom nav -->
                <div class="screen-nav">
                  <div class="nav-item nav-item--active">
                    <Icon name="lucide:route" size="14" />
                    <span>Маршрут</span>
                  </div>
                  <div class="nav-item">
                    <Icon name="lucide:calendar-days" size="14" />
                    <span>Записи</span>
                  </div>
                  <div class="nav-item">
                    <Icon name="lucide:file-text" size="14" />
                    <span>Документы</span>
                  </div>
                  <div class="nav-item">
                    <Icon name="lucide:user" size="14" />
                    <span>Профиль</span>
                  </div>
                </div>
              </div>
            </div>
            <!-- Phone shadow (below phone, perspective-aware) -->
            <div class="phone-shadow" />
          </div>
        </div>

        <!-- Floating cards orbiting the phone -->
        <div ref="floatingNotifRef" class="hero-float hero-float--notif" data-speed="0.8">
          <div class="float-card glass-card">
            <div class="float-icon float-icon--bell">
              <Icon name="lucide:bell-ring" size="14" />
            </div>
            <div class="float-body">
              <span class="float-title">Напоминание</span>
              <span class="float-desc">Витамин D3 — 08:00</span>
            </div>
            <span class="float-badge">Принять</span>
          </div>
        </div>

        <div ref="floatingAdherenceRef" class="hero-float hero-float--adherence" data-speed="1.2">
          <div class="float-card glass-card">
            <div class="float-icon float-icon--chart">
              <Icon name="lucide:trending-up" size="14" />
            </div>
            <div class="float-body">
              <span class="float-title">Adherence</span>
              <div class="float-bar"><div class="float-bar-fill" /></div>
            </div>
            <span class="float-pct font-mono">94%</span>
          </div>
        </div>

        <div ref="floatingDocRef" class="hero-float hero-float--doc" data-speed="0.6">
          <div class="float-card glass-card">
            <div class="float-icon float-icon--doc">
              <Icon name="lucide:stethoscope" size="14" />
            </div>
            <div class="float-body">
              <span class="float-title">Др. Алия К.</span>
              <span class="float-desc">Педиатр · завтра</span>
            </div>
          </div>
        </div>

        <div ref="floatingVaccRef" class="hero-float hero-float--vacc" data-speed="1.0">
          <div class="float-card glass-card float-card--compact">
            <div class="float-icon float-icon--shield">
              <Icon name="lucide:shield-check" size="14" />
            </div>
            <span class="float-title">Прививки 6/18</span>
          </div>
        </div>

        <div ref="floatingAiRef" class="hero-float hero-float--ai" data-speed="0.9">
          <div class="float-card glass-card float-card--compact">
            <div class="float-icon float-icon--ai">
              <Icon name="lucide:sparkles" size="14" />
            </div>
            <span class="float-title">AI-помощник</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Scroll indicator -->
    <div ref="scrollIndicatorRef" class="scroll-indicator">
      <div class="scroll-mouse">
        <div class="scroll-wheel" />
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const heroRef = ref<HTMLElement | null>(null)
const heroContentRef = ref<HTMLElement | null>(null)
const heroVisualRef = ref<HTMLElement | null>(null)
const heroTitleRef = ref<HTMLElement | null>(null)
const heroSubRef = ref<HTMLElement | null>(null)
const heroActionsRef = ref<HTMLElement | null>(null)
const scrollIndicatorRef = ref<HTMLElement | null>(null)

// Counter-up refs
const stat1Ref = ref<HTMLElement | null>(null)
const stat2Ref = ref<HTMLElement | null>(null)
const stat3Ref = ref<HTMLElement | null>(null)

// Week badge ref
const weekBadgeRef = ref<HTMLElement | null>(null)

// Counter-up for hero stats
useCountUp(stat1Ref, 87, { suffix: '%', delay: 0.3 })
useCountUp(stat2Ref, 94, { suffix: '%', delay: 0.5 })
useCountUp(stat3Ref, 4.2, { prefix: '×', decimals: 1, delay: 0.7 })

// Typewriter for subtitle
const { displayText, isTyping, isDone } = useTypewriter(
  ['для клиник', 'для семей', 'для врачей'],
  { typeSpeed: 70, deleteSpeed: 40, pauseAfterType: 2500 }
)

// Reactive phone week counter
const phoneWeek = ref(16)

// Phone refs
const phoneWrapperRef = ref<HTMLElement | null>(null)
const phoneBodyRef = ref<HTMLElement | null>(null)
const phoneScreenRef = ref<HTMLElement | null>(null)
const progressFillRef = ref<HTMLElement | null>(null)

// Floating refs
const floatingNotifRef = ref<HTMLElement | null>(null)
const floatingAdherenceRef = ref<HTMLElement | null>(null)
const floatingDocRef = ref<HTMLElement | null>(null)
const floatingVaccRef = ref<HTMLElement | null>(null)
const floatingAiRef = ref<HTMLElement | null>(null)

// Mouse tracking state for 3D tilt
const mouseActive = ref(false)
const currentRotX = ref(0)
const currentRotY = ref(0)
const targetRotX = ref(0)
const targetRotY = ref(0)
let lerpRaf: number | null = null

const MAX_ROT_Y = 8
const MAX_ROT_X = 5
const LERP_SPEED = 0.08

function onMouseMove(e: MouseEvent) {
  if (!heroVisualRef.value) return
  const rect = heroVisualRef.value.getBoundingClientRect()
  // Normalize to [-1, 1]
  const nx = ((e.clientX - rect.left) / rect.width) * 2 - 1
  const ny = ((e.clientY - rect.top) / rect.height) * 2 - 1
  targetRotY.value = nx * MAX_ROT_Y
  targetRotX.value = -ny * MAX_ROT_X
  mouseActive.value = true
}

function onMouseLeave() {
  targetRotX.value = 0
  targetRotY.value = 0
  mouseActive.value = false
}

function lerpLoop() {
  const dx = targetRotX.value - currentRotX.value
  const dy = targetRotY.value - currentRotY.value

  if (Math.abs(dx) > 0.01 || Math.abs(dy) > 0.01) {
    currentRotX.value += dx * LERP_SPEED
    currentRotY.value += dy * LERP_SPEED
  } else {
    currentRotX.value = targetRotX.value
    currentRotY.value = targetRotY.value
  }

  if (phoneBodyRef.value) {
    phoneBodyRef.value.style.transform =
      `rotateY(${currentRotY.value}deg) rotateX(${currentRotX.value}deg)`
  }

  lerpRaf = requestAnimationFrame(lerpLoop)
}

// Split-text reveal for H1
useSplitText(heroTitleRef, {
  type: 'words',
  from: { y: '100%', opacity: 0, rotateX: -45 },
  stagger: 0.05,
  duration: 0.9,
  ease: 'power4.out',
  scroll: false,
  delay: 0.2,
})

// Subtitle — words, gentler
useSplitText(heroSubRef, {
  type: 'words',
  from: { y: '100%', opacity: 0 },
  stagger: 0.02,
  duration: 0.7,
  ease: 'power3.out',
  scroll: false,
  delay: 0.6,
})

onMounted(() => {
  if (!import.meta.client) return
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  const isDesktop = window.innerWidth >= 768

  // Start mouse lerp loop on desktop
  if (isDesktop && !reducedMotion) {
    lerpLoop()
  }

  if (reducedMotion) return

  const { gsap } = useGsap()
  const allFloats = [
    floatingNotifRef.value,
    floatingAdherenceRef.value,
    floatingDocRef.value,
    floatingVaccRef.value,
    floatingAiRef.value,
  ].filter(Boolean) as HTMLElement[]

  // ---- Master entrance timeline ----
  const masterTL = gsap.timeline({ defaults: { ease: 'power3.out' } })

  // 1. Phone slides up + fades in
  if (phoneWrapperRef.value) {
    gsap.set(phoneWrapperRef.value, { opacity: 0, y: 60 })
    masterTL.to(phoneWrapperRef.value, {
      opacity: 1,
      y: 0,
      duration: 0.9,
      ease: 'power3.out',
    }, 0)
  }

  // 2. Screen content wipe-in via clip-path
  if (phoneScreenRef.value) {
    gsap.set(phoneScreenRef.value, { clipPath: 'inset(100% 0 0 0)' })
    masterTL.to(phoneScreenRef.value, {
      clipPath: 'inset(0% 0 0 0)',
      duration: 0.8,
      ease: 'power3.inOut',
    }, 0.3)
  }

  // 3. Progress bar fill
  if (progressFillRef.value) {
    gsap.set(progressFillRef.value, { width: '0%' })
    masterTL.to(progressFillRef.value, {
      width: '68%',
      duration: 1.0,
      ease: 'power2.out',
    }, 0.8)
  }

  // 4. Floating cards pop in staggered
  allFloats.forEach((el, i) => {
    gsap.set(el, { scale: 0, opacity: 0 })
    masterTL.to(el, {
      scale: 1,
      opacity: 1,
      duration: 0.6,
      ease: 'back.out(1.7)',
    }, 0.7 + i * 0.12)
  })

  // 5. Phone glow pulse
  if (phoneBodyRef.value) {
    masterTL.fromTo(
      phoneBodyRef.value,
      { boxShadow: '0 20px 60px rgba(139, 126, 200, 0)' },
      {
        boxShadow: '0 20px 60px rgba(139, 126, 200, 0.18)',
        duration: 0.6,
        ease: 'power2.out',
      },
      1.0,
    )
  }

  // CTA buttons entrance
  if (heroActionsRef.value) {
    gsap.from(heroActionsRef.value, {
      opacity: 0,
      y: 30,
      duration: 0.8,
      delay: 0.8,
      ease: 'power3.out',
    })
  }

  // ---- Continuous floating animation on cards ----
  allFloats.forEach((el, i) => {
    gsap.to(el, {
      y: '+=12',
      duration: 2.4 + i * 0.4,
      repeat: -1,
      yoyo: true,
      ease: 'sine.inOut',
      delay: 1.5 + i * 0.15,
    })
  })

  // Scroll indicator fade
  if (scrollIndicatorRef.value) {
    gsap.from(scrollIndicatorRef.value, {
      opacity: 0,
      y: -10,
      duration: 0.5,
      delay: 1.4,
    })
  }

  // ScrollTrigger: phone timeline animation on scroll
  if (heroRef.value && isDesktop) {
    // Animate week counter from 16 to 24 on scroll
    const weekObj = { val: 16 }
    gsap.to(weekObj, {
      val: 24,
      duration: 1,
      ease: 'none',
      scrollTrigger: {
        trigger: heroRef.value,
        start: 'top top',
        end: '60% top',
        scrub: 1,
      },
      onUpdate: () => {
        phoneWeek.value = Math.round(weekObj.val)
      },
    })

    // Animate screen items appearing sequentially
    const screenItems = heroRef.value.querySelectorAll('.s-item')
    screenItems.forEach((item, i) => {
      gsap.from(item, {
        opacity: 0,
        x: -20,
        duration: 0.5,
        delay: 1.2 + i * 0.15,
        ease: 'power2.out',
      })
    })

    // Animate "Принять" button pulse on the vitamin item
    const actionTag = heroRef.value.querySelector('.s-item-tag--action')
    if (actionTag) {
      gsap.to(actionTag, {
        scale: 1.1,
        duration: 0.4,
        delay: 2.5,
        ease: 'power2.out',
        yoyo: true,
        repeat: 1,
      })
    }
  }

  // ScrollTrigger: hero parallax scroll-out
  if (heroRef.value && isDesktop) {
    const scrollTL = gsap.timeline({
      scrollTrigger: {
        trigger: heroRef.value,
        start: 'top top',
        end: 'bottom top',
        scrub: 0.8,
      },
    })
    if (heroContentRef.value) {
      scrollTL.to(heroContentRef.value, { y: -80, opacity: 0, ease: 'none' }, 0)
    }
    if (heroVisualRef.value) {
      scrollTL.to(heroVisualRef.value, { y: -40, scale: 0.92, opacity: 0, ease: 'none' }, 0)
    }
    if (scrollIndicatorRef.value) {
      scrollTL.to(scrollIndicatorRef.value, { opacity: 0, ease: 'none' }, 0)
    }
  }

  // Magnetic CTA buttons
  document.querySelectorAll<HTMLElement>('.magnetic-btn').forEach((btn) => {
    btn.addEventListener('mousemove', (e) => {
      const rect = btn.getBoundingClientRect()
      const x = e.clientX - rect.left - rect.width / 2
      const y = e.clientY - rect.top - rect.height / 2
      btn.style.transform = `translate(${x * 0.2}px, ${y * 0.2}px)`
    })
    btn.addEventListener('mouseleave', () => {
      btn.style.transform = 'translate(0, 0)'
      btn.style.transition = 'transform 0.4s cubic-bezier(0.22, 0.61, 0.36, 1)'
      setTimeout(() => { btn.style.transition = '' }, 400)
    })
  })
})

onBeforeUnmount(() => {
  if (lerpRaf) cancelAnimationFrame(lerpRaf)
})
</script>

<style scoped>
.hero {
  position: relative;
  overflow: hidden;
  padding: 80px 0 96px;
  min-height: 100vh;
  display: flex;
  align-items: center;
}

/* Animated gradient orbs */
.hero-orbs {
  position: absolute;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
}

.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  will-change: transform;
}

.orb-1 {
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(139, 126, 200, 0.25) 0%, transparent 70%);
  top: -10%;
  left: -10%;
  animation: orb-float-1 20s ease-in-out infinite;
}

.orb-2 {
  width: 500px;
  height: 500px;
  background: radial-gradient(circle, rgba(232, 160, 191, 0.2) 0%, transparent 70%);
  top: 30%;
  right: -15%;
  animation: orb-float-2 25s ease-in-out infinite;
}

.orb-3 {
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(168, 200, 232, 0.2) 0%, transparent 70%);
  bottom: -10%;
  left: 30%;
  animation: orb-float-3 22s ease-in-out infinite;
}

@keyframes orb-float-1 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(80px, 60px) scale(1.1); }
  66% { transform: translate(-40px, 30px) scale(0.95); }
}

@keyframes orb-float-2 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(-60px, -80px) scale(1.05); }
  66% { transform: translate(40px, 40px) scale(0.9); }
}

@keyframes orb-float-3 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(60px, -40px) scale(1.1); }
  66% { transform: translate(-80px, -20px) scale(0.95); }
}

/* Scroll indicator */
.scroll-indicator {
  position: absolute;
  bottom: 32px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 3;
}

.scroll-mouse {
  width: 24px;
  height: 38px;
  border: 2px solid var(--color-text-muted);
  border-radius: 12px;
  display: flex;
  justify-content: center;
  padding-top: 8px;
  opacity: 0.5;
}

.scroll-wheel {
  width: 3px;
  height: 8px;
  border-radius: 2px;
  background: var(--color-primary);
  animation: scroll-wheel-pulse 1.8s ease-in-out infinite;
}

@keyframes scroll-wheel-pulse {
  0% { opacity: 1; transform: translateY(0); }
  50% { opacity: 0.3; transform: translateY(8px); }
  100% { opacity: 1; transform: translateY(0); }
}

/* ---- Layout ---- */
.hero-inner {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
  align-items: center;
  position: relative;
  z-index: 2;
}

.hero-content {
  max-width: 560px;
}

.hero-title {
  font-size: var(--text-hero);
  font-weight: 900;
  line-height: var(--leading-tight);
  color: var(--color-primary);
  margin: 0 0 16px;
  letter-spacing: var(--tracking-tight);
  text-indent: 0;
  padding-left: 0;
}

/* Gradient text — applied to inner spans created by useSplitText */
.hero-title :deep(span > span) {
  background: var(--gradient-cta);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: var(--text-body-lg);
  line-height: var(--leading-normal);
  color: var(--color-text-secondary);
  margin: 0 0 28px;
  max-width: 520px;
  text-indent: 0;
  padding-left: 0;
}

/* Hero stats row */
.hero-stats {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 32px;
  padding: 16px 0;
}

.hero-stat {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.hero-stat-number {
  font-size: clamp(1.25rem, 2vw, 1.75rem);
  font-weight: 800;
  color: var(--color-primary);
  line-height: 1.1;
}

.hero-stat-label {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  white-space: nowrap;
}

.hero-stat-divider {
  width: 1px;
  height: 32px;
  background: var(--color-border);
  flex-shrink: 0;
}

.hero-actions {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
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
  transition: opacity 0.2s, box-shadow 0.2s;
  box-shadow: 0 4px 20px rgba(139, 126, 200, 0.3);
  will-change: transform;
}

.hero-cta-primary:hover {
  opacity: 0.92;
  box-shadow: 0 6px 28px rgba(139, 126, 200, 0.4);
}

.hero-cta-secondary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 14px 32px;
  border-radius: var(--radius-full);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  color: var(--color-text-primary);
  font-size: 16px;
  font-weight: 600;
  text-decoration: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  will-change: transform;
}

.hero-cta-secondary:hover {
  border-color: var(--color-primary);
  box-shadow: 0 2px 12px rgba(139, 126, 200, 0.15);
}

/* Typewriter in subtitle */
.hero-typewriter {
  color: var(--color-primary);
  font-weight: 600;
}

/* Smart segment banner */
.hero-segment-banner {
  display: flex;
  gap: 12px;
  margin-bottom: 28px;
}

.segment-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: var(--radius-sm);
  font-size: var(--text-sm);
  font-weight: 500;
  text-decoration: none;
  transition: background var(--transition-fast), border-color var(--transition-fast);
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  color: var(--color-text-primary);
}

.segment-link:hover {
  border-color: var(--color-primary);
  background: var(--color-primary-ultralight);
}

.segment-link--clinic .iconify {
  color: var(--color-primary);
}

.segment-link--family .iconify {
  color: var(--color-secondary);
}

.segment-arrow {
  opacity: 0;
  transform: translateX(-4px);
  transition: opacity var(--transition-fast), transform var(--transition-fast);
}

.segment-link:hover .segment-arrow {
  opacity: 1;
  transform: translateX(0);
}

/* Auth hint below CTA */
.hero-auth-hint {
  margin-top: 16px;
  font-size: 0.875rem;
  color: var(--color-text-muted);
}

.hero-auth-link {
  color: var(--color-primary);
  font-weight: 600;
  text-decoration: none;
  transition: color var(--transition-fast);
}

.hero-auth-link:hover {
  text-decoration: underline;
}

.cta-arrow {
  transition: transform 0.2s;
}

.hero-cta-primary:hover .cta-arrow {
  transform: translateX(3px);
}

/* ============================================
   CSS 3D Phone
   ============================================ */
.hero-visual {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 540px;
  perspective: 1200px;
}

.phone-scene {
  position: relative;
  z-index: 2;
}

.phone-body {
  position: relative;
  transform-style: preserve-3d;
  will-change: transform;
  transition: box-shadow 0.6s ease;
  border-radius: 44px;
}

.phone-frame {
  position: relative;
  width: 280px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 44px;
  padding: 12px;
  box-shadow:
    0 1px 0 rgba(139, 126, 200, 0.06),
    0 8px 30px rgba(139, 126, 200, 0.12),
    0 20px 60px rgba(139, 126, 200, 0.08),
    inset 0 1px 0 rgba(255, 255, 255, 0.8);
  overflow: hidden;
}

/* Dynamic Island */
.phone-island {
  width: 90px;
  height: 26px;
  background: #2a2a2c;
  border-radius: 20px;
  margin: 2px auto 8px;
}

/* Glossy reflection overlay */
.phone-gloss {
  position: absolute;
  inset: 0;
  border-radius: 44px;
  background: linear-gradient(
    135deg,
    rgba(255, 255, 255, 0.18) 0%,
    rgba(255, 255, 255, 0.04) 40%,
    transparent 60%
  );
  pointer-events: none;
  z-index: 10;
}

/* Phone shadow — sits below phone in 3D space */
.phone-shadow {
  position: absolute;
  bottom: -16px;
  left: 10%;
  right: 10%;
  height: 40px;
  background: radial-gradient(ellipse, rgba(139, 126, 200, 0.18) 0%, transparent 70%);
  filter: blur(12px);
  transform: translateZ(-20px);
  pointer-events: none;
}

/* ---- Phone Screen Content ---- */
.phone-screen {
  background: var(--color-bg-alt);
  border-radius: 32px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.screen-statusbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 16px 4px;
  font-size: 10px;
  color: var(--color-text-muted);
}

.statusbar-time {
  font-weight: 600;
  font-size: 11px;
  color: var(--color-text-secondary);
}

.statusbar-icons {
  display: flex;
  gap: 4px;
  color: var(--color-text-muted);
}

.screen-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 16px 8px;
}

.screen-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--color-text-primary);
}

.screen-week {
  font-size: 10px;
  color: var(--color-primary);
  background: var(--color-primary-light);
  padding: 3px 10px;
  border-radius: var(--radius-full);
  font-weight: 600;
}

.screen-progress {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 16px 10px;
}

.progress-track {
  flex: 1;
  height: 5px;
  background: var(--color-border-light);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  width: 68%;
  background: var(--gradient-cta);
  border-radius: 3px;
}

.progress-pct {
  font-size: 11px;
  color: var(--color-primary);
  font-weight: 700;
}

/* Screen items */
.screen-items {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 0 10px 8px;
}

.s-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 8px;
  border-radius: 12px;
  background: var(--color-surface);
  border: 1px solid var(--color-border-light);
}

.s-item-icon {
  width: 30px;
  height: 30px;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: white;
}

.s-item-icon--pill { background: var(--color-primary); }
.s-item-icon--visit { background: var(--color-secondary); }
.s-item-icon--lab { background: var(--color-accent-blue); }
.s-item-icon--vaccine { background: var(--color-success); }

.s-item-body {
  flex: 1;
  min-width: 0;
}

.s-item-name {
  display: block;
  font-size: 11.5px;
  font-weight: 600;
  color: var(--color-text-primary);
  line-height: 1.3;
}

.s-item-meta {
  font-size: 9.5px;
  color: var(--color-text-muted);
}

.s-item-tag {
  font-size: 9px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: var(--radius-full);
  white-space: nowrap;
  flex-shrink: 0;
}

.s-item-tag--action {
  background: var(--color-primary-light);
  color: var(--color-primary);
}

.s-item-tag--new {
  background: var(--color-secondary-light);
  color: var(--color-secondary-dark);
}

/* Bottom nav */
.screen-nav {
  display: flex;
  justify-content: space-around;
  padding: 8px 4px 10px;
  border-top: 1px solid var(--color-border-light);
  background: var(--color-surface);
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  font-size: 8.5px;
  color: var(--color-text-muted);
  font-weight: 500;
}

.nav-item--active {
  color: var(--color-primary);
}

/* ============================================
   Floating cards
   ============================================ */
.hero-float {
  position: absolute;
  z-index: 3;
  pointer-events: none;
}

.hero-float--notif {
  top: 4%;
  right: -2%;
}

.hero-float--adherence {
  bottom: 12%;
  left: -6%;
}

.hero-float--doc {
  top: 32%;
  left: -12%;
}

.hero-float--vacc {
  bottom: 4%;
  right: -4%;
}

.hero-float--ai {
  top: 14%;
  left: 2%;
}

.float-card {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  border-radius: 14px;
  font-size: 12px;
  white-space: nowrap;
  background: rgba(255, 255, 255, 0.72);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(139, 126, 200, 0.12);
  box-shadow: 0 4px 20px rgba(139, 126, 200, 0.1);
}

.float-card--compact {
  padding: 7px 12px;
  gap: 6px;
}

.float-icon {
  width: 26px;
  height: 26px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: white;
}

.float-icon--bell { background: var(--color-primary); }
.float-icon--chart { background: var(--color-success); }
.float-icon--doc { background: var(--color-secondary); }
.float-icon--shield { background: var(--color-accent-blue); }
.float-icon--ai { background: linear-gradient(135deg, var(--color-primary), var(--color-secondary)); }

.float-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.float-title {
  font-size: 11px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.float-desc {
  font-size: 9.5px;
  color: var(--color-text-muted);
}

.float-badge {
  padding: 3px 9px;
  border-radius: var(--radius-full);
  background: var(--color-primary-light);
  color: var(--color-primary);
  font-size: 10px;
  font-weight: 600;
}

.float-pct {
  font-size: 13px;
  font-weight: 700;
  color: var(--color-success);
}

.float-bar {
  width: 48px;
  height: 4px;
  border-radius: 2px;
  background: var(--color-border-light);
  overflow: hidden;
}

.float-bar-fill {
  width: 94%;
  height: 100%;
  border-radius: 2px;
  background: var(--gradient-cta);
}

/* ---- Idle float animation (CSS fallback) ---- */
@media (prefers-reduced-motion: no-preference) {
  .phone-body {
    animation: phone-idle-float 5s ease-in-out infinite;
  }
}

@keyframes phone-idle-float {
  0%, 100% { transform: translateY(0) rotateY(0deg) rotateX(0deg); }
  50% { transform: translateY(-8px) rotateY(0deg) rotateX(0deg); }
}

/* ---- Responsive ---- */
@media (max-width: 1024px) {
  .hero-inner {
    grid-template-columns: 1fr;
    gap: 48px;
    text-align: center;
  }
  .hero-content { max-width: 100%; }
  .hero-subtitle { margin-left: auto; margin-right: auto; }
  .hero-stats { justify-content: center; }
  .hero-actions { justify-content: center; }
  .hero-segment-banner { justify-content: center; }
  .hero-visual { order: -1; min-height: 440px; }
  .hero-float--doc { left: -4%; }
  .hero-float--adherence { left: 0; }
  .hero-float--ai { left: 6%; }
}

@media (max-width: 768px) {
  .hero-visual {
    min-height: 400px;
    perspective: none;
  }
  .phone-body {
    animation: none !important;
    transform: none !important;
  }
  .phone-gloss { display: none; }
  .phone-frame { width: 260px; }
  /* Keep only 2 floating cards on mobile */
  .hero-float--doc,
  .hero-float--vacc,
  .hero-float--ai { display: none; }
  .hero-float--notif { top: 2%; right: 0; }
  .hero-float--adherence { bottom: 2%; left: 0; }
}

@media (max-width: 480px) {
  .hero {
    padding: 110px 0 64px;
    min-height: auto;
  }
  .hero-visual { min-height: 360px; }
  .phone-frame { width: 240px; }
  .hero-stats {
    flex-wrap: wrap;
    gap: 12px;
    justify-content: flex-start;
  }
  .hero-stat-divider { display: none; }
  .hero-actions {
    flex-direction: column;
    align-items: stretch;
  }
  .hero-cta-primary,
  .hero-cta-secondary {
    justify-content: center;
  }
  .hero-float { display: none; }
  .hero-segment-banner {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>

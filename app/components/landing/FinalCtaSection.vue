<template>
  <section id="contact" ref="sectionRef" class="final-cta-section">
    <div class="landing-container">
      <div ref="cardRef" class="cta-card landing-card">
        <div class="cta-content">
          <span class="cta-badge font-heading">Начните сейчас</span>
          <h2 ref="titleRef" class="cta-title font-display">Готовы увидеть платформу в действии?</h2>
          <p ref="descRef" class="cta-desc">Оставьте заявку — мы покажем демо на примере реального маршрута за 30 минут. Бесплатно, без обязательств.</p>

          <form ref="formRef" class="cta-form" @submit.prevent="handleSubmit">
            <div class="form-row">
              <input
                v-model="form.name"
                type="text"
                placeholder="Ваше имя"
                required
                class="cta-input"
              />
              <input
                v-model="form.contact"
                type="text"
                placeholder="Email или телефон"
                required
                class="cta-input"
              />
              <button type="submit" class="cta-submit btn-shimmer" :disabled="submitted">
                <template v-if="!submitted">
                  Запросить демо
                  <Icon name="lucide:arrow-right" size="18" />
                </template>
                <template v-else>
                  <Icon name="lucide:check" size="18" />
                  Отправлено
                </template>
              </button>
            </div>
            <p class="form-note">Демо 30 минут · Настройка за 1 день · Пилот на 10-20 семей</p>
          </form>
        </div>

        <!-- Animated decorative blobs -->
        <div class="cta-decor cta-decor--1" />
        <div class="cta-decor cta-decor--2" />
        <div class="cta-decor cta-decor--3" />
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { gsap, ScrollTrigger } = useGsap()

const form = reactive({ name: '', contact: '' })
const submitted = ref(false)

const sectionRef = ref<HTMLElement | null>(null)
const cardRef = ref<HTMLElement | null>(null)
const titleRef = ref<HTMLElement | null>(null)
const descRef = ref<HTMLElement | null>(null)
const formRef = ref<HTMLElement | null>(null)

useSplitText(titleRef, {
  type: 'words',
  from: { y: '100%', opacity: 0, rotateX: -60 },
  stagger: 0.05,
  duration: 0.7,
  ease: 'back.out(1.4)',
  scrollStart: 'top 80%',
})

onMounted(() => {
  if (!gsap || !ScrollTrigger || !sectionRef.value) return

  // Card entrance with clip reveal
  gsap.set(cardRef.value, { clipPath: 'inset(8% 8% 8% 8% round 24px)', opacity: 0, scale: 0.95 })
  
  ScrollTrigger.create({
    trigger: sectionRef.value,
    start: 'top 75%',
    once: true,
    onEnter: () => {
      gsap.to(cardRef.value!, {
        clipPath: 'inset(0% 0% 0% 0% round 16px)',
        opacity: 1,
        scale: 1,
        duration: 0.9,
        ease: 'power3.out',
      })

      // Desc and form fade in
      gsap.fromTo([descRef.value, formRef.value],
        { opacity: 0, y: 20 },
        { opacity: 1, y: 0, duration: 0.6, stagger: 0.15, ease: 'power2.out', delay: 0.4 },
      )
    },
  })

  // Floating blob animation
  const decors = cardRef.value?.querySelectorAll('.cta-decor')
  if (decors?.length) {
    decors.forEach((blob, i) => {
      gsap.to(blob, {
        x: `random(-20, 20)`,
        y: `random(-20, 20)`,
        duration: 4 + i * 0.5,
        ease: 'sine.inOut',
        repeat: -1,
        yoyo: true,
      })
    })
  }
})

async function handleSubmit() {
  try {
    await $fetch('/api/demo-request', {
      method: 'POST',
      body: { name: form.name, contact: form.contact, source: 'landing-final' },
    })
    submitted.value = true
  }
  catch {
    submitted.value = true
  }
}
</script>

<style scoped>
.final-cta-section {
  padding: var(--section-py) 0;
}

.cta-card {
  position: relative;
  overflow: hidden;
  text-align: center;
  padding: 64px 40px;
  background: var(--gradient-accent);
  border-radius: var(--radius-xl);
  will-change: clip-path, opacity, transform;
}

.cta-content {
  position: relative;
  z-index: 1;
  max-width: 600px;
  margin: 0 auto;
}

.cta-badge {
  display: inline-block;
  padding: 4px 14px;
  border-radius: var(--radius-full);
  background: rgba(139, 126, 200, 0.12);
  color: var(--color-primary);
  font-size: var(--text-xs);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: var(--tracking-wide);
  margin-bottom: 16px;
}

.cta-title {
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 12px;
}

.cta-desc {
  font-size: var(--text-body-lg);
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin: 0 0 32px;
}

.cta-form {
  max-width: 540px;
  margin: 0 auto;
}

.form-row {
  display: flex;
  gap: 10px;
  margin-bottom: 12px;
}

.cta-input {
  flex: 1;
  padding: 12px 16px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  background: var(--color-surface);
  font-size: var(--text-sm);
  font-family: inherit;
  color: var(--color-text-primary);
  transition: border-color var(--transition-base);
}

.cta-input:focus {
  outline: none;
  border-color: var(--color-primary);
}

.cta-input::placeholder {
  color: var(--color-text-muted);
}

.cta-submit {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border: none;
  border-radius: var(--radius-md);
  background: var(--color-primary);
  color: white;
  font-size: var(--text-sm);
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  transition: background var(--transition-base), transform var(--transition-base);
  white-space: nowrap;
}

.cta-submit:hover:not(:disabled) {
  background: var(--color-primary-dark);
  transform: translateY(-1px);
}

.cta-submit:disabled {
  opacity: 0.7;
  cursor: default;
}

.form-note {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  margin: 0;
}

/* Decorative blobs */
.cta-decor {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
}

.cta-decor--1 {
  width: 200px;
  height: 200px;
  background: var(--color-secondary-light);
  opacity: 0.4;
  top: -60px;
  right: -40px;
  filter: blur(60px);
}

.cta-decor--2 {
  width: 160px;
  height: 160px;
  background: var(--color-accent-blue-light);
  opacity: 0.35;
  bottom: -40px;
  left: -30px;
  filter: blur(50px);
}

.cta-decor--3 {
  width: 120px;
  height: 120px;
  background: var(--color-primary-light);
  opacity: 0.3;
  bottom: 20%;
  right: 20%;
  filter: blur(45px);
}

@media (max-width: 768px) {
  .cta-card {
    padding: 40px 24px;
  }

  .form-row {
    flex-direction: column;
  }

  .cta-submit {
    width: 100%;
    justify-content: center;
  }
}
</style>

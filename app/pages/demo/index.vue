<template>
  <div class="demo-page">
    <!-- Ambient blobs -->
    <div class="demo-ambient" aria-hidden="true">
      <div class="blob blob-1" />
      <div class="blob blob-2" />
    </div>

    <div class="demo-container landing-container">
      <div class="demo-header">
        <NuxtLink to="/" class="demo-back font-heading">
          <Icon name="lucide:arrow-left" size="16" />
          На главную
        </NuxtLink>
        <h1 class="demo-title font-display">Попробуйте платформу</h1>
        <p class="demo-subtitle">
          Выберите роль — и изучите интерфейс с&nbsp;тестовыми данными. Регистрация не&nbsp;нужна.
        </p>
      </div>

      <div class="demo-roles">
        <button
          v-for="role in roles"
          :key="role.key"
          class="demo-role-card"
          :class="{ 'is-loading': loadingRole === role.key }"
          :disabled="!!loadingRole"
          @click="enterDemo(role.key)"
        >
          <div class="role-icon" :style="{ background: role.gradient }">
            <Icon :name="role.icon" size="32" />
          </div>
          <div class="role-body">
            <h2 class="role-title font-heading">{{ role.title }}</h2>
            <p class="role-desc">{{ role.description }}</p>
            <ul class="role-features">
              <li v-for="f in role.features" :key="f">
                <Icon name="lucide:check" size="14" class="feature-check" />
                {{ f }}
              </li>
            </ul>
          </div>
          <div class="role-action">
            <span v-if="loadingRole === role.key" class="role-spinner" />
            <template v-else>
              Войти как {{ role.actionLabel }}
              <Icon name="lucide:arrow-right" size="16" />
            </template>
          </div>
        </button>
      </div>

      <p v-if="error" class="demo-error">{{ error }}</p>

      <p class="demo-hint">
        Аналогичный кабинет доступен для второго родителя (папа, бабушка).
      </p>

      <div class="demo-footer-cta">
        <p>Хотите обсудить подключение для вашей клиники?</p>
        <NuxtLink to="/for-clinics#clinic-cta" class="demo-cta-link font-heading">
          Оставить заявку
          <Icon name="lucide:arrow-right" size="16" />
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'landing' })

useSeoMeta({
  title: 'Попробовать демо — Family Care OS',
  description: 'Изучите платформу Family Care OS с тестовыми данными. Выберите роль: мама, координатор или руководитель.',
})

const supabase = useSupabaseClient()
const authStore = useAuthStore()
const loadingRole = ref<string | null>(null)
const error = ref('')

const DEMO_HOME: Record<string, string> = {
  mom: '/demo/family',
  coordinator: '/demo/coordinator',
  doctor: '/demo/doctor',
  admin: '/demo/coordinator', // admin shares coordinator view in demo
}

const roles = [
  {
    key: 'mom',
    icon: 'lucide:heart',
    title: 'Мама / Родитель',
    description: 'Маршрут ребёнка, напоминания, документы, прививки.',
    gradient: 'linear-gradient(135deg, var(--color-secondary), var(--color-accent-warm))',
    features: ['Маршрут от беременности до 2 лет', 'Напоминания о витаминах', 'Календарь прививок', 'Хранение документов'],
    actionLabel: 'мама',
  },
  {
    key: 'coordinator',
    icon: 'lucide:clipboard-list',
    title: 'Координатор клиники',
    description: 'Очередь задач, список семей, статусы соблюдения.',
    gradient: 'var(--gradient-cta)',
    features: ['Очередь задач с приоритетами', 'Список семей и статусы', 'Расписание дня', 'KPI метрики'],
    actionLabel: 'координатор',
  },
  {
    key: 'doctor',
    icon: 'lucide:stethoscope',
    title: 'Врач',
    description: 'Расписание приёма, карточки пациентов, KPI.',
    gradient: 'linear-gradient(135deg, #10b981, #059669)',
    features: ['Расписание на сегодня', 'Карточки пациентов', 'KPI приёма', 'Свободные слоты'],
    actionLabel: 'врач',
  },
  {
    key: 'admin',
    icon: 'lucide:bar-chart-3',
    title: 'Руководитель клиники',
    description: 'Аналитика, удержание, дашборд, отчёты.',
    gradient: 'linear-gradient(135deg, var(--color-accent-blue), var(--color-primary))',
    features: ['Real-time дашборд', 'Аналитика удержания', 'Когортный анализ', 'Управление командой'],
    actionLabel: 'руководитель',
  },
]

async function enterDemo(roleKey: string) {
  loadingRole.value = roleKey
  error.value = ''

  try {
    // Call server endpoint to get demo session
    const result = await $fetch<{ access_token: string; refresh_token: string }>('/api/auth/demo-login', {
      method: 'POST',
      body: { role: roleKey },
    })

    if (!result.access_token || !result.refresh_token) {
      throw new Error('Не удалось войти в демо-аккаунт')
    }

    // Set session via Supabase client
    const { error: sessionError } = await supabase.auth.setSession({
      access_token: result.access_token,
      refresh_token: result.refresh_token,
    })

    if (sessionError) {
      throw sessionError
    }

    // Wait for user state to update
    const user = useSupabaseUser()
    if (!user.value) {
      await new Promise<void>((resolve) => {
        const stop = watch(user, (v) => {
          if (v) { stop(); resolve() }
        }, { immediate: true })
        setTimeout(() => { stop(); resolve() }, 3000)
      })
    }

    // Reset and reinitialize auth store for the new demo session
    authStore.reset()
    await authStore.initialize()

    // Navigate to demo dashboard
    navigateTo(DEMO_HOME[roleKey] || '/demo/family', { replace: true })
  }
  catch (err: any) {
    error.value = err?.data?.message || err?.message || 'Ошибка входа. Попробуйте ещё раз.'
  }
  finally {
    loadingRole.value = null
  }
}
</script>

<style scoped>
.demo-page {
  position: relative;
  min-height: 100vh;
  padding: 120px 0 80px;
  overflow: hidden;
}

.demo-ambient {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 0;
}

.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.15;
}

.blob-1 {
  width: 400px;
  height: 400px;
  background: var(--color-primary);
  top: -100px;
  right: -100px;
}

.blob-2 {
  width: 300px;
  height: 300px;
  background: var(--color-secondary);
  bottom: -50px;
  left: -50px;
}

.demo-container {
  position: relative;
  z-index: 1;
  max-width: 900px;
}

.demo-header {
  text-align: center;
  margin-bottom: 48px;
}

.demo-back {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: var(--color-text-secondary);
  text-decoration: none;
  margin-bottom: 24px;
  transition: color var(--transition-fast);
}

.demo-back:hover {
  color: var(--color-primary);
}

.demo-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0 0 12px;
}

.demo-subtitle {
  font-size: 18px;
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin: 0;
}

.demo-roles {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.demo-role-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 32px 24px;
  border-radius: var(--radius-lg);
  background: var(--color-card-bg);
  border: 1px solid var(--color-border-light);
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.demo-role-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  opacity: 0;
  background: linear-gradient(135deg, rgba(139, 126, 200, 0.04), rgba(139, 126, 200, 0.08));
  transition: opacity 0.3s ease;
}

.demo-role-card:hover::before {
  opacity: 1;
}

.demo-role-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-hover);
  transform: translateY(-4px);
}

.demo-role-card:disabled {
  opacity: 0.7;
  cursor: wait;
}

.demo-role-card.is-loading {
  border-color: var(--color-primary);
}

.role-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: var(--radius-md);
  color: white;
  margin-bottom: 16px;
}

.role-body {
  flex: 1;
  margin-bottom: 20px;
}

.role-title {
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 8px;
}

.role-desc {
  font-size: 14px;
  color: var(--color-text-secondary);
  line-height: 1.5;
  margin: 0 0 16px;
}

.role-features {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 6px;
  text-align: left;
}

.role-features li {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--color-text-secondary);
}

.feature-check {
  color: var(--color-success);
  flex-shrink: 0;
}

.role-action {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: var(--radius-full);
  background: var(--gradient-cta);
  color: white;
  font-size: 14px;
  font-weight: 600;
  transition: opacity var(--transition-fast), transform var(--transition-fast);
}

.demo-role-card:hover .role-action {
  opacity: 0.9;
  transform: scale(1.02);
}

.role-spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.demo-error {
  text-align: center;
  color: var(--color-error);
  font-size: 14px;
  padding: 12px;
  border-radius: var(--radius-sm);
  background: rgba(239, 68, 68, 0.08);
  margin-bottom: 16px;
}

.demo-hint {
  text-align: center;
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0 0 48px;
}

.demo-footer-cta {
  text-align: center;
  padding: 32px;
  border-radius: var(--radius-lg);
  background: var(--color-bg-alt);
  border: 1px solid var(--color-border-light);
}

.demo-footer-cta p {
  font-size: 16px;
  color: var(--color-text-secondary);
  margin: 0 0 16px;
}

.demo-cta-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: var(--color-primary);
  text-decoration: none;
  transition: gap var(--transition-fast);
}

.demo-cta-link:hover {
  gap: 12px;
}

@media (max-width: 768px) {
  .demo-roles {
    grid-template-columns: 1fr;
  }

  .demo-title {
    font-size: 1.75rem;
  }
}
</style>

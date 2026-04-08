<template>
  <div>
    <h2 class="auth-title">Вход</h2>
    <p class="auth-subtitle">Войдите в свой аккаунт Family Care</p>

    <form class="auth-form" @submit.prevent="handleLogin">
      <div class="form-group">
        <label class="form-label" for="email">Email</label>
        <input
          id="email"
          v-model="form.email"
          type="email"
          class="form-input"
          placeholder="example@email.com"
          required
          autocomplete="email"
        />
        <span v-if="errors.email" class="form-error">{{ errors.email }}</span>
      </div>

      <div class="form-group">
        <label class="form-label" for="password">Пароль</label>
        <input
          id="password"
          v-model="form.password"
          type="password"
          class="form-input"
          placeholder="Минимум 8 символов"
          required
          autocomplete="current-password"
        />
        <span v-if="errors.password" class="form-error">{{ errors.password }}</span>
      </div>

      <div class="form-row">
        <NuxtLink to="/auth/forgot-password" class="form-link">
          Забыли пароль?
        </NuxtLink>
      </div>

      <button type="submit" class="btn-primary" :disabled="loading">
        {{ loading ? 'Вход...' : 'Войти' }}
      </button>

      <p v-if="errorMessage" class="form-error-global">{{ errorMessage }}</p>
    </form>

    <p class="auth-switch">
      Нет аккаунта?
      <NuxtLink to="/auth/register" class="form-link">Зарегистрироваться</NuxtLink>
    </p>
  </div>
</template>

<script setup lang="ts">
import { loginSchema } from '~/utils/validators'
import { ROLE_HOME_MAP } from '~/utils/constants'
import type { UserRole } from '~/types/database'

definePageMeta({
  layout: 'auth',
})

const supabase = useSupabaseClient()

const form = reactive({ email: '', password: '' })
const errors = reactive<Record<string, string>>({})
const errorMessage = ref('')
const loading = ref(false)

async function handleLogin() {
  // Validate
  Object.keys(errors).forEach(k => delete errors[k])
  errorMessage.value = ''

  const result = loginSchema.safeParse(form)
  if (!result.success) {
    for (const issue of result.error.issues) {
      errors[issue.path[0] as string] = issue.message
    }
    return
  }

  loading.value = true
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: form.email,
      password: form.password,
    })

    if (error) {
      errorMessage.value = error.message === 'Invalid login credentials'
        ? 'Неверный email или пароль'
        : error.message
      return
    }

    if (data.user) {
      // Initialize auth store to load profile from public.users
      const authStore = useAuthStore()
      await authStore.initialize()
      const role = authStore.role
      navigateTo(ROLE_HOME_MAP[role] || '/family')
    }
  }
  finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-title {
  text-align: center;
  font-family: var(--font-display);
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 8px;
}

.auth-subtitle {
  text-align: center;
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  margin-bottom: 28px;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.form-input {
  padding: 10px 14px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: 0.95rem;
  font-family: var(--font-body);
  color: var(--color-text-primary);
  background: var(--color-surface);
  transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
  outline: none;
}

.form-input:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(139, 126, 200, 0.15);
}

.form-input::placeholder {
  color: var(--color-text-muted);
}

.form-error {
  font-size: 0.8rem;
  color: var(--color-danger);
}

.form-error-global {
  text-align: center;
  font-size: 0.85rem;
  color: var(--color-danger);
  padding: 8px;
  background: rgba(212, 114, 124, 0.08);
  border-radius: var(--radius-sm);
}

.form-row {
  display: flex;
  justify-content: flex-end;
}

.form-link {
  color: var(--color-primary);
  font-size: 0.85rem;
  font-weight: 500;
  text-decoration: none;
}

.form-link:hover {
  text-decoration: underline;
}

.btn-primary {
  padding: 12px;
  background: var(--gradient-cta);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 1rem;
  font-weight: 600;
  font-family: var(--font-body);
  cursor: pointer;
  transition: opacity var(--transition-fast), transform var(--transition-fast);
}

.btn-primary:hover:not(:disabled) {
  opacity: 0.9;
  transform: translateY(-1px);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.auth-switch {
  text-align: center;
  margin-top: 20px;
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}
</style>

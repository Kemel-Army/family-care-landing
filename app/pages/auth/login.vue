<template>
  <div>
    <h2 class="auth-title">Вход</h2>
    <p class="auth-subtitle">Войдите в свой аккаунт Family Care</p>

    <form class="auth-form" @submit.prevent="handleLogin">
      <div class="fg">
        <label class="fl" for="email">Email</label>
        <input id="email" v-model="form.email" type="email" class="fi" placeholder="example@email.com" required autocomplete="email" />
        <span v-if="errors.email" class="fe">{{ errors.email }}</span>
      </div>

      <div class="fg">
        <label class="fl" for="password">Пароль</label>
        <input id="password" v-model="form.password" type="password" class="fi" placeholder="Минимум 8 символов" required autocomplete="current-password" />
        <span v-if="errors.password" class="fe">{{ errors.password }}</span>
      </div>

      <div class="form-row-end">
        <NuxtLink to="/auth/forgot-password" class="link">Забыли пароль?</NuxtLink>
      </div>

      <button type="submit" class="btn-primary" :disabled="loading">
        {{ loading ? 'Вход...' : 'Войти' }}
      </button>

      <p v-if="errorMessage" class="form-error-global">{{ errorMessage }}</p>
    </form>

    <p class="auth-switch">Нет аккаунта? <NuxtLink to="/auth/register" class="link">Зарегистрироваться</NuxtLink></p>
  </div>
</template>

<script setup lang="ts">
import { loginSchema } from '~/utils/validators'
import { ROLE_HOME_MAP } from '~/utils/constants'
import type { UserRole } from '~/types/database'

definePageMeta({ layout: 'auth' })

const supabase = useSupabaseClient()
const form = reactive({ email: '', password: '' })
const errors = reactive<Record<string, string>>({})
const errorMessage = ref('')
const loading = ref(false)

async function handleLogin() {
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
.auth-title { text-align: center; font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; margin-bottom: 6px; }
.auth-subtitle { text-align: center; color: var(--color-text-muted); font-size: 0.85rem; margin-bottom: 24px; }

.auth-form { display: flex; flex-direction: column; gap: 14px; }
.fg { display: flex; flex-direction: column; gap: 5px; }
.fl { font-size: 0.82rem; font-weight: 600; }
.fi { padding: 11px 14px; border: 1px solid rgba(139,126,200,0.15); border-radius: 12px; font-size: 0.92rem; font-family: var(--font-body); background: rgba(255,255,255,0.6); outline: none; transition: border-color 0.2s, box-shadow 0.2s; }
.fi:focus { border-color: var(--color-primary); box-shadow: 0 0 0 3px rgba(139,126,200,0.12); }
.fi::placeholder { color: var(--color-text-muted); }
.fe { font-size: 0.78rem; color: var(--color-danger); }

.form-row-end { display: flex; justify-content: flex-end; }
.link { color: var(--color-primary); font-size: 0.82rem; font-weight: 500; text-decoration: none; }
.link:hover { text-decoration: underline; }

.btn-primary { padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-size: 0.95rem; font-weight: 600; font-family: var(--font-body); cursor: pointer; transition: opacity 0.2s, transform 0.2s; }
.btn-primary:hover:not(:disabled) { opacity: 0.92; transform: translateY(-1px); }
.btn-primary:disabled { opacity: 0.55; cursor: not-allowed; }

.form-error-global { text-align: center; font-size: 0.82rem; color: var(--color-danger); padding: 8px; background: rgba(212,114,124,0.06); border-radius: 10px; }

.auth-switch { text-align: center; margin-top: 18px; font-size: 0.82rem; color: var(--color-text-muted); }
</style>

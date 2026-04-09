<template>
  <div>
    <h2 class="auth-title">Регистрация</h2>
    <p class="auth-subtitle">Создайте аккаунт для вашей семьи</p>

    <form class="auth-form" @submit.prevent="handleRegister">
      <div class="form-row-2">
        <div class="fg">
          <label class="fl" for="firstName">Имя</label>
          <input id="firstName" v-model="form.firstName" type="text" class="fi" placeholder="Имя" required />
          <span v-if="errors.firstName" class="fe">{{ errors.firstName }}</span>
        </div>
        <div class="fg">
          <label class="fl" for="lastName">Фамилия</label>
          <input id="lastName" v-model="form.lastName" type="text" class="fi" placeholder="Фамилия" required />
          <span v-if="errors.lastName" class="fe">{{ errors.lastName }}</span>
        </div>
      </div>

      <div class="fg">
        <label class="fl" for="email">Email</label>
        <input id="email" v-model="form.email" type="email" class="fi" placeholder="example@email.com" required autocomplete="email" />
        <span v-if="errors.email" class="fe">{{ errors.email }}</span>
      </div>

      <div class="fg">
        <label class="fl" for="phone">Телефон <span class="opt">(необязательно)</span></label>
        <input id="phone" v-model="form.phone" type="tel" class="fi" placeholder="+7XXXXXXXXXX" autocomplete="tel" />
        <span v-if="errors.phone" class="fe">{{ errors.phone }}</span>
      </div>

      <div class="fg">
        <label class="fl" for="password">Пароль</label>
        <input id="password" v-model="form.password" type="password" class="fi" placeholder="Минимум 8 символов" required autocomplete="new-password" />
        <span v-if="errors.password" class="fe">{{ errors.password }}</span>
      </div>

      <div class="fg">
        <label class="fl" for="confirmPassword">Подтверждение пароля</label>
        <input id="confirmPassword" v-model="form.confirmPassword" type="password" class="fi" placeholder="Повторите пароль" required autocomplete="new-password" />
        <span v-if="errors.confirmPassword" class="fe">{{ errors.confirmPassword }}</span>
      </div>

      <button type="submit" class="btn-primary" :disabled="loading">
        {{ loading ? 'Регистрация...' : 'Зарегистрироваться' }}
      </button>

      <p v-if="errorMessage" class="form-error-global">{{ errorMessage }}</p>
    </form>

    <div v-if="success" class="auth-success">
      <div class="success-icon-ring"><Icon name="lucide:mail-check" size="22" /></div>
      <p>Проверьте почту — мы отправили ссылку для подтверждения.</p>
    </div>

    <p class="auth-switch">Уже есть аккаунт? <NuxtLink to="/auth/login" class="link">Войти</NuxtLink></p>
  </div>
</template>

<script setup lang="ts">
import { registerSchema } from '~/utils/validators'

definePageMeta({ layout: 'auth' })

const supabase = useSupabaseClient()

const form = reactive({
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
})
const errors = reactive<Record<string, string>>({})
const errorMessage = ref('')
const loading = ref(false)
const success = ref(false)

async function handleRegister() {
  Object.keys(errors).forEach(k => delete errors[k])
  errorMessage.value = ''

  const result = registerSchema.safeParse(form)
  if (!result.success) {
    for (const issue of result.error.issues) {
      errors[issue.path[0] as string] = issue.message
    }
    return
  }

  loading.value = true
  try {
    const { error } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: {
          first_name: form.firstName,
          last_name: form.lastName,
          phone: form.phone || null,
          role: 'mother',
        },
      },
    })

    if (error) {
      errorMessage.value = error.message
      return
    }

    success.value = true
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
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { display: flex; flex-direction: column; gap: 5px; }
.fl { font-size: 0.82rem; font-weight: 600; }
.opt { font-weight: 400; color: var(--color-text-muted); }
.fi { padding: 11px 14px; border: 1px solid rgba(139,126,200,0.15); border-radius: 12px; font-size: 0.92rem; font-family: var(--font-body); background: rgba(255,255,255,0.6); outline: none; transition: border-color 0.2s, box-shadow 0.2s; }
.fi:focus { border-color: var(--color-primary); box-shadow: 0 0 0 3px rgba(139,126,200,0.12); }
.fi::placeholder { color: var(--color-text-muted); }
.fe { font-size: 0.78rem; color: var(--color-danger); }

.btn-primary { padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-size: 0.95rem; font-weight: 600; font-family: var(--font-body); cursor: pointer; transition: opacity 0.2s, transform 0.2s; }
.btn-primary:hover:not(:disabled) { opacity: 0.92; transform: translateY(-1px); }
.btn-primary:disabled { opacity: 0.55; cursor: not-allowed; }

.form-error-global { text-align: center; font-size: 0.82rem; color: var(--color-danger); padding: 8px; background: rgba(212,114,124,0.06); border-radius: 10px; }

.auth-success { display: flex; flex-direction: column; align-items: center; gap: 10px; text-align: center; color: var(--color-success); font-size: 0.88rem; padding: 16px; background: rgba(124,184,212,0.08); border-radius: 14px; margin-top: 16px; animation: fadeUp 0.4s ease; }
.success-icon-ring { width: 44px; height: 44px; border-radius: 50%; background: rgba(124,184,212,0.12); display: flex; align-items: center; justify-content: center; color: var(--color-success); }

.link { color: var(--color-primary); font-size: 0.82rem; font-weight: 500; text-decoration: none; }
.link:hover { text-decoration: underline; }
.auth-switch { text-align: center; margin-top: 18px; font-size: 0.82rem; color: var(--color-text-muted); }

@keyframes fadeUp { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
@media (max-width: 480px) { .form-row-2 { grid-template-columns: 1fr; } }
</style>

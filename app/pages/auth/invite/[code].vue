<template>
  <div>
    <h2 class="auth-title">Приглашение в семью</h2>

    <div v-if="loading" class="state-box">
      <div class="spinner" />
      <p>Загрузка...</p>
    </div>

    <div v-else-if="!validCode" class="state-box state-error">
      <div class="state-icon-ring danger"><Icon name="lucide:x" size="22" /></div>
      <p>Недействительный или истёкший код приглашения.</p>
      <NuxtLink to="/auth/login" class="link">Перейти ко входу</NuxtLink>
    </div>

    <div v-else-if="success" class="state-box state-success">
      <div class="state-icon-ring success"><Icon name="lucide:heart-handshake" size="22" /></div>
      <p>Вы присоединились к семье! Перенаправляем...</p>
    </div>

    <form v-else class="auth-form" @submit.prevent="handleJoin">
      <p class="auth-subtitle">Вас пригласили присоединиться к семье. Создайте аккаунт.</p>

      <div class="form-row-2">
        <div class="fg">
          <label class="fl" for="firstName">Имя</label>
          <input id="firstName" v-model="form.firstName" type="text" class="fi" placeholder="Имя" required />
        </div>
        <div class="fg">
          <label class="fl" for="lastName">Фамилия</label>
          <input id="lastName" v-model="form.lastName" type="text" class="fi" placeholder="Фамилия" required />
        </div>
      </div>

      <div class="fg">
        <label class="fl" for="email">Email</label>
        <input id="email" v-model="form.email" type="email" class="fi" placeholder="example@email.com" required autocomplete="email" />
      </div>

      <div class="fg">
        <label class="fl" for="password">Пароль</label>
        <input id="password" v-model="form.password" type="password" class="fi" placeholder="Минимум 8 символов" required autocomplete="new-password" />
      </div>

      <button type="submit" class="btn-primary" :disabled="submitting">
        {{ submitting ? 'Присоединение...' : 'Присоединиться' }}
      </button>

      <p v-if="errorMessage" class="form-error-global">{{ errorMessage }}</p>
    </form>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const route = useRoute()
const supabase = useSupabaseClient()

const inviteCode = route.params.code as string
const form = reactive({ firstName: '', lastName: '', email: '', password: '' })
const loading = ref(true)
const validCode = ref(false)
const submitting = ref(false)
const success = ref(false)
const errorMessage = ref('')
const familyId = ref('')

onMounted(async () => {
  const { data } = await supabase
    .from('families')
    .select('id')
    .eq('invite_code', inviteCode)
    .eq('status', 'active')
    .is('secondary_parent_id', null)
    .single()

  if (data) {
    validCode.value = true
    familyId.value = data.id
  }
  loading.value = false
})

async function handleJoin() {
  submitting.value = true
  errorMessage.value = ''

  try {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: {
          first_name: form.firstName,
          last_name: form.lastName,
          role: 'father',
        },
      },
    })

    if (authError || !authData.user) {
      errorMessage.value = authError?.message || 'Ошибка регистрации'
      return
    }

    const { error: joinError } = await supabase
      .from('families')
      .update({
        secondary_parent_id: authData.user.id,
        invite_code: null,
      })
      .eq('id', familyId.value)

    if (joinError) {
      errorMessage.value = 'Ошибка присоединения к семье'
      return
    }

    success.value = true
    setTimeout(() => navigateTo('/family'), 1500)
  }
  finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.auth-title { text-align: center; font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; margin-bottom: 20px; }
.auth-subtitle { text-align: center; color: var(--color-text-muted); font-size: 0.85rem; margin-bottom: 4px; }

.auth-form { display: flex; flex-direction: column; gap: 14px; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { display: flex; flex-direction: column; gap: 5px; }
.fl { font-size: 0.82rem; font-weight: 600; }
.fi { padding: 11px 14px; border: 1px solid rgba(139,126,200,0.15); border-radius: 12px; font-size: 0.92rem; font-family: var(--font-body); background: rgba(255,255,255,0.6); outline: none; transition: border-color 0.2s, box-shadow 0.2s; }
.fi:focus { border-color: var(--color-primary); box-shadow: 0 0 0 3px rgba(139,126,200,0.12); }
.fi::placeholder { color: var(--color-text-muted); }

.btn-primary { padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-size: 0.95rem; font-weight: 600; font-family: var(--font-body); cursor: pointer; transition: opacity 0.2s, transform 0.2s; }
.btn-primary:hover:not(:disabled) { opacity: 0.92; transform: translateY(-1px); }
.btn-primary:disabled { opacity: 0.55; cursor: not-allowed; }

.form-error-global { text-align: center; font-size: 0.82rem; color: var(--color-danger); padding: 8px; background: rgba(212,114,124,0.06); border-radius: 10px; }

.link { color: var(--color-primary); font-size: 0.82rem; font-weight: 500; text-decoration: none; }
.link:hover { text-decoration: underline; }

.state-box { display: flex; flex-direction: column; align-items: center; gap: 12px; text-align: center; padding: 24px 0; font-size: 0.88rem; color: var(--color-text-muted); animation: fadeUp 0.4s ease; }
.state-success { color: var(--color-success); }
.state-error { color: var(--color-danger); }

.state-icon-ring { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.state-icon-ring.success { background: rgba(124,184,212,0.12); color: var(--color-success); }
.state-icon-ring.danger { background: rgba(212,114,124,0.1); color: var(--color-danger); }

.spinner { width: 32px; height: 32px; border: 3px solid rgba(139,126,200,0.15); border-top-color: var(--color-primary); border-radius: 50%; animation: spin 0.7s linear infinite; }

@keyframes fadeUp { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
@keyframes spin { to { transform: rotate(360deg); } }
@media (max-width: 480px) { .form-row-2 { grid-template-columns: 1fr; } }
</style>

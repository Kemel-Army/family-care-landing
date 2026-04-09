<template>
  <div class="settings-page">
    <div class="settings-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Панель</NuxtLink>
      <h1 class="hero-title">Настройки</h1>
      <p class="hero-sub">Ваш профиль и предпочтения</p>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <template v-else>
      <!-- Profile -->
      <div class="card">
        <h2 class="card-title"><Icon name="lucide:user" size="16" /> Профиль</h2>
        <div class="profile-header">
          <div class="profile-avatar">{{ initials }}</div>
          <div class="profile-name-block">
            <span class="profile-name">{{ form.first_name }} {{ form.last_name }}</span>
            <span class="profile-email">{{ form.email }}</span>
          </div>
        </div>
        <div class="form-grid">
          <div class="fg"><label class="fl">Имя</label><input v-model="form.first_name" class="fi" /></div>
          <div class="fg"><label class="fl">Фамилия</label><input v-model="form.last_name" class="fi" /></div>
          <div class="fg"><label class="fl">Телефон</label><input v-model="form.phone" class="fi" placeholder="+7 (777) …" /></div>
          <div class="fg"><label class="fl">Email</label><input v-model="form.email" class="fi" readonly /></div>
        </div>
      </div>

      <!-- Doctor profile -->
      <div class="card">
        <h2 class="card-title"><Icon name="lucide:stethoscope" size="16" /> Врачебный профиль</h2>
        <div class="form-grid">
          <div class="fg">
            <label class="fl">Специальность</label>
            <select v-model="form.specialty" class="fi">
              <option value="gynecologist">Гинеколог</option>
              <option value="pediatrician">Педиатр</option>
              <option value="neonatologist">Неонатолог</option>
              <option value="ultrasound">УЗИ-специалист</option>
              <option value="lab">Лаборант</option>
            </select>
          </div>
          <div class="fg"><label class="fl">Стаж (лет)</label><input v-model.number="form.experience_years" class="fi" type="number" min="0" /></div>
          <div class="fg"><label class="fl">Стоимость консультации</label><input v-model.number="form.consultation_fee" class="fi" type="number" min="0" /></div>
          <div class="fg full"><label class="fl">Биография</label><textarea v-model="form.bio" class="fi" rows="3" placeholder="Расскажите о себе…" /></div>
        </div>
      </div>

      <button class="btn-save" @click="save"><Icon name="lucide:save" size="16" /> Сохранить</button>
      <span v-if="saved" class="saved-msg">✓ Изменения сохранены</span>
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const user = useSupabaseUser()
const loading = ref(true)
const saved = ref(false)
const doctorId = ref('')

const form = reactive({
  first_name: '',
  last_name: '',
  phone: '',
  email: '',
  specialty: 'gynecologist',
  experience_years: 0,
  consultation_fee: 0,
  bio: '',
})

const initials = computed(() =>
  `${form.first_name?.[0] || ''}${form.last_name?.[0] || ''}`.toUpperCase() || '??'
)

async function save() {
  // Update users table
  await sb.from('users').update({
    first_name: form.first_name,
    last_name: form.last_name,
    phone: form.phone,
  }).eq('id', user.value!.id)

  // Update doctors table
  if (doctorId.value) {
    await sb.from('doctors').update({
      specialty: form.specialty,
      experience_years: form.experience_years,
      consultation_fee: form.consultation_fee,
      bio: form.bio,
    }).eq('id', doctorId.value)
  }

  saved.value = true
  setTimeout(() => { saved.value = false }, 3000)
}

onMounted(async () => {
  const { data: profile } = await sb.from('users').select('first_name, last_name, phone, email').eq('id', user.value!.id).single()
  if (profile) {
    form.first_name = profile.first_name || ''
    form.last_name = profile.last_name || ''
    form.phone = profile.phone || ''
    form.email = profile.email || ''
  }

  const { data: doc } = await sb.from('doctors').select('id, specialty, experience_years, consultation_fee, bio').eq('user_id', user.value!.id).single()
  if (doc) {
    doctorId.value = doc.id
    form.specialty = doc.specialty || 'gynecologist'
    form.experience_years = doc.experience_years || 0
    form.consultation_fee = doc.consultation_fee || 0
    form.bio = doc.bio || ''
  }
  loading.value = false
})
</script>

<style scoped>
.settings-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }
.settings-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.92rem; font-weight: 600; display: flex; align-items: center; gap: 6px; margin-bottom: 16px; }
.profile-header { display: flex; align-items: center; gap: 14px; margin-bottom: 16px; }
.profile-avatar {
  width: 48px; height: 48px; border-radius: 14px; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, rgba(139,126,200,0.2), rgba(232,160,191,0.15));
  font-size: 1rem; font-weight: 700; color: var(--color-primary);
}
.profile-name-block { display: flex; flex-direction: column; }
.profile-name { font-size: 1rem; font-weight: 600; }
.profile-email { font-size: 0.78rem; color: var(--color-text-muted); }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fg.full { grid-column: 1 / -1; }
.fl { font-size: 0.75rem; font-weight: 500; color: var(--color-text-muted); }
.fi {
  padding: 8px 12px; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s; resize: vertical;
}
.fi:focus { border-color: var(--color-primary); }
.fi[readonly] { background: rgba(0,0,0,0.02); color: var(--color-text-muted); }
select.fi { appearance: auto; background: white; }
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 40px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.btn-save {
  display: flex; align-items: center; gap: 6px; padding: 10px 20px; border-radius: 12px;
  background: var(--color-primary); color: white; font-size: 0.88rem; font-weight: 600; font-family: var(--font-body);
  border: none; cursor: pointer; transition: opacity 0.2s; align-self: flex-start;
}
.btn-save:hover { opacity: 0.9; }
.saved-msg { font-size: 0.82rem; color: #4a9960; align-self: flex-start; }
</style>

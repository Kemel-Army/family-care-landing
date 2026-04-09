<template>
  <div class="clinic-page">
    <div class="clinic-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Настройки</NuxtLink>
      <h1 class="hero-title">Настройки клиники</h1>
      <p class="hero-sub">Основная информация и контакты</p>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <template v-else>
      <div class="card">
        <h2 class="card-title"><Icon name="lucide:building-2" size="16" /> Основное</h2>
        <div class="form-grid">
          <div class="fg"><label class="fl">Название</label><input v-model="form.name" class="fi" /></div>
          <div class="fg"><label class="fl">Slug</label><input v-model="form.slug" class="fi" readonly /></div>
          <div class="fg"><label class="fl">Часовой пояс</label>
            <select v-model="form.timezone" class="fi">
              <option value="Asia/Almaty">Asia/Almaty (UTC+6)</option>
              <option value="Asia/Aqtobe">Asia/Aqtobe (UTC+5)</option>
              <option value="Asia/Atyrau">Asia/Atyrau (UTC+5)</option>
              <option value="Europe/Moscow">Europe/Moscow (UTC+3)</option>
            </select>
          </div>
        </div>
      </div>

      <div class="card">
        <h2 class="card-title"><Icon name="lucide:phone" size="16" /> Контакты</h2>
        <div class="form-grid">
          <div class="fg"><label class="fl">Телефон</label><input v-model="form.phone" class="fi" placeholder="+7 (777) 123-45-67" /></div>
          <div class="fg full"><label class="fl">Адрес</label><input v-model="form.address" class="fi" placeholder="г. Алматы, ул. …" /></div>
        </div>
      </div>

      <div class="card">
        <h2 class="card-title"><Icon name="lucide:star" size="16" /> Отзывы</h2>
        <div class="form-grid">
          <div class="fg"><label class="fl">Ссылка 2GIS</label><input v-model="form.review_link_2gis" class="fi" placeholder="https://2gis.kz/…" /></div>
          <div class="fg"><label class="fl">Ссылка Google</label><input v-model="form.review_link_google" class="fi" placeholder="https://g.page/…" /></div>
        </div>
      </div>

      <div class="card">
        <h2 class="card-title"><Icon name="lucide:toggle-left" size="16" /> Статус</h2>
        <div class="status-row">
          <label class="toggle">
            <input v-model="form.is_active" type="checkbox" />
            <span class="toggle-track" />
          </label>
          <span class="status-label">{{ form.is_active ? 'Клиника активна' : 'Клиника деактивирована' }}</span>
        </div>
      </div>

      <button class="btn-save" @click="save"><Icon name="lucide:save" size="16" /> Сохранить</button>
      <span v-if="saved" class="saved-msg">✓ Настройки сохранены</span>
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const loading = ref(true)
const saved = ref(false)
const clinicId = ref('')

const form = reactive({
  name: '',
  slug: '',
  timezone: 'Asia/Almaty',
  phone: '',
  address: '',
  review_link_2gis: '',
  review_link_google: '',
  is_active: true,
})

async function save() {
  if (!clinicId.value) return
  await sb.from('clinics').update({
    name: form.name,
    timezone: form.timezone,
    phone: form.phone,
    address: form.address,
    review_link_2gis: form.review_link_2gis,
    review_link_google: form.review_link_google,
    is_active: form.is_active,
  }).eq('id', clinicId.value)
  saved.value = true
  setTimeout(() => { saved.value = false }, 3000)
}

onMounted(async () => {
  const user = useSupabaseUser()
  const { data: profile } = await sb.from('users').select('clinic_id').eq('id', user.value!.id).single()
  if (!profile?.clinic_id) { loading.value = false; return }
  clinicId.value = profile.clinic_id

  const { data } = await sb.from('clinics').select('*').eq('id', profile.clinic_id).single()
  if (data) {
    form.name = data.name || ''
    form.slug = data.slug || ''
    form.timezone = data.timezone || 'Asia/Almaty'
    form.phone = data.phone || ''
    form.address = data.address || ''
    form.review_link_2gis = data.review_link_2gis || ''
    form.review_link_google = data.review_link_google || ''
    form.is_active = data.is_active ?? true
  }
  loading.value = false
})
</script>

<style scoped>
.clinic-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }
.clinic-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.92rem; font-weight: 600; display: flex; align-items: center; gap: 6px; margin-bottom: 16px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fg.full { grid-column: 1 / -1; }
.fl { font-size: 0.75rem; font-weight: 500; color: var(--color-text-muted); }
.fi {
  padding: 8px 12px; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s;
}
.fi:focus { border-color: var(--color-primary); }
select.fi { appearance: auto; background: white; }
.status-row { display: flex; align-items: center; gap: 12px; }
.status-label { font-size: 0.88rem; }
.toggle { position: relative; display: inline-block; width: 40px; height: 22px; flex-shrink: 0; }
.toggle input { opacity: 0; width: 0; height: 0; }
.toggle-track {
  position: absolute; inset: 0; background: var(--color-border-light); border-radius: 11px; cursor: pointer; transition: background 0.2s;
}
.toggle-track::before {
  content: ''; position: absolute; width: 16px; height: 16px; border-radius: 50%; background: white; top: 3px; left: 3px; transition: transform 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.15);
}
.toggle input:checked + .toggle-track { background: var(--color-primary); }
.toggle input:checked + .toggle-track::before { transform: translateX(18px); }
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

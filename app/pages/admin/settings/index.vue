<template>
  <div class="settings-page">
    <header class="page-header">
      <h1 class="page-title">Настройки клиники</h1>
    </header>

    <!-- Clinic Info -->
    <section class="section">
      <h2 class="section-title">Основная информация</h2>
      <div class="form-grid">
        <div class="form-group">
          <label class="form-label">Название клиники</label>
          <input v-model="clinic.name" type="text" class="form-input" />
        </div>
        <div class="form-group">
          <label class="form-label">Slug (URL)</label>
          <input v-model="clinic.slug" type="text" class="form-input" disabled />
        </div>
        <div class="form-group">
          <label class="form-label">Телефон</label>
          <input v-model="clinic.phone" type="text" class="form-input" placeholder="+7 (XXX) XXX-XX-XX" />
        </div>
        <div class="form-group">
          <label class="form-label">Адрес</label>
          <input v-model="clinic.address" type="text" class="form-input" placeholder="г. Алматы, ул. ..." />
        </div>
        <div class="form-group">
          <label class="form-label">Часовой пояс</label>
          <select v-model="clinic.timezone" class="form-input">
            <option value="Asia/Almaty">Asia/Almaty (UTC+6)</option>
            <option value="Asia/Aqtobe">Asia/Aqtobe (UTC+5)</option>
            <option value="Asia/Oral">Asia/Oral (UTC+5)</option>
          </select>
        </div>
      </div>
    </section>

    <!-- Logo -->
    <section class="section">
      <h2 class="section-title">Логотип</h2>
      <div class="logo-area">
        <img v-if="clinic.logo_url" :src="clinic.logo_url" class="logo-preview" alt="Логотип" />
        <div v-else class="logo-placeholder">
          <Icon name="lucide:image" size="32" />
        </div>
        <div class="logo-upload">
          <label class="btn-upload">
            <Icon name="lucide:upload" size="14" /> Загрузить логотип
            <input type="file" accept="image/*" hidden @change="uploadLogo" />
          </label>
          <p class="logo-hint">PNG или SVG, макс. 500×500px</p>
        </div>
      </div>
    </section>

    <!-- Review Links -->
    <section class="section">
      <h2 class="section-title">Ссылки на отзывы</h2>
      <div class="form-grid">
        <div class="form-group">
          <label class="form-label">2GIS</label>
          <input v-model="clinic.review_link_2gis" type="url" class="form-input" placeholder="https://2gis.kz/almaty/firm/..." />
        </div>
        <div class="form-group">
          <label class="form-label">Google</label>
          <input v-model="clinic.review_link_google" type="url" class="form-input" placeholder="https://g.page/r/..." />
        </div>
      </div>
    </section>

    <!-- Working Hours -->
    <section class="section">
      <h2 class="section-title">Рабочие часы</h2>
      <div class="hours-grid">
        <div v-for="day in weekDays" :key="day.key" class="hours-row">
          <span class="day-label">{{ day.label }}</span>
          <input v-model="workingHours[day.key].start" type="time" class="time-input" />
          <span class="time-sep">—</span>
          <input v-model="workingHours[day.key].end" type="time" class="time-input" />
          <label class="day-toggle">
            <input v-model="workingHours[day.key].active" type="checkbox" />
            <span>{{ workingHours[day.key].active ? 'Работает' : 'Выходной' }}</span>
          </label>
        </div>
      </div>
    </section>

    <div class="save-bar">
      <button class="btn-save" :disabled="saving" @click="saveSettings">
        {{ saving ? 'Сохранение...' : 'Сохранить настройки' }}
      </button>
      <span v-if="saved" class="saved-msg">✓ Сохранено</span>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const saving = ref(false)
const saved = ref(false)

const clinic = reactive({
  name: '',
  slug: '',
  phone: '',
  address: '',
  timezone: 'Asia/Almaty',
  logo_url: null as string | null,
  review_link_2gis: '',
  review_link_google: '',
})

const weekDays = [
  { key: 'mon', label: 'Пн' }, { key: 'tue', label: 'Вт' },
  { key: 'wed', label: 'Ср' }, { key: 'thu', label: 'Чт' },
  { key: 'fri', label: 'Пт' }, { key: 'sat', label: 'Сб' },
  { key: 'sun', label: 'Вс' },
]

const workingHours = reactive<Record<string, { start: string; end: string; active: boolean }>>({
  mon: { start: '08:00', end: '18:00', active: true },
  tue: { start: '08:00', end: '18:00', active: true },
  wed: { start: '08:00', end: '18:00', active: true },
  thu: { start: '08:00', end: '18:00', active: true },
  fri: { start: '08:00', end: '18:00', active: true },
  sat: { start: '09:00', end: '14:00', active: true },
  sun: { start: '09:00', end: '14:00', active: false },
})

async function uploadLogo(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file || !authStore.clinicId) return

  const ext = file.name.split('.').pop()
  const path = `clinics/${authStore.clinicId}/logo.${ext}`

  const { error } = await supabase.storage.from('public').upload(path, file, { upsert: true })
  if (!error) {
    const { data } = supabase.storage.from('public').getPublicUrl(path)
    clinic.logo_url = data.publicUrl
  }
}

async function saveSettings() {
  if (!authStore.clinicId) return
  saving.value = true
  saved.value = false

  await supabase.from('clinics').update({
    name: clinic.name,
    phone: clinic.phone || null,
    address: clinic.address || null,
    timezone: clinic.timezone,
    logo_url: clinic.logo_url,
    review_link_2gis: clinic.review_link_2gis || null,
    review_link_google: clinic.review_link_google || null,
    settings_json: { working_hours: { ...workingHours } },
  }).eq('id', authStore.clinicId)

  saving.value = false
  saved.value = true
  setTimeout(() => { saved.value = false }, 3000)
}

onMounted(async () => {
  if (!authStore.clinicId) return

  const { data } = await supabase
    .from('clinics')
    .select('*')
    .eq('id', authStore.clinicId)
    .single()

  if (data) {
    clinic.name = data.name || ''
    clinic.slug = data.slug || ''
    clinic.phone = data.phone || ''
    clinic.address = data.address || ''
    clinic.timezone = data.timezone || 'Asia/Almaty'
    clinic.logo_url = data.logo_url || null
    clinic.review_link_2gis = data.review_link_2gis || ''
    clinic.review_link_google = data.review_link_google || ''

    const hours = (data.settings_json as Record<string, any>)?.working_hours
    if (hours) {
      for (const key of Object.keys(workingHours)) {
        if (hours[key]) Object.assign(workingHours[key], hours[key])
      }
    }
  }
})
</script>

<style scoped>
.settings-page { max-width: 700px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.section { margin-bottom: 28px; }
.section-title { font-size: 0.95rem; font-weight: 600; margin-bottom: 14px; padding-bottom: 8px; border-bottom: 1px solid var(--color-border-light); }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
@media (max-width: 600px) { .form-grid { grid-template-columns: 1fr; } }

.form-group { display: flex; flex-direction: column; }
.form-label { font-size: 0.8rem; font-weight: 600; margin-bottom: 6px; color: var(--color-text-secondary); }
.form-input {
  padding: 10px 12px; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body);
  background: var(--color-bg); color: var(--color-text-primary);
}
.form-input:focus { outline: none; border-color: var(--color-primary); }
.form-input:disabled { opacity: 0.5; }

/* Logo */
.logo-area { display: flex; align-items: center; gap: 16px; }
.logo-preview { width: 64px; height: 64px; border-radius: var(--radius-sm); object-fit: cover; border: 1px solid var(--color-border-light); }
.logo-placeholder { width: 64px; height: 64px; border-radius: var(--radius-sm); border: 2px dashed var(--color-border); display: flex; align-items: center; justify-content: center; color: var(--color-text-muted); }
.btn-upload {
  display: flex; align-items: center; gap: 6px; padding: 6px 14px;
  background: var(--color-primary-ultralight); color: var(--color-primary);
  border: 1px solid var(--color-primary-light); border-radius: var(--radius-sm);
  font-size: 0.8rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.logo-hint { font-size: 0.7rem; color: var(--color-text-muted); margin-top: 4px; }

/* Working Hours */
.hours-grid { display: flex; flex-direction: column; gap: 8px; }
.hours-row { display: flex; align-items: center; gap: 10px; }
.day-label { width: 30px; font-size: 0.85rem; font-weight: 600; }
.time-input {
  padding: 6px 10px; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); font-size: 0.85rem; font-family: var(--font-mono);
  background: var(--color-bg); width: 90px;
}
.time-sep { color: var(--color-text-muted); }
.day-toggle { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-secondary); cursor: pointer; margin-left: auto; }
.day-toggle input { accent-color: var(--color-primary); }

/* Save Bar */
.save-bar { display: flex; align-items: center; gap: 12px; padding-top: 20px; border-top: 1px solid var(--color-border-light); }
.btn-save {
  padding: 10px 24px; background: var(--color-primary); color: #fff; border: none;
  border-radius: var(--radius-sm); font-size: 0.9rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.btn-save:disabled { opacity: 0.6; cursor: not-allowed; }
.saved-msg { font-size: 0.85rem; color: var(--color-success); font-weight: 500; }
</style>

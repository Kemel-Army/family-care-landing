<template>
  <div class="set-page">
    <div class="set-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="hero-title">Настройки клиники</h1>
      <p class="hero-sub">Основная информация, расписание и брендинг</p>
    </div>

    <!-- Info -->
    <div class="card">
      <h2 class="card-title">Основная информация</h2>
      <div class="form-grid">
        <div class="fg"><label class="fl">Название клиники</label><input v-model="clinic.name" class="fi" /></div>
        <div class="fg"><label class="fl">Slug (URL)</label><input v-model="clinic.slug" class="fi" disabled /></div>
        <div class="fg"><label class="fl">Телефон</label><input v-model="clinic.phone" class="fi" placeholder="+7 (XXX) XXX-XX-XX" /></div>
        <div class="fg"><label class="fl">Адрес</label><input v-model="clinic.address" class="fi" placeholder="г. Алматы, ул. ..." /></div>
        <div class="fg">
          <label class="fl">Часовой пояс</label>
          <select v-model="clinic.timezone" class="fi">
            <option value="Asia/Almaty">Asia/Almaty (UTC+6)</option>
            <option value="Asia/Aqtobe">Asia/Aqtobe (UTC+5)</option>
            <option value="Asia/Oral">Asia/Oral (UTC+5)</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Logo -->
    <div class="card">
      <h2 class="card-title">Логотип</h2>
      <div class="logo-area">
        <div class="logo-placeholder"><Icon name="lucide:image" size="28" /></div>
        <div>
          <label class="btn-upload"><Icon name="lucide:upload" size="14" /> Загрузить логотип<input type="file" accept="image/*" hidden /></label>
          <p class="logo-hint">PNG или SVG, макс. 500×500px</p>
        </div>
      </div>
    </div>

    <!-- Review Links -->
    <div class="card">
      <h2 class="card-title">Ссылки на отзывы</h2>
      <div class="form-grid">
        <div class="fg"><label class="fl">2GIS</label><input v-model="clinic.link2gis" class="fi" placeholder="https://2gis.kz/almaty/firm/..." /></div>
        <div class="fg"><label class="fl">Google</label><input v-model="clinic.linkGoogle" class="fi" placeholder="https://g.page/r/..." /></div>
      </div>
    </div>

    <!-- Working Hours -->
    <div class="card">
      <h2 class="card-title">Рабочие часы</h2>
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
    </div>

    <div class="save-bar">
      <button class="btn-save" @click="saved = true">Сохранить настройки</button>
      <span v-if="saved" class="saved-msg">✓ Сохранено</span>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const saved = ref(false)

const clinic = reactive({
  name: 'UMAI Health Алматы',
  slug: 'umai-health-almaty',
  phone: '+7 (727) 123-45-67',
  address: 'г. Алматы, ул. Абая 52',
  timezone: 'Asia/Almaty',
  link2gis: 'https://2gis.kz/almaty/firm/umai-health',
  linkGoogle: 'https://g.page/umai-health-almaty',
})

const weekDays = [
  { key: 'mon' as const, label: 'Пн' }, { key: 'tue' as const, label: 'Вт' },
  { key: 'wed' as const, label: 'Ср' }, { key: 'thu' as const, label: 'Чт' },
  { key: 'fri' as const, label: 'Пт' }, { key: 'sat' as const, label: 'Сб' },
  { key: 'sun' as const, label: 'Вс' },
]

const workingHours = reactive({
  mon: { start: '08:00', end: '18:00', active: true },
  tue: { start: '08:00', end: '18:00', active: true },
  wed: { start: '08:00', end: '18:00', active: true },
  thu: { start: '08:00', end: '18:00', active: true },
  fri: { start: '08:00', end: '18:00', active: true },
  sat: { start: '09:00', end: '14:00', active: true },
  sun: { start: '09:00', end: '14:00', active: false },
})
</script>

<style scoped>
.set-page { max-width: 700px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.set-hero {
  background: linear-gradient(135deg, rgba(168,200,232,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(168,200,232,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; display: flex; flex-direction: column; gap: 14px; }
.card-title { font-size: 0.95rem; font-weight: 700; }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
@media (max-width: 600px) { .form-grid { grid-template-columns: 1fr; } }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; background: white; }
.fi:focus { border-color: var(--color-primary); }
.fi:disabled { opacity: 0.5; }

.logo-area { display: flex; align-items: center; gap: 16px; }
.logo-placeholder { width: 60px; height: 60px; border-radius: 12px; border: 2px dashed var(--color-border-light); display: flex; align-items: center; justify-content: center; color: var(--color-text-muted); }
.btn-upload { display: flex; align-items: center; gap: 6px; padding: 7px 14px; background: rgba(139,126,200,0.08); color: var(--color-primary); border: 1px solid rgba(139,126,200,0.15); border-radius: 10px; font-size: 0.78rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
.logo-hint { font-size: 0.7rem; color: var(--color-text-muted); margin-top: 4px; }

.hours-grid { display: flex; flex-direction: column; gap: 8px; }
.hours-row { display: flex; align-items: center; gap: 10px; }
.day-label { width: 28px; font-size: 0.82rem; font-weight: 600; }
.time-input { padding: 6px 10px; border: 1px solid var(--color-border-light); border-radius: 8px; font-size: 0.82rem; font-family: var(--font-mono); background: white; width: 88px; }
.time-sep { color: var(--color-text-muted); }
.day-toggle { display: flex; align-items: center; gap: 4px; font-size: 0.72rem; color: var(--color-text-muted); cursor: pointer; margin-left: auto; }
.day-toggle input { accent-color: var(--color-primary); }

.save-bar { display: flex; align-items: center; gap: 12px; }
.btn-save { padding: 10px 24px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-size: 0.88rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
.saved-msg { font-size: 0.82rem; color: var(--color-success); font-weight: 500; }
</style>

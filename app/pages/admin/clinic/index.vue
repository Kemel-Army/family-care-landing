<template>
  <div class="clinic-page">
    <div class="clinic-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="hero-title">Настройки клиники</h1>
      <p class="hero-sub">Брендинг, контакты и модули</p>
    </div>

    <form @submit.prevent="saved = true">
      <!-- Branding -->
      <div class="card">
        <h2 class="card-title"><Icon name="lucide:palette" size="16" /> Брендинг</h2>
        <div class="form-grid">
          <div class="fg"><label class="fl">Название</label><input v-model="form.name" class="fi" /></div>
          <div class="fg"><label class="fl">Slug</label><input v-model="form.slug" class="fi" /></div>
          <div class="fg span-2"><label class="fl">URL логотипа</label><input v-model="form.logo_url" class="fi" placeholder="https://..." /></div>
          <div class="fg"><label class="fl">Основной цвет</label><input v-model="form.primary_color" type="color" class="fc" /></div>
          <div class="fg"><label class="fl">Вторичный цвет</label><input v-model="form.secondary_color" type="color" class="fc" /></div>
        </div>
      </div>

      <!-- Contact -->
      <div class="card">
        <h2 class="card-title"><Icon name="lucide:phone" size="16" /> Контакты</h2>
        <div class="form-grid">
          <div class="fg"><label class="fl">Телефон</label><input v-model="form.phone" class="fi" /></div>
          <div class="fg"><label class="fl">Email</label><input v-model="form.email" type="email" class="fi" /></div>
          <div class="fg span-2"><label class="fl">Адрес</label><input v-model="form.address" class="fi" /></div>
        </div>
      </div>

      <!-- Features -->
      <div class="card">
        <h2 class="card-title"><Icon name="lucide:puzzle" size="16" /> Модули</h2>
        <div class="feat-list">
          <div v-for="f in features" :key="f.key" class="feat-row">
            <div class="feat-info">
              <span class="feat-name">{{ f.label }}</span>
              <span class="feat-desc">{{ f.desc }}</span>
            </div>
            <label class="toggle">
              <input v-model="form.features[f.key]" type="checkbox" />
              <span class="toggle-track" />
            </label>
          </div>
        </div>
      </div>

      <button type="submit" class="btn-save">
        <Icon name="lucide:save" size="16" /> Сохранить настройки
      </button>
      <span v-if="saved" class="saved-msg">✓ Сохранено</span>
    </form>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const saved = ref(false)

const form = reactive({
  name: 'Family Care Алматы',
  slug: 'familycare-almaty',
  logo_url: '',
  primary_color: '#8B7EC8',
  secondary_color: '#E8A0BF',
  phone: '+7 (727) 312-45-67',
  email: 'info@familycare.kz',
  address: 'г. Алматы, ул. Абая 52',
  features: { ai_assistant: true, telemedicine: true, mood_tracking: true, sos_button: false, gamification: true, lab_integration: false } as Record<string, boolean>,
})

const features = [
  { key: 'ai_assistant', label: 'AI-ассистент', desc: 'Чат-бот с медицинскими рекомендациями' },
  { key: 'telemedicine', label: 'Телемедицина', desc: 'Видеоконсультации с пациентами' },
  { key: 'mood_tracking', label: 'Трекер настроения', desc: 'EPDS-скрининг и мониторинг' },
  { key: 'sos_button', label: 'SOS-кнопка', desc: 'Экстренная связь для пациентов' },
  { key: 'gamification', label: 'Геймификация', desc: 'Ачивки и стрики для мотивации' },
  { key: 'lab_integration', label: 'Интеграция с лабораторией', desc: 'Автоимпорт результатов' },
]
</script>

<style scoped>
.clinic-page { max-width: 680px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.clinic-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.span-2 { grid-column: span 2; }
@media (max-width: 500px) { .form-grid { grid-template-columns: 1fr; } .span-2 { grid-column: span 1; } }

.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi {
  padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s;
}
.fi:focus { border-color: var(--color-primary); }
.fc { width: 56px; height: 36px; border: 1px solid var(--color-border-light); border-radius: 8px; cursor: pointer; padding: 2px; }

.feat-list { display: flex; flex-direction: column; gap: 2px; }
.feat-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--color-border-light); }
.feat-row:last-child { border-bottom: none; }
.feat-name { font-size: 0.88rem; font-weight: 600; display: block; }
.feat-desc { font-size: 0.72rem; color: var(--color-text-muted); }

.toggle { position: relative; display: inline-block; width: 42px; height: 24px; flex-shrink: 0; }
.toggle input { opacity: 0; width: 0; height: 0; }
.toggle-track { position: absolute; inset: 0; background: var(--color-border-light); border-radius: 24px; transition: background 0.2s; cursor: pointer; }
.toggle-track::before { content: ''; position: absolute; width: 18px; height: 18px; left: 3px; top: 3px; background: white; border-radius: 50%; transition: transform 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.toggle input:checked + .toggle-track { background: var(--color-primary); }
.toggle input:checked + .toggle-track::before { transform: translateX(18px); }

.btn-save {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  width: 100%; padding: 12px; background: var(--gradient-cta); color: white; border: none;
  border-radius: 12px; font-size: 0.95rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.saved-msg { display: block; text-align: center; font-size: 0.82rem; color: var(--color-success); margin-top: 8px; }
</style>

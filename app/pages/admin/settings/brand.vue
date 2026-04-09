<template>
  <div class="brand-page">
    <div class="brand-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Настройки</NuxtLink>
      <h1 class="hero-title">Бренд и White-label</h1>
      <p class="hero-sub">Настройте внешний вид приложения под вашу клинику</p>
    </div>

    <div class="brand-grid">
      <!-- Left column: form -->
      <div class="brand-form">
        <!-- Colors -->
        <div class="card">
          <h2 class="card-title"><Icon name="lucide:palette" size="16" /> Цветовая схема</h2>
          <div class="color-grid">
            <div v-for="c in colorFields" :key="c.key" class="color-field">
              <label class="fl">{{ c.label }}</label>
              <div class="color-picker-row">
                <input v-model="form[c.key]" type="color" class="fc" />
                <input v-model="form[c.key]" class="fi color-hex" maxlength="7" />
              </div>
            </div>
          </div>
        </div>

        <!-- Logo -->
        <div class="card">
          <h2 class="card-title"><Icon name="lucide:image" size="16" /> Логотип</h2>
          <div class="fg">
            <label class="fl">URL логотипа</label>
            <input v-model="form.logo_url" class="fi" placeholder="https://example.com/logo.svg" />
          </div>
          <div class="logo-preview-area">
            <img v-if="form.logo_url" :src="form.logo_url" alt="Логотип" class="logo-img" />
            <div v-else class="logo-placeholder">
              <Icon name="lucide:upload" size="24" />
              <span>Вставьте URL логотипа</span>
            </div>
          </div>
        </div>

        <!-- Display -->
        <div class="card">
          <h2 class="card-title"><Icon name="lucide:type" size="16" /> Отображение</h2>
          <div class="form-grid">
            <div class="fg"><label class="fl">Название клиники</label><input v-model="form.display_name" class="fi" /></div>
            <div class="fg"><label class="fl">Короткое имя</label><input v-model="form.short_name" class="fi" /></div>
          </div>
        </div>

        <button class="btn-save" @click="saved = true">
          <Icon name="lucide:save" size="16" /> Сохранить настройки
        </button>
        <span v-if="saved" class="saved-msg">✓ Изменения сохранены</span>
      </div>

      <!-- Right column: preview -->
      <div class="preview-col">
        <div class="card preview-card">
          <h2 class="card-title"><Icon name="lucide:eye" size="16" /> Предпросмотр</h2>

          <!-- Mini app preview -->
          <div class="preview-frame" :style="previewVars">
            <div class="pv-sidebar">
              <div class="pv-logo">
                <img v-if="form.logo_url" :src="form.logo_url" alt="" />
                <Icon v-else name="lucide:heart-pulse" size="18" />
                <span>{{ form.short_name || 'Клиника' }}</span>
              </div>
              <div class="pv-nav">
                <div class="pv-nav-item active"><Icon name="lucide:layout-dashboard" size="12" /> Дашборд</div>
                <div class="pv-nav-item"><Icon name="lucide:users" size="12" /> Семьи</div>
                <div class="pv-nav-item"><Icon name="lucide:calendar" size="12" /> Расписание</div>
              </div>
            </div>
            <div class="pv-main">
              <div class="pv-header">{{ form.display_name || 'Название клиники' }}</div>
              <div class="pv-kpi-row">
                <div class="pv-kpi"><span class="pv-kpi-val">30</span><span class="pv-kpi-label">Семей</span></div>
                <div class="pv-kpi"><span class="pv-kpi-val">85%</span><span class="pv-kpi-label">Adherence</span></div>
                <div class="pv-kpi"><span class="pv-kpi-val">6</span><span class="pv-kpi-label">Записей</span></div>
              </div>
              <div class="pv-btn">Новая запись</div>
            </div>
          </div>
        </div>

        <!-- Color tokens -->
        <div class="card">
          <h2 class="card-title"><Icon name="lucide:code-2" size="16" /> Токены</h2>
          <div class="token-list">
            <div v-for="c in colorFields" :key="c.key" class="token-row">
              <div class="token-swatch" :style="{ background: form[c.key] }" />
              <code>--color-{{ c.key.replace('_', '-') }}</code>
              <span class="token-val">{{ form[c.key] }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const saved = ref(false)

const form = reactive<Record<string, string>>({
  primary: '#8B7EC8',
  secondary: '#E8A0BF',
  accent: '#E8B84D',
  logo_url: '',
  display_name: 'Клиника «Мать и Дитя»',
  short_name: 'МиД',
})

const colorFields = [
  { key: 'primary', label: 'Основной' },
  { key: 'secondary', label: 'Вторичный' },
  { key: 'accent', label: 'Акцентный' },
]

const previewVars = computed(() => ({
  '--pv-primary': form.primary,
  '--pv-secondary': form.secondary,
  '--pv-accent': form.accent,
}))
</script>

<style scoped>
.brand-page { max-width: 960px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.brand-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.brand-grid { display: grid; grid-template-columns: 1fr 340px; gap: 16px; align-items: start; }
@media (max-width: 800px) { .brand-grid { grid-template-columns: 1fr; } }

.brand-form { display: flex; flex-direction: column; gap: 16px; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi {
  padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s;
}
.fi:focus { border-color: var(--color-primary); }

.color-grid { display: flex; flex-direction: column; gap: 12px; }
.color-field { display: flex; flex-direction: column; gap: 4px; }
.color-picker-row { display: flex; gap: 8px; align-items: center; }
.fc { width: 42px; height: 36px; border: 1px solid var(--color-border-light); border-radius: 8px; cursor: pointer; padding: 2px; flex-shrink: 0; }
.color-hex { width: 100px; font-family: var(--font-mono); }

.logo-preview-area { margin-top: 12px; display: flex; align-items: center; justify-content: center; border: 2px dashed var(--color-border-light); border-radius: 12px; min-height: 80px; padding: 12px; }
.logo-img { max-height: 48px; max-width: 200px; object-fit: contain; }
.logo-placeholder { display: flex; flex-direction: column; align-items: center; gap: 6px; color: var(--color-text-muted); font-size: 0.78rem; }

.btn-save {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  width: 100%; padding: 12px; background: var(--gradient-cta); color: white; border: none;
  border-radius: 12px; font-size: 0.95rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.saved-msg { display: block; text-align: center; font-size: 0.82rem; color: var(--color-success); margin-top: 8px; }

/* ─── Preview ─── */
.preview-col { display: flex; flex-direction: column; gap: 16px; position: sticky; top: 80px; }
.preview-card { padding: 16px; }
.preview-frame {
  border: 1px solid var(--color-border-light); border-radius: 10px; overflow: hidden;
  display: flex; min-height: 220px; font-size: 11px; background: #f7f7f9;
}
.pv-sidebar { width: 100px; background: white; border-right: 1px solid var(--color-border-light); padding: 10px 8px; display: flex; flex-direction: column; gap: 10px; }
.pv-logo { display: flex; align-items: center; gap: 4px; font-weight: 700; font-size: 10px; color: var(--pv-primary); }
.pv-logo img { height: 18px; width: auto; }
.pv-nav { display: flex; flex-direction: column; gap: 2px; }
.pv-nav-item { display: flex; align-items: center; gap: 4px; padding: 4px 6px; border-radius: 6px; font-size: 10px; color: var(--color-text-muted); }
.pv-nav-item.active { background: color-mix(in srgb, var(--pv-primary) 12%, transparent); color: var(--pv-primary); font-weight: 600; }
.pv-main { flex: 1; padding: 10px; display: flex; flex-direction: column; gap: 8px; }
.pv-header { font-weight: 700; font-size: 12px; }
.pv-kpi-row { display: flex; gap: 6px; }
.pv-kpi { flex: 1; background: white; border: 1px solid var(--color-border-light); border-radius: 8px; padding: 6px 8px; text-align: center; }
.pv-kpi-val { display: block; font-weight: 700; font-size: 14px; color: var(--pv-primary); }
.pv-kpi-label { font-size: 9px; color: var(--color-text-muted); }
.pv-btn {
  align-self: flex-start; padding: 5px 14px; border-radius: 8px; font-weight: 600;
  background: var(--pv-primary); color: white; font-size: 10px;
}

/* ─── Tokens ─── */
.token-list { display: flex; flex-direction: column; gap: 8px; }
.token-row { display: flex; align-items: center; gap: 8px; font-size: 0.78rem; }
.token-swatch { width: 20px; height: 20px; border-radius: 6px; border: 1px solid rgba(0,0,0,0.08); flex-shrink: 0; }
.token-row code { font-family: var(--font-mono); font-size: 0.72rem; color: var(--color-text-muted); }
.token-val { margin-left: auto; font-family: var(--font-mono); font-size: 0.72rem; }
</style>

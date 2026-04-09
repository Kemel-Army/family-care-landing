<template>
  <div class="pkg-page">
    <div class="pkg-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Сервисные пакеты</h1>
          <p class="hero-sub">Управление тарифами и подписками</p>
        </div>
        <button class="btn-create" @click="showCreate = true"><Icon name="lucide:plus" size="14" /> Создать пакет</button>
      </div>
    </div>

    <div class="pkg-grid">
      <div v-for="pkg in packages" :key="pkg.id" class="pkg-card" :class="{ featured: pkg.featured }">
        <div class="pkg-top">
          <h3>{{ pkg.name }}</h3>
          <span class="pkg-price">{{ pkg.price.toLocaleString('ru-RU') }} ₸</span>
        </div>
        <p class="pkg-desc">{{ pkg.desc }}</p>
        <div class="pkg-features">
          <div v-for="(f, i) in pkg.features" :key="i" class="pf"><Icon name="lucide:check" size="14" class="pf-icon" /> {{ f }}</div>
        </div>
        <div class="pkg-meta">
          <span>{{ pkg.families }} семей</span>
          <span>{{ pkg.months }} мес</span>
        </div>
        <div class="pkg-actions">
          <button class="btn-sm">Редактировать</button>
          <button class="btn-sm alt" @click="pkg.active = !pkg.active">{{ pkg.active ? 'Деактивировать' : 'Активировать' }}</button>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый пакет</h2>
          <div class="fg"><label class="fl">Название</label><input v-model="form.name" class="fi" /></div>
          <div class="fg"><label class="fl">Описание</label><textarea v-model="form.desc" rows="2" class="fi" /></div>
          <div class="form-row">
            <div class="fg"><label class="fl">Цена (₸)</label><input v-model.number="form.price" type="number" class="fi" /></div>
            <div class="fg"><label class="fl">Срок (мес)</label><input v-model.number="form.months" type="number" class="fi" /></div>
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showCreate = false">Отмена</button>
            <button class="btn-submit" @click="addPkg">Сохранить</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showCreate = ref(false)
const form = reactive({ name: '', desc: '', price: 0, months: 12 })

const packages = reactive([
  { id: 1, name: 'Базовый', desc: 'Основное наблюдение беременности', price: 150000, months: 9, families: 12, active: true, featured: false, features: ['Консультация гинеколога 1р/мес', 'УЗИ 3 раза', 'Базовые анализы'] },
  { id: 2, name: 'Стандарт', desc: 'Расширенное ведение с педиатром', price: 280000, months: 12, families: 23, active: true, featured: true, features: ['Гинеколог 2р/мес', 'Педиатр 1р/мес', 'УЗИ 5 раз', 'Полные анализы', 'AI-ассистент'] },
  { id: 3, name: 'Премиум', desc: 'VIP сопровождение семьи', price: 450000, months: 18, families: 8, active: true, featured: false, features: ['Неограниченные консультации', 'Телемедицина 24/7', 'Все анализы и УЗИ', 'Персональный координатор', 'SOS-кнопка'] },
])

function addPkg() {
  if (!form.name) return
  packages.push({ id: Date.now(), name: form.name, desc: form.desc, price: form.price, months: form.months, families: 0, active: true, featured: false, features: [] })
  showCreate.value = false
  form.name = ''; form.desc = ''; form.price = 0
}
</script>

<style scoped>
.pkg-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.pkg-hero {
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.btn-create { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }

.pkg-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(270px, 1fr)); gap: 14px; }
.pkg-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; display: flex; flex-direction: column; gap: 10px; }
.pkg-card.featured { border-color: var(--color-primary); box-shadow: 0 0 0 1px rgba(139,126,200,0.15); }
.pkg-top { display: flex; align-items: center; justify-content: space-between; }
.pkg-top h3 { font-size: 1rem; font-weight: 700; }
.pkg-price { font-size: 1.05rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); }
.pkg-desc { font-size: 0.82rem; color: var(--color-text-muted); }

.pkg-features { display: flex; flex-direction: column; gap: 4px; }
.pf { display: flex; align-items: center; gap: 6px; font-size: 0.82rem; }
.pf-icon { color: var(--color-success); flex-shrink: 0; }

.pkg-meta { display: flex; gap: 12px; font-size: 0.72rem; color: var(--color-text-muted); }
.pkg-actions { display: flex; gap: 8px; margin-top: auto; }
.btn-sm { padding: 6px 14px; background: white; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.78rem; cursor: pointer; font-family: var(--font-body); }
.btn-sm.alt { color: var(--color-text-muted); }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 480px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.form-row { display: flex; gap: 12px; }
.form-row .fg { flex: 1; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; resize: vertical; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

<template>
  <div class="tmpl-page">
    <div class="tmpl-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Шаблоны маршрутов</h1>
          <p class="hero-sub">Конструктор путей наблюдения</p>
        </div>
        <button class="btn-create" @click="showCreate = true"><Icon name="lucide:plus" size="14" /> Новый шаблон</button>
      </div>
    </div>

    <div class="tmpl-list">
      <div v-for="t in templates" :key="t.id" class="tmpl-card" :class="{ def: t.isDefault }">
        <div class="tmpl-top">
          <span class="tmpl-type" :class="t.type">{{ typeLabel(t.type) }}</span>
          <span v-if="t.isDefault" class="tmpl-badge">По умолчанию</span>
        </div>
        <h3>{{ t.name }}</h3>
        <p class="tmpl-desc">{{ t.desc }}</p>
        <div class="tmpl-stats">
          <span><Icon name="lucide:list" size="14" /> {{ t.events }} событий</span>
          <span><Icon name="lucide:shield-check" size="14" /> {{ t.mandatory }} обязательных</span>
        </div>
        <div class="tmpl-actions">
          <button class="btn-sm">Редактировать</button>
          <button v-if="!t.isDefault" class="btn-sm alt" @click="t.isDefault = true">Сделать по умол.</button>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый шаблон</h2>
          <div class="fg"><label class="fl">Название</label><input v-model="form.name" class="fi" placeholder="Беременность — стандартный" /></div>
          <div class="fg">
            <label class="fl">Тип</label>
            <select v-model="form.type" class="fi">
              <option value="pregnancy">Беременность</option>
              <option value="postpartum">Послеродовый</option>
              <option value="infant">Младенец (0–12 мес)</option>
              <option value="toddler">Тоддлер (12–24 мес)</option>
            </select>
          </div>
          <div class="fg"><label class="fl">Описание</label><textarea v-model="form.desc" rows="2" class="fi" /></div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showCreate = false">Отмена</button>
            <button class="btn-submit" @click="showCreate = false">Сохранить</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showCreate = ref(false)
const form = reactive({ name: '', type: 'pregnancy', desc: '' })

const typeLabel = (t: string) => ({ pregnancy: 'Беременность', postpartum: 'Послеродовый', infant: 'Младенец', toddler: 'Тоддлер' }[t] || t)

const templates = reactive([
  { id: 1, name: 'Стандартная беременность', desc: 'Полный маршрут ведения от 1 триместра до родов', type: 'pregnancy', events: 24, mandatory: 18, isDefault: true },
  { id: 2, name: 'Послеродовое восстановление', desc: '6-недельный план наблюдения мамы', type: 'postpartum', events: 12, mandatory: 8, isDefault: true },
  { id: 3, name: 'Наблюдение младенца', desc: 'Осмотры, прививки и скрининги до 12 месяцев', type: 'infant', events: 18, mandatory: 14, isDefault: true },
  { id: 4, name: 'Тоддлер — развитие', desc: 'Контрольные визиты и оценка развития 12–24 мес', type: 'toddler', events: 10, mandatory: 6, isDefault: false },
])
</script>

<style scoped>
.tmpl-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.tmpl-hero {
  background: linear-gradient(135deg, rgba(232,160,191,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(232,160,191,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.btn-create { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }

.tmpl-list { display: flex; flex-direction: column; gap: 10px; }
.tmpl-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px; }
.tmpl-card.def { border-color: var(--color-primary); box-shadow: 0 0 0 1px rgba(139,126,200,0.1); }

.tmpl-top { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
.tmpl-type { font-size: 0.68rem; font-weight: 600; padding: 2px 10px; border-radius: 20px; text-transform: uppercase; letter-spacing: 0.04em; }
.tmpl-type.pregnancy { background: rgba(232,160,191,0.15); color: #C27A9A; }
.tmpl-type.postpartum { background: rgba(139,126,200,0.15); color: var(--color-primary); }
.tmpl-type.infant { background: rgba(168,200,232,0.15); color: #6A9FC0; }
.tmpl-type.toddler { background: rgba(242,196,160,0.15); color: #C49570; }
.tmpl-badge { font-size: 0.68rem; font-weight: 600; color: var(--color-primary); }

.tmpl-card h3 { font-size: 0.95rem; font-weight: 700; }
.tmpl-desc { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 2px; }
.tmpl-stats { display: flex; gap: 16px; margin-top: 10px; font-size: 0.72rem; color: var(--color-text-muted); }
.tmpl-stats span { display: flex; align-items: center; gap: 4px; }

.tmpl-actions { display: flex; gap: 8px; margin-top: 10px; }
.btn-sm { padding: 5px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; background: white; font-size: 0.75rem; cursor: pointer; font-family: var(--font-body); }
.btn-sm.alt { color: var(--color-primary); border-color: rgba(139,126,200,0.2); }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 480px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; resize: vertical; background: white; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

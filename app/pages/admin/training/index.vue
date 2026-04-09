<template>
  <div class="trn-page">
    <div class="trn-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Обучение персонала</h1>
          <p class="hero-sub">Модули, прогресс и сертификация</p>
        </div>
        <button class="btn-create" @click="showCreate = true"><Icon name="lucide:plus" size="14" /> Добавить модуль</button>
      </div>
    </div>

    <!-- Progress overview -->
    <div class="card">
      <div class="prog-row">
        <span class="prog-label">Общий прогресс</span>
        <div class="prog-bar"><div class="prog-fill" :style="{ width: '73%' }" /></div>
        <span class="prog-pct">73%</span>
      </div>
      <div class="stat-row">
        <div class="stat"><span class="stat-num">6</span><span class="stat-lbl">модулей</span></div>
        <div class="stat"><span class="stat-num">38</span><span class="stat-lbl">пройдено</span></div>
        <div class="stat"><span class="stat-num">11</span><span class="stat-lbl">сертифицировано</span></div>
      </div>
    </div>

    <!-- Modules -->
    <div class="mod-list">
      <div v-for="m in modules" :key="m.id" class="mod-card">
        <div class="mod-icon" :class="m.type"><Icon :name="modIcon(m.type)" size="20" /></div>
        <div class="mod-body">
          <h3>{{ m.title }}</h3>
          <p>{{ m.desc }}</p>
          <div class="mod-meta">
            <span>{{ m.minutes }} мин</span>
            <span>{{ m.done }}/{{ m.total }} прошли</span>
          </div>
        </div>
        <div class="mod-ring">
          <svg viewBox="0 0 36 36">
            <circle cx="18" cy="18" r="15" fill="none" stroke="rgba(139,126,200,0.1)" stroke-width="3" />
            <circle cx="18" cy="18" r="15" fill="none" stroke="var(--color-primary)" stroke-width="3"
              stroke-linecap="round" :stroke-dasharray="`${m.pct * 0.94} 94`" transform="rotate(-90 18 18)" />
          </svg>
          <span class="ring-pct">{{ m.pct }}%</span>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый модуль</h2>
          <div class="fg"><label class="fl">Название</label><input v-model="form.title" class="fi" /></div>
          <div class="fg"><label class="fl">Описание</label><textarea v-model="form.desc" rows="2" class="fi" /></div>
          <div class="form-row">
            <div class="fg">
              <label class="fl">Тип</label>
              <select v-model="form.type" class="fi">
                <option value="video">Видео</option>
                <option value="article">Статья</option>
                <option value="quiz">Тест</option>
                <option value="checklist">Чеклист</option>
              </select>
            </div>
            <div class="fg"><label class="fl">Длительность (мин)</label><input v-model.number="form.minutes" type="number" class="fi" /></div>
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showCreate = false">Отмена</button>
            <button class="btn-submit" @click="showCreate = false">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showCreate = ref(false)
const form = reactive({ title: '', desc: '', type: 'video', minutes: 30 })

const modIcon = (t: string) => ({ video: 'lucide:video', article: 'lucide:file-text', quiz: 'lucide:help-circle', checklist: 'lucide:check-square' }[t] || 'lucide:book-open')

const modules = [
  { id: 1, title: 'Протокол ведения беременности', desc: 'Стандартный маршрут наблюдения по триместрам', type: 'video', minutes: 45, done: 12, total: 14, pct: 86 },
  { id: 2, title: 'Работа с AI-ассистентом', desc: 'Как использовать AI-рекомендации в карточке пациента', type: 'article', minutes: 20, done: 10, total: 14, pct: 71 },
  { id: 3, title: 'Тест по GDM-скринингу', desc: 'Проверка знаний по протоколу гестационного диабета', type: 'quiz', minutes: 15, done: 8, total: 14, pct: 57 },
  { id: 4, title: 'Координация маршрута', desc: 'Чеклист для координатора по каждому этапу', type: 'checklist', minutes: 30, done: 14, total: 14, pct: 100 },
  { id: 5, title: 'Телемедицина: инструкция', desc: 'Как проводить видео-консультации через платформу', type: 'video', minutes: 25, done: 9, total: 14, pct: 64 },
  { id: 6, title: 'NPS и работа с отзывами', desc: 'Как собирать обратную связь от семей', type: 'article', minutes: 15, done: 11, total: 14, pct: 79 },
]
</script>

<style scoped>
.trn-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.trn-hero {
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.btn-create { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.prog-row { display: flex; align-items: center; gap: 12px; margin-bottom: 14px; }
.prog-label { font-size: 0.82rem; font-weight: 600; width: 120px; flex-shrink: 0; }
.prog-bar { flex: 1; height: 8px; background: rgba(139,126,200,0.08); border-radius: 4px; overflow: hidden; }
.prog-fill { height: 100%; background: var(--gradient-cta); border-radius: 4px; }
.prog-pct { font-size: 0.82rem; font-weight: 700; font-family: var(--font-mono); width: 36px; text-align: right; }

.stat-row { display: flex; gap: 24px; }
.stat { display: flex; flex-direction: column; }
.stat-num { font-size: 1.1rem; font-weight: 700; font-family: var(--font-mono); }
.stat-lbl { font-size: 0.72rem; color: var(--color-text-muted); }

.mod-list { display: flex; flex-direction: column; gap: 10px; }
.mod-card { display: flex; align-items: center; gap: 14px; padding: 16px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; }
.mod-icon { width: 42px; height: 42px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; background: rgba(139,126,200,0.08); color: var(--color-primary); }
.mod-icon.quiz { background: rgba(233,196,106,0.12); color: var(--color-warning); }
.mod-icon.checklist { background: rgba(124,184,212,0.12); color: var(--color-success); }

.mod-body { flex: 1; }
.mod-body h3 { font-size: 0.92rem; font-weight: 700; }
.mod-body p { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 2px; }
.mod-meta { display: flex; gap: 12px; margin-top: 4px; font-size: 0.72rem; color: var(--color-text-muted); }

.mod-ring { position: relative; width: 46px; height: 46px; flex-shrink: 0; }
.mod-ring svg { width: 100%; height: 100%; }
.ring-pct { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 0.62rem; font-weight: 700; font-family: var(--font-mono); }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 480px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.form-row { display: flex; gap: 12px; }
.form-row .fg { flex: 1; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; resize: vertical; background: white; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

<template>
  <div class="fd-page">
    <!-- Hero -->
    <div class="fd-hero">
      <NuxtLink to="/coordinator/families" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Семьи</NuxtLink>
      <div class="hero-row">
        <div class="hero-avatar">{{ initials }}</div>
        <div>
          <h1 class="hero-title">{{ family.motherName }}</h1>
          <p class="hero-sub">{{ family.phone }} · Зарегистрирована {{ family.regDate }}</p>
        </div>
      </div>
      <div class="stat-chips">
        <span class="chip"><Icon name="lucide:heart" size="14" /> Маршруты: <strong>2</strong></span>
        <span class="chip"><Icon name="lucide:baby" size="14" /> Детей: <strong>{{ children.length }}</strong></span>
        <span class="chip" :class="{ warn: overdueEvents.length }"><Icon name="lucide:alert-triangle" size="14" /> Просрочено: <strong>{{ overdueEvents.length }}</strong></span>
      </div>
    </div>

    <!-- Children -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:baby" size="16" /> Дети</h2>
      <div v-for="c in children" :key="c.id" class="child-row">
        <div class="child-avatar">{{ c.name[0] }}</div>
        <div class="child-info">
          <span class="child-name">{{ c.name }}</span>
          <span class="child-age">{{ c.age }}</span>
        </div>
      </div>
    </div>

    <!-- Journeys -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:route" size="16" /> Маршруты</h2>
      <div v-for="j in journeys" :key="j.id" class="journey-row">
        <span class="j-badge" :class="j.type">{{ j.label }}</span>
        <div class="j-bar-wrap">
          <div class="j-bar" :style="{ width: j.progress + '%' }" />
        </div>
        <span class="j-pct">{{ j.progress }}%</span>
      </div>
    </div>

    <!-- Overdue events -->
    <div v-if="overdueEvents.length" class="card card-warn">
      <h2 class="card-title"><Icon name="lucide:alert-triangle" size="16" class="ic-warn" /> Просроченные события</h2>
      <div v-for="e in overdueEvents" :key="e.id" class="ev-row">
        <span>{{ e.title }}</span>
        <span class="ev-date">{{ e.dueDate }}</span>
      </div>
    </div>

    <!-- Documents -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:folder" size="16" /> Документы</h2>
      <div v-for="d in docs" :key="d.id" class="doc-row">
        <Icon :name="d.icon" size="14" class="doc-ic" />
        <span class="doc-name">{{ d.title }}</span>
        <span class="doc-date">{{ d.date }}</span>
      </div>
      <p v-if="!docs.length" class="empty-mini">Документов пока нет</p>
    </div>

    <!-- Actions -->
    <div class="actions-row">
      <button class="btn-action" @click="showTask = true"><Icon name="lucide:plus" size="14" /> Создать задачу</button>
      <a :href="`tel:${family.phone}`" class="btn-sec"><Icon name="lucide:phone" size="14" /> Позвонить</a>
    </div>

    <!-- Task modal -->
    <Teleport to="body">
      <div v-if="showTask" class="modal-overlay" @click.self="showTask = false">
        <div class="modal-card">
          <h2 class="modal-title">Новая задача</h2>
          <div class="fg"><label class="fl">Заголовок</label><input v-model="taskForm.title" class="fi" placeholder="Позвонить маме..." /></div>
          <div class="fg"><label class="fl">Описание</label><textarea v-model="taskForm.desc" class="fi" rows="2" placeholder="Подробности..." /></div>
          <div class="fg-row">
            <div class="fg">
              <label class="fl">Приоритет</label>
              <select v-model="taskForm.priority" class="fi">
                <option value="low">Низкий</option>
                <option value="medium">Средний</option>
                <option value="high">Высокий</option>
              </select>
            </div>
            <div class="fg">
              <label class="fl">Тип</label>
              <select v-model="taskForm.type" class="fi">
                <option value="custom">Обычная</option>
                <option value="overdue_followup">Просрочка</option>
                <option value="vaccination_reminder">Прививка</option>
                <option value="welcome_call">Приветствие</option>
              </select>
            </div>
          </div>
          <div class="fg"><label class="fl">Срок</label><input v-model="taskForm.due" type="date" class="fi" /></div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showTask = false">Отмена</button>
            <button class="btn-submit" @click="showTask = false">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showTask = ref(false)
const taskForm = reactive({ title: '', desc: '', priority: 'medium', type: 'custom', due: '' })

const family = {
  motherName: 'Айгуль Нурланова',
  phone: '+7 (707) 312-45-67',
  regDate: '14 января 2026',
}

const initials = computed(() => family.motherName.split(' ').map(w => w[0]).join(''))

const children = [
  { id: 1, name: 'Адиль', age: '2 года 3 мес' },
  { id: 2, name: 'Амина', age: '4 месяца' },
]

const journeys = [
  { id: 1, type: 'postpartum', label: 'Послеродовой', progress: 68 },
  { id: 2, type: 'infant', label: 'Младенец', progress: 35 },
]

const overdueEvents = [
  { id: 1, title: 'Осмотр педиатра — Амина', dueDate: '8 мая' },
  { id: 2, title: 'Анализ крови — Айгуль', dueDate: '5 мая' },
]

const docs = [
  { id: 1, title: 'УЗИ — Амина (3 мес)', date: '28 апр', icon: 'lucide:monitor' },
  { id: 2, title: 'Выписка из роддома', date: '15 янв', icon: 'lucide:file-output' },
  { id: 3, title: 'Общий анализ крови', date: '10 янв', icon: 'lucide:test-tubes' },
]
</script>

<style scoped>
.fd-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 14px; }

.fd-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 10px; }
.hero-row { display: flex; align-items: center; gap: 14px; }
.hero-avatar { width: 48px; height: 48px; border-radius: 50%; background: var(--gradient-cta); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; flex-shrink: 0; }
.hero-title { font-family: var(--font-display); font-size: 1.3rem; font-weight: 700; }
.hero-sub { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 2px; }
.stat-chips { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 14px; }
.chip { display: flex; align-items: center; gap: 5px; padding: 4px 12px; background: rgba(139,126,200,0.06); border-radius: 20px; font-size: 0.75rem; color: var(--color-text-muted); }
.chip strong { color: var(--color-text); }
.chip.warn strong { color: var(--color-danger); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px; }
.card-warn { border-color: rgba(212,114,124,0.25); background: rgba(212,114,124,0.02); }
.card-title { font-size: 0.92rem; font-weight: 700; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
.ic-warn { color: var(--color-danger); }

.child-row { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--color-border-light); }
.child-row:last-child { border: none; }
.child-avatar { width: 32px; height: 32px; border-radius: 50%; background: rgba(168,200,232,0.15); color: var(--color-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.78rem; flex-shrink: 0; }
.child-info { display: flex; flex-direction: column; }
.child-name { font-weight: 600; font-size: 0.88rem; }
.child-age { font-size: 0.72rem; color: var(--color-text-muted); }

.journey-row { display: flex; align-items: center; gap: 10px; padding: 7px 0; }
.j-badge { font-size: 0.72rem; font-weight: 600; padding: 3px 10px; border-radius: 10px; min-width: 100px; text-align: center; }
.j-badge.postpartum { background: rgba(232,160,191,0.12); color: #C27BA0; }
.j-badge.infant { background: rgba(168,200,232,0.12); color: #6B9AC4; }
.j-badge.pregnancy { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.j-badge.toddler { background: rgba(242,196,160,0.15); color: #C49A6C; }
.j-bar-wrap { flex: 1; height: 6px; background: rgba(139,126,200,0.08); border-radius: 3px; overflow: hidden; }
.j-bar { height: 100%; background: var(--gradient-cta); border-radius: 3px; transition: width 0.4s ease; }
.j-pct { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); min-width: 36px; text-align: right; }

.ev-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 0.82rem; border-bottom: 1px solid rgba(212,114,124,0.08); }
.ev-row:last-child { border: none; }
.ev-date { font-size: 0.75rem; color: var(--color-danger); font-weight: 500; }

.doc-row { display: flex; align-items: center; gap: 8px; padding: 6px 0; font-size: 0.82rem; border-bottom: 1px solid var(--color-border-light); }
.doc-row:last-child { border: none; }
.doc-ic { color: var(--color-text-muted); flex-shrink: 0; }
.doc-name { flex: 1; font-weight: 500; }
.doc-date { font-size: 0.72rem; color: var(--color-text-muted); }
.empty-mini { text-align: center; padding: 12px; font-size: 0.82rem; color: var(--color-text-muted); }

.actions-row { display: flex; gap: 8px; flex-wrap: wrap; }
.btn-action { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }
.btn-sec { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: white; color: var(--color-primary); border: 1px solid var(--color-primary); border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); text-decoration: none; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 460px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fg-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; background: white; resize: vertical; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

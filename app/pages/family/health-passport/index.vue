<template>
  <div class="hp-page">
    <!-- Hero -->
    <div class="hp-hero">
      <div>
        <h1 class="hp-hero-title">Паспорт здоровья</h1>
        <p class="hp-hero-sub">{{ appData.children[0]!.first_name }} · {{ entries.length }} записей</p>
      </div>
      <button class="hp-hero-btn" @click="showAdd = !showAdd">
        <Icon :name="showAdd ? 'lucide:x' : 'lucide:plus'" size="15" />
      </button>
    </div>

    <!-- Summary -->
    <div class="hp-strip">
      <div class="hp-chip"><Icon name="lucide:droplet" size="14" /> {{ passport.blood_type }}</div>
      <div class="hp-chip"><Icon name="lucide:alert-triangle" size="14" /> {{ passport.allergies }} аллергий</div>
      <div class="hp-chip"><Icon name="lucide:activity" size="14" /> {{ passport.chronic }} хрон.</div>
    </div>

    <!-- Add form -->
    <Transition name="slide">
      <div v-if="showAdd" class="card hp-form">
        <h3 class="hp-form-title">Новая запись</h3>
        <div class="hp-form-grid">
          <select v-model="newEntry.type" class="hp-input">
            <option value="diagnosis">Диагноз</option>
            <option value="allergy">Аллергия</option>
            <option value="surgery">Операция</option>
            <option value="note">Заметка</option>
          </select>
          <input v-model="newEntry.title" placeholder="Название" class="hp-input" />
          <input v-model="newEntry.date" type="date" class="hp-input" />
        </div>
        <textarea v-model="newEntry.description" placeholder="Описание..." rows="2" class="hp-input hp-textarea" />
        <div class="hp-form-actions">
          <button class="hp-btn-cancel" @click="showAdd = false">Отмена</button>
          <button class="hp-btn-save" @click="addEntry">Сохранить</button>
        </div>
      </div>
    </Transition>

    <!-- Entries -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:file-text" size="16" /> Медицинские записи</h2>
      </div>
      <div v-if="entries.length" class="hp-list">
        <div v-for="e in entries" :key="e.id" class="hp-row">
          <div class="hp-icon" :class="`hp-icon--${e.type}`">
            <Icon :name="entryIcon(e.type)" size="14" />
          </div>
          <div class="hp-info">
            <span class="hp-name">{{ e.title }}</span>
            <span v-if="e.description" class="hp-desc">{{ e.description }}</span>
            <span class="hp-meta">{{ e.date }}</span>
          </div>
          <span class="hp-type-badge">{{ typeLabel(e.type) }}</span>
        </div>
      </div>
      <AppSharedEmptyState v-else icon="lucide:file-text" title="Паспорт здоровья пока пуст" />
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const appData = useAppData()
const showAdd = ref(false)

const passport = reactive({ blood_type: appData.children[0]?.blood_type ?? 'N/A', allergies: 1, chronic: 0 })

const entries = ref([
  { id: '1', type: 'allergy', title: 'Пищевая аллергия — яичный белок', description: 'Сыпь, отёк. Рекомендована элиминационная диета.', date: '2026-03-10' },
  { id: '2', type: 'diagnosis', title: 'Физиологическая желтуха', description: 'Разрешилась к 14 дню.', date: '2026-01-20' },
  { id: '3', type: 'note', title: 'Осмотр невролога', description: 'Норма. Физическое развитие по возрасту.', date: '2026-02-15' },
])

const newEntry = reactive({ type: 'diagnosis', title: '', description: '', date: new Date().toISOString().slice(0, 10) })

function addEntry() {
  if (!newEntry.title) return
  entries.value.unshift({ id: String(Date.now()), type: newEntry.type, title: newEntry.title, description: newEntry.description, date: newEntry.date })
  newEntry.title = ''; newEntry.description = ''
  showAdd.value = false
}

function entryIcon(type: string) {
  const m: Record<string, string> = { diagnosis: 'lucide:stethoscope', allergy: 'lucide:alert-triangle', surgery: 'lucide:scissors', note: 'lucide:file-text' }
  return m[type] || 'lucide:file-text'
}

function typeLabel(type: string) {
  const m: Record<string, string> = { diagnosis: 'Диагноз', allergy: 'Аллергия', surgery: 'Операция', note: 'Заметка' }
  return m[type] || type
}
</script>

<style scoped>
.hp-page { max-width: 720px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.hp-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(232,160,191,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(232,160,191,0.12); border-radius: 16px; padding: 24px 28px;
}
.hp-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hp-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.hp-hero-btn {
  width: 40px; height: 40px; border-radius: 50%; border: 1px solid var(--color-border-light);
  background: white; display: flex; align-items: center; justify-content: center; cursor: pointer;
}

.hp-strip { display: flex; gap: 10px; flex-wrap: wrap; }
.hp-chip {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.78rem; color: var(--color-text-secondary); font-weight: 500;
}

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.hp-form { display: flex; flex-direction: column; gap: 10px; }
.hp-form-title { font-size: 0.9rem; font-weight: 600; }
.hp-form-grid { display: flex; gap: 8px; }
.hp-input {
  flex: 1; padding: 10px 12px; border: 1px solid var(--color-border-light); border-radius: 10px;
  font-size: 0.82rem; font-family: var(--font-body); outline: none;
}
.hp-input:focus { border-color: var(--color-primary); }
.hp-textarea { resize: none; }
.hp-form-actions { display: flex; gap: 8px; justify-content: flex-end; }
.hp-btn-cancel { padding: 8px 16px; border: 1px solid var(--color-border-light); background: white; border-radius: 10px; cursor: pointer; font-family: var(--font-body); font-size: 0.82rem; }
.hp-btn-save { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); font-size: 0.82rem; }

.hp-list { display: flex; flex-direction: column; gap: 4px; }
.hp-row { display: flex; align-items: flex-start; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.hp-row:hover { background: rgba(139,126,200,0.04); }

.hp-icon {
  width: 32px; height: 32px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  background: rgba(139,126,200,0.08); color: var(--color-primary);
}
.hp-icon--allergy { background: rgba(233,196,106,0.12); color: var(--color-warning); }
.hp-icon--surgery { background: rgba(212,114,124,0.1); color: var(--color-danger); }

.hp-info { flex: 1; min-width: 0; }
.hp-name { display: block; font-size: 0.85rem; font-weight: 500; }
.hp-desc { display: block; font-size: 0.75rem; color: var(--color-text-muted); margin-top: 2px; }
.hp-meta { display: block; font-size: 0.68rem; color: var(--color-text-muted); margin-top: 2px; }
.hp-type-badge { font-size: 0.62rem; font-weight: 600; padding: 3px 8px; border-radius: var(--radius-full); background: rgba(139,126,200,0.06); color: var(--color-text-muted); flex-shrink: 0; margin-top: 2px; }

.hp-empty { text-align: center; padding: 32px 16px; color: var(--color-text-muted); font-size: 0.85rem; }
.hp-empty p { margin-top: 8px; }

.slide-enter-active, .slide-leave-active { transition: all 0.25s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; transform: translateY(-8px); }
</style>

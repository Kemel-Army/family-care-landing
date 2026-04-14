<template>
  <div class="nutr-page">
    <!-- Hero -->
    <div class="nutr-hero">
      <div>
        <h1 class="nutr-hero-title">Питание</h1>
        <p class="nutr-hero-sub">{{ childName }} · {{ appData.feedingToday.length }} кормлений сегодня</p>
      </div>
      <div class="nutr-hero-right">
        <div class="nutr-hero-stat">
          <Icon name="lucide:flame" size="16" style="color: var(--color-warning)" />
          <span class="nutr-hero-streak">{{ appData.streaks.feeding.current }} дн</span>
        </div>
        <button class="btn-log" @click="showFeedModal = true">
          <Icon name="lucide:plus" size="15" /> Записать
        </button>
      </div>
    </div>

    <!-- Today's feedings -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:list" size="16" /> Сегодня</h2>
        <button class="card-action-btn" @click="showFeedModal = true">
          <Icon name="lucide:plus" size="14" /> Добавить
        </button>
      </div>
      <div v-if="appData.feedingToday.length" class="nutr-list">
        <div v-for="f in appData.feedingToday" :key="f.id" class="nutr-row">
          <div class="nutr-icon" :class="`nutr-icon--${f.type}`">
            <span>{{ typeEmoji(f.type) }}</span>
          </div>
          <div class="nutr-info">
            <span class="nutr-name">{{ typeLabel(f.type) }}</span>
            <span class="nutr-meta">
              <template v-if="f.duration">{{ f.duration }} мин<template v-if="f.side"> · {{ f.side }}</template></template>
              <template v-if="f.food">{{ f.food }}<template v-if="f.amount"> · {{ f.amount }}</template></template>
            </span>
          </div>
          <span class="nutr-time">{{ f.time }}</span>
        </div>
      </div>
      <div v-else class="no-entries">
        <span style="font-size:1.6rem">🍼</span>
        <p>Нет записей кормления на сегодня</p>
        <button class="btn-log-inline" @click="showFeedModal = true">Записать первое</button>
      </div>
    </div>

    <!-- Food intro -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:apple" size="16" /> Прикорм ({{ appData.foodIntros.length }})</h2>
        <button class="card-action-btn" @click="showIntroModal = true">
          <Icon name="lucide:plus" size="14" /> Добавить
        </button>
      </div>
      <div v-if="appData.foodIntros.length" class="food-tags">
        <span
          v-for="item in appData.foodIntros"
          :key="item.id"
          class="food-tag"
          :class="introTagClass(item.status)"
          :title="item.reaction ? `Реакция: ${item.reaction}` : item.food"
        >
          {{ item.food }}
          <Icon v-if="item.status === 'reaction'" name="lucide:alert-triangle" size="11" />
          <Icon v-else-if="item.status === 'rejected'" name="lucide:x" size="11" />
        </span>
      </div>
      <div v-else class="no-entries">
        <span style="font-size:1.4rem">🥣</span>
        <p>Прикорм ещё не начат</p>
        <button class="btn-log-inline" @click="showIntroModal = true">Добавить первый продукт</button>
      </div>

      <!-- Legend -->
      <div v-if="appData.foodIntros.length" class="intro-legend">
        <span class="legend-item"><span class="legend-chip legend-chip--ok" />Принят</span>
        <span class="legend-item"><span class="legend-chip legend-chip--reaction" />Реакция</span>
        <span class="legend-item"><span class="legend-chip legend-chip--rejected" />Не принят</span>
        <span class="legend-item"><span class="legend-chip legend-chip--pending" />В ожидании</span>
      </div>
    </div>

    <!-- Log Feeding Modal -->
    <Teleport to="body">
      <div v-if="showFeedModal" class="modal-overlay" @click.self="showFeedModal = false">
        <div class="modal-card">
          <div class="modal-header">
            <h2 class="modal-title"><span>🍼</span> Записать кормление</h2>
            <button class="btn-close" @click="showFeedModal = false"><Icon name="lucide:x" size="18" /></button>
          </div>

          <div class="fg">
            <label class="fl">Тип</label>
            <div class="type-toggle">
              <button v-for="t in feedTypes" :key="t.value" class="type-btn" :class="{ active: feedForm.type === t.value }" @click="feedForm.type = t.value">
                <span>{{ t.emoji }}</span> {{ t.label }}
              </button>
            </div>
          </div>

          <template v-if="feedForm.type === 'breast'">
            <div class="form-row-2">
              <div class="fg">
                <label class="fl">Сторона</label>
                <div class="type-toggle">
                  <button class="type-btn" :class="{ active: feedForm.side === 'L' }" @click="feedForm.side = 'L'">Лев</button>
                  <button class="type-btn" :class="{ active: feedForm.side === 'R' }" @click="feedForm.side = 'R'">Прав</button>
                  <button class="type-btn" :class="{ active: feedForm.side === 'Both' }" @click="feedForm.side = 'Both'">Обе</button>
                </div>
              </div>
              <div class="fg">
                <label class="fl">Продолжительность, мин</label>
                <input v-model.number="feedForm.duration" type="number" min="1" max="120" class="fi" placeholder="15" />
              </div>
            </div>
          </template>

          <template v-else-if="feedForm.type === 'solid'">
            <div class="form-row-2">
              <div class="fg">
                <label class="fl">Продукт</label>
                <input v-model="feedForm.food" type="text" class="fi" placeholder="Пюре кабачок..." />
              </div>
              <div class="fg">
                <label class="fl">Количество, мл/г</label>
                <input v-model="feedForm.amount" type="text" class="fi" placeholder="50 мл" />
              </div>
            </div>
          </template>

          <template v-else>
            <div class="fg">
              <label class="fl">Объём, мл</label>
              <input v-model="feedForm.amount" type="text" class="fi" placeholder="120 мл" />
            </div>
          </template>

          <div class="fg">
            <label class="fl">Заметка</label>
            <input v-model="feedForm.notes" type="text" class="fi" placeholder="Необязательно..." />
          </div>

          <div class="modal-actions">
            <button class="btn-cancel" @click="showFeedModal = false">Отмена</button>
            <button class="btn-submit" :disabled="saving" @click="saveFeed">
              {{ saving ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Food Intro Modal -->
    <Teleport to="body">
      <div v-if="showIntroModal" class="modal-overlay" @click.self="showIntroModal = false">
        <div class="modal-card">
          <div class="modal-header">
            <h2 class="modal-title"><span>🥣</span> Новый продукт</h2>
            <button class="btn-close" @click="showIntroModal = false"><Icon name="lucide:x" size="18" /></button>
          </div>

          <div class="form-row-2">
            <div class="fg">
              <label class="fl">Продукт</label>
              <input v-model="introForm.food" type="text" class="fi" placeholder="Кабачок..." />
            </div>
            <div class="fg">
              <label class="fl">Дата введения</label>
              <input v-model="introForm.introduced_at" type="date" class="fi" />
            </div>
          </div>

          <div class="fg">
            <label class="fl">Результат</label>
            <div class="type-toggle">
              <button v-for="s in introStatuses" :key="s.value" class="type-btn" :class="{ active: introForm.status === s.value }" @click="introForm.status = s.value">
                {{ s.label }}
              </button>
            </div>
          </div>

          <div v-if="introForm.status === 'reaction'" class="fg">
            <label class="fl">Описание реакции</label>
            <input v-model="introForm.reaction" type="text" class="fi" placeholder="Покраснение, сыпь..." />
          </div>

          <div class="fg">
            <label class="fl">Заметка</label>
            <input v-model="introForm.notes" type="text" class="fi" placeholder="Необязательно..." />
          </div>

          <div class="modal-actions">
            <button class="btn-cancel" @click="showIntroModal = false">Отмена</button>
            <button class="btn-submit" :disabled="!introForm.food || savingIntro" @click="saveIntro">
              {{ savingIntro ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const appData = useAppData()
const authStore = useAuthStore()
const sb = useSupabaseClient()

const childName = computed(() => appData.children[0]?.first_name || 'Ребёнок')

function typeEmoji(t: string) {
  const m: Record<string, string> = { breast: '🤱', bottle: '🍼', formula: '🥛', solid: '🥣' }
  return m[t] || '🍽️'
}
function typeLabel(t: string) {
  const m: Record<string, string> = { breast: 'Грудь', bottle: 'Бутылочка', formula: 'Смесь', solid: 'Прикорм' }
  return m[t] || t
}

function introTagClass(status: string) {
  return {
    'food-tag--ok': status === 'accepted',
    'food-tag--reaction': status === 'reaction',
    'food-tag--rejected': status === 'rejected',
    'food-tag--pending': status === 'pending',
  }
}

const feedTypes = [
  { value: 'breast', label: 'Грудь', emoji: '🤱' },
  { value: 'bottle', label: 'Бутылка', emoji: '🍼' },
  { value: 'formula', label: 'Смесь', emoji: '🥛' },
  { value: 'solid', label: 'Прикорм', emoji: '🥣' },
]

const introStatuses = [
  { value: 'accepted', label: '✅ Принят' },
  { value: 'pending', label: '⏳ Ожидание' },
  { value: 'reaction', label: '⚠️ Реакция' },
  { value: 'rejected', label: '❌ Не принят' },
]

// Feed modal
const showFeedModal = ref(false)
const saving = ref(false)
const { success: toastSuccess } = useToast()

const feedForm = reactive({
  type: 'breast' as string,
  side: 'L' as string,
  duration: null as number | null,
  food: '',
  amount: '',
  notes: '',
})

async function saveFeed() {
  const childId = authStore.children?.[0]?.id
  if (!childId) return
  saving.value = true
  try {
    const details: Record<string, any> = {}
    if (feedForm.side) details.side = feedForm.side
    if (feedForm.food) details.food = feedForm.food
    if (feedForm.amount) details.amount = feedForm.amount
    if (feedForm.notes) details.notes = feedForm.notes

    await sb.from('feeding_logs').insert({
      child_id: childId,
      timestamp: new Date().toISOString(),
      type: feedForm.type,
      duration_minutes: feedForm.duration || null,
      details,
    })
    await appData.fetchAll()
    showFeedModal.value = false
    toastSuccess('Кормление записано!')
    Object.assign(feedForm, { type: 'breast', side: 'L', duration: null, food: '', amount: '', notes: '' })
  }
  catch (e) { console.error(e) }
  finally { saving.value = false }
}

// Intro modal
const showIntroModal = ref(false)
const savingIntro = ref(false)

const introForm = reactive({
  food: '',
  introduced_at: new Date().toISOString().slice(0, 10),
  status: 'accepted' as string,
  reaction: '',
  notes: '',
})

async function saveIntro() {
  if (!introForm.food) return
  const childId = authStore.children?.[0]?.id
  if (!childId) return
  savingIntro.value = true
  try {
    await sb.from('food_introductions').insert({
      child_id: childId,
      food: introForm.food,
      introduced_at: introForm.introduced_at,
      status: introForm.status,
      reaction: introForm.reaction || null,
      notes: introForm.notes || null,
    })
    await appData.fetchFoodIntros(childId)
    showIntroModal.value = false
    toastSuccess(`${introForm.food} добавлен!`)
    Object.assign(introForm, { food: '', introduced_at: new Date().toISOString().slice(0, 10), status: 'accepted', reaction: '', notes: '' })
  }
  catch (e) { console.error(e) }
  finally { savingIntro.value = false }
}
</script>

<style scoped>
.nutr-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.nutr-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.nutr-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.nutr-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.nutr-hero-right { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }
.nutr-hero-stat { display: flex; align-items: center; gap: 6px; }
.nutr-hero-streak { font-size: 1rem; font-weight: 700; font-family: var(--font-mono); }
.btn-log {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: var(--gradient-cta); color: white; border-radius: 10px;
  font-size: 0.78rem; font-weight: 600; border: none; cursor: pointer;
}

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.card-action-btn { font-size: 0.72rem; font-weight: 600; color: var(--color-primary); display: flex; align-items: center; gap: 4px; background: rgba(139,126,200,0.08); border: none; cursor: pointer; padding: 5px 12px; border-radius: 8px; }

.nutr-list { display: flex; flex-direction: column; gap: 4px; }
.nutr-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.nutr-row:hover { background: rgba(242,196,160,0.04); }
.nutr-icon { width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 1.1rem; }
.nutr-icon--breast { background: rgba(232,160,191,0.1); }
.nutr-icon--solid { background: rgba(242,196,160,0.1); }
.nutr-icon--bottle, .nutr-icon--formula { background: rgba(168,200,232,0.1); }
.nutr-info { flex: 1; min-width: 0; }
.nutr-name { display: block; font-size: 0.85rem; font-weight: 500; }
.nutr-meta { display: block; font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }
.nutr-time { font-size: 0.78rem; font-family: var(--font-mono); color: var(--color-text-secondary); }

.food-tags { display: flex; gap: 8px; flex-wrap: wrap; }
.food-tag {
  padding: 6px 14px; border-radius: 20px; font-size: 0.78rem; font-weight: 500;
  display: flex; align-items: center; gap: 5px; transition: opacity 0.15s;
}
.food-tag--ok { background: rgba(124,184,212,0.08); color: var(--color-success); }
.food-tag--reaction { background: rgba(233,196,106,0.10); color: var(--color-warning); }
.food-tag--rejected { background: rgba(212,114,124,0.08); color: var(--color-danger); }
.food-tag--pending { background: rgba(139,126,200,0.08); color: var(--color-primary); }

.intro-legend { display: flex; gap: 16px; flex-wrap: wrap; margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--color-border-light); }
.legend-item { display: flex; align-items: center; gap: 6px; font-size: 0.68rem; color: var(--color-text-muted); }
.legend-chip { display: inline-block; width: 10px; height: 10px; border-radius: 50%; }
.legend-chip--ok { background: var(--color-success); }
.legend-chip--reaction { background: var(--color-warning); }
.legend-chip--rejected { background: var(--color-danger); }
.legend-chip--pending { background: var(--color-primary); }

.no-entries { display: flex; flex-direction: column; align-items: center; padding: 24px; gap: 6px; text-align: center; }
.no-entries p { font-size: 0.82rem; color: var(--color-text-muted); }
.btn-log-inline { margin-top: 8px; padding: 8px 18px; background: var(--gradient-cta); color: white; border-radius: 10px; font-size: 0.78rem; font-weight: 600; border: none; cursor: pointer; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); z-index: 9000; display: flex; align-items: flex-end; justify-content: center; padding: 16px; }
.modal-card { background: white; border-radius: 20px; padding: 24px; width: 100%; max-width: 480px; max-height: 95vh; overflow-y: auto; display: flex; flex-direction: column; gap: 14px; }
.modal-header { display: flex; align-items: center; justify-content: space-between; }
.modal-title { font-size: 1rem; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.btn-close { border: none; background: rgba(139,126,200,0.08); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; cursor: pointer; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { display: flex; flex-direction: column; gap: 6px; }
.fl { font-size: 0.72rem; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: 0.04em; }
.fi { padding: 10px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.85rem; width: 100%; }
.fi:focus { outline: none; border-color: var(--color-primary); }
.type-toggle { display: flex; gap: 6px; flex-wrap: wrap; }
.type-btn { flex: 1; min-width: 60px; padding: 8px 10px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.78rem; font-weight: 500; display: flex; align-items: center; justify-content: center; gap: 5px; cursor: pointer; background: white; transition: all 0.15s; }
.type-btn.active { background: rgba(139,126,200,0.1); border-color: var(--color-primary); color: var(--color-primary); font-weight: 700; }
.modal-actions { display: flex; gap: 10px; }
.btn-cancel { flex: 1; padding: 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.85rem; font-weight: 600; cursor: pointer; background: white; }
.btn-submit { flex: 2; padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-size: 0.85rem; font-weight: 700; cursor: pointer; }
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }

/* Toast */
.toast { position: fixed; bottom: 90px; left: 50%; transform: translateX(-50%); background: var(--color-success); color: white; padding: 12px 24px; border-radius: 12px; font-size: 0.82rem; font-weight: 600; display: flex; align-items: center; gap: 8px; z-index: 9999; box-shadow: 0 4px 16px rgba(0,0,0,0.15); }
.toast-enter-active, .toast-leave-active { transition: all 0.3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(10px); }
</style>

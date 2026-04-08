<template>
  <div class="family-detail">
    <header class="page-header">
      <NuxtLink to="/coordinator/families" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Семьи
      </NuxtLink>
      <h1 class="page-title">{{ familyName }}</h1>
    </header>

    <div v-if="loading" class="loading"><Icon name="lucide:loader-2" size="24" class="spin" /> Загрузка...</div>

    <template v-else>
      <!-- Mother info -->
      <section v-if="mother" class="info-card">
        <h2 class="card-title">Мама</h2>
        <div class="info-row"><span>Имя:</span><strong>{{ mother.first_name }} {{ mother.last_name }}</strong></div>
        <div class="info-row"><span>Телефон:</span><strong>{{ mother.phone || '—' }}</strong></div>
      </section>

      <!-- Children -->
      <section v-if="children.length" class="info-card">
        <h2 class="card-title">Дети</h2>
        <div v-for="child in children" :key="child.id" class="child-row">
          <strong>{{ child.name }}</strong>
          <span v-if="child.dob">{{ formatAge(child.dob) }}</span>
        </div>
      </section>

      <!-- Active journeys -->
      <section v-if="journeys.length" class="info-card">
        <h2 class="card-title">Маршруты</h2>
        <div v-for="j in journeys" :key="j.id" class="journey-row">
          <span class="journey-type">{{ journeyLabel(j.type) }}</span>
          <div class="mini-progress">
            <div class="mini-fill" :style="{ width: `${journeyProgress(j)}%` }" />
          </div>
          <span class="progress-text">{{ journeyProgress(j) }}%</span>
        </div>
      </section>

      <!-- Overdue events -->
      <section v-if="overdueEvents.length" class="info-card warning">
        <h2 class="card-title"><Icon name="lucide:alert-triangle" size="16" class="warn-icon" /> Просроченные события</h2>
        <div v-for="evt in overdueEvents" :key="evt.id" class="event-row">
          <span>{{ evt.title }}</span>
          <span class="event-due">{{ evt.due_date }}</span>
        </div>
      </section>

      <!-- Recent documents -->
      <section v-if="documents.length" class="info-card">
        <h2 class="card-title">Последние документы</h2>
        <div v-for="doc in documents" :key="doc.id" class="doc-row">
          <span>{{ doc.title }}</span>
          <a v-if="doc.file_url" :href="doc.file_url" target="_blank" rel="noopener" class="doc-download">
            <Icon name="lucide:download" size="14" />
          </a>
        </div>
      </section>

      <!-- Actions -->
      <div class="actions">
        <button class="btn-action" @click="showTaskModal = true">
          <Icon name="lucide:plus" size="16" /> Создать задачу
        </button>
        <a v-if="mother?.phone" :href="`tel:${mother.phone}`" class="btn-action btn-secondary">
          <Icon name="lucide:phone" size="16" /> Позвонить
        </a>
      </div>
    </template>

    <!-- Task Creation Modal -->
    <Teleport to="body">
      <div v-if="showTaskModal" class="modal-overlay" @click.self="showTaskModal = false">
        <div class="modal-card">
          <h2 class="modal-title">Создать задачу</h2>
          <form class="modal-form" @submit.prevent="handleCreateTask">
            <div class="form-group">
              <label class="form-label">Заголовок</label>
              <input v-model="taskForm.title" type="text" class="form-input" placeholder="Позвонить маме..." required />
            </div>
            <div class="form-group">
              <label class="form-label">Описание</label>
              <textarea v-model="taskForm.description" class="form-input form-textarea" rows="2" placeholder="Подробности..." />
            </div>
            <div class="form-row-2">
              <div class="form-group">
                <label class="form-label">Приоритет</label>
                <select v-model="taskForm.priority" class="form-input">
                  <option value="low">Низкий</option>
                  <option value="medium">Средний</option>
                  <option value="high">Высокий</option>
                  <option value="critical">Критический</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Тип</label>
                <select v-model="taskForm.type" class="form-input">
                  <option value="custom">Обычная</option>
                  <option value="overdue_followup">Просрочка</option>
                  <option value="vaccination_reminder">Прививка</option>
                  <option value="welcome_call">Приветственный звонок</option>
                  <option value="reactivation">Реактивация</option>
                </select>
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">Срок</label>
              <input v-model="taskForm.dueDate" type="date" class="form-input" />
            </div>

            <p v-if="taskError" class="form-error-global">{{ taskError }}</p>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="showTaskModal = false">Отмена</button>
              <button type="submit" class="btn-submit" :disabled="taskSaving">
                {{ taskSaving ? 'Создание...' : 'Создать' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { formatAge } from '~/utils/formatters'
import type { Journey, JourneyEvent, ChildProfile, TaskPriority, TaskType } from '~/types/database'
import dayjs from 'dayjs'

definePageMeta({ layout: 'app' })

const route = useRoute()
const supabase = useSupabaseClient()
const authStore = useAuthStore()

const familyId = route.params.id as string
const loading = ref(true)
const mother = ref<Record<string, unknown> | null>(null)
const children = ref<ChildProfile[]>([])
const journeys = ref<Journey[]>([])
const overdueEvents = ref<JourneyEvent[]>([])
const documents = ref<Array<Record<string, unknown>>>([])
const familyName = ref('Семья')

// Task creation
const showTaskModal = ref(false)
const taskSaving = ref(false)
const taskError = ref('')
const taskForm = reactive({
  title: '',
  description: '',
  priority: 'medium' as TaskPriority,
  type: 'custom' as TaskType,
  dueDate: dayjs().add(1, 'day').format('YYYY-MM-DD'),
})

function journeyLabel(type: string) {
  const map: Record<string, string> = { pregnancy: 'Беременность', postpartum: 'Послеродовой', infant: 'Младенец', toddler: 'Малыш' }
  return map[type] || type
}

function journeyProgress(j: Journey) {
  return (j as unknown as Record<string, unknown>).progress_percent || 0
}

async function handleCreateTask() {
  if (!taskForm.title.trim()) { taskError.value = 'Введите заголовок'; return }
  taskError.value = ''
  taskSaving.value = true

  try {
    const { error } = await supabase
      .from('coordinator_tasks')
      .insert({
        clinic_id: authStore.clinicId,
        family_id: familyId,
        type: taskForm.type,
        priority: taskForm.priority,
        status: 'pending',
        title: taskForm.title,
        notes: taskForm.description || null,
        assigned_to: authStore.profile?.id || null,
        due_date: taskForm.dueDate || null,
      })

    if (error) { taskError.value = error.message; return }
    showTaskModal.value = false
    Object.assign(taskForm, { title: '', description: '', priority: 'medium', type: 'custom', dueDate: dayjs().add(1, 'day').format('YYYY-MM-DD') })
  }
  finally {
    taskSaving.value = false
  }
}

onMounted(async () => {
  // Fetch family members
  const { data: members } = await supabase
    .from('users')
    .select('*')
    .eq('family_id', familyId)

  if (members) {
    const mom = members.find((m: Record<string, unknown>) => m.role === 'mother')
    if (mom) {
      mother.value = mom
      familyName.value = `${mom.first_name} ${mom.last_name}`
    }
  }

  // Fetch children
  const { data: kids } = await supabase
    .from('child_profiles')
    .select('*')
    .eq('family_id', familyId)
  if (kids) children.value = kids as ChildProfile[]

  // Fetch journeys
  const { data: js } = await supabase
    .from('journeys')
    .select('*')
    .eq('family_id', familyId)
    .order('created_at', { ascending: false })
  if (js) journeys.value = js as Journey[]

  // Fetch overdue events
  const { data: evts } = await supabase
    .from('journey_events')
    .select('*')
    .eq('status', 'overdue')
    .in('journey_id', journeys.value.map(j => j.id))
    .order('due_date')
    .limit(10)
  if (evts) overdueEvents.value = evts as JourneyEvent[]

  // Fetch recent documents
  const { data: docs } = await supabase
    .from('documents')
    .select('*')
    .eq('family_id', familyId)
    .order('created_at', { ascending: false })
    .limit(5)
  if (docs) documents.value = docs

  loading.value = false
})
</script>

<style scoped>
.family-detail { max-width: 800px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; flex: 1; }

.loading { text-align: center; padding: 48px; color: var(--color-text-muted); display: flex; align-items: center; justify-content: center; gap: 8px; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.info-card {
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md); padding: 18px; margin-bottom: 16px;
}
.info-card.warning { border-color: rgba(231, 111, 81, 0.3); background: rgba(231, 111, 81, 0.02); }
.card-title { font-size: 0.95rem; font-weight: 600; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
.warn-icon { color: var(--color-danger); }

.info-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 0.85rem; border-bottom: 1px solid var(--color-border-light); }
.info-row:last-child { border: none; }
.info-row span { color: var(--color-text-secondary); }

.child-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--color-border-light); font-size: 0.85rem; }
.child-row:last-child { border: none; }
.child-row span { color: var(--color-text-secondary); }

.journey-row { display: flex; align-items: center; gap: 12px; padding: 8px 0; }
.journey-type { font-size: 0.85rem; font-weight: 500; min-width: 120px; }
.mini-progress { flex: 1; height: 6px; background: var(--color-primary-ultralight); border-radius: 3px; overflow: hidden; }
.mini-fill { height: 100%; background: var(--gradient-cta); border-radius: 3px; }
.progress-text { font-size: 0.8rem; color: var(--color-text-secondary); font-weight: 600; min-width: 36px; text-align: right; }

.event-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 0.85rem; }
.event-due { color: var(--color-danger); font-size: 0.8rem; }

.doc-row { display: flex; justify-content: space-between; align-items: center; padding: 6px 0; font-size: 0.85rem; }
.doc-download { color: var(--color-text-muted); }

.actions { margin-top: 20px; }
.btn-action {
  display: flex; align-items: center; gap: 6px; padding: 10px 18px;
  background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm);
  font-weight: 600; cursor: pointer; font-family: var(--font-body); text-decoration: none;
}
.btn-secondary { background: var(--color-surface); color: var(--color-primary); border: 1px solid var(--color-primary); }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: var(--color-surface); border-radius: var(--radius-md); padding: 24px; width: 100%; max-width: 440px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; margin-bottom: 16px; }
.modal-form { display: flex; flex-direction: column; gap: 14px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.85rem; font-weight: 600; }
.form-input { padding: 10px 14px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body); outline: none; }
.form-input:focus { border-color: var(--color-primary); }
.form-textarea { resize: vertical; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.form-error-global { text-align: center; font-size: 0.85rem; color: var(--color-danger); padding: 8px; background: rgba(231, 111, 81, 0.08); border-radius: var(--radius-sm); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body); }
.btn-submit:disabled { opacity: 0.6; }
</style>

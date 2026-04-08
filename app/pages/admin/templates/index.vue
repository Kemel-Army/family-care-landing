<template>
  <div class="templates-page">
    <header class="page-header">
      <h1 class="page-title">Шаблоны маршрутов</h1>
      <button class="btn-create" @click="showCreate = true">
        <Icon name="lucide:plus" size="16" /> Новый шаблон
      </button>
    </header>

    <div class="templates-grid">
      <div v-for="tmpl in templates" :key="tmpl.id" class="template-card" :class="{ default: tmpl.is_default }">
        <div class="tmpl-header">
          <span class="tmpl-type" :class="tmpl.type">{{ typeLabel(tmpl.type) }}</span>
          <span v-if="tmpl.is_default" class="tmpl-badge">По умолчанию</span>
        </div>
        <h3>{{ tmpl.name }}</h3>
        <p v-if="tmpl.description" class="tmpl-desc">{{ tmpl.description }}</p>
        <div class="tmpl-stats">
          <span><Icon name="lucide:list" size="14" /> {{ tmpl.events_json?.length || 0 }} событий</span>
          <span><Icon name="lucide:shield-check" size="14" /> {{ mandatoryCount(tmpl) }} обязательных</span>
        </div>
        <div class="tmpl-actions">
          <button class="btn-sm" @click="editTemplate(tmpl)">
            <Icon name="lucide:pencil" size="14" /> Редактировать
          </button>
          <button v-if="!tmpl.is_default" class="btn-sm default-btn" @click="setDefault(tmpl)">
            Сделать по умолчанию
          </button>
        </div>
      </div>
    </div>

    <div v-if="!templates.length && !loading" class="empty">
      <Icon name="lucide:file-text" size="40" />
      <p>Шаблоны маршрутов не созданы</p>
    </div>

    <!-- Create / Edit Modal -->
    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="closeModal">
        <div class="modal-card">
          <div class="modal-header">
            <h2>{{ editId ? 'Редактировать шаблон' : 'Новый шаблон' }}</h2>
            <button class="modal-close" @click="closeModal"><Icon name="lucide:x" size="18" /></button>
          </div>

          <form @submit.prevent="saveTemplate">
            <div class="form-group">
              <label class="form-label">Название</label>
              <input v-model="form.name" type="text" class="form-input" required placeholder="Беременность — стандартный маршрут" />
            </div>

            <div class="form-group">
              <label class="form-label">Тип</label>
              <select v-model="form.type" class="form-input" required>
                <option value="pregnancy">Беременность</option>
                <option value="postpartum">Послеродовый</option>
                <option value="infant">Младенец (0–12 мес)</option>
                <option value="toddler">Тоддлер (12–24 мес)</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Описание</label>
              <textarea v-model="form.description" class="form-input" rows="3" placeholder="Описание маршрута..." />
            </div>

            <div class="form-group">
              <label class="form-label">По умолчанию</label>
              <label class="checkbox-label">
                <input v-model="form.is_default" type="checkbox" />
                Использовать как шаблон по умолчанию для этого типа
              </label>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="closeModal">Отмена</button>
              <button type="submit" class="btn-submit" :disabled="saving">{{ saving ? 'Сохранение...' : 'Сохранить' }}</button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const templates = ref<any[]>([])
const loading = ref(true)
const showCreate = ref(false)
const saving = ref(false)
const editId = ref<string | null>(null)

const form = reactive({
  name: '',
  type: 'pregnancy',
  description: '',
  is_default: false,
})

function typeLabel(type: string) {
  const map: Record<string, string> = {
    pregnancy: 'Беременность',
    postpartum: 'Послеродовый',
    infant: 'Младенец',
    toddler: 'Тоддлер',
  }
  return map[type] || type
}

function mandatoryCount(tmpl: any) {
  return (tmpl.events_json || []).filter((e: any) => e.is_mandatory).length
}

function editTemplate(tmpl: any) {
  editId.value = tmpl.id
  form.name = tmpl.name
  form.type = tmpl.type
  form.description = tmpl.description || ''
  form.is_default = tmpl.is_default
  showCreate.value = true
}

function closeModal() {
  showCreate.value = false
  editId.value = null
  form.name = ''
  form.type = 'pregnancy'
  form.description = ''
  form.is_default = false
}

async function setDefault(tmpl: any) {
  if (!authStore.clinicId) return
  // Unset current default for this type
  await supabase
    .from('journey_templates')
    .update({ is_default: false })
    .eq('clinic_id', authStore.clinicId)
    .eq('type', tmpl.type)

  await supabase
    .from('journey_templates')
    .update({ is_default: true })
    .eq('id', tmpl.id)

  tmpl.is_default = true
  templates.value.forEach(t => {
    if (t.type === tmpl.type && t.id !== tmpl.id) t.is_default = false
  })
}

async function saveTemplate() {
  if (!authStore.clinicId) return
  saving.value = true

  const payload = {
    clinic_id: authStore.clinicId,
    name: form.name,
    type: form.type,
    description: form.description || null,
    is_default: form.is_default,
  }

  if (editId.value) {
    await supabase.from('journey_templates').update(payload).eq('id', editId.value)
  } else {
    await supabase.from('journey_templates').insert({ ...payload, events_json: [] })
  }

  closeModal()
  await fetchData()
  saving.value = false
}

async function fetchData() {
  if (!authStore.clinicId) return
  loading.value = true

  const { data } = await supabase
    .from('journey_templates')
    .select('*')
    .eq('clinic_id', authStore.clinicId)
    .order('type')
    .order('is_default', { ascending: false })

  templates.value = data || []
  loading.value = false
}

onMounted(fetchData)
</script>

<style scoped>
.templates-page { max-width: 900px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }
.btn-create {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: var(--color-primary); color: #fff; border: none; border-radius: var(--radius-sm);
  font-size: 0.85rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}

.templates-grid { display: flex; flex-direction: column; gap: 12px; }
.template-card {
  padding: 18px; background: var(--color-surface);
  border: 1px solid var(--color-border-light); border-radius: var(--radius-md);
}
.template-card.default { border-color: var(--color-primary); }

.tmpl-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.tmpl-type {
  font-size: 0.7rem; font-weight: 600; padding: 2px 10px; border-radius: var(--radius-full);
  text-transform: uppercase; letter-spacing: 0.05em;
}
.tmpl-type.pregnancy { background: rgba(232, 160, 191, 0.15); color: var(--color-secondary-dark); }
.tmpl-type.postpartum { background: rgba(139, 126, 200, 0.15); color: var(--color-primary); }
.tmpl-type.infant { background: rgba(168, 200, 232, 0.15); color: var(--color-accent-blue); }
.tmpl-type.toddler { background: rgba(242, 196, 160, 0.15); color: var(--color-accent-warm); }

.tmpl-badge { font-size: 0.7rem; font-weight: 600; color: var(--color-primary); }
.template-card h3 { font-size: 0.95rem; font-weight: 600; }
.tmpl-desc { font-size: 0.8rem; color: var(--color-text-secondary); margin-top: 4px; }
.tmpl-stats { display: flex; gap: 16px; margin-top: 10px; font-size: 0.75rem; color: var(--color-text-muted); }
.tmpl-stats span { display: flex; align-items: center; gap: 4px; }

.tmpl-actions { display: flex; gap: 8px; margin-top: 12px; }
.btn-sm {
  display: flex; align-items: center; gap: 4px; padding: 5px 12px;
  border: 1px solid var(--color-border); border-radius: var(--radius-sm);
  background: transparent; font-size: 0.75rem; cursor: pointer; font-family: var(--font-body);
  color: var(--color-text-secondary);
}
.btn-sm:hover { background: var(--color-bg-alt); }
.default-btn { color: var(--color-primary); border-color: var(--color-primary-light); }

.empty { text-align: center; padding: 48px; color: var(--color-text-muted); }
.empty p { margin-top: 8px; }

/* Modal */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex;
  align-items: center; justify-content: center; z-index: 1000; padding: 16px;
}
.modal-card { background: var(--color-surface); border-radius: var(--radius-md); width: 100%; max-width: 500px; padding: 24px; box-shadow: var(--shadow-lg); }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.modal-header h2 { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.modal-close { background: none; border: none; cursor: pointer; color: var(--color-text-muted); padding: 4px; }

.form-group { margin-bottom: 16px; }
.form-label { display: block; font-size: 0.8rem; font-weight: 600; margin-bottom: 6px; color: var(--color-text-secondary); }
.form-input {
  width: 100%; padding: 10px 12px; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body);
  background: var(--color-bg); color: var(--color-text-primary);
}
.form-input:focus { outline: none; border-color: var(--color-primary); }
textarea.form-input { resize: vertical; }

.checkbox-label { display: flex; align-items: center; gap: 8px; font-size: 0.85rem; cursor: pointer; }
.checkbox-label input { accent-color: var(--color-primary); }

.modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 20px; }
.btn-cancel { padding: 8px 16px; background: transparent; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.85rem; cursor: pointer; font-family: var(--font-body); }
.btn-submit {
  padding: 8px 20px; background: var(--color-primary); color: #fff; border: none;
  border-radius: var(--radius-sm); font-size: 0.85rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }
</style>

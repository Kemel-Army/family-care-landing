<template>
  <div class="documents-page">
    <header class="page-header">
      <h1 class="page-title">Документы</h1>
      <button class="btn-upload" @click="showUpload = true">
        <Icon name="lucide:upload" size="16" />
        Загрузить
      </button>
    </header>

    <!-- Filter -->
    <div class="filter-row">
      <button
        v-for="f in filters"
        :key="f.value"
        class="filter-btn"
        :class="{ active: activeFilter === f.value }"
        @click="activeFilter = f.value"
      >
        {{ f.label }}
      </button>
    </div>

    <!-- Documents list -->
    <div v-if="filteredDocs.length" class="doc-list">
      <div v-for="doc in filteredDocs" :key="doc.id" class="doc-card">
        <div class="doc-icon" :class="doc.type">
          <Icon :name="docIcon(doc.type)" size="20" />
        </div>
        <div class="doc-content">
          <h3>{{ doc.title }}</h3>
          <p>{{ docTypeLabel(doc.type) }} · {{ formatDate(doc.created_at) }}</p>
        </div>
        <a v-if="doc.file_url" :href="doc.file_url" target="_blank" rel="noopener" class="doc-link">
          <Icon name="lucide:download" size="16" />
        </a>
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:folder-open" title="Нет документов" description="Загрузите анализы, УЗИ, выписки" />

    <!-- Upload Modal -->
    <Teleport to="body">
      <div v-if="showUpload" class="modal-overlay" @click.self="showUpload = false">
        <div class="modal-card">
          <h2 class="modal-title">Загрузка документа</h2>

          <div class="form-group">
            <label class="form-label">Название</label>
            <input v-model="uploadForm.title" type="text" class="form-input" placeholder="Например: УЗИ 12 недель" />
          </div>

          <div class="form-group">
            <label class="form-label">Тип</label>
            <select v-model="uploadForm.type" class="form-input">
              <option value="analysis">Анализ</option>
              <option value="ultrasound">УЗИ</option>
              <option value="screening">Скрининг</option>
              <option value="prescription">Назначение</option>
              <option value="discharge">Выписка</option>
              <option value="certificate">Справка</option>
              <option value="other">Другое</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Файл</label>
            <input ref="fileInput" type="file" class="form-input" accept="image/*,.pdf" @change="onFileSelect" />
          </div>

          <div class="modal-actions">
            <button class="btn-cancel" @click="showUpload = false">Отмена</button>
            <button class="btn-submit" :disabled="uploading || !uploadForm.title || !selectedFile" @click="handleUpload">
              {{ uploading ? 'Загрузка...' : 'Загрузить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { formatDate } from '~/utils/formatters'
import type { Document } from '~/types/database'

definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const documents = ref<Document[]>([])
const activeFilter = ref('all')
const showUpload = ref(false)
const uploading = ref(false)
const selectedFile = ref<File | null>(null)
const uploadForm = reactive({
  title: '',
  type: 'analysis' as string,
})

const filters = [
  { label: 'Все', value: 'all' },
  { label: 'Анализы', value: 'analysis' },
  { label: 'УЗИ', value: 'ultrasound' },
  { label: 'Скрининги', value: 'screening' },
  { label: 'Другое', value: 'other' },
]

const filteredDocs = computed(() => {
  if (activeFilter.value === 'all') return documents.value
  return documents.value.filter(d => d.type === activeFilter.value)
})

function docIcon(type: string) {
  const map: Record<string, string> = {
    analysis: 'lucide:file-text',
    ultrasound: 'lucide:eye',
    screening: 'lucide:shield',
    prescription: 'lucide:pill',
    discharge: 'lucide:file-check',
    certificate: 'lucide:file-text',
  }
  return map[type] || 'lucide:file-text'
}

function docTypeLabel(type: string) {
  const map: Record<string, string> = {
    analysis: 'Анализ',
    ultrasound: 'УЗИ',
    screening: 'Скрининг',
    prescription: 'Назначение',
    discharge: 'Выписка',
    certificate: 'Справка',
    photo: 'Фото',
    other: 'Другое',
  }
  return map[type] || type
}

function onFileSelect(event: Event) {
  const input = event.target as HTMLInputElement
  selectedFile.value = input.files?.[0] || null
}

async function handleUpload() {
  if (!selectedFile.value || !authStore.familyId) return

  uploading.value = true
  try {
    const file = selectedFile.value
    const ext = file.name.split('.').pop()
    const path = `medical-documents/${authStore.familyId}/${Date.now()}.${ext}`

    const { error: uploadError } = await supabase.storage
      .from('documents')
      .upload(path, file)

    if (uploadError) return

    const { data: urlData } = supabase.storage.from('documents').getPublicUrl(path)

    await supabase.from('documents').insert({
      family_id: authStore.familyId,
      title: uploadForm.title,
      type: uploadForm.type,
      file_url: urlData.publicUrl,
      file_type: file.type,
      file_size: file.size,
      uploaded_by: authStore.profile?.id,
    })

    // Refresh list
    await fetchDocuments()
    showUpload.value = false
    uploadForm.title = ''
    selectedFile.value = null
  }
  finally {
    uploading.value = false
  }
}

async function fetchDocuments() {
  if (!authStore.familyId) return
  const { data } = await supabase
    .from('documents')
    .select('*')
    .eq('family_id', authStore.familyId)
    .order('created_at', { ascending: false })

  documents.value = (data as Document[]) || []
}

onMounted(fetchDocuments)
</script>

<style scoped>
.documents-page { max-width: 800px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.btn-upload {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm);
  font-size: 0.85rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}

.filter-row { display: flex; gap: 8px; overflow-x: auto; margin-bottom: 20px; }
.filter-btn {
  flex-shrink: 0; padding: 6px 14px; border: 1px solid var(--color-border);
  border-radius: 20px; background: var(--color-surface); font-size: 0.8rem;
  cursor: pointer; white-space: nowrap; font-family: var(--font-body);
}
.filter-btn.active { border-color: var(--color-primary); background: var(--color-primary-ultralight); color: var(--color-primary); font-weight: 600; }

.doc-list { display: flex; flex-direction: column; gap: 8px; }
.doc-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); transition: all var(--transition-fast);
}
.doc-card:hover { box-shadow: var(--shadow-sm); }

.doc-icon {
  width: 40px; height: 40px; border-radius: 10px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  background: var(--color-primary-ultralight); color: var(--color-primary);
}
.doc-icon.ultrasound { background: rgba(232, 160, 191, 0.15); color: var(--color-secondary); }
.doc-icon.screening { background: rgba(233, 196, 106, 0.15); color: var(--color-warning); }

.doc-content { flex: 1; }
.doc-content h3 { font-size: 0.9rem; font-weight: 600; }
.doc-content p { font-size: 0.8rem; color: var(--color-text-secondary); }
.doc-link { color: var(--color-text-muted); text-decoration: none; }

/* Modal */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex;
  align-items: center; justify-content: center; z-index: 1000; padding: 16px;
}
.modal-card {
  background: var(--color-surface); border-radius: var(--radius-md);
  padding: 24px; width: 100%; max-width: 440px; display: flex; flex-direction: column; gap: 14px;
}
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.85rem; font-weight: 600; }
.form-input {
  padding: 10px 14px; border: 1px solid var(--color-border); border-radius: var(--radius-sm);
  font-size: 0.9rem; font-family: var(--font-body); outline: none;
}
.form-input:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer; font-family: var(--font-body); }
.btn-submit {
  padding: 8px 20px; background: var(--gradient-cta); color: white; border: none;
  border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }

.empty-state { text-align: center; padding: 48px 16px; color: var(--color-text-muted); }
.empty-state h3 { font-size: 1rem; margin: 8px 0 4px; color: var(--color-text-primary); }
.empty-state p { font-size: 0.85rem; }
.empty-icon { color: var(--color-primary-light); }
</style>

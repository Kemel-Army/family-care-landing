<template>
  <div class="docs-page">
    <div class="docs-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Панель</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Документы</h1>
          <p class="hero-sub">{{ documents.length }} документов</p>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по названию…" class="search-input" />
    </div>

    <div class="filter-row">
      <button v-for="f in typeFilters" :key="f.value" class="filter-btn" :class="{ active: typeFilter === f.value }" @click="typeFilter = f.value">{{ f.label }}</button>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="docs-list">
      <div v-for="d in filtered" :key="d.id" class="doc-row">
        <div class="doc-type-icon" :class="d.type">
          <Icon :name="typeIcon(d.type)" size="18" />
        </div>
        <div class="doc-info">
          <h3 class="doc-title">{{ d.title }}</h3>
          <p class="doc-desc" v-if="d.description">{{ d.description }}</p>
          <div class="doc-meta">
            <span class="doc-badge" :class="d.type">{{ typeLabel(d.type) }}</span>
            <span class="doc-patient"><Icon name="lucide:user" size="11" /> {{ d.patient_name }}</span>
            <span v-if="d.child_name" class="doc-child"><Icon name="lucide:baby" size="11" /> {{ d.child_name }}</span>
          </div>
        </div>
        <div class="doc-right">
          <span class="doc-date">{{ formatDate(d.created_at) }}</span>
          <span v-if="d.file_type" class="doc-size">{{ d.file_type }}</span>
        </div>
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:folder-open" title="Документы не найдены" description="Нет документов по текущим фильтрам" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const search = ref('')
const typeFilter = ref('all')
const loading = ref(true)

interface Doc {
  id: string; title: string; description: string | null; type: string
  file_type: string | null; patient_name: string; child_name: string | null; created_at: string
}

const documents = ref<Doc[]>([])

const typeFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Анализы', value: 'analysis' },
  { label: 'УЗИ', value: 'ultrasound' },
  { label: 'Скрининг', value: 'screening' },
  { label: 'Рецепт', value: 'prescription' },
  { label: 'Прочее', value: 'other' },
]

const filtered = computed(() => {
  let items = documents.value
  if (typeFilter.value !== 'all') items = items.filter(d => d.type === typeFilter.value)
  const q = search.value.toLowerCase()
  if (q) items = items.filter(d => d.title.toLowerCase().includes(q) || d.patient_name.toLowerCase().includes(q))
  return items
})

function typeLabel(t: string) {
  return { analysis: 'Анализ', ultrasound: 'УЗИ', screening: 'Скрининг', prescription: 'Рецепт', discharge: 'Выписка', certificate: 'Справка', photo: 'Фото', other: 'Прочее' }[t] || t
}

function typeIcon(t: string) {
  return { analysis: 'lucide:test-tubes', ultrasound: 'lucide:scan', screening: 'lucide:clipboard-check', prescription: 'lucide:pill', discharge: 'lucide:file-output', certificate: 'lucide:award', photo: 'lucide:image', other: 'lucide:file' }[t] || 'lucide:file'
}

function formatDate(d: string) { return new Date(d).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short', year: 'numeric' }) }

onMounted(async () => {
  const { data } = await sb.from('documents').select(`
    id, title, description, type, file_type, created_at, family_id, child_id,
    families!inner(primary_parent_id, users!families_primary_parent_id_fkey(first_name, last_name)),
    child_profiles(name)
  `).order('created_at', { ascending: false }).limit(100)

  documents.value = (data || []).map(d => {
    const fam = d.families as any
    const parent = fam?.users
    const child = Array.isArray(d.child_profiles) ? d.child_profiles[0] : d.child_profiles
    return {
      id: d.id,
      title: d.title,
      description: d.description,
      type: d.type,
      file_type: d.file_type,
      patient_name: `${parent?.last_name || ''} ${parent?.first_name || ''}`.trim() || 'Без имени',
      child_name: (child as any)?.name || null,
      created_at: d.created_at,
    }
  })
  loading.value = false
})
</script>

<style scoped>
.docs-page { max-width: 780px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }
.docs-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.search-box { position: relative; }
.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--color-text-muted); }
.search-input { width: 100%; padding: 10px 12px 10px 38px; border: 1px solid var(--color-border-light); border-radius: 12px; font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s; }
.search-input:focus { border-color: var(--color-primary); }
.filter-row { display: flex; gap: 6px; flex-wrap: wrap; }
.filter-btn { padding: 6px 14px; border: 1px solid var(--color-border-light); border-radius: 20px; font-size: 0.78rem; font-weight: 500; background: white; cursor: pointer; transition: all 0.2s; font-family: var(--font-body); color: var(--color-text-muted); }
.filter-btn.active { background: var(--color-primary); color: white; border-color: var(--color-primary); }
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 40px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.docs-list { display: flex; flex-direction: column; gap: 2px; }
.doc-row {
  display: flex; align-items: center; gap: 14px; padding: 12px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px; transition: box-shadow 0.2s;
}
.doc-row:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.doc-type-icon {
  width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.doc-type-icon.analysis { background: rgba(100,180,120,0.12); color: #4a9960; }
.doc-type-icon.ultrasound { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.doc-type-icon.screening { background: rgba(232,160,191,0.12); color: #c76b94; }
.doc-type-icon.prescription { background: rgba(232,184,77,0.12); color: #b08a2a; }
.doc-type-icon.discharge, .doc-type-icon.certificate { background: rgba(96,125,139,0.12); color: #607d8b; }
.doc-type-icon.photo { background: rgba(139,126,200,0.08); color: var(--color-primary); }
.doc-type-icon.other { background: rgba(150,150,150,0.1); color: #888; }
.doc-info { flex: 1; min-width: 0; }
.doc-title { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.doc-desc { font-size: 0.72rem; color: var(--color-text-muted); margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.doc-meta { display: flex; align-items: center; gap: 8px; margin-top: 4px; }
.doc-badge { font-size: 0.62rem; font-weight: 600; padding: 2px 6px; border-radius: 6px; }
.doc-badge.analysis { background: rgba(100,180,120,0.1); color: #4a9960; }
.doc-badge.ultrasound { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.doc-badge.screening { background: rgba(232,160,191,0.1); color: #c76b94; }
.doc-badge.prescription { background: rgba(232,184,77,0.1); color: #b08a2a; }
.doc-badge.other, .doc-badge.discharge, .doc-badge.certificate, .doc-badge.photo { background: rgba(150,150,150,0.1); color: #888; }
.doc-patient, .doc-child { display: flex; align-items: center; gap: 2px; font-size: 0.68rem; color: var(--color-text-muted); }
.doc-right { display: flex; flex-direction: column; align-items: flex-end; flex-shrink: 0; gap: 2px; }
.doc-date { font-size: 0.72rem; color: var(--color-text-muted); white-space: nowrap; }
.doc-size { font-size: 0.62rem; color: var(--color-text-muted); text-transform: uppercase; font-family: var(--font-mono); }
</style>

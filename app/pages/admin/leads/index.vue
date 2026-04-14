<template>
  <div class="leads-page">
    <!-- Hero -->
    <div class="leads-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Лиды</h1>
          <p class="hero-sub">{{ total }} лидов · {{ wonCount }} конвертировано</p>
        </div>
        <button class="btn-create" @click="showCreate = true"><Icon name="lucide:plus" size="14" /> Новый лид</button>
      </div>
      <!-- Stats chips -->
      <div class="stats-row">
        <div v-for="s in stageStats" :key="s.stage" class="stat-chip" :style="{ borderColor: s.color + '33' }">
          <span class="chip-dot" :style="{ background: s.color }" />
          <span class="chip-label">{{ s.label }}</span>
          <span class="chip-count">{{ s.count }}</span>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-row">
      <div class="search-wrap">
        <Icon name="lucide:search" size="16" class="search-icon" />
        <input v-model="search" type="text" placeholder="Поиск по имени, телефону..." class="search-input" />
      </div>
      <select v-model="filterSource" class="fi filter-sel">
        <option value="all">Все источники</option>
        <option v-for="(label, key) in sourceLabels" :key="key" :value="key">{{ label }}</option>
      </select>
      <select v-model="viewMode" class="fi filter-sel">
        <option value="kanban">Kanban</option>
        <option value="list">Список</option>
      </select>
    </div>

    <!-- Kanban View -->
    <div v-if="viewMode === 'kanban'" class="kanban-board">
      <div v-for="stg in activeStages" :key="stg" class="kanban-col"
        @dragover.prevent @drop="onDrop($event, stg)">
        <div class="col-header">
          <span class="col-dot" :style="{ background: stageColors[stg] }" />
          <span class="col-title">{{ stageLabels[stg] }}</span>
          <span class="col-count">{{ leadsBy(stg).length }}</span>
        </div>
        <div class="col-body">
          <div v-for="lead in leadsBy(stg)" :key="lead.id" class="lead-card"
            draggable="true" @dragstart="onDragStart($event, lead)">
            <div class="lc-top">
              <span class="lc-name">{{ lead.first_name }} {{ lead.last_name || '' }}</span>
              <span class="lc-source" :title="sourceLabels[lead.source] || lead.source">
                <Icon :name="sourceIcon(lead.source)" size="12" />
              </span>
            </div>
            <div v-if="lead.phone" class="lc-phone">{{ lead.phone }}</div>
            <div class="lc-bottom">
              <span class="lc-days">{{ daysInStage(lead) }} дн.</span>
              <span v-if="lead.assigned_name" class="lc-assigned">{{ lead.assigned_name }}</span>
            </div>
            <div class="lc-actions">
              <button class="lc-btn" title="Позвонить" @click.stop="logActivity(lead, 'call')"><Icon name="lucide:phone" size="12" /></button>
              <button class="lc-btn" title="WhatsApp" @click.stop="logActivity(lead, 'whatsapp')"><Icon name="lucide:message-circle" size="12" /></button>
              <button class="lc-btn" title="Заметка" @click.stop="logActivity(lead, 'note')"><Icon name="lucide:sticky-note" size="12" /></button>
              <NuxtLink :to="`/admin/leads/${lead.id}`" class="lc-btn" title="Подробнее"><Icon name="lucide:external-link" size="12" /></NuxtLink>
            </div>
          </div>
          <div v-if="!leadsBy(stg).length" class="col-empty">Пусто</div>
        </div>
      </div>
    </div>

    <!-- List View -->
    <div v-else class="leads-list">
      <div v-for="lead in filteredLeads" :key="lead.id" class="list-row">
        <NuxtLink :to="`/admin/leads/${lead.id}`" class="list-link">
          <div class="lr-avatar"><Icon name="lucide:user" size="16" /></div>
          <div class="lr-info">
            <span class="lr-name">{{ lead.first_name }} {{ lead.last_name || '' }}</span>
            <span class="lr-meta">{{ lead.phone || lead.email || '—' }}</span>
          </div>
          <span class="lr-badge" :style="{ background: stageColors[lead.stage] + '18', color: stageColors[lead.stage] }">{{ stageLabels[lead.stage] }}</span>
          <span class="lr-source">{{ sourceLabels[lead.source] || lead.source }}</span>
          <span v-if="lead.assigned_name" class="lr-assigned">{{ lead.assigned_name }}</span>
          <span class="lr-date">{{ formatDate(lead.created_at) }}</span>
        </NuxtLink>
      </div>
      <AppSharedEmptyState v-if="!filteredLeads.length" icon="lucide:user-plus" title="Лиды не найдены" />
    </div>

    <!-- Create Modal -->
    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый лид</h2>
          <div class="fg"><label class="fl">Имя *</label><input v-model="form.first_name" class="fi" placeholder="Айгуль" /></div>
          <div class="fg"><label class="fl">Фамилия</label><input v-model="form.last_name" class="fi" placeholder="Касымова" /></div>
          <div class="fg"><label class="fl">Телефон</label><input v-model="form.phone" class="fi" placeholder="+7 777 123 4567" /></div>
          <div class="fg"><label class="fl">Email</label><input v-model="form.email" class="fi" type="email" placeholder="email@example.com" /></div>
          <div class="fg"><label class="fl">Источник</label>
            <select v-model="form.source" class="fi">
              <option v-for="(label, key) in sourceLabels" :key="key" :value="key">{{ label }}</option>
            </select>
          </div>
          <div class="fg"><label class="fl">Заметки</label><textarea v-model="form.notes" rows="2" class="fi" placeholder="Узнала от подруги..." /></div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showCreate = false">Отмена</button>
            <button class="btn-submit" :disabled="!form.first_name || saving" @click="createLead">
              {{ saving ? 'Создание...' : 'Создать' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Activity Quick Log Modal -->
    <Teleport to="body">
      <div v-if="activityModal.show" class="modal-overlay" @click.self="activityModal.show = false">
        <div class="modal-card">
          <h2 class="modal-title">{{ activityTypeLabel(activityModal.type) }}: {{ activityModal.lead?.first_name }}</h2>
          <div class="fg"><label class="fl">Описание</label>
            <textarea v-model="activityModal.summary" rows="3" class="fi" placeholder="О чём говорили..." />
          </div>
          <div v-if="activityModal.type === 'call'" class="fg">
            <label class="fl">Длительность (сек)</label>
            <input v-model.number="activityModal.duration" type="number" class="fi" placeholder="120" />
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="activityModal.show = false">Отмена</button>
            <button class="btn-submit" :disabled="savingActivity" @click="saveActivity">
              {{ savingActivity ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import {
  LEAD_STAGE_LABELS, LEAD_STAGE_COLORS, LEAD_SOURCE_LABELS,
  type Lead, type LeadStage,
} from '~/types/crm.types'

definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()

const leads = ref<(Lead & { assigned_name?: string | null })[]>([])
const total = ref(0)
const loading = ref(false)
const saving = ref(false)
const savingActivity = ref(false)
const showCreate = ref(false)
const search = ref('')
const filterSource = ref('all')
const viewMode = ref<'kanban' | 'list'>('kanban')

const stageLabels = LEAD_STAGE_LABELS
const stageColors = LEAD_STAGE_COLORS
const sourceLabels = LEAD_SOURCE_LABELS
const activeStages: LeadStage[] = ['new', 'contacted', 'interested', 'negotiation', 'won', 'lost']

const form = reactive({
  first_name: '', last_name: '', phone: '', email: '',
  source: 'phone' as string, notes: '',
})

const activityModal = reactive({
  show: false, lead: null as Lead | null,
  type: 'call' as string, summary: '', duration: 0,
})

// Drag state
let draggedLead: Lead | null = null

const wonCount = computed(() => leads.value.filter(l => l.stage === 'won').length)

const stageStats = computed(() =>
  activeStages.map(stage => ({
    stage,
    label: stageLabels[stage],
    color: stageColors[stage],
    count: leads.value.filter(l => l.stage === stage).length,
  }))
)

const filteredLeads = computed(() => {
  let list = [...leads.value]
  const q = search.value.toLowerCase()
  if (q) {
    list = list.filter(l =>
      (l.first_name + ' ' + (l.last_name || '')).toLowerCase().includes(q) ||
      (l.phone || '').includes(q)
    )
  }
  if (filterSource.value !== 'all') {
    list = list.filter(l => l.source === filterSource.value)
  }
  return list
})

function leadsBy(stage: LeadStage) {
  return filteredLeads.value.filter(l => l.stage === stage)
}

function daysInStage(lead: Lead) {
  const d = new Date(lead.updated_at || lead.created_at)
  return Math.max(0, Math.floor((Date.now() - d.getTime()) / 86400000))
}

function sourceIcon(source: string) {
  const map: Record<string, string> = {
    website: 'lucide:globe', instagram: 'lucide:instagram', '2gis': 'lucide:map-pin',
    referral: 'lucide:users', walk_in: 'lucide:footprints', phone: 'lucide:phone',
    whatsapp: 'lucide:message-circle', other: 'lucide:help-circle',
  }
  return map[source] || 'lucide:help-circle'
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' })
}

function activityTypeLabel(type: string) {
  const map: Record<string, string> = { call: 'Звонок', whatsapp: 'WhatsApp', note: 'Заметка', sms: 'SMS', email: 'Email' }
  return map[type] || type
}

// Drag & Drop
function onDragStart(e: DragEvent, lead: Lead) {
  draggedLead = lead
  if (e.dataTransfer) e.dataTransfer.effectAllowed = 'move'
}

async function onDrop(_e: DragEvent, toStage: LeadStage) {
  if (!draggedLead || draggedLead.stage === toStage) return
  const lead = draggedLead
  draggedLead = null

  const oldStage = lead.stage
  lead.stage = toStage // optimistic

  try {
    await $fetch(`/api/admin/leads/${lead.id}`, { method: 'PUT', body: { stage: toStage } })
  } catch {
    lead.stage = oldStage // revert
  }
}

// Data
async function fetchLeads() {
  loading.value = true
  try {
    const res = await $fetch<{ leads: Lead[]; total: number }>('/api/admin/leads', {
      query: { perPage: 200 },
    })
    leads.value = res.leads
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function createLead() {
  if (!form.first_name) return
  saving.value = true
  try {
    const lead = await $fetch<Lead>('/api/admin/leads', { method: 'POST', body: { ...form } })
    leads.value.unshift(lead)
    total.value++
    showCreate.value = false
    form.first_name = ''; form.last_name = ''; form.phone = ''
    form.email = ''; form.notes = ''
  } finally {
    saving.value = false
  }
}

function logActivity(lead: Lead, type: string) {
  activityModal.lead = lead
  activityModal.type = type
  activityModal.summary = ''
  activityModal.duration = 0
  activityModal.show = true
}

async function saveActivity() {
  if (!activityModal.lead) return
  savingActivity.value = true
  try {
    await $fetch(`/api/admin/leads/${activityModal.lead.id}/activities`, {
      method: 'POST',
      body: {
        type: activityModal.type,
        direction: 'outbound',
        summary: activityModal.summary || null,
        duration_seconds: activityModal.type === 'call' ? activityModal.duration : undefined,
      },
    })
    activityModal.show = false
  } finally {
    savingActivity.value = false
  }
}

onMounted(fetchLeads)
</script>

<style scoped>
.leads-page { max-width: 1200px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.leads-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.btn-create {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: var(--gradient-cta, linear-gradient(135deg, #8B7EC8, #E8A0BF));
  color: white; border: none; border-radius: 10px; font-size: 0.8rem; font-weight: 600;
  cursor: pointer; transition: opacity 0.2s;
}
.btn-create:hover { opacity: 0.9; }

/* Stats chips */
.stats-row { display: flex; gap: 8px; margin-top: 14px; flex-wrap: wrap; }
.stat-chip {
  display: flex; align-items: center; gap: 6px; padding: 5px 10px;
  background: white; border: 1px solid; border-radius: 8px; font-size: 0.72rem;
}
.chip-dot { width: 7px; height: 7px; border-radius: 50%; }
.chip-label { color: var(--color-text-muted); }
.chip-count { font-weight: 700; font-family: var(--font-mono); }

/* Filters */
.filters-row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.search-wrap {
  display: flex; align-items: center; gap: 10px; padding: 8px 14px; flex: 1; min-width: 200px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 10px;
}
.search-icon { color: var(--color-text-muted); flex-shrink: 0; }
.search-input { border: none; outline: none; font-size: 0.82rem; font-family: var(--font-body); background: transparent; flex: 1; }
.filter-sel { max-width: 170px; padding: 8px 10px; font-size: 0.78rem; border-radius: 10px; border: 1px solid var(--color-border-light); background: white; }

/* Kanban Board */
.kanban-board { display: flex; gap: 10px; overflow-x: auto; padding-bottom: 8px; }
.kanban-col { flex: 1; min-width: 180px; max-width: 220px; }
.col-header {
  display: flex; align-items: center; gap: 6px; padding: 8px 12px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 10px 10px 0 0;
  font-size: 0.75rem; font-weight: 600;
}
.col-dot { width: 8px; height: 8px; border-radius: 50%; }
.col-title { flex: 1; }
.col-count { font-family: var(--font-mono); color: var(--color-text-muted); font-weight: 700; }
.col-body {
  display: flex; flex-direction: column; gap: 6px; padding: 8px 6px; min-height: 200px;
  background: rgba(0,0,0,0.015); border: 1px solid var(--color-border-light); border-top: none;
  border-radius: 0 0 10px 10px;
}
.col-empty { text-align: center; font-size: 0.72rem; color: var(--color-text-muted); padding: 24px 0; }

/* Lead Card */
.lead-card {
  background: white; border: 1px solid var(--color-border-light); border-radius: 10px;
  padding: 10px 12px; cursor: grab; transition: all 0.2s;
}
.lead-card:hover { border-color: rgba(139,126,200,0.25); box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.lead-card:active { cursor: grabbing; }
.lc-top { display: flex; align-items: center; justify-content: space-between; gap: 6px; }
.lc-name { font-size: 0.78rem; font-weight: 600; }
.lc-source { color: var(--color-text-muted); }
.lc-phone { font-size: 0.68rem; color: var(--color-text-muted); margin-top: 3px; font-family: var(--font-mono); }
.lc-bottom { display: flex; align-items: center; justify-content: space-between; gap: 4px; margin-top: 6px; }
.lc-days { font-size: 0.62rem; color: var(--color-text-muted); font-family: var(--font-mono); }
.lc-assigned { font-size: 0.62rem; color: var(--color-primary); font-weight: 500; }
.lc-actions { display: flex; gap: 4px; margin-top: 6px; border-top: 1px solid var(--color-border-light); padding-top: 6px; }
.lc-btn {
  display: flex; align-items: center; justify-content: center;
  width: 26px; height: 26px; border-radius: 6px; border: 1px solid var(--color-border-light);
  background: white; color: var(--color-text-muted); cursor: pointer; transition: all 0.15s;
  text-decoration: none;
}
.lc-btn:hover { background: rgba(139,126,200,0.06); color: var(--color-primary); border-color: rgba(139,126,200,0.2); }

/* List View */
.leads-list { display: flex; flex-direction: column; gap: 4px; }
.list-row { background: white; border: 1px solid var(--color-border-light); border-radius: 12px; transition: all 0.2s; }
.list-row:hover { border-color: rgba(139,126,200,0.2); }
.list-link {
  display: flex; align-items: center; gap: 12px; padding: 12px 16px;
  text-decoration: none; color: inherit;
}
.lr-avatar { width: 34px; height: 34px; border-radius: 50%; background: rgba(139,126,200,0.08); color: var(--color-primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.lr-info { flex: 1; min-width: 0; }
.lr-name { font-size: 0.82rem; font-weight: 600; display: block; }
.lr-meta { font-size: 0.7rem; color: var(--color-text-muted); }
.lr-badge { font-size: 0.62rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; white-space: nowrap; }
.lr-source { font-size: 0.7rem; color: var(--color-text-muted); white-space: nowrap; }
.lr-assigned { font-size: 0.7rem; color: var(--color-primary); white-space: nowrap; }
.lr-date { font-size: 0.68rem; color: var(--color-text-muted); font-family: var(--font-mono); }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); z-index: 1000; display: flex; align-items: center; justify-content: center; padding: 20px; }
.modal-card { background: white; border-radius: 16px; padding: 28px; width: 100%; max-width: 460px; box-shadow: 0 20px 60px rgba(0,0,0,0.15); }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; margin-bottom: 18px; }
.fg { margin-bottom: 14px; }
.fl { display: block; font-size: 0.72rem; font-weight: 600; color: var(--color-text-muted); margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.03em; }
.fi { width: 100%; padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 8px; font-size: 0.82rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s; box-sizing: border-box; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 20px; }
.btn-cancel { padding: 8px 16px; border: 1px solid var(--color-border-light); border-radius: 8px; background: white; font-size: 0.8rem; cursor: pointer; }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta, linear-gradient(135deg, #8B7EC8, #E8A0BF)); color: white; border: none; border-radius: 8px; font-size: 0.8rem; font-weight: 600; cursor: pointer; }
.btn-submit:disabled { opacity: 0.5; cursor: default; }

.empty-card { text-align: center; padding: 48px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; }
.empty-text { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 8px; }
</style>

<template>
  <div class="fd-page">
    <!-- Skeleton -->
    <div v-if="loading" class="skeleton-wrap">
      <div class="skel skel-hero" />
      <div class="skel skel-tabs" />
      <div class="skel skel-card" />
      <div class="skel skel-card" />
    </div>

    <template v-else-if="data">
      <!-- Hero -->
      <div class="fd-hero">
        <NuxtLink to="/coordinator/families" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Семьи</NuxtLink>
        <div class="hero-row">
          <div class="hero-avatar">{{ initials }}</div>
          <div class="hero-info">
            <h1 class="hero-title">{{ data.family.mother?.name || 'Без имени' }}</h1>
            <p class="hero-sub">
              {{ data.family.mother?.phone }} · {{ stageLabel }}
              <template v-if="data.week_or_age"> · {{ data.week_or_age }}</template>
            </p>
          </div>
          <div class="hero-actions">
            <a v-if="data.family.mother?.phone" :href="`tel:${data.family.mother.phone}`" class="hero-btn"><Icon name="lucide:phone" size="14" /></a>
            <button class="hero-btn" @click="showActivity = true"><Icon name="lucide:message-square-plus" size="14" /></button>
            <button class="hero-btn" @click="showTask = true"><Icon name="lucide:list-plus" size="14" /></button>
          </div>
        </div>
        <div class="stat-chips">
          <span class="chip"><Icon name="lucide:heart" size="13" /> {{ stageLabel }}</span>
          <span class="chip"><Icon name="lucide:baby" size="13" /> Детей: <strong>{{ data.children.length }}</strong></span>
          <span class="chip" :class="{ warn: data.journey?.overdue_events }">
            <Icon name="lucide:alert-triangle" size="13" /> Просрочено: <strong>{{ data.journey?.overdue_events || 0 }}</strong>
          </span>
          <span v-if="data.adherence !== null" class="chip" :class="{ good: data.adherence >= 80, warn: data.adherence < 60 }">
            <Icon name="lucide:pill" size="13" /> Приверженность: <strong>{{ data.adherence }}%</strong>
          </span>
          <span v-if="data.pending_tasks.length" class="chip warn">
            <Icon name="lucide:clipboard-list" size="13" /> Задач: <strong>{{ data.pending_tasks.length }}</strong>
          </span>
        </div>
      </div>

      <!-- Tabs -->
      <div class="tabs-bar">
        <button v-for="t in tabs" :key="t.key" class="tab-btn" :class="{ active: activeTab === t.key }" @click="activeTab = t.key">
          <Icon :name="t.icon" size="14" /> {{ t.label }}
        </button>
      </div>

      <!-- ═══════ TAB: Overview ═══════ -->
      <template v-if="activeTab === 'overview'">
        <div class="grid-2">
          <!-- Left col -->
          <div class="stack">
            <!-- Family info -->
            <div class="card">
              <h2 class="card-title"><Icon name="lucide:user" size="16" /> Информация</h2>
              <div class="detail-grid">
                <div><span class="dg-label">Мама</span><span class="dg-value">{{ data.family.mother?.name || '—' }}</span></div>
                <div><span class="dg-label">Телефон</span><span class="dg-value">{{ data.family.mother?.phone || '—' }}</span></div>
                <div><span class="dg-label">Email</span><span class="dg-value">{{ data.family.mother?.email || '—' }}</span></div>
                <div><span class="dg-label">Статус</span><span class="dg-value">{{ data.family.status }}</span></div>
                <template v-if="data.family.father">
                  <div><span class="dg-label">Отец</span><span class="dg-value">{{ data.family.father.name }}</span></div>
                  <div><span class="dg-label">Телефон отца</span><span class="dg-value">{{ data.family.father.phone || '—' }}</span></div>
                </template>
                <template v-if="data.family.mother_profile">
                  <div><span class="dg-label">Группа крови</span><span class="dg-value">{{ data.family.mother_profile.blood_type || '—' }} {{ data.family.mother_profile.rh_factor || '' }}</span></div>
                  <div><span class="dg-label">Беременностей</span><span class="dg-value">G{{ data.family.mother_profile.gravida || '?' }}P{{ data.family.mother_profile.para || '?' }}</span></div>
                  <div v-if="data.family.mother_profile.edd_date"><span class="dg-label">ПДР</span><span class="dg-value">{{ fmtDate(data.family.mother_profile.edd_date) }}</span></div>
                  <div v-if="data.family.mother_profile.allergies?.length"><span class="dg-label">Аллергии</span><span class="dg-value">{{ data.family.mother_profile.allergies.join(', ') }}</span></div>
                  <div v-if="data.family.mother_profile.chronic_conditions?.length"><span class="dg-label">Хрон. заболевания</span><span class="dg-value">{{ data.family.mother_profile.chronic_conditions.join(', ') }}</span></div>
                </template>
                <div><span class="dg-label">Зарегистрирована</span><span class="dg-value">{{ fmtDate(data.family.created_at) }}</span></div>
                <div v-if="data.family.mother?.last_seen"><span class="dg-label">Посл. визит</span><span class="dg-value">{{ fmtDateTime(data.family.mother.last_seen) }}</span></div>
              </div>
            </div>

            <!-- Children -->
            <div class="card">
              <h2 class="card-title"><Icon name="lucide:baby" size="16" /> Дети</h2>
              <AppSharedEmptyState v-if="!data.children.length" size="sm" icon="lucide:baby" title="Детей пока нет" />
              <div v-for="c in data.children" :key="c.id" class="child-row">
                <div class="child-avatar">{{ (c.name || '?')[0] }}</div>
                <div class="child-info">
                  <span class="child-name">{{ c.name }}</span>
                  <span class="child-age">{{ childAge(c.dob) }}</span>
                </div>
                <div class="child-meta">
                  <span v-if="c.blood_type" class="mini-tag">{{ c.blood_type }}</span>
                  <span v-if="c.gender" class="mini-tag">{{ c.gender === 'male' ? '♂' : '♀' }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Right col -->
          <div class="stack">
            <!-- Journey progress -->
            <div v-if="data.journey" class="card">
              <h2 class="card-title"><Icon name="lucide:route" size="16" /> Маршрут</h2>
              <div class="j-progress-header">
                <span class="j-badge" :class="data.journey.type">{{ journeyTypeLabel(data.journey.type) }}</span>
                <span class="j-pct-big">{{ data.journey.progress_pct }}%</span>
              </div>
              <div class="j-bar-wrap-lg">
                <div class="j-bar" :style="{ width: data.journey.progress_pct + '%' }" />
              </div>
              <div class="j-stats">
                <span><strong>{{ data.journey.completed_events }}</strong> / {{ data.journey.total_events }} событий</span>
                <span v-if="data.journey.overdue_events" class="j-overdue"><Icon name="lucide:alert-triangle" size="12" /> {{ data.journey.overdue_events }} просрочено</span>
              </div>
            </div>

            <!-- Pending tasks -->
            <div v-if="data.pending_tasks.length" class="card card-warn">
              <h2 class="card-title"><Icon name="lucide:clipboard-list" size="16" class="ic-warn" /> Задачи ({{ data.pending_tasks.length }})</h2>
              <div v-for="t in data.pending_tasks" :key="t.id" class="task-row">
                <span class="task-priority" :class="t.priority" />
                <span class="task-title">{{ t.title }}</span>
                <span class="task-date">{{ fmtDate(t.created_at) }}</span>
              </div>
            </div>

            <!-- Active prescriptions -->
            <div v-if="data.prescriptions.length" class="card">
              <h2 class="card-title"><Icon name="lucide:pill" size="16" /> Назначения</h2>
              <div v-for="rx in data.prescriptions" :key="rx.id" class="rx-row">
                <div class="rx-info">
                  <span class="rx-name">{{ rx.medication }}</span>
                  <span class="rx-dosage">{{ rx.dosage }} · {{ rx.frequency }}</span>
                </div>
                <span v-if="rx.time_of_day" class="mini-tag">{{ rx.time_of_day }}</span>
              </div>
            </div>

            <!-- Nearest appointments -->
            <div v-if="data.appointments.length" class="card">
              <h2 class="card-title"><Icon name="lucide:calendar" size="16" /> Приёмы</h2>
              <div v-for="a in data.appointments.slice(0, 5)" :key="a.id" class="appt-row">
                <div class="appt-info">
                  <span class="appt-date">{{ fmtDate(a.appointment_date) }}</span>
                  <span class="appt-time">{{ a.start_time?.slice(0, 5) }}</span>
                </div>
                <span class="appt-reason">{{ a.reason || '—' }}</span>
                <span class="appt-badge" :class="a.status">{{ apptStatusLabel(a.status) }}</span>
              </div>
            </div>
          </div>
        </div>
      </template>

      <!-- ═══════ TAB: Timeline ═══════ -->
      <template v-if="activeTab === 'timeline'">
        <div class="card">
          <div class="card-title-row">
            <h2 class="card-title"><Icon name="lucide:clock" size="16" /> Хронология</h2>
            <button class="btn-sm" @click="showActivity = true"><Icon name="lucide:plus" size="12" /> Записать</button>
          </div>
          <AppSharedEmptyState v-if="!activities.length && !activitiesLoading" size="sm" icon="lucide:clock" title="История взаимодействий пуста" />
          <div v-for="act in activities" :key="act.id" class="activity-item">
            <div class="act-dot" :class="act.type" />
            <div class="act-body">
              <div class="act-header">
                <span class="act-type-badge" :class="act.type">{{ actTypeLabel(act.type) }}</span>
                <span class="act-date">{{ fmtDateTime(act.created_at) }}</span>
              </div>
              <p class="act-summary">{{ act.summary }}</p>
              <span v-if="act.performer_name" class="act-performer">{{ act.performer_name }}</span>
            </div>
          </div>
        </div>
      </template>

      <!-- ═══════ TAB: Journey ═══════ -->
      <template v-if="activeTab === 'journey'">
        <div v-if="!data.journey" class="card"><AppSharedEmptyState size="sm" icon="lucide:route" title="Активный маршрут не найден" /></div>
        <template v-else>
          <div class="card">
            <h2 class="card-title"><Icon name="lucide:route" size="16" /> {{ journeyTypeLabel(data.journey.type) }} — События</h2>
            <div class="events-filters">
              <button v-for="s in eventStatuses" :key="s.key" class="filter-chip" :class="{ active: eventFilter === s.key }" @click="eventFilter = s.key">
                {{ s.label }} <span v-if="s.count" class="filter-count">{{ s.count }}</span>
              </button>
            </div>
            <div v-for="ev in filteredEvents" :key="ev.id" class="ev-item" :class="ev.status">
              <div class="ev-status-dot" :class="ev.status" />
              <div class="ev-content">
                <span class="ev-title">{{ ev.title }}</span>
                <span v-if="ev.due_date" class="ev-due">{{ fmtDate(ev.due_date) }}</span>
              </div>
              <span v-if="ev.is_mandatory" class="mini-tag mandatory">Обязательно</span>
              <span class="ev-status-label" :class="ev.status">{{ evStatusLabel(ev.status) }}</span>
            </div>
          </div>
        </template>
      </template>

      <!-- ═══════ TAB: Prescriptions ═══════ -->
      <template v-if="activeTab === 'prescriptions'">
        <div class="card">
          <h2 class="card-title"><Icon name="lucide:pill" size="16" /> Назначения</h2>
          <AppSharedEmptyState v-if="!data.prescriptions.length" size="sm" icon="lucide:pill" title="Назначений нет" />
          <div v-for="rx in data.prescriptions" :key="rx.id" class="rx-detail-row">
            <div class="rx-detail-main">
              <span class="rx-name">{{ rx.medication }}</span>
              <span class="rx-dosage">{{ rx.dosage }}</span>
            </div>
            <div class="rx-detail-meta">
              <span><Icon name="lucide:repeat" size="12" /> {{ rx.frequency }}</span>
              <span v-if="rx.time_of_day"><Icon name="lucide:clock" size="12" /> {{ rx.time_of_day }}</span>
              <span><Icon name="lucide:calendar" size="12" /> {{ fmtDate(rx.start_date) }} — {{ rx.end_date ? fmtDate(rx.end_date) : 'бессрочно' }}</span>
            </div>
            <p v-if="rx.instructions" class="rx-instructions">{{ rx.instructions }}</p>
          </div>
        </div>
        <div v-if="data.adherence !== null" class="card">
          <h2 class="card-title"><Icon name="lucide:activity" size="16" /> Приверженность (30 дней)</h2>
          <div class="adherence-bar-wrap">
            <div class="adherence-bar" :class="{ good: data.adherence >= 80, mid: data.adherence >= 60 && data.adherence < 80, low: data.adherence < 60 }" :style="{ width: data.adherence + '%' }">
              {{ data.adherence }}%
            </div>
          </div>
        </div>
      </template>

      <!-- ═══════ TAB: Notes ═══════ -->
      <template v-if="activeTab === 'notes'">
        <div class="card">
          <div class="card-title-row">
            <h2 class="card-title"><Icon name="lucide:sticky-note" size="16" /> Заметки</h2>
            <button class="btn-sm" @click="showNote = true"><Icon name="lucide:plus" size="12" /> Добавить</button>
          </div>
          <AppSharedEmptyState v-if="!data.notes.length" size="sm" icon="lucide:sticky-note" title="Заметок пока нет" />
          <div v-for="n in data.notes" :key="n.id" class="note-item" :class="{ pinned: n.is_pinned }">
            <div class="note-header">
              <Icon v-if="n.is_pinned" name="lucide:pin" size="12" class="note-pin" />
              <span class="note-author">{{ n.author_name || 'Система' }}</span>
              <span class="note-date">{{ fmtDateTime(n.created_at) }}</span>
            </div>
            <p class="note-content">{{ n.content }}</p>
          </div>
        </div>
      </template>
    </template>

    <!-- ═══════ MODALS ═══════ -->

    <!-- Activity modal -->
    <Teleport to="body">
      <div v-if="showActivity" class="modal-overlay" @click.self="showActivity = false">
        <div class="modal-card">
          <h2 class="modal-title">Записать взаимодействие</h2>
          <div class="fg">
            <label class="fl">Тип</label>
            <select v-model="actForm.type" class="fi">
              <option value="call">Звонок</option>
              <option value="whatsapp">WhatsApp</option>
              <option value="sms">SMS</option>
              <option value="email">Email</option>
              <option value="note">Заметка</option>
            </select>
          </div>
          <div class="fg">
            <label class="fl">Описание</label>
            <textarea v-model="actForm.summary" class="fi" rows="3" placeholder="Описание звонка / сообщения..." />
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showActivity = false">Отмена</button>
            <button class="btn-submit" :disabled="!actForm.summary || actSaving" @click="saveActivity">
              {{ actSaving ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Note modal -->
    <Teleport to="body">
      <div v-if="showNote" class="modal-overlay" @click.self="showNote = false">
        <div class="modal-card">
          <h2 class="modal-title">Новая заметка</h2>
          <div class="fg">
            <label class="fl">Заголовок</label>
            <input v-model="noteForm.title" class="fi" placeholder="Тема заметки..." />
          </div>
          <div class="fg">
            <label class="fl">Содержание</label>
            <textarea v-model="noteForm.body" class="fi" rows="4" placeholder="Текст заметки..." />
          </div>
          <label class="checkbox-row">
            <input v-model="noteForm.pinned" type="checkbox" />
            <span>Закрепить</span>
          </label>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showNote = false">Отмена</button>
            <button class="btn-submit" :disabled="!noteForm.title || !noteForm.body || noteSaving" @click="saveNote">
              {{ noteSaving ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

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
            <button class="btn-submit" @click="saveTask">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const route = useRoute()
const familyId = computed(() => route.params.id as string)

// ── Data ──
const loading = ref(true)
const data = ref<any>(null)

const activeTab = ref('overview')
const tabs = [
  { key: 'overview', label: 'Обзор', icon: 'lucide:layout-dashboard' },
  { key: 'timeline', label: 'Хронология', icon: 'lucide:clock' },
  { key: 'journey', label: 'Маршрут', icon: 'lucide:route' },
  { key: 'prescriptions', label: 'Назначения', icon: 'lucide:pill' },
  { key: 'notes', label: 'Заметки', icon: 'lucide:sticky-note' },
]

// ── Modals ──
const showActivity = ref(false)
const showNote = ref(false)
const showTask = ref(false)
const actForm = reactive({ type: 'call', summary: '' })
const noteForm = reactive({ title: '', body: '', pinned: false })
const taskForm = reactive({ title: '', desc: '', priority: 'medium', type: 'custom', due: '' })
const actSaving = ref(false)
const noteSaving = ref(false)

// ── Timeline ──
const activities = ref<any[]>([])
const activitiesLoading = ref(false)

// ── Journey filter ──
const eventFilter = ref('all')

const initials = computed(() => {
  const name = data.value?.family?.mother?.name || ''
  return name.split(' ').map((w: string) => w[0]).join('').slice(0, 2)
})

const stageLabel = computed(() => {
  const labels: Record<string, string> = { pregnancy: 'Беременность', postpartum: 'Послеродовой', infant: 'Младенец', toddler: 'Тоддлер' }
  return labels[data.value?.stage] || 'Неизвестно'
})

const eventStatuses = computed(() => {
  const events = data.value?.journey?.events || []
  return [
    { key: 'all', label: 'Все', count: events.length },
    { key: 'overdue', label: 'Просрочено', count: events.filter((e: any) => e.status === 'overdue').length },
    { key: 'active', label: 'Активные', count: events.filter((e: any) => e.status === 'active' || e.status === 'pending').length },
    { key: 'completed', label: 'Выполнено', count: events.filter((e: any) => e.status === 'completed').length },
  ]
})

const filteredEvents = computed(() => {
  const events = data.value?.journey?.events || []
  if (eventFilter.value === 'all') return events
  if (eventFilter.value === 'active') return events.filter((e: any) => e.status === 'active' || e.status === 'pending')
  return events.filter((e: any) => e.status === eventFilter.value)
})

// ── Helpers ──
function fmtDate(d: string | null) {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short', year: 'numeric' })
}
function fmtDateTime(d: string | null) {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}
function childAge(dob: string | null) {
  if (!dob) return ''
  const days = Math.floor((Date.now() - new Date(dob).getTime()) / 86_400_000)
  if (days < 30) return `${days} дн`
  if (days < 365) return `${Math.floor(days / 30)} мес`
  return `${Math.floor(days / 365)} г ${Math.floor((days % 365) / 30)} мес`
}
function journeyTypeLabel(t: string) {
  const m: Record<string, string> = { pregnancy: 'Беременность', postpartum: 'Послеродовой', infant: 'Младенец', toddler: 'Тоддлер' }
  return m[t] || t
}
function actTypeLabel(t: string) {
  const m: Record<string, string> = { call: 'Звонок', whatsapp: 'WhatsApp', sms: 'SMS', email: 'Email', note: 'Заметка' }
  return m[t] || t
}
function evStatusLabel(s: string) {
  const m: Record<string, string> = { completed: 'Выполнено', overdue: 'Просрочено', active: 'Активно', pending: 'Ожидает', skipped: 'Пропущено' }
  return m[s] || s
}
function apptStatusLabel(s: string) {
  const m: Record<string, string> = { scheduled: 'Назначен', completed: 'Завершён', cancelled: 'Отменён', no_show: 'Не пришёл' }
  return m[s] || s
}

// ── Fetch 360 ──
async function load360() {
  loading.value = true
  try {
    data.value = await $fetch(`/api/families/${familyId.value}/360`)
  } catch (e) {
    console.error('Failed to load family 360', e)
  } finally {
    loading.value = false
  }
}

// ── Fetch activities (lazy on tab switch) ──
async function loadActivities() {
  if (activities.value.length || activitiesLoading.value) return
  activitiesLoading.value = true
  try {
    activities.value = await $fetch<any[]>(`/api/families/${familyId.value}/activities`)
  } catch (e) {
    console.error('Failed to load activities', e)
  } finally {
    activitiesLoading.value = false
  }
}

watch(activeTab, (tab) => {
  if (tab === 'timeline') loadActivities()
})

// ── Save activity ──
async function saveActivity() {
  actSaving.value = true
  try {
    const newAct = await $fetch(`/api/families/${familyId.value}/activities`, {
      method: 'POST',
      body: { type: actForm.type, summary: actForm.summary },
    })
    activities.value.unshift(newAct)
    showActivity.value = false
    actForm.summary = ''
  } catch (e) {
    console.error(e)
  } finally {
    actSaving.value = false
  }
}

// ── Save note ──
async function saveNote() {
  noteSaving.value = true
  try {
    const newNote = await $fetch(`/api/families/${familyId.value}/notes`, {
      method: 'POST',
      body: { title: noteForm.title, body: noteForm.body, pinned: noteForm.pinned },
    })
    data.value.notes.unshift(newNote)
    showNote.value = false
    noteForm.title = ''
    noteForm.body = ''
    noteForm.pinned = false
  } catch (e) {
    console.error(e)
  } finally {
    noteSaving.value = false
  }
}

// ── Save task ──
async function saveTask() {
  try {
    await $fetch('/api/tasks', {
      method: 'POST',
      body: {
        family_id: familyId.value,
        title: taskForm.title,
        description: taskForm.desc,
        priority: taskForm.priority,
        type: taskForm.type,
        due_date: taskForm.due || undefined,
      },
    })
    showTask.value = false
    taskForm.title = ''
    taskForm.desc = ''
    taskForm.due = ''
    await load360()
  } catch (e) {
    console.error(e)
  }
}

onMounted(load360)
</script>

<style scoped>
.fd-page { max-width: 1000px; margin: 0 auto; display: flex; flex-direction: column; gap: 14px; }

/* Skeleton */
.skeleton-wrap { display: flex; flex-direction: column; gap: 14px; }
.skel { border-radius: 14px; background: linear-gradient(90deg, #f0f0f0 25%, #e8e8e8 50%, #f0f0f0 75%); background-size: 200% 100%; animation: shimmer 1.5s infinite; }
.skel-hero { height: 160px; }
.skel-tabs { height: 44px; }
.skel-card { height: 180px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }

/* Hero */
.fd-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 10px; }
.hero-row { display: flex; align-items: center; gap: 14px; }
.hero-avatar { width: 48px; height: 48px; border-radius: 50%; background: var(--gradient-cta); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; flex-shrink: 0; }
.hero-info { flex: 1; }
.hero-title { font-family: var(--font-display); font-size: 1.3rem; font-weight: 700; }
.hero-sub { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 2px; }
.hero-actions { display: flex; gap: 6px; }
.hero-btn { width: 36px; height: 36px; border-radius: 10px; border: 1px solid var(--color-border-light); background: white; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--color-primary); transition: background 0.15s; }
.hero-btn:hover { background: rgba(139,126,200,0.06); }
.stat-chips { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 14px; }
.chip { display: flex; align-items: center; gap: 5px; padding: 4px 12px; background: rgba(139,126,200,0.06); border-radius: 20px; font-size: 0.72rem; color: var(--color-text-muted); }
.chip strong { color: var(--color-text); }
.chip.warn strong { color: var(--color-danger); }
.chip.good strong { color: var(--color-success); }

/* Tabs */
.tabs-bar { display: flex; gap: 4px; background: white; border: 1px solid var(--color-border-light); border-radius: 12px; padding: 4px; overflow-x: auto; }
.tab-btn { display: flex; align-items: center; gap: 5px; padding: 7px 14px; border: none; background: none; border-radius: 8px; font-size: 0.78rem; font-weight: 600; cursor: pointer; color: var(--color-text-muted); font-family: var(--font-body); white-space: nowrap; transition: all 0.15s; }
.tab-btn.active { background: var(--gradient-cta); color: white; }
.tab-btn:not(.active):hover { background: rgba(139,126,200,0.06); }

/* Grid */
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
@media (max-width: 768px) { .grid-2 { grid-template-columns: 1fr; } }
.stack { display: flex; flex-direction: column; gap: 14px; }

/* Cards */
.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px; }
.card-warn { border-color: rgba(212,114,124,0.25); background: rgba(212,114,124,0.02); }
.card-title { font-size: 0.92rem; font-weight: 700; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
.card-title-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.card-title-row .card-title { margin-bottom: 0; }
.ic-warn { color: var(--color-danger); }

/* Detail grid */
.detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.dg-label { display: block; font-size: 0.65rem; font-weight: 600; color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.03em; margin-bottom: 2px; }
.dg-value { font-size: 0.82rem; }

/* Children */
.child-row { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--color-border-light); }
.child-row:last-child { border: none; }
.child-avatar { width: 32px; height: 32px; border-radius: 50%; background: rgba(168,200,232,0.15); color: var(--color-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.78rem; flex-shrink: 0; }
.child-info { display: flex; flex-direction: column; flex: 1; }
.child-name { font-weight: 600; font-size: 0.88rem; }
.child-age { font-size: 0.72rem; color: var(--color-text-muted); }
.child-meta { display: flex; gap: 4px; }

/* Mini tags */
.mini-tag { font-size: 0.65rem; font-weight: 600; padding: 2px 8px; border-radius: 8px; background: rgba(139,126,200,0.08); color: var(--color-primary); }
.mini-tag.mandatory { background: rgba(232,160,191,0.12); color: #C27BA0; }

/* Journey progress */
.j-progress-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.j-pct-big { font-size: 1.4rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); }
.j-bar-wrap-lg { height: 10px; background: rgba(139,126,200,0.08); border-radius: 5px; overflow: hidden; margin-bottom: 10px; }
.j-bar { height: 100%; background: var(--gradient-cta); border-radius: 5px; transition: width 0.4s ease; }
.j-stats { display: flex; justify-content: space-between; font-size: 0.75rem; color: var(--color-text-muted); }
.j-overdue { color: var(--color-danger); display: flex; align-items: center; gap: 3px; }
.j-badge { font-size: 0.72rem; font-weight: 600; padding: 3px 10px; border-radius: 10px; }
.j-badge.pregnancy { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.j-badge.postpartum { background: rgba(232,160,191,0.12); color: #C27BA0; }
.j-badge.infant { background: rgba(168,200,232,0.12); color: #6B9AC4; }
.j-badge.toddler { background: rgba(242,196,160,0.15); color: #C49A6C; }

/* Tasks */
.task-row { display: flex; align-items: center; gap: 8px; padding: 6px 0; font-size: 0.82rem; border-bottom: 1px solid rgba(212,114,124,0.08); }
.task-row:last-child { border: none; }
.task-priority { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.task-priority.high { background: var(--color-danger); }
.task-priority.medium { background: var(--color-warning, #F59E0B); }
.task-priority.low { background: var(--color-success); }
.task-title { flex: 1; font-weight: 500; }
.task-date { font-size: 0.72rem; color: var(--color-text-muted); }

/* Prescriptions */
.rx-row { display: flex; align-items: center; gap: 10px; padding: 7px 0; border-bottom: 1px solid var(--color-border-light); }
.rx-row:last-child { border: none; }
.rx-info { display: flex; flex-direction: column; flex: 1; }
.rx-name { font-weight: 600; font-size: 0.85rem; }
.rx-dosage { font-size: 0.72rem; color: var(--color-text-muted); }
.rx-detail-row { padding: 12px 0; border-bottom: 1px solid var(--color-border-light); }
.rx-detail-row:last-child { border: none; }
.rx-detail-main { display: flex; align-items: baseline; gap: 8px; margin-bottom: 6px; }
.rx-detail-meta { display: flex; gap: 14px; font-size: 0.72rem; color: var(--color-text-muted); flex-wrap: wrap; }
.rx-detail-meta span { display: flex; align-items: center; gap: 4px; }
.rx-instructions { margin-top: 6px; font-size: 0.78rem; color: var(--color-text-muted); font-style: italic; }

/* Adherence */
.adherence-bar-wrap { height: 28px; background: rgba(139,126,200,0.08); border-radius: 8px; overflow: hidden; }
.adherence-bar { height: 100%; display: flex; align-items: center; justify-content: center; font-size: 0.82rem; font-weight: 700; color: white; border-radius: 8px; transition: width 0.4s ease; }
.adherence-bar.good { background: var(--color-success); }
.adherence-bar.mid { background: var(--color-warning, #F59E0B); }
.adherence-bar.low { background: var(--color-danger); }

/* Appointments */
.appt-row { display: flex; align-items: center; gap: 10px; padding: 6px 0; font-size: 0.82rem; border-bottom: 1px solid var(--color-border-light); }
.appt-row:last-child { border: none; }
.appt-info { display: flex; flex-direction: column; min-width: 90px; }
.appt-date { font-weight: 600; font-size: 0.78rem; }
.appt-time { font-size: 0.68rem; color: var(--color-text-muted); }
.appt-reason { flex: 1; }
.appt-badge { font-size: 0.65rem; font-weight: 600; padding: 2px 8px; border-radius: 8px; }
.appt-badge.scheduled { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.appt-badge.completed { background: rgba(46,160,67,0.1); color: var(--color-success); }
.appt-badge.cancelled { background: rgba(212,114,124,0.1); color: var(--color-danger); }
.appt-badge.no_show { background: rgba(212,114,124,0.15); color: var(--color-danger); }

/* Timeline / Activities */
.activity-item { display: flex; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--color-border-light); }
.activity-item:last-child { border: none; }
.act-dot { width: 10px; height: 10px; border-radius: 50%; margin-top: 4px; flex-shrink: 0; }
.act-dot.call { background: var(--color-primary); }
.act-dot.whatsapp { background: #25D366; }
.act-dot.sms { background: #F59E0B; }
.act-dot.email { background: #6B9AC4; }
.act-dot.note { background: #C27BA0; }
.act-body { flex: 1; }
.act-header { display: flex; align-items: center; gap: 8px; margin-bottom: 3px; }
.act-type-badge { font-size: 0.65rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; }
.act-type-badge.call { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.act-type-badge.whatsapp { background: rgba(37,211,102,0.1); color: #25D366; }
.act-type-badge.sms { background: rgba(245,158,11,0.1); color: #D97706; }
.act-type-badge.email { background: rgba(107,154,196,0.1); color: #6B9AC4; }
.act-type-badge.note { background: rgba(194,123,160,0.1); color: #C27BA0; }
.act-date { font-size: 0.68rem; color: var(--color-text-muted); }
.act-summary { font-size: 0.82rem; line-height: 1.4; }
.act-performer { font-size: 0.68rem; color: var(--color-text-muted); margin-top: 2px; display: block; }

/* Journey events */
.events-filters { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 14px; }
.filter-chip { padding: 5px 12px; border: 1px solid var(--color-border-light); border-radius: 8px; background: white; font-size: 0.75rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); display: flex; align-items: center; gap: 4px; }
.filter-chip.active { background: var(--color-primary); color: white; border-color: var(--color-primary); }
.filter-count { font-weight: 700; }
.ev-item { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--color-border-light); }
.ev-item:last-child { border: none; }
.ev-status-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.ev-status-dot.completed { background: var(--color-success); }
.ev-status-dot.overdue { background: var(--color-danger); }
.ev-status-dot.active, .ev-status-dot.pending { background: var(--color-primary); }
.ev-status-dot.skipped { background: var(--color-text-muted); }
.ev-content { flex: 1; }
.ev-title { font-size: 0.82rem; font-weight: 500; display: block; }
.ev-due { font-size: 0.68rem; color: var(--color-text-muted); }
.ev-status-label { font-size: 0.65rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; }
.ev-status-label.completed { background: rgba(46,160,67,0.1); color: var(--color-success); }
.ev-status-label.overdue { background: rgba(212,114,124,0.1); color: var(--color-danger); }
.ev-status-label.active, .ev-status-label.pending { background: rgba(139,126,200,0.1); color: var(--color-primary); }

/* Notes */
.note-item { padding: 12px; border: 1px solid var(--color-border-light); border-radius: 10px; margin-bottom: 10px; }
.note-item.pinned { border-color: rgba(139,126,200,0.3); background: rgba(139,126,200,0.03); }
.note-header { display: flex; align-items: center; gap: 6px; margin-bottom: 6px; }
.note-pin { color: var(--color-primary); }
.note-author { font-size: 0.75rem; font-weight: 600; }
.note-date { font-size: 0.68rem; color: var(--color-text-muted); margin-left: auto; }
.note-content { font-size: 0.82rem; line-height: 1.5; white-space: pre-line; }

/* Buttons */
.btn-sm { display: flex; align-items: center; gap: 4px; padding: 5px 12px; border: 1px solid var(--color-border-light); border-radius: 8px; background: white; font-size: 0.72rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); color: var(--color-primary); }
.btn-sm:hover { background: rgba(139,126,200,0.06); }

.empty-mini { text-align: center; padding: 20px; font-size: 0.82rem; color: var(--color-text-muted); }

/* Modals */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 460px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fg-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; background: white; resize: vertical; }
.fi:focus { border-color: var(--color-primary); }
.checkbox-row { display: flex; align-items: center; gap: 8px; font-size: 0.82rem; cursor: pointer; }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }
</style>

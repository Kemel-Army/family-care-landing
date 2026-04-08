<template>
  <div class="patient-detail">
    <header class="page-header">
      <NuxtLink to="/doctor/patients" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Пациенты
      </NuxtLink>
      <h1 class="page-title">{{ familyName }}</h1>
    </header>

    <div v-if="loading" class="loading">
      <Icon name="lucide:loader-2" size="24" class="spin" /> Загрузка...
    </div>

    <template v-else>
      <!-- Mother Profile -->
      <section v-if="mother" class="card">
        <h2 class="card-title"><Icon name="lucide:user" size="16" /> Мама</h2>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Имя</span>
            <span class="info-value">{{ mother.first_name }} {{ mother.last_name }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Телефон</span>
            <span class="info-value">{{ mother.phone ? formatPhone(mother.phone) : '—' }}</span>
          </div>
          <div v-if="motherProfile?.blood_type" class="info-item">
            <span class="info-label">Группа крови</span>
            <span class="info-value">{{ motherProfile.blood_type }}</span>
          </div>
          <div v-if="motherProfile?.edd_date" class="info-item">
            <span class="info-label">ПДР</span>
            <span class="info-value">{{ formatDate(motherProfile.edd_date) }}</span>
          </div>
          <div v-if="motherProfile?.lmp_date" class="info-item">
            <span class="info-label">Срок</span>
            <span class="info-value">{{ formatGestationalWeek(motherProfile.lmp_date) }}</span>
          </div>
        </div>
        <div v-if="motherProfile?.allergies?.length" class="tags-row">
          <span class="info-label">Аллергии:</span>
          <span v-for="a in motherProfile.allergies" :key="a" class="tag tag-warning">{{ a }}</span>
        </div>
        <div v-if="motherProfile?.chronic_conditions?.length" class="tags-row">
          <span class="info-label">Хрон. заболевания:</span>
          <span v-for="c in motherProfile.chronic_conditions" :key="c" class="tag tag-danger">{{ c }}</span>
        </div>
      </section>

      <!-- Children -->
      <section v-if="children.length" class="card">
        <h2 class="card-title"><Icon name="lucide:baby" size="16" /> Дети</h2>
        <div v-for="child in children" :key="child.id" class="child-card">
          <div class="child-header">
            <strong>{{ child.name }}</strong>
            <span v-if="child.dob" class="child-age">{{ formatAge(child.dob) }}</span>
          </div>
          <div class="info-grid compact">
            <div v-if="child.birth_weight" class="info-item">
              <span class="info-label">Вес при рождении</span>
              <span class="info-value">{{ child.birth_weight }} кг</span>
            </div>
            <div v-if="child.birth_height" class="info-item">
              <span class="info-label">Рост при рождении</span>
              <span class="info-value">{{ child.birth_height }} см</span>
            </div>
            <div v-if="child.blood_type" class="info-item">
              <span class="info-label">Группа крови</span>
              <span class="info-value">{{ child.blood_type }}</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Active Journeys + Events -->
      <section v-if="journeys.length" class="card">
        <h2 class="card-title"><Icon name="lucide:route" size="16" /> Маршруты</h2>
        <div v-for="j in journeys" :key="j.id" class="journey-block">
          <div class="journey-header">
            <span class="journey-type-badge">{{ journeyLabel(j.type) }}</span>
            <span class="journey-status" :class="j.status">{{ j.status }}</span>
          </div>

          <!-- Events tabs -->
          <div class="event-tabs">
            <button
              v-for="tab in eventTabs"
              :key="tab.value"
              class="event-tab"
              :class="{ active: activeEventTab === tab.value }"
              @click="activeEventTab = tab.value"
            >
              {{ tab.label }}
              <span v-if="tab.count" class="tab-count">{{ tab.count }}</span>
            </button>
          </div>

          <div class="event-list">
            <div
              v-for="evt in filteredEvents(j.id)"
              :key="evt.id"
              class="event-row"
              :class="evt.status"
            >
              <div class="event-icon" :class="evt.type">
                <Icon :name="eventIcon(evt.type)" size="14" />
              </div>
              <div class="event-body">
                <span class="event-title">{{ evt.title }}</span>
                <span v-if="evt.due_date" class="event-date">{{ formatDate(evt.due_date, 'D MMM YYYY') }}</span>
              </div>
              <span class="event-status-badge" :class="evt.status">{{ eventStatusLabel(evt.status) }}</span>
              <button
                v-if="evt.status === 'upcoming' || evt.status === 'due' || evt.status === 'overdue'"
                class="btn-complete-event"
                @click="completeEvent(evt.id)"
              >
                <Icon name="lucide:check" size="14" />
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Prescriptions -->
      <section class="card">
        <div class="card-header-row">
          <h2 class="card-title"><Icon name="lucide:pill" size="16" /> Назначения</h2>
          <button class="btn-add" @click="showPrescriptionForm = true">
            <Icon name="lucide:plus" size="14" /> Новое назначение
          </button>
        </div>

        <div v-if="prescriptions.length" class="rx-list">
          <div v-for="rx in prescriptions" :key="rx.id" class="rx-card">
            <div class="rx-info">
              <h4>{{ rx.medication }}</h4>
              <p>{{ rx.dosage }} · {{ rx.frequency }}</p>
              <span class="rx-dates">{{ formatDate(rx.start_date, 'D MMM') }} — {{ rx.end_date ? formatDate(rx.end_date, 'D MMM') : 'бессрочно' }}</span>
            </div>
            <span class="rx-status" :class="{ active: rx.is_active }">{{ rx.is_active ? 'Активно' : 'Завершено' }}</span>
          </div>
        </div>
        <p v-else class="empty-mini">Нет активных назначений</p>
      </section>

      <!-- Vaccinations -->
      <section v-if="vaccinations.length" class="card">
        <h2 class="card-title"><Icon name="lucide:shield-check" size="16" /> Прививки</h2>
        <div class="vax-list">
          <div v-for="v in vaccinations" :key="v.id" class="vax-row" :class="v.status">
            <span class="vax-name">{{ v.vaccine_name }}</span>
            <span class="vax-dose">Доза {{ v.dose_number }}</span>
            <span class="vax-date">{{ v.scheduled_date ? formatDate(v.scheduled_date, 'D MMM YYYY') : '—' }}</span>
            <span class="vax-status-badge" :class="v.status">{{ vaxStatusLabel(v.status) }}</span>
          </div>
        </div>
      </section>

      <!-- Documents -->
      <section v-if="documents.length" class="card">
        <h2 class="card-title"><Icon name="lucide:folder" size="16" /> Документы</h2>
        <div class="doc-list">
          <div v-for="doc in documents" :key="doc.id" class="doc-row">
            <Icon :name="docIcon(doc.type)" size="16" class="doc-icon" />
            <span class="doc-title">{{ doc.title }}</span>
            <span class="doc-date">{{ formatDate(doc.created_at, 'D MMM') }}</span>
            <a :href="doc.file_url" target="_blank" rel="noopener" class="doc-download">
              <Icon name="lucide:download" size="14" />
            </a>
          </div>
        </div>
      </section>
    </template>

    <!-- Prescription Form Modal -->
    <Teleport to="body">
      <div v-if="showPrescriptionForm" class="modal-overlay" @click.self="showPrescriptionForm = false">
        <div class="modal-card">
          <h2 class="modal-title">Новое назначение</h2>
          <form class="modal-form" @submit.prevent="handleCreatePrescription">
            <div class="form-group">
              <label class="form-label">Препарат</label>
              <input v-model="rxForm.medication" type="text" class="form-input" placeholder="Витамин D3" required />
            </div>
            <div class="form-row-2">
              <div class="form-group">
                <label class="form-label">Дозировка</label>
                <input v-model="rxForm.dosage" type="text" class="form-input" placeholder="1000 МЕ" required />
              </div>
              <div class="form-group">
                <label class="form-label">Частота</label>
                <input v-model="rxForm.frequency" type="text" class="form-input" placeholder="1 раз в день" required />
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">Время приёма</label>
              <div class="times-row">
                <label v-for="t in timeOptions" :key="t" class="time-check">
                  <input v-model="rxForm.timesOfDay" type="checkbox" :value="t" />
                  <span>{{ t }}</span>
                </label>
              </div>
            </div>
            <div class="form-row-2">
              <div class="form-group">
                <label class="form-label">Начало</label>
                <input v-model="rxForm.startDate" type="date" class="form-input" required />
              </div>
              <div class="form-group">
                <label class="form-label">Конец (необяз.)</label>
                <input v-model="rxForm.endDate" type="date" class="form-input" />
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">Примечания</label>
              <textarea v-model="rxForm.notes" class="form-input form-textarea" rows="2" placeholder="Принимать после еды" />
            </div>

            <p v-if="rxError" class="form-error-global">{{ rxError }}</p>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="showPrescriptionForm = false">Отмена</button>
              <button type="submit" class="btn-submit" :disabled="rxSaving">
                {{ rxSaving ? 'Сохранение...' : 'Назначить' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'
import { prescriptionSchema } from '~/utils/validators'
import { formatDate, formatAge, formatPhone, formatGestationalWeek } from '~/utils/formatters'
import type { ChildProfile, MotherProfile, Journey, JourneyEvent, Prescription, Vaccination, Document as FcDoc } from '~/types/database'

definePageMeta({ layout: 'app' })

const route = useRoute()
const supabase = useSupabaseClient()
const authStore = useAuthStore()

const familyId = route.params.id as string
const loading = ref(true)

// Data
const mother = ref<Record<string, unknown> | null>(null)
const motherProfile = ref<MotherProfile | null>(null)
const children = ref<ChildProfile[]>([])
const journeys = ref<Journey[]>([])
const allEvents = ref<JourneyEvent[]>([])
const prescriptions = ref<Prescription[]>([])
const vaccinations = ref<Vaccination[]>([])
const documents = ref<FcDoc[]>([])
const familyName = ref('Пациент')

// Event filtering
const activeEventTab = ref('all')
const eventTabs = computed(() => {
  const overdue = allEvents.value.filter(e => e.status === 'overdue').length
  const due = allEvents.value.filter(e => e.status === 'due').length
  const upcoming = allEvents.value.filter(e => e.status === 'upcoming').length
  const completed = allEvents.value.filter(e => e.status === 'completed').length
  return [
    { label: 'Все', value: 'all', count: 0 },
    { label: 'Просрочено', value: 'overdue', count: overdue },
    { label: 'Сегодня', value: 'due', count: due },
    { label: 'Предстоит', value: 'upcoming', count: upcoming },
    { label: 'Выполнено', value: 'completed', count: completed },
  ]
})

function filteredEvents(journeyId: string) {
  let events = allEvents.value.filter(e => e.journey_id === journeyId)
  if (activeEventTab.value !== 'all') {
    events = events.filter(e => e.status === activeEventTab.value)
  }
  return events.slice(0, 20)
}

// Prescription form
const showPrescriptionForm = ref(false)
const rxSaving = ref(false)
const rxError = ref('')
const rxForm = reactive({
  medication: '',
  dosage: '',
  frequency: '',
  timesOfDay: [] as string[],
  startDate: dayjs().format('YYYY-MM-DD'),
  endDate: '',
  notes: '',
})
const timeOptions = ['08:00', '12:00', '14:00', '18:00', '21:00']

// Helpers
function journeyLabel(type: string) {
  const map: Record<string, string> = { pregnancy: 'Беременность', postpartum: 'Послеродовой', infant: 'Младенец', toddler: 'Малыш' }
  return map[type] || type
}

function eventStatusLabel(status: string) {
  const map: Record<string, string> = { upcoming: 'Предстоит', due: 'Сегодня', overdue: 'Просрочено', completed: 'Выполнено', skipped: 'Пропущено', cancelled: 'Отменено' }
  return map[status] || status
}

function eventIcon(type: string) {
  const map: Record<string, string> = {
    consultation: 'lucide:stethoscope', screening: 'lucide:scan', analysis: 'lucide:test-tubes',
    ultrasound: 'lucide:monitor', vaccination: 'lucide:shield-check', checkup: 'lucide:clipboard-check',
    specialist: 'lucide:user-check', prescription_start: 'lucide:pill', milestone: 'lucide:star', custom: 'lucide:circle',
  }
  return map[type] || 'lucide:circle'
}

function vaxStatusLabel(status: string) {
  const map: Record<string, string> = { scheduled: 'Запланировано', completed: 'Сделано', skipped: 'Пропущено', postponed: 'Отложено' }
  return map[status] || status
}

function docIcon(type: string) {
  const map: Record<string, string> = {
    analysis: 'lucide:test-tubes', ultrasound: 'lucide:monitor', screening: 'lucide:scan',
    prescription: 'lucide:pill', discharge: 'lucide:file-output', certificate: 'lucide:file-badge',
    photo: 'lucide:image', other: 'lucide:file',
  }
  return map[type] || 'lucide:file'
}

async function completeEvent(eventId: string) {
  const { data, error } = await supabase
    .from('journey_events')
    .update({ status: 'completed', completed_at: new Date().toISOString(), completed_by: authStore.profile?.id })
    .eq('id', eventId)
    .select()
    .single()

  if (!error && data) {
    const idx = allEvents.value.findIndex(e => e.id === eventId)
    if (idx >= 0) allEvents.value[idx] = data as JourneyEvent
  }
}

async function handleCreatePrescription() {
  rxError.value = ''
  const result = prescriptionSchema.safeParse(rxForm)
  if (!result.success) {
    rxError.value = result.error.issues.map(i => i.message).join(', ')
    return
  }

  rxSaving.value = true
  try {
    const { data, error } = await supabase
      .from('prescriptions')
      .insert({
        family_id: familyId,
        child_id: children.value[0]?.id || null,
        medication: rxForm.medication,
        dosage: rxForm.dosage,
        frequency: rxForm.frequency,
        times_of_day: rxForm.timesOfDay,
        start_date: rxForm.startDate,
        end_date: rxForm.endDate || null,
        prescribed_by: authStore.profile?.id,
        is_active: true,
        notes: rxForm.notes || null,
      })
      .select()
      .single()

    if (error) {
      rxError.value = error.message
      return
    }

    if (data) {
      prescriptions.value.unshift(data as Prescription)
      showPrescriptionForm.value = false
      // Reset form
      Object.assign(rxForm, { medication: '', dosage: '', frequency: '', timesOfDay: [], startDate: dayjs().format('YYYY-MM-DD'), endDate: '', notes: '' })
    }
  }
  finally {
    rxSaving.value = false
  }
}

// Load data
onMounted(async () => {
  const [familyRes, mpRes, kidsRes, journeysRes, rxRes, docsRes] = await Promise.all([
    supabase.from('families').select('*, primary_parent:users!families_primary_parent_id_fkey(id, first_name, last_name, phone, email)').eq('id', familyId).single(),
    supabase.from('mother_profiles').select('*').eq('family_id', familyId).single(),
    supabase.from('child_profiles').select('*').eq('family_id', familyId).order('created_at'),
    supabase.from('journeys').select('*').eq('family_id', familyId).order('created_at', { ascending: false }),
    supabase.from('prescriptions').select('*').eq('family_id', familyId).order('created_at', { ascending: false }),
    supabase.from('documents').select('*').eq('family_id', familyId).order('created_at', { ascending: false }).limit(20),
  ])

  if (familyRes.data) {
    const parent = familyRes.data.primary_parent as Record<string, unknown> | null
    if (parent) {
      mother.value = parent
      familyName.value = `${parent.first_name || ''} ${parent.last_name || ''}`.trim()
    }
  }

  if (mpRes.data) motherProfile.value = mpRes.data as MotherProfile
  if (kidsRes.data) children.value = kidsRes.data as ChildProfile[]
  if (journeysRes.data) journeys.value = journeysRes.data as Journey[]
  if (rxRes.data) prescriptions.value = rxRes.data as Prescription[]
  if (docsRes.data) documents.value = docsRes.data as FcDoc[]

  // Fetch events for all journeys
  if (journeys.value.length) {
    const { data: events } = await supabase
      .from('journey_events')
      .select('*')
      .in('journey_id', journeys.value.map(j => j.id))
      .order('due_date')
    if (events) allEvents.value = events as JourneyEvent[]
  }

  // Fetch vaccinations for all children
  if (children.value.length) {
    const { data: vaxData } = await supabase
      .from('vaccinations')
      .select('*')
      .in('child_id', children.value.map(c => c.id))
      .order('scheduled_date')
    if (vaxData) vaccinations.value = vaxData as Vaccination[]
  }

  loading.value = false
})
</script>

<style scoped>
.patient-detail { max-width: 900px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.35rem; font-weight: 700; flex: 1; }

.loading { text-align: center; padding: 48px; color: var(--color-text-muted); display: flex; align-items: center; justify-content: center; gap: 8px; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

/* Card */
.card {
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md); padding: 20px; margin-bottom: 16px;
}
.card-title { font-size: 0.95rem; font-weight: 600; margin-bottom: 14px; display: flex; align-items: center; gap: 8px; color: var(--color-text-primary); }
.card-header-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-header-row .card-title { margin-bottom: 0; }

/* Info grid */
.info-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; }
.info-grid.compact { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 8px; }
.info-item { }
.info-label { font-size: 0.75rem; color: var(--color-text-muted); display: block; margin-bottom: 2px; }
.info-value { font-size: 0.9rem; font-weight: 500; }

/* Tags */
.tags-row { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-top: 10px; }
.tag { font-size: 0.7rem; font-weight: 600; padding: 3px 10px; border-radius: 4px; }
.tag-warning { background: rgba(233, 196, 106, 0.15); color: var(--color-warning); }
.tag-danger { background: rgba(231, 111, 81, 0.15); color: var(--color-danger); }

/* Children */
.child-card { padding: 12px 0; border-bottom: 1px solid var(--color-border-light); }
.child-card:last-child { border: none; padding-bottom: 0; }
.child-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.child-age { font-size: 0.8rem; color: var(--color-text-secondary); }

/* Journeys */
.journey-block { margin-bottom: 16px; }
.journey-header { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.journey-type-badge { font-size: 0.8rem; font-weight: 600; padding: 4px 12px; border-radius: 4px; background: var(--color-primary-ultralight); color: var(--color-primary); }
.journey-status { font-size: 0.75rem; font-weight: 500; }
.journey-status.active { color: var(--color-success); }
.journey-status.completed { color: var(--color-text-muted); }

/* Event tabs */
.event-tabs { display: flex; gap: 4px; margin-bottom: 12px; overflow-x: auto; }
.event-tab {
  padding: 5px 12px; border: 1px solid var(--color-border); border-radius: 16px;
  background: var(--color-surface); font-size: 0.75rem; cursor: pointer;
  font-family: var(--font-body); display: flex; align-items: center; gap: 4px; white-space: nowrap;
}
.event-tab.active { border-color: var(--color-primary); background: var(--color-primary-ultralight); color: var(--color-primary); font-weight: 600; }
.tab-count { font-size: 0.7rem; background: var(--color-primary-ultralight); color: var(--color-primary); padding: 1px 6px; border-radius: 10px; font-weight: 700; }

/* Events */
.event-list { display: flex; flex-direction: column; gap: 6px; max-height: 400px; overflow-y: auto; }
.event-row {
  display: flex; align-items: center; gap: 10px; padding: 10px 12px;
  border: 1px solid var(--color-border-light); border-radius: var(--radius-sm);
  font-size: 0.85rem;
}
.event-row.overdue { border-left: 3px solid var(--color-danger); background: rgba(231, 111, 81, 0.02); }
.event-row.due { border-left: 3px solid var(--color-primary); background: rgba(139, 126, 200, 0.02); }
.event-row.completed { opacity: 0.6; }

.event-icon { width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; background: var(--color-primary-ultralight); color: var(--color-primary); }
.event-icon.vaccination { background: rgba(124, 184, 212, 0.15); color: var(--color-success); }
.event-icon.analysis { background: rgba(233, 196, 106, 0.15); color: var(--color-warning); }

.event-body { flex: 1; display: flex; flex-direction: column; gap: 2px; }
.event-title { font-weight: 500; }
.event-date { font-size: 0.75rem; color: var(--color-text-muted); }

.event-status-badge { font-size: 0.7rem; font-weight: 600; padding: 3px 8px; border-radius: 4px; flex-shrink: 0; }
.event-status-badge.overdue { background: rgba(231, 111, 81, 0.12); color: var(--color-danger); }
.event-status-badge.due { background: rgba(139, 126, 200, 0.12); color: var(--color-primary); }
.event-status-badge.upcoming { background: rgba(124, 184, 212, 0.12); color: var(--color-info, #7CB8D4); }
.event-status-badge.completed { background: rgba(124, 184, 212, 0.12); color: var(--color-success); }
.event-status-badge.skipped { background: var(--color-primary-ultralight); color: var(--color-text-muted); }

.btn-complete-event { background: none; border: 1px solid var(--color-success, #7CB8D4); color: var(--color-success, #7CB8D4); border-radius: 50%; width: 26px; height: 26px; display: flex; align-items: center; justify-content: center; cursor: pointer; flex-shrink: 0; }

/* Prescriptions */
.rx-list { display: flex; flex-direction: column; gap: 8px; }
.rx-card {
  display: flex; align-items: center; gap: 12px; padding: 12px;
  border: 1px solid var(--color-border-light); border-radius: var(--radius-sm);
}
.rx-info { flex: 1; }
.rx-info h4 { font-size: 0.9rem; font-weight: 600; }
.rx-info p { font-size: 0.8rem; color: var(--color-text-secondary); margin-top: 2px; }
.rx-dates { font-size: 0.75rem; color: var(--color-text-muted); }
.rx-status { font-size: 0.7rem; font-weight: 600; padding: 3px 8px; border-radius: 4px; flex-shrink: 0; }
.rx-status.active { background: rgba(124, 184, 212, 0.12); color: var(--color-success); }

.btn-add {
  display: flex; align-items: center; gap: 4px; padding: 6px 14px;
  background: var(--color-primary-ultralight); color: var(--color-primary);
  border: 1px solid var(--color-primary); border-radius: var(--radius-sm);
  font-size: 0.8rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}

/* Vaccinations */
.vax-list { display: flex; flex-direction: column; gap: 4px; }
.vax-row { display: flex; align-items: center; gap: 10px; padding: 8px 0; font-size: 0.85rem; border-bottom: 1px solid var(--color-border-light); }
.vax-row:last-child { border: none; }
.vax-name { flex: 1; font-weight: 500; }
.vax-dose { font-size: 0.75rem; color: var(--color-text-muted); min-width: 60px; }
.vax-date { font-size: 0.8rem; color: var(--color-text-secondary); min-width: 100px; }
.vax-status-badge { font-size: 0.7rem; font-weight: 600; padding: 2px 8px; border-radius: 4px; }
.vax-status-badge.completed { background: rgba(124, 184, 212, 0.12); color: var(--color-success); }
.vax-status-badge.scheduled { background: var(--color-primary-ultralight); color: var(--color-primary); }
.vax-status-badge.skipped { background: rgba(231, 111, 81, 0.1); color: var(--color-danger); }
.vax-status-badge.postponed { background: rgba(233, 196, 106, 0.15); color: var(--color-warning); }

/* Documents */
.doc-list { display: flex; flex-direction: column; gap: 4px; }
.doc-row { display: flex; align-items: center; gap: 10px; padding: 8px 0; font-size: 0.85rem; border-bottom: 1px solid var(--color-border-light); }
.doc-row:last-child { border: none; }
.doc-icon { color: var(--color-text-muted); flex-shrink: 0; }
.doc-title { flex: 1; font-weight: 500; }
.doc-date { font-size: 0.75rem; color: var(--color-text-muted); }
.doc-download { color: var(--color-text-muted); }

.empty-mini { text-align: center; padding: 16px; color: var(--color-text-muted); font-size: 0.85rem; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: var(--color-surface); border-radius: var(--radius-md); padding: 24px; width: 100%; max-width: 480px; max-height: 90vh; overflow-y: auto; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; margin-bottom: 16px; }
.modal-form { display: flex; flex-direction: column; gap: 14px; }

.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.85rem; font-weight: 600; }
.form-input { padding: 10px 14px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body); outline: none; }
.form-input:focus { border-color: var(--color-primary); }
.form-textarea { resize: vertical; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.form-error-global { text-align: center; font-size: 0.85rem; color: var(--color-danger); padding: 8px; background: rgba(231, 111, 81, 0.08); border-radius: var(--radius-sm); }

.times-row { display: flex; flex-wrap: wrap; gap: 8px; }
.time-check { display: flex; align-items: center; gap: 4px; font-size: 0.85rem; cursor: pointer; }
.time-check input { accent-color: var(--color-primary); }

.modal-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 4px; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body); }
.btn-submit:disabled { opacity: 0.6; }
</style>

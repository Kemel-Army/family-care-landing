<template>
  <div class="cp-page">
    <div class="cp-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Панель</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Маршруты пациентов</h1>
          <p class="hero-sub">{{ journeys.length }} активных маршрутов</p>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по пациенту…" class="search-input" />
    </div>

    <div class="filter-row">
      <button v-for="f in typeFilters" :key="f.value" class="filter-btn" :class="{ active: typeFilter === f.value }" @click="typeFilter = f.value">{{ f.label }}</button>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="cp-list">
      <div v-for="j in filtered" :key="j.id" class="cp-card">
        <div class="cp-card-top">
          <div class="cp-patient">
            <div class="cp-avatar">{{ initials(j.patient_name) }}</div>
            <div>
              <h3 class="cp-name">{{ j.patient_name }}</h3>
              <p class="cp-child" v-if="j.child_name">{{ j.child_name }}</p>
            </div>
          </div>
          <div class="cp-badges">
            <span class="type-badge" :class="j.type">{{ typeLabel(j.type) }}</span>
            <span class="status-badge" :class="j.status">{{ statusLabel(j.status) }}</span>
          </div>
        </div>

        <!-- Progress -->
        <div class="cp-progress">
          <div class="prog-bar"><div class="prog-fill" :style="{ width: `${j.progress}%` }" /></div>
          <span class="prog-text">{{ j.completed_events }}/{{ j.total_events }} событий</span>
        </div>

        <!-- Upcoming events -->
        <div v-if="j.upcoming.length" class="cp-upcoming">
          <div v-for="ev in j.upcoming" :key="ev.id" class="up-event">
            <span class="up-status-dot" :class="ev.status" />
            <span class="up-title">{{ ev.title }}</span>
            <span v-if="ev.due_date" class="up-date">{{ formatDate(ev.due_date) }}</span>
            <span v-if="ev.status === 'overdue'" class="up-overdue">просрочено</span>
          </div>
        </div>
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:route" title="Маршруты не найдены" description="Нет активных маршрутов по текущим фильтрам" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const search = ref('')
const typeFilter = ref('all')
const loading = ref(true)

interface UpcomingEvent { id: string; title: string; status: string; due_date: string | null }
interface Journey { id: string; type: string; status: string; patient_name: string; child_name: string | null; total_events: number; completed_events: number; progress: number; upcoming: UpcomingEvent[] }

const journeys = ref<Journey[]>([])

const typeFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Беременность', value: 'pregnancy' },
  { label: 'Послеродовой', value: 'postpartum' },
  { label: 'Младенец', value: 'infant' },
  { label: 'Тоддлер', value: 'toddler' },
]

const filtered = computed(() => {
  let items = journeys.value
  if (typeFilter.value !== 'all') items = items.filter(j => j.type === typeFilter.value)
  const q = search.value.toLowerCase()
  if (q) items = items.filter(j => j.patient_name.toLowerCase().includes(q))
  return items
})

function initials(name: string) { return name.split(' ').map(w => w[0]).join('').slice(0, 2) }
function typeLabel(s: string) { return { pregnancy: 'Беременность', postpartum: 'Послеродовой', infant: 'Младенец', toddler: 'Тоддлер' }[s] || s }
function statusLabel(s: string) { return { active: 'Активен', paused: 'Пауза', completed: 'Завершён', cancelled: 'Отменён' }[s] || s }
function formatDate(d: string) { return new Date(d).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' }) }

onMounted(async () => {
  const { data: jData } = await sb.from('journeys').select(`
    id, type, status, family_id,
    families!inner(primary_parent_id, users!families_primary_parent_id_fkey(first_name, last_name)),
    child_profiles(name)
  `).in('status', ['active', 'paused']).order('created_at', { ascending: false })

  if (!jData) { loading.value = false; return }
  const ids = jData.map(j => j.id)

  // Events per journey
  const { data: evData } = await sb.from('journey_events').select('id, journey_id, title, status, due_date').in('journey_id', ids).order('due_date')

  const evMap: Record<string, { total: number; completed: number; upcoming: UpcomingEvent[] }> = {}
  evData?.forEach(ev => {
    evMap[ev.journey_id] ??= { total: 0, completed: 0, upcoming: [] }
    evMap[ev.journey_id].total++
    if (ev.status === 'completed') evMap[ev.journey_id].completed++
    if (['upcoming', 'due', 'overdue'].includes(ev.status)) {
      evMap[ev.journey_id].upcoming.push({ id: ev.id, title: ev.title, status: ev.status, due_date: ev.due_date })
    }
  })

  journeys.value = jData.map(j => {
    const fam = j.families as any
    const parent = fam?.users
    const child = Array.isArray(j.child_profiles) ? j.child_profiles[0] : j.child_profiles
    const stats = evMap[j.id] || { total: 0, completed: 0, upcoming: [] }
    return {
      id: j.id,
      type: j.type,
      status: j.status,
      patient_name: `${parent?.last_name || ''} ${parent?.first_name || ''}`.trim() || 'Без имени',
      child_name: (child as any)?.name || null,
      total_events: stats.total,
      completed_events: stats.completed,
      progress: stats.total ? Math.round((stats.completed / stats.total) * 100) : 0,
      upcoming: stats.upcoming.slice(0, 3),
    }
  })
  loading.value = false
})
</script>

<style scoped>
.cp-page { max-width: 780px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }
.cp-hero {
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
.cp-list { display: flex; flex-direction: column; gap: 8px; }
.cp-card {
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px 18px; transition: box-shadow 0.2s;
}
.cp-card:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.cp-card-top { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.cp-patient { display: flex; align-items: center; gap: 10px; }
.cp-avatar {
  width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, rgba(139,126,200,0.15), rgba(232,160,191,0.12));
  font-size: 0.7rem; font-weight: 700; color: var(--color-primary); flex-shrink: 0;
}
.cp-name { font-size: 0.88rem; font-weight: 600; }
.cp-child { font-size: 0.72rem; color: var(--color-text-muted); }
.cp-badges { display: flex; gap: 6px; }
.type-badge, .status-badge { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
.type-badge.pregnancy { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.type-badge.postpartum { background: rgba(232,160,191,0.12); color: #c76b94; }
.type-badge.infant { background: rgba(100,180,120,0.12); color: #4a9960; }
.type-badge.toddler { background: rgba(232,184,77,0.12); color: #b08a2a; }
.status-badge.active { background: rgba(100,180,120,0.1); color: #4a9960; }
.status-badge.paused { background: rgba(232,184,77,0.1); color: #b08a2a; }
.status-badge.completed { background: rgba(150,150,150,0.1); color: #888; }
/* Progress */
.cp-progress { display: flex; align-items: center; gap: 10px; margin-top: 12px; }
.prog-bar { flex: 1; height: 6px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
.prog-fill { height: 100%; background: var(--color-primary); border-radius: 3px; transition: width 0.5s ease; }
.prog-text { font-size: 0.72rem; color: var(--color-text-muted); font-family: var(--font-mono); white-space: nowrap; }
/* Upcoming */
.cp-upcoming { margin-top: 10px; padding-top: 10px; border-top: 1px solid var(--color-border-light); display: flex; flex-direction: column; gap: 4px; }
.up-event { display: flex; align-items: center; gap: 6px; font-size: 0.78rem; }
.up-status-dot { width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0; background: var(--color-border-light); }
.up-status-dot.due { background: var(--color-primary); }
.up-status-dot.overdue { background: #d94f4f; }
.up-status-dot.upcoming { background: #4a9960; }
.up-title { flex: 1; }
.up-date { font-size: 0.68rem; color: var(--color-text-muted); font-family: var(--font-mono); }
.up-overdue { font-size: 0.62rem; font-weight: 600; color: #d94f4f; }
</style>

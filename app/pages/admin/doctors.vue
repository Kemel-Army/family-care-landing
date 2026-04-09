<template>
  <div class="doc-page">
    <div class="doc-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Врачи</h1>
          <p class="hero-sub">{{ doctors.length }} специалистов в клинике</p>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени или специальности…" class="search-input" />
    </div>

    <div class="filter-row">
      <button v-for="f in specFilters" :key="f.value" class="filter-btn" :class="{ active: spec === f.value }" @click="spec = f.value">{{ f.label }}</button>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="doc-list">
      <div v-for="d in filtered" :key="d.id" class="doc-row">
        <div class="doc-avatar">{{ initials(d.name) }}</div>
        <div class="doc-info">
          <h3 class="doc-name">{{ d.name }}</h3>
          <p class="doc-meta">
            <span class="spec-badge" :class="d.specialty">{{ specLabel(d.specialty) }}</span>
            <span v-if="d.experience_years" class="doc-exp">{{ d.experience_years }} лет</span>
          </p>
        </div>
        <div class="doc-stats">
          <div class="stat-item">
            <span class="stat-val">{{ d.appointment_count }}</span>
            <span class="stat-lbl">приёмов</span>
          </div>
          <div class="stat-item">
            <span class="stat-val" :class="d.avg_rating >= 4.5 ? 'good' : d.avg_rating >= 3.5 ? 'warn' : 'low'">{{ d.avg_rating?.toFixed(1) || '—' }}</span>
            <span class="stat-lbl">рейтинг</span>
          </div>
        </div>
        <span class="status-dot" :class="{ active: d.is_active }" />
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:stethoscope" title="Врачи не найдены" description="Попробуйте изменить фильтры" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const search = ref('')
const spec = ref('all')
const loading = ref(true)

interface Doctor {
  id: string
  name: string
  specialty: string
  experience_years: number | null
  is_active: boolean
  appointment_count: number
  avg_rating: number | null
}

const doctors = ref<Doctor[]>([])

const specFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Гинеколог', value: 'gynecologist' },
  { label: 'Педиатр', value: 'pediatrician' },
  { label: 'Неонатолог', value: 'neonatologist' },
  { label: 'УЗИ', value: 'ultrasound' },
]

const filtered = computed(() => {
  let items = doctors.value
  if (spec.value !== 'all') items = items.filter(d => d.specialty === spec.value)
  const q = search.value.toLowerCase()
  if (q) items = items.filter(d => d.name.toLowerCase().includes(q) || specLabel(d.specialty).toLowerCase().includes(q))
  return items
})

function initials(name: string) { return name.split(' ').map(w => w[0]).join('').slice(0, 2) }

function specLabel(s: string) {
  return { gynecologist: 'Гинеколог', pediatrician: 'Педиатр', neonatologist: 'Неонатолог', ultrasound: 'УЗИ', lab: 'Лаборатория' }[s] || s
}

onMounted(async () => {
  const { data } = await sb.from('doctors').select('id, specialty, experience_years, is_active, user_id, users!doctors_user_id_fkey(first_name, last_name)')
  if (!data) { loading.value = false; return }

  const ids = data.map(d => d.id)

  // Count appointments per doctor
  const { data: appts } = await sb.from('appointments').select('doctor_id').in('doctor_id', ids)
  const apptMap: Record<string, number> = {}
  appts?.forEach(a => { apptMap[a.doctor_id] = (apptMap[a.doctor_id] || 0) + 1 })

  // Average ratings
  const { data: ratings } = await sb.from('visit_ratings').select('appointment_id, rating')
  const { data: ratedAppts } = await sb.from('appointments').select('id, doctor_id').in('doctor_id', ids)
  const ratingMap: Record<string, number[]> = {}
  const apptDocMap: Record<string, string> = {}
  ratedAppts?.forEach(a => { apptDocMap[a.id] = a.doctor_id })
  ratings?.forEach(r => {
    const docId = apptDocMap[r.appointment_id]
    if (docId) { (ratingMap[docId] ??= []).push(r.rating) }
  })

  doctors.value = data.map(d => {
    const u = d.users as any
    const rArr = ratingMap[d.id]
    return {
      id: d.id,
      name: `${u?.last_name || ''} ${u?.first_name || ''}`.trim() || 'Без имени',
      specialty: d.specialty,
      experience_years: d.experience_years,
      is_active: d.is_active,
      appointment_count: apptMap[d.id] || 0,
      avg_rating: rArr ? rArr.reduce((a, b) => a + b, 0) / rArr.length : null,
    }
  })
  loading.value = false
})
</script>

<style scoped>
.doc-page { max-width: 780px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }
.doc-hero {
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
.doc-list { display: flex; flex-direction: column; gap: 2px; }
.doc-row {
  display: flex; align-items: center; gap: 14px; padding: 12px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px; transition: box-shadow 0.2s;
}
.doc-row:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.doc-avatar {
  width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, rgba(139,126,200,0.15), rgba(232,160,191,0.12));
  font-size: 0.72rem; font-weight: 700; color: var(--color-primary); flex-shrink: 0;
}
.doc-info { flex: 1; min-width: 0; }
.doc-name { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.doc-meta { display: flex; align-items: center; gap: 6px; margin-top: 2px; }
.doc-exp { font-size: 0.72rem; color: var(--color-text-muted); }
.spec-badge { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
.spec-badge.gynecologist { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.spec-badge.pediatrician { background: rgba(100,180,120,0.12); color: #4a9960; }
.spec-badge.neonatologist { background: rgba(232,160,191,0.12); color: #c76b94; }
.spec-badge.ultrasound { background: rgba(232,184,77,0.12); color: #b08a2a; }
.spec-badge.lab { background: rgba(150,150,150,0.12); color: #888; }
.doc-stats { display: flex; gap: 16px; flex-shrink: 0; }
.stat-item { display: flex; flex-direction: column; align-items: center; }
.stat-val { font-size: 0.88rem; font-weight: 700; font-family: var(--font-mono); }
.stat-val.good { color: #4a9960; }
.stat-val.warn { color: #b08a2a; }
.stat-val.low { color: #d94f4f; }
.stat-lbl { font-size: 0.62rem; color: var(--color-text-muted); }
.status-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; background: var(--color-border-light); }
.status-dot.active { background: #4a9960; }
</style>

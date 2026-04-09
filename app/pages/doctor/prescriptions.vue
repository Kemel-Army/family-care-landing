<template>
  <div class="rx-page">
    <div class="rx-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Панель</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Назначения</h1>
          <p class="hero-sub">{{ prescriptions.length }} назначений</p>
        </div>
        <div class="hero-stat">
          <span class="stat-num">{{ activeCount }}</span>
          <span class="stat-label">активных</span>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по препарату или пациенту…" class="search-input" />
    </div>

    <div class="filter-row">
      <button class="filter-btn" :class="{ active: showActive === 'all' }" @click="showActive = 'all'">Все</button>
      <button class="filter-btn" :class="{ active: showActive === 'active' }" @click="showActive = 'active'">Активные</button>
      <button class="filter-btn" :class="{ active: showActive === 'ended' }" @click="showActive = 'ended'">Завершённые</button>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="rx-list">
      <div v-for="rx in filtered" :key="rx.id" class="rx-card" :class="{ inactive: !rx.is_active }">
        <div class="rx-card-top">
          <div class="rx-drug">
            <Icon name="lucide:pill" size="16" class="rx-icon" />
            <div>
              <h3 class="rx-med">{{ rx.medication }}</h3>
              <p class="rx-dosage">{{ rx.dosage }} · {{ rx.frequency }}</p>
            </div>
          </div>
          <span class="rx-status" :class="{ active: rx.is_active }">{{ rx.is_active ? 'Активен' : 'Завершён' }}</span>
        </div>

        <div class="rx-patient">
          <span class="rx-patient-name"><Icon name="lucide:user" size="12" /> {{ rx.patient_name }}</span>
          <span v-if="rx.child_name" class="rx-child"><Icon name="lucide:baby" size="12" /> {{ rx.child_name }}</span>
        </div>

        <div class="rx-meta">
          <span class="rx-chip"><Icon name="lucide:calendar" size="11" /> {{ formatDate(rx.start_date) }} — {{ rx.end_date ? formatDate(rx.end_date) : '∞' }}</span>
          <span v-if="rx.time_of_day?.length" class="rx-chip"><Icon name="lucide:clock" size="11" /> {{ rx.time_of_day.join(', ') }}</span>
        </div>

        <p v-if="rx.instructions" class="rx-instructions">{{ rx.instructions }}</p>

        <!-- Adherence bar -->
        <div v-if="rx.adherence != null" class="rx-adh">
          <div class="adh-bar"><div class="adh-fill" :style="{ width: `${rx.adherence}%` }" :class="adhClass(rx.adherence)" /></div>
          <span class="adh-val" :class="adhClass(rx.adherence)">{{ rx.adherence }}%</span>
        </div>
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:pill" title="Назначения не найдены" description="Нет назначений по текущим фильтрам" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const search = ref('')
const showActive = ref('all')
const loading = ref(true)

interface Rx {
  id: string; medication: string; dosage: string; frequency: string; time_of_day: string[]
  start_date: string; end_date: string | null; instructions: string | null
  is_active: boolean; patient_name: string; child_name: string | null; adherence: number | null
}

const prescriptions = ref<Rx[]>([])
const activeCount = computed(() => prescriptions.value.filter(r => r.is_active).length)

const filtered = computed(() => {
  let items = prescriptions.value
  if (showActive.value === 'active') items = items.filter(r => r.is_active)
  else if (showActive.value === 'ended') items = items.filter(r => !r.is_active)
  const q = search.value.toLowerCase()
  if (q) items = items.filter(r => r.medication.toLowerCase().includes(q) || r.patient_name.toLowerCase().includes(q))
  return items
})

function formatDate(d: string) { return new Date(d).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' }) }
function adhClass(v: number) { return v >= 80 ? 'good' : v >= 50 ? 'warn' : 'low' }

onMounted(async () => {
  const { data } = await sb.from('prescriptions').select(`
    id, medication, dosage, frequency, time_of_day, start_date, end_date, instructions, is_active, family_id, child_id,
    families!inner(primary_parent_id, users!families_primary_parent_id_fkey(first_name, last_name)),
    child_profiles(name)
  `).order('created_at', { ascending: false })

  if (!data) { loading.value = false; return }

  // Adherence last 30 days per prescription
  const ids = data.map(r => r.id)
  const since = new Date(Date.now() - 30 * 86_400_000).toISOString()
  const { data: logs } = await sb.from('dose_logs').select('prescription_id, status').in('prescription_id', ids).gte('scheduled_at', since)
  const adhMap: Record<string, { total: number; confirmed: number }> = {}
  logs?.forEach(l => {
    adhMap[l.prescription_id] ??= { total: 0, confirmed: 0 }
    adhMap[l.prescription_id].total++
    if (l.status === 'confirmed') adhMap[l.prescription_id].confirmed++
  })

  prescriptions.value = data.map(r => {
    const fam = r.families as any
    const parent = fam?.users
    const child = Array.isArray(r.child_profiles) ? r.child_profiles[0] : r.child_profiles
    const adh = adhMap[r.id]
    return {
      id: r.id,
      medication: r.medication,
      dosage: r.dosage,
      frequency: r.frequency,
      time_of_day: r.time_of_day || [],
      start_date: r.start_date,
      end_date: r.end_date,
      instructions: r.instructions,
      is_active: r.is_active,
      patient_name: `${parent?.last_name || ''} ${parent?.first_name || ''}`.trim() || 'Без имени',
      child_name: (child as any)?.name || null,
      adherence: adh ? Math.round((adh.confirmed / adh.total) * 100) : null,
    }
  })
  loading.value = false
})
</script>

<style scoped>
.rx-page { max-width: 700px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }
.rx-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.hero-stat { text-align: center; }
.stat-num { display: block; font-size: 1.5rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); }
.stat-label { font-size: 0.68rem; color: var(--color-text-muted); }
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
.rx-list { display: flex; flex-direction: column; gap: 8px; }
.rx-card {
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px 18px; transition: box-shadow 0.2s;
}
.rx-card:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.rx-card.inactive { opacity: 0.6; }
.rx-card-top { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.rx-drug { display: flex; align-items: center; gap: 10px; }
.rx-icon { color: var(--color-primary); flex-shrink: 0; }
.rx-med { font-size: 0.92rem; font-weight: 600; }
.rx-dosage { font-size: 0.75rem; color: var(--color-text-muted); margin-top: 1px; }
.rx-status { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; background: rgba(150,150,150,0.1); color: #888; }
.rx-status.active { background: rgba(100,180,120,0.12); color: #4a9960; }
.rx-patient { display: flex; gap: 12px; margin-top: 10px; }
.rx-patient-name, .rx-child { display: flex; align-items: center; gap: 3px; font-size: 0.78rem; color: var(--color-text-muted); }
.rx-meta { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 8px; }
.rx-chip {
  display: inline-flex; align-items: center; gap: 3px; padding: 2px 8px; border-radius: 8px;
  font-size: 0.68rem; font-weight: 500; background: rgba(139,126,200,0.06); color: var(--color-text-muted);
}
.rx-instructions { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 8px; font-style: italic; }
.rx-adh { display: flex; align-items: center; gap: 8px; margin-top: 10px; }
.adh-bar { flex: 1; height: 6px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
.adh-fill { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
.adh-fill.good { background: #4a9960; }
.adh-fill.warn { background: #e8b84d; }
.adh-fill.low { background: #d94f4f; }
.adh-val { font-size: 0.72rem; font-weight: 600; font-family: var(--font-mono); width: 32px; text-align: right; }
.adh-val.good { color: #4a9960; }
.adh-val.warn { color: #b08a2a; }
.adh-val.low { color: #d94f4f; }
</style>

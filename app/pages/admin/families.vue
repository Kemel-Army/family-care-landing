<template>
  <div class="fam-page">
    <div class="fam-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Все семьи</h1>
          <p class="hero-sub">{{ total }} семей в системе</p>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени…" class="search-input" />
    </div>

    <div class="filter-row">
      <button
        v-for="f in stageFilters"
        :key="f.value"
        class="filter-btn"
        :class="{ active: stage === f.value }"
        @click="stage = f.value"
      >
        {{ f.label }}
      </button>
    </div>

    <div v-if="pending" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="fam-list">
      <div v-for="f in filtered" :key="f.id" class="fam-row">
        <div class="fam-avatar">{{ initials(f.mother_name) }}</div>
        <div class="fam-info">
          <h3 class="fam-name">{{ f.mother_name }}</h3>
          <p class="fam-meta">
            <span class="stage-badge" :class="f.stage">{{ stageLabel(f.stage) }}</span>
            <span v-if="f.week" class="fam-week">{{ f.week }} нед</span>
            <span v-if="f.month_age" class="fam-week">{{ f.month_age }} мес</span>
          </p>
        </div>
        <div class="fam-adherence">
          <div class="adh-bar">
            <div class="adh-fill" :style="{ width: `${f.adherence ?? 0}%` }" :class="adhClass(f.adherence)" />
          </div>
          <span class="adh-val" :class="adhClass(f.adherence)">{{ f.adherence ?? '—' }}%</span>
        </div>
        <span class="status-dot" :class="f.status" />
      </div>
    </div>

    <AppSharedEmptyState
      v-else
      icon="lucide:users"
      title="Семьи не найдены"
      description="Попробуйте изменить фильтры или запустите seed для создания тестовых данных"
    />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const search = ref('')
const stage = ref('all')

const stageFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Беременность', value: 'pregnancy' },
  { label: 'Послеродовой', value: 'postpartum' },
  { label: 'Младенец', value: 'infant' },
  { label: 'Тоддлер', value: 'toddler' },
]

interface Family {
  id: string
  mother_name: string
  stage: string
  week: number | null
  month_age: number | null
  adherence: number | null
  status: string
}

const { data, pending } = await useFetch<{ families: Family[]; total: number }>('/api/families')
const total = computed(() => data.value?.total ?? 0)

const filtered = computed(() => {
  let items = data.value?.families ?? []
  if (stage.value !== 'all') items = items.filter(f => f.stage === stage.value)
  const q = search.value.toLowerCase()
  if (q) items = items.filter(f => f.mother_name.toLowerCase().includes(q))
  return items
})

function initials(name: string) {
  return name.split(' ').map(w => w[0]).join('').slice(0, 2)
}

function stageLabel(s: string) {
  return { pregnancy: 'Беременность', postpartum: 'Послерод.', infant: 'Младенец', toddler: 'Тоддлер' }[s] || s
}

function adhClass(v: number | null) {
  if (v == null) return 'neutral'
  if (v >= 80) return 'good'
  if (v >= 50) return 'warn'
  return 'low'
}
</script>

<style scoped>
.fam-page { max-width: 780px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }

.fam-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

/* Search */
.search-box { position: relative; }
.search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--color-text-muted); }
.search-input {
  width: 100%; padding: 10px 12px 10px 38px; border: 1px solid var(--color-border-light); border-radius: 12px;
  font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.2s;
}
.search-input:focus { border-color: var(--color-primary); }

/* Filters */
.filter-row { display: flex; gap: 6px; flex-wrap: wrap; }
.filter-btn {
  padding: 6px 14px; border: 1px solid var(--color-border-light); border-radius: 20px;
  font-size: 0.78rem; font-weight: 500; background: white; cursor: pointer; transition: all 0.2s;
  font-family: var(--font-body); color: var(--color-text-muted);
}
.filter-btn.active { background: var(--color-primary); color: white; border-color: var(--color-primary); }

/* Loading */
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 40px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

/* List */
.fam-list { display: flex; flex-direction: column; gap: 2px; }
.fam-row {
  display: flex; align-items: center; gap: 14px; padding: 12px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px;
  transition: box-shadow 0.2s;
}
.fam-row:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }

.fam-avatar {
  width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, rgba(139,126,200,0.15), rgba(232,160,191,0.12));
  font-size: 0.72rem; font-weight: 700; color: var(--color-primary); flex-shrink: 0;
}

.fam-info { flex: 1; min-width: 0; }
.fam-name { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.fam-meta { display: flex; align-items: center; gap: 6px; margin-top: 2px; }
.fam-week { font-size: 0.72rem; color: var(--color-text-muted); }

.stage-badge {
  font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px;
}
.stage-badge.pregnancy { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.stage-badge.postpartum { background: rgba(232,160,191,0.12); color: #c76b94; }
.stage-badge.infant { background: rgba(100,180,120,0.12); color: #4a9960; }
.stage-badge.toddler { background: rgba(232,184,77,0.12); color: #b08a2a; }

/* Adherence */
.fam-adherence { display: flex; align-items: center; gap: 8px; width: 120px; flex-shrink: 0; }
.adh-bar { height: 6px; flex: 1; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
.adh-fill { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
.adh-fill.good { background: #4a9960; }
.adh-fill.warn { background: #e8b84d; }
.adh-fill.low { background: #d94f4f; }
.adh-fill.neutral { background: var(--color-border-light); }
.adh-val { font-size: 0.72rem; font-weight: 600; font-family: var(--font-mono); width: 32px; text-align: right; }
.adh-val.good { color: #4a9960; }
.adh-val.warn { color: #b08a2a; }
.adh-val.low { color: #d94f4f; }
.adh-val.neutral { color: var(--color-text-muted); }

.status-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; background: var(--color-border-light); }
.status-dot.active { background: #4a9960; }
.status-dot.new { background: var(--color-primary); }
</style>

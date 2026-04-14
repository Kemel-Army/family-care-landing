<template>
  <div class="fam-page">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <div class="skel skel-hero" />
      <div class="skel skel-search" />
      <div v-for="i in 5" :key="i" class="skel skel-row" />
    </template>

    <template v-else>
    <!-- Hero -->
    <div class="fam-hero">
      <NuxtLink to="/coordinator" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="fam-hero-title">Семьи</h1>
      <p class="fam-hero-sub">{{ families.length }} семей под наблюдением</p>
    </div>

    <!-- Search -->
    <div class="search-wrap">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени..." class="search-input" />
    </div>

    <!-- Filter Chips -->
    <div class="filter-chips">
      <button v-for="chip in filterChips" :key="chip.value" class="chip" :class="{ active: filterBy === chip.value }" @click="filterBy = chip.value">
        {{ chip.label }}
        <span v-if="chip.count !== undefined" class="chip-count">{{ chip.count }}</span>
      </button>
    </div>

    <!-- Family list -->
    <div v-if="filtered.length" class="fam-list">
      <NuxtLink v-for="f in filtered" :key="f.id" :to="`/coordinator/families/${f.id}`" class="fam-card">
        <div class="fam-avatar" :class="f.journey_type">
          <Icon name="lucide:users" size="18" />
        </div>
        <div class="fam-info">
          <span class="fam-name">{{ f.mother_name }}</span>
          <span class="fam-meta">
            <span class="journey-tag" :class="f.journey_type">{{ journeyLabel(f.journey_type) }}</span>
            <span v-if="f.week_or_age">{{ f.week_or_age }}</span>
            <span v-if="f.children_count">{{ f.children_count }} дет.</span>
          </span>
          <div class="adherence-bar-row">
            <div class="adherence-bar">
              <div class="adherence-bar-fill" :class="adherenceClass(f.adherence)" :style="{ width: `${f.adherence}%` }" />
            </div>
            <span class="adherence-pct" :class="adherenceClass(f.adherence)">{{ f.adherence }}%</span>
          </div>
        </div>
        <div class="fam-right">
          <span v-if="f.overdue_count" class="overdue-badge">{{ f.overdue_count }}</span>
          <span v-if="f.last_activity" class="fam-activity">{{ f.last_activity }}</span>
        </div>
      </NuxtLink>
    </div>
    <AppSharedEmptyState v-else icon="lucide:search-x" title="Нет семей по запросу" />
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const coordStore = useCoordinatorStore()
const authStore = useAuthStore()
const appData = useAppData()

const search = ref('')
const filterBy = ref('all')
const loading = ref(true)

const filterChips = computed(() => [
  { value: 'all', label: 'Все', count: families.value.length },
  { value: 'overdue', label: '⚠️ Просрочено', count: families.value.filter((f: any) => f.overdue_count > 0).length },
  { value: 'low', label: '📉 Низкий adherence', count: families.value.filter((f: any) => f.adherence < 70).length },
  { value: 'pregnancy', label: 'Беременность' },
  { value: 'infant', label: 'Младенец' },
  { value: 'toddler', label: 'Тоддлер' },
])

const filtered = computed(() => {
  let list = families.value
  const q = search.value.toLowerCase()
  if (q) list = list.filter((f: any) => (f.mother_name || '').toLowerCase().includes(q) || (f.phone || f.mother_phone || '').includes(q))
  if (filterBy.value === 'overdue') list = list.filter((f: any) => f.overdue_count > 0)
  else if (filterBy.value === 'low') list = list.filter((f: any) => f.adherence < 70)
  else if (filterBy.value !== 'all') list = list.filter((f: any) => f.journey_type === filterBy.value)
  return list
})

function adherenceClass(a: number) {
  if (a >= 85) return 'good'
  if (a >= 60) return 'medium'
  return 'low'
}

onMounted(async () => {
  try {
    const clinicId = authStore.clinicId
    if (clinicId) await coordStore.fetchFamilies(clinicId)
  } finally {
    loading.value = false
  }
})

const hasReal = computed(() => coordStore.families.length > 0)
const families = computed((): any[] => {
  if (hasReal.value) return coordStore.families as any[]
  return appData.families as any[]
})

function journeyLabel(type: string) {
  const map: Record<string, string> = { pregnancy: 'Берем.', postpartum: 'Послерод.', infant: 'Младенец', toddler: 'Тоддлер' }
  return map[type] || type
}
</script>

<style scoped>
.fam-page { max-width: 760px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.fam-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.05));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.fam-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.fam-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.search-wrap {
  display: flex; align-items: center; gap: 10px; padding: 10px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px;
}
.search-icon { color: var(--color-text-muted); flex-shrink: 0; }
.search-input { border: none; outline: none; font-size: 0.85rem; font-family: var(--font-body); background: transparent; flex: 1; }

.fam-list { display: flex; flex-direction: column; gap: 6px; }
.fam-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 18px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px;
  transition: all 0.2s; cursor: pointer;
}
.fam-card:hover { border-color: rgba(139,126,200,0.2); transform: translateY(-1px); }

.fam-avatar { width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; background: rgba(139,126,200,0.08); color: var(--color-primary); }
.fam-avatar.pregnancy { background: rgba(232,160,191,0.1); color: var(--color-accent-rose); }
.fam-avatar.infant { background: rgba(168,200,232,0.12); color: var(--color-accent-sky); }
.fam-avatar.toddler { background: rgba(233,196,106,0.1); color: var(--color-warning); }

.fam-info { flex: 1; min-width: 0; }
.fam-name { font-size: 0.85rem; font-weight: 600; display: block; }
.fam-meta { font-size: 0.7rem; color: var(--color-text-muted); display: flex; align-items: center; gap: 6px; margin-top: 2px; flex-wrap: wrap; }

.adherence-bar-row { display: flex; align-items: center; gap: 8px; margin-top: 6px; }
.adherence-bar { flex: 1; height: 4px; border-radius: 4px; background: rgba(139,126,200,0.08); overflow: hidden; max-width: 100px; }
.adherence-bar-fill { height: 100%; border-radius: 4px; transition: width 0.4s; }
.adherence-bar-fill.good { background: var(--color-success); }
.adherence-bar-fill.medium { background: var(--color-warning); }
.adherence-bar-fill.low { background: var(--color-danger); }
.adherence-pct { font-size: 0.65rem; font-weight: 700; font-family: var(--font-mono); }
.adherence-pct.good { color: var(--color-success); }
.adherence-pct.medium { color: var(--color-warning); }
.adherence-pct.low { color: var(--color-danger); }

.filter-chips { display: flex; gap: 8px; flex-wrap: wrap; }
.chip { padding: 6px 14px; border-radius: 20px; font-size: 0.75rem; font-weight: 500; background: white; border: 1px solid var(--color-border-light); cursor: pointer; display: flex; align-items: center; gap: 6px; transition: all 0.15s; }
.chip:hover { border-color: rgba(139,126,200,0.3); }
.chip.active { background: rgba(139,126,200,0.1); border-color: rgba(139,126,200,0.3); color: var(--color-primary); font-weight: 700; }
.chip-count { background: rgba(139,126,200,0.1); color: var(--color-primary); font-size: 0.65rem; font-weight: 700; padding: 1px 6px; border-radius: 10px; }
.chip.active .chip-count { background: rgba(139,126,200,0.2); }
.journey-tag { font-size: 0.6rem; font-weight: 600; padding: 1px 6px; border-radius: 4px; }
.journey-tag.pregnancy { background: rgba(232,160,191,0.1); color: var(--color-accent-rose); }
.journey-tag.postpartum { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.journey-tag.infant { background: rgba(168,200,232,0.1); color: var(--color-accent-sky); }
.journey-tag.toddler { background: rgba(233,196,106,0.1); color: var(--color-warning); }

.fam-right { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
.adherence-mini { position: relative; width: 38px; height: 38px; }
.adherence-ring { width: 100%; height: 100%; transform: rotate(-90deg); }
.adherence-val { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); font-size: 0.55rem; font-weight: 700; font-family: var(--font-mono); }
.overdue-badge { font-size: 0.6rem; font-weight: 700; padding: 2px 6px; border-radius: 50%; background: rgba(212,114,124,0.12); color: var(--color-danger); min-width: 20px; text-align: center; }
.fam-activity { font-size: 0.6rem; color: var(--color-text-muted); white-space: nowrap; }

.empty-card { text-align: center; padding: 48px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; }
.empty-text { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 8px; }

/* Skeleton */
.skel { background: linear-gradient(90deg, rgba(139,126,200,0.06) 0%, rgba(139,126,200,0.12) 50%, rgba(139,126,200,0.06) 100%); background-size: 200% 100%; animation: shimmer 1.4s ease infinite; border-radius: 14px; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.skel-hero { height: 90px; border-radius: 16px; }
.skel-search { height: 44px; border-radius: 12px; }
.skel-row { height: 68px; }
</style>

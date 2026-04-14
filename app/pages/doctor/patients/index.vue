<template>
  <div class="pts-page">
    <!-- Hero -->
    <div class="pts-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="pts-hero-title">Пациенты</h1>
      <p class="pts-hero-sub">{{ appData.doctorPatients.length }} пациентов под наблюдением</p>
    </div>

    <!-- Search -->
    <div class="search-wrap">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени..." class="search-input" />
    </div>

    <!-- Patient list -->
    <div v-if="filtered.length" class="pt-list">
      <div v-for="p in filtered" :key="p.id" class="pt-card">
        <div class="pt-avatar" :class="healthStatus(p)">
          <Icon name="lucide:user" size="18" />
          <span class="health-dot" :class="healthStatus(p)" />
        </div>
        <div class="pt-info">
          <span class="pt-name">{{ p.mother_name }}</span>
          <span class="pt-journey">{{ p.journey_type }}</span>
          <div class="pt-dates">
            <span v-if="p.last_visit" class="pt-date-chip">
              <Icon name="lucide:clock" size="10" /> {{ formatDate(p.last_visit) }}
            </span>
            <span v-if="p.next_visit" class="pt-date-chip" :class="isOverdue(p.next_visit) ? 'chip--danger' : 'chip--upcoming'">
              <Icon name="lucide:calendar" size="10" /> {{ formatDate(p.next_visit) }}
              <span v-if="isOverdue(p.next_visit)"> ⟵ просрочено</span>
            </span>
          </div>
        </div>
        <div class="pt-right">
          <div v-if="p.children.length" class="pt-children">
            <span v-for="c in p.children" :key="c.name" class="child-tag">{{ c.name }}, {{ c.age }}</span>
          </div>
          <Icon name="lucide:chevron-right" size="14" class="pt-arrow" />
        </div>
      </div>
    </div>
    <AppSharedEmptyState v-else icon="lucide:search-x" title="Нет пациентов по запросу" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const appData = useAppData()
const search = ref('')

const filtered = computed(() => {
  const q = search.value.toLowerCase()
  if (!q) return appData.doctorPatients
  return appData.doctorPatients.filter(p => p.mother_name.toLowerCase().includes(q))
})

function formatDate(iso: string) {
  if (!iso) return ''
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

function isOverdue(iso: string) {
  return new Date(iso) < new Date()
}

function healthStatus(p: any) {
  if (p.next_visit && isOverdue(p.next_visit)) return 'danger'
  if (p.last_visit) {
    const daysSince = (Date.now() - new Date(p.last_visit).getTime()) / 86400000
    if (daysSince > 30) return 'warning'
  }
  return 'success'
}
</script>

<style scoped>
.pts-page { max-width: 760px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.pts-hero {
  background: linear-gradient(135deg, rgba(232,160,191,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(232,160,191,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.pts-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.pts-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.search-wrap {
  display: flex; align-items: center; gap: 10px; padding: 10px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px;
}
.search-icon { color: var(--color-text-muted); flex-shrink: 0; }
.search-input { border: none; outline: none; font-size: 0.85rem; font-family: var(--font-body); background: transparent; flex: 1; }

.pt-list { display: flex; flex-direction: column; gap: 6px; }
.pt-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 18px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px;
  transition: all 0.2s; cursor: pointer;
}
.pt-card:hover { border-color: rgba(139,126,200,0.2); transform: translateY(-1px); }

.pt-avatar { width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; background: rgba(232,160,191,0.1); color: var(--color-accent-rose); position: relative; }
.pt-avatar.danger { background: rgba(212,114,124,0.1); color: var(--color-danger); }
.pt-avatar.warning { background: rgba(233,196,106,0.1); color: var(--color-warning); }
.pt-avatar.success { background: rgba(124,184,212,0.1); color: var(--color-success); }
.health-dot { position: absolute; bottom: 0; right: 0; width: 10px; height: 10px; border-radius: 50%; border: 2px solid white; }
.health-dot.danger { background: var(--color-danger); }
.health-dot.warning { background: var(--color-warning); }
.health-dot.success { background: var(--color-success); }

.pt-info { flex: 1; min-width: 0; }
.pt-name { font-size: 0.85rem; font-weight: 600; display: block; }
.pt-journey { font-size: 0.72rem; color: var(--color-primary); font-weight: 500; }
.pt-dates { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 4px; }
.pt-date-chip { font-size: 0.62rem; padding: 2px 8px; border-radius: 8px; background: rgba(139,126,200,0.06); color: var(--color-text-muted); display: flex; align-items: center; gap: 4px; }
.pt-date-chip.chip--danger { background: rgba(212,114,124,0.08); color: var(--color-danger); }
.pt-date-chip.chip--upcoming { background: rgba(124,184,212,0.08); color: var(--color-success); }

.pt-right { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.pt-children { display: flex; gap: 4px; flex-wrap: wrap; }
.child-tag { font-size: 0.6rem; padding: 2px 8px; border-radius: 8px; background: rgba(168,200,232,0.1); color: var(--color-accent-sky); font-weight: 500; }
.pt-arrow { color: var(--color-text-muted); flex-shrink: 0; }

.empty-card { text-align: center; padding: 48px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; }
.empty-text { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 8px; }
</style>

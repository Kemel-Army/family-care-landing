<template>
  <div class="fam-page">
    <!-- Hero -->
    <div class="fam-hero">
      <NuxtLink to="/coordinator" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="fam-hero-title">Семьи</h1>
      <p class="fam-hero-sub">{{ mock.families.length }} семей под наблюдением</p>
    </div>

    <!-- Search -->
    <div class="search-wrap">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени..." class="search-input" />
    </div>

    <!-- Family list -->
    <div v-if="filtered.length" class="fam-list">
      <div v-for="f in filtered" :key="f.id" class="fam-card">
        <div class="fam-avatar" :class="f.journey_type">
          <Icon name="lucide:users" size="18" />
        </div>
        <div class="fam-info">
          <span class="fam-name">{{ f.mother_name }}</span>
          <span class="fam-meta">
            <span class="journey-tag" :class="f.journey_type">{{ journeyLabel(f.journey_type) }}</span>
            {{ f.week_or_age }}
          </span>
        </div>
        <div class="fam-right">
          <div class="adherence-mini">
            <svg viewBox="0 0 36 36" class="adherence-ring">
              <circle cx="18" cy="18" r="15.9" fill="none" stroke="var(--color-border-light)" stroke-width="3" />
              <circle cx="18" cy="18" r="15.9" fill="none" :stroke="adherenceColor(f.adherence)" stroke-width="3"
                stroke-linecap="round" :stroke-dasharray="`${f.adherence} ${100 - f.adherence}`" stroke-dashoffset="25" />
            </svg>
            <span class="adherence-val">{{ f.adherence }}%</span>
          </div>
          <span v-if="f.overdue_count" class="overdue-badge">{{ f.overdue_count }}</span>
          <span class="fam-activity">{{ f.last_activity }}</span>
        </div>
      </div>
    </div>
    <div v-else class="empty-card">
      <Icon name="lucide:search-x" size="32" style="opacity:0.3; color:var(--color-primary)" />
      <p class="empty-text">Нет семей по запросу</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const search = ref('')

const filtered = computed(() => {
  const q = search.value.toLowerCase()
  if (!q) return mock.families
  return mock.families.filter(f => f.mother_name.toLowerCase().includes(q) || f.phone.includes(q))
})

function journeyLabel(type: string) {
  const map: Record<string, string> = { pregnancy: 'Берем.', postpartum: 'Послерод.', infant: 'Младенец', toddler: 'Тоддлер' }
  return map[type] || type
}

function adherenceColor(v: number) {
  if (v >= 85) return 'var(--color-success)'
  if (v >= 65) return 'var(--color-warning)'
  return 'var(--color-danger)'
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
.fam-meta { font-size: 0.7rem; color: var(--color-text-muted); display: flex; align-items: center; gap: 6px; margin-top: 2px; }
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
</style>

<template>
  <div class="families-page">
    <header class="page-header">
      <NuxtLink to="/coordinator" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Назад
      </NuxtLink>
      <h1 class="page-title">Семьи</h1>
      <div class="search-box">
        <Icon name="lucide:search" size="16" class="search-icon" />
        <input v-model="search" type="text" placeholder="Поиск по имени..." class="search-input" />
      </div>
    </header>

    <!-- Family list -->
    <div v-if="filteredFamilies.length" class="family-list">
      <NuxtLink
        v-for="family in filteredFamilies"
        :key="family.id"
        :to="`/coordinator/families/${family.id}`"
        class="family-card"
      >
        <div class="family-avatar">
          <Icon name="lucide:users" size="20" />
        </div>
        <div class="family-details">
          <h3>{{ familyName(family) }}</h3>
          <p>
            <span v-if="family.journey_type" class="tag">{{ journeyLabel(family.journey_type) }}</span>
            <span v-if="family.children_count" class="meta">{{ family.children_count }} {{ childrenWord(family.children_count) }}</span>
          </p>
        </div>
        <div class="family-indicators">
          <span v-if="family.overdue_count" class="badge danger">{{ family.overdue_count }}</span>
          <Icon name="lucide:chevron-right" size="16" class="arrow" />
        </div>
      </NuxtLink>
    </div>

    <div v-else class="empty-state">
      <p>Нет семей</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const authStore = useAuthStore()
const coordinatorStore = useCoordinatorStore()
const search = ref('')

const filteredFamilies = computed(() => {
  const q = search.value.toLowerCase()
  if (!q) return coordinatorStore.families
  return coordinatorStore.families.filter(f =>
    (f.mother_name as string || '').toLowerCase().includes(q)
    || (f.mother_phone as string || '').toLowerCase().includes(q),
  )
})

function familyName(f: Record<string, unknown>) {
  return (f.mother_name as string) || `Семья #${(f.id as string)?.slice(0, 6)}`
}

function journeyLabel(type: string) {
  const map: Record<string, string> = {
    pregnancy: 'Беременность',
    postpartum: 'Послеродовой',
    infant: 'Младенец',
    toddler: 'Малыш',
  }
  return map[type] || type
}

function childrenWord(count: number) {
  if (count === 1) return 'ребёнок'
  if (count >= 2 && count <= 4) return 'ребёнка'
  return 'детей'
}

onMounted(async () => {
  if (authStore.clinicId) {
    await coordinatorStore.fetchFamilies(authStore.clinicId)
  }
})
</script>

<style scoped>
.families-page { max-width: 800px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; flex-wrap: wrap; align-items: center; gap: 12px; margin-bottom: 20px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; flex: 1; }

.search-box {
  display: flex; align-items: center; gap: 8px; padding: 8px 14px;
  border: 1px solid var(--color-border); border-radius: var(--radius-sm);
  background: var(--color-surface); width: 100%; max-width: 280px;
}
.search-input {
  border: none; outline: none; font-size: 0.85rem; font-family: var(--font-body);
  background: transparent; flex: 1;
}
.search-icon { color: var(--color-text-muted); }

.family-list { display: flex; flex-direction: column; gap: 8px; }
.family-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); text-decoration: none; color: inherit;
  transition: all var(--transition-fast);
}
.family-card:hover { box-shadow: var(--shadow-sm); }

.family-avatar {
  width: 44px; height: 44px; border-radius: 50%; background: var(--color-primary-ultralight);
  color: var(--color-primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}

.family-details { flex: 1; }
.family-details h3 { font-size: 0.9rem; font-weight: 600; }
.family-details p { display: flex; align-items: center; gap: 8px; margin-top: 4px; }

.tag {
  font-size: 0.7rem; font-weight: 600; padding: 2px 8px; border-radius: 4px;
  background: var(--color-primary-ultralight); color: var(--color-primary);
}

.meta { font-size: 0.8rem; color: var(--color-text-secondary); }

.family-indicators { display: flex; align-items: center; gap: 8px; }
.badge {
  font-size: 0.7rem; font-weight: 700; padding: 2px 7px; border-radius: 50%; min-width: 22px;
  text-align: center; line-height: 18px;
}
.badge.danger { background: rgba(231, 111, 81, 0.15); color: var(--color-danger); }
.arrow { color: var(--color-text-muted); }

.empty-state { text-align: center; padding: 48px; color: var(--color-text-muted); }
</style>

<template>
  <div class="edu-page">
    <!-- Hero -->
    <div class="edu-hero">
      <div>
        <h1 class="edu-hero-title">Библиотека знаний</h1>
        <p class="edu-hero-sub">{{ filtered.length }} материалов для вас</p>
      </div>
      <Icon name="lucide:book-open" size="28" style="color: var(--color-primary); opacity: 0.5;" />
    </div>

    <!-- Category tabs -->
    <div class="cat-scroll">
      <button
        v-for="cat in categories"
        :key="cat.value"
        class="cat-chip"
        :class="{ 'cat-chip--active': activeCat === cat.value }"
        @click="activeCat = cat.value"
      >{{ cat.label }}</button>
    </div>

    <!-- Articles grid -->
    <div v-if="filtered.length" class="article-grid">
      <div v-for="a in filtered" :key="a.id" class="article-card">
        <div class="article-type-icon" :class="a.category">
          <Icon :name="catIcon(a.category)" size="20" />
        </div>
        <div class="article-body">
          <h3 class="article-title">{{ a.title }}</h3>
          <div class="article-meta">
            <span class="meta-cat">{{ catLabel(a.category) }}</span>
            <span class="meta-dot">·</span>
            <span>{{ a.readTime }} мин</span>
            <template v-if="a.week">
              <span class="meta-dot">·</span>
              <span>Неделя {{ a.week }}</span>
            </template>
          </div>
        </div>
        <Icon name="lucide:chevron-right" size="16" class="article-arrow" />
      </div>
    </div>

    <!-- Empty state -->
    <AppSharedEmptyState v-else icon="lucide:search-x" title="Нет материалов в этой категории" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const appData = useAppData()
const activeCat = ref('all')

const categories = [
  { label: 'Все', value: 'all' },
  { label: 'Беременность', value: 'pregnancy' },
  { label: 'Роды', value: 'birth' },
  { label: 'Грудное вскармливание', value: 'breastfeeding' },
  { label: 'Уход', value: 'childcare' },
  { label: 'Психология', value: 'psychology' },
  { label: 'Питание', value: 'nutrition' },
]

const filtered = computed(() => {
  if (activeCat.value === 'all') return appData.educationArticles
  return appData.educationArticles.filter(a => a.category === activeCat.value)
})

function catIcon(cat: string) {
  const map: Record<string, string> = {
    pregnancy: 'lucide:baby',
    birth: 'lucide:heart-pulse',
    breastfeeding: 'lucide:milk',
    childcare: 'lucide:hand-heart',
    psychology: 'lucide:brain',
    nutrition: 'lucide:utensils',
  }
  return map[cat] || 'lucide:file-text'
}

function catLabel(cat: string) {
  return categories.find(c => c.value === cat)?.label || cat
}
</script>

<style scoped>
.edu-page { max-width: 720px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.edu-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(168,200,232,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(168,200,232,0.12); border-radius: 16px; padding: 24px 28px;
}
.edu-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.edu-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.cat-scroll { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; }
.cat-scroll::-webkit-scrollbar { display: none; }
.cat-chip {
  flex-shrink: 0; padding: 8px 16px; border: 1px solid var(--color-border-light);
  border-radius: 20px; background: white; font-size: 0.78rem; font-weight: 500;
  cursor: pointer; font-family: var(--font-body); white-space: nowrap;
  transition: all 0.15s;
}
.cat-chip:hover { border-color: rgba(139,126,200,0.2); }
.cat-chip--active {
  border-color: var(--color-primary); background: rgba(139,126,200,0.08);
  color: var(--color-primary); font-weight: 600;
}

.article-grid { display: flex; flex-direction: column; gap: 8px; }
.article-card {
  display: flex; align-items: center; gap: 14px; padding: 16px 18px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px;
  cursor: pointer; transition: all 0.2s;
}
.article-card:hover { border-color: rgba(139,126,200,0.2); transform: translateY(-1px); box-shadow: 0 4px 16px rgba(139,126,200,0.06); }

.article-type-icon {
  width: 44px; height: 44px; border-radius: 12px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  background: rgba(139,126,200,0.08); color: var(--color-primary);
}
.article-type-icon.pregnancy { background: rgba(232,160,191,0.1); color: var(--color-accent-rose); }
.article-type-icon.birth { background: rgba(212,114,124,0.08); color: var(--color-danger); }
.article-type-icon.breastfeeding { background: rgba(242,196,160,0.12); color: var(--color-accent-peach); }
.article-type-icon.childcare { background: rgba(168,200,232,0.12); color: var(--color-accent-sky); }
.article-type-icon.psychology { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.article-type-icon.nutrition { background: rgba(233,196,106,0.1); color: var(--color-warning); }

.article-body { flex: 1; min-width: 0; }
.article-title { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.article-meta { display: flex; align-items: center; gap: 6px; margin-top: 4px; font-size: 0.7rem; color: var(--color-text-muted); }
.meta-cat { font-weight: 500; color: var(--color-text-secondary); }
.meta-dot { opacity: 0.4; }
.article-arrow { color: var(--color-text-muted); flex-shrink: 0; }

.empty-card { text-align: center; padding: 48px 20px; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; }
.empty-text { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 10px; }
</style>

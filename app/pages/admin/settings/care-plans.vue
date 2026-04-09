<template>
  <div class="cp-page">
    <div class="cp-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Настройки</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Шаблоны маршрутов</h1>
          <p class="hero-sub">{{ templates.length }} шаблонов для автоматизации ведения пациентов</p>
        </div>
      </div>
    </div>

    <div class="filter-row">
      <button v-for="f in typeFilters" :key="f.value" class="filter-btn" :class="{ active: typeFilter === f.value }" @click="typeFilter = f.value">{{ f.label }}</button>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="cp-list">
      <div v-for="t in filtered" :key="t.id" class="cp-card">
        <div class="cp-card-header">
          <span class="type-badge" :class="t.type">{{ typeLabel(t.type) }}</span>
          <div class="cp-card-flags">
            <span v-if="t.is_default" class="flag-badge default">По умолчанию</span>
            <span class="flag-badge" :class="t.is_active ? 'active' : 'inactive'">{{ t.is_active ? 'Активен' : 'Неактивен' }}</span>
          </div>
        </div>
        <h3 class="cp-name">{{ t.name }}</h3>
        <p class="cp-desc">{{ t.description || 'Без описания' }}</p>
        <div class="cp-meta">
          <span class="cp-chip"><Icon name="lucide:list-checks" size="12" /> {{ t.event_count }} событий</span>
          <span class="cp-chip"><Icon name="lucide:calendar" size="12" /> {{ formatDate(t.created_at) }}</span>
        </div>

        <!-- Events preview -->
        <div v-if="t.events.length" class="cp-events">
          <div v-for="(ev, i) in t.events.slice(0, 5)" :key="i" class="cp-event">
            <span class="ev-week">{{ ev.trigger_week ? `Нед ${ev.trigger_week}` : ev.trigger_day ? `День ${ev.trigger_day}` : '—' }}</span>
            <span class="ev-type-dot" :class="ev.type" />
            <span class="ev-title">{{ ev.title }}</span>
            <span v-if="ev.is_mandatory" class="ev-req">обяз.</span>
          </div>
          <p v-if="t.events.length > 5" class="cp-more">+ ещё {{ t.events.length - 5 }} событий</p>
        </div>
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:route" title="Шаблоны не найдены" description="Создайте первый шаблон маршрута для ведения пациентов" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const loading = ref(true)
const typeFilter = ref('all')

interface TemplateEvent { type: string; title: string; trigger_week: number | null; trigger_day: number | null; is_mandatory: boolean }
interface Template { id: string; type: string; name: string; description: string | null; is_default: boolean; is_active: boolean; event_count: number; events: TemplateEvent[]; created_at: string }

const templates = ref<Template[]>([])

const typeFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Беременность', value: 'pregnancy' },
  { label: 'Послеродовой', value: 'postpartum' },
  { label: 'Младенец', value: 'infant' },
  { label: 'Тоддлер', value: 'toddler' },
]

const filtered = computed(() => {
  if (typeFilter.value === 'all') return templates.value
  return templates.value.filter(t => t.type === typeFilter.value)
})

function typeLabel(s: string) {
  return { pregnancy: 'Беременность', postpartum: 'Послеродовой', infant: 'Младенец', toddler: 'Тоддлер' }[s] || s
}

function formatDate(dt: string) {
  return new Date(dt).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short', year: 'numeric' })
}

onMounted(async () => {
  const { data } = await sb.from('journey_templates').select('*').order('type').order('name')
  templates.value = (data || []).map(t => {
    const events: TemplateEvent[] = Array.isArray(t.events_json) ? t.events_json : []
    return {
      id: t.id,
      type: t.type,
      name: t.name,
      description: t.description,
      is_default: t.is_default,
      is_active: t.is_active,
      event_count: events.length,
      events,
      created_at: t.created_at,
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
.filter-row { display: flex; gap: 6px; flex-wrap: wrap; }
.filter-btn { padding: 6px 14px; border: 1px solid var(--color-border-light); border-radius: 20px; font-size: 0.78rem; font-weight: 500; background: white; cursor: pointer; transition: all 0.2s; font-family: var(--font-body); color: var(--color-text-muted); }
.filter-btn.active { background: var(--color-primary); color: white; border-color: var(--color-primary); }
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 40px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.cp-list { display: flex; flex-direction: column; gap: 10px; }
.cp-card {
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px 20px; transition: box-shadow 0.2s;
}
.cp-card:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.cp-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.cp-card-flags { display: flex; gap: 6px; }
.type-badge { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; }
.type-badge.pregnancy { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.type-badge.postpartum { background: rgba(232,160,191,0.12); color: #c76b94; }
.type-badge.infant { background: rgba(100,180,120,0.12); color: #4a9960; }
.type-badge.toddler { background: rgba(232,184,77,0.12); color: #b08a2a; }
.flag-badge { font-size: 0.62rem; font-weight: 600; padding: 2px 6px; border-radius: 6px; }
.flag-badge.default { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.flag-badge.active { background: rgba(100,180,120,0.1); color: #4a9960; }
.flag-badge.inactive { background: rgba(150,150,150,0.1); color: #888; }
.cp-name { font-size: 0.95rem; font-weight: 600; }
.cp-desc { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 4px; }
.cp-meta { display: flex; gap: 8px; margin-top: 10px; }
.cp-chip {
  display: inline-flex; align-items: center; gap: 3px; padding: 2px 8px; border-radius: 8px;
  font-size: 0.68rem; font-weight: 500; background: rgba(139,126,200,0.06); color: var(--color-text-muted);
}
/* Events preview */
.cp-events { margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--color-border-light); display: flex; flex-direction: column; gap: 4px; }
.cp-event { display: flex; align-items: center; gap: 8px; font-size: 0.78rem; }
.ev-week { width: 60px; font-size: 0.68rem; font-weight: 600; font-family: var(--font-mono); color: var(--color-text-muted); }
.ev-type-dot { width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0; }
.ev-type-dot.consultation { background: var(--color-primary); }
.ev-type-dot.screening { background: #c76b94; }
.ev-type-dot.analysis { background: #4a9960; }
.ev-type-dot.ultrasound { background: #b08a2a; }
.ev-type-dot.vaccination { background: #e8b84d; }
.ev-type-dot.checkup { background: #607d8b; }
.ev-title { flex: 1; color: var(--color-text-primary); }
.ev-req { font-size: 0.62rem; font-weight: 600; color: #d94f4f; }
.cp-more { font-size: 0.72rem; color: var(--color-text-muted); margin-top: 4px; }
</style>

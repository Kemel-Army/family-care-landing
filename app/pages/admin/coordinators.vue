<template>
  <div class="coord-page">
    <div class="coord-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Координаторы</h1>
          <p class="hero-sub">{{ coordinators.length }} координаторов</p>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени…" class="search-input" />
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="coord-list">
      <div v-for="c in filtered" :key="c.id" class="coord-row">
        <div class="coord-avatar">{{ initials(c.name) }}</div>
        <div class="coord-info">
          <h3 class="coord-name">{{ c.name }}</h3>
          <p class="coord-contact">{{ c.email }}</p>
        </div>
        <div class="coord-stats">
          <div class="stat-item">
            <span class="stat-val">{{ c.pending_tasks }}</span>
            <span class="stat-lbl">задач</span>
          </div>
          <div class="stat-item">
            <span class="stat-val">{{ c.completed_tasks }}</span>
            <span class="stat-lbl">завершено</span>
          </div>
          <div class="stat-item">
            <span class="stat-val">{{ c.family_count }}</span>
            <span class="stat-lbl">семей</span>
          </div>
        </div>
        <span class="status-dot" :class="{ active: c.is_active, recent: c.was_online_recently }" />
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:headphones" title="Координаторы не найдены" description="Попробуйте изменить поиск" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const search = ref('')
const loading = ref(true)

interface Coordinator {
  id: string
  name: string
  email: string
  is_active: boolean
  was_online_recently: boolean
  pending_tasks: number
  completed_tasks: number
  family_count: number
}

const coordinators = ref<Coordinator[]>([])

const filtered = computed(() => {
  if (!search.value) return coordinators.value
  const q = search.value.toLowerCase()
  return coordinators.value.filter(c => c.name.toLowerCase().includes(q) || c.email.toLowerCase().includes(q))
})

function initials(name: string) { return name.split(' ').map(w => w[0]).join('').slice(0, 2) }

onMounted(async () => {
  const { data: users } = await sb.from('users').select('id, first_name, last_name, email, is_active, last_seen_at').eq('role', 'coordinator')
  if (!users) { loading.value = false; return }

  const ids = users.map(u => u.id)

  // Tasks per coordinator
  const { data: tasks } = await sb.from('coordinator_tasks').select('assigned_to, status').in('assigned_to', ids)
  const taskMap: Record<string, { pending: number; completed: number }> = {}
  tasks?.forEach(t => {
    if (!t.assigned_to) return
    taskMap[t.assigned_to] ??= { pending: 0, completed: 0 }
    if (t.status === 'completed') taskMap[t.assigned_to].completed++
    else taskMap[t.assigned_to].pending++
  })

  // Families assigned (via tasks)
  const familyMap: Record<string, Set<string>> = {}
  tasks?.forEach(t => {
    if (!t.assigned_to) return
    familyMap[t.assigned_to] ??= new Set()
  })
  const { data: famTasks } = await sb.from('coordinator_tasks').select('assigned_to, family_id').in('assigned_to', ids)
  famTasks?.forEach(t => {
    if (t.assigned_to && t.family_id) {
      (familyMap[t.assigned_to] ??= new Set()).add(t.family_id)
    }
  })

  const hourAgo = new Date(Date.now() - 3600_000).toISOString()

  coordinators.value = users.map(u => ({
    id: u.id,
    name: `${u.last_name || ''} ${u.first_name || ''}`.trim() || u.email,
    email: u.email,
    is_active: u.is_active,
    was_online_recently: u.last_seen_at ? u.last_seen_at > hourAgo : false,
    pending_tasks: taskMap[u.id]?.pending || 0,
    completed_tasks: taskMap[u.id]?.completed || 0,
    family_count: familyMap[u.id]?.size || 0,
  }))
  loading.value = false
})
</script>

<style scoped>
.coord-page { max-width: 780px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }
.coord-hero {
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
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 40px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.coord-list { display: flex; flex-direction: column; gap: 2px; }
.coord-row {
  display: flex; align-items: center; gap: 14px; padding: 12px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px; transition: box-shadow 0.2s;
}
.coord-row:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.coord-avatar {
  width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, rgba(139,126,200,0.15), rgba(232,160,191,0.12));
  font-size: 0.72rem; font-weight: 700; color: var(--color-primary); flex-shrink: 0;
}
.coord-info { flex: 1; min-width: 0; }
.coord-name { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.coord-contact { font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }
.coord-stats { display: flex; gap: 16px; flex-shrink: 0; }
.stat-item { display: flex; flex-direction: column; align-items: center; }
.stat-val { font-size: 0.88rem; font-weight: 700; font-family: var(--font-mono); }
.stat-lbl { font-size: 0.62rem; color: var(--color-text-muted); }
.status-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; background: var(--color-border-light); }
.status-dot.active { background: #4a9960; }
.status-dot.recent { background: #4a9960; box-shadow: 0 0 0 3px rgba(74,153,96,0.2); }
</style>

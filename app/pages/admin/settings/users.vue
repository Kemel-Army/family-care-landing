<template>
  <div class="users-page">
    <div class="users-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Настройки</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Пользователи</h1>
          <p class="hero-sub">{{ users.length }} пользователей в системе</p>
        </div>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени или email…" class="search-input" />
    </div>

    <div class="filter-row">
      <button v-for="f in roleFilters" :key="f.value" class="filter-btn" :class="{ active: roleFilter === f.value }" @click="roleFilter = f.value">{{ f.label }}</button>
    </div>

    <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>

    <div v-else-if="filtered.length" class="user-list">
      <div v-for="u in filtered" :key="u.id" class="user-row">
        <div class="user-avatar">{{ initials(u.name) }}</div>
        <div class="user-info">
          <h3 class="user-name">{{ u.name }}</h3>
          <p class="user-email">{{ u.email }}</p>
        </div>
        <span class="role-badge" :class="u.role">{{ roleLabel(u.role) }}</span>
        <div class="user-seen">
          <span v-if="u.last_seen" class="seen-text">{{ formatSeen(u.last_seen) }}</span>
          <span v-else class="seen-text muted">Не был</span>
        </div>
        <span class="status-dot" :class="{ active: u.is_active }" />
      </div>
    </div>

    <AppSharedEmptyState v-else icon="lucide:shield" title="Пользователи не найдены" description="Попробуйте изменить фильтры" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const search = ref('')
const roleFilter = ref('all')
const loading = ref(true)

interface User { id: string; name: string; email: string; role: string; is_active: boolean; last_seen: string | null }

const users = ref<User[]>([])

const roleFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Админ', value: 'admin' },
  { label: 'Врач', value: 'doctor' },
  { label: 'Координатор', value: 'coordinator' },
  { label: 'Семья', value: 'family' },
]

const filtered = computed(() => {
  let items = users.value
  if (roleFilter.value === 'family') items = items.filter(u => ['mother', 'father', 'grandmother'].includes(u.role))
  else if (roleFilter.value !== 'all') items = items.filter(u => u.role === roleFilter.value)
  const q = search.value.toLowerCase()
  if (q) items = items.filter(u => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q))
  return items
})

function initials(name: string) { return name.split(' ').map(w => w[0]).join('').slice(0, 2) }

function roleLabel(r: string) {
  return { admin: 'Админ', superadmin: 'Суперадмин', doctor: 'Врач', nurse: 'Медсестра', coordinator: 'Координатор', mother: 'Мама', father: 'Папа', grandmother: 'Бабушка' }[r] || r
}

function formatSeen(dt: string) {
  const diff = Date.now() - new Date(dt).getTime()
  if (diff < 3_600_000) return `${Math.floor(diff / 60_000)} мин назад`
  if (diff < 86_400_000) return `${Math.floor(diff / 3_600_000)} ч назад`
  return new Date(dt).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' })
}

onMounted(async () => {
  const { data } = await sb.from('users').select('id, first_name, last_name, email, role, is_active, last_seen_at').order('role').order('last_name')
  users.value = (data || []).map(u => ({
    id: u.id,
    name: `${u.last_name || ''} ${u.first_name || ''}`.trim() || u.email,
    email: u.email,
    role: u.role,
    is_active: u.is_active,
    last_seen: u.last_seen_at,
  }))
  loading.value = false
})
</script>

<style scoped>
.users-page { max-width: 780px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }
.users-hero {
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
.user-list { display: flex; flex-direction: column; gap: 2px; }
.user-row {
  display: flex; align-items: center; gap: 14px; padding: 12px 16px;
  background: white; border: 1px solid var(--color-border-light); border-radius: 12px; transition: box-shadow 0.2s;
}
.user-row:hover { box-shadow: 0 2px 8px rgba(139,126,200,0.08); }
.user-avatar {
  width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, rgba(139,126,200,0.15), rgba(232,160,191,0.12));
  font-size: 0.72rem; font-weight: 700; color: var(--color-primary); flex-shrink: 0;
}
.user-info { flex: 1; min-width: 0; }
.user-name { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-email { font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }
.role-badge { font-size: 0.68rem; font-weight: 600; padding: 2px 8px; border-radius: 10px; white-space: nowrap; }
.role-badge.admin, .role-badge.superadmin { background: rgba(232,184,77,0.12); color: #b08a2a; }
.role-badge.doctor, .role-badge.nurse { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.role-badge.coordinator { background: rgba(100,180,120,0.12); color: #4a9960; }
.role-badge.mother, .role-badge.father, .role-badge.grandmother { background: rgba(232,160,191,0.12); color: #c76b94; }
.user-seen { width: 80px; flex-shrink: 0; text-align: right; }
.seen-text { font-size: 0.72rem; color: var(--color-text-muted); }
.seen-text.muted { opacity: 0.5; }
.status-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; background: var(--color-border-light); }
.status-dot.active { background: #4a9960; }
</style>

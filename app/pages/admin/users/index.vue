<template>
  <div class="usr-page">
    <div class="usr-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Пользователи</h1>
          <p class="hero-sub">Управление доступами и ролями</p>
        </div>
        <button class="btn-create" @click="openCreate"><Icon name="lucide:user-plus" size="14" /> Добавить</button>
      </div>
    </div>

    <div class="search-box">
      <Icon name="lucide:search" size="16" class="search-icon" />
      <input v-model="search" type="text" placeholder="Поиск по имени, email..." class="search-input" />
    </div>

    <div class="filter-row">
      <button v-for="r in roleFilters" :key="r.value" class="filter-btn" :class="{ active: roleFilter === r.value }" @click="roleFilter = r.value">{{ r.label }}</button>
    </div>

    <div class="user-list">
      <div v-for="u in filteredUsers" :key="u.id" class="user-row">
        <div class="user-avatar">{{ u.initials }}</div>
        <div class="user-info">
          <h3>{{ u.name }}</h3>
          <p>{{ u.email }}</p>
        </div>
        <span class="role-badge" :class="u.badgeClass">{{ u.roleLabel }}</span>
        <span class="user-status" :class="{ active: u.active }">{{ u.active ? 'Активен' : 'Неактивен' }}</span>
        <div class="user-actions">
          <button class="btn-icon" title="Редактировать"><Icon name="lucide:pencil" size="14" /></button>
          <button class="btn-icon" :class="{ danger: u.active }" @click="u.active = !u.active">
            <Icon :name="u.active ? 'lucide:user-x' : 'lucide:user-check'" size="14" />
          </button>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый пользователь</h2>
          <div class="form-row-2">
            <div class="fg"><label class="fl">Имя</label><input v-model="form.first" class="fi" /></div>
            <div class="fg"><label class="fl">Фамилия</label><input v-model="form.last" class="fi" /></div>
          </div>
          <div class="fg"><label class="fl">Email</label><input v-model="form.email" type="email" class="fi" /></div>
          <div class="fg"><label class="fl">Телефон</label><input v-model="form.phone" class="fi" placeholder="+7XXXXXXXXXX" /></div>
          <div class="fg">
            <label class="fl">Роль</label>
            <select v-model="form.role" class="fi">
              <option value="coordinator">Координатор</option>
              <option value="gynecologist">Гинеколог</option>
              <option value="pediatrician">Педиатр</option>
              <option value="clinic_admin">Администратор</option>
            </select>
          </div>
          <div class="fg"><label class="fl">Пароль</label><input v-model="form.password" type="password" class="fi" /></div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showModal = false">Отмена</button>
            <button class="btn-submit" @click="showModal = false">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const search = ref('')
const roleFilter = ref('all')
const showModal = ref(false)
const form = reactive({ first: '', last: '', email: '', phone: '', role: 'coordinator', password: '' })

const roleFilters = [
  { label: 'Все', value: 'all' },
  { label: 'Координаторы', value: 'coordinator' },
  { label: 'Гинекологи', value: 'gynecologist' },
  { label: 'Педиатры', value: 'pediatrician' },
  { label: 'Админы', value: 'clinic_admin' },
]

const rawUsers = reactive([
  { id: 1, first: 'Айгерим', last: 'Касымова', email: 'aigerim@familycare.kz', role: 'coordinator', active: true },
  { id: 2, first: 'Марат', last: 'Ибрагимов', email: 'marat@familycare.kz', role: 'gynecologist', active: true },
  { id: 3, first: 'Динара', last: 'Нуртаева', email: 'dinara@familycare.kz', role: 'pediatrician', active: true },
  { id: 4, first: 'Алия', last: 'Жумабаева', email: 'aliya@familycare.kz', role: 'coordinator', active: true },
  { id: 5, first: 'Ержан', last: 'Темiрбеков', email: 'erzhan@familycare.kz', role: 'clinic_admin', active: true },
  { id: 6, first: 'Сауле', last: 'Бектурганова', email: 'saule@familycare.kz', role: 'gynecologist', active: false },
  { id: 7, first: 'Бакыт', last: 'Оспанов', email: 'bakyt@familycare.kz', role: 'pediatrician', active: true },
])

function roleLabel(r: string) {
  return { coordinator: 'Координатор', gynecologist: 'Гинеколог', pediatrician: 'Педиатр', clinic_admin: 'Админ' }[r] || r
}
function badgeClass(r: string) {
  if (r === 'coordinator') return 'coordinator'
  if (['gynecologist', 'pediatrician'].includes(r)) return 'doctor'
  return 'admin'
}

const filteredUsers = computed(() => {
  let result = rawUsers.map(u => ({
    ...u,
    name: `${u.first} ${u.last}`,
    initials: `${u.first[0]}${u.last[0]}`,
    roleLabel: roleLabel(u.role),
    badgeClass: badgeClass(u.role),
  }))
  if (roleFilter.value !== 'all') result = result.filter(u => u.role === roleFilter.value)
  const q = search.value.toLowerCase()
  if (q) result = result.filter(u => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q))
  return result
})

function openCreate() {
  Object.assign(form, { first: '', last: '', email: '', phone: '', role: 'coordinator', password: '' })
  showModal.value = true
}
</script>

<style scoped>
.usr-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 12px; }

.usr-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.btn-create { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }

.search-box { display: flex; align-items: center; gap: 8px; padding: 9px 14px; border: 1px solid var(--color-border-light); border-radius: 12px; background: white; }
.search-icon { color: var(--color-text-muted); flex-shrink: 0; }
.search-input { border: none; outline: none; font-size: 0.85rem; font-family: var(--font-body); background: transparent; flex: 1; }

.filter-row { display: flex; gap: 6px; overflow-x: auto; }
.filter-btn { padding: 6px 14px; border: 1px solid var(--color-border-light); border-radius: 20px; background: white; font-size: 0.78rem; cursor: pointer; font-family: var(--font-body); white-space: nowrap; }
.filter-btn.active { border-color: var(--color-primary); background: rgba(139,126,200,0.08); color: var(--color-primary); font-weight: 600; }

.user-list { display: flex; flex-direction: column; gap: 6px; }
.user-row { display: flex; align-items: center; gap: 12px; padding: 12px 16px; background: white; border: 1px solid var(--color-border-light); border-radius: 12px; }
.user-avatar { width: 36px; height: 36px; border-radius: 50%; background: rgba(139,126,200,0.1); color: var(--color-primary); display: flex; align-items: center; justify-content: center; font-size: 0.72rem; font-weight: 700; flex-shrink: 0; }
.user-info { flex: 1; min-width: 0; }
.user-info h3 { font-size: 0.88rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-info p { font-size: 0.78rem; color: var(--color-text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.role-badge { font-size: 0.68rem; font-weight: 600; padding: 3px 10px; border-radius: 6px; flex-shrink: 0; }
.role-badge.coordinator { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.role-badge.doctor { background: rgba(124,184,212,0.12); color: var(--color-success); }
.role-badge.admin { background: rgba(233,196,106,0.12); color: var(--color-warning); }

.user-status { font-size: 0.72rem; color: var(--color-text-muted); flex-shrink: 0; }
.user-status.active { color: var(--color-success); }

.user-actions { display: flex; gap: 4px; flex-shrink: 0; }
.btn-icon { width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--color-border-light); border-radius: 8px; background: none; cursor: pointer; color: var(--color-text-muted); }
.btn-icon:hover { background: rgba(139,126,200,0.06); color: var(--color-primary); }
.btn-icon.danger:hover { background: rgba(212,114,124,0.08); color: var(--color-danger); border-color: var(--color-danger); }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 460px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; background: white; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

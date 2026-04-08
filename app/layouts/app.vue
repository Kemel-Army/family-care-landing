<template>
  <div class="app-layout">
    <!-- Sidebar -->
    <aside class="app-sidebar" :class="{ 'is-collapsed': sidebarCollapsed }">
      <div class="sidebar-header">
        <div class="sidebar-logo">
          <Icon name="lucide:heart-pulse" size="28" />
          <span v-if="!sidebarCollapsed" class="sidebar-logo-text">Family Care</span>
        </div>
        <div class="sidebar-header-actions">
          <div v-if="isFamily" class="desktop-bell-wrapper">
            <button class="desktop-bell" @click="bellOpen = !bellOpen">
              <Icon name="lucide:bell" size="18" />
              <span v-if="notifStore.unreadCount > 0" class="desktop-bell-badge">{{ notifStore.unreadCount > 9 ? '9+' : notifStore.unreadCount }}</span>
            </button>
            <!-- Dropdown -->
            <div v-if="bellOpen" class="notif-dropdown">
              <div class="notif-dropdown-header">
                <span class="notif-dropdown-title">Уведомления</span>
                <button v-if="notifStore.unreadCount" class="notif-mark-all" @click="notifStore.markAllAsRead()">Прочитать все</button>
              </div>
              <div class="notif-dropdown-body">
                <div v-if="!notifStore.recent.length" class="notif-empty">Нет уведомлений</div>
                <div v-for="n in notifStore.recent" :key="n.id" class="notif-item" :class="{ unread: !n.read_at }" @click="notifStore.markAsRead(n.id)">
                  <div class="notif-item-title">{{ n.title }}</div>
                  <div class="notif-item-body">{{ n.body }}</div>
                  <div class="notif-item-time">{{ formatNotifTime(n.created_at) }}</div>
                </div>
              </div>
            </div>
          </div>
          <button class="sidebar-toggle" @click="sidebarCollapsed = !sidebarCollapsed">
            <Icon :name="sidebarCollapsed ? 'lucide:chevron-right' : 'lucide:x'" size="18" />
          </button>
        </div>
      </div>

      <nav class="sidebar-nav">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="sidebar-link"
          :class="{ active: isActive(item.to) }"
        >
          <Icon :name="item.icon" size="20" />
          <span v-if="!sidebarCollapsed">{{ item.label }}</span>
        </NuxtLink>
      </nav>

      <div class="sidebar-footer">
        <div class="sidebar-user">
          <div class="sidebar-avatar">
            {{ userInitials }}
          </div>
          <div v-if="!sidebarCollapsed" class="sidebar-user-info">
            <span class="sidebar-user-name">{{ userName }}</span>
            <span class="sidebar-user-role">{{ roleLabel }}</span>
          </div>
        </div>
        <button class="sidebar-link" @click="handleLogout">
          <Icon name="lucide:log-out" size="20" />
          <span v-if="!sidebarCollapsed">Выйти</span>
        </button>
      </div>
    </aside>

    <!-- Mobile topbar -->
    <header class="app-topbar">
      <button class="topbar-menu" @click="mobileMenuOpen = !mobileMenuOpen">
        <Icon name="lucide:menu" size="24" />
      </button>
      <div class="topbar-title">
        <Icon name="lucide:heart-pulse" size="22" />
        <span>Family Care</span>
      </div>
      <div class="topbar-actions">
        <button class="topbar-bell" @click="bellOpen = !bellOpen">
          <Icon name="lucide:bell" size="22" />
          <span v-if="notifStore.unreadCount > 0" class="topbar-badge">{{ notifStore.unreadCount > 9 ? '9+' : notifStore.unreadCount }}</span>
        </button>
      </div>
    </header>

    <!-- Mobile overlay -->
    <div v-if="mobileMenuOpen" class="mobile-overlay" @click="mobileMenuOpen = false" />

    <!-- Mobile drawer -->
    <aside v-if="mobileMenuOpen" class="mobile-drawer">
      <nav class="sidebar-nav">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="sidebar-link"
          @click="mobileMenuOpen = false"
        >
          <Icon :name="item.icon" size="20" />
          <span>{{ item.label }}</span>
        </NuxtLink>
      </nav>
    </aside>

    <!-- Main content -->
    <main class="app-main" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'
import { ROLE_HOME_MAP } from '~/utils/constants'
import type { UserRole } from '~/types/database'

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const notifStore = useNotificationStore()
const authStore = useAuthStore()

const sidebarCollapsed = ref(false)
const mobileMenuOpen = ref(false)
const bellOpen = ref(false)

// Use auth store profile (populated from public.users table) with fallback to user_metadata
const userName = computed(() => {
  if (authStore.profile) {
    return authStore.fullName || user.value?.email || 'Пользователь'
  }
  const meta = user.value?.user_metadata ?? {}
  const first = meta.first_name || ''
  const last = meta.last_name || ''
  return `${first} ${last}`.trim() || user.value?.email || 'Пользователь'
})
const userInitials = computed(() => {
  const parts = userName.value.split(' ')
  return parts.map(p => p[0]).join('').toUpperCase().slice(0, 2)
})
const userRole = computed<UserRole>(() => authStore.role)
const roleLabel = computed(() => {
  const labels: Record<string, string> = {
    mother: 'Мама',
    father: 'Папа',
    coordinator: 'Координатор',
    gynecologist: 'Гинеколог',
    pediatrician: 'Педиатр',
    clinic_admin: 'Администратор',
    clinic_manager: 'Руководитель',
    platform_admin: 'Platform Admin',
    doctor: 'Врач',
    nurse: 'Медсестра',
    admin: 'Администратор',
    superadmin: 'Суперадмин',
  }
  return labels[userRole.value] || userRole.value
})

// Navigation items based on role
const navItems = computed(() => {
  const role = userRole.value
  if (role === 'mother' || role === 'father') {
    return [
      { to: '/family', label: 'Главная', icon: 'lucide:layout-dashboard' },
      { to: '/family/journey', label: 'Маршрут', icon: 'lucide:route' },
      { to: '/family/prescriptions', label: 'Назначения', icon: 'lucide:pill' },
      { to: '/family/appointments', label: 'Записи', icon: 'lucide:calendar-check' },
      { to: '/family/documents', label: 'Документы', icon: 'lucide:folder' },
      { to: '/family/vaccinations', label: 'Прививки', icon: 'lucide:shield-check' },
      { to: '/family/health-passport', label: 'Паспорт', icon: 'lucide:file-text' },
      { to: '/family/ai-assistant', label: 'AI Помощник', icon: 'lucide:brain' },
      { to: '/family/settings', label: 'Настройки', icon: 'lucide:settings' },
    ]
  }
  if (role === 'coordinator') {
    return [
      { to: '/coordinator', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
      { to: '/coordinator/families', label: 'Семьи', icon: 'lucide:users' },
      { to: '/coordinator/tasks', label: 'Задачи', icon: 'lucide:check' },
      { to: '/coordinator/outreach', label: 'Outreach', icon: 'lucide:phone-call' },
    ]
  }
  if (role === 'doctor' || role === 'gynecologist' || role === 'pediatrician') {
    return [
      { to: '/doctor', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
      { to: '/doctor/patients', label: 'Пациенты', icon: 'lucide:users' },
      { to: '/doctor/schedule', label: 'Расписание', icon: 'lucide:calendar-check' },
    ]
  }
  if (role === 'nurse') {
    return [
      { to: '/doctor', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
      { to: '/doctor/patients', label: 'Пациенты', icon: 'lucide:users' },
      { to: '/doctor/schedule', label: 'Расписание', icon: 'lucide:calendar-check' },
    ]
  }
  // Admin roles (admin, superadmin, clinic_admin, clinic_manager, platform_admin)
  return [
    { to: '/admin', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
    { to: '/admin/users', label: 'Пользователи', icon: 'lucide:users' },
    { to: '/admin/clinic', label: 'Клиника', icon: 'lucide:building-2' },
    { to: '/admin/templates', label: 'Шаблоны', icon: 'lucide:file-text' },
    { to: '/admin/packages', label: 'Пакеты', icon: 'lucide:package' },
    { to: '/admin/analytics', label: 'Аналитика', icon: 'lucide:bar-chart-3' },
    { to: '/admin/capacity', label: 'Загрузка', icon: 'lucide:calendar-range' },
    { to: '/admin/compliance', label: 'Комплаенс', icon: 'lucide:shield-check' },
    { to: '/admin/reputation', label: 'Репутация', icon: 'lucide:star' },
    { to: '/admin/outreach', label: 'Outreach', icon: 'lucide:phone-call' },
    { to: '/admin/training', label: 'Обучение', icon: 'lucide:graduation-cap' },
    { to: '/admin/integrations', label: 'Интеграции', icon: 'lucide:plug' },
    { to: '/admin/network', label: 'Сеть клиник', icon: 'lucide:network' },
    { to: '/admin/settings', label: 'Настройки', icon: 'lucide:settings' },
  ]
})

function isActive(to: string): boolean {
  if (to === '/family' || to === '/coordinator' || to === '/doctor' || to === '/admin') {
    return route.path === to
  }
  return route.path.startsWith(to)
}

async function handleLogout() {
  await supabase.auth.signOut()
  navigateTo('/auth/login')
}

const isFamily = computed(() => ['mother', 'father'].includes(userRole.value))

function formatNotifTime(dt: string) {
  const d = dayjs(dt)
  return d.isToday?.() ? d.format('HH:mm') : d.format('DD.MM HH:mm')
}

// Close menus on route change
watch(() => route.path, () => {
  mobileMenuOpen.value = false
  bellOpen.value = false
})

// Init auth store + notifications
onMounted(async () => {
  await authStore.initialize()
  if (isFamily.value) {
    await notifStore.fetchNotifications()
    notifStore.subscribeToNotifications()
  }
})
</script>

<style scoped>
.app-layout {
  display: flex;
  min-height: 100vh;
  background: var(--color-bg-alt);
}

/* Sidebar */
.app-sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 260px;
  background: var(--color-surface);
  border-right: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  z-index: 40;
  transition: width var(--transition-smooth);
}

.app-sidebar.is-collapsed {
  width: 72px;
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 16px;
  border-bottom: 1px solid var(--color-border-light);
}

.sidebar-header-actions { display: flex; align-items: center; gap: 4px; }

.desktop-bell-wrapper { position: relative; }
.desktop-bell {
  position: relative; background: none; border: none; padding: 6px;
  color: var(--color-text-muted); cursor: pointer; border-radius: var(--radius-sm);
  transition: color var(--transition-fast);
}
.desktop-bell:hover { color: var(--color-primary); }
.desktop-bell-badge {
  position: absolute; top: 0; right: 0; background: var(--color-danger); color: white;
  font-size: 0.6rem; font-weight: 700; padding: 1px 4px; border-radius: var(--radius-full); line-height: 1.2;
}

.notif-dropdown {
  position: absolute; top: 40px; right: 0; width: 320px; max-height: 400px;
  background: var(--color-surface); border: 1px solid var(--color-border); border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg); z-index: 100; display: flex; flex-direction: column;
}
.notif-dropdown-header {
  display: flex; align-items: center; justify-content: space-between; padding: 12px 14px;
  border-bottom: 1px solid var(--color-border-light);
}
.notif-dropdown-title { font-weight: 600; font-size: 0.9rem; }
.notif-mark-all {
  background: none; border: none; color: var(--color-primary); font-size: 0.75rem;
  font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.notif-dropdown-body { overflow-y: auto; max-height: 340px; }
.notif-empty { padding: 24px; text-align: center; color: var(--color-text-muted); font-size: 0.85rem; }
.notif-item {
  padding: 10px 14px; cursor: pointer; border-bottom: 1px solid var(--color-border-light);
  transition: background var(--transition-fast);
}
.notif-item:hover { background: var(--color-primary-ultralight); }
.notif-item.unread { background: rgba(139, 126, 200, 0.05); }
.notif-item-title { font-size: 0.85rem; font-weight: 600; margin-bottom: 2px; }
.notif-item-body { font-size: 0.8rem; color: var(--color-text-secondary); line-height: 1.4; }
.notif-item-time { font-size: 0.7rem; color: var(--color-text-muted); margin-top: 4px; }

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--color-primary);
}

.sidebar-logo-text {
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 1.1rem;
  color: var(--color-text-primary);
  white-space: nowrap;
}

.sidebar-toggle {
  background: none;
  border: none;
  color: var(--color-text-muted);
  cursor: pointer;
  padding: 4px;
  border-radius: var(--radius-sm);
  transition: color var(--transition-fast);
}

.sidebar-toggle:hover {
  color: var(--color-text-primary);
}

.sidebar-nav {
  flex: 1;
  padding: 12px 8px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow-y: auto;
}

.sidebar-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  color: var(--color-text-secondary);
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all var(--transition-fast);
  white-space: nowrap;
  border: none;
  background: none;
  cursor: pointer;
  width: 100%;
  text-align: left;
}

.sidebar-link:hover {
  background: var(--color-primary-ultralight);
  color: var(--color-primary);
}

.sidebar-link.active {
  background: var(--color-primary-light);
  color: var(--color-primary-dark);
  font-weight: 600;
}

.sidebar-footer {
  padding: 12px 8px;
  border-top: 1px solid var(--color-border-light);
}

.sidebar-user {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  margin-bottom: 4px;
}

.sidebar-avatar {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-full);
  background: var(--gradient-cta);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.8rem;
  flex-shrink: 0;
}

.sidebar-user-info {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.sidebar-user-name {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sidebar-user-role {
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

/* Main content */
.app-main {
  flex: 1;
  margin-left: 260px;
  padding: 32px;
  min-height: 100vh;
  transition: margin-left var(--transition-smooth);
}

.app-main.sidebar-collapsed {
  margin-left: 72px;
}

/* Mobile topbar (hidden on desktop) */
.app-topbar {
  display: none;
}

.mobile-overlay,
.mobile-drawer {
  display: none;
}

/* Mobile */
@media (max-width: 1024px) {
  .app-sidebar {
    display: none;
  }

  .app-topbar {
    display: flex;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: 56px;
    background: var(--color-surface);
    border-bottom: 1px solid var(--color-border);
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    z-index: 50;
  }

  .topbar-menu {
    background: none;
    border: none;
    color: var(--color-text-primary);
    cursor: pointer;
    padding: 4px;
  }

  .topbar-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-family: var(--font-display);
    font-weight: 700;
    color: var(--color-primary);
  }

  .topbar-actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .topbar-bell {
    position: relative;
    color: var(--color-text-secondary);
    padding: 4px;
  }

  .topbar-badge {
    position: absolute;
    top: -2px;
    right: -4px;
    background: var(--color-danger);
    color: white;
    font-size: 0.65rem;
    font-weight: 700;
    padding: 1px 5px;
    border-radius: var(--radius-full);
    line-height: 1.2;
  }

  .app-main {
    margin-left: 0;
    padding: 72px 16px 24px;
  }

  .app-main.sidebar-collapsed {
    margin-left: 0;
  }

  .mobile-overlay {
    display: block;
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.4);
    z-index: 55;
  }

  .mobile-drawer {
    display: block;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: 280px;
    background: var(--color-surface);
    z-index: 60;
    padding: 72px 8px 24px;
    overflow-y: auto;
    box-shadow: var(--shadow-lg);
  }
}
</style>

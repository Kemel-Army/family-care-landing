<template>
  <div class="app-layout" :class="{ 'has-collapsed-sidebar': sidebarCollapsed }">
    <!-- Ambient gradient blob -->
    <div class="app-ambient" aria-hidden="true" />

    <!-- Sidebar -->
    <aside class="app-sidebar" :class="{ 'is-collapsed': sidebarCollapsed }">
      <!-- Glass backdrop -->
      <div class="sidebar-glass" />

      <div class="sidebar-inner">
        <div class="sidebar-header">
          <div class="sidebar-logo">
            <div class="sidebar-logo-icon">
              <Icon name="lucide:heart-pulse" size="22" />
            </div>
            <Transition name="fade-text">
              <span v-if="!sidebarCollapsed" class="sidebar-logo-text">Family Care</span>
            </Transition>
          </div>
          <button class="sidebar-toggle" @click="sidebarCollapsed = !sidebarCollapsed" :aria-label="sidebarCollapsed ? 'Развернуть' : 'Свернуть'">
            <Icon :name="sidebarCollapsed ? 'lucide:panel-left-open' : 'lucide:panel-left-close'" size="18" />
          </button>
        </div>

        <!-- Greeting -->
        <Transition name="fade-text">
          <div v-if="!sidebarCollapsed" class="sidebar-greeting">
            <span class="greeting-text">{{ greeting }},</span>
            <span class="greeting-name">{{ userFirstName }}</span>
          </div>
        </Transition>

        <nav class="sidebar-nav">
          <div v-for="(group, gi) in navGroups" :key="gi" class="nav-group">
            <span v-if="group.label && !sidebarCollapsed" class="nav-group-label">{{ group.label }}</span>
            <NuxtLink
              v-for="item in group.items"
              :key="item.to"
              :to="item.to"
              class="sidebar-link"
              :class="{ active: isActive(item.to) }"
            >
              <span class="sidebar-link-icon">
                <Icon :name="item.icon" size="20" />
              </span>
              <Transition name="fade-text">
                <span v-if="!sidebarCollapsed" class="sidebar-link-label">{{ item.label }}</span>
              </Transition>
              <span v-if="item.badge && !sidebarCollapsed" class="sidebar-link-badge">{{ item.badge }}</span>
              <span v-if="item.badge && sidebarCollapsed" class="sidebar-link-dot" />
            </NuxtLink>
          </div>
        </nav>

        <div class="sidebar-footer">
          <!-- Notifications -->
          <div v-if="isFamily" class="sidebar-notif-wrapper">
            <button class="sidebar-notif-btn" :class="{ 'has-unread': notifStore.unreadCount > 0 }" @click="bellOpen = !bellOpen">
              <Icon name="lucide:bell" size="18" />
              <Transition name="fade-text">
                <span v-if="!sidebarCollapsed" class="sidebar-notif-label">Уведомления</span>
              </Transition>
              <span v-if="notifStore.unreadCount > 0" class="sidebar-notif-badge">{{ notifStore.unreadCount > 9 ? '9+' : notifStore.unreadCount }}</span>
            </button>
            <!-- Dropdown -->
            <Transition name="dropdown">
              <div v-if="bellOpen" class="notif-dropdown">
                <div class="notif-dropdown-header">
                  <span class="notif-dropdown-title">Уведомления</span>
                  <button v-if="notifStore.unreadCount" class="notif-mark-all" @click="notifStore.markAllAsRead()">Прочитать все</button>
                </div>
                <div class="notif-dropdown-body">
                  <div v-if="!notifStore.recent.length" class="notif-empty">
                    <Icon name="lucide:inbox" size="32" style="opacity: 0.3; margin-bottom: 8px" />
                    <span>Нет уведомлений</span>
                  </div>
                  <div v-for="n in notifStore.recent" :key="n.id" class="notif-item" :class="{ unread: !n.read_at }" @click="notifStore.markAsRead(n.id)">
                    <div class="notif-item-dot" :class="{ visible: !n.read_at }" />
                    <div class="notif-item-content">
                      <div class="notif-item-title">{{ n.title }}</div>
                      <div class="notif-item-body">{{ n.body }}</div>
                      <div class="notif-item-time">{{ formatNotifTime(n.created_at) }}</div>
                    </div>
                  </div>
                </div>
              </div>
            </Transition>
          </div>

          <!-- User -->
          <div class="sidebar-user">
            <div class="sidebar-avatar">
              {{ userInitials }}
            </div>
            <Transition name="fade-text">
              <div v-if="!sidebarCollapsed" class="sidebar-user-info">
                <span class="sidebar-user-name">{{ userName }}</span>
                <span class="sidebar-user-role">{{ roleLabel }}</span>
              </div>
            </Transition>
            <button v-if="!sidebarCollapsed" class="sidebar-logout" @click="handleLogout" aria-label="Выйти">
              <Icon name="lucide:log-out" size="16" />
            </button>
          </div>
        </div>
      </div>
    </aside>

    <!-- Mobile topbar -->
    <header class="app-topbar">
      <button class="topbar-menu" @click="mobileMenuOpen = !mobileMenuOpen">
        <Icon name="lucide:menu" size="22" />
      </button>
      <div class="topbar-title">
        <div class="topbar-logo-icon">
          <Icon name="lucide:heart-pulse" size="18" />
        </div>
        <span>Family Care</span>
      </div>
      <div class="topbar-actions">
        <button class="topbar-bell" @click="bellOpen = !bellOpen">
          <Icon name="lucide:bell" size="20" />
          <span v-if="notifStore.unreadCount > 0" class="topbar-badge">{{ notifStore.unreadCount > 9 ? '9+' : notifStore.unreadCount }}</span>
        </button>
      </div>
    </header>

    <!-- Mobile overlay -->
    <Transition name="fade">
      <div v-if="mobileMenuOpen" class="mobile-overlay" @click="mobileMenuOpen = false" />
    </Transition>

    <!-- Mobile drawer -->
    <Transition name="slide-left">
      <aside v-if="mobileMenuOpen" class="mobile-drawer">
        <div class="mobile-drawer-header">
          <div class="sidebar-logo">
            <div class="sidebar-logo-icon">
              <Icon name="lucide:heart-pulse" size="22" />
            </div>
            <span class="sidebar-logo-text">Family Care</span>
          </div>
          <button class="mobile-drawer-close" @click="mobileMenuOpen = false">
            <Icon name="lucide:x" size="20" />
          </button>
        </div>
        <div class="mobile-greeting">
          <span class="greeting-text">{{ greeting }},</span>
          <span class="greeting-name">{{ userFirstName }}</span>
        </div>
        <nav class="sidebar-nav">
          <NuxtLink
            v-for="item in flatNavItems"
            :key="item.to"
            :to="item.to"
            class="sidebar-link"
            :class="{ active: isActive(item.to) }"
            @click="mobileMenuOpen = false"
          >
            <span class="sidebar-link-icon"><Icon :name="item.icon" size="20" /></span>
            <span class="sidebar-link-label">{{ item.label }}</span>
            <span v-if="item.badge" class="sidebar-link-badge">{{ item.badge }}</span>
          </NuxtLink>
        </nav>
        <div class="sidebar-footer" style="padding: 16px 8px">
          <div class="sidebar-user">
            <div class="sidebar-avatar">{{ userInitials }}</div>
            <div class="sidebar-user-info">
              <span class="sidebar-user-name">{{ userName }}</span>
              <span class="sidebar-user-role">{{ roleLabel }}</span>
            </div>
          </div>
          <button class="sidebar-link" @click="handleLogout" style="margin-top: 4px">
            <span class="sidebar-link-icon"><Icon name="lucide:log-out" size="20" /></span>
            <span class="sidebar-link-label">Выйти</span>
          </button>
        </div>
      </aside>
    </Transition>

    <!-- Main content -->
    <main class="app-main" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'
import type { UserRole } from '~/types/database'

interface NavItem {
  to: string
  label: string
  icon: string
  badge?: string | number
}
interface NavGroup {
  label?: string
  items: NavItem[]
}

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const notifStore = useNotificationStore()
const authStore = useAuthStore()

const sidebarCollapsed = ref(false)
const mobileMenuOpen = ref(false)
const bellOpen = ref(false)

// Greeting based on time of day
const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return 'Доброй ночи'
  if (h < 12) return 'Доброе утро'
  if (h < 18) return 'Добрый день'
  return 'Добрый вечер'
})

const userName = computed(() => {
  if (authStore.profile) {
    return authStore.fullName || user.value?.email || 'Пользователь'
  }
  const meta = user.value?.user_metadata ?? {}
  const first = meta.first_name || ''
  const last = meta.last_name || ''
  return `${first} ${last}`.trim() || user.value?.email || 'Пользователь'
})

const userFirstName = computed(() => {
  if (authStore.profile?.first_name) return authStore.profile.first_name
  const meta = user.value?.user_metadata ?? {}
  return meta.first_name || userName.value.split(' ')[0]
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

const isFamily = computed(() => ['mother', 'father'].includes(userRole.value))

// Navigation with groups
const navGroups = computed<NavGroup[]>(() => {
  const role = userRole.value
  if (role === 'mother' || role === 'father') {
    return [
      {
        items: [
          { to: '/family', label: 'Главная', icon: 'lucide:layout-dashboard' },
        ],
      },
      {
        label: 'Здоровье',
        items: [
          { to: '/family/journey', label: 'Маршрут', icon: 'lucide:route' },
          { to: '/family/prescriptions', label: 'Назначения', icon: 'lucide:pill' },
          { to: '/family/appointments', label: 'Записи', icon: 'lucide:calendar-check' },
          { to: '/family/vaccinations', label: 'Прививки', icon: 'lucide:shield-check' },
          { to: '/family/health-passport', label: 'Паспорт', icon: 'lucide:file-text' },
        ],
      },
      {
        label: 'Дневник',
        items: [
          { to: '/family/growth', label: 'Рост', icon: 'lucide:ruler' },
          { to: '/family/mood', label: 'Настроение', icon: 'lucide:smile' },
          { to: '/family/sleep', label: 'Сон', icon: 'lucide:moon' },
          { to: '/family/nutrition', label: 'Питание', icon: 'lucide:apple' },
        ],
      },
      {
        label: 'Ещё',
        items: [
          { to: '/family/documents', label: 'Документы', icon: 'lucide:folder' },
          { to: '/family/achievements', label: 'Достижения', icon: 'lucide:trophy' },
          { to: '/family/education', label: 'Обучение', icon: 'lucide:book-open' },
          { to: '/family/ai-assistant', label: 'AI Помощник', icon: 'lucide:sparkles' },
          { to: '/family/settings', label: 'Настройки', icon: 'lucide:settings' },
        ],
      },
    ]
  }
  if (role === 'coordinator') {
    return [
      {
        items: [
          { to: '/coordinator', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
          { to: '/coordinator/families', label: 'Семьи', icon: 'lucide:users' },
          { to: '/coordinator/tasks', label: 'Задачи', icon: 'lucide:check-circle' },
          { to: '/coordinator/outreach', label: 'Outreach', icon: 'lucide:phone-call' },
        ],
      },
    ]
  }
  if (role === 'doctor' || role === 'gynecologist' || role === 'pediatrician' || role === 'nurse') {
    return [
      {
        items: [
          { to: '/doctor', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
          { to: '/doctor/patients', label: 'Пациенты', icon: 'lucide:users' },
          { to: '/doctor/schedule', label: 'Расписание', icon: 'lucide:calendar-check' },
        ],
      },
    ]
  }
  return [
    {
      items: [
        { to: '/admin', label: 'Дашборд', icon: 'lucide:layout-dashboard' },
      ],
    },
    {
      label: 'Управление',
      items: [
        { to: '/admin/users', label: 'Пользователи', icon: 'lucide:users' },
        { to: '/admin/clinic', label: 'Клиника', icon: 'lucide:building-2' },
        { to: '/admin/templates', label: 'Шаблоны', icon: 'lucide:file-text' },
        { to: '/admin/packages', label: 'Пакеты', icon: 'lucide:package' },
      ],
    },
    {
      label: 'Аналитика',
      items: [
        { to: '/admin/analytics', label: 'Аналитика', icon: 'lucide:bar-chart-3' },
        { to: '/admin/capacity', label: 'Загрузка', icon: 'lucide:calendar-range' },
        { to: '/admin/compliance', label: 'Комплаенс', icon: 'lucide:shield-check' },
        { to: '/admin/reputation', label: 'Репутация', icon: 'lucide:star' },
      ],
    },
    {
      label: 'Операции',
      items: [
        { to: '/admin/outreach', label: 'Outreach', icon: 'lucide:phone-call' },
        { to: '/admin/training', label: 'Обучение', icon: 'lucide:graduation-cap' },
        { to: '/admin/integrations', label: 'Интеграции', icon: 'lucide:plug' },
        { to: '/admin/network', label: 'Сеть клиник', icon: 'lucide:network' },
        { to: '/admin/settings', label: 'Настройки', icon: 'lucide:settings' },
      ],
    },
  ]
})

const flatNavItems = computed(() => navGroups.value.flatMap(g => g.items))

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

function formatNotifTime(dt: string) {
  const d = dayjs(dt)
  return d.isToday?.() ? d.format('HH:mm') : d.format('DD.MM HH:mm')
}

// Close menus on route change
watch(() => route.path, () => {
  mobileMenuOpen.value = false
  bellOpen.value = false
})

// Close dropdown on outside click
function onClickOutside(e: MouseEvent) {
  if (bellOpen.value) {
    const target = e.target as HTMLElement
    if (!target.closest('.sidebar-notif-wrapper') && !target.closest('.topbar-bell')) {
      bellOpen.value = false
    }
  }
}

onMounted(async () => {
  await authStore.initialize()
  if (isFamily.value) {
    await notifStore.fetchNotifications()
    notifStore.subscribeToNotifications()
  }
  document.addEventListener('click', onClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', onClickOutside)
})
</script>

<style scoped>
/* ─── Layout ─── */
.app-layout {
  display: flex;
  min-height: 100vh;
  background: var(--color-bg-alt);
  position: relative;
  overflow-x: hidden;
}

/* Ambient gradient blob behind sidebar */
.app-ambient {
  position: fixed;
  top: -120px;
  left: -80px;
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(139, 126, 200, 0.12) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
  filter: blur(60px);
}

/* ─── Sidebar ─── */
.app-sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 260px;
  z-index: 40;
  transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.app-sidebar.is-collapsed {
  width: 72px;
}

.sidebar-glass {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.65);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border-right: 1px solid rgba(139, 126, 200, 0.12);
}

.sidebar-inner {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* ─── Header ─── */
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 16px 12px;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
}

.sidebar-logo-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: var(--gradient-cta);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sidebar-logo-text {
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 1.05rem;
  color: var(--color-text-primary);
  white-space: nowrap;
}

.sidebar-toggle {
  background: none;
  border: none;
  color: var(--color-text-muted);
  cursor: pointer;
  padding: 6px;
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.sidebar-toggle:hover {
  color: var(--color-primary);
  background: rgba(139, 126, 200, 0.08);
}

/* ─── Greeting ─── */
.sidebar-greeting,
.mobile-greeting {
  padding: 4px 20px 16px;
}

.greeting-text {
  font-size: 0.8rem;
  color: var(--color-text-muted);
  display: block;
  line-height: 1.4;
}

.greeting-name {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text-primary);
  display: block;
  line-height: 1.4;
}

/* ─── Nav ─── */
.sidebar-nav {
  flex: 1;
  padding: 4px 10px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow-y: auto;
  scrollbar-width: none;
}

.sidebar-nav::-webkit-scrollbar { display: none; }

.nav-group {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.nav-group + .nav-group {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(139, 126, 200, 0.08);
}

.nav-group-label {
  font-size: 0.65rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--color-text-muted);
  padding: 4px 12px 6px;
  opacity: 0.7;
}

.sidebar-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 9px 12px;
  border-radius: 10px;
  color: var(--color-text-secondary);
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s ease;
  white-space: nowrap;
  border: none;
  background: none;
  cursor: pointer;
  width: 100%;
  text-align: left;
  position: relative;
}

.sidebar-link-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  flex-shrink: 0;
}

.sidebar-link-label {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sidebar-link:hover {
  background: rgba(139, 126, 200, 0.08);
  color: var(--color-primary);
}

.sidebar-link.active {
  background: rgba(139, 126, 200, 0.12);
  color: var(--color-primary-dark);
  font-weight: 600;
}

.sidebar-link.active .sidebar-link-icon {
  color: var(--color-primary);
}

.sidebar-link.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 20px;
  border-radius: 0 4px 4px 0;
  background: var(--gradient-cta);
}

.sidebar-link-badge {
  font-size: 0.65rem;
  font-weight: 600;
  padding: 2px 7px;
  border-radius: var(--radius-full);
  background: rgba(139, 126, 200, 0.12);
  color: var(--color-primary);
}

.sidebar-link-dot {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--color-primary);
}

/* ─── Footer ─── */
.sidebar-footer {
  padding: 8px 10px 16px;
  border-top: 1px solid rgba(139, 126, 200, 0.08);
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.sidebar-notif-wrapper {
  position: relative;
}

.sidebar-notif-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 9px 12px;
  border-radius: 10px;
  color: var(--color-text-secondary);
  font-size: 0.875rem;
  font-weight: 500;
  border: none;
  background: none;
  cursor: pointer;
  width: 100%;
  text-align: left;
  transition: all 0.2s ease;
}

.sidebar-notif-btn:hover {
  background: rgba(139, 126, 200, 0.08);
  color: var(--color-primary);
}

.sidebar-notif-label { flex: 1; }

.sidebar-notif-badge {
  font-size: 0.6rem;
  font-weight: 700;
  padding: 2px 7px;
  border-radius: var(--radius-full);
  background: var(--color-danger);
  color: white;
  line-height: 1.3;
}

/* ─── Notification Dropdown ─── */
.notif-dropdown {
  position: absolute;
  bottom: 100%;
  left: 8px;
  right: 8px;
  margin-bottom: 8px;
  max-height: 380px;
  background: white;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.1), 0 2px 8px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  z-index: 100;
  overflow: hidden;
}

.notif-dropdown-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  border-bottom: 1px solid var(--color-border-light);
}

.notif-dropdown-title { font-weight: 600; font-size: 0.9rem; }

.notif-mark-all {
  background: none;
  border: none;
  color: var(--color-primary);
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  font-family: var(--font-body);
}

.notif-dropdown-body { overflow-y: auto; flex: 1; }

.notif-empty {
  padding: 32px;
  text-align: center;
  color: var(--color-text-muted);
  font-size: 0.85rem;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.notif-item {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 1px solid var(--color-border-light);
  transition: background 0.15s ease;
}

.notif-item:last-child { border-bottom: none; }
.notif-item:hover { background: rgba(139, 126, 200, 0.04); }

.notif-item-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: transparent;
  flex-shrink: 0;
  margin-top: 6px;
}

.notif-item-dot.visible {
  background: var(--color-primary);
}

.notif-item-content { flex: 1; min-width: 0; }
.notif-item-title { font-size: 0.85rem; font-weight: 600; margin-bottom: 2px; }
.notif-item-body { font-size: 0.8rem; color: var(--color-text-secondary); line-height: 1.4; }
.notif-item-time { font-size: 0.7rem; color: var(--color-text-muted); margin-top: 4px; }

/* ─── User ─── */
.sidebar-user {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 10px;
  transition: background 0.2s ease;
}

.sidebar-avatar {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  background: var(--gradient-cta);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.75rem;
  flex-shrink: 0;
}

.sidebar-user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-width: 0;
}

.sidebar-user-name {
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--color-text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sidebar-user-role {
  font-size: 0.7rem;
  color: var(--color-text-muted);
}

.sidebar-logout {
  background: none;
  border: none;
  color: var(--color-text-muted);
  cursor: pointer;
  padding: 6px;
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.sidebar-logout:hover {
  color: var(--color-danger);
  background: rgba(212, 114, 124, 0.08);
}

/* ─── Main Content ─── */
.app-main {
  flex: 1;
  margin-left: 260px;
  padding: 28px 32px;
  min-height: 100vh;
  transition: margin-left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.app-main.sidebar-collapsed {
  margin-left: 72px;
}

/* ─── Mobile Topbar ─── */
.app-topbar {
  display: none;
}

.mobile-overlay,
.mobile-drawer {
  display: none;
}

/* ─── Transitions ─── */
.fade-text-enter-active { transition: opacity 0.2s ease 0.1s; }
.fade-text-leave-active { transition: opacity 0.1s ease; }
.fade-text-enter-from,
.fade-text-leave-to { opacity: 0; }

.dropdown-enter-active { transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); }
.dropdown-leave-active { transition: all 0.15s ease; }
.dropdown-enter-from,
.dropdown-leave-to { opacity: 0; transform: translateY(8px) scale(0.96); }

.fade-enter-active { transition: opacity 0.2s ease; }
.fade-leave-active { transition: opacity 0.15s ease; }
.fade-enter-from,
.fade-leave-to { opacity: 0; }

.slide-left-enter-active { transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
.slide-left-leave-active { transition: transform 0.2s ease; }
.slide-left-enter-from,
.slide-left-leave-to { transform: translateX(-100%); }

/* ─── Mobile ─── */
@media (max-width: 1024px) {
  .app-sidebar {
    display: none;
  }

  .app-ambient {
    display: none;
  }

  .app-topbar {
    display: flex;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: 56px;
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(139, 126, 200, 0.1);
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
    padding: 6px;
    border-radius: var(--radius-sm);
  }

  .topbar-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-family: var(--font-display);
    font-weight: 700;
    font-size: 0.95rem;
    color: var(--color-text-primary);
  }

  .topbar-logo-icon {
    width: 30px;
    height: 30px;
    border-radius: 8px;
    background: var(--gradient-cta);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .topbar-actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .topbar-bell {
    position: relative;
    background: none;
    border: none;
    color: var(--color-text-secondary);
    padding: 6px;
    cursor: pointer;
    border-radius: var(--radius-sm);
  }

  .topbar-badge {
    position: absolute;
    top: 0;
    right: -2px;
    background: var(--color-danger);
    color: white;
    font-size: 0.6rem;
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
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    z-index: 55;
  }

  .mobile-drawer {
    display: flex;
    flex-direction: column;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: 280px;
    background: rgba(255, 255, 255, 0.92);
    backdrop-filter: blur(24px);
    -webkit-backdrop-filter: blur(24px);
    z-index: 60;
    overflow-y: auto;
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
  }

  .mobile-drawer-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px;
  }

  .mobile-drawer-close {
    background: none;
    border: none;
    color: var(--color-text-muted);
    cursor: pointer;
    padding: 6px;
    border-radius: var(--radius-sm);
  }

  .mobile-greeting {
    padding: 0 20px 16px;
  }

  .mobile-drawer .sidebar-nav {
    flex: 1;
  }

  .mobile-drawer .sidebar-footer {
    border-top: 1px solid rgba(139, 126, 200, 0.08);
  }
}
</style>

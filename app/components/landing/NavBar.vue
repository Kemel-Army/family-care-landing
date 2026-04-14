<template>
  <header class="navbar" :class="{ scrolled: isScrolled }">
    <div class="navbar-inner landing-container">
      <!-- Logo -->
      <NuxtLink to="/" class="navbar-logo">
        <span class="logo-icon">
          <Icon name="lucide:heart-pulse" size="24" />
        </span>
        <span class="logo-text font-display">Family Care OS</span>
      </NuxtLink>

      <!-- Desktop Navigation — page tabs -->
      <nav class="navbar-tabs">
        <NuxtLink
          v-for="tab in tabs"
          :key="tab.to"
          :to="tab.to"
          class="nav-tab font-heading"
          :class="{ active: isActiveTab(tab.to) }"
        >
          {{ tab.label }}
        </NuxtLink>
      </nav>

      <!-- Auth + CTA -->
      <div class="navbar-actions">
        <NuxtLink to="/demo" class="navbar-demo font-heading">
          Попробовать демо
        </NuxtLink>
        <a href="#contact" class="navbar-cta font-heading">Обсудить подключение</a>
      </div>

      <!-- Mobile burger -->
      <button class="navbar-burger" @click="menuOpen = !menuOpen" :aria-label="menuOpen ? 'Закрыть меню' : 'Открыть меню'">
        <Icon :name="menuOpen ? 'lucide:x' : 'lucide:menu'" size="24" />
      </button>
    </div>

    <!-- Mobile menu -->
    <Transition name="mobile-menu">
      <div v-if="menuOpen" class="mobile-menu">
        <nav class="mobile-nav">
          <NuxtLink
            v-for="tab in tabs"
            :key="tab.to"
            :to="tab.to"
            class="mobile-link font-heading"
            :class="{ active: isActiveTab(tab.to) }"
            @click="menuOpen = false"
          >
            {{ tab.label }}
          </NuxtLink>
          <div class="mobile-auth">
            <NuxtLink to="/demo" class="mobile-auth-btn mobile-auth-login font-heading" @click="menuOpen = false">Попробовать демо</NuxtLink>
          </div>
          <a href="#contact" class="mobile-cta font-heading" @click="menuOpen = false">Обсудить подключение</a>
        </nav>
      </div>
    </Transition>

    <!-- Demo Modal removed — all demo links go to /demo directly -->
  </header>
</template>

<script setup lang="ts">
const route = useRoute()
const menuOpen = ref(false)
const isScrolled = ref(false)

const tabs = [
  { to: '/', label: 'Платформа' },
  { to: '/for-clinics', label: 'Для клиник' },
  { to: '/for-families', label: 'Для родителей' },
]

function isActiveTab(path: string) {
  return route.path === path
}

onMounted(() => {
  const onScroll = () => {
    isScrolled.value = window.scrollY > 100
  }
  window.addEventListener('scroll', onScroll, { passive: true })
  onUnmounted(() => window.removeEventListener('scroll', onScroll))
})
</script>

<style scoped>
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  padding: 16px 24px 0;
  transition:
    padding var(--transition-smooth);
}

.navbar.scrolled {
  padding-top: 8px;
}

.navbar-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1000px;
  margin: 0 auto;
  height: 56px;
  padding: 0 6px;
  border-radius: var(--radius-full);
  background: rgba(254, 252, 255, 0.72);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(139, 126, 200, 0.08);
  box-shadow: var(--shadow-lg);
  transition:
    height var(--transition-smooth),
    box-shadow var(--transition-smooth),
    background var(--transition-smooth);
}

.navbar.scrolled .navbar-inner {
  height: 48px;
  background: rgba(254, 252, 255, 0.92);
  box-shadow: var(--shadow-hover);
}

/* Logo */
.navbar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  color: var(--color-text-primary);
  flex-shrink: 0;
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  background: var(--gradient-cta);
  color: white;
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  letter-spacing: -0.02em;
}

/* Desktop tabs */
.navbar-tabs {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px;
  border-radius: var(--radius-full);
  background: rgba(139, 126, 200, 0.06);
}

.nav-tab {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-text-secondary);
  text-decoration: none;
  padding: 8px 20px;
  border-radius: var(--radius-full);
  transition: color var(--transition-fast), background var(--transition-fast);
  position: relative;
  white-space: nowrap;
}

.nav-tab:hover {
  color: var(--color-primary);
  background: rgba(139, 126, 200, 0.08);
}

.nav-tab.active {
  color: var(--color-primary);
  background: white;
  font-weight: 600;
  box-shadow: 0 1px 6px rgba(139, 126, 200, 0.15);
}

/* Auth + CTA group */
.navbar-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

/* Login link */
.navbar-login {
  padding: 8px 18px;
  border-radius: var(--radius-full);
  color: var(--color-primary);
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  transition: background var(--transition-fast), color var(--transition-fast);
  white-space: nowrap;
}

.navbar-login:hover {
  background: rgba(139, 126, 200, 0.08);
}

/* Demo button */
.navbar-demo {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 10px 20px;
  border-radius: var(--radius-full);
  border: 1px solid var(--color-primary);
  background: transparent;
  color: var(--color-primary);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
  white-space: nowrap;
}

.navbar-demo:hover {
  background: var(--color-primary-ultralight);
}

/* Mobile demo button */
.mobile-demo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-primary);
  background: transparent;
  color: var(--color-primary);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.mobile-demo:hover {
  background: var(--color-primary-ultralight);
}

/* CTA button */
.navbar-cta {
  padding: 10px 24px;
  border-radius: var(--radius-full);
  background: var(--gradient-cta);
  color: white;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  transition: opacity var(--transition-fast), transform var(--transition-fast);
  white-space: nowrap;
}

.navbar-cta:hover {
  opacity: 0.9;
  transform: scale(1.02);
}

/* Burger */
.navbar-burger {
  display: none;
  align-items: center;
  justify-content: center;
  padding: 8px;
  background: none;
  border: none;
  color: var(--color-text-primary);
  cursor: pointer;
  border-radius: var(--radius-sm);
  transition: background var(--transition-fast);
}

.navbar-burger:hover {
  background: var(--color-primary-light);
}

/* Mobile menu */
.mobile-menu {
  background: rgba(254, 252, 255, 0.97);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--color-border);
  padding: 16px 0;
  max-height: calc(100vh - 60px);
  overflow-y: auto;
}

.mobile-nav {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 0 var(--container-px);
}

.mobile-link {
  display: block;
  padding: 12px 16px;
  font-size: 16px;
  font-weight: 500;
  color: var(--color-text-secondary);
  text-decoration: none;
  border-radius: var(--radius-sm);
  transition: background var(--transition-fast), color var(--transition-fast);
}

.mobile-link:hover {
  background: var(--color-primary-ultralight);
  color: var(--color-primary);
}

.mobile-link.active {
  background: var(--color-primary-light);
  color: var(--color-primary);
  font-weight: 600;
}

/* Mobile auth buttons */
.mobile-auth {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}

.mobile-auth-btn {
  flex: 1;
  display: block;
  text-align: center;
  padding: 12px 16px;
  border-radius: var(--radius-sm);
  font-size: 15px;
  font-weight: 600;
  text-decoration: none;
  transition: background var(--transition-fast);
}

.mobile-auth-login {
  color: var(--color-primary);
  background: rgba(139, 126, 200, 0.08);
}

.mobile-auth-login:hover {
  background: rgba(139, 126, 200, 0.14);
}

.mobile-auth-register {
  color: white;
  background: var(--gradient-cta);
}

.mobile-auth-register:hover {
  opacity: 0.9;
}

.mobile-cta {
  display: block;
  text-align: center;
  margin-top: 8px;
  padding: 14px 24px;
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--color-primary);
  font-size: 15px;
  font-weight: 600;
  text-decoration: none;
  border: 1.5px solid rgba(139, 126, 200, 0.2);
}

/* Mobile menu transition */
.mobile-menu-enter-active,
.mobile-menu-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.mobile-menu-enter-from,
.mobile-menu-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

/* Responsive */
@media (max-width: 1024px) {
  .navbar-tabs {
    gap: 2px;
    padding: 3px;
  }

  .nav-tab {
    font-size: 13px;
    padding: 6px 14px;
  }

  .navbar-login {
    padding: 6px 14px;
    font-size: 13px;
  }

  .navbar-cta {
    padding: 8px 18px;
    font-size: 13px;
  }
}

@media (max-width: 768px) {
  .navbar-tabs,
  .navbar-actions {
    display: none;
  }

  .navbar-burger {
    display: flex;
  }

  .navbar {
    padding: 8px 12px 0;
  }

  .navbar-inner {
    max-width: 100%;
    height: 52px;
    padding: 0 12px 0 16px;
    border-radius: var(--radius-xl);
  }

  .navbar.scrolled .navbar-inner {
    height: 46px;
  }
}
</style>

<template>
  <div class="demo-layout">
    <!-- Demo banner -->
    <div class="demo-banner">
      <div class="demo-banner-inner">
        <Icon name="lucide:eye" size="16" />
        <span>Демо-режим — тестовые данные</span>
        <NuxtLink to="/for-clinics#clinic-cta" class="demo-banner-cta">
          Оставить заявку
          <Icon name="lucide:arrow-right" size="14" />
        </NuxtLink>
      </div>
    </div>

    <!-- Simplified topbar -->
    <header class="demo-topbar">
      <NuxtLink to="/" class="demo-logo">
        <div class="demo-logo-icon">
          <Icon name="lucide:heart-pulse" size="20" />
        </div>
        <span class="demo-logo-text">UMAI Health</span>
      </NuxtLink>

      <nav class="demo-nav">
        <NuxtLink
          v-for="tab in tabs"
          :key="tab.to"
          :to="tab.to"
          class="demo-tab"
          :class="{ active: route.path === tab.to }"
        >
          <Icon :name="tab.icon" size="18" />
          <span>{{ tab.label }}</span>
        </NuxtLink>
      </nav>

      <NuxtLink to="/" class="demo-back">
        <Icon name="lucide:arrow-left" size="16" />
        <span>На главную</span>
      </NuxtLink>
    </header>

    <!-- Content -->
    <main class="demo-main">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()

const tabs = [
  { to: '/demo/family', label: 'Приложение мамы', icon: 'lucide:heart' },
  { to: '/demo/coordinator', label: 'Координатор', icon: 'lucide:clipboard-list' },
  { to: '/demo/doctor', label: 'Врач', icon: 'lucide:stethoscope' },
]
</script>

<style scoped>
.demo-layout {
  min-height: 100vh;
  background: var(--color-bg);
  display: flex;
  flex-direction: column;
}

/* Demo banner */
.demo-banner {
  background: var(--gradient-cta);
  color: white;
  font-size: var(--text-sm);
  padding: 8px 16px;
  text-align: center;
}

.demo-banner-inner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  max-width: var(--container-max);
  margin: 0 auto;
}

.demo-banner-cta {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: white;
  font-weight: 600;
  text-decoration: none;
  padding: 4px 12px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.2);
  transition: background var(--transition-fast);
}

.demo-banner-cta:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* Topbar */
.demo-topbar {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 12px 24px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--color-border-light);
  position: sticky;
  top: 0;
  z-index: 50;
}

.demo-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  text-decoration: none;
  color: var(--color-text-primary);
  flex-shrink: 0;
}

.demo-logo-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  background: var(--gradient-cta);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
}

.demo-logo-text {
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 1rem;
}

.demo-nav {
  display: flex;
  gap: 4px;
  flex: 1;
  justify-content: center;
}

.demo-tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: var(--radius-sm);
  font-size: var(--text-sm);
  font-weight: 500;
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: all var(--transition-fast);
}

.demo-tab:hover {
  background: var(--color-primary-ultralight);
  color: var(--color-text-primary);
}

.demo-tab.active {
  background: var(--color-primary-light);
  color: var(--color-primary);
  font-weight: 600;
}

.demo-back {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--color-text-secondary);
  text-decoration: none;
  font-size: var(--text-sm);
  font-weight: 500;
  flex-shrink: 0;
  transition: color var(--transition-fast);
}

.demo-back:hover {
  color: var(--color-primary);
}

/* Main content */
.demo-main {
  flex: 1;
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

/* Responsive */
@media (max-width: 768px) {
  .demo-topbar {
    flex-wrap: wrap;
    gap: 12px;
    padding: 12px 16px;
  }

  .demo-nav {
    order: 3;
    width: 100%;
    overflow-x: auto;
    justify-content: flex-start;
    -webkit-overflow-scrolling: touch;
  }

  .demo-tab span {
    white-space: nowrap;
  }

  .demo-back span {
    display: none;
  }

  .demo-main {
    padding: 16px;
  }
}

@media (max-width: 480px) {
  .demo-logo-text {
    display: none;
  }
}
</style>

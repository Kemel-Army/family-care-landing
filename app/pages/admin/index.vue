<template>
  <div class="adm-page">
    <!-- Hero -->
    <div class="adm-hero">
      <h1 class="adm-hero-title">Администрирование</h1>
      <p class="adm-hero-sub">Центр управления клиникой</p>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid">
      <div v-for="k in kpis" :key="k.label" class="kpi-card">
        <div class="kpi-top">
          <span class="kpi-label">{{ k.label }}</span>
          <span class="kpi-trend" :class="k.trend > 0 ? 'up' : k.trend < 0 ? 'down' : ''">
            {{ k.trend > 0 ? '+' : '' }}{{ k.trend }}%
          </span>
        </div>
        <span class="kpi-value">{{ k.value }}</span>
        <svg class="kpi-spark" viewBox="0 0 56 20" fill="none">
          <polyline :points="k.sparkline" stroke="var(--color-primary)" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </div>
    </div>

    <!-- Nav Grid -->
    <div class="card">
      <h2 class="card-title">Управление</h2>
      <div class="nav-grid">
        <NuxtLink v-for="item in navItems" :key="item.to" :to="item.to" class="nav-item">
          <div class="nav-icon" :style="{ background: item.bg }">
            <Icon :name="item.icon" size="18" />
          </div>
          <div>
            <h3 class="nav-name">{{ item.name }}</h3>
            <p class="nav-desc">{{ item.desc }}</p>
          </div>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const kpis = computed(() => [
  { label: 'Пользователей', value: mock.adminKpi.totalUsers.value, trend: mock.adminKpi.totalUsers.trend, sparkline: mock.adminKpi.totalUsers.sparkline },
  { label: 'Активных семей', value: mock.adminKpi.activeFamilies.value, trend: mock.adminKpi.activeFamilies.trend, sparkline: mock.adminKpi.activeFamilies.sparkline },
  { label: 'Врачей', value: mock.adminKpi.totalDoctors.value, trend: mock.adminKpi.totalDoctors.trend, sparkline: mock.adminKpi.totalDoctors.sparkline },
  { label: 'Записей/мес', value: mock.adminKpi.monthlyAppointments.value, trend: mock.adminKpi.monthlyAppointments.trend, sparkline: mock.adminKpi.monthlyAppointments.sparkline },
])

const navItems = [
  { to: '/admin/users', icon: 'lucide:users', name: 'Пользователи', desc: 'Учётные записи', bg: 'rgba(139,126,200,0.1)' },
  { to: '/admin/analytics', icon: 'lucide:line-chart', name: 'Аналитика', desc: 'KPI и метрики', bg: 'rgba(168,200,232,0.12)' },
  { to: '/admin/templates', icon: 'lucide:clipboard-list', name: 'Шаблоны маршрутов', desc: 'Care-маршруты', bg: 'rgba(232,160,191,0.1)' },
  { to: '/admin/clinic', icon: 'lucide:building-2', name: 'Клиника', desc: 'Профиль и брендинг', bg: 'rgba(242,196,160,0.1)' },
  { to: '/admin/capacity', icon: 'lucide:bar-chart-3', name: 'Мощность', desc: 'Загрузка ресурсов', bg: 'rgba(168,200,232,0.12)' },
  { to: '/admin/compliance', icon: 'lucide:shield-check', name: 'Протоколы', desc: 'Соблюдение стандартов', bg: 'rgba(124,184,212,0.1)' },
  { to: '/admin/reputation', icon: 'lucide:star', name: 'Репутация', desc: 'NPS и отзывы', bg: 'rgba(233,196,106,0.1)' },
  { to: '/admin/packages', icon: 'lucide:package', name: 'Пакеты', desc: 'Сервисные пакеты', bg: 'rgba(139,126,200,0.1)' },
  { to: '/admin/outreach', icon: 'lucide:phone-call', name: 'Outreach', desc: 'CRM-рассылки', bg: 'rgba(232,160,191,0.1)' },
  { to: '/admin/integrations', icon: 'lucide:plug', name: 'Интеграции', desc: 'API и webhooks', bg: 'rgba(168,200,232,0.12)' },
  { to: '/admin/network', icon: 'lucide:globe', name: 'Сеть', desc: 'Филиалы', bg: 'rgba(242,196,160,0.1)' },
  { to: '/admin/training', icon: 'lucide:graduation-cap', name: 'Обучение', desc: 'Персонал', bg: 'rgba(124,184,212,0.1)' },
  { to: '/admin/settings', icon: 'lucide:settings', name: 'Настройки', desc: 'Рабочие часы и пр.', bg: 'rgba(139,126,200,0.1)' },
]
</script>

<style scoped>
.adm-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.adm-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 28px;
}
.adm-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.adm-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; }
.kpi-card {
  background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px;
  display: flex; flex-direction: column; gap: 4px; position: relative; overflow: hidden;
}
.kpi-top { display: flex; align-items: center; justify-content: space-between; }
.kpi-label { font-size: 0.72rem; color: var(--color-text-muted); font-weight: 500; }
.kpi-trend { font-size: 0.68rem; font-weight: 700; font-family: var(--font-mono); }
.kpi-trend.up { color: var(--color-success); }
.kpi-trend.down { color: var(--color-danger); }
.kpi-value { font-size: 1.5rem; font-weight: 800; font-family: var(--font-mono); }
.kpi-spark { width: 100%; height: 20px; margin-top: 4px; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; margin-bottom: 14px; }

.nav-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 8px; }
.nav-item {
  display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 12px;
  text-decoration: none; color: inherit; transition: background 0.15s;
}
.nav-item:hover { background: rgba(139,126,200,0.04); }
.nav-icon {
  width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center;
  justify-content: center; color: var(--color-primary); flex-shrink: 0;
}
.nav-name { font-size: 0.82rem; font-weight: 600; }
.nav-desc { font-size: 0.7rem; color: var(--color-text-muted); }
</style>

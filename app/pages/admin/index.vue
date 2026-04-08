<template>
  <div class="admin-dashboard">
    <header class="page-header">
      <h1 class="page-title">Администрирование</h1>
    </header>

    <!-- Stats Overview -->
    <div class="stats-grid">
      <div class="stat-card">
        <Icon name="lucide:users" size="22" class="stat-icon" />
        <div class="stat-value">{{ stats.total_users }}</div>
        <div class="stat-label">Пользователей</div>
      </div>
      <div class="stat-card">
        <Icon name="lucide:home" size="22" class="stat-icon" />
        <div class="stat-value">{{ stats.total_families }}</div>
        <div class="stat-label">Семей</div>
      </div>
      <div class="stat-card">
        <Icon name="lucide:stethoscope" size="22" class="stat-icon" />
        <div class="stat-value">{{ stats.total_doctors }}</div>
        <div class="stat-label">Врачей</div>
      </div>
      <div class="stat-card">
        <Icon name="lucide:calendar" size="22" class="stat-icon" />
        <div class="stat-value">{{ stats.total_appointments }}</div>
        <div class="stat-label">Записей</div>
      </div>
    </div>

    <!-- Management links -->
    <section class="section">
      <h2 class="section-title">Управление</h2>
      <div class="nav-grid">
        <NuxtLink to="/admin/users" class="nav-card">
          <Icon name="lucide:users" size="24" />
          <h3>Пользователи</h3>
          <p>Управление учётными записями</p>
        </NuxtLink>
        <NuxtLink to="/admin/templates" class="nav-card">
          <Icon name="lucide:clipboard-list" size="24" />
          <h3>Шаблоны маршрутов</h3>
          <p>Настройка шаблонов care-маршрутов</p>
        </NuxtLink>
        <NuxtLink to="/admin/clinic" class="nav-card">
          <Icon name="lucide:building-2" size="24" />
          <h3>Клиника</h3>
          <p>Профиль и настройки клиники</p>
        </NuxtLink>
        <NuxtLink to="/admin/analytics" class="nav-card">
          <Icon name="lucide:line-chart" size="24" />
          <h3>Аналитика</h3>
          <p>Дашборд метрик и KPI</p>
        </NuxtLink>
        <NuxtLink to="/admin/outreach" class="nav-card">
          <Icon name="lucide:phone-call" size="24" />
          <h3>Outreach</h3>
          <p>Сценарии и массовые рассылки</p>
        </NuxtLink>
        <NuxtLink to="/admin/settings" class="nav-card">
          <Icon name="lucide:settings" size="24" />
          <h3>Настройки</h3>
          <p>Рабочие часы, ссылки, параметры</p>
        </NuxtLink>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const stats = reactive({
  total_users: 0,
  total_families: 0,
  total_doctors: 0,
  total_appointments: 0,
})

onMounted(async () => {
  const clinicId = authStore.clinicId
  if (!clinicId) return

  const [users, families, doctors, appointments] = await Promise.all([
    supabase.from('users').select('id', { count: 'exact', head: true }).eq('clinic_id', clinicId),
    supabase.from('families').select('id', { count: 'exact', head: true }).eq('clinic_id', clinicId),
    supabase.from('doctors').select('id', { count: 'exact', head: true }).eq('clinic_id', clinicId),
    supabase.from('appointments').select('id', { count: 'exact', head: true }).eq('clinic_id', clinicId),
  ])

  stats.total_users = users.count || 0
  stats.total_families = families.count || 0
  stats.total_doctors = doctors.count || 0
  stats.total_appointments = appointments.count || 0
})
</script>

<style scoped>
.admin-dashboard { max-width: 900px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.35rem; font-weight: 700; }

.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin-bottom: 28px; }
.stat-card {
  display: flex; flex-direction: column; align-items: center; padding: 18px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md); text-align: center;
}
.stat-icon { color: var(--color-primary); margin-bottom: 8px; }
.stat-value { font-size: 1.5rem; font-weight: 700; font-family: var(--font-mono); }
.stat-label { font-size: 0.75rem; color: var(--color-text-secondary); margin-top: 2px; }

.section { margin-bottom: 28px; }
.section-title { font-size: 1rem; font-weight: 600; margin-bottom: 16px; }

.nav-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; }
.nav-card {
  padding: 20px; background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md); text-decoration: none; color: inherit;
  transition: all var(--transition-fast); display: flex; flex-direction: column; gap: 8px;
}
.nav-card:hover { box-shadow: var(--shadow-sm); border-color: var(--color-primary-light); }
.nav-card h3 { font-size: 0.95rem; font-weight: 600; }
.nav-card p { font-size: 0.8rem; color: var(--color-text-secondary); }
</style>

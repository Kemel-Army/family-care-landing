<template>
  <div class="doctor-dashboard">
    <header class="page-header">
      <h1 class="page-title">Панель врача</h1>
      <p class="page-subtitle">{{ authStore.fullName }}</p>
    </header>

    <!-- Today's stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <Icon name="lucide:calendar" size="20" class="stat-icon" />
        <div class="stat-value">{{ todayAppointments.length }}</div>
        <div class="stat-label">Записей сегодня</div>
      </div>
      <div class="stat-card">
        <Icon name="lucide:users" size="20" class="stat-icon" />
        <div class="stat-value">{{ patients.length }}</div>
        <div class="stat-label">Пациентов</div>
      </div>
    </div>

    <!-- Today's schedule -->
    <section class="section">
      <h2 class="section-title">Расписание на сегодня</h2>
      <div v-if="todayAppointments.length" class="schedule-list">
        <div v-for="apt in todayAppointments" :key="apt.id" class="schedule-card">
          <div class="time-block">
            <span class="time">{{ apt.start_time?.slice(0, 5) }}</span>
          </div>
          <div class="schedule-content">
            <h3>{{ apt.patient_name || 'Пациент' }}</h3>
            <p>{{ apt.reason || 'Плановый приём' }}</p>
          </div>
          <NuxtLink :to="`/doctor/patients/${apt.family_id}`" class="view-btn">
            <Icon name="lucide:eye" size="16" />
          </NuxtLink>
        </div>
      </div>
      <div v-else class="empty-mini">Нет записей на сегодня</div>
    </section>

    <!-- Quick links -->
    <div class="quick-links">
      <NuxtLink to="/doctor/patients" class="quick-link">
        <Icon name="lucide:users" size="20" />
        <span>Все пациенты</span>
        <Icon name="lucide:chevron-right" size="16" />
      </NuxtLink>
      <NuxtLink to="/doctor/schedule" class="quick-link">
        <Icon name="lucide:calendar" size="20" />
        <span>Управление расписанием</span>
        <Icon name="lucide:chevron-right" size="16" />
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'

definePageMeta({ layout: 'app' })

const authStore = useAuthStore()
const supabase = useSupabaseClient()

const todayAppointments = ref<Array<Record<string, unknown>>>([])
const patients = ref<Array<Record<string, unknown>>>([])

onMounted(async () => {
  const today = dayjs().format('YYYY-MM-DD')

  // Fetch today's appointments for this doctor
  const { data: apts } = await supabase
    .from('appointments')
    .select('*, family:families(id, primary_parent:users!families_primary_parent_id_fkey(first_name, last_name))')
    .eq('doctor_id', authStore.profile?.id)
    .eq('appointment_date', today)
    .order('start_time')

  todayAppointments.value = (apts || []).map(a => {
    const parent = (a.family as Record<string, unknown>)?.primary_parent as Record<string, unknown> | null
    return { ...a, patient_name: parent ? `${parent.first_name || ''} ${parent.last_name || ''}`.trim() : null }
  })

  // Fetch distinct patients
  const { data: pts } = await supabase
    .from('appointments')
    .select('family_id')
    .eq('doctor_id', authStore.profile?.id)

  const uniqueFamilies = [...new Set((pts || []).map(p => p.family_id))]
  patients.value = uniqueFamilies.map(id => ({ id }))
})
</script>

<style scoped>
.doctor-dashboard { max-width: 900px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.35rem; font-weight: 700; }
.page-subtitle { font-size: 0.9rem; color: var(--color-text-secondary); margin-top: 4px; }

.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin-bottom: 28px; }
.stat-card {
  display: flex; flex-direction: column; align-items: center; padding: 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md); text-align: center;
}
.stat-icon { color: var(--color-primary); margin-bottom: 8px; }
.stat-value { font-size: 1.5rem; font-weight: 700; font-family: var(--font-mono); }
.stat-label { font-size: 0.75rem; color: var(--color-text-secondary); margin-top: 2px; }

.section { margin-bottom: 28px; }
.section-title { font-size: 1rem; font-weight: 600; margin-bottom: 12px; }

.schedule-list { display: flex; flex-direction: column; gap: 8px; }
.schedule-card {
  display: flex; align-items: center; gap: 14px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm);
}

.time-block { flex-shrink: 0; }
.time { font-size: 1rem; font-weight: 700; color: var(--color-primary); font-family: var(--font-mono); }

.schedule-content { flex: 1; }
.schedule-content h3 { font-size: 0.9rem; font-weight: 600; }
.schedule-content p { font-size: 0.8rem; color: var(--color-text-secondary); }

.view-btn { color: var(--color-text-muted); text-decoration: none; }

.empty-mini { text-align: center; padding: 24px; color: var(--color-text-muted); font-size: 0.85rem; }

.quick-links { display: flex; flex-direction: column; gap: 8px; }
.quick-link {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); text-decoration: none; color: inherit;
  transition: all var(--transition-fast);
}
.quick-link:hover { box-shadow: var(--shadow-sm); }
.quick-link span { flex: 1; font-weight: 500; }
</style>

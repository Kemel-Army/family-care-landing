<template>
  <div class="outreach-page">
    <header class="page-header">
      <NuxtLink to="/coordinator" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Назад
      </NuxtLink>
      <h1 class="page-title">Outreach-сценарии</h1>
      <button class="btn-add" @click="showCreate = true">
        <Icon name="lucide:plus" size="16" /> Новый сценарий
      </button>
    </header>

    <!-- Stats -->
    <div class="stats-row">
      <div class="stat-pill">
        <Icon name="lucide:zap" size="14" />
        <span>Активных: <strong>{{ activeScenarios.length }}</strong></span>
      </div>
      <div class="stat-pill">
        <Icon name="lucide:send" size="14" />
        <span>Отправлено: <strong>{{ totalSent }}</strong></span>
      </div>
      <div class="stat-pill">
        <Icon name="lucide:target" size="14" />
        <span>Конверсия: <strong>{{ conversionRate }}%</strong></span>
      </div>
    </div>

    <!-- Scenarios list -->
    <section v-if="loading" class="loading-state">
      <Icon name="lucide:loader-2" size="24" class="spinner" />
      <span>Загрузка...</span>
    </section>

    <section v-else-if="scenarios.length" class="scenarios-list">
      <div
        v-for="scenario in scenarios"
        :key="scenario.id"
        class="scenario-card"
        :class="{ inactive: !scenario.is_active }"
      >
        <div class="scenario-header">
          <div class="scenario-info">
            <h3>{{ scenario.name }}</h3>
            <span class="scenario-trigger">{{ describeTrigger(scenario.trigger_json) }}</span>
          </div>
          <div class="scenario-toggle">
            <button
              class="toggle-btn"
              :class="{ active: scenario.is_active }"
              @click="toggleScenario(scenario)"
            >
              {{ scenario.is_active ? 'Активен' : 'Выключен' }}
            </button>
          </div>
        </div>

        <div class="scenario-actions">
          <div v-for="action in parseActions(scenario.actions_json)" :key="action.type" class="action-badge">
            <Icon :name="channelIcon(action.type)" size="12" />
            {{ channelLabel(action.type) }}
          </div>
        </div>

        <div class="scenario-stats">
          <span>Отправлено: {{ scenarioLogStats(scenario.id).sent }}</span>
          <span>Доставлено: {{ scenarioLogStats(scenario.id).delivered }}</span>
          <span>Конвертировано: {{ scenarioLogStats(scenario.id).converted }}</span>
        </div>
      </div>
    </section>

    <div v-else class="empty-state">
      <Icon name="lucide:phone-call" size="40" class="empty-icon" />
      <h3>Нет сценариев</h3>
      <p>Создайте первый outreach-сценарий для автоматизации коммуникаций</p>
    </div>

    <!-- Recent logs -->
    <section v-if="logs.length" class="section">
      <h2 class="section-title">Последние отправки</h2>
      <div class="logs-list">
        <div v-for="log in recentLogs" :key="log.id" class="log-row">
          <span class="log-status" :class="log.status" />
          <div class="log-content">
            <span class="log-scenario">{{ scenarioName(log.scenario_id) }}</span>
            <span class="log-result">{{ log.result || '-' }}</span>
          </div>
          <span class="log-date">{{ formatDate(log.sent_at || log.created_at) }}</span>
        </div>
      </div>
    </section>

    <!-- Create modal -->
    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal">
          <div class="modal-header">
            <h2>Новый outreach-сценарий</h2>
            <button class="modal-close" @click="showCreate = false">
              <Icon name="lucide:x" size="18" />
            </button>
          </div>

          <form class="modal-form" @submit.prevent="createScenario">
            <div class="form-group">
              <label>Название</label>
              <input v-model="form.name" type="text" required placeholder="Напоминание о визите" />
            </div>

            <div class="form-group">
              <label>Триггер</label>
              <select v-model="form.triggerEvent" required>
                <option value="" disabled>Выберите событие</option>
                <option value="appointment_upcoming">Приближающийся приём</option>
                <option value="dose_missed">Пропущен приём лекарства</option>
                <option value="no_login">Неактивность</option>
                <option value="appointment_completed">Приём завершён</option>
                <option value="family_registered">Новая семья</option>
              </select>
            </div>

            <div class="form-group">
              <label>Дней / часов</label>
              <input v-model.number="form.triggerDelay" type="number" min="0" placeholder="1" />
            </div>

            <div class="form-group">
              <label>Каналы</label>
              <div class="channels-grid">
                <label v-for="ch in channelOptions" :key="ch.value" class="channel-checkbox">
                  <input v-model="form.channels" type="checkbox" :value="ch.value" />
                  <Icon :name="ch.icon" size="14" />
                  {{ ch.label }}
                </label>
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="showCreate = false">Отмена</button>
              <button type="submit" class="btn-submit" :disabled="creating">
                {{ creating ? 'Создание...' : 'Создать' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const scenarios = ref<any[]>([])
const logs = ref<any[]>([])
const loading = ref(true)
const showCreate = ref(false)
const creating = ref(false)

const form = reactive({
  name: '',
  triggerEvent: '',
  triggerDelay: 1,
  channels: [] as string[],
})

const channelOptions = [
  { value: 'sms', label: 'SMS', icon: 'lucide:message-square' },
  { value: 'push', label: 'Push', icon: 'lucide:bell' },
  { value: 'email', label: 'Email', icon: 'lucide:mail' },
  { value: 'whatsapp', label: 'WhatsApp', icon: 'lucide:phone' },
]

const activeScenarios = computed(() => scenarios.value.filter(s => s.is_active))

const totalSent = computed(() =>
  logs.value.filter(l => l.status !== 'pending').length
)

const conversionRate = computed(() => {
  if (!logs.value.length) return 0
  const converted = logs.value.filter(l => l.status === 'converted').length
  return Math.round((converted / logs.value.length) * 100)
})

const recentLogs = computed(() => logs.value.slice(0, 20))

function scenarioLogStats(scenarioId: string) {
  const scenarioLogs = logs.value.filter(l => l.scenario_id === scenarioId)
  return {
    sent: scenarioLogs.filter(l => ['sent', 'delivered', 'opened', 'converted'].includes(l.status)).length,
    delivered: scenarioLogs.filter(l => ['delivered', 'opened', 'converted'].includes(l.status)).length,
    converted: scenarioLogs.filter(l => l.status === 'converted').length,
  }
}

function scenarioName(id: string) {
  return scenarios.value.find(s => s.id === id)?.name || '—'
}

function describeTrigger(trigger: any) {
  const t = typeof trigger === 'string' ? JSON.parse(trigger) : trigger
  const eventLabels: Record<string, string> = {
    appointment_upcoming: 'Приближающийся приём',
    dose_missed: 'Пропущен приём лекарства',
    no_login: 'Неактивность',
    appointment_completed: 'Приём завершён',
    family_registered: 'Регистрация семьи',
  }
  const eventLabel = eventLabels[t.event] || t.event
  const delay = t.days_before ? `за ${t.days_before} дн.`
    : t.hours_after ? `через ${t.hours_after} ч.`
    : t.days_after ? `через ${t.days_after} дн.`
    : ''
  return `${eventLabel} ${delay}`.trim()
}

function parseActions(actions: any): { type: string; template: string }[] {
  if (typeof actions === 'string') return JSON.parse(actions)
  return actions || []
}

function channelIcon(type: string) {
  const map: Record<string, string> = {
    sms: 'lucide:message-square',
    push: 'lucide:bell',
    email: 'lucide:mail',
    whatsapp: 'lucide:phone',
  }
  return map[type] || 'lucide:send'
}

function channelLabel(type: string) {
  const map: Record<string, string> = { sms: 'SMS', push: 'Push', email: 'Email', whatsapp: 'WhatsApp' }
  return map[type] || type
}

function formatDate(date: string | null) {
  if (!date) return '—'
  return new Date(date).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short' })
}

async function fetchData() {
  if (!authStore.clinicId) return
  loading.value = true

  const [scenariosRes, logsRes] = await Promise.all([
    supabase
      .from('outreach_scenarios')
      .select('*')
      .eq('clinic_id', authStore.clinicId)
      .order('created_at', { ascending: false }),
    supabase
      .from('outreach_logs')
      .select('*, outreach_scenarios!inner(clinic_id)')
      .eq('outreach_scenarios.clinic_id', authStore.clinicId)
      .order('created_at', { ascending: false })
      .limit(100),
  ])

  if (scenariosRes.data) scenarios.value = scenariosRes.data
  if (logsRes.data) logs.value = logsRes.data

  loading.value = false
}

async function toggleScenario(scenario: any) {
  const { error } = await supabase
    .from('outreach_scenarios')
    .update({ is_active: !scenario.is_active })
    .eq('id', scenario.id)

  if (!error) scenario.is_active = !scenario.is_active
}

async function createScenario() {
  if (!authStore.clinicId || !form.name || !form.triggerEvent) return
  creating.value = true

  const delayKey = ['appointment_upcoming'].includes(form.triggerEvent) ? 'days_before'
    : ['no_login'].includes(form.triggerEvent) ? 'days_after'
    : 'hours_after'

  const { error } = await supabase.from('outreach_scenarios').insert({
    clinic_id: authStore.clinicId,
    name: form.name,
    trigger_json: { event: form.triggerEvent, [delayKey]: form.triggerDelay },
    actions_json: form.channels.map(ch => ({ type: ch, template: `${form.triggerEvent}_${ch}` })),
    is_active: true,
  })

  if (!error) {
    showCreate.value = false
    form.name = ''
    form.triggerEvent = ''
    form.triggerDelay = 1
    form.channels = []
    await fetchData()
  }

  creating.value = false
}

onMounted(fetchData)
</script>

<style scoped>
.outreach-page { max-width: 900px; margin: 0 auto; padding: 24px 16px; }

.page-header { display: flex; flex-wrap: wrap; align-items: center; gap: 12px; margin-bottom: 20px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; flex: 1; }
.btn-add {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: var(--color-primary); color: #fff; border: none; border-radius: var(--radius-sm);
  font-size: 0.85rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}

.stats-row { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 20px; }
.stat-pill {
  display: flex; align-items: center; gap: 6px; padding: 6px 14px;
  background: var(--color-primary-ultralight); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-full); font-size: 0.8rem; color: var(--color-text-secondary);
}
.stat-pill strong { color: var(--color-text-primary); }

/* Scenarios */
.scenarios-list { display: flex; flex-direction: column; gap: 10px; margin-bottom: 28px; }
.scenario-card {
  padding: 16px; background: var(--color-surface);
  border: 1px solid var(--color-border-light); border-radius: var(--radius-sm);
}
.scenario-card.inactive { opacity: 0.6; }

.scenario-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }
.scenario-info h3 { font-size: 0.95rem; font-weight: 600; }
.scenario-trigger { font-size: 0.8rem; color: var(--color-text-secondary); }

.toggle-btn {
  padding: 4px 12px; border-radius: var(--radius-full); font-size: 0.75rem; font-weight: 600;
  border: 1px solid var(--color-border); background: var(--color-surface); cursor: pointer;
  color: var(--color-text-muted); font-family: var(--font-body);
}
.toggle-btn.active { border-color: var(--color-success); color: var(--color-success); background: rgba(124, 184, 212, 0.08); }

.scenario-actions { display: flex; gap: 6px; margin-top: 10px; }
.action-badge {
  display: flex; align-items: center; gap: 4px; padding: 3px 10px;
  background: var(--color-primary-ultralight); border-radius: var(--radius-full);
  font-size: 0.7rem; color: var(--color-primary); font-weight: 500;
}

.scenario-stats { display: flex; gap: 16px; margin-top: 10px; font-size: 0.75rem; color: var(--color-text-muted); }

/* Logs */
.section { margin-top: 28px; }
.section-title { font-family: var(--font-display); font-size: 1rem; font-weight: 600; margin-bottom: 12px; }

.logs-list { display: flex; flex-direction: column; gap: 4px; }
.log-row {
  display: flex; align-items: center; gap: 10px; padding: 8px 12px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); font-size: 0.8rem;
}
.log-status { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.log-status.sent { background: var(--color-accent-blue); }
.log-status.delivered { background: var(--color-success); }
.log-status.opened { background: var(--color-warning); }
.log-status.converted { background: var(--color-primary); }
.log-status.failed { background: var(--color-danger); }
.log-status.pending { background: var(--color-text-muted); }

.log-content { flex: 1; display: flex; flex-direction: column; }
.log-scenario { font-weight: 500; }
.log-result { font-size: 0.75rem; color: var(--color-text-muted); }
.log-date { font-size: 0.75rem; color: var(--color-text-muted); flex-shrink: 0; }

/* Empty */
.empty-state { text-align: center; padding: 48px; color: var(--color-text-muted); }
.empty-state h3 { font-size: 1rem; margin-top: 8px; color: var(--color-text-primary); }
.empty-state p { font-size: 0.85rem; margin-top: 4px; }
.empty-icon { color: var(--color-primary-light); }

/* Loading */
.loading-state { text-align: center; padding: 48px; color: var(--color-text-muted); font-size: 0.9rem; }
.spinner { animation: spin 1s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

/* Modal */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex;
  align-items: center; justify-content: center; z-index: 1000; padding: 16px;
}
.modal {
  background: var(--color-surface); border-radius: var(--radius-md);
  width: 100%; max-width: 480px; box-shadow: var(--shadow-lg);
}
.modal-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 16px 20px; border-bottom: 1px solid var(--color-border-light);
}
.modal-header h2 { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.modal-close { background: none; border: none; cursor: pointer; color: var(--color-text-muted); padding: 4px; }

.modal-form { padding: 20px; }
.form-group { margin-bottom: 16px; }
.form-group label { display: block; font-size: 0.8rem; font-weight: 600; margin-bottom: 6px; color: var(--color-text-secondary); }
.form-group input, .form-group select {
  width: 100%; padding: 10px 12px; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body);
  background: var(--color-bg); color: var(--color-text-primary);
}
.form-group input:focus, .form-group select:focus { outline: none; border-color: var(--color-primary); }

.channels-grid { display: flex; flex-wrap: wrap; gap: 8px; }
.channel-checkbox {
  display: flex; align-items: center; gap: 4px; padding: 6px 12px;
  border: 1px solid var(--color-border-light); border-radius: var(--radius-sm);
  font-size: 0.8rem; cursor: pointer;
}
.channel-checkbox input { width: 14px; height: 14px; accent-color: var(--color-primary); }

.modal-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 20px; }
.btn-cancel {
  padding: 8px 16px; background: transparent; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); font-size: 0.85rem; cursor: pointer;
  font-family: var(--font-body); color: var(--color-text-secondary);
}
.btn-submit {
  padding: 8px 20px; background: var(--color-primary); color: #fff; border: none;
  border-radius: var(--radius-sm); font-size: 0.85rem; font-weight: 600;
  cursor: pointer; font-family: var(--font-body);
}
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }
</style>

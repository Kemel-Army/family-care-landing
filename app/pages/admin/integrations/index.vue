<template>
  <div class="integrations-page">
    <header class="page-header">
      <h1 class="page-title">Интеграции</h1>
    </header>

    <!-- Available integrations -->
    <div class="integrations-grid">
      <div v-for="intg in integrations" :key="intg.id" class="intg-card" :class="{ connected: intg.is_active }">
        <div class="intg-header">
          <div class="intg-icon">
            <Icon :name="intg.icon" size="24" />
          </div>
          <span v-if="intg.is_active" class="intg-badge connected">Подключено</span>
          <span v-else class="intg-badge">Доступно</span>
        </div>
        <h3>{{ intg.name }}</h3>
        <p>{{ intg.description }}</p>
        <div v-if="intg.is_active" class="intg-status">
          <span>Последняя синхронизация: {{ intg.last_sync || '—' }}</span>
        </div>
        <button
          class="intg-btn"
          :class="intg.is_active ? 'btn-disconnect' : 'btn-connect'"
          @click="toggleIntegration(intg)"
        >
          {{ intg.is_active ? 'Отключить' : 'Подключить' }}
        </button>
      </div>
    </div>

    <!-- Webhooks section -->
    <section class="section">
      <div class="section-header">
        <h2 class="section-title">Webhooks</h2>
        <button class="btn-add" @click="showWebhook = true">
          <Icon name="lucide:plus" size="14" /> Добавить
        </button>
      </div>
      <div v-if="webhooks.length" class="webhook-list">
        <div v-for="wh in webhooks" :key="wh.id" class="webhook-row">
          <div class="wh-event">{{ wh.event }}</div>
          <div class="wh-url">{{ wh.url }}</div>
          <button class="wh-delete" @click="deleteWebhook(wh.id)">
            <Icon name="lucide:trash-2" size="14" />
          </button>
        </div>
      </div>
      <p v-else class="empty-hint">Нет добавленных webhooks</p>
    </section>

    <!-- Webhook modal -->
    <Teleport to="body">
      <div v-if="showWebhook" class="modal-overlay" @click.self="showWebhook = false">
        <div class="modal-card">
          <h2>Новый Webhook</h2>
          <div class="form-group">
            <label class="form-label">Событие</label>
            <select v-model="whForm.event" class="form-input">
              <option value="appointment.created">Запись создана</option>
              <option value="appointment.completed">Запись завершена</option>
              <option value="journey.completed">Маршрут завершён</option>
              <option value="sos.triggered">SOS активирован</option>
              <option value="family.created">Семья создана</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">URL</label>
            <input v-model="whForm.url" type="url" class="form-input" placeholder="https://..." />
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showWebhook = false">Отмена</button>
            <button class="btn-submit" @click="addWebhook">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const showWebhook = ref(false)
const whForm = reactive({ event: 'appointment.created', url: '' })

interface IntegrationItem { id: string; name: string; description: string; icon: string; is_active: boolean; last_sync: string | null }

const integrations = ref<IntegrationItem[]>([
  { id: '1c', name: '1С:Бухгалтерия', description: 'Синхронизация финансовых данных с 1С', icon: 'lucide:database', is_active: false, last_sync: null },
  { id: 'olymp', name: 'Лаборатория Олимп', description: 'Автоматический импорт результатов анализов', icon: 'lucide:test-tube', is_active: false, last_sync: null },
  { id: 'whatsapp', name: 'WhatsApp Business', description: 'Отправка уведомлений через WhatsApp', icon: 'lucide:message-circle', is_active: false, last_sync: null },
  { id: 'sms', name: 'SMS (Mobizon)', description: 'SMS-рассылки и напоминания', icon: 'lucide:smartphone', is_active: false, last_sync: null },
  { id: 'email', name: 'Email (Resend)', description: 'Транзакционные и маркетинговые письма', icon: 'lucide:mail', is_active: false, last_sync: null },
  { id: '2gis', name: '2GIS', description: 'Геолокация и навигация для пациентов', icon: 'lucide:map-pin', is_active: false, last_sync: null },
])

const webhooks = ref<Array<{ id: string; event: string; url: string }>>([])

async function toggleIntegration(intg: IntegrationItem) {
  const newStatus = !intg.is_active
  if (!authStore.clinicId) return

  await supabase.from('integrations').upsert({
    clinic_id: authStore.clinicId,
    provider: intg.id,
    type: 'custom',
    sync_status: newStatus ? 'active' : 'inactive',
  }, { onConflict: 'clinic_id,provider' })

  intg.is_active = newStatus
}

async function addWebhook() {
  if (!authStore.clinicId || !whForm.url) return
  const { data } = await supabase.from('webhooks').insert({
    clinic_id: authStore.clinicId,
    event: whForm.event,
    url: whForm.url,
  }).select().single()

  if (data) webhooks.value.push(data as { id: string; event: string; url: string })
  showWebhook.value = false
  whForm.url = ''
}

async function deleteWebhook(id: string) {
  await supabase.from('webhooks').delete().eq('id', id)
  webhooks.value = webhooks.value.filter(w => w.id !== id)
}

onMounted(async () => {
  if (!authStore.clinicId) return

  // Load active integrations
  const { data: active } = await supabase
    .from('integrations')
    .select('*')
    .eq('clinic_id', authStore.clinicId)

  for (const row of (active || []) as Array<Record<string, unknown>>) {
    const intg = integrations.value.find(i => i.id === row.provider)
    if (intg) {
      intg.is_active = Boolean(row.is_active)
      intg.last_sync = row.last_sync_at ? new Date(row.last_sync_at as string).toLocaleString('ru-RU') : null
    }
  }

  // Load webhooks
  const { data: wh } = await supabase
    .from('webhooks')
    .select('*')
    .eq('clinic_id', authStore.clinicId)

  webhooks.value = (wh || []) as Array<{ id: string; event: string; url: string }>
})
</script>

<style scoped>
.integrations-page { max-width: 900px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.integrations-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 14px; margin-bottom: 32px; }
.intg-card { padding: 20px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); display: flex; flex-direction: column; gap: 8px; }
.intg-card.connected { border-color: rgba(124, 184, 212, 0.3); }
.intg-header { display: flex; align-items: center; justify-content: space-between; }
.intg-icon { width: 40px; height: 40px; border-radius: 10px; background: var(--color-primary-ultralight); color: var(--color-primary); display: flex; align-items: center; justify-content: center; }
.intg-badge { font-size: 0.7rem; padding: 2px 8px; border-radius: 10px; background: var(--color-border-light); color: var(--color-text-secondary); }
.intg-badge.connected { background: rgba(124, 184, 212, 0.15); color: var(--color-success); }
.intg-card h3 { font-size: 0.95rem; font-weight: 600; }
.intg-card p { font-size: 0.8rem; color: var(--color-text-secondary); }
.intg-status { font-size: 0.75rem; color: var(--color-text-muted); }

.intg-btn { padding: 8px; border-radius: var(--radius-sm); font-size: 0.8rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); width: 100%; }
.btn-connect { background: var(--gradient-cta); color: white; border: none; }
.btn-disconnect { background: none; border: 1px solid var(--color-border); color: var(--color-text-secondary); }

.section { margin-bottom: 28px; }
.section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.section-title { font-size: 1rem; font-weight: 600; }
.btn-add { display: flex; align-items: center; gap: 4px; padding: 6px 14px; background: var(--color-primary-ultralight); color: var(--color-primary); border: 1px solid var(--color-primary); border-radius: var(--radius-sm); font-size: 0.8rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); }

.webhook-list { display: flex; flex-direction: column; gap: 6px; }
.webhook-row { display: flex; align-items: center; gap: 12px; padding: 10px 14px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-sm); }
.wh-event { font-size: 0.8rem; font-weight: 600; min-width: 160px; color: var(--color-primary); }
.wh-url { flex: 1; font-size: 0.8rem; color: var(--color-text-secondary); font-family: var(--font-mono); overflow: hidden; text-overflow: ellipsis; }
.wh-delete { border: none; background: none; color: var(--color-text-muted); cursor: pointer; padding: 4px; border-radius: 4px; }
.wh-delete:hover { color: var(--color-danger); }

.empty-hint { font-size: 0.85rem; color: var(--color-text-muted); }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: var(--color-surface); border-radius: var(--radius-md); padding: 24px; width: 100%; max-width: 440px; display: flex; flex-direction: column; gap: 14px; }
.modal-card h2 { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.85rem; font-weight: 600; }
.form-input { padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body); outline: none; }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border); border-radius: var(--radius-sm); cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

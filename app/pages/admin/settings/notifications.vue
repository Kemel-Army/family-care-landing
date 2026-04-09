<template>
  <div class="notif-page">
    <div class="notif-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Настройки</NuxtLink>
      <h1 class="hero-title">Уведомления</h1>
      <p class="hero-sub">Каналы доставки и автоматические триггеры</p>
    </div>

    <!-- Channels -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:radio" size="16" /> Каналы доставки</h2>
      <div class="channel-list">
        <div v-for="ch in channels" :key="ch.key" class="channel-row">
          <Icon :name="ch.icon" size="18" class="channel-icon" />
          <div class="channel-info">
            <h3 class="channel-name">{{ ch.label }}</h3>
            <p class="channel-desc">{{ ch.desc }}</p>
          </div>
          <label class="toggle">
            <input v-model="ch.enabled" type="checkbox" />
            <span class="toggle-track" />
          </label>
        </div>
      </div>
    </div>

    <!-- Triggers -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:zap" size="16" /> Автоматические триггеры</h2>
      <div class="trigger-list">
        <div v-for="tr in triggers" :key="tr.key" class="trigger-row">
          <div class="trigger-info">
            <h3 class="trigger-name">{{ tr.label }}</h3>
            <p class="trigger-desc">{{ tr.desc }}</p>
          </div>
          <div class="trigger-controls">
            <select v-model="tr.channel" class="trigger-select">
              <option value="in_app">In-app</option>
              <option value="push">Push</option>
              <option value="whatsapp">WhatsApp</option>
              <option value="sms">SMS</option>
              <option value="email">Email</option>
            </select>
            <label class="toggle">
              <input v-model="tr.enabled" type="checkbox" />
              <span class="toggle-track" />
            </label>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:history" size="16" /> Последние уведомления</h2>
      <div v-if="loading" class="loading-row"><Icon name="lucide:loader-2" size="18" class="spin" /> Загрузка…</div>
      <div v-else-if="recent.length" class="recent-list">
        <div v-for="n in recent" :key="n.id" class="recent-row">
          <span class="recent-channel" :class="n.channel">{{ n.channel }}</span>
          <div class="recent-info">
            <span class="recent-title">{{ n.title }}</span>
            <span class="recent-body">{{ n.body }}</span>
          </div>
          <span class="recent-status" :class="n.status">{{ statusLabel(n.status) }}</span>
          <span class="recent-time">{{ formatTime(n.created_at) }}</span>
        </div>
      </div>
      <p v-else class="empty-hint">Нет отправленных уведомлений</p>
    </div>

    <button class="btn-save" @click="saved = true"><Icon name="lucide:save" size="16" /> Сохранить</button>
    <span v-if="saved" class="saved-msg">✓ Настройки сохранены</span>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const sb = useSupabaseClient()
const loading = ref(true)
const saved = ref(false)

const channels = reactive([
  { key: 'in_app', label: 'In-app', desc: 'Уведомления внутри приложения', icon: 'lucide:bell', enabled: true },
  { key: 'push', label: 'Push', desc: 'Браузерные push-уведомления', icon: 'lucide:smartphone', enabled: true },
  { key: 'whatsapp', label: 'WhatsApp', desc: 'Сообщения через WhatsApp Business API', icon: 'lucide:message-circle', enabled: false },
  { key: 'sms', label: 'SMS', desc: 'Текстовые сообщения', icon: 'lucide:phone', enabled: false },
  { key: 'email', label: 'Email', desc: 'Электронная почта', icon: 'lucide:mail', enabled: true },
])

const triggers = reactive([
  { key: 'appointment_reminder', label: 'Напоминание о визите', desc: 'За 24 ч и за 1 ч до визита', channel: 'push', enabled: true },
  { key: 'dose_reminder', label: 'Напоминание о приёме', desc: 'В назначенное время приёма лекарства', channel: 'push', enabled: true },
  { key: 'overdue_event', label: 'Просроченное событие', desc: 'Когда событие маршрута просрочено', channel: 'in_app', enabled: true },
  { key: 'vaccination_due', label: 'Вакцинация', desc: 'За 7 дней до плановой вакцинации', channel: 'whatsapp', enabled: true },
  { key: 'low_adherence', label: 'Низкий adherence', desc: 'Когда adherence падает ниже 50%', channel: 'in_app', enabled: true },
  { key: 'epds_alert', label: 'EPDS алерт', desc: 'Когда скрининг показывает высокий риск', channel: 'push', enabled: true },
  { key: 'welcome', label: 'Приветствие', desc: 'Приветственное сообщение новой семье', channel: 'email', enabled: true },
  { key: 'missed_appointment', label: 'Неявка', desc: 'Уведомление координатору при неявке', channel: 'in_app', enabled: true },
])

interface RecentNotif { id: string; channel: string; title: string; body: string; status: string; created_at: string }
const recent = ref<RecentNotif[]>([])

function statusLabel(s: string) {
  return { pending: 'Ожидает', sent: 'Отправлено', delivered: 'Доставлено', read: 'Прочитано', failed: 'Ошибка' }[s] || s
}

function formatTime(dt: string) {
  return new Date(dt).toLocaleDateString('ru-RU', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
}

onMounted(async () => {
  const { data } = await sb.from('notifications').select('id, channel, title, body, status, created_at').order('created_at', { ascending: false }).limit(20)
  recent.value = data || []
  loading.value = false
})
</script>

<style scoped>
.notif-page { max-width: 700px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }
.notif-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.92rem; font-weight: 600; display: flex; align-items: center; gap: 6px; margin-bottom: 16px; }

/* Channels */
.channel-list { display: flex; flex-direction: column; gap: 4px; }
.channel-row { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--color-border-light); }
.channel-row:last-child { border-bottom: none; }
.channel-icon { color: var(--color-primary); flex-shrink: 0; }
.channel-info { flex: 1; }
.channel-name { font-size: 0.88rem; font-weight: 600; }
.channel-desc { font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }

/* Toggle */
.toggle { position: relative; display: inline-block; width: 40px; height: 22px; flex-shrink: 0; }
.toggle input { opacity: 0; width: 0; height: 0; }
.toggle-track {
  position: absolute; inset: 0; background: var(--color-border-light); border-radius: 11px; cursor: pointer; transition: background 0.2s;
}
.toggle-track::before {
  content: ''; position: absolute; width: 16px; height: 16px; border-radius: 50%; background: white; top: 3px; left: 3px; transition: transform 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.15);
}
.toggle input:checked + .toggle-track { background: var(--color-primary); }
.toggle input:checked + .toggle-track::before { transform: translateX(18px); }

/* Triggers */
.trigger-list { display: flex; flex-direction: column; gap: 4px; }
.trigger-row { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--color-border-light); }
.trigger-row:last-child { border-bottom: none; }
.trigger-info { flex: 1; }
.trigger-name { font-size: 0.88rem; font-weight: 600; }
.trigger-desc { font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }
.trigger-controls { display: flex; align-items: center; gap: 10px; }
.trigger-select {
  padding: 4px 8px; border: 1px solid var(--color-border-light); border-radius: 8px;
  font-size: 0.72rem; font-family: var(--font-body); outline: none; background: white;
}

/* Recent */
.recent-list { display: flex; flex-direction: column; gap: 2px; }
.recent-row { display: flex; align-items: center; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--color-border-light); }
.recent-row:last-child { border-bottom: none; }
.recent-channel { font-size: 0.62rem; font-weight: 600; padding: 2px 6px; border-radius: 6px; text-transform: uppercase; }
.recent-channel.push { background: rgba(139,126,200,0.12); color: var(--color-primary); }
.recent-channel.in_app { background: rgba(100,180,120,0.12); color: #4a9960; }
.recent-channel.email { background: rgba(232,184,77,0.12); color: #b08a2a; }
.recent-channel.whatsapp { background: rgba(37,211,102,0.12); color: #128c7e; }
.recent-channel.sms { background: rgba(150,150,150,0.12); color: #888; }
.recent-info { flex: 1; min-width: 0; }
.recent-title { font-size: 0.82rem; font-weight: 600; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.recent-body { font-size: 0.72rem; color: var(--color-text-muted); display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.recent-status { font-size: 0.62rem; font-weight: 600; }
.recent-status.delivered, .recent-status.read { color: #4a9960; }
.recent-status.sent { color: var(--color-primary); }
.recent-status.pending { color: #b08a2a; }
.recent-status.failed { color: #d94f4f; }
.recent-time { font-size: 0.68rem; color: var(--color-text-muted); white-space: nowrap; }
.empty-hint { font-size: 0.82rem; color: var(--color-text-muted); text-align: center; padding: 20px; }
.loading-row { display: flex; align-items: center; gap: 8px; justify-content: center; padding: 20px; color: var(--color-text-muted); font-size: 0.88rem; }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.btn-save {
  display: flex; align-items: center; gap: 6px; padding: 10px 20px; border-radius: 12px;
  background: var(--color-primary); color: white; font-size: 0.88rem; font-weight: 600; font-family: var(--font-body);
  border: none; cursor: pointer; transition: opacity 0.2s; align-self: flex-start;
}
.btn-save:hover { opacity: 0.9; }
.saved-msg { font-size: 0.82rem; color: #4a9960; align-self: flex-start; }
</style>

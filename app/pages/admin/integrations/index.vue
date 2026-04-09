<template>
  <div class="intg-page">
    <div class="intg-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="hero-title">Интеграции</h1>
      <p class="hero-sub">Внешние сервисы и webhooks</p>
    </div>

    <!-- Integrations grid -->
    <div class="intg-grid">
      <div v-for="intg in integrations" :key="intg.id" class="intg-card" :class="{ connected: intg.active }">
        <div class="intg-top">
          <div class="intg-icon"><Icon :name="intg.icon" size="22" /></div>
          <span class="intg-badge" :class="{ on: intg.active }">{{ intg.active ? 'Подключено' : 'Доступно' }}</span>
        </div>
        <h3>{{ intg.name }}</h3>
        <p class="intg-desc">{{ intg.desc }}</p>
        <span v-if="intg.active" class="intg-sync">Синхронизация: {{ intg.lastSync }}</span>
        <button class="intg-btn" :class="intg.active ? 'off' : 'on'" @click="intg.active = !intg.active">
          {{ intg.active ? 'Отключить' : 'Подключить' }}
        </button>
      </div>
    </div>

    <!-- Webhooks -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:webhook" size="16" /> Webhooks</h2>
        <button class="btn-add" @click="showWh = true"><Icon name="lucide:plus" size="14" /> Добавить</button>
      </div>
      <div v-if="webhooks.length" class="wh-list">
        <div v-for="(wh, i) in webhooks" :key="i" class="wh-row">
          <span class="wh-event">{{ wh.event }}</span>
          <span class="wh-url">{{ wh.url }}</span>
          <button class="wh-del" @click="webhooks.splice(i, 1)"><Icon name="lucide:trash-2" size="14" /></button>
        </div>
      </div>
      <p v-else class="empty-hint">Нет webhooks</p>
    </div>

    <!-- Webhook modal -->
    <Teleport to="body">
      <div v-if="showWh" class="modal-overlay" @click.self="showWh = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый Webhook</h2>
          <div class="fg"><label class="fl">Событие</label>
            <select v-model="whForm.event" class="fi">
              <option value="appointment.created">Запись создана</option>
              <option value="appointment.completed">Запись завершена</option>
              <option value="journey.completed">Маршрут завершён</option>
              <option value="sos.triggered">SOS активирован</option>
            </select>
          </div>
          <div class="fg"><label class="fl">URL</label>
            <input v-model="whForm.url" class="fi" placeholder="https://..." />
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showWh = false">Отмена</button>
            <button class="btn-submit" @click="addWh">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showWh = ref(false)
const whForm = reactive({ event: 'appointment.created', url: '' })

const integrations = reactive([
  { id: '1c', name: '1С:Бухгалтерия', desc: 'Синхронизация финансовых данных', icon: 'lucide:database', active: true, lastSync: '12:45' },
  { id: 'olymp', name: 'Лаборатория Олимп', desc: 'Автоимпорт результатов анализов', icon: 'lucide:test-tube', active: false, lastSync: '—' },
  { id: 'wa', name: 'WhatsApp Business', desc: 'Уведомления через WhatsApp', icon: 'lucide:message-circle', active: true, lastSync: '09:30' },
  { id: 'sms', name: 'SMS (Mobizon)', desc: 'SMS-рассылки и напоминания', icon: 'lucide:smartphone', active: false, lastSync: '—' },
  { id: 'email', name: 'Email (Resend)', desc: 'Транзакционные письма', icon: 'lucide:mail', active: true, lastSync: '08:00' },
  { id: '2gis', name: '2GIS', desc: 'Геолокация для пациентов', icon: 'lucide:map-pin', active: false, lastSync: '—' },
])

const webhooks = reactive([
  { event: 'appointment.created', url: 'https://api.example.com/hooks/apt' },
])

function addWh() {
  if (!whForm.url) return
  webhooks.push({ event: whForm.event, url: whForm.url })
  showWh.value = false
  whForm.url = ''
}
</script>

<style scoped>
.intg-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.intg-hero {
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.intg-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 12px; }
.intg-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px; display: flex; flex-direction: column; gap: 6px; }
.intg-card.connected { border-color: rgba(124,184,212,0.3); }
.intg-top { display: flex; align-items: center; justify-content: space-between; }
.intg-icon { width: 40px; height: 40px; border-radius: 10px; background: rgba(139,126,200,0.08); color: var(--color-primary); display: flex; align-items: center; justify-content: center; }
.intg-badge { font-size: 0.65rem; padding: 2px 8px; border-radius: 10px; background: var(--color-border-light); color: var(--color-text-muted); }
.intg-badge.on { background: rgba(124,184,212,0.15); color: var(--color-success); }
.intg-card h3 { font-size: 0.92rem; font-weight: 600; }
.intg-desc { font-size: 0.78rem; color: var(--color-text-muted); }
.intg-sync { font-size: 0.68rem; color: var(--color-text-muted); }
.intg-btn { padding: 8px; border-radius: 10px; font-size: 0.8rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); width: 100%; margin-top: auto; }
.intg-btn.on { background: var(--gradient-cta); color: white; border: none; }
.intg-btn.off { background: none; border: 1px solid var(--color-border-light); color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.btn-add { display: flex; align-items: center; gap: 4px; padding: 6px 14px; background: rgba(139,126,200,0.08); color: var(--color-primary); border: 1px solid var(--color-primary); border-radius: 10px; font-size: 0.78rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); }

.wh-list { display: flex; flex-direction: column; gap: 6px; }
.wh-row { display: flex; align-items: center; gap: 12px; padding: 10px 14px; background: rgba(0,0,0,0.01); border-radius: 10px; }
.wh-event { font-size: 0.78rem; font-weight: 600; min-width: 150px; color: var(--color-primary); }
.wh-url { flex: 1; font-size: 0.78rem; color: var(--color-text-muted); font-family: var(--font-mono); overflow: hidden; text-overflow: ellipsis; }
.wh-del { border: none; background: none; color: var(--color-text-muted); cursor: pointer; padding: 4px; border-radius: 4px; }
.wh-del:hover { color: var(--color-danger); }
.empty-hint { font-size: 0.82rem; color: var(--color-text-muted); }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 440px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

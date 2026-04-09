<template>
  <div class="out-page">
    <div class="out-hero">
      <NuxtLink to="/coordinator" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Outreach-сценарии</h1>
          <p class="hero-sub">Автоматизация коммуникаций с семьями</p>
        </div>
        <button class="btn-create" @click="showCreate = true"><Icon name="lucide:plus" size="14" /> Новый сценарий</button>
      </div>
      <div class="stat-chips">
        <span class="chip"><Icon name="lucide:zap" size="14" /> Активных: <strong>{{ activeCount }}</strong></span>
        <span class="chip"><Icon name="lucide:send" size="14" /> Отправлено: <strong>847</strong></span>
        <span class="chip"><Icon name="lucide:target" size="14" /> Конверсия: <strong>24%</strong></span>
      </div>
    </div>

    <!-- Scenarios -->
    <div class="scn-list">
      <div v-for="s in scenarios" :key="s.id" class="scn-card" :class="{ inactive: !s.active }">
        <div class="scn-top">
          <div>
            <h3>{{ s.name }}</h3>
            <span class="scn-trigger">{{ s.trigger }}</span>
          </div>
          <button class="toggle-btn" :class="{ on: s.active }" @click="s.active = !s.active">{{ s.active ? 'Активен' : 'Выключен' }}</button>
        </div>
        <div class="scn-channels">
          <span v-for="ch in s.channels" :key="ch" class="ch-badge"><Icon :name="chIcon(ch)" size="12" /> {{ ch }}</span>
        </div>
        <div class="scn-stats">
          <span>Отправлено: {{ s.sent }}</span>
          <span>Доставлено: {{ s.delivered }}</span>
          <span>Конвертировано: {{ s.converted }}</span>
        </div>
      </div>
    </div>

    <!-- Recent logs -->
    <div class="card">
      <h2 class="card-title">Последние отправки</h2>
      <div class="log-list">
        <div v-for="l in logs" :key="l.id" class="log-row">
          <span class="log-dot" :class="l.status" />
          <div class="log-body">
            <span class="log-name">{{ l.scenario }}</span>
            <span class="log-result">{{ l.result }}</span>
          </div>
          <span class="log-date">{{ l.date }}</span>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый сценарий</h2>
          <div class="fg"><label class="fl">Название</label><input v-model="form.name" class="fi" placeholder="Напоминание о визите" /></div>
          <div class="fg">
            <label class="fl">Триггер</label>
            <select v-model="form.trigger" class="fi">
              <option value="appointment_upcoming">Приближающийся приём</option>
              <option value="dose_missed">Пропущен приём лекарства</option>
              <option value="no_login">Неактивность</option>
              <option value="appointment_completed">Приём завершён</option>
            </select>
          </div>
          <div class="fg">
            <label class="fl">Каналы</label>
            <div class="ch-grid">
              <label v-for="ch in channelOptions" :key="ch.value" class="ch-check">
                <input v-model="form.channels" type="checkbox" :value="ch.value" />
                <Icon :name="ch.icon" size="14" /> {{ ch.label }}
              </label>
            </div>
          </div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showCreate = false">Отмена</button>
            <button class="btn-submit" @click="showCreate = false">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showCreate = ref(false)
const form = reactive({ name: '', trigger: 'appointment_upcoming', channels: [] as string[] })

const channelOptions = [
  { value: 'SMS', label: 'SMS', icon: 'lucide:message-square' },
  { value: 'Push', label: 'Push', icon: 'lucide:bell' },
  { value: 'Email', label: 'Email', icon: 'lucide:mail' },
  { value: 'WhatsApp', label: 'WhatsApp', icon: 'lucide:phone' },
]

const chIcon = (ch: string) => ({ SMS: 'lucide:message-square', Push: 'lucide:bell', Email: 'lucide:mail', WhatsApp: 'lucide:phone' }[ch] || 'lucide:send')

const scenarios = reactive([
  { id: 1, name: 'Напоминание о визите', trigger: 'За 24ч до приёма', active: true, channels: ['SMS', 'Push'], sent: 312, delivered: 298, converted: 87 },
  { id: 2, name: 'Реактивация', trigger: 'Неактивность 14 дней', active: true, channels: ['WhatsApp', 'Email'], sent: 156, delivered: 142, converted: 34 },
  { id: 3, name: 'Пропущен приём лекарства', trigger: 'Через 2ч после пропуска', active: true, channels: ['Push'], sent: 248, delivered: 245, converted: 189 },
  { id: 4, name: 'Приветствие новой семьи', trigger: 'При регистрации', active: false, channels: ['Email', 'SMS'], sent: 131, delivered: 128, converted: 45 },
])

const activeCount = computed(() => scenarios.filter(s => s.active).length)

const logs = [
  { id: 1, scenario: 'Напоминание о визите', result: 'Доставлено — Айгуль М.', status: 'delivered', date: '12 мая' },
  { id: 2, scenario: 'Реактивация', result: 'Открыто — Динара К.', status: 'opened', date: '12 мая' },
  { id: 3, scenario: 'Пропущен приём', result: 'Конвертировано — Марат Т.', status: 'converted', date: '11 мая' },
  { id: 4, scenario: 'Напоминание о визите', result: 'Ошибка доставки', status: 'failed', date: '11 мая' },
  { id: 5, scenario: 'Приветствие', result: 'Доставлено — Сауле Б.', status: 'delivered', date: '10 мая' },
]
</script>

<style scoped>
.out-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.out-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(168,200,232,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.btn-create { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }
.stat-chips { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 14px; }
.chip { display: flex; align-items: center; gap: 5px; padding: 4px 12px; background: rgba(139,126,200,0.06); border-radius: 20px; font-size: 0.75rem; color: var(--color-text-muted); }
.chip strong { color: var(--color-text); }

.scn-list { display: flex; flex-direction: column; gap: 10px; }
.scn-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px; }
.scn-card.inactive { opacity: 0.55; }
.scn-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }
.scn-top h3 { font-size: 0.92rem; font-weight: 700; }
.scn-trigger { font-size: 0.78rem; color: var(--color-text-muted); }
.toggle-btn { padding: 4px 12px; border-radius: 20px; font-size: 0.72rem; font-weight: 600; border: 1px solid var(--color-border-light); background: white; cursor: pointer; color: var(--color-text-muted); font-family: var(--font-body); }
.toggle-btn.on { border-color: var(--color-success); color: var(--color-success); background: rgba(124,184,212,0.06); }

.scn-channels { display: flex; gap: 5px; margin-top: 8px; }
.ch-badge { display: flex; align-items: center; gap: 3px; padding: 2px 8px; background: rgba(139,126,200,0.06); border-radius: 12px; font-size: 0.68rem; color: var(--color-primary); font-weight: 500; }
.scn-stats { display: flex; gap: 14px; margin-top: 8px; font-size: 0.72rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.95rem; font-weight: 700; margin-bottom: 12px; }

.log-list { display: flex; flex-direction: column; gap: 4px; }
.log-row { display: flex; align-items: center; gap: 10px; padding: 8px 10px; border-radius: 8px; font-size: 0.78rem; }
.log-row:hover { background: rgba(139,126,200,0.03); }
.log-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.log-dot.delivered { background: var(--color-success); }
.log-dot.opened { background: var(--color-warning); }
.log-dot.converted { background: var(--color-primary); }
.log-dot.failed { background: var(--color-danger); }
.log-body { flex: 1; display: flex; flex-direction: column; }
.log-name { font-weight: 600; }
.log-result { font-size: 0.72rem; color: var(--color-text-muted); }
.log-date { font-size: 0.72rem; color: var(--color-text-muted); flex-shrink: 0; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 480px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; background: white; }
.fi:focus { border-color: var(--color-primary); }
.ch-grid { display: flex; flex-wrap: wrap; gap: 6px; }
.ch-check { display: flex; align-items: center; gap: 4px; padding: 5px 10px; border: 1px solid var(--color-border-light); border-radius: 8px; font-size: 0.78rem; cursor: pointer; }
.ch-check input { accent-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

<template>
  <div class="out-page">
    <div class="out-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <div class="hero-row">
        <div>
          <h1 class="hero-title">Outreach & CRM</h1>
          <p class="hero-sub">Автоматические сценарии рассылок</p>
        </div>
        <button class="btn-create" @click="showCreate = true"><Icon name="lucide:plus" size="14" /> Новый сценарий</button>
      </div>
    </div>

    <div class="sc-list">
      <div v-for="sc in scenarios" :key="sc.id" class="sc-card">
        <div class="sc-top">
          <div class="sc-dot" :class="sc.active ? 'on' : 'off'" />
          <span class="sc-name">{{ sc.name }}</span>
          <span class="sc-badge">{{ sc.trigger }}</span>
        </div>
        <p class="sc-desc">{{ sc.desc }}</p>
        <div class="sc-stats">
          <span><strong>{{ sc.sent }}</strong> отправлено</span>
          <span><strong>{{ sc.openRate }}%</strong> открыто</span>
          <span><strong>{{ sc.convRate }}%</strong> конверсия</span>
        </div>
        <div class="sc-actions">
          <button class="btn-sm" @click="sc.active = !sc.active">{{ sc.active ? 'Пауза' : 'Запуск' }}</button>
          <button class="btn-sm alt">Подробнее</button>
        </div>
      </div>
    </div>

    <div v-if="!scenarios.length" class="empty-state">
      <Icon name="lucide:mail" size="40" />
      <p>Создайте первый сценарий</p>
    </div>

    <Teleport to="body">
      <div v-if="showCreate" class="modal-overlay" @click.self="showCreate = false">
        <div class="modal-card">
          <h2 class="modal-title">Новый сценарий</h2>
          <div class="fg"><label class="fl">Название</label><input v-model="form.name" class="fi" placeholder="Реактивация 30 дней" /></div>
          <div class="fg"><label class="fl">Триггер</label>
            <select v-model="form.trigger" class="fi">
              <option value="inactivity">Неактивность</option>
              <option value="event_due">Приближение события</option>
              <option value="missed">Пропуск приёма</option>
              <option value="low_adherence">Низкая приверженность</option>
              <option value="birthday">День рождения</option>
            </select>
          </div>
          <div class="fg"><label class="fl">Канал</label>
            <select v-model="form.channel" class="fi">
              <option value="push">Push</option>
              <option value="whatsapp">WhatsApp</option>
              <option value="sms">SMS</option>
              <option value="email">Email</option>
            </select>
          </div>
          <div class="fg"><label class="fl">Текст</label><textarea v-model="form.message" rows="3" class="fi" placeholder="Здравствуйте, {name}!" /></div>
          <div class="modal-actions">
            <button class="btn-cancel" @click="showCreate = false">Отмена</button>
            <button class="btn-submit" @click="addScenario">Создать</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const showCreate = ref(false)
const form = reactive({ name: '', trigger: 'inactivity', channel: 'push', message: '' })

const scenarios = reactive([
  { id: 1, name: 'Реактивация после 14 дней', desc: 'Напоминание неактивным пользователям', trigger: 'inactivity', active: true, sent: 186, openRate: 62, convRate: 18 },
  { id: 2, name: 'Напоминание о визите', desc: 'За 24ч до приёма', trigger: 'event_due', active: true, sent: 342, openRate: 85, convRate: 94 },
  { id: 3, name: 'Пропущенный приём', desc: 'Через 2ч после пропуска', trigger: 'missed', active: false, sent: 47, openRate: 71, convRate: 38 },
])

function addScenario() {
  if (!form.name) return
  scenarios.push({ id: Date.now(), name: form.name, desc: form.message, trigger: form.trigger, active: true, sent: 0, openRate: 0, convRate: 0 })
  showCreate.value = false
  form.name = ''; form.message = ''
}
</script>

<style scoped>
.out-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.out-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.btn-create { display: flex; align-items: center; gap: 6px; padding: 9px 18px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; font-size: 0.82rem; cursor: pointer; font-family: var(--font-body); }

.sc-list { display: flex; flex-direction: column; gap: 12px; }
.sc-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px; }
.sc-top { display: flex; align-items: center; gap: 10px; margin-bottom: 6px; }
.sc-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.sc-dot.on { background: var(--color-success); }
.sc-dot.off { background: var(--color-text-muted); }
.sc-name { flex: 1; font-size: 0.92rem; font-weight: 600; }
.sc-badge { padding: 2px 8px; background: rgba(139,126,200,0.08); color: var(--color-primary); border-radius: 10px; font-size: 0.68rem; font-weight: 600; }
.sc-desc { font-size: 0.82rem; color: var(--color-text-muted); margin-bottom: 10px; }

.sc-stats { display: flex; gap: 16px; margin-bottom: 10px; font-size: 0.78rem; color: var(--color-text-muted); }
.sc-stats strong { color: var(--color-text-primary); font-family: var(--font-mono); }

.sc-actions { display: flex; gap: 8px; }
.btn-sm { padding: 6px 14px; background: white; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.78rem; cursor: pointer; font-family: var(--font-body); }
.btn-sm.alt { background: rgba(139,126,200,0.06); color: var(--color-primary); border-color: var(--color-primary); }

.empty-state { text-align: center; padding: 48px; color: var(--color-text-muted); }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 24px; width: 100%; max-width: 480px; display: flex; flex-direction: column; gap: 14px; }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; resize: vertical; }
.fi:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 16px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); }
.btn-submit { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); }
</style>

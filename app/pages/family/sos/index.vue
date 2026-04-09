<template>
  <div class="sos-page">
    <header class="page-header">
      <h1 class="page-title">SOS помощь</h1>
    </header>

    <!-- SOS Button -->
    <section class="sos-hero">
      <button class="sos-button" :class="{ active: sosActive }" @click="triggerSOS">
        <Icon name="lucide:phone" size="32" />
        <span>SOS</span>
      </button>
      <p class="sos-hint">Нажмите в экстренной ситуации</p>
    </section>

    <!-- Triage questions (shown after SOS press) -->
    <section v-if="sosActive && !triageComplete" class="triage-section">
      <h2 class="section-title">Что случилось?</h2>
      <div class="triage-options">
        <button
          v-for="opt in triageOptions"
          :key="opt.value"
          class="triage-btn"
          :class="{ selected: selectedTriage === opt.value }"
          @click="selectedTriage = opt.value"
        >
          <Icon :name="opt.icon" size="20" />
          <span>{{ opt.label }}</span>
        </button>
      </div>
      <button v-if="selectedTriage" class="btn-send-sos" :disabled="sending" @click="sendSOS">
        {{ sending ? 'Отправка...' : 'Отправить SOS' }}
      </button>
    </section>

    <!-- Confirmation -->
    <section v-if="triageComplete" class="confirmation-section">
      <div class="confirm-card">
        <Icon name="lucide:check-circle" size="40" class="confirm-icon" />
        <h2>SOS отправлен</h2>
        <p>Ваш координатор получил уведомление и свяжется с вами в ближайшее время.</p>
        <div class="contact-info">
          <p v-if="triageResult === 'emergency'"><strong>Скорая помощь: 103</strong></p>
          <p v-if="triageResult === 'urgent'"><strong>Горячая линия: +7 (700) 000-00-00</strong></p>
        </div>
        <button class="btn-reset" @click="resetSOS">OK</button>
      </div>
    </section>

    <!-- Emergency contacts -->
    <section class="section">
      <h2 class="section-title">Экстренные контакты</h2>
      <div class="contact-list">
        <a href="tel:103" class="contact-card">
          <Icon name="lucide:phone" size="20" class="contact-icon danger" />
          <div>
            <h3>Скорая помощь</h3>
            <p>103</p>
          </div>
        </a>
        <a href="tel:150" class="contact-card">
          <Icon name="lucide:heart" size="20" class="contact-icon" />
          <div>
            <h3>Горячая линия психологической помощи</h3>
            <p>150</p>
          </div>
        </a>
      </div>
    </section>

    <!-- SOS History -->
    <section v-if="sosHistory.length" class="section">
      <h2 class="section-title">История обращений</h2>
      <div class="history-list">
        <div v-for="entry in sosHistory" :key="entry.id" class="history-card">
          <div class="history-indicator" :class="entry.triage_result" />
          <div class="history-content">
            <h3>{{ entry.reason }}</h3>
            <p>{{ formatDateTime(entry.created_at) }}</p>
          </div>
          <span class="history-status">{{ entry.status }}</span>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { formatDateTime } from '~/utils/formatters'
import type { SOSEvent } from '~/types/database'

definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const userId = useSupabaseUserId()
const authStore = useAuthStore()

const sosActive = ref(false)
const triageComplete = ref(false)
const selectedTriage = ref('')
const triageResult = ref('')
const sending = ref(false)
const sosHistory = ref<SOSEvent[]>([])

const triageOptions = [
  { value: 'bleeding', label: 'Кровотечение', icon: 'lucide:droplet' },
  { value: 'pain', label: 'Сильная боль', icon: 'lucide:alert-triangle' },
  { value: 'fever', label: 'Высокая температура', icon: 'lucide:thermometer' },
  { value: 'breathing', label: 'Проблемы с дыханием', icon: 'lucide:wind' },
  { value: 'mental', label: 'Психологический кризис', icon: 'lucide:heart' },
  { value: 'other', label: 'Другое', icon: 'lucide:help-circle' },
]

function triggerSOS() {
  sosActive.value = true
}

async function sendSOS() {
  if (!user.value || !selectedTriage.value) return
  sending.value = true

  // Determine triage result
  const emergencyReasons = ['bleeding', 'breathing']
  triageResult.value = emergencyReasons.includes(selectedTriage.value) ? 'emergency' : 'urgent'

  try {
    await supabase.from('sos_events').insert({
      user_id: userId.value,
      family_id: authStore.familyId,
      reason: triageOptions.find(o => o.value === selectedTriage.value)?.label || selectedTriage.value,
      triage_result: triageResult.value,
      status: 'open',
    })

    triageComplete.value = true
  }
  finally { sending.value = false }
}

function resetSOS() {
  sosActive.value = false
  triageComplete.value = false
  selectedTriage.value = ''
  triageResult.value = ''
}

onMounted(async () => {
  if (!user.value) return
  const { data } = await supabase
    .from('sos_events')
    .select('*')
    .eq('user_id', userId.value)
    .order('created_at', { ascending: false })
    .limit(10)

  sosHistory.value = (data as SOSEvent[]) || []
})
</script>

<style scoped>
.sos-page { max-width: 640px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 20px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.sos-hero { text-align: center; padding: 32px 0 24px; }
.sos-button {
  width: 120px; height: 120px; border-radius: 50%; border: 3px solid var(--color-danger);
  background: rgba(231, 111, 81, 0.1); color: var(--color-danger);
  display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px;
  margin: 0 auto; cursor: pointer; font-family: var(--font-body); font-size: 1.1rem; font-weight: 700;
  transition: all 0.3s ease;
}
.sos-button:hover { background: rgba(231, 111, 81, 0.2); transform: scale(1.05); }
.sos-button.active { background: var(--color-danger); color: white; animation: pulse 1.5s infinite; }
.sos-hint { font-size: 0.85rem; color: var(--color-text-muted); margin-top: 12px; }

@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(231, 111, 81, 0.4); }
  50% { box-shadow: 0 0 0 15px rgba(231, 111, 81, 0); }
}

.triage-section { margin-bottom: 24px; }
.section { margin-bottom: 24px; }
.section-title { font-size: 1rem; font-weight: 600; margin-bottom: 12px; }

.triage-options { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; margin-bottom: 16px; }
.triage-btn {
  display: flex; align-items: center; gap: 8px; padding: 14px; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); background: var(--color-surface); cursor: pointer;
  font-family: var(--font-body); font-size: 0.85rem; text-align: left;
}
.triage-btn:hover { border-color: var(--color-danger); }
.triage-btn.selected { border-color: var(--color-danger); background: rgba(231, 111, 81, 0.05); color: var(--color-danger); }

.btn-send-sos {
  width: 100%; padding: 14px; background: var(--color-danger); color: white; border: none;
  border-radius: var(--radius-sm); font-size: 1rem; font-weight: 700; cursor: pointer; font-family: var(--font-body);
}
.btn-send-sos:disabled { opacity: 0.6; }

.confirmation-section { text-align: center; }
.confirm-card { padding: 32px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); }
.confirm-icon { color: var(--color-success); margin-bottom: 12px; }
.confirm-card h2 { font-family: var(--font-display); font-size: 1.2rem; margin-bottom: 8px; }
.confirm-card p { font-size: 0.9rem; color: var(--color-text-secondary); }
.contact-info { margin: 16px 0; }
.contact-info p { font-size: 1rem; }
.btn-reset { padding: 10px 24px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body); }

.contact-list { display: flex; flex-direction: column; gap: 8px; }
.contact-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); text-decoration: none; color: inherit;
}
.contact-icon { color: var(--color-primary); }
.contact-icon.danger { color: var(--color-danger); }
.contact-card h3 { font-size: 0.9rem; font-weight: 600; }
.contact-card p { font-size: 0.85rem; color: var(--color-text-secondary); }

.history-list { display: flex; flex-direction: column; gap: 6px; }
.history-card { display: flex; align-items: center; gap: 10px; padding: 10px 14px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-sm); }
.history-indicator { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.history-indicator.emergency { background: var(--color-danger); }
.history-indicator.urgent { background: var(--color-warning); }
.history-content { flex: 1; }
.history-content h3 { font-size: 0.85rem; font-weight: 600; }
.history-content p { font-size: 0.75rem; color: var(--color-text-muted); }
.history-status { font-size: 0.75rem; color: var(--color-text-secondary); }
</style>

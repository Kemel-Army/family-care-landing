<template>
  <div class="booking-page">
    <header class="page-header">
      <NuxtLink to="/family/appointments" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Назад
      </NuxtLink>
      <h1 class="page-title">Запись к врачу</h1>
    </header>

    <!-- Step 1: Select Doctor -->
    <section v-if="step === 1" class="booking-step">
      <h2 class="step-title">Выберите специалиста</h2>
      <div v-if="doctors.length" class="doctor-grid">
        <button
          v-for="doc in doctors"
          :key="doc.id"
          class="doctor-card"
          :class="{ selected: selectedDoctor?.id === doc.id }"
          @click="selectedDoctor = doc; step = 2"
        >
          <div class="doctor-avatar">
            <Icon name="lucide:user" size="24" />
          </div>
          <div class="doctor-info">
            <h3>{{ doc.user?.first_name }} {{ doc.user?.last_name }}</h3>
            <span>{{ doc.specialty }}</span>
          </div>
          <Icon name="lucide:chevron-right" size="16" class="doctor-arrow" />
        </button>
      </div>
      <div v-else class="empty-state">
        <p>Нет доступных специалистов</p>
      </div>
    </section>

    <!-- Step 2: Select Date & Slot -->
    <section v-if="step === 2" class="booking-step">
      <h2 class="step-title">Выберите дату и время</h2>
      <p class="step-doctor">{{ selectedDoctor?.specialty }} — {{ selectedDoctor?.user?.first_name }} {{ selectedDoctor?.user?.last_name }}</p>

      <div class="date-picker">
        <button
          v-for="d in availableDates"
          :key="d"
          class="date-btn"
          :class="{ selected: selectedDate === d }"
          @click="selectedDate = d; loadSlots()"
        >
          {{ formatShortDate(d) }}
        </button>
      </div>

      <div v-if="slots.length" class="slots-grid">
        <button
          v-for="slot in slots"
          :key="slot.id"
          class="slot-btn"
          :class="{ selected: selectedSlot?.id === slot.id }"
          @click="selectedSlot = slot; step = 3"
        >
          {{ slot.start_time?.slice(0, 5) }}
        </button>
      </div>
      <p v-else-if="selectedDate" class="no-slots">Нет свободных слотов</p>
    </section>

    <!-- Step 3: Confirm -->
    <section v-if="step === 3" class="booking-step">
      <h2 class="step-title">Подтверждение</h2>
      <div class="confirm-card">
        <div class="confirm-row">
          <span class="confirm-label">Специалист</span>
          <span>{{ selectedDoctor?.specialty }} — {{ selectedDoctor?.user?.first_name }} {{ selectedDoctor?.user?.last_name }}</span>
        </div>
        <div class="confirm-row">
          <span class="confirm-label">Дата</span>
          <span>{{ selectedDate }}</span>
        </div>
        <div class="confirm-row">
          <span class="confirm-label">Время</span>
          <span>{{ selectedSlot?.start_time?.slice(0, 5) }} — {{ selectedSlot?.end_time?.slice(0, 5) }}</span>
        </div>

        <div class="form-group">
          <label class="form-label">Причина визита</label>
          <textarea v-model="reason" class="form-textarea" rows="2" placeholder="Опишите причину визита..." />
        </div>

        <button class="btn-confirm" :disabled="booking" @click="handleBook">
          {{ booking ? 'Запись...' : 'Подтвердить запись' }}
        </button>
      </div>
    </section>

    <!-- Step navigation -->
    <div v-if="step > 1" class="step-nav">
      <button class="btn-back" @click="step--">← Назад</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'

definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()
const appointmentsStore = useAppointmentStore()

const step = ref(1)
const doctors = ref<Array<Record<string, unknown>>>([])
const selectedDoctor = ref<Record<string, unknown> | null>(null)
const selectedDate = ref('')
const slots = ref<Array<Record<string, unknown>>>([])
const selectedSlot = ref<Record<string, unknown> | null>(null)
const reason = ref('')
const booking = ref(false)

// Generate next 14 days
const availableDates = computed(() => {
  const dates: string[] = []
  for (let i = 1; i <= 14; i++) {
    dates.push(dayjs().add(i, 'day').format('YYYY-MM-DD'))
  }
  return dates
})

function formatShortDate(d: string) {
  return dayjs(d).format('D MMM')
}

onMounted(async () => {
  const { data } = await supabase
    .from('doctors')
    .select('*, user:users(first_name, last_name)')
    .eq('is_active', true)

  if (data) doctors.value = data
})

async function loadSlots() {
  if (!selectedDoctor.value || !selectedDate.value) return

  const { data } = await supabase
    .from('appointment_slots')
    .select('*')
    .eq('doctor_id', selectedDoctor.value.id)
    .eq('date', selectedDate.value)
    .eq('is_available', true)
    .order('start_time')

  slots.value = data || []
}

async function handleBook() {
  if (!selectedDoctor.value || !selectedSlot.value || !authStore.familyId) return

  booking.value = true
  try {
    await appointmentsStore.bookAppointment({
      family_id: authStore.familyId,
      doctor_id: selectedDoctor.value.id as string,
      appointment_date: selectedDate.value,
      start_time: selectedSlot.value.start_time as string,
      end_time: selectedSlot.value.end_time as string,
      slot_id: selectedSlot.value.id as string,
      reason: reason.value || undefined,
    })

    // Mark slot as unavailable
    await supabase
      .from('appointment_slots')
      .update({ is_available: false })
      .eq('id', selectedSlot.value.id)

    navigateTo('/family/appointments')
  }
  finally {
    booking.value = false
  }
}
</script>

<style scoped>
.booking-page {
  max-width: 640px;
  margin: 0 auto;
  padding: 24px 16px;
}

.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.booking-step { margin-bottom: 24px; }
.step-title { font-size: 1rem; font-weight: 600; margin-bottom: 12px; }
.step-doctor { font-size: 0.85rem; color: var(--color-text-secondary); margin-bottom: 16px; }

.doctor-grid { display: flex; flex-direction: column; gap: 8px; }
.doctor-card {
  display: flex; align-items: center; gap: 12px; padding: 14px 16px;
  background: var(--color-surface); border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm); cursor: pointer; width: 100%;
  font-family: var(--font-body); text-align: left; transition: all var(--transition-fast);
}
.doctor-card:hover, .doctor-card.selected { border-color: var(--color-primary); box-shadow: var(--shadow-sm); }
.doctor-avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--color-primary-ultralight); color: var(--color-primary); display: flex; align-items: center; justify-content: center; }
.doctor-info { flex: 1; }
.doctor-info h3 { font-size: 0.9rem; font-weight: 600; }
.doctor-info span { font-size: 0.8rem; color: var(--color-text-secondary); }
.doctor-arrow { color: var(--color-text-muted); }

.date-picker { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 8px; margin-bottom: 16px; }
.date-btn {
  flex-shrink: 0; padding: 8px 14px; border: 1px solid var(--color-border); border-radius: 8px;
  background: var(--color-surface); font-size: 0.8rem; cursor: pointer; white-space: nowrap; font-family: var(--font-body);
}
.date-btn.selected { border-color: var(--color-primary); background: var(--color-primary-ultralight); color: var(--color-primary); font-weight: 600; }

.slots-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(80px, 1fr)); gap: 8px; }
.slot-btn {
  padding: 10px; border: 1px solid var(--color-border); border-radius: 8px;
  background: var(--color-surface); font-size: 0.85rem; font-weight: 500; cursor: pointer; text-align: center; font-family: var(--font-body);
}
.slot-btn.selected { border-color: var(--color-primary); background: var(--color-primary-ultralight); color: var(--color-primary); }
.no-slots { font-size: 0.85rem; color: var(--color-text-muted); text-align: center; padding: 16px; }

.confirm-card { background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); padding: 20px; display: flex; flex-direction: column; gap: 14px; }
.confirm-row { display: flex; justify-content: space-between; font-size: 0.9rem; }
.confirm-label { color: var(--color-text-secondary); }

.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.85rem; font-weight: 600; }
.form-textarea {
  padding: 10px 14px; border: 1px solid var(--color-border); border-radius: var(--radius-sm);
  font-size: 0.9rem; font-family: var(--font-body); resize: vertical; outline: none;
}
.form-textarea:focus { border-color: var(--color-primary); }

.btn-confirm {
  padding: 12px; background: var(--gradient-cta); color: white; border: none;
  border-radius: var(--radius-sm); font-size: 1rem; font-weight: 600; cursor: pointer; font-family: var(--font-body);
}
.btn-confirm:disabled { opacity: 0.6; cursor: not-allowed; }

.step-nav { margin-top: 16px; }
.btn-back { background: none; border: none; color: var(--color-text-secondary); cursor: pointer; font-size: 0.85rem; font-family: var(--font-body); }

.empty-state { text-align: center; padding: 32px; color: var(--color-text-muted); }
</style>

<template>
  <div class="sched-page">
    <!-- Hero -->
    <div class="sched-hero">
      <NuxtLink to="/doctor" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="sched-hero-title">Управление расписанием</h1>
      <p class="sched-hero-sub">{{ bookedCount }}/{{ appData.todaySchedule.length }} слотов занято сегодня</p>
    </div>

    <!-- Date picker -->
    <div class="date-scroll">
      <button v-for="(d, i) in weekDates" :key="d.iso" class="date-chip"
        :class="{ 'date-chip--active': selectedIdx === i, 'date-chip--today': i === 0 }"
        @click="selectedIdx = i">
        <span class="date-day-name">{{ d.dayName }}</span>
        <span class="date-day-num">{{ d.day }}</span>
      </button>
    </div>

    <!-- Slot list -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:clock" size="16" /> Слоты</h2>
        <button class="btn-add" @click="showAdd = true"><Icon name="lucide:plus" size="14" /> Добавить слот</button>
      </div>
      <div class="slot-list">
        <div v-for="s in appData.todaySchedule" :key="s.id" class="slot-row" :class="{ 'slot-row--free': !s.is_booked }">
          <span class="slot-time">{{ s.start_time }} — {{ s.end_time }}</span>
          <template v-if="s.is_booked">
            <span class="slot-name">{{ s.patient_name }}</span>
            <span class="slot-reason">{{ s.reason }}</span>
          </template>
          <span v-else class="slot-free">Свободно</span>
          <button v-if="!s.is_booked" class="btn-del"><Icon name="lucide:trash-2" size="14" /></button>
        </div>
      </div>
    </div>

    <!-- Add slot modal -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showAdd" class="modal-overlay" @click.self="showAdd = false">
          <div class="modal-card">
            <h2 class="modal-title">Добавить слот</h2>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Начало</label>
                <input v-model="newSlot.start" type="time" class="form-input" />
              </div>
              <div class="form-group">
                <label class="form-label">Конец</label>
                <input v-model="newSlot.end" type="time" class="form-input" />
              </div>
            </div>
            <div class="modal-actions">
              <button class="btn-cancel" @click="showAdd = false">Отмена</button>
            <button class="btn-submit" :disabled="saving" @click="addSlot">{{ saving ? 'Сохр...' : 'Добавить' }}</button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const appData = useAppData()
const selectedIdx = ref(0)
const showAdd = ref(false)
const saving = ref(false)
const newSlot = reactive({ start: '09:00', end: '09:30' })

const bookedCount = computed(() => appData.todaySchedule.filter(s => s.is_booked).length)

const weekDates = computed(() => {
  const days: Array<{ iso: string; day: number; dayName: string }> = []
  const now = new Date()
  const dayNames = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
  for (let i = 0; i < 14; i++) {
    const d = new Date(now)
    d.setDate(d.getDate() + i)
    days.push({ iso: d.toISOString().slice(0, 10), day: d.getDate(), dayName: dayNames[d.getDay()]! })
  }
  return days
})

async function addSlot() {
  saving.value = true
  try {
    const date = weekDates.value[selectedIdx.value]?.iso
    if (!date) return
    await $fetch('/api/doctor/slots', {
      method: 'POST',
      body: { date, start_time: newSlot.start, end_time: newSlot.end },
    })
    showAdd.value = false
    // Refresh schedule for the selected date
    if (appData.fetchDoctorSchedule) {
      await appData.fetchDoctorSchedule(date)
    }
  } catch (err: any) {
    alert(err?.data?.message || 'Не удалось добавить слот')
  } finally {
    saving.value = false
  }
}

watch(selectedIdx, (idx) => {
  const iso = weekDates.value[idx]?.iso
  if (iso && appData.fetchDoctorSchedule) {
    appData.fetchDoctorSchedule(iso)
  }
})
</script>

<style scoped>
.sched-page { max-width: 700px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.sched-hero {
  background: linear-gradient(135deg, rgba(168,200,232,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(168,200,232,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.sched-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.sched-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.date-scroll { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; }
.date-scroll::-webkit-scrollbar { display: none; }
.date-chip {
  display: flex; flex-direction: column; align-items: center; gap: 3px; padding: 10px 14px; min-width: 52px;
  border: 1px solid var(--color-border-light); border-radius: 12px; background: white;
  cursor: pointer; font-family: var(--font-body); flex-shrink: 0; transition: all 0.15s;
}
.date-chip:hover { border-color: rgba(139,126,200,0.2); }
.date-chip--active { border-color: var(--color-primary); background: rgba(139,126,200,0.08); }
.date-chip--today .date-day-num { color: var(--color-primary); font-weight: 700; }
.date-day-name { font-size: 0.65rem; color: var(--color-text-muted); text-transform: capitalize; }
.date-day-num { font-size: 1rem; font-weight: 600; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.btn-add { display: flex; align-items: center; gap: 4px; padding: 6px 14px; background: rgba(139,126,200,0.08); color: var(--color-primary); border: 1px solid rgba(139,126,200,0.2); border-radius: 10px; font-size: 0.78rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); transition: all 0.15s; }
.btn-add:hover { background: rgba(139,126,200,0.14); }

.slot-list { display: flex; flex-direction: column; gap: 4px; }
.slot-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.slot-row:hover { background: rgba(139,126,200,0.04); }
.slot-row--free { opacity: 0.45; }
.slot-time { font-size: 0.82rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); width: 100px; flex-shrink: 0; }
.slot-name { font-size: 0.82rem; font-weight: 600; flex: 1; }
.slot-reason { font-size: 0.7rem; color: var(--color-text-muted); }
.slot-free { font-size: 0.78rem; color: var(--color-text-muted); font-style: italic; flex: 1; }
.btn-del { background: none; border: none; color: var(--color-danger); cursor: pointer; padding: 4px; opacity: 0.6; }
.btn-del:hover { opacity: 1; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.35); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: white; border-radius: 16px; padding: 28px; width: 100%; max-width: 380px; display: flex; flex-direction: column; gap: 18px; box-shadow: 0 20px 60px rgba(0,0,0,0.12); }
.modal-title { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.form-row { display: flex; gap: 12px; }
.form-group { flex: 1; display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.78rem; font-weight: 600; }
.form-input { padding: 10px 14px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; transition: border-color 0.15s; }
.form-input:focus { border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 8px; justify-content: flex-end; }
.btn-cancel { padding: 8px 18px; background: none; border: 1px solid var(--color-border-light); border-radius: 10px; cursor: pointer; font-family: var(--font-body); font-size: 0.82rem; }
.btn-submit { padding: 8px 22px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; font-family: var(--font-body); font-size: 0.82rem; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>

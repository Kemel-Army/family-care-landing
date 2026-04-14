<template>
  <div class="sleep-page">
    <!-- Hero -->
    <div class="sleep-hero">
      <div>
        <h1 class="sleep-hero-title">Сон</h1>
        <p class="sleep-hero-sub">{{ childName }} · Трекер сна</p>
      </div>
      <div class="sleep-hero-right">
        <div class="sleep-hero-total">
          <Icon name="lucide:moon" size="18" style="color: var(--color-primary)" />
          <span class="sleep-hero-val">{{ avgTotal.toFixed(1) }}ч</span>
          <span class="sleep-hero-lbl">среднее/день</span>
        </div>
        <button class="btn-log" @click="showModal = true">
          <Icon name="lucide:plus" size="15" /> Записать
        </button>
      </div>
    </div>

    <!-- Week chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:bar-chart-3" size="16" /> За 7 дней</h2>
        <div class="legend-row">
          <span class="legend-dot" style="background:var(--color-primary)" /> Ночной
          <span class="legend-dot" style="background:#E8A0BF; margin-left:10px" /> Дневной
        </div>
      </div>
      <AppSharedEChart :option="sleepChartOption" style="height: 200px" />
    </div>

    <!-- Today's logs -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:sun-moon" size="16" /> Сегодня</h2>
        <button class="card-action-btn" @click="showModal = true">
          <Icon name="lucide:plus" size="14" /> Добавить
        </button>
      </div>
      <div v-if="todayLogs.length" class="sleep-logs">
        <div v-for="log in todayLogs" :key="log.id" class="sleep-log-row">
          <div class="sleep-log-icon" :class="log.type === 'night' ? 'sleep-log-icon--night' : 'sleep-log-icon--nap'">
            <Icon :name="log.type === 'night' ? 'lucide:moon' : 'lucide:sun'" size="14" />
          </div>
          <div class="sleep-log-info">
            <span class="sleep-log-name">{{ log.type === 'night' ? 'Ночной сон' : 'Дневной сон' }}</span>
            <span class="sleep-log-time">{{ log.sleep_start }} — {{ log.sleep_end }}</span>
            <span v-if="log.wake_ups" class="sleep-log-wakeup">{{ log.wake_ups }} {{ pluralWakeup(log.wake_ups) }}</span>
          </div>
          <div class="sleep-log-right">
            <span class="sleep-log-dur">{{ formatDuration(log.duration_h) }}</span>
            <div v-if="log.quality" class="quality-dots">
              <span v-for="i in 5" :key="i" class="qdot" :class="{ active: i <= log.quality }" />
            </div>
          </div>
        </div>
      </div>
      <AppSharedEmptyState v-else icon="lucide:moon" title="Нет записей сна на сегодня" action-label="Записать первый" @action="showModal = true" />
    </div>

    <!-- Sleep quality tips -->
    <div class="card tips-card">
      <h2 class="card-title"><Icon name="lucide:lightbulb" size="16" /> Советы по сну</h2>
      <div class="tips-grid">
        <div v-for="tip in sleepTips" :key="tip.text" class="tip-item">
          <span class="tip-icon">{{ tip.emoji }}</span>
          <span class="tip-text">{{ tip.text }}</span>
        </div>
      </div>
    </div>

    <!-- Streak -->
    <div class="card sleep-streak">
      <div class="streak-icon-wrap"><Icon name="lucide:flame" size="20" style="color: var(--color-warning)" /></div>
      <div>
        <span class="streak-val">{{ appData.streaks.sleep.current }} дней</span>
        <span class="streak-lbl">серия записей · рекорд {{ appData.streaks.sleep.longest }} дней</span>
      </div>
    </div>

    <!-- Log modal -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
        <div class="modal-card">
          <div class="modal-header">
            <h2 class="modal-title"><Icon name="lucide:moon" size="18" /> Записать сон</h2>
            <button class="btn-close" @click="showModal = false"><Icon name="lucide:x" size="18" /></button>
          </div>

          <div class="form-row">
            <div class="fg">
              <label class="fl">Тип</label>
              <div class="type-toggle">
                <button class="type-btn" :class="{ active: sleepForm.type === 'night' }" @click="sleepForm.type = 'night'">
                  <Icon name="lucide:moon" size="14" /> Ночной
                </button>
                <button class="type-btn" :class="{ active: sleepForm.type === 'nap' }" @click="sleepForm.type = 'nap'">
                  <Icon name="lucide:sun" size="14" /> Дневной
                </button>
              </div>
            </div>
          </div>

          <div class="form-row-2">
            <div class="fg">
              <label class="fl">Начало</label>
              <input v-model="sleepForm.sleep_start" type="time" class="fi" />
            </div>
            <div class="fg">
              <label class="fl">Конец</label>
              <input v-model="sleepForm.sleep_end" type="time" class="fi" />
            </div>
          </div>

          <div class="form-row-2">
            <div class="fg">
              <label class="fl">Просыпания</label>
              <input v-model.number="sleepForm.wake_ups" type="number" min="0" max="20" class="fi" placeholder="0" />
            </div>
            <div class="fg">
              <label class="fl">Качество (1–5)</label>
              <div class="quality-row">
                <button v-for="q in 5" :key="q" class="q-btn" :class="{ active: sleepForm.quality === q }" @click="sleepForm.quality = q">{{ q }}</button>
              </div>
            </div>
          </div>

          <div class="fg">
            <label class="fl">Заметка</label>
            <input v-model="sleepForm.notes" type="text" class="fi" placeholder="Необязательно..." />
          </div>

          <div v-if="durationPreview" class="duration-preview">
            <Icon name="lucide:clock" size="14" /> Продолжительность: <strong>{{ durationPreview }}</strong>
          </div>

          <div class="modal-actions">
            <button class="btn-cancel" @click="showModal = false">Отмена</button>
            <button class="btn-submit" :disabled="!canSave || saving" @click="saveLog">
              <Icon v-if="saving" name="lucide:loader-2" size="14" class="spin" />
              {{ saving ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Toast -->
  </div>
</template>

<script setup lang="ts">
import type { EChartsOption } from 'echarts'
definePageMeta({ layout: 'app' })

const appData = useAppData()
const authStore = useAuthStore()
const sb = useSupabaseClient()

const childName = computed(() => appData.children[0]?.first_name || 'Ребёнок')
const todayLogs = computed(() => appData.sleepLogsToday)

const avgTotal = computed(() => {
  const w = appData.sleepWeek
  if (!w.length) return 0
  return w.reduce((s, d) => s + d.night + d.nap, 0) / w.length
})

function formatDuration(h: number) {
  const hrs = Math.floor(h)
  const mins = Math.round((h - hrs) * 60)
  if (hrs === 0) return `${mins}мин`
  if (mins === 0) return `${hrs}ч`
  return `${hrs}ч ${mins}мин`
}

function pluralWakeup(n: number) {
  if (n === 1) return 'пробуждение'
  if (n >= 2 && n <= 4) return 'пробуждения'
  return 'пробуждений'
}

const sleepChartOption = computed<EChartsOption>(() => ({
  grid: { top: 20, right: 8, bottom: 24, left: 38 },
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category' as const, data: appData.sleepWeek.map(d => d.date), axisLine: { lineStyle: { color: '#e0dce8' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  yAxis: { type: 'value' as const, name: 'ч', nameTextStyle: { color: '#9690a8', fontSize: 11 }, axisLine: { show: false }, splitLine: { lineStyle: { color: '#f0eef5' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  series: [
    { name: 'Ночной', type: 'bar' as const, stack: 'sleep', data: appData.sleepWeek.map(d => d.night), itemStyle: { color: '#8B7EC8', borderRadius: [0, 0, 4, 4] }, barWidth: '40%' },
    { name: 'Дневной', type: 'bar' as const, stack: 'sleep', data: appData.sleepWeek.map(d => d.nap), itemStyle: { color: '#E8A0BF', borderRadius: [4, 4, 0, 0] }, barWidth: '40%' },
  ],
}))

const sleepTips = [
  { emoji: '🌡️', text: 'Оптимальная температура: 18–22°C' },
  { emoji: '🌑', text: 'Полная темнота ускоряет засыпание' },
  { emoji: '🔔', text: 'Ритуал укладывания за 20 мин' },
  { emoji: '📵', text: 'Без экранов за 1 час до сна' },
]

// Modal
const showModal = ref(false)
const saving = ref(false)
const { success: toastSuccess } = useToast()

const sleepForm = reactive({
  type: 'night' as 'night' | 'nap',
  sleep_start: '',
  sleep_end: '',
  wake_ups: 0,
  quality: 0,
  notes: '',
})

function timeToMin(t: string) {
  const [h, m] = t.split(':').map(Number)
  return (h || 0) * 60 + (m || 0)
}

const durationPreview = computed(() => {
  if (!sleepForm.sleep_start || !sleepForm.sleep_end) return null
  const start = timeToMin(sleepForm.sleep_start)
  const end = timeToMin(sleepForm.sleep_end)
  const diff = ((end - start + 1440) % 1440)
  if (!diff) return null
  return formatDuration(diff / 60)
})

const canSave = computed(() => sleepForm.sleep_start && sleepForm.sleep_end)

async function saveLog() {
  if (!canSave.value) return
  const childId = authStore.children?.[0]?.id
  if (!childId) return
  saving.value = true
  try {
    const today = new Date().toISOString().slice(0, 10)
    await (sb.from('sleep_logs') as any).insert({
      child_id: childId,
      date: today,
      sleep_start: sleepForm.sleep_start,
      sleep_end: sleepForm.sleep_end,
      type: sleepForm.type,
      quality: sleepForm.quality || null,
      wake_ups: sleepForm.wake_ups || 0,
      notes: sleepForm.notes || null,
    })
    // Refresh today's logs
    await appData.fetchSleepLogsToday(childId)
    showModal.value = false
    toastSuccess('Сон записан!')
    // Reset form
    Object.assign(sleepForm, { type: 'night', sleep_start: '', sleep_end: '', wake_ups: 0, quality: 0, notes: '' })
  }
  catch (e) {
    console.error(e)
    toast.value = 'Ошибка при сохранении'
    setTimeout(() => { toast.value = '' }, 2500)
  }
  finally {
    saving.value = false
  }
}
</script>

<style scoped>
.sleep-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.sleep-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(168,200,232,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.sleep-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.sleep-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.sleep-hero-right { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }
.sleep-hero-total { display: flex; align-items: center; gap: 6px; }
.sleep-hero-val { font-size: 1.1rem; font-weight: 700; font-family: var(--font-mono); }
.sleep-hero-lbl { font-size: 0.68rem; color: var(--color-text-muted); }
.btn-log {
  display: flex; align-items: center; gap: 6px; padding: 8px 16px;
  background: var(--gradient-cta); color: white; border-radius: 10px;
  font-size: 0.78rem; font-weight: 600; border: none; cursor: pointer;
}

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.card-action-btn { font-size: 0.72rem; font-weight: 600; color: var(--color-primary); display: flex; align-items: center; gap: 4px; background: rgba(139,126,200,0.08); border: none; cursor: pointer; padding: 5px 12px; border-radius: 8px; }

.legend-row { font-size: 0.72rem; color: var(--color-text-muted); display: flex; align-items: center; gap: 4px; }
.legend-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; }

.sleep-logs { display: flex; flex-direction: column; gap: 6px; }
.sleep-log-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.sleep-log-row:hover { background: rgba(139,126,200,0.04); }
.sleep-log-icon { width: 32px; height: 32px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.sleep-log-icon--night { background: rgba(139,126,200,0.1); color: var(--color-primary); }
.sleep-log-icon--nap { background: rgba(242,196,160,0.12); color: var(--color-accent-peach); }
.sleep-log-info { flex: 1; }
.sleep-log-name { display: block; font-size: 0.85rem; font-weight: 500; }
.sleep-log-time { display: block; font-size: 0.72rem; color: var(--color-text-muted); }
.sleep-log-wakeup { display: block; font-size: 0.68rem; color: var(--color-accent-rose); margin-top: 2px; }
.sleep-log-right { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; }
.sleep-log-dur { font-size: 0.85rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); }
.quality-dots { display: flex; gap: 3px; }
.qdot { width: 6px; height: 6px; border-radius: 50%; background: var(--color-border-light); transition: background 0.2s; }
.qdot.active { background: var(--color-primary); }

.no-logs { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 28px; text-align: center; gap: 4px; }
.no-logs p { font-size: 0.82rem; color: var(--color-text-muted); }
.btn-log-inline { margin-top: 8px; padding: 8px 18px; background: var(--gradient-cta); color: white; border-radius: 10px; font-size: 0.78rem; font-weight: 600; border: none; cursor: pointer; }

.tips-card { }
.tips-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 12px; }
.tip-item { display: flex; align-items: center; gap: 8px; padding: 10px 12px; border-radius: 10px; background: rgba(139,126,200,0.04); }
.tip-icon { font-size: 1.1rem; flex-shrink: 0; }
.tip-text { font-size: 0.75rem; color: var(--color-text-secondary); line-height: 1.3; }

.sleep-streak { display: flex; align-items: center; gap: 14px; }
.streak-icon-wrap { width: 40px; height: 40px; border-radius: 12px; background: rgba(233,196,106,0.1); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.streak-val { font-size: 0.92rem; font-weight: 700; display: block; }
.streak-lbl { font-size: 0.72rem; color: var(--color-text-muted); }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); z-index: 9000; display: flex; align-items: flex-end; justify-content: center; padding: 16px; }
.modal-card { background: white; border-radius: 20px 20px 20px 20px; padding: 24px; width: 100%; max-width: 480px; max-height: 95vh; overflow-y: auto; display: flex; flex-direction: column; gap: 14px; }
.modal-header { display: flex; align-items: center; justify-content: space-between; }
.modal-title { font-size: 1rem; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.btn-close { border: none; background: rgba(139,126,200,0.08); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; cursor: pointer; }
.form-row { display: flex; flex-direction: column; gap: 6px; }
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.fg { display: flex; flex-direction: column; gap: 6px; }
.fl { font-size: 0.72rem; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: 0.04em; }
.fi { padding: 10px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.85rem; width: 100%; }
.fi:focus { outline: none; border-color: var(--color-primary); }

.type-toggle { display: flex; gap: 8px; }
.type-btn { flex: 1; padding: 9px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.8rem; font-weight: 500; display: flex; align-items: center; justify-content: center; gap: 6px; cursor: pointer; background: white; transition: all 0.15s; }
.type-btn.active { background: rgba(139,126,200,0.1); border-color: var(--color-primary); color: var(--color-primary); font-weight: 700; }

.quality-row { display: flex; gap: 6px; }
.q-btn { width: 36px; height: 36px; border: 1px solid var(--color-border-light); border-radius: 8px; font-size: 0.85rem; font-weight: 600; cursor: pointer; background: white; transition: all 0.15s; }
.q-btn.active { background: var(--color-primary); color: white; border-color: var(--color-primary); }

.duration-preview { background: rgba(139,126,200,0.06); border-radius: 8px; padding: 10px 14px; font-size: 0.82rem; color: var(--color-text-secondary); display: flex; align-items: center; gap: 8px; }

.modal-actions { display: flex; gap: 10px; }
.btn-cancel { flex: 1; padding: 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.85rem; font-weight: 600; cursor: pointer; background: white; }
.btn-submit { flex: 2; padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-size: 0.85rem; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; }
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }

/* Toast */
.toast { position: fixed; bottom: 90px; left: 50%; transform: translateX(-50%); background: var(--color-success); color: white; padding: 12px 24px; border-radius: 12px; font-size: 0.82rem; font-weight: 600; display: flex; align-items: center; gap: 8px; z-index: 9999; box-shadow: 0 4px 16px rgba(0,0,0,0.15); }
.toast-enter-active, .toast-leave-active { transition: all 0.3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(10px); }
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>


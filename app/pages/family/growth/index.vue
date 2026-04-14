<template>
  <div class="grow-page">
    <!-- Hero -->
    <div class="grow-hero">
      <div>
        <h1 class="grow-hero-title">Рост и развитие</h1>
        <p class="grow-hero-sub">{{ appData.children[0]!.first_name }} · {{ achievedCount }}/{{ appData.milestones.length }} вех</p>
      </div>
      <div class="grow-hero-metrics">
        <div class="grow-metric">
          <span class="grow-metric-val">{{ latestWeight }} <small>кг</small></span>
          <span class="grow-metric-lbl">Вес</span>
        </div>
        <div class="grow-metric">
          <span class="grow-metric-val">{{ latestHeight }} <small>см</small></span>
          <span class="grow-metric-lbl">Рост</span>
        </div>
        <div class="grow-metric">
          <span class="grow-metric-val">{{ latestHead }} <small>см</small></span>
          <span class="grow-metric-lbl">Голова</span>
        </div>
        <button class="btn-add-measure" @click="showModal = true">
          <Icon name="lucide:plus" size="14" /> Измерение
        </button>
      </div>
    </div>

    <!-- Weight chart -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:trending-up" size="16" /> Кривая роста (вес)</h2>
      </div>
      <div class="chart-wrap">
        <AppSharedEChart :option="weightChartOption" style="height: 240px" />
      </div>
    </div>

    <!-- Milestones -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:star" size="16" /> Вехи развития</h2>
        <span class="card-badge">{{ achievedCount }}/{{ appData.milestones.length }}</span>
      </div>
      <!-- dummy comment to uniquify -->
      <div class="ms-list">
        <div v-for="ms in appData.milestones" :key="ms.id" class="ms-row" :class="{ 'ms-row--done': ms.achieved }">
          <div class="ms-dot" :class="{ 'ms-dot--done': ms.achieved }">
            <Icon :name="ms.achieved ? 'lucide:check' : ms.icon" size="14" />
          </div>
          <div class="ms-info">
            <span class="ms-name">{{ ms.name }}</span>
            <span class="ms-meta">{{ ms.expected }}{{ ms.achieved ? ' · ' + formatDate(ms.date) : '' }}</span>
          </div>
          <span v-if="ms.achieved" class="ms-badge ms-badge--done">Достигнуто</span>
          <span v-else class="ms-badge ms-badge--pending">Ожидается</span>
        </div>
      </div>
    </div>

    <!-- Add Measurement Modal -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
        <div class="modal-card">
          <div class="modal-header">
            <h2 class="modal-title"><Icon name="lucide:ruler" size="18" /> Добавить измерение</h2>
            <button class="btn-close" @click="showModal = false"><Icon name="lucide:x" size="18" /></button>
          </div>

          <div class="fg">
            <label class="fl">Дата</label>
            <input v-model="measureForm.date" type="date" class="fi" />
          </div>

          <div class="form-row-3">
            <div class="fg">
              <label class="fl">Вес, кг</label>
              <input v-model="measureForm.weight_kg" type="number" step="0.1" min="0" class="fi" placeholder="8.5" />
            </div>
            <div class="fg">
              <label class="fl">Рост, см</label>
              <input v-model="measureForm.height_cm" type="number" step="0.1" min="0" class="fi" placeholder="72" />
            </div>
            <div class="fg">
              <label class="fl">Голова, см</label>
              <input v-model="measureForm.head_cm" type="number" step="0.1" min="0" class="fi" placeholder="46" />
            </div>
          </div>

          <div class="modal-actions">
            <button class="btn-cancel" @click="showModal = false">Отмена</button>
            <button class="btn-submit" :disabled="!canSave || saving" @click="saveMeasure">
              {{ saving ? 'Сохранение...' : 'Сохранить' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import type { EChartsOption } from 'echarts'
definePageMeta({ layout: 'app' })

const appData = useAppData()
const authStore = useAuthStore()
const sb = useSupabaseClient()

const g = appData.growthData
const latestWeight = g.weight[g.weight.length - 1]
const latestHeight = g.height[g.height.length - 1]
const latestHead = g.head[g.head.length - 1]
const achievedCount = computed(() => appData.milestones.filter(m => m.achieved).length)

const weightChartOption = computed<EChartsOption>(() => ({
  grid: { top: 30, right: 16, bottom: 30, left: 42 },
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category' as const, data: g.months.map(m => `${m} мес`), axisLine: { lineStyle: { color: '#e0dce8' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  yAxis: { type: 'value' as const, name: 'кг', nameTextStyle: { color: '#9690a8', fontSize: 11 }, axisLine: { show: false }, splitLine: { lineStyle: { color: '#f0eef5' } }, axisLabel: { color: '#9690a8', fontSize: 11 } },
  series: [
    { name: '3-й перцентиль', type: 'line' as const, data: g.whoWeight3rd, lineStyle: { type: 'dashed', color: '#d4d0e0', width: 1 }, symbol: 'none', itemStyle: { color: '#d4d0e0' } },
    { name: '50-й перцентиль', type: 'line' as const, data: g.whoWeight50th, lineStyle: { type: 'dashed', color: '#b8b0d0', width: 1 }, symbol: 'none', itemStyle: { color: '#b8b0d0' } },
    { name: '97-й перцентиль', type: 'line' as const, data: g.whoWeight97th, lineStyle: { type: 'dashed', color: '#d4d0e0', width: 1 }, symbol: 'none', itemStyle: { color: '#d4d0e0' } },
    { name: 'Вес ребёнка', type: 'line' as const, data: g.weight, lineStyle: { color: '#8B7EC8', width: 3 }, symbol: 'circle', symbolSize: 8, itemStyle: { color: '#8B7EC8', borderColor: '#fff', borderWidth: 2 }, areaStyle: { color: { type: 'linear' as const, x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(139,126,200,0.18)' }, { offset: 1, color: 'rgba(139,126,200,0)' }] } } },
  ],
}))

function formatDate(iso: string) {
  const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

// Measurement modal
const showModal = ref(false)
const saving = ref(false)
const { success: toastSuccess } = useToast()
const measureForm = reactive({
  date: new Date().toISOString().slice(0, 10),
  weight_kg: null as number | null,
  height_cm: null as number | null,
  head_cm: null as number | null,
})
const canSave = computed(() => measureForm.weight_kg || measureForm.height_cm || measureForm.head_cm)

async function saveMeasure() {
  if (!canSave.value) return
  const childId = authStore.children?.[0]?.id
  if (!childId) return
  saving.value = true
  try {
    await sb.from('growth_metrics').insert({
      child_id: childId,
      date: measureForm.date,
      weight_kg: measureForm.weight_kg || null,
      height_cm: measureForm.height_cm || null,
      head_cm: measureForm.head_cm || null,
    })
    await appData.fetchAll()
    showModal.value = false
    toastSuccess('Измерение сохранено!')
    Object.assign(measureForm, { date: new Date().toISOString().slice(0, 10), weight_kg: null, height_cm: null, head_cm: null })
  }
  catch (e) { console.error(e) }
  finally { saving.value = false }
}
</script>

<style scoped>
.grow-page { max-width: 720px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.grow-hero {
  display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(242,196,160,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.grow-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.grow-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.grow-hero-metrics { display: flex; gap: 20px; }
.grow-metric { text-align: center; }
.grow-metric-val { font-size: 1.2rem; font-weight: 700; font-family: var(--font-mono); display: block; }
.grow-metric-val small { font-size: 0.7rem; font-weight: 400; color: var(--color-text-muted); }
.grow-metric-lbl { font-size: 0.68rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.card-badge { font-size: 0.72rem; font-weight: 600; color: var(--color-primary); background: rgba(139,126,200,0.08); padding: 3px 10px; border-radius: var(--radius-full); }
.chart-wrap { margin: 0 -8px; }

.ms-list { display: flex; flex-direction: column; gap: 4px; }
.ms-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.ms-row:hover { background: rgba(139,126,200,0.04); }
.ms-row--done { opacity: 0.65; }

.ms-dot {
  width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  background: rgba(233,196,106,0.12); color: var(--color-warning);
}
.ms-dot--done { background: rgba(124,184,212,0.12); color: var(--color-success); }

.ms-info { flex: 1; min-width: 0; }
.ms-name { display: block; font-size: 0.85rem; font-weight: 500; }
.ms-meta { display: block; font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }

.ms-badge { font-size: 0.62rem; font-weight: 600; padding: 3px 8px; border-radius: var(--radius-full); flex-shrink: 0; }
.ms-badge--done { background: rgba(124,184,212,0.1); color: var(--color-success); }
.ms-badge--pending { background: rgba(233,196,106,0.08); color: var(--color-warning); }

.btn-add-measure {
  padding: 8px 14px; background: white; border: 1px solid rgba(139,126,200,0.3); border-radius: 10px;
  font-size: 0.75rem; font-weight: 600; color: var(--color-primary); cursor: pointer;
  display: flex; align-items: center; gap: 5px; transition: all 0.15s;
}
.btn-add-measure:hover { background: rgba(139,126,200,0.06); }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); z-index: 9000; display: flex; align-items: flex-end; justify-content: center; padding: 16px; }
.modal-card { background: white; border-radius: 20px; padding: 24px; width: 100%; max-width: 480px; display: flex; flex-direction: column; gap: 14px; }
.modal-header { display: flex; align-items: center; justify-content: space-between; }
.modal-title { font-size: 1rem; font-weight: 700; display: flex; align-items: center; gap: 8px; }
.btn-close { border: none; background: rgba(139,126,200,0.08); border-radius: 8px; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; cursor: pointer; }
.form-row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.fg { display: flex; flex-direction: column; gap: 6px; }
.fl { font-size: 0.72rem; font-weight: 600; color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: 0.04em; }
.fi { padding: 10px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.85rem; width: 100%; }
.fi:focus { outline: none; border-color: var(--color-primary); }
.modal-actions { display: flex; gap: 10px; }
.btn-cancel { flex: 1; padding: 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.85rem; font-weight: 600; cursor: pointer; background: white; }
.btn-submit { flex: 2; padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: 10px; font-size: 0.85rem; font-weight: 700; cursor: pointer; }
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }
.toast { position: fixed; bottom: 90px; left: 50%; transform: translateX(-50%); background: var(--color-success); color: white; padding: 12px 24px; border-radius: 12px; font-size: 0.82rem; font-weight: 600; display: flex; align-items: center; gap: 8px; z-index: 9999; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(10px); }
</style>

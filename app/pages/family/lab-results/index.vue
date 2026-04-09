<template>
  <div class="lab-page">
    <header class="page-header">
      <h1 class="page-title">Результаты анализов</h1>
    </header>

    <!-- Pending results alert -->
    <div v-if="pendingCount > 0" class="pending-alert">
      <Icon name="lucide:clock" size="18" />
      <span>{{ pendingCount }} {{ pendingCount === 1 ? 'анализ' : 'анализов' }} в обработке</span>
    </div>

    <!-- Results list -->
    <div class="results-list">
      <div v-for="result in results" :key="result.id" class="result-card" @click="openResult(result)">
        <div class="result-type-icon" :class="result.statusClass">
          <Icon :name="result.statusIcon" size="18" />
        </div>
        <div class="result-content">
          <h3>{{ result.test_name }}</h3>
          <p>{{ result.lab_name }} · {{ result.date }}</p>
          <div v-if="result.highlights.length" class="result-highlights">
            <span v-for="h in result.highlights" :key="h.name" class="highlight-chip" :class="h.flag">
              {{ h.name }}: {{ h.value }} {{ h.unit }}
            </span>
          </div>
        </div>
        <Icon name="lucide:chevron-right" size="16" class="result-arrow" />
      </div>
    </div>

    <div v-if="!results.length" class="empty">
      <Icon name="lucide:test-tube" size="40" />
      <p>Результаты анализов появятся здесь</p>
      <span class="empty-hint">Подключите лабораторию в разделе Интеграции</span>
    </div>

    <!-- Result detail modal -->
    <Teleport to="body">
      <div v-if="selectedResult" class="modal-overlay" @click.self="selectedResult = null">
        <div class="modal-card">
          <div class="modal-header">
            <h2>{{ selectedResult.test_name }}</h2>
            <button class="btn-close" @click="selectedResult = null">
              <Icon name="lucide:x" size="18" />
            </button>
          </div>
          <div class="detail-meta">
            <span>{{ selectedResult.lab_name }}</span>
            <span>{{ selectedResult.date }}</span>
          </div>

          <div class="detail-values">
            <div v-for="v in selectedResult.values" :key="v.name" class="value-row" :class="v.flag">
              <span class="value-name">{{ v.name }}</span>
              <span class="value-result">{{ v.value }} {{ v.unit }}</span>
              <span class="value-ref">Норма: {{ v.reference }}</span>
              <span v-if="v.flag" class="value-flag">{{ v.flag === 'high' ? '▲' : '▼' }}</span>
            </div>
          </div>

          <div v-if="selectedResult.doctor_comment" class="doctor-comment">
            <h3>Комментарий врача</h3>
            <p>{{ selectedResult.doctor_comment }}</p>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const userId = useSupabaseUserId()

interface LabValue { name: string; value: string; unit: string; reference: string; flag: string }
interface LabResult {
  id: string; test_name: string; lab_name: string; date: string; status: string
  statusClass: string; statusIcon: string; highlights: LabValue[]; values: LabValue[]
  doctor_comment: string
}

const results = ref<LabResult[]>([])
const selectedResult = ref<LabResult | null>(null)
const pendingCount = ref(0)

function openResult(result: LabResult) {
  selectedResult.value = result
}

function parseValues(raw: unknown): LabValue[] {
  if (!Array.isArray(raw)) return []
  return raw.map((v: Record<string, string>) => ({
    name: v.name || '',
    value: v.value || '',
    unit: v.unit || '',
    reference: v.reference || '',
    flag: v.flag || '',
  }))
}

onMounted(async () => {
  if (!user.value) return

  const { data } = await supabase
    .from('lab_results')
    .select('*')
    .eq('user_id', userId.value)
    .order('created_at', { ascending: false })

  results.value = (data || []).map((r: Record<string, unknown>) => {
    const vals = parseValues(r.values)
    const highlights = vals.filter(v => v.flag)
    const status = String(r.status || 'ready')
    return {
      id: String(r.id),
      test_name: String(r.test_name),
      lab_name: String(r.lab_name || 'Лаборатория'),
      date: new Date(r.created_at as string).toLocaleDateString('ru-RU'),
      status,
      statusClass: status === 'ready' ? 'ready' : 'pending',
      statusIcon: status === 'ready' ? 'lucide:check-circle' : 'lucide:clock',
      highlights: highlights.slice(0, 3),
      values: vals,
      doctor_comment: String(r.doctor_comment || ''),
    }
  })

  pendingCount.value = results.value.filter(r => r.status === 'pending').length
})
</script>

<style scoped>
.lab-page { max-width: 700px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.pending-alert { display: flex; align-items: center; gap: 8px; padding: 12px 16px; background: rgba(233, 196, 106, 0.1); border: 1px solid rgba(233, 196, 106, 0.3); border-radius: var(--radius-sm); margin-bottom: 16px; font-size: 0.85rem; color: var(--color-warning); }

.results-list { display: flex; flex-direction: column; gap: 8px; }
.result-card { display: flex; align-items: center; gap: 12px; padding: 16px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); cursor: pointer; transition: border-color 0.15s; }
.result-card:hover { border-color: var(--color-primary); }

.result-type-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.result-type-icon.ready { background: rgba(124, 184, 212, 0.15); color: var(--color-success); }
.result-type-icon.pending { background: rgba(233, 196, 106, 0.15); color: var(--color-warning); }

.result-content { flex: 1; }
.result-content h3 { font-size: 0.95rem; font-weight: 600; }
.result-content p { font-size: 0.8rem; color: var(--color-text-secondary); }
.result-highlights { display: flex; flex-wrap: wrap; gap: 4px; margin-top: 6px; }
.highlight-chip { font-size: 0.7rem; padding: 2px 8px; border-radius: 8px; font-family: var(--font-mono); }
.highlight-chip.high { background: rgba(231, 111, 81, 0.12); color: var(--color-danger); }
.highlight-chip.low { background: rgba(233, 196, 106, 0.12); color: var(--color-warning); }

.result-arrow { color: var(--color-text-muted); flex-shrink: 0; }

.empty { text-align: center; padding: 48px; color: var(--color-text-muted); }
.empty-hint { font-size: 0.8rem; display: block; margin-top: 4px; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 16px; }
.modal-card { background: var(--color-surface); border-radius: var(--radius-md); padding: 24px; width: 100%; max-width: 520px; max-height: 80vh; overflow-y: auto; }
.modal-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.modal-header h2 { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; }
.btn-close { border: none; background: none; cursor: pointer; color: var(--color-text-muted); padding: 4px; }

.detail-meta { display: flex; gap: 12px; font-size: 0.8rem; color: var(--color-text-secondary); margin-bottom: 16px; }

.detail-values { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
.value-row { display: flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: var(--radius-sm); background: var(--color-page); }
.value-row.high { background: rgba(231, 111, 81, 0.06); }
.value-row.low { background: rgba(233, 196, 106, 0.06); }
.value-name { flex: 1; font-size: 0.85rem; font-weight: 500; }
.value-result { font-size: 0.9rem; font-weight: 700; font-family: var(--font-mono); }
.value-ref { font-size: 0.7rem; color: var(--color-text-muted); width: 120px; }
.value-flag { font-size: 0.75rem; width: 20px; text-align: center; }
.value-row.high .value-flag { color: var(--color-danger); }
.value-row.low .value-flag { color: var(--color-warning); }

.doctor-comment { padding: 14px; background: var(--color-primary-ultralight); border-radius: var(--radius-sm); }
.doctor-comment h3 { font-size: 0.85rem; font-weight: 600; margin-bottom: 6px; }
.doctor-comment p { font-size: 0.85rem; }
</style>

<template>
  <div class="reputation-page">
    <header class="page-header">
      <h1 class="page-title">Репутация клиники</h1>
    </header>

    <!-- NPS Overview -->
    <div class="nps-overview">
      <div class="nps-score-card">
        <div class="nps-circle" :class="npsClass">
          <span class="nps-num">{{ npsScore }}</span>
        </div>
        <div class="nps-details">
          <h3>NPS Score</h3>
          <p>На основе {{ totalResponses }} ответов</p>
        </div>
      </div>
      <div class="nps-breakdown">
        <div class="breakdown-bar">
          <span class="bar-label promoters">Промоутеры (9-10)</span>
          <div class="bar-track"><div class="bar-fill green" :style="{ width: `${promotersPct}%` }" /></div>
          <span class="bar-pct">{{ promotersPct }}%</span>
        </div>
        <div class="breakdown-bar">
          <span class="bar-label passives">Нейтральные (7-8)</span>
          <div class="bar-track"><div class="bar-fill yellow" :style="{ width: `${passivesPct}%` }" /></div>
          <span class="bar-pct">{{ passivesPct }}%</span>
        </div>
        <div class="breakdown-bar">
          <span class="bar-label detractors">Критики (0-6)</span>
          <div class="bar-track"><div class="bar-fill red" :style="{ width: `${detractorsPct}%` }" /></div>
          <span class="bar-pct">{{ detractorsPct }}%</span>
        </div>
      </div>
    </div>

    <!-- Recent reviews -->
    <section class="section">
      <h2 class="section-title">Последние отзывы</h2>
      <div class="review-list">
        <div v-for="review in reviews" :key="review.id" class="review-card">
          <div class="review-header">
            <div class="review-stars">{{ '★'.repeat(review.rating) }}{{ '☆'.repeat(5 - review.rating) }}</div>
            <span class="review-date">{{ review.date }}</span>
          </div>
          <p v-if="review.comment" class="review-text">{{ review.comment }}</p>
          <span class="review-author">{{ review.author }}</span>
        </div>
      </div>
    </section>

    <!-- Review request -->
    <section class="section">
      <h2 class="section-title">Запрос отзыва</h2>
      <p class="hint-text">Автоматически отправляется семьям с NPS ≥ 9 через 24ч после положительного события.</p>
      <div class="settings-row">
        <label>Ссылка на 2GIS</label>
        <input v-model="reviewLink2gis" type="url" class="form-input" placeholder="https://2gis.kz/..." />
      </div>
      <div class="settings-row">
        <label>Ссылка на Google</label>
        <input v-model="reviewLinkGoogle" type="url" class="form-input" placeholder="https://g.page/..." />
      </div>
      <button class="btn-save" @click="saveLinks">Сохранить ссылки</button>
    </section>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const authStore = useAuthStore()

const npsScore = ref(0)
const totalResponses = ref(0)
const promotersPct = ref(0)
const passivesPct = ref(0)
const detractorsPct = ref(0)
const reviews = ref<Array<{ id: string; rating: number; comment: string; date: string; author: string }>>([])
const reviewLink2gis = ref('')
const reviewLinkGoogle = ref('')

const npsClass = computed(() => {
  if (npsScore.value >= 50) return 'excellent'
  if (npsScore.value >= 0) return 'good'
  return 'poor'
})

async function saveLinks() {
  if (!authStore.clinicId) return
  await supabase.from('clinics').update({
    review_link_2gis: reviewLink2gis.value || null,
    review_link_google: reviewLinkGoogle.value || null,
  }).eq('id', authStore.clinicId)
}

onMounted(async () => {
  if (!authStore.clinicId) return

  const { data: nps } = await supabase
    .from('v_clinic_nps')
    .select('*')
    .eq('clinic_id', authStore.clinicId)
    .single()

  if (nps) {
    const d = nps as Record<string, number>
    npsScore.value = d.nps_score || 0
    totalResponses.value = d.total_responses || 0
    promotersPct.value = d.promoters_pct || 0
    passivesPct.value = d.passives_pct || 0
    detractorsPct.value = d.detractors_pct || 0
  }

  // Recent reviews
  const { data: rev } = await supabase
    .from('nps_responses')
    .select('*, families!inner(clinic_id, primary_parent:users!families_primary_parent_id_fkey(first_name, last_name))')
    .eq('families.clinic_id', authStore.clinicId)
    .order('created_at', { ascending: false })
    .limit(10)

  reviews.value = (rev || []).map((r: Record<string, unknown>) => {
    const family = r.families as Record<string, unknown> | null
    const parent = family?.primary_parent as Record<string, unknown> | null
    const name = parent ? `${parent.first_name || ''} ${parent.last_name || ''}`.trim() : 'Аноним'
    return {
      id: String(r.id),
      rating: Math.round(Number(r.score) / 2),
      comment: String(r.comment || ''),
      date: new Date(r.created_at as string).toLocaleDateString('ru-RU'),
      author: name,
    }
  })
})
</script>

<style scoped>
.reputation-page { max-width: 800px; margin: 0 auto; padding: 24px 16px; }
.page-header { margin-bottom: 24px; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.nps-overview { display: flex; gap: 24px; margin-bottom: 28px; flex-wrap: wrap; }
.nps-score-card { display: flex; align-items: center; gap: 16px; }
.nps-circle { width: 80px; height: 80px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.nps-circle.excellent { background: rgba(124, 184, 212, 0.15); }
.nps-circle.good { background: rgba(233, 196, 106, 0.15); }
.nps-circle.poor { background: rgba(231, 111, 81, 0.15); }
.nps-num { font-size: 2rem; font-weight: 700; font-family: var(--font-mono); }
.nps-details h3 { font-size: 1rem; font-weight: 600; }
.nps-details p { font-size: 0.8rem; color: var(--color-text-secondary); }

.nps-breakdown { flex: 1; min-width: 260px; display: flex; flex-direction: column; gap: 8px; justify-content: center; }
.breakdown-bar { display: flex; align-items: center; gap: 8px; }
.bar-label { width: 150px; font-size: 0.8rem; flex-shrink: 0; }
.bar-track { flex: 1; height: 10px; background: var(--color-border-light); border-radius: 5px; overflow: hidden; }
.bar-fill { height: 100%; border-radius: 5px; }
.bar-fill.green { background: var(--color-success); }
.bar-fill.yellow { background: var(--color-warning); }
.bar-fill.red { background: var(--color-danger); }
.bar-pct { width: 40px; text-align: right; font-size: 0.8rem; font-family: var(--font-mono); font-weight: 600; }

.section { margin-bottom: 28px; }
.section-title { font-size: 1rem; font-weight: 600; margin-bottom: 12px; }

.review-list { display: flex; flex-direction: column; gap: 10px; }
.review-card { padding: 14px 16px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-sm); }
.review-header { display: flex; justify-content: space-between; margin-bottom: 6px; }
.review-stars { color: #F59E0B; }
.review-date { font-size: 0.75rem; color: var(--color-text-muted); }
.review-text { font-size: 0.85rem; margin-bottom: 4px; }
.review-author { font-size: 0.75rem; color: var(--color-text-secondary); }

.hint-text { font-size: 0.85rem; color: var(--color-text-secondary); margin-bottom: 16px; }
.settings-row { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
.settings-row label { width: 140px; font-size: 0.85rem; font-weight: 600; flex-shrink: 0; }
.form-input { flex: 1; padding: 8px 12px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.85rem; font-family: var(--font-body); outline: none; }
.btn-save { padding: 8px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body); margin-top: 8px; }
</style>

<template>
  <div class="rep-page">
    <div class="rep-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="hero-title">Репутация клиники</h1>
      <p class="hero-sub">NPS-метрика, отзывы и интеграции</p>
    </div>

    <!-- NPS ring + breakdown -->
    <div class="nps-row">
      <div class="nps-ring-card">
        <svg viewBox="0 0 120 120" class="nps-svg">
          <circle cx="60" cy="60" r="52" fill="none" stroke="rgba(139,126,200,0.1)" stroke-width="10" />
          <circle cx="60" cy="60" r="52" fill="none" stroke="var(--color-primary)" stroke-width="10" stroke-linecap="round"
            :stroke-dasharray="`${(mock.npsScore / 100) * 327} 327`" transform="rotate(-90 60 60)" />
        </svg>
        <div class="nps-center">
          <span class="nps-num">{{ mock.npsScore }}</span>
          <span class="nps-label">NPS</span>
        </div>
      </div>

      <div class="nps-bars">
        <div class="nb"><span class="nb-label">Промоутеры</span><div class="nb-track"><div class="nb-fill promo" :style="{ width: mock.npsSplit.promoters + '%' }" /></div><span class="nb-pct">{{ mock.npsSplit.promoters }}%</span></div>
        <div class="nb"><span class="nb-label">Нейтральные</span><div class="nb-track"><div class="nb-fill passive" :style="{ width: mock.npsSplit.passives + '%' }" /></div><span class="nb-pct">{{ mock.npsSplit.passives }}%</span></div>
        <div class="nb"><span class="nb-label">Критики</span><div class="nb-track"><div class="nb-fill detract" :style="{ width: mock.npsSplit.detractors + '%' }" /></div><span class="nb-pct">{{ mock.npsSplit.detractors }}%</span></div>
      </div>
    </div>

    <!-- Reviews -->
    <div class="card">
      <h2 class="card-title">Последние отзывы</h2>
      <div class="review-list">
        <div v-for="r in reviews" :key="r.id" class="review">
          <div class="rv-top">
            <span class="rv-stars">{{ '★'.repeat(r.stars) }}{{ '☆'.repeat(5 - r.stars) }}</span>
            <span class="rv-date">{{ r.date }}</span>
          </div>
          <p class="rv-text">{{ r.text }}</p>
          <span class="rv-author">{{ r.author }}</span>
        </div>
      </div>
    </div>

    <!-- Links -->
    <div class="card">
      <h2 class="card-title">Ссылки на отзывы</h2>
      <p class="hint">Отправляются семьям с NPS ≥ 9 через 24ч после положительного события</p>
      <div class="fg"><label class="fl">2GIS</label><input v-model="link2gis" class="fi" placeholder="https://2gis.kz/..." /></div>
      <div class="fg"><label class="fl">Google</label><input v-model="linkGoogle" class="fi" placeholder="https://g.page/..." /></div>
      <button class="btn-save">Сохранить</button>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const { data: mock } = useMockData()

const link2gis = ref('https://2gis.kz/almaty/firm/family-care')
const linkGoogle = ref('https://g.page/family-care-almaty')

const reviews = [
  { id: 1, stars: 5, date: '12 мая', text: 'Отличный сервис! Координатор всегда на связи, врачи внимательные.', author: 'Айгуль М.' },
  { id: 2, stars: 5, date: '09 мая', text: 'Приложение очень удобное, все напоминания приходят вовремя.', author: 'Динара К.' },
  { id: 3, stars: 4, date: '05 мая', text: 'В целом хорошо, но хотелось бы больше врачей на выбор.', author: 'Марат Т.' },
  { id: 4, stars: 5, date: '01 мая', text: 'Рекомендую всем! Особенно AI-план ухода — реально помогает.', author: 'Сауле Б.' },
]
</script>

<style scoped>
.rep-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.rep-hero {
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(168,200,232,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.nps-row { display: flex; gap: 24px; align-items: center; flex-wrap: wrap; background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 24px; }
.nps-ring-card { position: relative; width: 120px; height: 120px; flex-shrink: 0; }
.nps-svg { width: 100%; height: 100%; }
.nps-center { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; }
.nps-num { font-size: 1.8rem; font-weight: 700; font-family: var(--font-mono); color: var(--color-primary); }
.nps-label { font-size: 0.7rem; color: var(--color-text-muted); font-weight: 600; }

.nps-bars { flex: 1; min-width: 220px; display: flex; flex-direction: column; gap: 10px; }
.nb { display: flex; align-items: center; gap: 10px; }
.nb-label { width: 100px; font-size: 0.78rem; flex-shrink: 0; color: var(--color-text-muted); }
.nb-track { flex: 1; height: 8px; background: rgba(139,126,200,0.08); border-radius: 4px; overflow: hidden; }
.nb-fill { height: 100%; border-radius: 4px; }
.nb-fill.promo { background: var(--color-success); }
.nb-fill.passive { background: var(--color-warning); }
.nb-fill.detract { background: var(--color-danger); }
.nb-pct { width: 36px; text-align: right; font-size: 0.78rem; font-family: var(--font-mono); font-weight: 600; }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
.card-title { font-size: 0.95rem; font-weight: 700; }

.review-list { display: flex; flex-direction: column; gap: 8px; }
.review { padding: 12px 14px; background: rgba(139,126,200,0.04); border-radius: 10px; }
.rv-top { display: flex; justify-content: space-between; margin-bottom: 4px; }
.rv-stars { color: #F59E0B; font-size: 0.85rem; }
.rv-date { font-size: 0.72rem; color: var(--color-text-muted); }
.rv-text { font-size: 0.82rem; margin-bottom: 4px; line-height: 1.5; }
.rv-author { font-size: 0.72rem; color: var(--color-text-muted); font-weight: 500; }

.hint { font-size: 0.78rem; color: var(--color-text-muted); }
.fg { display: flex; flex-direction: column; gap: 4px; }
.fl { font-size: 0.78rem; font-weight: 600; color: var(--color-text-muted); }
.fi { padding: 9px 12px; border: 1px solid var(--color-border-light); border-radius: 10px; font-size: 0.88rem; font-family: var(--font-body); outline: none; }
.fi:focus { border-color: var(--color-primary); }
.btn-save { align-self: flex-start; padding: 9px 20px; background: var(--gradient-cta); color: white; border: none; border-radius: 12px; font-weight: 600; cursor: pointer; font-family: var(--font-body); font-size: 0.82rem; }
</style>

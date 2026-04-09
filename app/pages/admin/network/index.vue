<template>
  <div class="net-page">
    <div class="net-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="hero-title">Сеть филиалов</h1>
      <p class="hero-sub">Рейтинг и метрики по филиалам</p>
    </div>

    <div class="kpi-grid">
      <div class="kpi-card"><span class="kpi-value">{{ branches.length }}</span><span class="kpi-label">Филиалов</span></div>
      <div class="kpi-card"><span class="kpi-value">{{ totalFamilies }}</span><span class="kpi-label">Семей</span></div>
      <div class="kpi-card"><span class="kpi-value">{{ avgCompletion }}%</span><span class="kpi-label">Ср. выполнение</span></div>
    </div>

    <div class="card">
      <h2 class="card-title"><Icon name="lucide:trophy" size="16" /> Рейтинг филиалов</h2>
      <div class="branch-list">
        <div v-for="(b, idx) in branches" :key="idx" class="branch-row">
          <span class="branch-rank">{{ idx + 1 }}</span>
          <div class="branch-info">
            <span class="branch-name">{{ b.name }}</span>
            <span class="branch-city">{{ b.city }}</span>
          </div>
          <div class="branch-metrics">
            <div class="bm"><span class="bm-val">{{ b.families }}</span><span class="bm-lbl">семей</span></div>
            <div class="bm"><span class="bm-val">{{ b.completion }}%</span><span class="bm-lbl">выполн.</span></div>
            <div class="bm"><span class="bm-val">{{ b.nps }}</span><span class="bm-lbl">NPS</span></div>
            <div class="bm"><span class="bm-val">{{ b.revenue }}</span><span class="bm-lbl">доход</span></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const branches = [
  { name: 'Family Care Центр', city: 'Алматы', families: 47, completion: 88, nps: 72, revenue: '4.2M' },
  { name: 'Family Care Бостандык', city: 'Алматы', families: 31, completion: 82, nps: 65, revenue: '2.8M' },
  { name: 'Family Care Астана', city: 'Астана', families: 28, completion: 79, nps: 68, revenue: '3.1M' },
]

const totalFamilies = computed(() => branches.reduce((s, b) => s + b.families, 0))
const avgCompletion = computed(() => Math.round(branches.reduce((s, b) => s + b.completion, 0) / branches.length))
</script>

<style scoped>
.net-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.net-hero {
  background: linear-gradient(135deg, rgba(232,160,191,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(232,160,191,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.kpi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
.kpi-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 16px; text-align: center; }
.kpi-value { display: block; font-size: 1.4rem; font-weight: 800; font-family: var(--font-mono); }
.kpi-label { font-size: 0.7rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.branch-list { display: flex; flex-direction: column; gap: 8px; }
.branch-row { display: flex; align-items: center; gap: 14px; padding: 14px 16px; background: rgba(0,0,0,0.01); border-radius: 12px; }
.branch-rank { width: 28px; height: 28px; border-radius: 50%; background: rgba(139,126,200,0.08); color: var(--color-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.82rem; flex-shrink: 0; }
.branch-info { flex: 1; }
.branch-name { display: block; font-size: 0.92rem; font-weight: 600; }
.branch-city { font-size: 0.72rem; color: var(--color-text-muted); }

.branch-metrics { display: flex; gap: 16px; }
.bm { text-align: center; }
.bm-val { display: block; font-size: 0.88rem; font-weight: 700; font-family: var(--font-mono); }
.bm-lbl { font-size: 0.6rem; color: var(--color-text-muted); }

@media (max-width: 600px) { .branch-metrics { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; } }
</style>

<template>
  <div class="doc-page">
    <div class="doc-hero">
      <NuxtLink to="/admin/analytics" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Аналитика</NuxtLink>
      <h1 class="doc-hero-title">Производительность врачей</h1>
      <p class="doc-hero-sub">{{ mock.doctorPerformance.length }} специалистов</p>
    </div>

    <div class="doc-grid">
      <div v-for="d in mock.doctorPerformance" :key="d.name" class="doc-card">
        <div class="dc-top">
          <div class="dc-avatar">{{ d.name.slice(4, 5) }}</div>
          <div class="dc-info">
            <h3>{{ d.name }}</h3>
            <span class="dc-spec">{{ d.specialty }}</span>
          </div>
          <span class="dc-rating">★ {{ d.rating }}</span>
        </div>
        <div class="dc-metrics">
          <div class="dcm"><span class="dcm-val">{{ d.visits }}</span><span class="dcm-lbl">визит./нед</span></div>
          <div class="dcm"><span class="dcm-val" :class="{ danger: d.noShowRate > 10 }">{{ d.noShowRate }}%</span><span class="dcm-lbl">no-show</span></div>
          <div class="dcm"><span class="dcm-val">{{ d.avgDuration }}</span><span class="dcm-lbl">мин/визит</span></div>
        </div>
        <div class="dc-load">
          <span class="dc-load-lbl">Загрузка</span>
          <div class="dc-load-track">
            <div class="dc-load-fill" :style="{ width: `${d.load}%` }" :class="d.load > 90 ? 'over' : d.load > 70 ? 'ok' : 'low'" />
          </div>
          <span class="dc-load-pct">{{ d.load }}%</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })
const mock = useMockData()
</script>

<style scoped>
.doc-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.doc-hero {
  background: linear-gradient(135deg, rgba(232,160,191,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(232,160,191,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.doc-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.doc-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.doc-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 12px; }
.doc-card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 18px; display: flex; flex-direction: column; gap: 14px; }

.dc-top { display: flex; align-items: center; gap: 10px; }
.dc-avatar { width: 36px; height: 36px; border-radius: 50%; background: rgba(139,126,200,0.1); color: var(--color-primary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.85rem; flex-shrink: 0; }
.dc-info { flex: 1; }
.dc-info h3 { font-size: 0.88rem; font-weight: 600; }
.dc-spec { font-size: 0.72rem; color: var(--color-text-muted); }
.dc-rating { font-size: 0.8rem; font-weight: 700; color: var(--color-warning); }

.dc-metrics { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; text-align: center; }
.dcm-val { display: block; font-size: 1rem; font-weight: 700; font-family: var(--font-mono); }
.dcm-val.danger { color: var(--color-danger); }
.dcm-lbl { font-size: 0.62rem; color: var(--color-text-muted); }

.dc-load { display: flex; align-items: center; gap: 8px; }
.dc-load-lbl { font-size: 0.72rem; color: var(--color-text-muted); width: 55px; }
.dc-load-track { flex: 1; height: 6px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
.dc-load-fill { height: 100%; border-radius: 3px; transition: width 0.4s; }
.dc-load-fill.low { background: rgba(168,200,232,0.5); }
.dc-load-fill.ok { background: var(--color-primary); }
.dc-load-fill.over { background: var(--color-danger); }
.dc-load-pct { font-size: 0.75rem; font-weight: 700; font-family: var(--font-mono); width: 36px; text-align: right; }
</style>

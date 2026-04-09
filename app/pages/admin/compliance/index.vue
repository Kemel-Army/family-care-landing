<template>
  <div class="comp-page">
    <div class="comp-hero">
      <NuxtLink to="/admin" class="back-link"><Icon name="lucide:chevron-left" size="16" /> Назад</NuxtLink>
      <h1 class="hero-title">Соблюдение протоколов</h1>
      <p class="hero-sub">Мониторинг качества медицинского обслуживания</p>
    </div>

    <!-- Overview -->
    <div class="overview-row">
      <div class="ring-card">
        <svg viewBox="0 0 120 120" class="ring-svg">
          <circle cx="60" cy="60" r="52" fill="none" stroke="var(--color-border-light)" stroke-width="8" />
          <circle cx="60" cy="60" r="52" fill="none" :stroke="ringColor" stroke-width="8"
            stroke-linecap="round" :stroke-dasharray="`${mock.complianceOverall * 3.27} 327`"
            transform="rotate(-90 60 60)" />
        </svg>
        <div class="ring-label">
          <span class="ring-value">{{ mock.complianceOverall }}%</span>
          <span class="ring-text">выполнение</span>
        </div>
      </div>
      <div class="summary-cards">
        <div class="sc"><span class="sc-val">68</span><span class="sc-lbl">Выполнено</span></div>
        <div class="sc warn"><span class="sc-val">7</span><span class="sc-lbl">Просрочено</span></div>
        <div class="sc"><span class="sc-val">14</span><span class="sc-lbl">Предстоит</span></div>
      </div>
    </div>

    <!-- Gaps -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:alert-circle" size="16" /> Выявленные пробелы</h2>
      <div class="gaps-list">
        <div v-for="(g, i) in gaps" :key="i" class="gap-row">
          <div class="gap-dot" :class="g.severity" />
          <div class="gap-info">
            <span class="gap-name">{{ g.title }}</span>
            <span class="gap-desc">{{ g.desc }}</span>
          </div>
          <span class="gap-count">{{ g.families }} семей</span>
        </div>
      </div>
    </div>

    <!-- Protocols -->
    <div class="card">
      <h2 class="card-title"><Icon name="lucide:shield-check" size="16" /> Мероприятия</h2>
      <div class="proto-list">
        <div v-for="p in mock.complianceProtocols" :key="p.name" class="proto-row">
          <span class="proto-name">{{ p.name }}</span>
          <div class="proto-track"><div class="proto-fill" :class="barClass(p.completion)" :style="{ width: `${p.completion}%` }" /></div>
          <span class="proto-pct">{{ p.completion }}%</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

const ringColor = computed(() => {
  if (mock.complianceOverall >= 80) return 'var(--color-success)'
  if (mock.complianceOverall >= 60) return 'var(--color-warning)'
  return 'var(--color-danger)'
})

function barClass(pct: number) { return pct >= 80 ? 'high' : pct >= 60 ? 'med' : 'low' }

const gaps = [
  { title: 'Пропущенный скрининг GDM', desc: 'Глюкозотолерантный тест на 24–28 нед.', families: 5, severity: 'critical' },
  { title: 'Задержка УЗИ II триместра', desc: 'Анатомическое УЗИ 18–22 нед.', families: 3, severity: 'warning' },
]
</script>

<style scoped>
.comp-page { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 16px; }

.comp-hero {
  background: linear-gradient(135deg, rgba(124,184,212,0.08), rgba(139,126,200,0.06));
  border: 1px solid rgba(124,184,212,0.12); border-radius: 16px; padding: 24px 28px;
}
.back-link { display: flex; align-items: center; gap: 4px; font-size: 0.75rem; color: var(--color-text-muted); text-decoration: none; margin-bottom: 8px; }
.hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }

.overview-row { display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
.ring-card { position: relative; width: 120px; height: 120px; flex-shrink: 0; }
.ring-svg { width: 100%; height: 100%; }
.ring-label { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; }
.ring-value { font-size: 1.5rem; font-weight: 800; font-family: var(--font-mono); }
.ring-text { font-size: 0.65rem; color: var(--color-text-muted); }

.summary-cards { display: flex; gap: 10px; }
.sc { background: white; border: 1px solid var(--color-border-light); border-radius: 12px; padding: 14px 18px; text-align: center; }
.sc.warn { border-color: rgba(212,114,124,0.3); }
.sc-val { display: block; font-size: 1.3rem; font-weight: 800; font-family: var(--font-mono); }
.sc-lbl { font-size: 0.68rem; color: var(--color-text-muted); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; margin-bottom: 14px; }

.gaps-list { display: flex; flex-direction: column; gap: 8px; }
.gap-row { display: flex; align-items: center; gap: 12px; padding: 10px 14px; background: rgba(0,0,0,0.01); border-radius: 10px; }
.gap-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.gap-dot.critical { background: var(--color-danger); }
.gap-dot.warning { background: var(--color-warning); }
.gap-name { font-size: 0.88rem; font-weight: 600; display: block; }
.gap-desc { font-size: 0.72rem; color: var(--color-text-muted); }
.gap-info { flex: 1; }
.gap-count { font-size: 0.72rem; color: var(--color-text-muted); font-family: var(--font-mono); white-space: nowrap; }

.proto-list { display: flex; flex-direction: column; gap: 8px; }
.proto-row { display: flex; align-items: center; gap: 12px; }
.proto-name { width: 180px; font-size: 0.82rem; flex-shrink: 0; }
.proto-track { flex: 1; height: 8px; background: var(--color-border-light); border-radius: 4px; overflow: hidden; }
.proto-fill { height: 100%; border-radius: 4px; transition: width 0.4s; }
.proto-fill.high { background: var(--color-success); }
.proto-fill.med { background: var(--color-warning); }
.proto-fill.low { background: var(--color-danger); }
.proto-pct { width: 40px; text-align: right; font-size: 0.78rem; font-family: var(--font-mono); font-weight: 600; }
</style>

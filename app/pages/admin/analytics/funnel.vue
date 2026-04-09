<template>
  <div class="analytics-page">
    <div class="page-header">
      <h1 class="page-title font-display">Воронка удержания</h1>
      <p class="page-desc">Где теряются семьи: от подключения до маршрута 12+ мес</p>
    </div>

    <div class="chart-card">
      <AppSharedEChart :option="funnelOption" height="380px" />
    </div>

    <div class="stages">
      <div v-for="stage in stages" :key="stage.name" class="stage-card">
        <div class="stage-header">
          <span class="stage-name">{{ stage.name }}</span>
          <span class="stage-val font-mono">{{ stage.count }}</span>
        </div>
        <div class="stage-bar">
          <div class="stage-bar-fill" :style="{ width: stage.pct + '%', background: stage.color }" />
        </div>
        <div class="stage-meta">
          <span>{{ stage.pct }}% от начала</span>
          <span v-if="stage.drop" class="stage-drop">-{{ stage.drop }}% dropout</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const stages = [
  { name: 'Подключение', count: 100, pct: 100, color: '#8B7EC8', drop: null },
  { name: 'Беременность (активны)', count: 88, pct: 88, color: '#A8C8E8', drop: 12 },
  { name: 'Роды (остались)', count: 72, pct: 72, color: '#E8A0BF', drop: 16 },
  { name: 'Младенец 0-6 мес', count: 65, pct: 65, color: '#F2C4A0', drop: 7 },
  { name: 'Малыш 6-12 мес', count: 58, pct: 58, color: '#7CB8D4', drop: 7 },
  { name: 'Тоддлер 12-24 мес', count: 52, pct: 52, color: '#E9C46A', drop: 6 },
]

const funnelOption = {
  tooltip: { trigger: 'item' as const },
  series: [{
    type: 'funnel',
    left: '10%',
    right: '10%',
    top: 20,
    bottom: 20,
    minSize: '20%',
    maxSize: '100%',
    sort: 'descending' as const,
    gap: 4,
    label: {
      show: true,
      position: 'inside' as const,
      formatter: '{b}: {c}',
      color: '#fff',
      fontSize: 13,
      fontWeight: 600,
    },
    itemStyle: { borderWidth: 0, borderRadius: 4 },
    data: stages.map(s => ({ name: s.name, value: s.count, itemStyle: { color: s.color } })),
  }],
}
</script>

<style scoped>
.analytics-page { max-width: 900px; margin: 0 auto; display: flex; flex-direction: column; gap: 20px; }
.page-header { margin-bottom: 4px; }
.page-title { font-size: var(--text-h2); color: var(--color-text-primary); margin: 0 0 4px; }
.page-desc { font-size: var(--text-sm); color: var(--color-text-muted); margin: 0; }
.chart-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-lg); padding: 24px; }
.stages { display: flex; flex-direction: column; gap: 8px; }
.stage-card { background: white; border: 1px solid var(--color-border-light); border-radius: var(--radius-md); padding: 14px 16px; }
.stage-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
.stage-name { font-size: var(--text-sm); font-weight: 600; color: var(--color-text-primary); }
.stage-val { font-size: var(--text-sm); font-weight: 700; color: var(--color-primary); }
.stage-bar { height: 6px; background: var(--color-border-light); border-radius: 3px; overflow: hidden; }
.stage-bar-fill { height: 100%; border-radius: 3px; transition: width 0.6s ease; }
.stage-meta { display: flex; justify-content: space-between; font-size: var(--text-xs); color: var(--color-text-muted); margin-top: 4px; }
.stage-drop { color: var(--color-danger); font-weight: 600; }
</style>

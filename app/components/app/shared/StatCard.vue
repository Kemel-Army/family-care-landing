<template>
  <div class="kpi-card" :class="[`kpi-card--${variant}`]">
    <div class="stat-card-header">
      <div class="stat-card-icon" :class="[`stat-card-icon--${variant}`]">
        <Icon :name="icon" size="20" />
      </div>
      <div v-if="trend !== undefined" class="stat-card-trend" :class="trendClass">
        <Icon :name="trendIcon" size="12" />
        {{ Math.abs(trend) }}%
      </div>
    </div>
    <div class="stat-card-value count-up-number">
      <span ref="valueEl">{{ prefix }}{{ displayValue }}{{ suffix }}</span>
    </div>
    <div class="stat-card-label">{{ label }}</div>
    <div v-if="sparkline.length" class="stat-card-sparkline">
      <svg :viewBox="`0 0 ${sparkline.length * 12} 28`" preserveAspectRatio="none">
        <polyline
          :points="sparklinePoints"
          fill="none"
          :stroke="sparklineColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  label: string
  value: number
  prefix?: string
  suffix?: string
  icon: string
  variant?: 'default' | 'warm' | 'blue' | 'success'
  trend?: number
  sparkline?: number[]
  animate?: boolean
}>(), {
  prefix: '',
  suffix: '',
  variant: 'default',
  sparkline: () => [],
  animate: true,
})

const valueEl = ref<HTMLElement>()
const displayValue = ref(props.animate ? 0 : props.value)

const trendClass = computed(() => {
  if (props.trend === undefined) return ''
  if (props.trend > 0) return 'trend-up'
  if (props.trend < 0) return 'trend-down'
  return 'trend-neutral'
})

const trendIcon = computed(() => {
  if (props.trend === undefined || props.trend === 0) return 'lucide:minus'
  return props.trend > 0 ? 'lucide:arrow-up-right' : 'lucide:arrow-down-right'
})

const sparklineColor = computed(() => {
  const colors: Record<string, string> = {
    default: '#8B7EC8',
    warm: '#E8A0BF',
    blue: '#A8C8E8',
    success: '#7CB8D4',
  }
  return colors[props.variant]
})

const sparklinePoints = computed(() => {
  if (!props.sparkline.length) return ''
  const max = Math.max(...props.sparkline)
  const min = Math.min(...props.sparkline)
  const range = max - min || 1
  return props.sparkline
    .map((v, i) => `${i * 12 + 6},${28 - ((v - min) / range) * 24 - 2}`)
    .join(' ')
})

let rafId: number
onMounted(() => {
  if (!props.animate) return
  const duration = 1200
  const start = performance.now()
  const target = props.value

  function tick(now: number) {
    const elapsed = now - start
    const progress = Math.min(elapsed / duration, 1)
    const eased = 1 - Math.pow(1 - progress, 3) // ease-out cubic
    displayValue.value = Math.round(eased * target)
    if (progress < 1) {
      rafId = requestAnimationFrame(tick)
    }
  }
  rafId = requestAnimationFrame(tick)
})

onUnmounted(() => {
  if (rafId) cancelAnimationFrame(rafId)
})

watch(() => props.value, (newVal) => {
  displayValue.value = newVal
})
</script>

<style scoped>
.stat-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.stat-card-icon {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-primary-ultralight);
  color: var(--color-primary);
}

.stat-card-icon--warm {
  background: rgba(232, 160, 191, 0.12);
  color: #D47EA5;
}

.stat-card-icon--blue {
  background: rgba(168, 200, 232, 0.15);
  color: #5A9ABF;
}

.stat-card-icon--success {
  background: rgba(124, 184, 212, 0.12);
  color: #4A9AB8;
}

.stat-card-value {
  font-size: 1.75rem;
  line-height: 1.2;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.stat-card-label {
  font-size: 0.8rem;
  color: var(--color-text-muted);
  font-weight: 500;
}

.stat-card-sparkline {
  margin-top: 12px;
  height: 28px;
  overflow: hidden;
}

.stat-card-sparkline svg {
  width: 100%;
  height: 100%;
}
</style>

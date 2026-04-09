<template>
  <div class="progress-ring-wrapper" :style="{ width: `${size}px`, height: `${size}px` }">
    <svg :width="size" :height="size" :viewBox="`0 0 ${size} ${size}`">
      <!-- Background circle -->
      <circle
        :cx="center"
        :cy="center"
        :r="radius"
        fill="none"
        :stroke="trackColor"
        :stroke-width="strokeWidth"
        stroke-linecap="round"
      />
      <!-- Progress arc -->
      <circle
        :cx="center"
        :cy="center"
        :r="radius"
        fill="none"
        :stroke="progressGradientUrl"
        :stroke-width="strokeWidth"
        stroke-linecap="round"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="dashOffset"
        class="progress-ring-circle"
        :style="{ transition: `stroke-dashoffset ${duration}ms cubic-bezier(0.4, 0, 0.2, 1)` }"
        transform-origin="center"
        :transform="`rotate(-90 ${center} ${center})`"
      />
      <!-- Gradient definition -->
      <defs>
        <linearGradient :id="gradientId" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" :stop-color="colorStart" />
          <stop offset="100%" :stop-color="colorEnd" />
        </linearGradient>
      </defs>
    </svg>
    <div class="progress-ring-content">
      <span class="progress-ring-value count-up-number">{{ displayPercent }}{{ showPercent ? '%' : '' }}</span>
      <span v-if="sublabel" class="progress-ring-sublabel">{{ sublabel }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  percent: number
  size?: number
  strokeWidth?: number
  variant?: 'primary' | 'warm' | 'blue' | 'success' | 'danger'
  sublabel?: string
  showPercent?: boolean
  animate?: boolean
  duration?: number
}>(), {
  size: 120,
  strokeWidth: 8,
  variant: 'primary',
  showPercent: true,
  animate: true,
  duration: 1200,
})

const uid = Math.random().toString(36).slice(2, 8)
const gradientId = `ring-grad-${uid}`
const progressGradientUrl = computed(() => `url(#${gradientId})`)

const center = computed(() => props.size / 2)
const radius = computed(() => (props.size - props.strokeWidth) / 2)
const circumference = computed(() => 2 * Math.PI * radius.value)
const trackColor = 'rgba(139, 126, 200, 0.08)'

const colorMap: Record<string, [string, string]> = {
  primary: ['#8B7EC8', '#B8ADE8'],
  warm: ['#E8A0BF', '#F2C4A0'],
  blue: ['#A8C8E8', '#7CB8D4'],
  success: ['#7CB8D4', '#A8C8E8'],
  danger: ['#D4727C', '#E8A0BF'],
}

const colorStart = computed(() => colorMap[props.variant]?.[0] ?? '#8B7EC8')
const colorEnd = computed(() => colorMap[props.variant]?.[1] ?? '#B8ADE8')

const animatedPercent = ref(props.animate ? 0 : props.percent)
const displayPercent = computed(() => Math.round(animatedPercent.value))

const dashOffset = computed(() => {
  const p = Math.min(Math.max(animatedPercent.value, 0), 100)
  return circumference.value * (1 - p / 100)
})

let rafId: number
onMounted(() => {
  if (!props.animate) return
  const start = performance.now()
  const target = props.percent
  function tick(now: number) {
    const elapsed = now - start
    const progress = Math.min(elapsed / props.duration, 1)
    const eased = 1 - Math.pow(1 - progress, 3)
    animatedPercent.value = eased * target
    if (progress < 1) {
      rafId = requestAnimationFrame(tick)
    }
  }
  rafId = requestAnimationFrame(tick)
})

onUnmounted(() => { if (rafId) cancelAnimationFrame(rafId) })

watch(() => props.percent, (v) => { animatedPercent.value = v })
</script>

<style scoped>
.progress-ring-wrapper {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.progress-ring-circle {
  will-change: stroke-dashoffset;
}

.progress-ring-content {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.progress-ring-value {
  font-size: 1.5rem;
  color: var(--color-text-primary);
}

.progress-ring-sublabel {
  font-size: 0.7rem;
  color: var(--color-text-muted);
  font-weight: 500;
  margin-top: 2px;
}
</style>

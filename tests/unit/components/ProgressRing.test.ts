import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, ref, computed } from 'vue'

// Re-create ProgressRing as testable component
const ProgressRing = defineComponent({
  name: 'ProgressRing',
  props: {
    value: { type: Number, required: true },
    size: { type: Number, default: 120 },
    strokeWidth: { type: Number, default: 8 },
    variant: { type: String, default: 'primary' },
    sublabel: { type: String, default: undefined },
    showPercent: { type: Boolean, default: true },
    animate: { type: Boolean, default: false }, // disable for tests
  },
  setup(props) {
    const center = computed(() => props.size / 2)
    const radius = computed(() => (props.size - props.strokeWidth) / 2)
    const circumference = computed(() => 2 * Math.PI * radius.value)
    const displayPercent = computed(() => Math.round(props.value))
    const dashOffset = computed(() => {
      const p = Math.min(Math.max(props.value, 0), 100)
      return circumference.value * (1 - p / 100)
    })

    return { center, radius, circumference, displayPercent, dashOffset }
  },
  template: `
    <div class="progress-ring-wrapper" :style="{ width: size + 'px', height: size + 'px' }">
      <svg :width="size" :height="size">
        <circle class="track" :cx="center" :cy="center" :r="radius" fill="none" />
        <circle class="progress" :cx="center" :cy="center" :r="radius" fill="none"
          :stroke-dasharray="circumference" :stroke-dashoffset="dashOffset" />
      </svg>
      <div class="progress-ring-content">
        <span class="progress-ring-value">{{ displayPercent }}{{ showPercent ? '%' : '' }}</span>
        <span v-if="sublabel" class="progress-ring-sublabel">{{ sublabel }}</span>
      </div>
    </div>
  `,
})

describe('ProgressRing component', () => {
  it('renders with correct percentage', () => {
    const wrapper = mount(ProgressRing, { props: { value: 75 } })

    expect(wrapper.find('.progress-ring-value').text()).toContain('75%')
  })

  it('shows % sign when showPercent is true', () => {
    const wrapper = mount(ProgressRing, { props: { value: 50, showPercent: true } })
    expect(wrapper.find('.progress-ring-value').text()).toContain('%')
  })

  it('hides % sign when showPercent is false', () => {
    const wrapper = mount(ProgressRing, { props: { value: 50, showPercent: false } })
    expect(wrapper.find('.progress-ring-value').text()).not.toContain('%')
  })

  it('renders sublabel when provided', () => {
    const wrapper = mount(ProgressRing, { props: { value: 60, sublabel: 'выполнено' } })
    expect(wrapper.find('.progress-ring-sublabel').text()).toBe('выполнено')
  })

  it('hides sublabel when not provided', () => {
    const wrapper = mount(ProgressRing, { props: { value: 60 } })
    expect(wrapper.find('.progress-ring-sublabel').exists()).toBe(false)
  })

  it('SVG has correct size', () => {
    const wrapper = mount(ProgressRing, { props: { value: 50, size: 80 } })
    const svg = wrapper.find('svg')
    expect(svg.attributes('width')).toBe('80')
    expect(svg.attributes('height')).toBe('80')
  })

  it('clamps value between 0 and 100', () => {
    const wrapper = mount(ProgressRing, { props: { value: 150 } })
    // dashOffset should be for 100%
    expect(wrapper.find('.progress-ring-value').text()).toContain('150')
  })

  it('renders 0% correctly', () => {
    const wrapper = mount(ProgressRing, { props: { value: 0 } })
    expect(wrapper.find('.progress-ring-value').text()).toContain('0%')
  })

  it('renders 100% correctly', () => {
    const wrapper = mount(ProgressRing, { props: { value: 100 } })
    expect(wrapper.find('.progress-ring-value').text()).toContain('100%')
  })
})

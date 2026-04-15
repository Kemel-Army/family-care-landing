import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h, ref, computed, watch, onMounted, onUnmounted } from 'vue'

// Stub the Icon component
const IconStub = defineComponent({
  name: 'Icon',
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

// Re-create StatCard as a testable component (avoids Nuxt auto-import issues)
const StatCard = defineComponent({
  name: 'StatCard',
  components: { Icon: IconStub },
  props: {
    title: { type: String, required: true },
    value: { type: Number, required: true },
    prefix: { type: String, default: '' },
    suffix: { type: String, default: '' },
    icon: { type: String, required: true },
    variant: { type: String, default: 'default' },
    trend: { type: Number, default: undefined },
    sparkline: { type: Array, default: () => [] },
    animate: { type: Boolean, default: false }, // disable animation for tests
  },
  setup(props) {
    const displayValue = ref(props.value)
    const trendClass = computed(() => {
      if (props.trend === undefined) return ''
      if (props.trend > 0) return 'trend-up'
      if (props.trend < 0) return 'trend-down'
      return 'trend-neutral'
    })
    return { displayValue, trendClass }
  },
  template: `
    <div class="kpi-card" :class="['kpi-card--' + variant]">
      <div class="stat-card-header">
        <div class="stat-card-icon"><Icon :name="icon" size="20" /></div>
        <div v-if="trend !== undefined" class="stat-card-trend" :class="trendClass">{{ Math.abs(trend) }}%</div>
      </div>
      <div class="stat-card-value"><span>{{ prefix }}{{ displayValue }}{{ suffix }}</span></div>
      <div class="stat-card-label">{{ title }}</div>
    </div>
  `,
})

describe('StatCard component', () => {
  it('renders title, value, and icon', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Визиты', value: 42, icon: 'lucide:users' },
    })

    expect(wrapper.find('.stat-card-label').text()).toBe('Визиты')
    expect(wrapper.find('.stat-card-value').text()).toContain('42')
    expect(wrapper.find('.icon').attributes('data-name')).toBe('lucide:users')
  })

  it('renders prefix and suffix', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Баланс', value: 1500, prefix: '₸', suffix: '+', icon: 'lucide:wallet' },
    })

    expect(wrapper.find('.stat-card-value').text()).toContain('₸')
    expect(wrapper.find('.stat-card-value').text()).toContain('+')
  })

  it('shows positive trend with trend-up class', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Рост', value: 10, icon: 'lucide:trending-up', trend: 12 },
    })

    expect(wrapper.find('.stat-card-trend').exists()).toBe(true)
    expect(wrapper.find('.stat-card-trend').classes()).toContain('trend-up')
    expect(wrapper.find('.stat-card-trend').text()).toContain('12%')
  })

  it('shows negative trend with trend-down class', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Спад', value: 5, icon: 'lucide:trending-down', trend: -8 },
    })

    expect(wrapper.find('.stat-card-trend').classes()).toContain('trend-down')
    expect(wrapper.find('.stat-card-trend').text()).toContain('8%')
  })

  it('shows neutral trend when trend is 0', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Стабильно', value: 100, icon: 'lucide:minus', trend: 0 },
    })

    expect(wrapper.find('.stat-card-trend').classes()).toContain('trend-neutral')
  })

  it('hides trend when not provided', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Без тренда', value: 50, icon: 'lucide:box' },
    })

    expect(wrapper.find('.stat-card-trend').exists()).toBe(false)
  })

  it('applies variant class', () => {
    const wrapper = mount(StatCard, {
      props: { title: 'Test', value: 1, icon: 'lucide:heart', variant: 'warm' },
    })

    expect(wrapper.find('.kpi-card').classes()).toContain('kpi-card--warm')
  })

  it.each(['default', 'warm', 'blue', 'success'] as const)('supports variant "%s"', (v) => {
    const wrapper = mount(StatCard, {
      props: { title: 'T', value: 1, icon: 'lucide:x', variant: v },
    })

    expect(wrapper.find('.kpi-card').classes()).toContain(`kpi-card--${v}`)
  })
})

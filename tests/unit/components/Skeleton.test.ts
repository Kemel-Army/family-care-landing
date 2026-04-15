import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent } from 'vue'

const Skeleton = defineComponent({
  name: 'Skeleton',
  props: {
    type: { type: String, default: 'text' },
    lines: { type: Number, default: 3 },
    width: { type: String, default: '100%' },
    height: { type: String, default: undefined },
    circle: { type: Boolean, default: false },
  },
  template: `
    <div class="skeleton" :class="['skeleton--' + type, { 'skeleton--circle': circle }]" :style="{ width, height }">
      <div v-if="type === 'text'" class="skeleton-lines">
        <div v-for="i in lines" :key="i" class="skeleton-line" :style="{ width: i === lines ? '60%' : '100%' }"></div>
      </div>
      <div v-else-if="type === 'card'" class="skeleton-card">
        <div class="skeleton-card-header"></div>
        <div class="skeleton-card-body">
          <div class="skeleton-line"></div>
          <div class="skeleton-line" style="width: 80%"></div>
        </div>
      </div>
      <div v-else-if="type === 'avatar'" class="skeleton-avatar"></div>
    </div>
  `,
})

describe('Skeleton component', () => {
  it('renders text skeleton with default 3 lines', () => {
    const wrapper = mount(Skeleton, { props: { type: 'text' } })

    expect(wrapper.find('.skeleton--text').exists()).toBe(true)
    expect(wrapper.findAll('.skeleton-line')).toHaveLength(3)
  })

  it('renders custom number of lines', () => {
    const wrapper = mount(Skeleton, { props: { type: 'text', lines: 5 } })
    expect(wrapper.findAll('.skeleton-line')).toHaveLength(5)
  })

  it('last line is shorter (60%)', () => {
    const wrapper = mount(Skeleton, { props: { type: 'text', lines: 3 } })
    const lines = wrapper.findAll('.skeleton-line')
    expect(lines[2].attributes('style')).toContain('60%')
  })

  it('renders card skeleton', () => {
    const wrapper = mount(Skeleton, { props: { type: 'card' } })

    expect(wrapper.find('.skeleton--card').exists()).toBe(true)
    expect(wrapper.find('.skeleton-card-header').exists()).toBe(true)
    expect(wrapper.find('.skeleton-card-body').exists()).toBe(true)
  })

  it('renders avatar skeleton', () => {
    const wrapper = mount(Skeleton, { props: { type: 'avatar' } })
    expect(wrapper.find('.skeleton-avatar').exists()).toBe(true)
  })

  it('applies circle class', () => {
    const wrapper = mount(Skeleton, { props: { type: 'avatar', circle: true } })
    expect(wrapper.find('.skeleton').classes()).toContain('skeleton--circle')
  })

  it('applies custom width and height', () => {
    const wrapper = mount(Skeleton, {
      props: { type: 'text', width: '200px', height: '40px' },
    })

    const style = wrapper.find('.skeleton').attributes('style')
    expect(style).toContain('width: 200px')
    expect(style).toContain('height: 40px')
  })
})

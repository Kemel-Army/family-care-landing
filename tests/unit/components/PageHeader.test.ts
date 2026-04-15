import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h } from 'vue'

const IconStub = defineComponent({
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

const PageHeader = defineComponent({
  name: 'PageHeader',
  components: { Icon: IconStub },
  props: {
    title: { type: String, required: true },
    subtitle: { type: String, default: undefined },
    icon: { type: String, default: undefined },
    breadcrumbs: { type: Array, default: () => [] },
  },
  template: `
    <div class="page-header">
      <div v-if="breadcrumbs.length" class="breadcrumbs">
        <span v-for="(crumb, i) in breadcrumbs" :key="i" class="breadcrumb-item">
          {{ crumb.label }}
          <span v-if="i < breadcrumbs.length - 1" class="breadcrumb-sep">/</span>
        </span>
      </div>
      <div class="page-header-row">
        <Icon v-if="icon" :name="icon" size="24" />
        <h1 class="page-title">{{ title }}</h1>
      </div>
      <p v-if="subtitle" class="page-subtitle">{{ subtitle }}</p>
    </div>
  `,
})

describe('PageHeader component', () => {
  it('renders title', () => {
    const wrapper = mount(PageHeader, {
      props: { title: 'Мои назначения' },
    })

    expect(wrapper.find('.page-title').text()).toBe('Мои назначения')
  })

  it('renders subtitle when provided', () => {
    const wrapper = mount(PageHeader, {
      props: { title: 'Dashboard', subtitle: 'Обзор за неделю' },
    })

    expect(wrapper.find('.page-subtitle').text()).toBe('Обзор за неделю')
  })

  it('hides subtitle when not provided', () => {
    const wrapper = mount(PageHeader, {
      props: { title: 'Dashboard' },
    })

    expect(wrapper.find('.page-subtitle').exists()).toBe(false)
  })

  it('renders icon when provided', () => {
    const wrapper = mount(PageHeader, {
      props: { title: 'Test', icon: 'lucide:home' },
    })

    expect(wrapper.find('.icon').exists()).toBe(true)
  })

  it('hides icon when not provided', () => {
    const wrapper = mount(PageHeader, {
      props: { title: 'Test' },
    })

    expect(wrapper.find('.icon').exists()).toBe(false)
  })

  it('renders breadcrumbs', () => {
    const wrapper = mount(PageHeader, {
      props: {
        title: 'Рецепты',
        breadcrumbs: [
          { label: 'Главная', to: '/' },
          { label: 'Семья', to: '/family' },
          { label: 'Рецепты' },
        ],
      },
    })

    const items = wrapper.findAll('.breadcrumb-item')
    expect(items).toHaveLength(3)
    expect(items[0].text()).toContain('Главная')
    expect(items[2].text()).toContain('Рецепты')
  })

  it('shows separators between breadcrumbs', () => {
    const wrapper = mount(PageHeader, {
      props: {
        title: 'Test',
        breadcrumbs: [{ label: 'A' }, { label: 'B' }, { label: 'C' }],
      },
    })

    const seps = wrapper.findAll('.breadcrumb-sep')
    expect(seps).toHaveLength(2)
  })

  it('hides breadcrumbs when empty', () => {
    const wrapper = mount(PageHeader, {
      props: { title: 'Test' },
    })

    expect(wrapper.find('.breadcrumbs').exists()).toBe(false)
  })
})

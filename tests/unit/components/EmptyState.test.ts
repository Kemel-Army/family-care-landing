import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h, computed } from 'vue'

const IconStub = defineComponent({
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

const EmptyState = defineComponent({
  name: 'EmptyState',
  components: { Icon: IconStub },
  props: {
    icon: { type: String, default: 'lucide:inbox' },
    title: { type: String, required: true },
    description: { type: String, default: '' },
    actionLabel: { type: String, default: undefined },
    actionIcon: { type: String, default: undefined },
    size: { type: String, default: 'default' },
  },
  emits: ['action'],
  template: `
    <div v-if="size === 'sm'" class="empty-state empty-state--sm">
      <Icon :name="icon" size="20" class="empty-state-sm-icon" />
      <span class="empty-state-sm-text">{{ title }}</span>
    </div>
    <div v-else class="empty-state">
      <div class="empty-state-icon"><Icon :name="icon" :size="36" /></div>
      <h3 class="empty-state-title">{{ title }}</h3>
      <p v-if="description" class="empty-state-description">{{ description }}</p>
      <button v-if="actionLabel" class="app-btn app-btn--primary app-btn--sm" @click="$emit('action')">
        <Icon v-if="actionIcon" :name="actionIcon" size="16" />
        {{ actionLabel }}
      </button>
    </div>
  `,
})

describe('EmptyState component', () => {
  it('renders title and icon', () => {
    const wrapper = mount(EmptyState, {
      props: { title: 'Нет данных', icon: 'lucide:inbox' },
    })

    expect(wrapper.find('.empty-state-title').text()).toBe('Нет данных')
    expect(wrapper.find('.icon').exists()).toBe(true)
  })

  it('renders description when provided', () => {
    const wrapper = mount(EmptyState, {
      props: { title: 'Пусто', description: 'Здесь будут ваши записи' },
    })

    expect(wrapper.find('.empty-state-description').text()).toBe('Здесь будут ваши записи')
  })

  it('hides description when empty', () => {
    const wrapper = mount(EmptyState, { props: { title: 'Пусто' } })
    expect(wrapper.find('.empty-state-description').exists()).toBe(false)
  })

  it('renders action button when actionLabel provided', () => {
    const wrapper = mount(EmptyState, {
      props: { title: 'Пусто', actionLabel: 'Добавить' },
    })

    expect(wrapper.find('.app-btn').text()).toContain('Добавить')
  })

  it('emits action event on button click', async () => {
    const wrapper = mount(EmptyState, {
      props: { title: 'Пусто', actionLabel: 'Добавить' },
    })

    await wrapper.find('.app-btn').trigger('click')
    expect(wrapper.emitted('action')).toHaveLength(1)
  })

  it('hides action button when no actionLabel', () => {
    const wrapper = mount(EmptyState, { props: { title: 'Пусто' } })
    expect(wrapper.find('.app-btn').exists()).toBe(false)
  })

  it('renders compact (sm) mode', () => {
    const wrapper = mount(EmptyState, {
      props: { title: 'Пусто', size: 'sm' },
    })

    expect(wrapper.find('.empty-state--sm').exists()).toBe(true)
    expect(wrapper.find('.empty-state-sm-text').text()).toBe('Пусто')
  })

  it('does not show full layout in sm mode', () => {
    const wrapper = mount(EmptyState, {
      props: { title: 'Пусто', size: 'sm' },
    })

    expect(wrapper.find('.empty-state-title').exists()).toBe(false)
  })
})

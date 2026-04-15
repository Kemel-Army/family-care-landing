import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h, computed } from 'vue'

const IconStub = defineComponent({
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

const EventCard = defineComponent({
  name: 'EventCard',
  components: { Icon: IconStub },
  props: {
    event: { type: Object, required: true },
    variant: { type: String, default: 'upcoming' },
  },
  emits: ['complete', 'skip'],
  setup(props) {
    const eventTypeLabel = computed(() => {
      const map: Record<string, string> = {
        checkup: 'Осмотр',
        screening: 'Скрининг',
        analysis: 'Анализ',
        ultrasound: 'УЗИ',
        vaccination: 'Прививка',
        education: 'Обучение',
      }
      return map[props.event.type] || props.event.type
    })
    return { eventTypeLabel }
  },
  template: `
    <div class="event-card" :class="[variant, { completed: event.status === 'completed' }]">
      <div class="event-status-dot" />
      <div class="event-content">
        <span class="event-type-badge">{{ eventTypeLabel }}</span>
        <h3 class="event-title">{{ event.title }}</h3>
        <p v-if="event.description" class="event-desc">{{ event.description }}</p>
        <span v-if="event.due_date" class="event-date">{{ event.due_date }}</span>
      </div>
      <div v-if="variant !== 'upcoming' && event.status !== 'completed'" class="event-actions">
        <button class="btn-complete" @click="$emit('complete', event.id)"><Icon name="lucide:check" size="16" /></button>
        <button class="btn-skip" @click="$emit('skip', event.id)"><Icon name="lucide:x" size="16" /></button>
      </div>
      <div v-else-if="event.status === 'completed'" class="event-done">
        <Icon name="lucide:check" size="16" />
      </div>
    </div>
  `,
})

describe('EventCard component', () => {
  const baseEvent = {
    id: 'e1',
    title: 'УЗИ 2 триместра',
    description: 'Плановое обследование',
    type: 'ultrasound',
    status: 'upcoming',
    due_date: '2026-05-15',
  }

  it('renders event title and type badge', () => {
    const wrapper = mount(EventCard, {
      props: { event: baseEvent },
    })

    expect(wrapper.find('.event-title').text()).toBe('УЗИ 2 триместра')
    expect(wrapper.find('.event-type-badge').text()).toBe('УЗИ')
  })

  it('renders description when present', () => {
    const wrapper = mount(EventCard, {
      props: { event: baseEvent },
    })

    expect(wrapper.find('.event-desc').text()).toBe('Плановое обследование')
  })

  it('hides description when absent', () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, description: undefined } },
    })

    expect(wrapper.find('.event-desc').exists()).toBe(false)
  })

  it('renders due date', () => {
    const wrapper = mount(EventCard, {
      props: { event: baseEvent },
    })

    expect(wrapper.find('.event-date').text()).toContain('2026-05-15')
  })

  it('applies overdue variant class', () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, status: 'overdue' }, variant: 'overdue' },
    })

    expect(wrapper.find('.event-card').classes()).toContain('overdue')
  })

  it('applies completed class', () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, status: 'completed' }, variant: 'today' },
    })

    expect(wrapper.find('.event-card').classes()).toContain('completed')
  })

  it('shows action buttons for non-upcoming non-completed events', () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, status: 'due' }, variant: 'today' },
    })

    expect(wrapper.find('.event-actions').exists()).toBe(true)
    expect(wrapper.find('.btn-complete').exists()).toBe(true)
    expect(wrapper.find('.btn-skip').exists()).toBe(true)
  })

  it('hides action buttons for upcoming variant', () => {
    const wrapper = mount(EventCard, {
      props: { event: baseEvent, variant: 'upcoming' },
    })

    expect(wrapper.find('.event-actions').exists()).toBe(false)
  })

  it('shows done check for completed events', () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, status: 'completed' }, variant: 'today' },
    })

    expect(wrapper.find('.event-done').exists()).toBe(true)
  })

  it('emits complete event on button click', async () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, status: 'due' }, variant: 'today' },
    })

    await wrapper.find('.btn-complete').trigger('click')
    expect(wrapper.emitted('complete')).toEqual([['e1']])
  })

  it('emits skip event on button click', async () => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, status: 'due' }, variant: 'today' },
    })

    await wrapper.find('.btn-skip').trigger('click')
    expect(wrapper.emitted('skip')).toEqual([['e1']])
  })

  it.each([
    ['checkup', 'Осмотр'],
    ['screening', 'Скрининг'],
    ['analysis', 'Анализ'],
    ['vaccination', 'Прививка'],
    ['education', 'Обучение'],
  ])('maps type "%s" to label "%s"', (type, label) => {
    const wrapper = mount(EventCard, {
      props: { event: { ...baseEvent, type } },
    })

    expect(wrapper.find('.event-type-badge').text()).toBe(label)
  })
})

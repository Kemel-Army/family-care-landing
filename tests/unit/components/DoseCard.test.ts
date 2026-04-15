import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h, computed } from 'vue'

const IconStub = defineComponent({
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

const DoseCard = defineComponent({
  name: 'DoseCard',
  components: { Icon: IconStub },
  props: {
    dose: { type: Object, required: true },
  },
  emits: ['confirm', 'skip'],
  setup(props) {
    const statusLabel = computed(() => {
      const map: Record<string, string> = {
        pending: 'Ожидает',
        confirmed: 'Принято',
        skipped: 'Пропущено',
        missed: 'Пропущено',
      }
      return map[props.dose.status] || props.dose.status
    })
    return { statusLabel }
  },
  template: `
    <div class="dose-card" :class="'dose-card--' + dose.status">
      <div class="dose-info">
        <span class="dose-medication">{{ dose.medication }}</span>
        <span class="dose-time">{{ dose.scheduled_time }}</span>
        <span class="dose-status">{{ statusLabel }}</span>
      </div>
      <div v-if="dose.status === 'pending'" class="dose-actions">
        <button class="btn-confirm" @click="$emit('confirm', dose.id)">
          <Icon name="lucide:check" size="16" /> Принять
        </button>
        <button class="btn-skip" @click="$emit('skip', dose.id)">
          <Icon name="lucide:x" size="16" /> Пропустить
        </button>
      </div>
    </div>
  `,
})

describe('DoseCard component', () => {
  const baseDose = {
    id: 'd1',
    medication: 'Витамин D3',
    scheduled_time: '08:00',
    status: 'pending',
  }

  it('renders medication name and time', () => {
    const wrapper = mount(DoseCard, { props: { dose: baseDose } })

    expect(wrapper.find('.dose-medication').text()).toBe('Витамин D3')
    expect(wrapper.find('.dose-time').text()).toBe('08:00')
  })

  it('shows status label', () => {
    const wrapper = mount(DoseCard, { props: { dose: baseDose } })
    expect(wrapper.find('.dose-status').text()).toBe('Ожидает')
  })

  it('shows action buttons for pending dose', () => {
    const wrapper = mount(DoseCard, { props: { dose: baseDose } })

    expect(wrapper.find('.dose-actions').exists()).toBe(true)
    expect(wrapper.find('.btn-confirm').exists()).toBe(true)
    expect(wrapper.find('.btn-skip').exists()).toBe(true)
  })

  it('hides action buttons for confirmed dose', () => {
    const wrapper = mount(DoseCard, {
      props: { dose: { ...baseDose, status: 'confirmed' } },
    })

    expect(wrapper.find('.dose-actions').exists()).toBe(false)
  })

  it('emits confirm event', async () => {
    const wrapper = mount(DoseCard, { props: { dose: baseDose } })

    await wrapper.find('.btn-confirm').trigger('click')
    expect(wrapper.emitted('confirm')).toEqual([['d1']])
  })

  it('emits skip event', async () => {
    const wrapper = mount(DoseCard, { props: { dose: baseDose } })

    await wrapper.find('.btn-skip').trigger('click')
    expect(wrapper.emitted('skip')).toEqual([['d1']])
  })

  it('applies status class to card', () => {
    const wrapper = mount(DoseCard, {
      props: { dose: { ...baseDose, status: 'confirmed' } },
    })

    expect(wrapper.find('.dose-card').classes()).toContain('dose-card--confirmed')
  })

  it.each([
    ['pending', 'Ожидает'],
    ['confirmed', 'Принято'],
    ['skipped', 'Пропущено'],
    ['missed', 'Пропущено'],
  ])('maps status "%s" to label "%s"', (status, label) => {
    const wrapper = mount(DoseCard, {
      props: { dose: { ...baseDose, status } },
    })

    expect(wrapper.find('.dose-status').text()).toBe(label)
  })
})

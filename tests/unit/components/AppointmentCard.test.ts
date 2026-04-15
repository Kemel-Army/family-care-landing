import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h, computed } from 'vue'

const IconStub = defineComponent({
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

const NuxtLinkStub = defineComponent({
  props: ['to'],
  render() { return h('a', { href: this.to, class: 'apt-link' }, this.$slots.default?.()) },
})

const AppointmentCard = defineComponent({
  name: 'AppointmentCard',
  components: { Icon: IconStub, NuxtLink: NuxtLinkStub },
  props: {
    appointment: { type: Object, required: true },
  },
  setup(props) {
    const statusLabel = computed(() => {
      const map: Record<string, string> = {
        requested: 'Ожидает',
        confirmed: 'Подтверждена',
        completed: 'Завершена',
        cancelled: 'Отменена',
        no_show: 'Неявка',
        rescheduled: 'Перенесена',
      }
      return map[props.appointment.status] || props.appointment.status
    })
    return { statusLabel }
  },
  template: `
    <div class="appointment-card">
      <div class="apt-content">
        <h4 class="apt-reason">{{ appointment.reason || 'Приём' }}</h4>
        <span class="apt-status-badge" :class="appointment.status">{{ statusLabel }}</span>
      </div>
      <NuxtLink :to="'/family/appointments/' + appointment.id" class="apt-link">
        <Icon name="lucide:chevron-right" size="16" />
      </NuxtLink>
    </div>
  `,
})

describe('AppointmentCard component', () => {
  const baseAppointment = {
    id: 'apt-1',
    reason: 'Плановый осмотр',
    status: 'confirmed',
    appointment_date: '2026-04-20',
    start_time: '10:30:00',
  }

  it('renders appointment reason', () => {
    const wrapper = mount(AppointmentCard, {
      props: { appointment: baseAppointment },
    })

    expect(wrapper.find('.apt-reason').text()).toBe('Плановый осмотр')
  })

  it('shows default reason "Приём" when none provided', () => {
    const wrapper = mount(AppointmentCard, {
      props: { appointment: { ...baseAppointment, reason: undefined } },
    })

    expect(wrapper.find('.apt-reason').text()).toBe('Приём')
  })

  it('renders status badge with correct label', () => {
    const wrapper = mount(AppointmentCard, {
      props: { appointment: baseAppointment },
    })

    expect(wrapper.find('.apt-status-badge').text()).toBe('Подтверждена')
    expect(wrapper.find('.apt-status-badge').classes()).toContain('confirmed')
  })

  it.each([
    ['requested', 'Ожидает'],
    ['confirmed', 'Подтверждена'],
    ['completed', 'Завершена'],
    ['cancelled', 'Отменена'],
    ['no_show', 'Неявка'],
    ['rescheduled', 'Перенесена'],
  ])('maps status "%s" to label "%s"', (status, label) => {
    const wrapper = mount(AppointmentCard, {
      props: { appointment: { ...baseAppointment, status } },
    })

    expect(wrapper.find('.apt-status-badge').text()).toBe(label)
  })

  it('renders link to appointment detail', () => {
    const wrapper = mount(AppointmentCard, {
      props: { appointment: baseAppointment },
    })

    expect(wrapper.find('a').attributes('href')).toBe('/family/appointments/apt-1')
  })
})

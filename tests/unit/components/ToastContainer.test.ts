import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h, ref, computed } from 'vue'

const IconStub = defineComponent({
  props: ['name', 'size'],
  render() { return h('i', { class: 'icon', 'data-name': this.name }) },
})

const ToastContainer = defineComponent({
  name: 'ToastContainer',
  components: { Icon: IconStub },
  props: {
    toasts: { type: Array, required: true },
  },
  emits: ['dismiss'],
  setup(props) {
    const iconMap: Record<string, string> = {
      success: 'lucide:check-circle',
      error: 'lucide:alert-circle',
      warning: 'lucide:alert-triangle',
      info: 'lucide:info',
    }
    return { iconMap }
  },
  template: `
    <div class="toast-container">
      <div v-for="toast in toasts" :key="toast.id"
        class="toast-item" :class="'toast-item--' + (toast.type || 'info')">
        <Icon :name="iconMap[toast.type || 'info']" size="20" />
        <span class="toast-message">{{ toast.message }}</span>
        <button class="toast-dismiss" @click="$emit('dismiss', toast.id)">
          <Icon name="lucide:x" size="14" />
        </button>
      </div>
    </div>
  `,
})

describe('ToastContainer component', () => {
  it('renders empty when no toasts', () => {
    const wrapper = mount(ToastContainer, {
      props: { toasts: [] },
    })

    expect(wrapper.findAll('.toast-item')).toHaveLength(0)
  })

  it('renders multiple toasts', () => {
    const wrapper = mount(ToastContainer, {
      props: {
        toasts: [
          { id: '1', message: 'Saved', type: 'success' },
          { id: '2', message: 'Error', type: 'error' },
        ],
      },
    })

    expect(wrapper.findAll('.toast-item')).toHaveLength(2)
  })

  it('renders toast message', () => {
    const wrapper = mount(ToastContainer, {
      props: {
        toasts: [{ id: '1', message: 'Данные сохранены', type: 'success' }],
      },
    })

    expect(wrapper.find('.toast-message').text()).toBe('Данные сохранены')
  })

  it('applies type class to toast', () => {
    const wrapper = mount(ToastContainer, {
      props: {
        toasts: [{ id: '1', message: 'Ошибка', type: 'error' }],
      },
    })

    expect(wrapper.find('.toast-item').classes()).toContain('toast-item--error')
  })

  it('defaults to info type', () => {
    const wrapper = mount(ToastContainer, {
      props: {
        toasts: [{ id: '1', message: 'Info' }],
      },
    })

    expect(wrapper.find('.toast-item').classes()).toContain('toast-item--info')
  })

  it('emits dismiss with toast id on close click', async () => {
    const wrapper = mount(ToastContainer, {
      props: {
        toasts: [{ id: 'abc', message: 'Test', type: 'warning' }],
      },
    })

    await wrapper.find('.toast-dismiss').trigger('click')
    expect(wrapper.emitted('dismiss')).toEqual([['abc']])
  })

  it.each(['success', 'error', 'warning', 'info'])('renders %s variant', (type) => {
    const wrapper = mount(ToastContainer, {
      props: {
        toasts: [{ id: '1', message: 'M', type }],
      },
    })

    expect(wrapper.find('.toast-item').classes()).toContain(`toast-item--${type}`)
  })
})

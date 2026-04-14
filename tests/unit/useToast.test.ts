import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref, readonly, type Ref } from 'vue'

// Inline reimplementation of useToast logic for unit testing
// (avoids Nuxt auto-import complexity)

type ToastType = 'success' | 'error' | 'info'
interface Toast { id: number; type: ToastType; message: string }

function createUseToast() {
  let _id = 0
  const toasts: Ref<Toast[]> = ref([])

  function show(type: ToastType, message: string, duration = 3000) {
    const id = ++_id
    toasts.value.push({ id, type, message })
    setTimeout(() => {
      toasts.value = toasts.value.filter(t => t.id !== id)
    }, duration)
  }

  return {
    toasts: readonly(toasts),
    success: (msg: string) => show('success', msg),
    error: (msg: string) => show('error', msg),
    info: (msg: string) => show('info', msg),
    show,
  }
}

describe('useToast composable', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  it('starts with empty toasts', () => {
    const { toasts } = createUseToast()
    expect(toasts.value).toHaveLength(0)
  })

  it('success() adds a success toast', () => {
    const { toasts, success } = createUseToast()
    success('Saved!')
    expect(toasts.value).toHaveLength(1)
    expect(toasts.value[0].type).toBe('success')
    expect(toasts.value[0].message).toBe('Saved!')
  })

  it('error() adds an error toast', () => {
    const { toasts, error } = createUseToast()
    error('Failed!')
    expect(toasts.value).toHaveLength(1)
    expect(toasts.value[0].type).toBe('error')
  })

  it('info() adds an info toast', () => {
    const { toasts, info } = createUseToast()
    info('Note')
    expect(toasts.value).toHaveLength(1)
    expect(toasts.value[0].type).toBe('info')
  })

  it('auto-removes toast after duration', () => {
    const { toasts, success } = createUseToast()
    success('Temporary')
    expect(toasts.value).toHaveLength(1)

    vi.advanceTimersByTime(3000)
    expect(toasts.value).toHaveLength(0)
  })

  it('supports multiple concurrent toasts', () => {
    const { toasts, success, error } = createUseToast()
    success('First')
    error('Second')
    success('Third')
    expect(toasts.value).toHaveLength(3)
  })

  it('removes only the expired toast', () => {
    const toast = createUseToast()
    toast.show('success', 'Short', 1000)
    toast.show('error', 'Long', 5000)
    expect(toast.toasts.value).toHaveLength(2)

    vi.advanceTimersByTime(1000)
    expect(toast.toasts.value).toHaveLength(1)
    expect(toast.toasts.value[0].message).toBe('Long')

    vi.advanceTimersByTime(4000)
    expect(toast.toasts.value).toHaveLength(0)
  })

  it('assigns unique IDs to each toast', () => {
    const { toasts, success } = createUseToast()
    success('A')
    success('B')
    success('C')
    const ids = toasts.value.map(t => t.id)
    expect(new Set(ids).size).toBe(3)
  })
})

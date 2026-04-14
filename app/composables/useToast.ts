type ToastType = 'success' | 'error' | 'info'

interface Toast {
  id: number
  type: ToastType
  message: string
}

let _id = 0
const toasts = ref<Toast[]>([])

export function useToast() {
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

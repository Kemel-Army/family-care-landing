import { ref, onMounted, onUnmounted } from 'vue'

interface TypewriterOptions {
  typeSpeed?: number
  deleteSpeed?: number
  pauseAfterType?: number
  pauseAfterDelete?: number
  loop?: boolean
}

export function useTypewriter(
  strings: string[],
  options?: TypewriterOptions
) {
  const typeSpeed = options?.typeSpeed ?? 80
  const deleteSpeed = options?.deleteSpeed ?? 40
  const pauseAfterType = options?.pauseAfterType ?? 2000
  const pauseAfterDelete = options?.pauseAfterDelete ?? 500
  const loop = options?.loop ?? true

  const displayText = ref('')
  const isTyping = ref(false)
  const isDone = ref(false)

  let timeoutId: ReturnType<typeof setTimeout> | null = null
  let currentIndex = 0
  let isDestroyed = false

  function sleep(ms: number): Promise<void> {
    return new Promise((resolve) => {
      timeoutId = setTimeout(resolve, ms)
    })
  }

  async function typeString(str: string) {
    isTyping.value = true
    for (let i = 0; i <= str.length; i++) {
      if (isDestroyed) return
      displayText.value = str.slice(0, i)
      await sleep(typeSpeed)
    }
    isTyping.value = false
  }

  async function deleteString() {
    isTyping.value = true
    const current = displayText.value
    for (let i = current.length; i >= 0; i--) {
      if (isDestroyed) return
      displayText.value = current.slice(0, i)
      await sleep(deleteSpeed)
    }
    isTyping.value = false
  }

  async function run() {
    if (isDestroyed || !strings.length) return

    // Respect reduced motion
    if (typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      displayText.value = strings[0] ?? ''
      isDone.value = true
      return
    }

    while (!isDestroyed) {
      await typeString(strings[currentIndex] ?? '')
      if (isDestroyed) return

      if (!loop && currentIndex === strings.length - 1) {
        isDone.value = true
        return
      }

      await sleep(pauseAfterType)
      if (isDestroyed) return

      await deleteString()
      if (isDestroyed) return

      await sleep(pauseAfterDelete)
      currentIndex = (currentIndex + 1) % strings.length
    }
  }

  onMounted(() => {
    run()
  })

  onUnmounted(() => {
    isDestroyed = true
    if (timeoutId) clearTimeout(timeoutId)
  })

  return { displayText, isTyping, isDone }
}

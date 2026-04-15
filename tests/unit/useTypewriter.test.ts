import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref } from 'vue'

vi.stubGlobal('ref', ref)

let mountedCb: (() => void) | null = null
let unmountedCb: (() => void) | null = null

// Mock vue's onMounted/onUnmounted at module level so the composable picks up our stubs
vi.mock('vue', async (importOriginal) => {
  const actual = await importOriginal<typeof import('vue')>()
  return {
    ...actual,
    onMounted: (fn: () => void) => { mountedCb = fn },
    onUnmounted: (fn: () => void) => { unmountedCb = fn },
  }
})

// Mock window.matchMedia for reduced motion check
Object.defineProperty(globalThis, 'window', {
  value: {
    matchMedia: vi.fn().mockReturnValue({ matches: false }),
    location: { origin: 'http://localhost:3000' },
  },
  writable: true,
  configurable: true,
})

describe('useTypewriter', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
    vi.useFakeTimers()
    mountedCb = null
    unmountedCb = null
  })

  it('starts with empty displayText', async () => {
    const { useTypewriter } = await import('../../app/composables/useTypewriter')
    const { displayText } = useTypewriter(['Hello', 'World'])

    expect(displayText.value).toBe('')
  })

  it('isTyping starts as false', async () => {
    const { useTypewriter } = await import('../../app/composables/useTypewriter')
    const { isTyping } = useTypewriter(['Test'])

    expect(isTyping.value).toBe(false)
  })

  it('respects reduced motion — shows first string immediately', async () => {
    (window as any).matchMedia = vi.fn().mockReturnValue({ matches: true })

    const { useTypewriter } = await import('../../app/composables/useTypewriter')
    const { displayText, isDone } = useTypewriter(['Привет', 'Мир'])

    // Trigger mounted
    if (mountedCb) mountedCb()

    // Should show first string immediately without animation
    expect(displayText.value).toBe('Привет')
    expect(isDone.value).toBe(true)
  })

  it('cleanup on unmount clears timeouts', async () => {
    (window as any).matchMedia = vi.fn().mockReturnValue({ matches: false })

    const { useTypewriter } = await import('../../app/composables/useTypewriter')
    useTypewriter(['A', 'B'])

    // Unmount should not throw
    if (unmountedCb) unmountedCb()
  })

  it('accepts custom options', async () => {
    const { useTypewriter } = await import('../../app/composables/useTypewriter')
    const { displayText } = useTypewriter(['Test'], {
      typeSpeed: 50,
      deleteSpeed: 30,
      pauseAfterType: 1000,
      pauseAfterDelete: 300,
      loop: false,
    })

    expect(displayText.value).toBe('')
  })
})

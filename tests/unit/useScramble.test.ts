import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref } from 'vue'

vi.stubGlobal('ref', ref)

const mockGsapTo = vi.fn().mockImplementation((_obj, opts) => {
  if (opts.onComplete) opts.onComplete()
})

let mountedCb: (() => void) | null = null
let unmountedCb: (() => void) | null = null
vi.stubGlobal('onMounted', (fn: () => void) => { mountedCb = fn })
vi.stubGlobal('onUnmounted', (fn: () => void) => { unmountedCb = fn })

// Mock useGsap
vi.mock('../../app/composables/useGsap', () => ({
  useGsap: () => ({
    gsap: { to: mockGsapTo },
    ScrollTrigger: null,
  }),
}))

Object.defineProperty(globalThis, 'window', {
  value: {
    matchMedia: vi.fn().mockReturnValue({ matches: false }),
    location: { origin: 'http://localhost:3000' },
    IntersectionObserver: vi.fn().mockImplementation(() => ({
      observe: vi.fn(),
      disconnect: vi.fn(),
    })),
  },
  writable: true,
  configurable: true,
})

describe('useScramble', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
    mountedCb = null
    unmountedCb = null
  })

  it('applies text to element on reduced motion', async () => {
    (window as any).matchMedia = vi.fn().mockReturnValue({ matches: true })

    const el = { textContent: '' } as HTMLElement
    const elRef = ref(el)

    const { useScramble } = await import('../../app/composables/useScramble')
    useScramble(elRef as any, '94%')

    if (mountedCb) mountedCb()

    expect(el.textContent).toBe('94%')
  })

  it('accepts custom options', async () => {
    const elRef = ref(null)

    const { useScramble } = await import('../../app/composables/useScramble')
    // Should not throw with null el
    useScramble(elRef as any, '100', {
      duration: 2,
      chars: '0123456789',
      revealSpeed: 5,
    })

    if (mountedCb) mountedCb()
    // With null ref, nothing should happen
  })
})

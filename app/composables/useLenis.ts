import { initGsap } from './useGsap'

let lenisInstance: any = null

export function useLenis() {
  return { lenis: lenisInstance }
}

export async function initLenis() {
  if (!import.meta.client) return { lenis: null }
  if (lenisInstance) return { lenis: lenisInstance }

  const { gsap, ScrollTrigger } = await initGsap()
  const { default: Lenis } = await import('lenis')

  lenisInstance = new Lenis({
    duration: 1.2,
    easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
    touchMultiplier: 1.5,
    infinite: false,
  })

  lenisInstance.on('scroll', ScrollTrigger.update)

  gsap.ticker.add((time: number) => {
    lenisInstance?.raf(time * 1000)
  })

  gsap.ticker.lagSmoothing(0)

  return { lenis: lenisInstance }
}

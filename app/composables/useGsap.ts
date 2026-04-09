let gsapModule: any = null
let scrollTriggerModule: any = null
let registered = false

export function useGsap() {
  return { gsap: gsapModule, ScrollTrigger: scrollTriggerModule }
}

export async function initGsap() {
  if (registered) return { gsap: gsapModule, ScrollTrigger: scrollTriggerModule }
  if (!import.meta.client) return { gsap: null, ScrollTrigger: null }

  const [{ gsap }, { ScrollTrigger }] = await Promise.all([
    import('gsap'),
    import('gsap/ScrollTrigger'),
  ])
  gsap.registerPlugin(ScrollTrigger)
  gsapModule = gsap
  scrollTriggerModule = ScrollTrigger
  registered = true
  return { gsap, ScrollTrigger }
}

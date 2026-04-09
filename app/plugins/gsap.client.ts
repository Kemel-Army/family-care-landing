import { initGsap } from '~/composables/useGsap'
import { initLenis } from '~/composables/useLenis'

export default defineNuxtPlugin(async () => {
  await initGsap()
  await initLenis()
})

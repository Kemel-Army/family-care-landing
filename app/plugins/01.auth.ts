// Plugin to initialize auth store — runs on both SSR and client
export default defineNuxtPlugin(async () => {
  const user = useSupabaseUser()
  const authStore = useAuthStore()

  const getUserId = () => (user.value as any)?.id ?? (user.value as any)?.sub

  // Try immediate init if user is available
  if (getUserId() && !authStore.initialized) {
    await authStore.initialize()
  }

  // On client: watch for user becoming available after hydration
  if (import.meta.client) {
    watch(user, async (newUser) => {
      const uid = (newUser as any)?.id ?? (newUser as any)?.sub
      if (uid && !authStore.initialized) {
        await authStore.initialize()
      }
      if (!newUser) {
        authStore.reset()
      }
    })
  }
})

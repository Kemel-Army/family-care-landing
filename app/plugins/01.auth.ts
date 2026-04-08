// Plugin to initialize auth store — runs on both SSR and client
export default defineNuxtPlugin(async () => {
  const user = useSupabaseUser()
  const authStore = useAuthStore()

  // Try immediate init if user is available
  if (user.value?.id && !authStore.initialized) {
    await authStore.initialize()
  }

  // On client: watch for user becoming available after hydration
  if (import.meta.client) {
    watch(user, async (newUser) => {
      if (newUser?.id && !authStore.initialized) {
        await authStore.initialize()
      }
      if (!newUser) {
        authStore.reset()
      }
    })
  }
})

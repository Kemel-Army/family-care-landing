// Role middleware — checks if user has the required role for the route
import { ROUTE_ROLE_MAP, ROLE_HOME_MAP } from '~/utils/constants'

export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  if (!user.value) return // auth middleware handles this

  const authStore = useAuthStore()
  if (!authStore.initialized) {
    await authStore.initialize()
  }

  const role = authStore.role

  // Check route prefix against role map
  for (const [prefix, allowedRoles] of Object.entries(ROUTE_ROLE_MAP)) {
    if (to.path.startsWith(prefix)) {
      if (!allowedRoles.includes(role)) {
        // Redirect to user's home based on their role
        return navigateTo(ROLE_HOME_MAP[role] || '/family', { replace: true })
      }
      break
    }
  }
})

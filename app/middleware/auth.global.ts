// Auth middleware — redirects unauthenticated users to login
export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()

  // Public routes that don't need auth
  const publicPaths = ['/', '/for-clinics', '/for-families', '/auth', '/demo']
  const isPublic = publicPaths.some(p => to.path === p || to.path.startsWith(p + '/'))

  if (isPublic) return

  if (!user.value) {
    return navigateTo('/auth/login', { replace: true })
  }
})

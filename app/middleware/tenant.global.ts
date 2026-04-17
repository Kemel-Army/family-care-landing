// Tenant middleware — determines clinic from subdomain or user metadata
export default defineNuxtRouteMiddleware((to) => {
  // Skip for public landing pages
  const publicPaths = ['/', '/for-clinics', '/for-families', '/auth']
  const isPublic = publicPaths.some(p => to.path === p || to.path.startsWith(p + '/'))
  if (isPublic) return

  // In production: extract clinic slug from subdomain
  // e.g. clinic-name.umai-health.kz → clinic-name
  // For now, use user metadata or default
  const user = useSupabaseUser()
  if (!user.value) return

  const clinicId = user.value.user_metadata?.clinic_id
  if (!clinicId) {
    // User not assigned to a clinic — redirect to onboarding or error
    // For now, allow access (will be handled by data queries)
  }
})

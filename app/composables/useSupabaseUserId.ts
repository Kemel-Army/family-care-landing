/**
 * Get the user ID from useSupabaseUser().
 *
 * On SSR, @nuxtjs/supabase v2 returns the decoded JWT payload where the
 * user ID lives in `sub`. On client-side after hydration, it returns the
 * full Supabase User object where the ID lives in `id`.
 *
 * This helper normalises the access so every consumer works in both contexts.
 */
export function useSupabaseUserId(): ComputedRef<string | undefined> {
  const user = useSupabaseUser()
  return computed(() => {
    const u = user.value as any
    return u?.id ?? u?.sub
  })
}

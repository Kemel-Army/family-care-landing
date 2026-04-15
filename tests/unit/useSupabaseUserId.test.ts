import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref, computed } from 'vue'

vi.stubGlobal('ref', ref)
vi.stubGlobal('computed', computed)

describe('useSupabaseUserId', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
  })

  it('returns id when client-side user has id', async () => {
    vi.stubGlobal('useSupabaseUser', () => ref({ id: 'user-123', email: 'a@b.com' }))

    const { useSupabaseUserId } = await import('../../app/composables/useSupabaseUserId')
    const userId = useSupabaseUserId()

    expect(userId.value).toBe('user-123')
  })

  it('returns sub when SSR JWT has sub', async () => {
    vi.stubGlobal('useSupabaseUser', () => ref({ sub: 'jwt-sub-456' }))

    const { useSupabaseUserId } = await import('../../app/composables/useSupabaseUserId')
    const userId = useSupabaseUserId()

    expect(userId.value).toBe('jwt-sub-456')
  })

  it('prefers id over sub', async () => {
    vi.stubGlobal('useSupabaseUser', () => ref({ id: 'user-id', sub: 'jwt-sub' }))

    const { useSupabaseUserId } = await import('../../app/composables/useSupabaseUserId')
    const userId = useSupabaseUserId()

    expect(userId.value).toBe('user-id')
  })

  it('returns undefined when no user', async () => {
    vi.stubGlobal('useSupabaseUser', () => ref(null))

    const { useSupabaseUserId } = await import('../../app/composables/useSupabaseUserId')
    const userId = useSupabaseUserId()

    expect(userId.value).toBeUndefined()
  })
})

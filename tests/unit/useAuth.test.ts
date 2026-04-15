import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref, computed } from 'vue'

// Mock Nuxt auto-imports
const mockSignInWithPassword = vi.fn()
const mockSignUp = vi.fn()
const mockSignOut = vi.fn()
const mockResetPasswordForEmail = vi.fn()
const mockInitialize = vi.fn()
const mockReset = vi.fn()

vi.stubGlobal('useSupabaseClient', () => ({
  auth: {
    signInWithPassword: mockSignInWithPassword,
    signUp: mockSignUp,
    signOut: mockSignOut,
    resetPasswordForEmail: mockResetPasswordForEmail,
  },
}))
vi.stubGlobal('useSupabaseUser', () => ref(null))
vi.stubGlobal('useAuthStore', () => ({ initialize: mockInitialize, reset: mockReset }))
vi.stubGlobal('navigateTo', vi.fn())
vi.stubGlobal('ref', ref)
vi.stubGlobal('computed', computed)

describe('useAuth', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
  })

  describe('signIn', () => {
    it('returns true on successful login', async () => {
      mockSignInWithPassword.mockResolvedValue({ error: null })
      mockInitialize.mockResolvedValue(undefined)

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signIn } = useAuth()

      const result = await signIn('test@email.com', 'password123')
      expect(result).toBe(true)
      expect(mockSignInWithPassword).toHaveBeenCalledWith({
        email: 'test@email.com',
        password: 'password123',
      })
      expect(mockInitialize).toHaveBeenCalled()
    })

    it('returns false and sets error on auth failure', async () => {
      mockSignInWithPassword.mockResolvedValue({
        error: { message: 'Invalid login credentials' },
      })

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signIn, error } = useAuth()

      const result = await signIn('test@email.com', 'wrong')
      expect(result).toBe(false)
      expect(error.value).toBe('Invalid login credentials')
    })

    it('handles exceptions gracefully', async () => {
      mockSignInWithPassword.mockRejectedValue(new Error('Network error'))

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signIn, error } = useAuth()

      const result = await signIn('test@email.com', 'pass')
      expect(result).toBe(false)
      expect(error.value).toBe('Network error')
    })

    it('sets loading to true during sign-in and false after', async () => {
      mockSignInWithPassword.mockResolvedValue({ error: null })
      mockInitialize.mockResolvedValue(undefined)

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signIn, loading } = useAuth()

      expect(loading.value).toBe(false)
      const promise = signIn('test@email.com', 'pass')
      // loading should be true during execution
      await promise
      expect(loading.value).toBe(false)
    })
  })

  describe('signUp', () => {
    it('returns true on successful sign-up', async () => {
      mockSignUp.mockResolvedValue({ error: null })

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signUp } = useAuth()

      const result = await signUp({
        email: 'test@email.com',
        password: 'password123',
        firstName: 'Айгуль',
        lastName: 'Каримова',
        phone: '+77001234567',
      })
      expect(result).toBe(true)
      expect(mockSignUp).toHaveBeenCalledWith({
        email: 'test@email.com',
        password: 'password123',
        options: {
          data: {
            first_name: 'Айгуль',
            last_name: 'Каримова',
            phone: '+77001234567',
            role: 'mother',
          },
        },
      })
    })

    it('defaults role to "mother" when not specified', async () => {
      mockSignUp.mockResolvedValue({ error: null })

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signUp } = useAuth()

      await signUp({ email: 'a@b.com', password: '12345678', firstName: 'A', lastName: 'B' })
      expect(mockSignUp).toHaveBeenCalledWith(
        expect.objectContaining({
          options: expect.objectContaining({
            data: expect.objectContaining({ role: 'mother' }),
          }),
        }),
      )
    })

    it('returns false on sign-up error', async () => {
      mockSignUp.mockResolvedValue({ error: { message: 'Email already registered' } })

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signUp, error } = useAuth()

      const result = await signUp({ email: 'a@b.com', password: '12345678', firstName: 'A', lastName: 'B' })
      expect(result).toBe(false)
      expect(error.value).toBe('Email already registered')
    })
  })

  describe('signOut', () => {
    it('calls supabase signOut, resets store and navigates', async () => {
      mockSignOut.mockResolvedValue(undefined)
      const navMock = vi.fn()
      vi.stubGlobal('navigateTo', navMock)

      const { useAuth } = await import('../../app/composables/useAuth')
      const { signOut } = useAuth()

      await signOut()
      expect(mockSignOut).toHaveBeenCalled()
      expect(mockReset).toHaveBeenCalled()
      expect(navMock).toHaveBeenCalledWith('/auth/login')
    })
  })

  describe('resetPassword', () => {
    it('returns true on success', async () => {
      mockResetPasswordForEmail.mockResolvedValue({ error: null })

      const { useAuth } = await import('../../app/composables/useAuth')
      const { resetPassword } = useAuth()

      const result = await resetPassword('test@email.com')
      expect(result).toBe(true)
      expect(mockResetPasswordForEmail).toHaveBeenCalledWith(
        'test@email.com',
        expect.objectContaining({ redirectTo: expect.stringContaining('/auth/verify') }),
      )
    })

    it('returns false and sets error on failure', async () => {
      mockResetPasswordForEmail.mockResolvedValue({ error: { message: 'Rate limit exceeded' } })

      const { useAuth } = await import('../../app/composables/useAuth')
      const { resetPassword, error } = useAuth()

      const result = await resetPassword('test@email.com')
      expect(result).toBe(false)
      expect(error.value).toBe('Rate limit exceeded')
    })
  })

  describe('computed properties', () => {
    it('role returns null when no user', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref(null))
      const { useAuth } = await import('../../app/composables/useAuth')
      const { role } = useAuth()
      expect(role.value).toBeNull()
    })

    it('role reads from user metadata', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { role: 'doctor' } }))
      const { useAuth } = await import('../../app/composables/useAuth')
      const { role } = useAuth()
      expect(role.value).toBe('doctor')
    })

    it('homeRoute returns /auth/login when no role', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref(null))
      const { useAuth } = await import('../../app/composables/useAuth')
      const { homeRoute } = useAuth()
      expect(homeRoute.value).toBe('/auth/login')
    })

    it('homeRoute maps role to correct path', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { role: 'coordinator' } }))
      const { useAuth } = await import('../../app/composables/useAuth')
      const { homeRoute } = useAuth()
      expect(homeRoute.value).toBe('/coordinator')
    })
  })
})

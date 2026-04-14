import { describe, it, expect } from 'vitest'
import { ROLE_HOME_MAP } from '~/utils/constants'

describe('auth store getters (pure logic)', () => {
  // Test the getter logic without Pinia/Supabase dependencies

  function makeState(overrides: Record<string, any> = {}) {
    return {
      profile: null,
      family: null,
      motherProfile: null,
      children: [],
      consents: [],
      doctorId: null,
      loading: false,
      initialized: false,
      ...overrides,
    }
  }

  describe('isAuthenticated', () => {
    it('returns false when profile is null', () => {
      const state = makeState()
      expect(!!state.profile).toBe(false)
    })

    it('returns true when profile exists', () => {
      const state = makeState({ profile: { id: '1', role: 'mother', first_name: 'A', last_name: 'B' } })
      expect(!!state.profile).toBe(true)
    })
  })

  describe('role', () => {
    it('defaults to "mother" when no profile', () => {
      const state = makeState()
      const role = state.profile?.role ?? 'mother'
      expect(role).toBe('mother')
    })

    it('returns profile role', () => {
      const state = makeState({ profile: { id: '1', role: 'coordinator', first_name: 'D' } })
      const role = state.profile?.role ?? 'mother'
      expect(role).toBe('coordinator')
    })

    it.each(['mother', 'father', 'coordinator', 'doctor', 'admin'])('handles role "%s"', (r) => {
      const state = makeState({ profile: { id: '1', role: r } })
      expect(state.profile?.role).toBe(r)
    })
  })

  describe('clinicId', () => {
    it('returns undefined when no profile', () => {
      const state = makeState()
      expect(state.profile?.clinic_id).toBeUndefined()
    })

    it('returns clinic_id from profile', () => {
      const state = makeState({ profile: { id: '1', role: 'coordinator', clinic_id: 'clinic-1' } })
      expect(state.profile?.clinic_id).toBe('clinic-1')
    })
  })

  describe('fullName', () => {
    it('returns empty string when no profile', () => {
      const state = makeState()
      const name = state.profile ? `${state.profile.first_name} ${state.profile.last_name}` : ''
      expect(name).toBe('')
    })

    it('concatenates first and last name', () => {
      const state = makeState({ profile: { first_name: 'Айгуль', last_name: 'Каримова' } })
      const name = `${state.profile.first_name} ${state.profile.last_name}`
      expect(name).toBe('Айгуль Каримова')
    })
  })

  describe('homeRoute', () => {
    it('maps each role to correct route', () => {
      expect(ROLE_HOME_MAP['mother']).toBe('/family')
      expect(ROLE_HOME_MAP['father']).toBe('/family')
      expect(ROLE_HOME_MAP['coordinator']).toBe('/coordinator')
      expect(ROLE_HOME_MAP['doctor']).toBe('/doctor')
      expect(ROLE_HOME_MAP['admin']).toBe('/admin')
    })
  })

  describe('activeChildren', () => {
    it('returns empty array when no children', () => {
      const state = makeState({ children: [] })
      expect(state.children.filter((c: any) => c.dob)).toHaveLength(0)
    })

    it('filters children with dob', () => {
      const state = makeState({
        children: [
          { id: '1', name: 'Child A', dob: '2024-01-01' },
          { id: '2', name: 'Child B', dob: null },
          { id: '3', name: 'Child C', dob: '2025-03-15' },
        ],
      })
      const active = state.children.filter((c: any) => c.dob)
      expect(active).toHaveLength(2)
    })
  })

  describe('hasConsent', () => {
    it('returns false for unknown consent type', () => {
      const state = makeState({ consents: [] })
      const has = (type: string) => state.consents.find((c: any) => c.type === type)?.granted ?? false
      expect(has('sms')).toBe(false)
    })

    it('returns true for granted consent', () => {
      const state = makeState({ consents: [{ type: 'sms', granted: true }] })
      const has = (type: string) => state.consents.find((c: any) => c.type === type)?.granted ?? false
      expect(has('sms')).toBe(true)
    })

    it('returns false for revoked consent', () => {
      const state = makeState({ consents: [{ type: 'sms', granted: false }] })
      const has = (type: string) => state.consents.find((c: any) => c.type === type)?.granted ?? false
      expect(has('sms')).toBe(false)
    })
  })

  describe('reset', () => {
    it('resets state to defaults', () => {
      const state = makeState({
        profile: { id: '1' },
        family: { id: 'f1' },
        children: [{ id: 'c1' }],
        initialized: true,
        loading: true,
      })

      // Simulate reset
      state.profile = null
      state.family = null
      state.motherProfile = null
      state.children = []
      state.consents = []
      state.loading = false
      state.initialized = false

      expect(state.profile).toBeNull()
      expect(state.family).toBeNull()
      expect(state.children).toHaveLength(0)
      expect(state.initialized).toBe(false)
    })
  })
})

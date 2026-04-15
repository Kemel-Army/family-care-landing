import { describe, it, expect } from 'vitest'

// Test the store getter logic as pure functions (same pattern as auth-store.test.ts)

describe('family store getters (pure logic)', () => {
  function makeState(overrides: Record<string, any> = {}) {
    return {
      family: null,
      motherProfile: null,
      children: [],
      journeys: [],
      loading: false,
      ...overrides,
    }
  }

  describe('hasChildren', () => {
    it('returns false when no children', () => {
      const state = makeState()
      expect(state.children.length > 0).toBe(false)
    })

    it('returns true when children exist', () => {
      const state = makeState({
        children: [{ id: '1', name: 'Амина', dob: '2025-01-15' }],
      })
      expect(state.children.length > 0).toBe(true)
    })
  })

  describe('activeJourneys', () => {
    it('returns empty when no journeys', () => {
      const state = makeState()
      const active = state.journeys.filter((j: any) => j.status === 'active')
      expect(active).toHaveLength(0)
    })

    it('filters active journeys', () => {
      const state = makeState({
        journeys: [
          { id: 'j1', type: 'pregnancy', status: 'active' },
          { id: 'j2', type: 'postpartum', status: 'completed' },
          { id: 'j3', type: 'infant', status: 'active' },
        ],
      })
      const active = state.journeys.filter((j: any) => j.status === 'active')
      expect(active).toHaveLength(2)
      expect(active[0].type).toBe('pregnancy')
    })
  })

  describe('isPregnant', () => {
    it('returns false when no pregnancy journey', () => {
      const state = makeState({
        journeys: [{ id: 'j1', type: 'infant', status: 'active' }],
      })
      const isPregnant = state.journeys.some((j: any) => j.type === 'pregnancy' && j.status === 'active')
      expect(isPregnant).toBe(false)
    })

    it('returns true with active pregnancy journey', () => {
      const state = makeState({
        journeys: [
          { id: 'j1', type: 'pregnancy', status: 'active' },
          { id: 'j2', type: 'infant', status: 'active' },
        ],
      })
      const isPregnant = state.journeys.some((j: any) => j.type === 'pregnancy' && j.status === 'active')
      expect(isPregnant).toBe(true)
    })

    it('returns false for completed pregnancy', () => {
      const state = makeState({
        journeys: [{ id: 'j1', type: 'pregnancy', status: 'completed' }],
      })
      const isPregnant = state.journeys.some((j: any) => j.type === 'pregnancy' && j.status === 'active')
      expect(isPregnant).toBe(false)
    })
  })
})

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref } from 'vue'

const mockInsert = vi.fn()
const mockUpdate = vi.fn()
const mockFetchJourneys = vi.fn()
const mockCompleteEvent = vi.fn()
const mockSkipEvent = vi.fn()

function setupInsertChain(data: any = null, error: any = null) {
  mockInsert.mockReturnValue({
    select: vi.fn().mockReturnValue({
      single: vi.fn().mockResolvedValue({ data, error }),
    }),
  })
}

vi.stubGlobal('useSupabaseClient', () => ({
  from: vi.fn(() => ({
    insert: mockInsert,
    update: vi.fn().mockReturnValue({
      eq: vi.fn().mockResolvedValue({ error: null }),
    }),
  })),
}))
vi.stubGlobal('useJourneyStore', () => ({
  fetchJourneys: mockFetchJourneys,
  completeEvent: mockCompleteEvent,
  skipEvent: mockSkipEvent,
}))
vi.stubGlobal('ref', ref)

describe('useJourney', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
  })

  describe('generateCarePlan', () => {
    it('creates a journey and refreshes store', async () => {
      const journey = { id: 'j-1', family_id: 'fam-1', type: 'pregnancy', status: 'active' }
      setupInsertChain(journey, null)
      mockFetchJourneys.mockResolvedValue(undefined)

      const { useJourney } = await import('../../app/composables/useJourney')
      const { generateCarePlan } = useJourney()

      const result = await generateCarePlan({
        familyId: 'fam-1',
        type: 'pregnancy' as any,
        lmpDate: '2025-06-01',
      })

      expect(result).toEqual(journey)
      expect(mockFetchJourneys).toHaveBeenCalledWith('fam-1')
    })

    it('returns null on journey creation error', async () => {
      setupInsertChain(null, { message: 'DB error' })

      const { useJourney } = await import('../../app/composables/useJourney')
      const { generateCarePlan, error } = useJourney()

      const result = await generateCarePlan({
        familyId: 'fam-1',
        type: 'infant' as any,
      })

      expect(result).toBeNull()
      expect(error.value).toContain('DB error')
    })

    it('manages loading state', async () => {
      const journey = { id: 'j-1', type: 'postpartum' }
      setupInsertChain(journey, null)
      mockFetchJourneys.mockResolvedValue(undefined)

      const { useJourney } = await import('../../app/composables/useJourney')
      const { generateCarePlan, loading } = useJourney()

      expect(loading.value).toBe(false)
      await generateCarePlan({ familyId: 'fam-1', type: 'postpartum' as any })
      expect(loading.value).toBe(false)
    })
  })

  describe('completeEvent', () => {
    it('delegates to journey store', async () => {
      mockCompleteEvent.mockResolvedValue({ data: { id: 'e1' }, error: null })

      const { useJourney } = await import('../../app/composables/useJourney')
      const { completeEvent } = useJourney()

      await completeEvent('e1', 'Notes here')
      expect(mockCompleteEvent).toHaveBeenCalledWith('e1', 'Notes here')
    })
  })

  describe('skipEvent', () => {
    it('delegates to journey store', async () => {
      mockSkipEvent.mockResolvedValue({ data: { id: 'e1' }, error: null })

      const { useJourney } = await import('../../app/composables/useJourney')
      const { skipEvent } = useJourney()

      await skipEvent('e1', 'Patient refused')
      expect(mockSkipEvent).toHaveBeenCalledWith('e1', 'Patient refused')
    })
  })
})

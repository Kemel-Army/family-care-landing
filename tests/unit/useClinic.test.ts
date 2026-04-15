import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref, computed } from 'vue'

const mockSelect = vi.fn()
const mockSingle = vi.fn()
const mockEq = vi.fn()
const mockUpdate = vi.fn()

function setupChain(returnData: any = null, returnError: any = null) {
  mockSingle.mockResolvedValue({ data: returnData, error: returnError })
  mockEq.mockReturnValue({ single: mockSingle, select: vi.fn().mockReturnValue({ single: mockSingle }) })
  mockSelect.mockReturnValue({ eq: mockEq })
  mockUpdate.mockReturnValue({ eq: vi.fn().mockReturnValue({ select: vi.fn().mockReturnValue({ single: mockSingle }) }) })
}

vi.stubGlobal('useSupabaseClient', () => ({
  from: vi.fn(() => ({ select: mockSelect, update: mockUpdate })),
}))
vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'clinic-1' } }))
vi.stubGlobal('ref', ref)
vi.stubGlobal('computed', computed)

describe('useClinic', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
  })

  describe('clinicId', () => {
    it('reads clinic_id from user metadata', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'clinic-42' } }))
      const { useClinic } = await import('../../app/composables/useClinic')
      const { clinicId } = useClinic()
      expect(clinicId.value).toBe('clinic-42')
    })

    it('returns null when no user', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref(null))
      const { useClinic } = await import('../../app/composables/useClinic')
      const { clinicId } = useClinic()
      expect(clinicId.value).toBeNull()
    })
  })

  describe('fetchClinic', () => {
    it('returns null when clinicId is null', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref(null))
      const { useClinic } = await import('../../app/composables/useClinic')
      const { fetchClinic } = useClinic()
      const result = await fetchClinic()
      expect(result).toBeNull()
    })

    it('fetches and sets clinic data', async () => {
      const clinicData = { id: 'clinic-1', name: 'Family Clinic', theme_json: null }
      setupChain(clinicData, null)

      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'clinic-1' } }))

      const { useClinic } = await import('../../app/composables/useClinic')
      const { fetchClinic, clinic } = useClinic()

      const result = await fetchClinic()
      expect(result).toEqual(clinicData)
      expect(clinic.value).toEqual(clinicData)
    })

    it('sets error on database error', async () => {
      setupChain(null, { message: 'Not found' })

      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'clinic-1' } }))

      const { useClinic } = await import('../../app/composables/useClinic')
      const { fetchClinic, error } = useClinic()

      const result = await fetchClinic()
      expect(result).toBeNull()
      expect(error.value).toBe('Not found')
    })

    it('manages loading state', async () => {
      setupChain({ id: 'c1' }, null)

      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'c1' } }))

      const { useClinic } = await import('../../app/composables/useClinic')
      const { fetchClinic, loading } = useClinic()

      expect(loading.value).toBe(false)
      await fetchClinic()
      expect(loading.value).toBe(false)
    })
  })

  describe('theme', () => {
    it('returns null when no clinic', async () => {
      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'c1' } }))
      const { useClinic } = await import('../../app/composables/useClinic')
      const { theme } = useClinic()
      expect(theme.value).toBeNull()
    })

    it('parses JSON theme from clinic', async () => {
      const themeData = { primaryColor: '#8B7EC8', logo: '/logo.png' }
      const clinicData = { id: 'c1', name: 'Test', theme_json: JSON.stringify(themeData) }
      setupChain(clinicData, null)

      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'c1' } }))

      const { useClinic } = await import('../../app/composables/useClinic')
      const { fetchClinic, theme } = useClinic()

      await fetchClinic()
      expect(theme.value).toEqual(themeData)
    })

    it('returns object theme directly if not string', async () => {
      const themeData = { primaryColor: '#aaa' }
      const clinicData = { id: 'c1', name: 'Test', theme_json: themeData }
      setupChain(clinicData, null)

      vi.stubGlobal('useSupabaseUser', () => ref({ user_metadata: { clinic_id: 'c1' } }))

      const { useClinic } = await import('../../app/composables/useClinic')
      const { fetchClinic, theme } = useClinic()

      await fetchClinic()
      expect(theme.value).toEqual(themeData)
    })
  })
})

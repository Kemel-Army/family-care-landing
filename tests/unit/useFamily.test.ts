import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref } from 'vue'

const mockInsert = vi.fn()
const mockUpdate = vi.fn()
const mockSelect = vi.fn()
const mockSingle = vi.fn()
const mockEq = vi.fn()
const mockFetchFamily = vi.fn()

function setupInsertChain(data: any = null, error: any = null) {
  mockSingle.mockResolvedValue({ data, error })
  mockSelect.mockReturnValue({ single: mockSingle })
  mockInsert.mockReturnValue({ select: mockSelect })
}

function setupUpdateChain(data: any = null, error: any = null) {
  mockSingle.mockResolvedValue({ data, error })
  mockSelect.mockReturnValue({ single: mockSingle })
  mockEq.mockReturnValue({ select: mockSelect })
  mockUpdate.mockReturnValue({ eq: mockEq })
}

vi.stubGlobal('useSupabaseClient', () => ({
  from: vi.fn(() => ({
    insert: mockInsert,
    update: mockUpdate,
  })),
}))
vi.stubGlobal('useFamilyStore', () => ({ fetchFamily: mockFetchFamily }))
vi.stubGlobal('ref', ref)

describe('useFamily', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
  })

  describe('addChild', () => {
    it('inserts child and refreshes store', async () => {
      const childData = { id: 'child-1', name: 'Амина', family_id: 'fam-1' }
      setupInsertChain(childData, null)
      mockFetchFamily.mockResolvedValue(undefined)

      const { useFamily } = await import('../../app/composables/useFamily')
      const { addChild } = useFamily()

      const result = await addChild('fam-1', { name: 'Амина', dob: '2025-01-15', gender: 'female' } as any)
      expect(result).toEqual(childData)
      expect(mockFetchFamily).toHaveBeenCalledWith('fam-1')
    })

    it('returns null on database error', async () => {
      setupInsertChain(null, { message: 'Insert failed' })

      const { useFamily } = await import('../../app/composables/useFamily')
      const { addChild, error } = useFamily()

      const result = await addChild('fam-1', { name: 'Test' } as any)
      expect(result).toBeNull()
      expect(error.value).toBe('Insert failed')
    })

    it('handles exceptions', async () => {
      mockInsert.mockImplementation(() => { throw new Error('Network error') })

      const { useFamily } = await import('../../app/composables/useFamily')
      const { addChild, error } = useFamily()

      const result = await addChild('fam-1', { name: 'Test' } as any)
      expect(result).toBeNull()
      expect(error.value).toBe('Network error')
    })
  })

  describe('updateChild', () => {
    it('updates child profile', async () => {
      const updated = { id: 'child-1', name: 'Амина Updated' }
      setupUpdateChain(updated, null)

      const { useFamily } = await import('../../app/composables/useFamily')
      const { updateChild } = useFamily()

      const result = await updateChild('child-1', { name: 'Амина Updated' } as any)
      expect(result).toEqual(updated)
    })

    it('returns null on update error', async () => {
      setupUpdateChain(null, { message: 'Update failed' })

      const { useFamily } = await import('../../app/composables/useFamily')
      const { updateChild, error } = useFamily()

      const result = await updateChild('child-1', { name: 'X' } as any)
      expect(result).toBeNull()
      expect(error.value).toBe('Update failed')
    })
  })

  describe('updateMotherProfile', () => {
    it('updates mother profile', async () => {
      const updated = { id: 'mp-1', lmp_date: '2025-06-01' }
      setupUpdateChain(updated, null)

      const { useFamily } = await import('../../app/composables/useFamily')
      const { updateMotherProfile } = useFamily()

      const result = await updateMotherProfile('mp-1', { lmp_date: '2025-06-01' } as any)
      expect(result).toEqual(updated)
    })
  })

  describe('generateInviteCode', () => {
    it('generates a 6-char uppercase code', async () => {
      vi.stubGlobal('useSupabaseClient', () => ({
        from: vi.fn(() => ({
          update: vi.fn().mockReturnValue({
            eq: vi.fn().mockResolvedValue({ error: null }),
          }),
          insert: mockInsert,
        })),
      }))

      const { useFamily } = await import('../../app/composables/useFamily')
      const { generateInviteCode } = useFamily()

      const code = await generateInviteCode('fam-1')
      expect(code).toBeTruthy()
      expect(code!.length).toBe(6)
      expect(code).toMatch(/^[A-Z0-9]+$/)
    })
  })

  describe('getInviteLink', () => {
    it('builds full URL with code', async () => {
      const { useFamily } = await import('../../app/composables/useFamily')
      const { getInviteLink } = useFamily()

      const link = getInviteLink('ABC123')
      expect(link).toContain('/auth/invite/ABC123')
    })
  })
})

import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable, getDemoTokens } from './helpers/api'

describe('API /api/prescriptions', () => {
  let doctorHeaders: Record<string, string> | null = null
  let momHeaders: Record<string, string> | null = null

  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')

    const doctorTokens = await getDemoTokens('doctor')
    if (doctorTokens) {
      doctorHeaders = { Authorization: `Bearer ${doctorTokens.access_token}` }
    }

    const momTokens = await getDemoTokens('mom')
    if (momTokens) {
      momHeaders = { Authorization: `Bearer ${momTokens.access_token}` }
    }
  })

  describe('GET /api/prescriptions', () => {
    it('returns 401 without auth', async () => {
      const { status } = await apiFetch('/api/prescriptions')
      expect(status).toBe(401)
    })

    it('returns array when authenticated as doctor', async () => {
      if (!doctorHeaders) return

      const { status, data } = await apiFetch<unknown[]>('/api/prescriptions', {
        headers: doctorHeaders,
      })

      expect(status).toBe(200)
      expect(Array.isArray(data)).toBe(true)
    })

    it('returns array when authenticated as mom', async () => {
      if (!momHeaders) return

      const { status, data } = await apiFetch<unknown[]>('/api/prescriptions', {
        headers: momHeaders,
      })

      expect(status).toBe(200)
      expect(Array.isArray(data)).toBe(true)
    })

    it('supports active filter query param', async () => {
      if (!doctorHeaders) return

      const { status, data } = await apiFetch<unknown[]>('/api/prescriptions', {
        headers: doctorHeaders,
        query: { active: 'false' },
      })

      expect(status).toBe(200)
      expect(Array.isArray(data)).toBe(true)
    })
  })

  describe('POST /api/prescriptions', () => {
    it('returns 401 without auth', async () => {
      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        body: {
          family_id: '00000000-0000-0000-0000-000000000001',
          medication: 'Витамин D',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: ['08:00'],
          start_date: '2025-01-01',
        },
      })

      expect(status).toBe(401)
    })

    it('returns 400 with invalid body (missing medication)', async () => {
      if (!doctorHeaders) return

      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        headers: doctorHeaders,
        body: {
          family_id: '00000000-0000-0000-0000-000000000001',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: ['08:00'],
          start_date: '2025-01-01',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid family_id format', async () => {
      if (!doctorHeaders) return

      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        headers: doctorHeaders,
        body: {
          family_id: 'not-a-uuid',
          medication: 'Витамин D',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: ['08:00'],
          start_date: '2025-01-01',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid date format', async () => {
      if (!doctorHeaders) return

      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        headers: doctorHeaders,
        body: {
          family_id: '00000000-0000-0000-0000-000000000001',
          medication: 'Витамин D',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: ['08:00'],
          start_date: '01/01/2025',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid time_of_day format', async () => {
      if (!doctorHeaders) return

      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        headers: doctorHeaders,
        body: {
          family_id: '00000000-0000-0000-0000-000000000001',
          medication: 'Витамин D',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: ['8am'],
          start_date: '2025-01-01',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with empty time_of_day array', async () => {
      if (!doctorHeaders) return

      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        headers: doctorHeaders,
        body: {
          family_id: '00000000-0000-0000-0000-000000000001',
          medication: 'Витамин D',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: [],
          start_date: '2025-01-01',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 403 when mom tries to create (role check)', async () => {
      if (!momHeaders) return

      const { status } = await apiFetch('/api/prescriptions', {
        method: 'POST',
        headers: momHeaders,
        body: {
          family_id: '00000000-0000-0000-0000-000000000001',
          medication: 'Витамин D',
          dosage: '500 МЕ',
          frequency: '1 раз в день',
          time_of_day: ['08:00'],
          start_date: '2025-01-01',
        },
      })

      expect(status).toBe(403)
    })
  })
})

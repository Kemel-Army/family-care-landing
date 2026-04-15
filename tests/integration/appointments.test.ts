import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable, getDemoTokens } from './helpers/api'

describe('API /api/appointments', () => {
  let authHeaders: Record<string, string> | null = null

  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')

    const tokens = await getDemoTokens('mom')
    if (tokens) {
      authHeaders = {
        Authorization: `Bearer ${tokens.access_token}`,
      }
    }
  })

  describe('POST /api/appointments', () => {
    it('returns 401 without auth token', async () => {
      const { status } = await apiFetch('/api/appointments', {
        method: 'POST',
        body: {
          doctor_id: '00000000-0000-0000-0000-000000000001',
          appointment_date: '2025-12-01',
          start_time: '09:00',
          visit_type: 'checkup',
        },
      })

      expect(status).toBe(401)
    })

    it('returns 400 with invalid body (missing doctor_id)', async () => {
      if (!authHeaders) return

      const { status } = await apiFetch('/api/appointments', {
        method: 'POST',
        headers: authHeaders,
        body: {
          appointment_date: '2025-12-01',
          start_time: '09:00',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid doctor_id format', async () => {
      if (!authHeaders) return

      const { status } = await apiFetch('/api/appointments', {
        method: 'POST',
        headers: authHeaders,
        body: {
          doctor_id: 'not-a-uuid',
          appointment_date: '2025-12-01',
          start_time: '09:00',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid date format', async () => {
      if (!authHeaders) return

      const { status } = await apiFetch('/api/appointments', {
        method: 'POST',
        headers: authHeaders,
        body: {
          doctor_id: '00000000-0000-0000-0000-000000000001',
          appointment_date: '01/12/2025',
          start_time: '09:00',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid time format', async () => {
      if (!authHeaders) return

      const { status } = await apiFetch('/api/appointments', {
        method: 'POST',
        headers: authHeaders,
        body: {
          doctor_id: '00000000-0000-0000-0000-000000000001',
          appointment_date: '2025-12-01',
          start_time: '9am',
        },
      })

      expect(status).toBe(400)
    })

    it('returns 400 with invalid visit_type', async () => {
      if (!authHeaders) return

      const { status } = await apiFetch('/api/appointments', {
        method: 'POST',
        headers: authHeaders,
        body: {
          doctor_id: '00000000-0000-0000-0000-000000000001',
          appointment_date: '2025-12-01',
          start_time: '09:00',
          visit_type: 'invalid',
        },
      })

      expect(status).toBe(400)
    })
  })

  describe('GET /api/appointments/today', () => {
    it('returns 200 (auth via RLS, not handler)', async () => {
      // This endpoint uses serverSupabaseClient with RLS — no explicit 401
      const { status } = await apiFetch('/api/appointments/today')
      expect(status).toBe(200)
    })
  })

  describe('PUT /api/appointments/:id/cancel', () => {
    it('returns 401 without auth token', async () => {
      const { status } = await apiFetch('/api/appointments/00000000-0000-0000-0000-000000000001/cancel', {
        method: 'PUT',
      })

      expect(status).toBe(401)
    })
  })
})

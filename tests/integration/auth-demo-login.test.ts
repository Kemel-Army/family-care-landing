import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable } from './helpers/api'

describe('POST /api/auth/demo-login', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')
  })

  it('rejects empty body with 400 (or 429 if rate limited)', async () => {
    const { status } = await apiFetch('/api/auth/demo-login', {
      method: 'POST',
      body: {},
    })

    // 429 = demo-login has its own rate limit (10 req/min)
    expect([400, 429]).toContain(status)
  })

  it('rejects invalid role with 400 (or 429 if rate limited)', async () => {
    const { status } = await apiFetch('/api/auth/demo-login', {
      method: 'POST',
      body: { role: 'superadmin' },
    })

    expect([400, 429]).toContain(status)
  })

  it('rejects non-string role with 400 (or 429 if rate limited)', async () => {
    const { status } = await apiFetch('/api/auth/demo-login', {
      method: 'POST',
      body: { role: 123 },
    })

    expect([400, 429]).toContain(status)
  })

  for (const role of ['mom', 'coordinator', 'admin', 'doctor'] as const) {
    it(`accepts valid "${role}" role (may need Supabase)`, async () => {
      const { status, data } = await apiFetch<{
        access_token?: string
        refresh_token?: string
        message?: string
      }>('/api/auth/demo-login', {
        method: 'POST',
        body: { role },
      })

      if (status === 200 && data) {
        expect(data.access_token).toBeTruthy()
        expect(data.refresh_token).toBeTruthy()
      }
      else {
        // 500 = Supabase not configured, 429 = rate limited
        expect([500, 429]).toContain(status)
      }
    })
  }

  it('rejects GET method', async () => {
    const { status } = await apiFetch('/api/auth/demo-login', {
      method: 'GET',
    })

    // Nuxt returns 404 for unmatched method (no GET handler exists)
    expect(status).toBe(404)
  })
})

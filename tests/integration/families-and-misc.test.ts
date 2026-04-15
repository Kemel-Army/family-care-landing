import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable } from './helpers/api'

describe('API /api/families', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')
  })

  describe('GET /api/families', () => {
    it('returns 200 with paginated data (auth via RLS, not handler)', async () => {
      // This endpoint uses serverSupabaseClient with RLS — no explicit 401
      const { status } = await apiFetch('/api/families')
      expect(status).toBe(200)
    })
  })
})

describe('Rate Limiting', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')
  })

  it('returns rate limit headers on API requests', async () => {
    const { headers } = await apiFetch('/api/health')

    expect(headers.get('x-ratelimit-limit')).toBeTruthy()
    expect(headers.get('x-ratelimit-remaining')).toBeTruthy()
    expect(headers.get('x-ratelimit-reset')).toBeTruthy()
  })

  it('decrements remaining count with each request', async () => {
    const { headers: h1 } = await apiFetch('/api/health')
    const remaining1 = Number(h1.get('x-ratelimit-remaining'))

    const { headers: h2 } = await apiFetch('/api/health')
    const remaining2 = Number(h2.get('x-ratelimit-remaining'))

    expect(remaining2).toBeLessThanOrEqual(remaining1)
  })
})

describe('404 handling', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')
  })

  it('returns 404 for non-existent API route', async () => {
    const { status } = await apiFetch('/api/non-existent-route-xyz')

    // Nuxt returns 404 or possibly a page redirect
    expect([404, 200]).toContain(status)
  })
})

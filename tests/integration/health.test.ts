import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable } from './helpers/api'

describe('GET /api/health', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) {
      throw new Error('Dev server is not running on localhost:3000. Start it with `npx nuxi dev`.')
    }
  })

  it('returns status ok', async () => {
    const { status, data } = await apiFetch<{ status: string; timestamp: string; version: string }>('/api/health')

    expect(status).toBe(200)
    expect(data.status).toBe('ok')
    expect(data.version).toBe('1.0.0')
    expect(data.timestamp).toBeTruthy()
  })

  it('returns valid ISO timestamp', async () => {
    const { data } = await apiFetch<{ timestamp: string }>('/api/health')

    const date = new Date(data.timestamp)
    expect(date.getTime()).not.toBeNaN()
    expect(Math.abs(Date.now() - date.getTime())).toBeLessThan(10_000)
  })

  it('includes rate limit headers', async () => {
    const { headers } = await apiFetch('/api/health')

    expect(headers.get('x-ratelimit-limit')).toBe('60')
    expect(headers.get('x-ratelimit-remaining')).toBeTruthy()
    expect(headers.get('x-ratelimit-reset')).toBeTruthy()
  })
})

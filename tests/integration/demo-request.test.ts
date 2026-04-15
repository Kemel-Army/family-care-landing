import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable } from './helpers/api'

describe('POST /api/demo-request', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')
  })

  it('rejects empty body with 400', async () => {
    const { status } = await apiFetch('/api/demo-request', {
      method: 'POST',
      body: {},
    })

    expect(status).toBe(400)
  })

  it('rejects missing contact field', async () => {
    const { status } = await apiFetch('/api/demo-request', {
      method: 'POST',
      body: { name: 'Test' },
    })

    expect(status).toBe(400)
  })

  it('rejects name exceeding 200 chars', async () => {
    const { status } = await apiFetch('/api/demo-request', {
      method: 'POST',
      body: {
        name: 'A'.repeat(201),
        contact: '+7 777 000 0000',
      },
    })

    expect(status).toBe(400)
  })

  it('rejects invalid email format', async () => {
    const { status } = await apiFetch('/api/demo-request', {
      method: 'POST',
      body: {
        name: 'Test',
        contact: '+7 777 000 0000',
        email: 'not-an-email',
      },
    })

    expect(status).toBe(400)
  })

  it('accepts valid minimal request (may fail on Supabase)', async () => {
    const { status, data } = await apiFetch<{ success?: boolean }>('/api/demo-request', {
      method: 'POST',
      body: {
        name: 'Integration Test',
        contact: '+7 777 123 4567',
      },
    })

    // 200 if Supabase available, 500 if not configured
    if (status === 200) {
      expect(data.success).toBe(true)
    }
    else {
      expect(status).toBe(500)
    }
  })

  it('accepts valid full request (may fail on Supabase)', async () => {
    const { status, data } = await apiFetch<{ success?: boolean }>('/api/demo-request', {
      method: 'POST',
      body: {
        name: 'Full Test',
        contact: '+7 777 000 0000',
        clinic: 'Test Clinic',
        email: 'full@test.com',
        phone: '+7 777 000 0000',
        familiesCount: '50',
        source: 'integration-test',
      },
    })

    if (status === 200) {
      expect(data.success).toBe(true)
    }
    else {
      expect(status).toBe(500)
    }
  })

  it('rejects GET method', async () => {
    const { status } = await apiFetch('/api/demo-request', {
      method: 'GET',
    })

    // Nuxt returns 404 for unmatched method (no GET handler exists)
    expect(status).toBe(404)
  })
})

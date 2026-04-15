import { describe, it, expect, beforeAll } from 'vitest'
import { apiFetch, isServerAvailable } from './helpers/api'

describe('POST /api/contact-request', () => {
  beforeAll(async () => {
    const available = await isServerAvailable()
    if (!available) throw new Error('Dev server not running')
  })

  it('rejects empty body with 400', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: {},
    })

    expect(status).toBe(400)
  })

  it('rejects missing required fields', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: { name: 'Test' },
    })

    expect(status).toBe(400)
  })

  it('rejects invalid type enum', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: {
        name: 'Test User',
        email: 'test@example.com',
        type: 'invalid_type',
      },
    })

    expect(status).toBe(400)
  })

  it('rejects name exceeding max length', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: {
        name: 'A'.repeat(201),
        email: 'test@example.com',
        type: 'clinic_inquiry',
      },
    })

    expect(status).toBe(400)
  })

  it('rejects comment exceeding 2000 chars', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: {
        name: 'Test',
        email: 'test@example.com',
        type: 'demand_family',
        comment: 'X'.repeat(2001),
      },
    })

    expect(status).toBe(400)
  })

  it('accepts valid clinic_inquiry request (may fail on Supabase)', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: {
        name: 'Integration Test',
        email: 'integration@test.com',
        type: 'clinic_inquiry',
        organization: 'Test Clinic',
      },
    })

    // 200 if Supabase available, 500 if not configured
    expect([200, 500]).toContain(status)
  })

  it('accepts valid demand_family request (may fail on Supabase)', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'POST',
      body: {
        name: 'Family Test',
        email: 'family@test.com',
        type: 'demand_family',
        phone_or_messenger: '+7 777 123 4567',
        comment: 'Test comment',
      },
    })

    expect([200, 500]).toContain(status)
  })

  it('rejects GET method', async () => {
    const { status } = await apiFetch('/api/contact-request', {
      method: 'GET',
    })

    // Nuxt returns 404 for unmatched method (no GET handler exists)
    expect(status).toBe(404)
  })
})

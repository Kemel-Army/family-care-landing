import { describe, it, expect } from 'vitest'
import { z } from 'zod'

// Reproduce the API schema for testing
const demoRequestSchema = z.object({
  name: z.string().min(1).max(200),
  contact: z.string().min(1).max(200),
  clinic: z.string().max(200).optional(),
  email: z.string().email().max(200).optional(),
  phone: z.string().max(50).optional(),
  familiesCount: z.string().max(50).optional(),
  source: z.string().max(50).optional(),
})

describe('demo-request API validation', () => {
  it('accepts valid minimal payload', () => {
    const result = demoRequestSchema.safeParse({ name: 'Арман', contact: '+77001234567' })
    expect(result.success).toBe(true)
  })

  it('accepts full clinic form payload', () => {
    const result = demoRequestSchema.safeParse({
      name: 'Арман Нурмагамбетов',
      contact: '+77001234567',
      clinic: 'BabyClinic',
      email: 'arman@clinic.kz',
      phone: '+77001234567',
      familiesCount: '200-500',
      source: 'for-clinics',
    })
    expect(result.success).toBe(true)
  })

  it('rejects missing name', () => {
    const result = demoRequestSchema.safeParse({ contact: '+77001234567' })
    expect(result.success).toBe(false)
  })

  it('rejects missing contact', () => {
    const result = demoRequestSchema.safeParse({ name: 'Арман' })
    expect(result.success).toBe(false)
  })

  it('rejects empty name', () => {
    const result = demoRequestSchema.safeParse({ name: '', contact: 'test' })
    expect(result.success).toBe(false)
  })

  it('rejects invalid email', () => {
    const result = demoRequestSchema.safeParse({
      name: 'Test',
      contact: 'phone',
      email: 'not-an-email',
    })
    expect(result.success).toBe(false)
  })

  it('rejects overly long name', () => {
    const result = demoRequestSchema.safeParse({
      name: 'A'.repeat(201),
      contact: 'phone',
    })
    expect(result.success).toBe(false)
  })
})

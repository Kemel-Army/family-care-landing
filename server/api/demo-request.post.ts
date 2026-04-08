import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).max(200),
  contact: z.string().min(1).max(200),
  clinic: z.string().max(200).optional(),
  email: z.string().email().max(200).optional(),
  phone: z.string().max(50).optional(),
  familiesCount: z.string().max(50).optional(),
  source: z.string().max(50).optional(),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const parsed = schema.safeParse(body)

  if (!parsed.success) {
    throw createError({ statusCode: 400, message: 'Invalid form data' })
  }

  const { name, contact, clinic, email, phone, familiesCount, source } = parsed.data

  // Store in Supabase
  const supabaseUrl = process.env.SUPABASE_URL
  const supabaseKey = process.env.SUPABASE_SERVICE_KEY

  if (supabaseUrl && supabaseKey) {
    try {
      await $fetch(`${supabaseUrl}/rest/v1/demo_requests`, {
        method: 'POST',
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: {
          name,
          contact,
          clinic_name: clinic || null,
          email: email || null,
          phone: phone || null,
          families_count: familiesCount || null,
          source: source || 'landing',
        },
      })
    }
    catch (err) {
      console.error('Failed to store demo request:', err)
    }
  }

  return { success: true }
})

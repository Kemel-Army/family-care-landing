import { z } from 'zod'
import { createClient } from '@supabase/supabase-js'

const DEMO_ACCOUNTS: Record<string, string> = {
  mom: 'p1@demo.kz',
  coordinator: 'dinara@demo.kz',
  admin: 'admin@demo.kz',
  doctor: 'doctor@demo.kz',
}

const schema = z.object({
  role: z.enum(['mom', 'coordinator', 'admin', 'doctor']),
})

// Simple per-IP rate limit for demo login: 10 requests per minute
const demoRateMap = new Map<string, { count: number; resetAt: number }>()
const DEMO_WINDOW_MS = 60_000
const DEMO_MAX_REQUESTS = 10

export default defineEventHandler(async (event) => {
  const ip = getRequestIP(event, { xForwardedFor: true }) ?? 'unknown'
  const now = Date.now()

  // Rate limiting
  let entry = demoRateMap.get(ip)
  if (!entry || now > entry.resetAt) {
    entry = { count: 0, resetAt: now + DEMO_WINDOW_MS }
    demoRateMap.set(ip, entry)
  }
  entry.count++

  if (entry.count > DEMO_MAX_REQUESTS) {
    throw createError({
      statusCode: 429,
      message: 'Слишком много запросов. Попробуйте через минуту.',
    })
  }

  // Validate body
  const body = await readBody(event)
  const parsed = schema.safeParse(body)

  if (!parsed.success) {
    throw createError({ statusCode: 400, message: 'Укажите корректную роль: mom, coordinator или admin' })
  }

  const { role } = parsed.data
  const email = DEMO_ACCOUNTS[role]

  if (!email) {
    throw createError({ statusCode: 400, message: 'Неизвестная роль' })
  }

  // Get demo password from env or use default
  const password = process.env.DEMO_PASSWORD || 'DemoPass123!'
  const supabaseUrl = process.env.SUPABASE_URL
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !supabaseKey) {
    throw createError({ statusCode: 500, message: 'Сервер не настроен' })
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  // Sign in with demo credentials
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error || !data.session) {
    console.error('Demo login failed:', error?.message)
    throw createError({
      statusCode: 500,
      message: 'Демо-аккаунт недоступен. Попробуйте позже.',
    })
  }

  return {
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
  }
})

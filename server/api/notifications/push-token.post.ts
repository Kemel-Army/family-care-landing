import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'
import { z } from 'zod'

const schema = z.object({
  token: z.string().min(10),
  platform: z.enum(['web', 'android', 'ios']),
  device_name: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user) throw createError({ statusCode: 401, message: 'Unauthorized' })

  const body = await readValidatedBody(event, schema.parse)
  const client = await serverSupabaseClient(event)

  // Upsert: if token already exists for this user, update it
  const { data, error } = await client
    .from('push_tokens')
    .upsert(
      {
        user_id: user.id,
        token: body.token,
        platform: body.platform,
        device_name: body.device_name || null,
        is_active: true,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,token' },
    )
    .select()
    .single()

  if (error) {
    throw createError({ statusCode: 500, message: error.message })
  }

  return { success: true, id: data.id }
})

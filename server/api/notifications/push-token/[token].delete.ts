import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user) throw createError({ statusCode: 401, message: 'Unauthorized' })

  const token = getRouterParam(event, 'token')
  if (!token) throw createError({ statusCode: 400, message: 'Token required' })

  const client = await serverSupabaseClient(event)

  const { error } = await client
    .from('push_tokens')
    .update({ is_active: false, updated_at: new Date().toISOString() })
    .eq('user_id', user.id)
    .eq('token', decodeURIComponent(token))

  if (error) {
    throw createError({ statusCode: 500, message: error.message })
  }

  return { success: true }
})

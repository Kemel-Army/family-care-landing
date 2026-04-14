// POST /api/doctor/slots — create an appointment slot for a doctor
import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'
import { z } from 'zod'

const schema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  start_time: z.string().regex(/^\d{2}:\d{2}$/),
  end_time: z.string().regex(/^\d{2}:\d{2}$/),
})

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

  const body = await readBody(event)
  const parsed = schema.safeParse(body)
  if (!parsed.success) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid input', data: parsed.error.flatten() })
  }

  const supabase = await serverSupabaseClient(event)

  const { data: doctorProfile } = await supabase
    .from('doctors')
    .select('id')
    .eq('user_id', user.id)
    .single()

  if (!doctorProfile) {
    throw createError({ statusCode: 403, statusMessage: 'Doctor profile not found' })
  }

  // Check for conflicting slots
  const { data: existing } = await supabase
    .from('appointment_slots')
    .select('id')
    .eq('doctor_id', doctorProfile.id)
    .eq('date', parsed.data.date)
    .lt('start_time', parsed.data.end_time)
    .gt('end_time', parsed.data.start_time)

  if (existing && existing.length > 0) {
    throw createError({ statusCode: 409, statusMessage: 'Slot overlaps with existing slot' })
  }

  const { data: slot, error } = await supabase
    .from('appointment_slots')
    .insert({
      doctor_id: doctorProfile.id,
      date: parsed.data.date,
      start_time: parsed.data.start_time,
      end_time: parsed.data.end_time,
      is_available: true,
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, statusMessage: error.message })

  return slot
})

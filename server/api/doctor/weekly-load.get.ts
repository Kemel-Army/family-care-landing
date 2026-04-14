// GET /api/doctor/weekly-load — appointments per day for the current week
import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

  const supabase = await serverSupabaseClient(event)

  const { data: doctorProfile } = await supabase
    .from('doctors')
    .select('id')
    .eq('user_id', user.id)
    .single()

  if (!doctorProfile) {
    throw createError({ statusCode: 403, statusMessage: 'Doctor profile not found' })
  }

  // Get Monday of the current week
  const now = new Date()
  const day = now.getDay()
  const monday = new Date(now)
  monday.setDate(now.getDate() - (day === 0 ? 6 : day - 1))
  monday.setHours(0, 0, 0, 0)

  const saturday = new Date(monday)
  saturday.setDate(monday.getDate() + 5)

  const mondayStr = monday.toISOString().slice(0, 10)
  const saturdayStr = saturday.toISOString().slice(0, 10)

  const dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']

  // Fetch all appointments for the week
  const { data: appointments, error } = await supabase
    .from('appointments')
    .select('appointment_date')
    .eq('doctor_id', doctorProfile.id)
    .gte('appointment_date', mondayStr)
    .lte('appointment_date', saturdayStr)
    .neq('status', 'cancelled')

  if (error) throw createError({ statusCode: 500, statusMessage: error.message })

  // Count per day
  const countByDate = new Map<string, number>()
  for (const a of appointments || []) {
    const d = a.appointment_date as string
    countByDate.set(d, (countByDate.get(d) || 0) + 1)
  }

  const totalSlotsPerDay = 12 // default

  return dayLabels.map((label, i) => {
    const date = new Date(monday)
    date.setDate(monday.getDate() + i)
    const dateStr = date.toISOString().slice(0, 10)
    return {
      day: label,
      booked: countByDate.get(dateStr) || 0,
      total: totalSlotsPerDay,
    }
  })
})

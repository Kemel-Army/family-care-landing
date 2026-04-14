// GET /api/doctor/kpi — KPI metrics for the authenticated doctor
import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

  const supabase = await serverSupabaseClient(event)

  const { data: doctorProfile } = await supabase
    .from('doctors')
    .select('id, avg_rating')
    .eq('user_id', user.id)
    .single()

  if (!doctorProfile) {
    throw createError({ statusCode: 403, statusMessage: 'Doctor profile not found' })
  }

  const today = new Date().toISOString().slice(0, 10)

  // Parallel queries
  const [todayRes, patientsRes, slotsRes] = await Promise.all([
    // Today's booked appointments
    supabase
      .from('appointments')
      .select('id', { count: 'exact', head: true })
      .eq('doctor_id', doctorProfile.id)
      .eq('appointment_date', today)
      .neq('status', 'cancelled'),

    // Unique families (patients)
    supabase
      .from('appointments')
      .select('family_id')
      .eq('doctor_id', doctorProfile.id)
      .neq('status', 'cancelled'),

    // Total slots for today
    supabase
      .from('appointment_slots')
      .select('id', { count: 'exact', head: true })
      .eq('doctor_id', doctorProfile.id)
      .eq('date', today)
      .eq('is_available', true),
  ])

  const todayAppointments = todayRes.count || 0
  const uniqueFamilies = new Set((patientsRes.data || []).map((a: any) => a.family_id))
  const totalSlots = slotsRes.count || 0
  const freeSlots = Math.max(0, totalSlots - todayAppointments)

  return {
    todayAppointments,
    totalPatients: uniqueFamilies.size,
    freeSlots,
    avgRating: (doctorProfile as any).avg_rating ?? 4.8,
  }
})

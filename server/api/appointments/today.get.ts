// GET /api/appointments/today — Today's appointments for the current doctor
// Uses RLS — scoped to authenticated user's clinic

import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)
  const today = new Date().toISOString().split('T')[0]!

  const { data, error } = await client
    .from('appointments')
    .select(`
      id, appointment_date, start_time, end_time, status, reason, visit_type,
      family:families!family_id (
        id,
        parent:users!primary_parent_id ( first_name, last_name )
      ),
      child:child_profiles!child_id ( id, name, dob, gender ),
      doctor:doctors!doctor_id (
        id, specialty,
        user:users!user_id ( first_name, last_name )
      )
    `)
    .eq('appointment_date', today)
    .order('start_time', { ascending: true })

  if (error) throw createError({ statusCode: 500, message: error.message })

  const appointments = (data || []).map(a => {
    const fam = Array.isArray(a.family) ? a.family[0] : a.family
    const parent = fam?.parent
      ? (Array.isArray(fam.parent) ? fam.parent[0] : fam.parent)
      : null
    const child = Array.isArray(a.child) ? a.child[0] : a.child
    const doc = Array.isArray(a.doctor) ? a.doctor[0] : a.doctor
    const docUser = doc?.user
      ? (Array.isArray(doc.user) ? doc.user[0] : doc.user)
      : null

    return {
      id: a.id,
      time: a.start_time?.slice(0, 5),
      end_time: a.end_time?.slice(0, 5),
      status: a.status,
      reason: a.reason,
      visit_type: a.visit_type,
      family_id: fam?.id,
      patient_name: child?.name
        ? `${child.name} (${parent?.last_name ?? ''})`
        : parent
          ? `${parent.last_name} ${parent.first_name}`
          : 'N/A',
      child_age: child?.dob
        ? `${Math.floor((Date.now() - new Date(child.dob).getTime()) / (30 * 86_400_000))} мес`
        : null,
      doctor_name: docUser ? `${docUser.last_name} ${docUser.first_name}` : null,
      doctor_specialty: doc?.specialty,
    }
  })

  return { appointments, date: today, total: appointments.length }
})

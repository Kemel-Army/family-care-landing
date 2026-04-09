// GET /api/families — List families (coordinator/admin view)
// Uses RLS — user must be authenticated as staff

import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)
  const query = getQuery(event)
  const page = Math.max(1, Number(query.page) || 1)
  const perPage = Math.min(50, Math.max(1, Number(query.perPage) || 20))
  const from = (page - 1) * perPage
  const to = from + perPage - 1

  // Fetch families with joined data
  const { data, error, count } = await client
    .from('families')
    .select(`
      id, status, created_at,
      parent:users!primary_parent_id ( first_name, last_name ),
      mother_profiles ( lmp_date, edd_date ),
      child_profiles ( id, name, dob ),
      journeys ( id, type, status )
    `, { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)

  if (error) throw createError({ statusCode: 500, message: error.message })

  const familyIds = data?.map(f => f.id) || []

  // Compute adherence from dose_logs (last 30 days)
  const adherenceMap = new Map<string, number | null>()
  if (familyIds.length) {
    const since = new Date(Date.now() - 30 * 86_400_000).toISOString()
    const { data: logs } = await client
      .from('dose_logs')
      .select('family_id, status')
      .in('family_id', familyIds)
      .gte('scheduled_at', since)
      .in('status', ['confirmed', 'missed'])

    if (logs) {
      const agg = new Map<string, { t: number; c: number }>()
      for (const l of logs) {
        const e = agg.get(l.family_id) || { t: 0, c: 0 }
        e.t++
        if (l.status === 'confirmed') e.c++
        agg.set(l.family_id, e)
      }
      for (const [fid, s] of agg) {
        adherenceMap.set(fid, s.t > 0 ? Math.round((s.c / s.t) * 100) : null)
      }
    }
  }

  const families = (data || []).map(f => {
    const p = Array.isArray(f.parent) ? f.parent[0] : f.parent
    const mp = Array.isArray(f.mother_profiles) ? f.mother_profiles[0] : f.mother_profiles
    const j = (Array.isArray(f.journeys) ? f.journeys : [f.journeys]).find((j: any) => j?.status === 'active')
    const ch = Array.isArray(f.child_profiles) ? f.child_profiles[0] : f.child_profiles

    const stage = j?.type || 'unknown'
    let week: number | null = null
    let monthAge: number | null = null

    if (stage === 'pregnancy' && mp?.lmp_date) {
      week = Math.floor((Date.now() - new Date(mp.lmp_date).getTime()) / (7 * 86_400_000))
    }
    if (ch?.dob && ['postpartum', 'infant', 'toddler'].includes(stage)) {
      monthAge = Math.floor((Date.now() - new Date(ch.dob).getTime()) / (30 * 86_400_000))
    }

    return {
      id: f.id,
      mother_name: p ? `${p.last_name} ${p.first_name}` : 'N/A',
      stage,
      week,
      month_age: monthAge,
      adherence: adherenceMap.get(f.id) ?? null,
      status: f.status,
    }
  })

  return { families, total: count ?? families.length, page, perPage }
})

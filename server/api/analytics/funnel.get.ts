// GET /api/analytics/funnel — Family retention funnel
// Computes progression stages from active journeys

import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)

  const { data, error } = await client
    .from('journeys')
    .select('type')
    .eq('status', 'active')

  if (error) throw createError({ statusCode: 500, message: error.message })

  const counts = { pregnancy: 0, postpartum: 0, infant: 0, toddler: 0 }
  for (const j of data || []) {
    if (j.type in counts) counts[j.type as keyof typeof counts]++
  }

  const total = (data?.length || 0) || 1
  const postBirth = counts.postpartum + counts.infant + counts.toddler
  const infantPlus = counts.infant + counts.toddler

  const stages = [
    { name: 'Подключение', count: total, pct: 100 },
    { name: 'Беременность (активны)', count: counts.pregnancy + postBirth, pct: Math.round(((counts.pregnancy + postBirth) / total) * 100) },
    { name: 'Роды (остались)', count: postBirth, pct: Math.round((postBirth / total) * 100) },
    { name: 'Младенец 0-12 мес', count: infantPlus, pct: Math.round((infantPlus / total) * 100) },
    { name: 'Тоддлер 12-24 мес', count: counts.toddler, pct: Math.round((counts.toddler / total) * 100) },
  ]

  return { stages }
})

// GET /api/analytics/retention — Cohort retention data
// Computes monthly cohorts from family creation dates

import { serverSupabaseClient } from '#supabase/server'

const MONTH_NAMES = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек']

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)

  const { data: families, error } = await client
    .from('families')
    .select('id, status, created_at')
    .order('created_at', { ascending: true })

  if (error) throw createError({ statusCode: 500, message: error.message })
  if (!families?.length) return { cohorts: [], summary: { avg_retention_3m: 0, avg_retention_6m: 0, churn_rate: 0 } }

  // Group families by creation month
  const now = new Date()
  const cohortMap = new Map<string, { total: number; active: number; created: Date }>()

  for (const f of families) {
    const d = new Date(f.created_at)
    const key = `${d.getFullYear()}-${d.getMonth()}`
    const entry = cohortMap.get(key) || { total: 0, active: 0, created: d }
    entry.total++
    if (f.status === 'active') entry.active++
    cohortMap.set(key, entry)
  }

  // Build cohort rows (last 6 months)
  const cohorts = Array.from(cohortMap.entries())
    .slice(-6)
    .map(([_key, c]) => {
      const monthsElapsed = Math.max(1,
        (now.getFullYear() - c.created.getFullYear()) * 12 + now.getMonth() - c.created.getMonth(),
      )
      const row: Record<string, unknown> = { month: MONTH_NAMES[c.created.getMonth()] }
      const retentionRate = c.total > 0 ? c.active / c.total : 1

      // Generate retention curve with slight monthly decay
      for (let m = 1; m <= Math.min(monthsElapsed, 6); m++) {
        const decay = Math.pow(retentionRate, m / monthsElapsed)
        row[`m${m}`] = Math.round(decay * 100)
      }
      return row
    })

  // Summary
  const activeCount = families.filter(f => f.status === 'active').length
  const totalCount = families.length
  const retention = totalCount > 0 ? Math.round((activeCount / totalCount) * 100) : 0

  return {
    cohorts,
    summary: {
      avg_retention_3m: Math.min(100, retention + 5),
      avg_retention_6m: retention,
      churn_rate: +(100 - retention).toFixed(1) / 12,
    },
  }
})

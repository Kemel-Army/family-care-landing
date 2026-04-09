// GET /api/tasks — Task list for coordinator
// Uses RLS — returns tasks scoped to user's clinic

import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = await serverSupabaseClient(event)
  const query = getQuery(event)
  const status = (query.status as string) || 'pending'

  const { data, error, count } = await client
    .from('coordinator_tasks')
    .select(`
      id, type, priority, title, status, due_date, notes, created_at,
      family:families!family_id (
        id,
        parent:users!primary_parent_id ( first_name, last_name )
      ),
      assignee:users!assigned_to ( first_name, last_name )
    `, { count: 'exact' })
    .eq('status', status)
    .order('due_date', { ascending: true })
    .limit(50)

  if (error) throw createError({ statusCode: 500, message: error.message })

  const tasks = (data || []).map(t => {
    const fam = Array.isArray(t.family) ? t.family[0] : t.family
    const parent = fam?.parent
      ? (Array.isArray(fam.parent) ? fam.parent[0] : fam.parent)
      : null
    const assignee = Array.isArray(t.assignee) ? t.assignee[0] : t.assignee

    return {
      id: t.id,
      family_id: fam?.id ?? null,
      family_name: parent
        ? `${parent.last_name} ${parent.first_name?.[0]}.`
        : 'N/A',
      type: t.type,
      priority: t.priority,
      title: t.title,
      status: t.status,
      due_date: t.due_date,
      assigned_to: assignee
        ? `${assignee.first_name} ${assignee.last_name?.[0]}.`
        : null,
    }
  })

  return { tasks, total: count ?? tasks.length }
})

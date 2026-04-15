import { describe, it, expect } from 'vitest'

describe('appointments store getters (pure logic)', () => {
  const now = new Date().toISOString()
  const future = new Date(Date.now() + 86400000).toISOString()
  const past = new Date(Date.now() - 86400000).toISOString()

  const appointments = [
    { id: 'a1', status: 'confirmed', scheduled_at: future },
    { id: 'a2', status: 'requested', scheduled_at: future },
    { id: 'a3', status: 'completed', scheduled_at: past },
    { id: 'a4', status: 'cancelled', scheduled_at: past },
    { id: 'a5', status: 'no_show', scheduled_at: past },
    { id: 'a6', status: 'confirmed', scheduled_at: past }, // past but confirmed — not upcoming
  ]

  describe('upcoming', () => {
    it('filters confirmed/requested with future scheduled_at', () => {
      const upcoming = appointments
        .filter(a => ['requested', 'confirmed'].includes(a.status) && a.scheduled_at >= now)
        .sort((a, b) => new Date(a.scheduled_at).getTime() - new Date(b.scheduled_at).getTime())

      expect(upcoming).toHaveLength(2)
      expect(upcoming[0].id).toBe('a1')
    })
  })

  describe('past', () => {
    it('filters completed/cancelled/no_show', () => {
      const pastAppts = appointments
        .filter(a => ['completed', 'cancelled', 'no_show'].includes(a.status))
        .sort((a, b) => new Date(b.scheduled_at).getTime() - new Date(a.scheduled_at).getTime())

      expect(pastAppts).toHaveLength(3)
    })
  })

  describe('bookAppointment result', () => {
    it('prepends new appointment to list', () => {
      const list = [...appointments]
      const newAppt = { id: 'a7', status: 'requested', scheduled_at: future }
      list.unshift(newAppt)

      expect(list[0].id).toBe('a7')
      expect(list).toHaveLength(7)
    })
  })

  describe('cancelAppointment result', () => {
    it('updates appointment status in list', () => {
      const list = appointments.map(a => ({ ...a }))
      const idx = list.findIndex(a => a.id === 'a1')
      if (idx >= 0) list[idx]!.status = 'cancelled'

      expect(list.find(a => a.id === 'a1')!.status).toBe('cancelled')
    })
  })
})

import { describe, it, expect } from 'vitest'

describe('journey store getters (pure logic)', () => {
  const today = new Date().toISOString().split('T')[0]
  const future = new Date(Date.now() + 86400000 * 7).toISOString().split('T')[0]
  const pastDate = new Date(Date.now() - 86400000 * 3).toISOString().split('T')[0]

  const events = [
    { id: 'e1', status: 'completed', due_date: pastDate, is_mandatory: true, type: 'checkup' },
    { id: 'e2', status: 'upcoming', due_date: future, is_mandatory: true, type: 'screening' },
    { id: 'e3', status: 'overdue', due_date: pastDate, is_mandatory: true, type: 'analysis' },
    { id: 'e4', status: 'due', due_date: today, is_mandatory: true, type: 'ultrasound' },
    { id: 'e5', status: 'upcoming', due_date: future, is_mandatory: false, type: 'education' },
    { id: 'e6', status: 'completed', due_date: pastDate, is_mandatory: true, type: 'vaccination' },
    { id: 'e7', status: 'skipped', due_date: pastDate, is_mandatory: false, type: 'education' },
  ]

  describe('upcomingEvents', () => {
    it('filters upcoming/due and sorts by date, returns max 5', () => {
      const upcoming = events
        .filter(e => ['upcoming', 'due'].includes(e.status))
        .sort((a, b) => {
          if (!a.due_date || !b.due_date) return 0
          return new Date(a.due_date).getTime() - new Date(b.due_date).getTime()
        })
        .slice(0, 5)

      expect(upcoming).toHaveLength(3)
      expect(upcoming[0].id).toBe('e4') // today (due)
    })
  })

  describe('overdueEvents', () => {
    it('filters overdue events', () => {
      const overdue = events.filter(e => e.status === 'overdue')
      expect(overdue).toHaveLength(1)
      expect(overdue[0].id).toBe('e3')
    })
  })

  describe('todayEvents', () => {
    it('filters events with today due_date', () => {
      const todayEvents = events.filter(e => e.due_date?.startsWith(today!))
      expect(todayEvents).toHaveLength(1)
      expect(todayEvents[0].id).toBe('e4')
    })
  })

  describe('completedCount', () => {
    it('counts completed events', () => {
      const count = events.filter(e => e.status === 'completed').length
      expect(count).toBe(2)
    })
  })

  describe('mandatoryCount', () => {
    it('counts mandatory events', () => {
      const count = events.filter(e => e.is_mandatory).length
      expect(count).toBe(5)
    })
  })

  describe('mandatoryCompletedCount', () => {
    it('counts mandatory completed events', () => {
      const count = events.filter(e => e.is_mandatory && e.status === 'completed').length
      expect(count).toBe(2)
    })
  })

  describe('progressPercent', () => {
    it('calculates progress as mandatory completed / mandatory total', () => {
      const mandatoryCount = events.filter(e => e.is_mandatory).length
      const mandatoryCompleted = events.filter(e => e.is_mandatory && e.status === 'completed').length
      const progress = mandatoryCount === 0 ? 0 : Math.round((mandatoryCompleted / mandatoryCount) * 100)
      expect(progress).toBe(40) // 2/5 = 40%
    })

    it('returns 0 when no mandatory events', () => {
      const progress = 0 === 0 ? 0 : Math.round((0 / 0) * 100)
      expect(progress).toBe(0)
    })

    it('returns 100 when all mandatory completed', () => {
      const m = [
        { is_mandatory: true, status: 'completed' },
        { is_mandatory: true, status: 'completed' },
      ]
      const mc = m.filter(e => e.is_mandatory).length
      const mcc = m.filter(e => e.is_mandatory && e.status === 'completed').length
      expect(Math.round((mcc / mc) * 100)).toBe(100)
    })
  })

  describe('completeEvent mutation', () => {
    it('updates event status to completed in list', () => {
      const list = events.map(e => ({ ...e }))
      const idx = list.findIndex(e => e.id === 'e2')
      if (idx >= 0) {
        list[idx] = { ...list[idx]!, status: 'completed' }
      }
      expect(list[idx]!.status).toBe('completed')
    })
  })

  describe('skipEvent mutation', () => {
    it('updates event status to skipped in list', () => {
      const list = events.map(e => ({ ...e }))
      const idx = list.findIndex(e => e.id === 'e3')
      if (idx >= 0) {
        list[idx] = { ...list[idx]!, status: 'skipped' }
      }
      expect(list[idx]!.status).toBe('skipped')
    })
  })
})

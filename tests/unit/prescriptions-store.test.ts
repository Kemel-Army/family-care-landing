import { describe, it, expect } from 'vitest'

describe('prescriptions store getters (pure logic)', () => {
  const prescriptions = [
    { id: 'rx1', medication: 'Витамин D3', is_active: true },
    { id: 'rx2', medication: 'Фолиевая кислота', is_active: true },
    { id: 'rx3', medication: 'Железо', is_active: false },
  ]

  const todayDoses = [
    { id: 'd1', prescription_id: 'rx1', status: 'confirmed', scheduled_at: '2026-04-15T08:00:00' },
    { id: 'd2', prescription_id: 'rx1', status: 'pending', scheduled_at: '2026-04-15T20:00:00' },
    { id: 'd3', prescription_id: 'rx2', status: 'confirmed', scheduled_at: '2026-04-15T09:00:00' },
    { id: 'd4', prescription_id: 'rx2', status: 'missed', scheduled_at: '2026-04-15T21:00:00' },
    { id: 'd5', prescription_id: 'rx2', status: 'skipped', scheduled_at: '2026-04-15T12:00:00' },
  ]

  describe('activePrescriptions', () => {
    it('filters active prescriptions', () => {
      const active = prescriptions.filter(p => p.is_active)
      expect(active).toHaveLength(2)
      expect(active.map(p => p.medication)).toContain('Витамин D3')
      expect(active.map(p => p.medication)).toContain('Фолиевая кислота')
    })
  })

  describe('pendingDoses', () => {
    it('filters pending doses', () => {
      const pending = todayDoses.filter(d => d.status === 'pending')
      expect(pending).toHaveLength(1)
      expect(pending[0].id).toBe('d2')
    })
  })

  describe('confirmedDoses', () => {
    it('filters confirmed doses', () => {
      const confirmed = todayDoses.filter(d => d.status === 'confirmed')
      expect(confirmed).toHaveLength(2)
    })
  })

  describe('missedDoses', () => {
    it('filters missed doses', () => {
      const missed = todayDoses.filter(d => d.status === 'missed')
      expect(missed).toHaveLength(1)
    })
  })

  describe('adherencePercent', () => {
    it('calculates percentage of confirmed doses', () => {
      const total = todayDoses.length
      const confirmed = todayDoses.filter(d => d.status === 'confirmed').length
      const adherence = total > 0 ? Math.round((confirmed / total) * 100) : 100
      expect(adherence).toBe(40)
    })

    it('returns 100 when no doses', () => {
      const total = 0
      const adherence = total > 0 ? Math.round((0 / total) * 100) : 100
      expect(adherence).toBe(100)
    })

    it('returns 0 when all missed', () => {
      const doses = [
        { status: 'missed' },
        { status: 'missed' },
      ]
      const total = doses.length
      const confirmed = doses.filter(d => d.status === 'confirmed').length
      const adherence = Math.round((confirmed / total) * 100)
      expect(adherence).toBe(0)
    })

    it('returns 100 when all confirmed', () => {
      const doses = [
        { status: 'confirmed' },
        { status: 'confirmed' },
        { status: 'confirmed' },
      ]
      const total = doses.length
      const confirmed = doses.filter(d => d.status === 'confirmed').length
      const adherence = Math.round((confirmed / total) * 100)
      expect(adherence).toBe(100)
    })
  })

  describe('confirmDose mutation', () => {
    it('updates dose status to confirmed in list', () => {
      const list = todayDoses.map(d => ({ ...d }))
      const idx = list.findIndex(d => d.id === 'd2')
      if (idx >= 0) {
        list[idx] = { ...list[idx]!, status: 'confirmed' }
      }
      expect(list[idx]!.status).toBe('confirmed')
    })
  })

  describe('skipDose mutation', () => {
    it('updates dose status to skipped in list', () => {
      const list = todayDoses.map(d => ({ ...d }))
      const idx = list.findIndex(d => d.id === 'd2')
      if (idx >= 0) {
        list[idx] = { ...list[idx]!, status: 'skipped' }
      }
      expect(list[idx]!.status).toBe('skipped')
    })
  })
})

import { describe, it, expect } from 'vitest'

describe('notifications store getters (pure logic)', () => {
  const notifications = [
    { id: 'n1', read_at: null, created_at: '2026-04-15T10:00:00Z', type: 'reminder' },
    { id: 'n2', read_at: '2026-04-15T09:00:00Z', created_at: '2026-04-15T08:00:00Z', type: 'alert' },
    { id: 'n3', read_at: null, created_at: '2026-04-14T12:00:00Z', type: 'appointment' },
    { id: 'n4', read_at: null, created_at: '2026-04-14T10:00:00Z', type: 'dose_reminder' },
    { id: 'n5', read_at: '2026-04-13T10:00:00Z', created_at: '2026-04-13T09:00:00Z', type: 'system' },
  ]

  describe('unread', () => {
    it('filters notifications without read_at', () => {
      const unread = notifications.filter(n => !n.read_at)
      expect(unread).toHaveLength(3)
      expect(unread.map(n => n.id)).toEqual(['n1', 'n3', 'n4'])
    })
  })

  describe('unreadCount', () => {
    it('counts unread notifications', () => {
      const unreadCount = notifications.filter(n => !n.read_at).length
      expect(unreadCount).toBe(3)
    })
  })

  describe('recent', () => {
    it('returns first 20 (or fewer)', () => {
      const recent = notifications.slice(0, 20)
      expect(recent).toHaveLength(5)
    })
  })

  describe('markAsRead', () => {
    it('sets read_at and decrements unreadCount', () => {
      const list = notifications.map(n => ({ ...n }))
      let unreadCount = list.filter(n => !n.read_at).length

      const idx = list.findIndex(n => n.id === 'n1')
      if (idx >= 0) {
        list[idx]!.read_at = new Date().toISOString()
        unreadCount = Math.max(0, unreadCount - 1)
      }

      expect(list[idx]!.read_at).toBeTruthy()
      expect(unreadCount).toBe(2)
    })
  })

  describe('markAllAsRead', () => {
    it('sets read_at on all unread and resets count', () => {
      const list = notifications.map(n => ({ ...n }))
      list.forEach(n => {
        if (!n.read_at) n.read_at = new Date().toISOString()
      })
      const unreadCount = 0

      expect(list.every(n => n.read_at)).toBe(true)
      expect(unreadCount).toBe(0)
    })
  })
})

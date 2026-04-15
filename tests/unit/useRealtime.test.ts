import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref } from 'vue'

const mockSubscribe = vi.fn().mockReturnValue({ id: 'ch-1' })
const mockOn = vi.fn().mockReturnThis()
const mockChannel = vi.fn().mockReturnValue({ on: mockOn, subscribe: mockSubscribe })
const mockRemoveChannel = vi.fn()

vi.stubGlobal('useSupabaseClient', () => ({
  channel: mockChannel,
  removeChannel: mockRemoveChannel,
}))
vi.stubGlobal('ref', ref)
vi.stubGlobal('onUnmounted', vi.fn((cb) => cb)) // capture cleanup

let cleanupFn: (() => void) | null = null
vi.stubGlobal('onUnmounted', (fn: () => void) => { cleanupFn = fn })

describe('useRealtime', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    vi.resetModules()
    cleanupFn = null
  })

  it('subscribeToTable creates a channel subscription', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToTable } = useRealtime()

    const onInsert = vi.fn()
    subscribeToTable('notifications', {
      event: 'INSERT',
      filter: 'user_id=eq.123',
      onInsert,
    })

    expect(mockChannel).toHaveBeenCalledWith(expect.stringContaining('notifications'))
    expect(mockOn).toHaveBeenCalled()
    expect(mockSubscribe).toHaveBeenCalled()
  })

  it('tracks channels for cleanup', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToTable, channels } = useRealtime()

    subscribeToTable('dose_logs', { onChange: vi.fn() })
    subscribeToTable('notifications', { onInsert: vi.fn() })

    expect(channels.value).toHaveLength(2)
  })

  it('unsubscribeAll removes all channels', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToTable, unsubscribeAll, channels } = useRealtime()

    subscribeToTable('t1', { onChange: vi.fn() })
    subscribeToTable('t2', { onChange: vi.fn() })

    unsubscribeAll()

    expect(mockRemoveChannel).toHaveBeenCalledTimes(2)
    expect(channels.value).toHaveLength(0)
  })

  it('subscribeToJourneyEvents filters by journey_id', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToJourneyEvents } = useRealtime()

    subscribeToJourneyEvents('j-123', vi.fn())

    expect(mockOn).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        table: 'journey_events',
        filter: 'journey_id=eq.j-123',
      }),
      expect.any(Function),
    )
  })

  it('subscribeToNotifications filters by user_id', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToNotifications } = useRealtime()

    subscribeToNotifications('user-1', vi.fn())

    expect(mockOn).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        table: 'notifications',
        filter: 'user_id=eq.user-1',
      }),
      expect.any(Function),
    )
  })

  it('subscribeToDoseLogs filters by family_id', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToDoseLogs } = useRealtime()

    subscribeToDoseLogs('fam-1', vi.fn())

    expect(mockOn).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        table: 'dose_logs',
        filter: 'family_id=eq.fam-1',
      }),
      expect.any(Function),
    )
  })

  it('subscribeToTasks filters by clinic_id', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToTasks } = useRealtime()

    subscribeToTasks('clinic-1', vi.fn())

    expect(mockOn).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({
        table: 'coordinator_tasks',
        filter: 'clinic_id=eq.clinic-1',
      }),
      expect.any(Function),
    )
  })

  it('auto-cleanup on unmount calls unsubscribeAll', async () => {
    const { useRealtime } = await import('../../app/composables/useRealtime')
    const { subscribeToTable } = useRealtime()

    subscribeToTable('test', { onChange: vi.fn() })

    // onUnmounted callback should have been captured
    if (cleanupFn) cleanupFn()
    expect(mockRemoveChannel).toHaveBeenCalled()
  })
})

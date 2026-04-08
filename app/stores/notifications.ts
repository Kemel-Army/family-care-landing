import { defineStore } from 'pinia'
import type { Notification } from '~/types/database'

interface NotificationState {
  notifications: Notification[]
  unreadCount: number
  loading: boolean
}

export const useNotificationStore = defineStore('notifications', {
  state: (): NotificationState => ({
    notifications: [],
    unreadCount: 0,
    loading: false,
  }),

  getters: {
    unread: (state) => state.notifications.filter(n => !n.read_at),
    recent: (state) => state.notifications.slice(0, 20),
  },

  actions: {
    async fetchNotifications() {
      const supabase = useSupabaseClient()
      const user = useSupabaseUser()
      if (!user.value?.id) return

      this.loading = true
      try {
        const { data } = await supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.value.id)
          .order('created_at', { ascending: false })
          .limit(50)

        if (data) {
          this.notifications = data as Notification[]
          this.unreadCount = data.filter((n: any) => !n.read_at).length
        }
      }
      finally {
        this.loading = false
      }
    },

    async markAsRead(notificationId: string) {
      const supabase = useSupabaseClient()

      const { error } = await supabase
        .from('notifications')
        .update({ read_at: new Date().toISOString() })
        .eq('id', notificationId)

      if (!error) {
        const idx = this.notifications.findIndex(n => n.id === notificationId)
        if (idx >= 0) {
          this.notifications[idx].read_at = new Date().toISOString()
          this.unreadCount = Math.max(0, this.unreadCount - 1)
        }
      }
    },

    async markAllAsRead() {
      const supabase = useSupabaseClient()
      const user = useSupabaseUser()
      if (!user.value?.id) return

      const { error } = await supabase
        .from('notifications')
        .update({ read_at: new Date().toISOString() })
        .eq('user_id', user.value.id)
        .is('read_at', null)

      if (!error) {
        this.notifications.forEach(n => {
          if (!n.read_at) n.read_at = new Date().toISOString()
        })
        this.unreadCount = 0
      }
    },

    // Subscribe to real-time notifications
    subscribeToNotifications() {
      const supabase = useSupabaseClient()
      const user = useSupabaseUser()
      if (!user.value?.id) return

      const channelName = `notifications:${user.value.id}`
      const channel = supabase
        .channel(channelName)
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'notifications',
            filter: `user_id=eq.${user.value.id}`,
          },
          (payload) => {
            this.notifications.unshift(payload.new as Notification)
            this.unreadCount++
          },
        )
        .subscribe()

      return channel
    },
  },
})

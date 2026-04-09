import { defineStore } from 'pinia'
import type { Journey, JourneyEvent } from '~/types/database'

interface JourneyState {
  activeJourneys: Journey[]
  currentJourney: Journey | null
  events: JourneyEvent[]
  loading: boolean
}

export const useJourneyStore = defineStore('journey', {
  state: (): JourneyState => ({
    activeJourneys: [],
    currentJourney: null,
    events: [],
    loading: false,
  }),

  getters: {
    upcomingEvents: (state) => {
      return state.events
        .filter(e => ['upcoming', 'due'].includes(e.status))
        .sort((a, b) => {
          if (!a.due_date || !b.due_date) return 0
          return new Date(a.due_date).getTime() - new Date(b.due_date).getTime()
        })
        .slice(0, 5)
    },
    overdueEvents: (state) => {
      return state.events.filter(e => e.status === 'overdue')
    },
    todayEvents: (state) => {
      const today = new Date().toISOString().split('T')[0]
      return state.events.filter(e => e.due_date?.startsWith(today))
    },
    completedCount: (state) => state.events.filter(e => e.status === 'completed').length,
    mandatoryCount: (state) => state.events.filter(e => e.is_mandatory).length,
    mandatoryCompletedCount: (state) => state.events.filter(e => e.is_mandatory && e.status === 'completed').length,
    progressPercent(): number {
      if (this.mandatoryCount === 0) return 0
      return Math.round((this.mandatoryCompletedCount / this.mandatoryCount) * 100)
    },
  },

  actions: {
    async fetchJourneys(familyId: string) {
      this.loading = true
      try {
        const supabase = useSupabaseClient()
        const { data } = await supabase
          .from('journeys')
          .select('*')
          .eq('family_id', familyId)
          .eq('status', 'active')
          .order('created_at', { ascending: false })

        if (data) {
          this.activeJourneys = data as Journey[]
          if (data.length > 0) {
            this.currentJourney = data[0] as Journey
            await this.fetchEvents(data[0].id)
          }
        }
      }
      finally {
        this.loading = false
      }
    },

    async fetchEvents(journeyId: string) {
      const supabase = useSupabaseClient()
      const { data } = await supabase
        .from('journey_events')
        .select('*')
        .eq('journey_id', journeyId)
        .order('due_date', { ascending: true })

      if (data) {
        this.events = data as JourneyEvent[]
      }
    },

    async completeEvent(eventId: string) {
      const supabase = useSupabaseClient()
      const user = useSupabaseUser()
      const userId = (user.value as any)?.id ?? (user.value as any)?.sub

      const { data, error } = await supabase
        .from('journey_events')
        .update({
          status: 'completed',
          completed_at: new Date().toISOString(),
          completed_by: userId,
        })
        .eq('id', eventId)
        .select()
        .single()

      if (!error && data) {
        const idx = this.events.findIndex(e => e.id === eventId)
        if (idx >= 0) this.events[idx] = data as JourneyEvent
      }
      return { data, error }
    },

    async skipEvent(eventId: string, reason?: string) {
      const supabase = useSupabaseClient()

      const { data, error } = await supabase
        .from('journey_events')
        .update({
          status: 'skipped',
          notes: reason || null,
        })
        .eq('id', eventId)
        .select()
        .single()

      if (!error && data) {
        const idx = this.events.findIndex(e => e.id === eventId)
        if (idx >= 0) this.events[idx] = data as JourneyEvent
      }
      return { data, error }
    },
  },
})

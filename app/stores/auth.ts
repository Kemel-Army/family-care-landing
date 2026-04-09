import { defineStore } from 'pinia'
import type { User, Family, MotherProfile, ChildProfile, Consent, UserRole } from '~/types/database'
import { ROLE_HOME_MAP, DOCTOR_ROLES } from '~/utils/constants'

interface AuthState {
  profile: User | null
  family: Family | null
  motherProfile: MotherProfile | null
  children: ChildProfile[]
  consents: Consent[]
  doctorId: string | null
  loading: boolean
  initialized: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    profile: null,
    family: null,
    motherProfile: null,
    children: [],
    consents: [],
    doctorId: null,
    loading: false,
    initialized: false,
  }),

  getters: {
    isAuthenticated: (state) => !!state.profile,
    role: (state): UserRole => state.profile?.role ?? 'mother',
    clinicId: (state) => state.profile?.clinic_id,
    familyId: (state) => state.family?.id,
    fullName: (state) => state.profile ? `${state.profile.first_name} ${state.profile.last_name}` : '',
    homeRoute(): string {
      return ROLE_HOME_MAP[this.role]
    },
    activeChildren: (state) => state.children.filter(c => c.dob),
    hasConsent: (state) => (type: string) => {
      return state.consents.find(c => c.type === type)?.granted ?? false
    },
  },

  actions: {
    async initialize() {
      if (this.initialized) return
      this.loading = true

      try {
        const supabase = useSupabaseClient()
        const user = useSupabaseUser()
        // On SSR, useSupabaseUser() returns decoded JWT payload (sub, not id)
        // On client, it returns the full User object (id)
        const userId = (user.value as any)?.id ?? (user.value as any)?.sub
        if (!userId) return

        // Fetch user profile from public.users
        const { data: profile, error: profileError } = await supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single()

        if (profileError) {
          console.error('[AuthStore] Failed to load profile:', profileError.message)
        }

        if (profile) {
          this.profile = profile as User
        }

        // Fetch doctor record if doctor/nurse role
        if (this.profile && DOCTOR_ROLES.includes(this.profile.role)) {
          const { data: doctorRow } = await supabase
            .from('doctors')
            .select('id')
            .eq('user_id', userId)
            .single()
          if (doctorRow) this.doctorId = doctorRow.id
        }

        // Fetch family if family role
        if (this.profile && ['mother', 'father'].includes(this.profile.role)) {
          const { data: family, error: familyError } = await supabase
            .from('families')
            .select('*')
            .or(`primary_parent_id.eq.${userId},secondary_parent_id.eq.${userId}`)
            .eq('status', 'active')
            .single()

          if (familyError) {
            console.error('[AuthStore] Failed to load family:', familyError.message)
          }

          if (family) {
            this.family = family as Family

            // Fetch mother profile
            const { data: mp } = await supabase
              .from('mother_profiles')
              .select('*')
              .eq('family_id', family.id)
              .single()
            if (mp) this.motherProfile = mp as MotherProfile

            // Fetch children
            const { data: children } = await supabase
              .from('child_profiles')
              .select('*')
              .eq('family_id', family.id)
              .order('created_at', { ascending: false })
            if (children) this.children = children as ChildProfile[]
          }
        }

        // Fetch consents
        const { data: consents } = await supabase
          .from('consents')
          .select('*')
          .eq('user_id', userId)
        if (consents) this.consents = consents as Consent[]

        this.initialized = true
      }
      finally {
        this.loading = false
      }
    },

    async updateProfile(updates: Partial<User>) {
      const supabase = useSupabaseClient()
      if (!this.profile) return

      const { data, error } = await supabase
        .from('users')
        .update(updates)
        .eq('id', this.profile.id)
        .select()
        .single()

      if (!error && data) {
        this.profile = data as User
      }
      return { data, error }
    },

    async updateConsent(type: string, granted: boolean) {
      const supabase = useSupabaseClient()
      const user = useSupabaseUser()
      if (!user.value) return
      const userId = (user.value as any).id ?? (user.value as any).sub

      const { data, error } = await supabase
        .from('consents')
        .upsert({
          user_id: userId,
          type,
          granted,
          granted_at: granted ? new Date().toISOString() : null,
          revoked_at: !granted ? new Date().toISOString() : null,
        }, { onConflict: 'user_id,type' })
        .select()
        .single()

      if (!error && data) {
        const idx = this.consents.findIndex(c => c.type === type)
        if (idx >= 0) this.consents[idx] = data as Consent
        else this.consents.push(data as Consent)
      }
      return { data, error }
    },

    reset() {
      this.profile = null
      this.family = null
      this.motherProfile = null
      this.children = []
      this.consents = []
      this.loading = false
      this.initialized = false
    },
  },
})

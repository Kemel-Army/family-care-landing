export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      achievements: {
        Row: {
          category: string | null
          created_at: string | null
          criteria_json: Json
          description: string | null
          icon: string | null
          id: string
          name: string
          points: number | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          criteria_json?: Json
          description?: string | null
          icon?: string | null
          id?: string
          name: string
          points?: number | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          criteria_json?: Json
          description?: string | null
          icon?: string | null
          id?: string
          name?: string
          points?: number | null
        }
        Relationships: []
      }
      ai_conversations: {
        Row: {
          child_id: string | null
          created_at: string | null
          id: string
          messages: Json
          updated_at: string | null
          user_id: string
        }
        Insert: {
          child_id?: string | null
          created_at?: string | null
          id?: string
          messages?: Json
          updated_at?: string | null
          user_id: string
        }
        Update: {
          child_id?: string | null
          created_at?: string | null
          id?: string
          messages?: Json
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_conversations_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_conversations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      ai_feedback: {
        Row: {
          comment: string | null
          conversation_id: string
          created_at: string | null
          doctor_agreed: boolean | null
          id: string
          message_index: number
          was_helpful: boolean | null
        }
        Insert: {
          comment?: string | null
          conversation_id: string
          created_at?: string | null
          doctor_agreed?: boolean | null
          id?: string
          message_index: number
          was_helpful?: boolean | null
        }
        Update: {
          comment?: string | null
          conversation_id?: string
          created_at?: string | null
          doctor_agreed?: boolean | null
          id?: string
          message_index?: number
          was_helpful?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "ai_feedback_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "ai_conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      appointment_slots: {
        Row: {
          created_at: string | null
          date: string
          doctor_id: string
          end_time: string
          id: string
          is_available: boolean | null
          start_time: string
        }
        Insert: {
          created_at?: string | null
          date: string
          doctor_id: string
          end_time: string
          id?: string
          is_available?: boolean | null
          start_time: string
        }
        Update: {
          created_at?: string | null
          date?: string
          doctor_id?: string
          end_time?: string
          id?: string
          is_available?: boolean | null
          start_time?: string
        }
        Relationships: [
          {
            foreignKeyName: "appointment_slots_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "doctors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointment_slots_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "v_doctor_performance"
            referencedColumns: ["doctor_id"]
          },
        ]
      }
      appointments: {
        Row: {
          appointment_date: string
          cancel_reason: string | null
          cancelled_at: string | null
          child_id: string | null
          created_at: string | null
          doctor_id: string
          end_time: string | null
          family_id: string
          id: string
          journey_event_id: string | null
          notes: string | null
          post_visit_notes: string | null
          pre_visit_answers: Json | null
          reason: string | null
          slot_id: string | null
          start_time: string
          status: string
          updated_at: string | null
          visit_type: string | null
        }
        Insert: {
          appointment_date: string
          cancel_reason?: string | null
          cancelled_at?: string | null
          child_id?: string | null
          created_at?: string | null
          doctor_id: string
          end_time?: string | null
          family_id: string
          id?: string
          journey_event_id?: string | null
          notes?: string | null
          post_visit_notes?: string | null
          pre_visit_answers?: Json | null
          reason?: string | null
          slot_id?: string | null
          start_time: string
          status?: string
          updated_at?: string | null
          visit_type?: string | null
        }
        Update: {
          appointment_date?: string
          cancel_reason?: string | null
          cancelled_at?: string | null
          child_id?: string | null
          created_at?: string | null
          doctor_id?: string
          end_time?: string | null
          family_id?: string
          id?: string
          journey_event_id?: string | null
          notes?: string | null
          post_visit_notes?: string | null
          pre_visit_answers?: Json | null
          reason?: string | null
          slot_id?: string | null
          start_time?: string
          status?: string
          updated_at?: string | null
          visit_type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "appointments_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointments_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "doctors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointments_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "v_doctor_performance"
            referencedColumns: ["doctor_id"]
          },
          {
            foreignKeyName: "appointments_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointments_journey_event_id_fkey"
            columns: ["journey_event_id"]
            isOneToOne: false
            referencedRelation: "journey_events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "appointments_slot_id_fkey"
            columns: ["slot_id"]
            isOneToOne: false
            referencedRelation: "appointment_slots"
            referencedColumns: ["id"]
          },
        ]
      }
      child_profiles: {
        Row: {
          allergies: string[] | null
          apgar_1min: number | null
          apgar_5min: number | null
          birth_height: number | null
          birth_weight: number | null
          blood_type: string | null
          created_at: string | null
          dob: string | null
          family_id: string
          gender: string | null
          id: string
          is_active: boolean | null
          name: string
          photo_url: string | null
          updated_at: string | null
        }
        Insert: {
          allergies?: string[] | null
          apgar_1min?: number | null
          apgar_5min?: number | null
          birth_height?: number | null
          birth_weight?: number | null
          blood_type?: string | null
          created_at?: string | null
          dob?: string | null
          family_id: string
          gender?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          photo_url?: string | null
          updated_at?: string | null
        }
        Update: {
          allergies?: string[] | null
          apgar_1min?: number | null
          apgar_5min?: number | null
          birth_height?: number | null
          birth_weight?: number | null
          blood_type?: string | null
          created_at?: string | null
          dob?: string | null
          family_id?: string
          gender?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          photo_url?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "child_profiles_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      clinic_network_members: {
        Row: {
          clinic_id: string
          joined_at: string | null
          network_id: string
        }
        Insert: {
          clinic_id: string
          joined_at?: string | null
          network_id: string
        }
        Update: {
          clinic_id?: string
          joined_at?: string | null
          network_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "clinic_network_members_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "clinic_network_members_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
          {
            foreignKeyName: "clinic_network_members_network_id_fkey"
            columns: ["network_id"]
            isOneToOne: false
            referencedRelation: "clinic_networks"
            referencedColumns: ["id"]
          },
        ]
      }
      clinic_networks: {
        Row: {
          created_at: string | null
          id: string
          name: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          name: string
        }
        Update: {
          created_at?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      clinics: {
        Row: {
          address: string | null
          created_at: string | null
          id: string
          is_active: boolean | null
          logo_url: string | null
          name: string
          phone: string | null
          review_link_2gis: string | null
          review_link_google: string | null
          settings_json: Json | null
          slug: string
          theme_json: Json | null
          timezone: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          logo_url?: string | null
          name: string
          phone?: string | null
          review_link_2gis?: string | null
          review_link_google?: string | null
          settings_json?: Json | null
          slug: string
          theme_json?: Json | null
          timezone?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          logo_url?: string | null
          name?: string
          phone?: string | null
          review_link_2gis?: string | null
          review_link_google?: string | null
          settings_json?: Json | null
          slug?: string
          theme_json?: Json | null
          timezone?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      consents: {
        Row: {
          created_at: string | null
          granted: boolean | null
          granted_at: string | null
          id: string
          revoked_at: string | null
          type: string
          user_id: string
        }
        Insert: {
          created_at?: string | null
          granted?: boolean | null
          granted_at?: string | null
          id?: string
          revoked_at?: string | null
          type: string
          user_id: string
        }
        Update: {
          created_at?: string | null
          granted?: boolean | null
          granted_at?: string | null
          id?: string
          revoked_at?: string | null
          type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "consents_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      content_views: {
        Row: {
          content_id: string
          id: string
          user_id: string
          viewed_at: string | null
        }
        Insert: {
          content_id: string
          id?: string
          user_id: string
          viewed_at?: string | null
        }
        Update: {
          content_id?: string
          id?: string
          user_id?: string
          viewed_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "content_views_content_id_fkey"
            columns: ["content_id"]
            isOneToOne: false
            referencedRelation: "education_content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "content_views_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      coordinator_tasks: {
        Row: {
          assigned_to: string | null
          clinic_id: string
          completed_at: string | null
          created_at: string | null
          created_by: string | null
          due_date: string | null
          family_id: string | null
          id: string
          notes: string | null
          priority: string
          result: string | null
          status: string
          title: string
          type: string
          updated_at: string | null
        }
        Insert: {
          assigned_to?: string | null
          clinic_id: string
          completed_at?: string | null
          created_at?: string | null
          created_by?: string | null
          due_date?: string | null
          family_id?: string | null
          id?: string
          notes?: string | null
          priority?: string
          result?: string | null
          status?: string
          title: string
          type: string
          updated_at?: string | null
        }
        Update: {
          assigned_to?: string | null
          clinic_id?: string
          completed_at?: string | null
          created_at?: string | null
          created_by?: string | null
          due_date?: string | null
          family_id?: string | null
          id?: string
          notes?: string | null
          priority?: string
          result?: string | null
          status?: string
          title?: string
          type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "coordinator_tasks_assigned_to_fkey"
            columns: ["assigned_to"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "coordinator_tasks_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "coordinator_tasks_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
          {
            foreignKeyName: "coordinator_tasks_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      doctors: {
        Row: {
          bio: string | null
          clinic_id: string
          consultation_fee: number | null
          created_at: string | null
          experience_years: number | null
          id: string
          is_active: boolean | null
          specialty: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          bio?: string | null
          clinic_id: string
          consultation_fee?: number | null
          created_at?: string | null
          experience_years?: number | null
          id?: string
          is_active?: boolean | null
          specialty: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          bio?: string | null
          clinic_id?: string
          consultation_fee?: number | null
          created_at?: string | null
          experience_years?: number | null
          id?: string
          is_active?: boolean | null
          specialty?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "doctors_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doctors_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
          {
            foreignKeyName: "doctors_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      documents: {
        Row: {
          child_id: string | null
          created_at: string | null
          description: string | null
          family_id: string
          file_size: number | null
          file_type: string | null
          file_url: string
          id: string
          journey_event_id: string | null
          tags: string[] | null
          title: string
          type: string
          updated_at: string | null
          uploaded_by: string | null
        }
        Insert: {
          child_id?: string | null
          created_at?: string | null
          description?: string | null
          family_id: string
          file_size?: number | null
          file_type?: string | null
          file_url: string
          id?: string
          journey_event_id?: string | null
          tags?: string[] | null
          title: string
          type: string
          updated_at?: string | null
          uploaded_by?: string | null
        }
        Update: {
          child_id?: string | null
          created_at?: string | null
          description?: string | null
          family_id?: string
          file_size?: number | null
          file_type?: string | null
          file_url?: string
          id?: string
          journey_event_id?: string | null
          tags?: string[] | null
          title?: string
          type?: string
          updated_at?: string | null
          uploaded_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "documents_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documents_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documents_journey_event_id_fkey"
            columns: ["journey_event_id"]
            isOneToOne: false
            referencedRelation: "journey_events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documents_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      dose_logs: {
        Row: {
          confirmed_at: string | null
          confirmed_by: string | null
          created_at: string | null
          family_id: string
          id: string
          prescription_id: string
          scheduled_at: string
          skip_reason: string | null
          status: string
        }
        Insert: {
          confirmed_at?: string | null
          confirmed_by?: string | null
          created_at?: string | null
          family_id: string
          id?: string
          prescription_id: string
          scheduled_at: string
          skip_reason?: string | null
          status?: string
        }
        Update: {
          confirmed_at?: string | null
          confirmed_by?: string | null
          created_at?: string | null
          family_id?: string
          id?: string
          prescription_id?: string
          scheduled_at?: string
          skip_reason?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "dose_logs_confirmed_by_fkey"
            columns: ["confirmed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "dose_logs_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "dose_logs_prescription_id_fkey"
            columns: ["prescription_id"]
            isOneToOne: false
            referencedRelation: "prescriptions"
            referencedColumns: ["id"]
          },
        ]
      }
      education_content: {
        Row: {
          body: string | null
          clinic_id: string | null
          created_at: string | null
          excerpt: string | null
          id: string
          is_published: boolean | null
          media_url: string | null
          published_at: string | null
          tags: string[] | null
          target_age_days: number | null
          target_journey_type: string | null
          target_week: number | null
          thumbnail_url: string | null
          title: string
          type: string
          updated_at: string | null
        }
        Insert: {
          body?: string | null
          clinic_id?: string | null
          created_at?: string | null
          excerpt?: string | null
          id?: string
          is_published?: boolean | null
          media_url?: string | null
          published_at?: string | null
          tags?: string[] | null
          target_age_days?: number | null
          target_journey_type?: string | null
          target_week?: number | null
          thumbnail_url?: string | null
          title: string
          type: string
          updated_at?: string | null
        }
        Update: {
          body?: string | null
          clinic_id?: string | null
          created_at?: string | null
          excerpt?: string | null
          id?: string
          is_published?: boolean | null
          media_url?: string | null
          published_at?: string | null
          tags?: string[] | null
          target_age_days?: number | null
          target_journey_type?: string | null
          target_week?: number | null
          thumbnail_url?: string | null
          title?: string
          type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "education_content_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "education_content_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      epds_screenings: {
        Row: {
          answers: Json
          created_at: string | null
          date: string
          id: string
          reviewed_at: string | null
          reviewed_by: string | null
          risk_level: string
          total_score: number
          user_id: string
        }
        Insert: {
          answers: Json
          created_at?: string | null
          date?: string
          id?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          risk_level: string
          total_score: number
          user_id: string
        }
        Update: {
          answers?: Json
          created_at?: string | null
          date?: string
          id?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          risk_level?: string
          total_score?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "epds_screenings_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "epds_screenings_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      families: {
        Row: {
          clinic_id: string
          created_at: string | null
          id: string
          invite_code: string | null
          primary_parent_id: string
          secondary_parent_id: string | null
          status: string
          updated_at: string | null
        }
        Insert: {
          clinic_id: string
          created_at?: string | null
          id?: string
          invite_code?: string | null
          primary_parent_id: string
          secondary_parent_id?: string | null
          status?: string
          updated_at?: string | null
        }
        Update: {
          clinic_id?: string
          created_at?: string | null
          id?: string
          invite_code?: string | null
          primary_parent_id?: string
          secondary_parent_id?: string | null
          status?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "families_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "families_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
          {
            foreignKeyName: "families_primary_parent_id_fkey"
            columns: ["primary_parent_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "families_secondary_parent_id_fkey"
            columns: ["secondary_parent_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      family_packages: {
        Row: {
          expires_at: string | null
          family_id: string
          id: string
          package_id: string
          purchased_at: string | null
          status: string | null
          usage_json: Json | null
        }
        Insert: {
          expires_at?: string | null
          family_id: string
          id?: string
          package_id: string
          purchased_at?: string | null
          status?: string | null
          usage_json?: Json | null
        }
        Update: {
          expires_at?: string | null
          family_id?: string
          id?: string
          package_id?: string
          purchased_at?: string | null
          status?: string | null
          usage_json?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "family_packages_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "family_packages_package_id_fkey"
            columns: ["package_id"]
            isOneToOne: false
            referencedRelation: "service_packages"
            referencedColumns: ["id"]
          },
        ]
      }
      feeding_logs: {
        Row: {
          child_id: string
          created_at: string | null
          details: Json | null
          duration_minutes: number | null
          id: string
          notes: string | null
          timestamp: string
          type: string
        }
        Insert: {
          child_id: string
          created_at?: string | null
          details?: Json | null
          duration_minutes?: number | null
          id?: string
          notes?: string | null
          timestamp?: string
          type: string
        }
        Update: {
          child_id?: string
          created_at?: string | null
          details?: Json | null
          duration_minutes?: number | null
          id?: string
          notes?: string | null
          timestamp?: string
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "feeding_logs_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      food_introductions: {
        Row: {
          child_id: string
          created_at: string | null
          food: string
          id: string
          introduced_at: string
          notes: string | null
          reaction: string | null
          status: string | null
        }
        Insert: {
          child_id: string
          created_at?: string | null
          food: string
          id?: string
          introduced_at: string
          notes?: string | null
          reaction?: string | null
          status?: string | null
        }
        Update: {
          child_id?: string
          created_at?: string | null
          food?: string
          id?: string
          introduced_at?: string
          notes?: string | null
          reaction?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "food_introductions_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      growth_metrics: {
        Row: {
          child_id: string
          created_at: string | null
          date: string
          head_cm: number | null
          height_cm: number | null
          id: string
          measured_by: string | null
          notes: string | null
          weight_kg: number | null
        }
        Insert: {
          child_id: string
          created_at?: string | null
          date: string
          head_cm?: number | null
          height_cm?: number | null
          id?: string
          measured_by?: string | null
          notes?: string | null
          weight_kg?: number | null
        }
        Update: {
          child_id?: string
          created_at?: string | null
          date?: string
          head_cm?: number | null
          height_cm?: number | null
          id?: string
          measured_by?: string | null
          notes?: string | null
          weight_kg?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "growth_metrics_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      health_passport_entries: {
        Row: {
          category: string | null
          child_id: string
          created_at: string | null
          date: string
          description: string | null
          doctor_id: string | null
          file_ids: string[] | null
          id: string
          source: string | null
          title: string
          type: string
        }
        Insert: {
          category?: string | null
          child_id: string
          created_at?: string | null
          date: string
          description?: string | null
          doctor_id?: string | null
          file_ids?: string[] | null
          id?: string
          source?: string | null
          title: string
          type: string
        }
        Update: {
          category?: string | null
          child_id?: string
          created_at?: string | null
          date?: string
          description?: string | null
          doctor_id?: string | null
          file_ids?: string[] | null
          id?: string
          source?: string | null
          title?: string
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "health_passport_entries_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "health_passport_entries_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "doctors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "health_passport_entries_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "v_doctor_performance"
            referencedColumns: ["doctor_id"]
          },
        ]
      }
      integrations: {
        Row: {
          clinic_id: string
          config_encrypted: string | null
          created_at: string | null
          id: string
          last_sync_at: string | null
          provider: string
          sync_status: string | null
          type: string
          updated_at: string | null
        }
        Insert: {
          clinic_id: string
          config_encrypted?: string | null
          created_at?: string | null
          id?: string
          last_sync_at?: string | null
          provider: string
          sync_status?: string | null
          type: string
          updated_at?: string | null
        }
        Update: {
          clinic_id?: string
          config_encrypted?: string | null
          created_at?: string | null
          id?: string
          last_sync_at?: string | null
          provider?: string
          sync_status?: string | null
          type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "integrations_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "integrations_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      journey_events: {
        Row: {
          completed_at: string | null
          completed_by: string | null
          created_at: string | null
          description: string | null
          due_date: string | null
          id: string
          is_mandatory: boolean | null
          journey_id: string
          metadata: Json | null
          notes: string | null
          skip_reason: string | null
          status: string
          title: string
          trigger_day: number | null
          trigger_week: number | null
          type: string
          updated_at: string | null
        }
        Insert: {
          completed_at?: string | null
          completed_by?: string | null
          created_at?: string | null
          description?: string | null
          due_date?: string | null
          id?: string
          is_mandatory?: boolean | null
          journey_id: string
          metadata?: Json | null
          notes?: string | null
          skip_reason?: string | null
          status?: string
          title: string
          trigger_day?: number | null
          trigger_week?: number | null
          type: string
          updated_at?: string | null
        }
        Update: {
          completed_at?: string | null
          completed_by?: string | null
          created_at?: string | null
          description?: string | null
          due_date?: string | null
          id?: string
          is_mandatory?: boolean | null
          journey_id?: string
          metadata?: Json | null
          notes?: string | null
          skip_reason?: string | null
          status?: string
          title?: string
          trigger_day?: number | null
          trigger_week?: number | null
          type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "journey_events_completed_by_fkey"
            columns: ["completed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "journey_events_journey_id_fkey"
            columns: ["journey_id"]
            isOneToOne: false
            referencedRelation: "journeys"
            referencedColumns: ["id"]
          },
        ]
      }
      journey_templates: {
        Row: {
          clinic_id: string | null
          created_at: string | null
          description: string | null
          events_json: Json
          id: string
          is_active: boolean | null
          is_default: boolean | null
          name: string
          type: string
          updated_at: string | null
        }
        Insert: {
          clinic_id?: string | null
          created_at?: string | null
          description?: string | null
          events_json?: Json
          id?: string
          is_active?: boolean | null
          is_default?: boolean | null
          name: string
          type: string
          updated_at?: string | null
        }
        Update: {
          clinic_id?: string | null
          created_at?: string | null
          description?: string | null
          events_json?: Json
          id?: string
          is_active?: boolean | null
          is_default?: boolean | null
          name?: string
          type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "journey_templates_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "journey_templates_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      journeys: {
        Row: {
          child_id: string | null
          completed_at: string | null
          created_at: string | null
          family_id: string
          id: string
          metadata: Json | null
          started_at: string | null
          status: string
          template_id: string | null
          type: string
          updated_at: string | null
        }
        Insert: {
          child_id?: string | null
          completed_at?: string | null
          created_at?: string | null
          family_id: string
          id?: string
          metadata?: Json | null
          started_at?: string | null
          status?: string
          template_id?: string | null
          type: string
          updated_at?: string | null
        }
        Update: {
          child_id?: string | null
          completed_at?: string | null
          created_at?: string | null
          family_id?: string
          id?: string
          metadata?: Json | null
          started_at?: string | null
          status?: string
          template_id?: string | null
          type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "journeys_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "journeys_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "journeys_template_id_fkey"
            columns: ["template_id"]
            isOneToOne: false
            referencedRelation: "journey_templates"
            referencedColumns: ["id"]
          },
        ]
      }
      lab_integrations: {
        Row: {
          api_key_encrypted: string | null
          clinic_id: string
          created_at: string | null
          id: string
          is_active: boolean | null
          lab_provider: string
          settings: Json | null
          updated_at: string | null
        }
        Insert: {
          api_key_encrypted?: string | null
          clinic_id: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          lab_provider: string
          settings?: Json | null
          updated_at?: string | null
        }
        Update: {
          api_key_encrypted?: string | null
          clinic_id?: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          lab_provider?: string
          settings?: Json | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "lab_integrations_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lab_integrations_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      lab_results: {
        Row: {
          child_id: string | null
          created_at: string | null
          family_id: string
          id: string
          lab_provider: string
          order_id: string | null
          raw_pdf_url: string | null
          received_at: string | null
          results_json: Json | null
          status: string
        }
        Insert: {
          child_id?: string | null
          created_at?: string | null
          family_id: string
          id?: string
          lab_provider: string
          order_id?: string | null
          raw_pdf_url?: string | null
          received_at?: string | null
          results_json?: Json | null
          status?: string
        }
        Update: {
          child_id?: string | null
          created_at?: string | null
          family_id?: string
          id?: string
          lab_provider?: string
          order_id?: string | null
          raw_pdf_url?: string | null
          received_at?: string | null
          results_json?: Json | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "lab_results_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lab_results_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      loyalty_points: {
        Row: {
          description: string | null
          earned_at: string | null
          family_id: string
          id: string
          points: number
          source: string
        }
        Insert: {
          description?: string | null
          earned_at?: string | null
          family_id: string
          id?: string
          points: number
          source: string
        }
        Update: {
          description?: string | null
          earned_at?: string | null
          family_id?: string
          id?: string
          points?: number
          source?: string
        }
        Relationships: [
          {
            foreignKeyName: "loyalty_points_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      milestones: {
        Row: {
          achieved_at: string | null
          child_id: string
          created_at: string | null
          id: string
          notes: string | null
          photo_url: string | null
          title: string
          type: string
        }
        Insert: {
          achieved_at?: string | null
          child_id: string
          created_at?: string | null
          id?: string
          notes?: string | null
          photo_url?: string | null
          title: string
          type: string
        }
        Update: {
          achieved_at?: string | null
          child_id?: string
          created_at?: string | null
          id?: string
          notes?: string | null
          photo_url?: string | null
          title?: string
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "milestones_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      mood_logs: {
        Row: {
          created_at: string | null
          date: string
          id: string
          notes: string | null
          score: number
          user_id: string
        }
        Insert: {
          created_at?: string | null
          date?: string
          id?: string
          notes?: string | null
          score: number
          user_id: string
        }
        Update: {
          created_at?: string | null
          date?: string
          id?: string
          notes?: string | null
          score?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mood_logs_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      mother_profiles: {
        Row: {
          allergies: string[] | null
          blood_type: string | null
          chronic_conditions: string[] | null
          created_at: string | null
          edd_date: string | null
          family_id: string
          gravida: number | null
          id: string
          lmp_date: string | null
          notes: string | null
          para: number | null
          pregnancy_number: number | null
          rh_factor: string | null
          updated_at: string | null
          user_id: string
        }
        Insert: {
          allergies?: string[] | null
          blood_type?: string | null
          chronic_conditions?: string[] | null
          created_at?: string | null
          edd_date?: string | null
          family_id: string
          gravida?: number | null
          id?: string
          lmp_date?: string | null
          notes?: string | null
          para?: number | null
          pregnancy_number?: number | null
          rh_factor?: string | null
          updated_at?: string | null
          user_id: string
        }
        Update: {
          allergies?: string[] | null
          blood_type?: string | null
          chronic_conditions?: string[] | null
          created_at?: string | null
          edd_date?: string | null
          family_id?: string
          gravida?: number | null
          id?: string
          lmp_date?: string | null
          notes?: string | null
          para?: number | null
          pregnancy_number?: number | null
          rh_factor?: string | null
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mother_profiles_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "mother_profiles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          body: string | null
          channel: string
          created_at: string | null
          data: Json | null
          id: string
          read_at: string | null
          sent_at: string | null
          status: string
          title: string
          type: string
          user_id: string
        }
        Insert: {
          body?: string | null
          channel?: string
          created_at?: string | null
          data?: Json | null
          id?: string
          read_at?: string | null
          sent_at?: string | null
          status?: string
          title: string
          type: string
          user_id: string
        }
        Update: {
          body?: string | null
          channel?: string
          created_at?: string | null
          data?: Json | null
          id?: string
          read_at?: string | null
          sent_at?: string | null
          status?: string
          title?: string
          type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      nps_responses: {
        Row: {
          comment: string | null
          created_at: string | null
          event_type: string | null
          family_id: string
          id: string
          score: number
        }
        Insert: {
          comment?: string | null
          created_at?: string | null
          event_type?: string | null
          family_id: string
          id?: string
          score: number
        }
        Update: {
          comment?: string | null
          created_at?: string | null
          event_type?: string | null
          family_id?: string
          id?: string
          score?: number
        }
        Relationships: [
          {
            foreignKeyName: "nps_responses_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      outreach_logs: {
        Row: {
          created_at: string | null
          family_id: string
          id: string
          result: string | null
          scenario_id: string
          sent_at: string | null
          status: string
        }
        Insert: {
          created_at?: string | null
          family_id: string
          id?: string
          result?: string | null
          scenario_id: string
          sent_at?: string | null
          status?: string
        }
        Update: {
          created_at?: string | null
          family_id?: string
          id?: string
          result?: string | null
          scenario_id?: string
          sent_at?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "outreach_logs_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outreach_logs_scenario_id_fkey"
            columns: ["scenario_id"]
            isOneToOne: false
            referencedRelation: "outreach_scenarios"
            referencedColumns: ["id"]
          },
        ]
      }
      outreach_scenarios: {
        Row: {
          actions_json: Json
          clinic_id: string
          created_at: string | null
          id: string
          is_active: boolean | null
          name: string
          trigger_json: Json
          updated_at: string | null
        }
        Insert: {
          actions_json?: Json
          clinic_id: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          trigger_json?: Json
          updated_at?: string | null
        }
        Update: {
          actions_json?: Json
          clinic_id?: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          trigger_json?: Json
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "outreach_scenarios_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "outreach_scenarios_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      push_tokens: {
        Row: {
          created_at: string | null
          device_type: string | null
          id: string
          token: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          device_type?: string | null
          id?: string
          token: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          device_type?: string | null
          id?: string
          token?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "push_tokens_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      prescriptions: {
        Row: {
          child_id: string | null
          created_at: string | null
          dosage: string
          end_date: string | null
          family_id: string
          frequency: string
          id: string
          instructions: string | null
          is_active: boolean | null
          medication: string
          prescribed_by: string | null
          start_date: string
          time_of_day: string[] | null
          updated_at: string | null
        }
        Insert: {
          child_id?: string | null
          created_at?: string | null
          dosage: string
          end_date?: string | null
          family_id: string
          frequency: string
          id?: string
          instructions?: string | null
          is_active?: boolean | null
          medication: string
          prescribed_by?: string | null
          start_date: string
          time_of_day?: string[] | null
          updated_at?: string | null
        }
        Update: {
          child_id?: string | null
          created_at?: string | null
          dosage?: string
          end_date?: string | null
          family_id?: string
          frequency?: string
          id?: string
          instructions?: string | null
          is_active?: boolean | null
          medication?: string
          prescribed_by?: string | null
          start_date?: string
          time_of_day?: string[] | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "prescriptions_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prescriptions_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "prescriptions_prescribed_by_fkey"
            columns: ["prescribed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      referrals: {
        Row: {
          created_at: string | null
          id: string
          referral_code: string
          referred_family_id: string | null
          referrer_family_id: string
          reward: string | null
          status: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          referral_code: string
          referred_family_id?: string | null
          referrer_family_id: string
          reward?: string | null
          status?: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          referral_code?: string
          referred_family_id?: string | null
          referrer_family_id?: string
          reward?: string | null
          status?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "referrals_referred_family_id_fkey"
            columns: ["referred_family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referrals_referrer_family_id_fkey"
            columns: ["referrer_family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      revenue_forecasts: {
        Row: {
          clinic_id: string
          created_at: string | null
          forecast_json: Json
          id: string
          period: string
        }
        Insert: {
          clinic_id: string
          created_at?: string | null
          forecast_json?: Json
          id?: string
          period: string
        }
        Update: {
          clinic_id?: string
          created_at?: string | null
          forecast_json?: Json
          id?: string
          period?: string
        }
        Relationships: [
          {
            foreignKeyName: "revenue_forecasts_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "revenue_forecasts_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      review_requests: {
        Row: {
          created_at: string | null
          event_type: string | null
          family_id: string
          id: string
          nps_score: number | null
          review_url: string | null
          status: string | null
        }
        Insert: {
          created_at?: string | null
          event_type?: string | null
          family_id: string
          id?: string
          nps_score?: number | null
          review_url?: string | null
          status?: string | null
        }
        Update: {
          created_at?: string | null
          event_type?: string | null
          family_id?: string
          id?: string
          nps_score?: number | null
          review_url?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "review_requests_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      service_packages: {
        Row: {
          clinic_id: string
          created_at: string | null
          description: string | null
          duration_months: number | null
          id: string
          is_active: boolean | null
          name: string
          price: number
          services_json: Json
          updated_at: string | null
        }
        Insert: {
          clinic_id: string
          created_at?: string | null
          description?: string | null
          duration_months?: number | null
          id?: string
          is_active?: boolean | null
          name: string
          price: number
          services_json?: Json
          updated_at?: string | null
        }
        Update: {
          clinic_id?: string
          created_at?: string | null
          description?: string | null
          duration_months?: number | null
          id?: string
          is_active?: boolean | null
          name?: string
          price?: number
          services_json?: Json
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "service_packages_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_packages_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      service_transactions: {
        Row: {
          amount: number
          appointment_id: string | null
          clinic_id: string
          created_at: string | null
          date: string
          description: string | null
          doctor_id: string | null
          family_id: string
          id: string
          service_type: string
        }
        Insert: {
          amount?: number
          appointment_id?: string | null
          clinic_id: string
          created_at?: string | null
          date?: string
          description?: string | null
          doctor_id?: string | null
          family_id: string
          id?: string
          service_type: string
        }
        Update: {
          amount?: number
          appointment_id?: string | null
          clinic_id?: string
          created_at?: string | null
          date?: string
          description?: string | null
          doctor_id?: string | null
          family_id?: string
          id?: string
          service_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "service_transactions_appointment_id_fkey"
            columns: ["appointment_id"]
            isOneToOne: false
            referencedRelation: "appointments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_transactions_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_transactions_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
          {
            foreignKeyName: "service_transactions_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "doctors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_transactions_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "v_doctor_performance"
            referencedColumns: ["doctor_id"]
          },
          {
            foreignKeyName: "service_transactions_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      sleep_logs: {
        Row: {
          child_id: string
          created_at: string | null
          date: string
          id: string
          notes: string | null
          quality: string | null
          sleep_end: string | null
          sleep_start: string
          type: string
          wake_ups: number | null
        }
        Insert: {
          child_id: string
          created_at?: string | null
          date: string
          id?: string
          notes?: string | null
          quality?: string | null
          sleep_end?: string | null
          sleep_start: string
          type: string
          wake_ups?: number | null
        }
        Update: {
          child_id?: string
          created_at?: string | null
          date?: string
          id?: string
          notes?: string | null
          quality?: string | null
          sleep_end?: string | null
          sleep_start?: string
          type?: string
          wake_ups?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "sleep_logs_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      sos_events: {
        Row: {
          actions_taken: string | null
          category: string
          child_id: string | null
          created_at: string | null
          family_id: string
          id: string
          location: Json | null
          resolved_at: string | null
          symptoms: string[] | null
          triage_result: string
        }
        Insert: {
          actions_taken?: string | null
          category: string
          child_id?: string | null
          created_at?: string | null
          family_id: string
          id?: string
          location?: Json | null
          resolved_at?: string | null
          symptoms?: string[] | null
          triage_result: string
        }
        Update: {
          actions_taken?: string | null
          category?: string
          child_id?: string | null
          created_at?: string | null
          family_id?: string
          id?: string
          location?: Json | null
          resolved_at?: string | null
          symptoms?: string[] | null
          triage_result?: string
        }
        Relationships: [
          {
            foreignKeyName: "sos_events_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sos_events_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      streaks: {
        Row: {
          created_at: string | null
          current_count: number
          id: string
          last_date: string | null
          longest_count: number
          type: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          current_count?: number
          id?: string
          last_date?: string | null
          longest_count?: number
          type: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          current_count?: number
          id?: string
          last_date?: string | null
          longest_count?: number
          type?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "streaks_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      sync_logs: {
        Row: {
          completed_at: string | null
          direction: string
          entity: string
          error_message: string | null
          id: string
          integration_id: string
          records_count: number | null
          started_at: string | null
          status: string
        }
        Insert: {
          completed_at?: string | null
          direction: string
          entity: string
          error_message?: string | null
          id?: string
          integration_id: string
          records_count?: number | null
          started_at?: string | null
          status: string
        }
        Update: {
          completed_at?: string | null
          direction?: string
          entity?: string
          error_message?: string | null
          id?: string
          integration_id?: string
          records_count?: number | null
          started_at?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "sync_logs_integration_id_fkey"
            columns: ["integration_id"]
            isOneToOne: false
            referencedRelation: "integrations"
            referencedColumns: ["id"]
          },
        ]
      }
      training_modules: {
        Row: {
          clinic_id: string
          content: Json
          created_at: string | null
          description: string | null
          id: string
          is_published: boolean | null
          passing_score: number | null
          role: string
          test_json: Json | null
          title: string
          updated_at: string | null
        }
        Insert: {
          clinic_id: string
          content?: Json
          created_at?: string | null
          description?: string | null
          id?: string
          is_published?: boolean | null
          passing_score?: number | null
          role: string
          test_json?: Json | null
          title: string
          updated_at?: string | null
        }
        Update: {
          clinic_id?: string
          content?: Json
          created_at?: string | null
          description?: string | null
          id?: string
          is_published?: boolean | null
          passing_score?: number | null
          role?: string
          test_json?: Json | null
          title?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "training_modules_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "training_modules_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      training_progress: {
        Row: {
          attempts: number | null
          completed_at: string | null
          created_at: string | null
          id: string
          module_id: string
          score: number | null
          user_id: string
        }
        Insert: {
          attempts?: number | null
          completed_at?: string | null
          created_at?: string | null
          id?: string
          module_id: string
          score?: number | null
          user_id: string
        }
        Update: {
          attempts?: number | null
          completed_at?: string | null
          created_at?: string | null
          id?: string
          module_id?: string
          score?: number | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "training_progress_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "training_modules"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "training_progress_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_achievements: {
        Row: {
          achievement_id: string
          earned_at: string | null
          id: string
          user_id: string
        }
        Insert: {
          achievement_id: string
          earned_at?: string | null
          id?: string
          user_id: string
        }
        Update: {
          achievement_id?: string
          earned_at?: string | null
          id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_achievements_achievement_id_fkey"
            columns: ["achievement_id"]
            isOneToOne: false
            referencedRelation: "achievements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_achievements_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          avatar_url: string | null
          clinic_id: string | null
          created_at: string | null
          email: string
          first_name: string
          id: string
          is_active: boolean | null
          last_name: string
          last_seen_at: string | null
          phone: string | null
          role: string
          updated_at: string | null
        }
        Insert: {
          avatar_url?: string | null
          clinic_id?: string | null
          created_at?: string | null
          email: string
          first_name: string
          id: string
          is_active?: boolean | null
          last_name: string
          last_seen_at?: string | null
          phone?: string | null
          role?: string
          updated_at?: string | null
        }
        Update: {
          avatar_url?: string | null
          clinic_id?: string | null
          created_at?: string | null
          email?: string
          first_name?: string
          id?: string
          is_active?: boolean | null
          last_name?: string
          last_seen_at?: string | null
          phone?: string | null
          role?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "users_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "users_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
      vaccinations: {
        Row: {
          administered_date: string | null
          batch_number: string | null
          child_id: string
          created_at: string | null
          doctor_id: string | null
          dose_number: number
          id: string
          notes: string | null
          reactions: string | null
          scheduled_date: string
          status: string
          updated_at: string | null
          vaccine_name: string
        }
        Insert: {
          administered_date?: string | null
          batch_number?: string | null
          child_id: string
          created_at?: string | null
          doctor_id?: string | null
          dose_number?: number
          id?: string
          notes?: string | null
          reactions?: string | null
          scheduled_date: string
          status?: string
          updated_at?: string | null
          vaccine_name: string
        }
        Update: {
          administered_date?: string | null
          batch_number?: string | null
          child_id?: string
          created_at?: string | null
          doctor_id?: string | null
          dose_number?: number
          id?: string
          notes?: string | null
          reactions?: string | null
          scheduled_date?: string
          status?: string
          updated_at?: string | null
          vaccine_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "vaccinations_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vaccinations_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "doctors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vaccinations_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "v_doctor_performance"
            referencedColumns: ["doctor_id"]
          },
        ]
      }
      video_consultations: {
        Row: {
          appointment_id: string | null
          child_id: string | null
          created_at: string | null
          doctor_id: string
          duration_minutes: number | null
          ended_at: string | null
          family_id: string
          id: string
          notes: string | null
          recording_url: string | null
          room_url: string | null
          scheduled_at: string
          started_at: string | null
          status: string
          updated_at: string | null
        }
        Insert: {
          appointment_id?: string | null
          child_id?: string | null
          created_at?: string | null
          doctor_id: string
          duration_minutes?: number | null
          ended_at?: string | null
          family_id: string
          id?: string
          notes?: string | null
          recording_url?: string | null
          room_url?: string | null
          scheduled_at: string
          started_at?: string | null
          status?: string
          updated_at?: string | null
        }
        Update: {
          appointment_id?: string | null
          child_id?: string | null
          created_at?: string | null
          doctor_id?: string
          duration_minutes?: number | null
          ended_at?: string | null
          family_id?: string
          id?: string
          notes?: string | null
          recording_url?: string | null
          room_url?: string | null
          scheduled_at?: string
          started_at?: string | null
          status?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "video_consultations_appointment_id_fkey"
            columns: ["appointment_id"]
            isOneToOne: false
            referencedRelation: "appointments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "video_consultations_child_id_fkey"
            columns: ["child_id"]
            isOneToOne: false
            referencedRelation: "child_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "video_consultations_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "doctors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "video_consultations_doctor_id_fkey"
            columns: ["doctor_id"]
            isOneToOne: false
            referencedRelation: "v_doctor_performance"
            referencedColumns: ["doctor_id"]
          },
          {
            foreignKeyName: "video_consultations_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
      visit_ratings: {
        Row: {
          appointment_id: string
          comment: string | null
          created_at: string | null
          family_id: string
          id: string
          rating: number
        }
        Insert: {
          appointment_id: string
          comment?: string | null
          created_at?: string | null
          family_id: string
          id?: string
          rating: number
        }
        Update: {
          appointment_id?: string
          comment?: string | null
          created_at?: string | null
          family_id?: string
          id?: string
          rating?: number
        }
        Relationships: [
          {
            foreignKeyName: "visit_ratings_appointment_id_fkey"
            columns: ["appointment_id"]
            isOneToOne: false
            referencedRelation: "appointments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_ratings_family_id_fkey"
            columns: ["family_id"]
            isOneToOne: false
            referencedRelation: "families"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      v_clinic_dashboard: {
        Row: {
          active_families: number | null
          active_journeys: number | null
          clinic_id: string | null
          clinic_name: string | null
          compliance_percent: number | null
          monthly_revenue: number | null
          overdue_events: number | null
          pending_tasks: number | null
        }
        Relationships: []
      }
      v_doctor_performance: {
        Row: {
          avg_rating: number | null
          clinic_id: string | null
          completed_appointments: number | null
          doctor_id: string | null
          doctor_name: string | null
          no_shows: number | null
          specialty: string | null
          total_appointments: number | null
          total_revenue: number | null
        }
        Relationships: [
          {
            foreignKeyName: "doctors_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "clinics"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doctors_clinic_id_fkey"
            columns: ["clinic_id"]
            isOneToOne: false
            referencedRelation: "v_clinic_dashboard"
            referencedColumns: ["clinic_id"]
          },
        ]
      }
    }
    Functions: {
      get_user_clinic_id: { Args: never; Returns: string }
      get_user_role: { Args: never; Returns: string }
      is_family_member: { Args: { family_uuid: string }; Returns: boolean }
      is_staff: { Args: never; Returns: boolean }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const

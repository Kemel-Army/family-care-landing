// Family Care OS — Database Types (mirrors Supabase schema)

export type UserRole = 'mother' | 'father' | 'grandmother' | 'coordinator' | 'gynecologist' | 'pediatrician' | 'clinic_admin' | 'clinic_manager' | 'platform_admin' | 'doctor' | 'nurse' | 'admin' | 'superadmin'

export type JourneyType = 'pregnancy' | 'postpartum' | 'infant' | 'toddler'
export type JourneyStatus = 'active' | 'completed' | 'cancelled'

export type EventStatus = 'upcoming' | 'due' | 'overdue' | 'completed' | 'skipped' | 'cancelled'
export type EventType = 'consultation' | 'screening' | 'analysis' | 'ultrasound' | 'vaccination' | 'checkup' | 'specialist' | 'prescription_start' | 'milestone' | 'custom'

export type AppointmentStatus = 'requested' | 'confirmed' | 'completed' | 'cancelled' | 'no_show' | 'rescheduled'

export type DoseStatus = 'pending' | 'confirmed' | 'missed' | 'skipped'

export type VaccinationStatus = 'scheduled' | 'completed' | 'skipped' | 'postponed'

export type DocumentType = 'analysis' | 'ultrasound' | 'screening' | 'prescription' | 'discharge' | 'certificate' | 'photo' | 'other'

export type TaskPriority = 'critical' | 'high' | 'medium' | 'low'
export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'dismissed'
export type TaskType = 'overdue_followup' | 'missed_appointment' | 'low_adherence' | 'vaccination_reminder' | 'welcome_call' | 'reactivation' | 'ppd_alert' | 'custom'

export type NotificationChannel = 'push' | 'whatsapp' | 'sms' | 'email' | 'in_app'
export type NotificationStatus = 'pending' | 'sent' | 'delivered' | 'read' | 'failed'

export type ConsentType = 'push' | 'whatsapp' | 'sms' | 'email' | 'data_sharing' | 'ai_assistant' | 'telemedicine'

export type MoodScore = 1 | 2 | 3 | 4 | 5
export type EPDSRiskLevel = 'low' | 'moderate' | 'high'

export type FeedingType = 'breast_left' | 'breast_right' | 'formula' | 'solid' | 'mixed'
export type SleepType = 'night' | 'nap'
export type SOSTriageResult = 'emergency' | 'urgent' | 'non_urgent'

// ---- Row types ----

export interface Clinic {
  id: string
  name: string
  slug: string
  logo_url: string | null
  theme_json: Record<string, string>
  settings_json: Record<string, unknown>
  timezone: string
  phone: string | null
  address: string | null
  is_active: boolean
  review_link_2gis: string | null
  review_link_google: string | null
  created_at: string
  updated_at: string
}

export interface User {
  id: string
  email: string
  phone: string | null
  role: UserRole
  clinic_id: string
  first_name: string
  last_name: string
  avatar_url: string | null
  is_active: boolean
  created_at: string
}

export interface Family {
  id: string
  clinic_id: string
  primary_parent_id: string
  secondary_parent_id: string | null
  invite_code: string | null
  status: 'active' | 'inactive' | 'archived'
  created_at: string
}

export interface MotherProfile {
  id: string
  family_id: string
  user_id: string
  lmp_date: string | null
  edd_date: string | null
  blood_type: string | null
  allergies: string[]
  chronic_conditions: string[]
  notes: string | null
}

export interface ChildProfile {
  id: string
  family_id: string
  name: string
  dob: string | null
  gender: 'male' | 'female' | null
  birth_weight: number | null
  birth_height: number | null
  apgar_1min: number | null
  apgar_5min: number | null
  blood_type: string | null
  allergies: string[]
  photo_url: string | null
  is_active: boolean
}

export interface Journey {
  id: string
  family_id: string
  child_id: string | null
  template_id: string | null
  type: JourneyType
  status: JourneyStatus
  started_at: string
  completed_at: string | null
}

export interface JourneyEvent {
  id: string
  journey_id: string
  type: EventType
  title: string
  description: string | null
  trigger_week: number | null
  trigger_day: number | null
  due_date: string | null
  status: EventStatus
  is_mandatory: boolean
  completed_at: string | null
  completed_by: string | null
  notes: string | null
}

export interface JourneyTemplate {
  id: string
  clinic_id: string
  type: JourneyType
  name: string
  description: string | null
  events: JourneyTemplateEvent[]
  is_default: boolean
}

export interface JourneyTemplateEvent {
  type: EventType
  title: string
  description: string | null
  trigger_week?: number
  trigger_day?: number
  is_mandatory: boolean
  specialty?: string
}

export interface Doctor {
  id: string
  clinic_id: string
  user_id: string
  specialty: string
  bio: string | null
  is_active: boolean
}

export interface AppointmentSlot {
  id: string
  doctor_id: string
  date: string
  start_time: string
  end_time: string
  is_available: boolean
}

export interface Appointment {
  id: string
  family_id: string
  child_id: string | null
  doctor_id: string
  journey_event_id: string | null
  slot_id: string | null
  status: AppointmentStatus
  scheduled_at: string
  notes: string | null
  pre_visit_answers: Record<string, unknown> | null
  created_at: string
}

export interface Document {
  id: string
  family_id: string
  child_id: string | null
  type: DocumentType
  title: string
  description: string | null
  file_url: string
  file_type: string
  file_size: number
  tags: string[]
  journey_event_id: string | null
  uploaded_by: string
  created_at: string
}

export interface Prescription {
  id: string
  family_id: string
  child_id: string | null
  medication: string
  dosage: string
  frequency: string
  time_of_day: string[]
  start_date: string
  end_date: string | null
  prescribed_by: string
  is_active: boolean
  notes: string | null
  created_at: string
}

export interface DoseLog {
  id: string
  prescription_id: string
  scheduled_at: string
  status: DoseStatus
  confirmed_at: string | null
}

export interface Vaccination {
  id: string
  child_id: string
  journey_event_id: string | null
  vaccine_name: string
  dose_number: number
  scheduled_date: string
  status: VaccinationStatus
  administered_date: string | null
  batch_number: string | null
  doctor_id: string | null
  reactions: string | null
  notes: string | null
}

export interface CoordinatorTask {
  id: string
  clinic_id: string
  family_id: string
  child_id: string | null
  type: TaskType
  priority: TaskPriority
  status: TaskStatus
  title: string
  description: string | null
  assigned_to: string | null
  due_date: string | null
  completed_at: string | null
  notes: string | null
  created_at: string
}

export interface Notification {
  id: string
  user_id: string
  type: string
  channel: NotificationChannel
  title: string
  body: string
  data: Record<string, unknown> | null
  status: NotificationStatus
  sent_at: string | null
  read_at: string | null
  created_at: string
}

export interface Consent {
  id: string
  user_id: string
  type: ConsentType
  granted: boolean
  granted_at: string | null
  revoked_at: string | null
}

// Extended module types

export interface HealthPassportEntry {
  id: string
  child_id: string
  type: string
  category: string
  date: string
  title: string
  description: string | null
  file_ids: string[]
  doctor_id: string | null
  source: 'parent' | 'doctor' | 'lab' | 'system'
  created_at: string
}

export interface AIConversation {
  id: string
  user_id: string
  child_id: string
  messages: AIMessage[]
  created_at: string
}

export interface AIMessage {
  role: 'user' | 'assistant'
  content: string
  timestamp: string
}

export interface MoodLog {
  id: string
  user_id: string
  date: string
  score: MoodScore
  notes: string | null
}

export interface EPDSScreening {
  id: string
  user_id: string
  date: string
  answers: number[]
  total_score: number
  risk_level: EPDSRiskLevel
}

export interface GrowthMetric {
  id: string
  child_id: string
  date: string
  weight_kg: number | null
  height_cm: number | null
  head_circumference_cm: number | null
  measured_by: string | null
}

export interface Milestone {
  id: string
  child_id: string
  type: string
  title: string
  expected_age_months: number | null
  achieved_at: string | null
  notes: string | null
  photo_url: string | null
}

export interface FeedingLog {
  id: string
  child_id: string
  type: FeedingType
  details: Record<string, unknown>
  timestamp: string
}

export interface FoodIntroduction {
  id: string
  child_id: string
  food: string
  introduced_at: string
  reaction: string | null
  status: 'safe' | 'reaction' | 'pending'
}

export interface SleepLog {
  id: string
  child_id: string
  date: string
  sleep_start: string
  sleep_end: string
  type: SleepType
  wake_ups: number
  notes: string | null
}

export interface SOSEvent {
  id: string
  family_id: string
  child_id: string | null
  category: string
  triage_result: SOSTriageResult
  actions_taken: string | null
  resolved_at: string | null
  created_at: string
}

export interface EducationContent {
  id: string
  clinic_id: string | null
  type: 'article' | 'checklist' | 'video' | 'infographic'
  target_week_or_age: number | null
  target_journey_type: JourneyType | null
  title: string
  body: string
  media_url: string | null
  is_published: boolean
  created_at: string
}

export interface Achievement {
  id: string
  name: string
  description: string
  icon: string
  criteria: Record<string, unknown>
}

export interface UserAchievement {
  id: string
  user_id: string
  achievement_id: string
  earned_at: string
}

export interface Streak {
  id: string
  user_id: string
  type: string
  current_count: number
  longest_count: number
  last_date: string
}

export interface Referral {
  id: string
  referrer_family_id: string
  referred_family_id: string | null
  code: string
  status: 'pending' | 'registered' | 'rewarded'
  reward: string | null
  created_at: string
}

// Clinic B2B types

export interface ServicePackage {
  id: string
  clinic_id: string
  name: string
  description: string | null
  services: Record<string, unknown>[]
  price: number
  duration_months: number
  is_active: boolean
}

export interface FamilyPackage {
  id: string
  family_id: string
  package_id: string
  purchased_at: string
  expires_at: string
  usage: Record<string, unknown>
}

export interface OutreachScenario {
  id: string
  clinic_id: string
  name: string
  trigger: Record<string, unknown>
  actions: Record<string, unknown>[]
  is_active: boolean
}

export interface TrainingModule {
  id: string
  clinic_id: string
  role: UserRole
  title: string
  content: string
  test: Record<string, unknown>[]
  order: number
}

export interface Integration {
  id: string
  clinic_id: string
  provider: string
  type: 'mis' | '1c' | 'lab' | 'sms' | 'whatsapp' | 'calendar' | 'custom'
  config_encrypted: string | null
  sync_status: 'inactive' | 'active' | 'error' | 'syncing'
  last_sync_at: string | null
  created_at: string
  updated_at: string
}

// Migration 009 additional types

export interface OutreachLog {
  id: string
  scenario_id: string
  family_id: string
  status: 'pending' | 'sent' | 'delivered' | 'opened' | 'converted' | 'failed'
  result: string | null
  sent_at: string | null
  created_at: string
}

export interface ReviewRequest {
  id: string
  family_id: string
  event_type: string | null
  nps_score: number | null
  review_url: string | null
  status: 'pending' | 'sent' | 'completed' | 'skipped'
  created_at: string
}

export interface TrainingProgress {
  id: string
  user_id: string
  module_id: string
  completed_at: string | null
  score: number | null
  attempts: number
  created_at: string
}

export interface ClinicNetwork {
  id: string
  name: string
  created_at: string
}

export interface ClinicNetworkMember {
  network_id: string
  clinic_id: string
  joined_at: string
}

export interface SyncLog {
  id: string
  integration_id: string
  direction: 'inbound' | 'outbound'
  entity: string
  records_processed: number
  records_failed: number
  error_log: string | null
  created_at: string
}

export interface RevenueForecast {
  id: string
  clinic_id: string
  month: string
  predicted_revenue: number
  actual_revenue: number | null
  model_version: string | null
  created_at: string
}

export interface NpsResponse {
  id: string
  family_id: string
  score: number
  event_type: string | null
  comment: string | null
  created_at: string
}

// Migration 011 types

export interface Webhook {
  id: string
  clinic_id: string
  event: string
  url: string
  is_active: boolean
  created_at: string
}

export interface DemoRequest {
  id: string
  name: string
  contact: string
  clinic_name: string | null
  email: string | null
  phone: string | null
  families_count: string | null
  source: string | null
  status: 'new' | 'contacted' | 'demo_scheduled' | 'converted' | 'rejected'
  notes: string | null
  created_at: string
}

// Migration 012 types

export interface PushToken {
  id: string
  user_id: string
  token: string
  platform: 'ios' | 'android' | 'web'
  is_active: boolean
  created_at: string
  updated_at: string
}

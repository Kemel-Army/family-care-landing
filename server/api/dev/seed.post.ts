// Dev seed endpoint — populates Supabase with realistic test data
// POST /api/dev/seed
// Only available in development mode
// Creates: 1 clinic, 39 users (1 admin + 3 coordinators + 5 doctors + 30 mothers),
//          30 families, 12 children, 30 journeys, ~150 events, ~30 prescriptions,
//          ~200 dose logs, ~20 appointments, ~10 tasks, ~30 vaccinations

import { createClient } from '@supabase/supabase-js'

// ─── Constants ───────────────────────────────────────────────────────────────
const SLUG = 'demo-mat-i-ditya'
const PWD = 'DemoPass123!'

// ─── Date helpers ────────────────────────────────────────────────────────────
function dateOffset(days: number): string {
  const d = new Date()
  d.setDate(d.getDate() + days)
  return d.toISOString().split('T')[0]
}

function tsOffset(days: number): string {
  return new Date(Date.now() + days * 86_400_000).toISOString()
}

function todayStr(): string { return dateOffset(0) }

// ─── Staff ───────────────────────────────────────────────────────────────────
const STAFF = [
  { first_name: 'Админ', last_name: 'Демо', email: 'admin@demo.kz', role: 'admin' as const },
  { first_name: 'Динара', last_name: 'Сатыбалдиева', email: 'dinara@demo.kz', role: 'coordinator' as const },
  { first_name: 'Айнур', last_name: 'Карабаева', email: 'ainur@demo.kz', role: 'coordinator' as const },
  { first_name: 'Жанна', last_name: 'Толеуова', email: 'zhanna@demo.kz', role: 'coordinator' as const },
  { first_name: 'Алия', last_name: 'Кенесова', email: 'aliya@demo.kz', role: 'doctor' as const },
  { first_name: 'Марат', last_name: 'Нурланов', email: 'marat@demo.kz', role: 'doctor' as const },
  { first_name: 'Гульнар', last_name: 'Байтурсынова', email: 'gulnar@demo.kz', role: 'doctor' as const },
  { first_name: 'Серик', last_name: 'Оразов', email: 'serik@demo.kz', role: 'doctor' as const },
  { first_name: 'Дана', last_name: 'Муканова', email: 'dana@demo.kz', role: 'doctor' as const },
]

const DOC_SPECS = [
  { email: 'aliya@demo.kz', specialty: 'gynecologist', experience_years: 12, consultation_fee: 15000 },
  { email: 'marat@demo.kz', specialty: 'pediatrician', experience_years: 8, consultation_fee: 12000 },
  { email: 'gulnar@demo.kz', specialty: 'neonatologist', experience_years: 15, consultation_fee: 18000 },
  { email: 'serik@demo.kz', specialty: 'ultrasound', experience_years: 10, consultation_fee: 10000 },
  { email: 'dana@demo.kz', specialty: 'lab', experience_years: 6, consultation_fee: 8000 },
]

// ─── 30 Mothers ──────────────────────────────────────────────────────────────
interface MotherDef {
  first_name: string; last_name: string; email: string
  stage: 'pregnancy' | 'postpartum' | 'infant' | 'toddler'
  week?: number; monthAge?: number
  persona?: string; adherenceRate?: number
}

const MOTHERS: MotherDef[] = [
  // 3 Key Personas
  { first_name: 'Айгерим', last_name: 'Каримова', email: 'p1@demo.kz', stage: 'pregnancy', week: 24, persona: 'problematic', adherenceRate: 0.45 },
  { first_name: 'Сауле', last_name: 'Нурланова', email: 'p2@demo.kz', stage: 'infant', monthAge: 6, persona: 'ideal', adherenceRate: 0.98 },
  { first_name: 'Камила', last_name: 'Жумабаева', email: 'p3@demo.kz', stage: 'pregnancy', week: 8, persona: 'new', adherenceRate: 0 },
  // Early Pregnancy (7)
  { first_name: 'Гулназ', last_name: 'Садыкова', email: 'm04@demo.kz', stage: 'pregnancy', week: 4 },
  { first_name: 'Айдана', last_name: 'Калиева', email: 'm05@demo.kz', stage: 'pregnancy', week: 5 },
  { first_name: 'Лаура', last_name: 'Серикова', email: 'm06@demo.kz', stage: 'pregnancy', week: 6 },
  { first_name: 'Молдир', last_name: 'Нурпеисова', email: 'm07@demo.kz', stage: 'pregnancy', week: 6 },
  { first_name: 'Сабина', last_name: 'Рустемова', email: 'm08@demo.kz', stage: 'pregnancy', week: 7 },
  { first_name: 'Фариза', last_name: 'Кожахметова', email: 'm09@demo.kz', stage: 'pregnancy', week: 7 },
  { first_name: 'Арайлым', last_name: 'Бейсекова', email: 'm10@demo.kz', stage: 'pregnancy', week: 5 },
  // Active Pregnancy (9)
  { first_name: 'Дана', last_name: 'Алиева', email: 'm11@demo.kz', stage: 'pregnancy', week: 12 },
  { first_name: 'Асель', last_name: 'Бекболатова', email: 'm12@demo.kz', stage: 'pregnancy', week: 14 },
  { first_name: 'Мадина', last_name: 'Сулейменова', email: 'm13@demo.kz', stage: 'pregnancy', week: 16 },
  { first_name: 'Маржан', last_name: 'Дюсенова', email: 'm14@demo.kz', stage: 'pregnancy', week: 18 },
  { first_name: 'Балжан', last_name: 'Карабаева', email: 'm15@demo.kz', stage: 'pregnancy', week: 20 },
  { first_name: 'Жанар', last_name: 'Оразова', email: 'm16@demo.kz', stage: 'pregnancy', week: 26 },
  { first_name: 'Томирис', last_name: 'Муканова', email: 'm17@demo.kz', stage: 'pregnancy', week: 30 },
  { first_name: 'Инжу', last_name: 'Сатыбалдиева', email: 'm18@demo.kz', stage: 'pregnancy', week: 34 },
  { first_name: 'Асем', last_name: 'Нуртасова', email: 'm19@demo.kz', stage: 'pregnancy', week: 38 },
  // Postpartum (5)
  { first_name: 'Назгуль', last_name: 'Жаксылыкова', email: 'm20@demo.kz', stage: 'postpartum', monthAge: 1 },
  { first_name: 'Айжан', last_name: 'Ермекова', email: 'm21@demo.kz', stage: 'postpartum', monthAge: 2 },
  { first_name: 'Карлыгаш', last_name: 'Байтурсынова', email: 'm22@demo.kz', stage: 'postpartum', monthAge: 1 },
  { first_name: 'Алтынай', last_name: 'Нуржанова', email: 'm23@demo.kz', stage: 'postpartum', monthAge: 3 },
  { first_name: 'Жансая', last_name: 'Абылкасымова', email: 'm24@demo.kz', stage: 'postpartum', monthAge: 2 },
  // Infant (3, + Сауле = 4)
  { first_name: 'Нургуль', last_name: 'Жетписбаева', email: 'm25@demo.kz', stage: 'infant', monthAge: 4 },
  { first_name: 'Раушан', last_name: 'Тлеуова', email: 'm26@demo.kz', stage: 'infant', monthAge: 9 },
  { first_name: 'Сания', last_name: 'Кусаинова', email: 'm27@demo.kz', stage: 'infant', monthAge: 11 },
  // Toddler (3)
  { first_name: 'Бибигуль', last_name: 'Медеуова', email: 'm28@demo.kz', stage: 'toddler', monthAge: 14 },
  { first_name: 'Гулмира', last_name: 'Утеева', email: 'm29@demo.kz', stage: 'toddler', monthAge: 18 },
  { first_name: 'Ляззат', last_name: 'Рахимова', email: 'm30@demo.kz', stage: 'toddler', monthAge: 22 },
]

// ─── Child names ─────────────────────────────────────────────────────────────
const CHILD_NAMES = [
  { name: 'Алихан', gender: 'male' as const },
  { name: 'Аяулым', gender: 'female' as const },
  { name: 'Тамерлан', gender: 'male' as const },
  { name: 'Медина', gender: 'female' as const },
  { name: 'Нурсултан', gender: 'male' as const },
  { name: 'Айару', gender: 'female' as const },
  { name: 'Адилет', gender: 'male' as const },
  { name: 'Нурай', gender: 'female' as const },
  { name: 'Даулет', gender: 'male' as const },
  { name: 'Жасмин', gender: 'female' as const },
  { name: 'Алдияр', gender: 'male' as const },
  { name: 'Амина', gender: 'female' as const },
]

// ─── Event templates ─────────────────────────────────────────────────────────
const PREG_EVENTS = [
  { type: 'consultation', title: 'Постановка на учёт', tw: 6 },
  { type: 'analysis', title: 'ОАК, группа крови, RW, ВИЧ, гепатиты', tw: 8 },
  { type: 'ultrasound', title: 'УЗИ I триместр', tw: 12 },
  { type: 'screening', title: 'Скрининг I триместра (PAPP-A, β-ХГЧ)', tw: 12 },
  { type: 'consultation', title: 'Осмотр гинеколога (II триместр)', tw: 16 },
  { type: 'ultrasound', title: 'УЗИ II триместр (анатомия)', tw: 20 },
  { type: 'analysis', title: 'Глюкозотолерантный тест', tw: 26 },
  { type: 'analysis', title: 'ОАК, коагулограмма (III триместр)', tw: 30 },
  { type: 'ultrasound', title: 'УЗИ III триместр', tw: 32 },
  { type: 'consultation', title: 'Предродовая подготовка', tw: 36 },
]

const PP_EVENTS = [
  { type: 'screening', title: 'Неонатальный скрининг', td: 4 },
  { type: 'consultation', title: 'Первый осмотр новорождённого', td: 7 },
  { type: 'consultation', title: 'Послеродовой осмотр мамы', td: 14 },
  { type: 'analysis', title: 'ОАК мамы (послеродовой)', td: 30 },
  { type: 'checkup', title: 'Осмотр педиатра (1 мес)', td: 30 },
]

const INF_EVENTS = [
  { type: 'vaccination', title: 'АКДС-HepB-Hib (1), ИПВ (1), PCV13 (1)', td: 60 },
  { type: 'checkup', title: 'Осмотр педиатра (2 мес)', td: 60 },
  { type: 'vaccination', title: 'АКДС-HepB-Hib (2), ИПВ (2)', td: 90 },
  { type: 'checkup', title: 'Осмотр педиатра (3 мес)', td: 90 },
  { type: 'vaccination', title: 'АКДС-HepB-Hib (3), ИПВ (3), PCV13 (2)', td: 120 },
  { type: 'checkup', title: 'Осмотр педиатра (6 мес)', td: 180 },
  { type: 'analysis', title: 'ОАК (6 мес)', td: 180 },
  { type: 'checkup', title: 'Осмотр педиатра (9 мес)', td: 270 },
  { type: 'vaccination', title: 'КПК, PCV13 (3)', td: 365 },
  { type: 'checkup', title: 'Осмотр педиатра (12 мес)', td: 365 },
]

const TOD_EVENTS = [
  { type: 'checkup', title: 'Осмотр педиатра (15 мес)', td: 450 },
  { type: 'vaccination', title: 'АКДС (4) + ОПВ (4)', td: 540 },
  { type: 'checkup', title: 'Осмотр педиатра (18 мес)', td: 540 },
  { type: 'checkup', title: 'Осмотр педиатра (24 мес)', td: 730 },
  { type: 'analysis', title: 'Оценка речи и моторики', td: 730 },
]

const EVENT_MAP: Record<string, { type: string; title: string; tw?: number; td?: number }[]> = {
  pregnancy: PREG_EVENTS,
  postpartum: PP_EVENTS,
  infant: INF_EVENTS,
  toddler: TOD_EVENTS,
}

// ─── Vaccination schedule (Kazakhstan national calendar) ─────────────────────
const VAX_SCHEDULE = [
  { name: 'BCG', dose: 1, day: 1 },
  { name: 'HepB', dose: 1, day: 1 },
  { name: 'HepB', dose: 2, day: 60 },
  { name: 'АКДС-HepB-Hib', dose: 1, day: 60 },
  { name: 'ИПВ', dose: 1, day: 60 },
  { name: 'PCV13', dose: 1, day: 60 },
  { name: 'АКДС-HepB-Hib', dose: 2, day: 90 },
  { name: 'ИПВ', dose: 2, day: 90 },
  { name: 'АКДС-HepB-Hib', dose: 3, day: 120 },
  { name: 'ИПВ', dose: 3, day: 120 },
  { name: 'PCV13', dose: 2, day: 120 },
  { name: 'КПК', dose: 1, day: 365 },
  { name: 'PCV13', dose: 3, day: 365 },
  { name: 'АКДС', dose: 4, day: 540 },
  { name: 'ОПВ', dose: 4, day: 540 },
]

// ─── Generation helpers ──────────────────────────────────────────────────────
function makeEvents(
  journeyId: string,
  stage: string,
  startDate: string,
  _progressDays: number,
  completionRate: number,
): Record<string, unknown>[] {
  const template = EVENT_MAP[stage] || []
  const todayMs = new Date(todayStr()).getTime()

  return template.map(evt => {
    const triggerDays = evt.tw ? evt.tw * 7 : evt.td!
    const dueMs = new Date(startDate).getTime() + triggerDays * 86_400_000
    const dueDateStr = new Date(dueMs).toISOString().split('T')[0]

    let status: string
    if (dueMs < todayMs - 7 * 86_400_000) {
      status = Math.random() < completionRate ? 'completed' : 'overdue'
    } else if (dueMs <= todayMs) {
      status = Math.random() < completionRate ? 'completed' : 'due'
    } else {
      status = 'upcoming'
    }

    return {
      journey_id: journeyId,
      type: evt.type,
      title: evt.title,
      trigger_week: evt.tw ?? null,
      trigger_day: evt.td ?? null,
      due_date: dueDateStr,
      status,
      is_mandatory: true,
      completed_at: status === 'completed'
        ? new Date(dueMs + Math.random() * 2 * 86_400_000).toISOString()
        : null,
    }
  })
}

function makeVaccinations(
  childId: string,
  dobStr: string,
  childAgeDays: number,
  doctorId: string,
): Record<string, unknown>[] {
  return VAX_SCHEDULE
    .filter(v => v.day <= childAgeDays + 30)
    .map(v => {
      const schedDate = new Date(new Date(dobStr).getTime() + v.day * 86_400_000)
      const schedStr = schedDate.toISOString().split('T')[0]
      const completed = v.day < childAgeDays - 7
      return {
        child_id: childId,
        vaccine_name: v.name,
        dose_number: v.dose,
        scheduled_date: schedStr,
        status: completed ? 'completed' : 'scheduled',
        administered_date: completed
          ? new Date(schedDate.getTime() + Math.floor(Math.random() * 3) * 86_400_000).toISOString().split('T')[0]
          : null,
        doctor_id: doctorId,
      }
    })
}

// ═════════════════════════════════════════════════════════════════════════════
// MAIN HANDLER
// ═════════════════════════════════════════════════════════════════════════════
export default defineEventHandler(async (event) => {
  if (process.env.NODE_ENV === 'production') {
    throw createError({ statusCode: 403, message: 'Seed endpoint is disabled in production' })
  }

  const config = useRuntimeConfig()
  const url = process.env.SUPABASE_URL
  const key = config.supabaseServiceKey

  if (!url || !key) {
    throw createError({ statusCode: 500, message: 'Supabase not configured — set SUPABASE_URL and supabaseServiceKey' })
  }

  const sb = createClient(url, key as string, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const log: string[] = []

  // ─── CLEANUP ─────────────────────────────────────────────────────────────
  const { data: existing } = await sb.from('clinics').select('id').eq('slug', SLUG).maybeSingle()
  if (existing) {
    log.push('Cleaning up previous seed data…')
    const cid = existing.id

    const [{ data: fams }, { data: usrs }] = await Promise.all([
      sb.from('families').select('id').eq('clinic_id', cid),
      sb.from('users').select('id').eq('clinic_id', cid),
    ])
    const fIds = fams?.map(r => r.id) || []
    const uIds = usrs?.map(r => r.id) || []

    if (fIds.length) {
      const [{ data: jRows }, { data: cRows }] = await Promise.all([
        sb.from('journeys').select('id').in('family_id', fIds),
        sb.from('child_profiles').select('id').in('family_id', fIds),
      ])
      const jIds = jRows?.map(r => r.id) || []
      const cIds = cRows?.map(r => r.id) || []

      // Leaf tables
      await Promise.all([
        fIds.length ? sb.from('dose_logs').delete().in('family_id', fIds) : null,
        fIds.length ? sb.from('visit_ratings').delete().in('family_id', fIds) : null,
        fIds.length ? sb.from('documents').delete().in('family_id', fIds) : null,
        jIds.length ? sb.from('journey_events').delete().in('journey_id', jIds) : null,
        cIds.length ? sb.from('vaccinations').delete().in('child_id', cIds) : null,
      ].filter(Boolean))

      // Depends on leaf tables being gone
      await Promise.all([
        sb.from('appointments').delete().in('family_id', fIds),
        sb.from('prescriptions').delete().in('family_id', fIds),
      ])

      // Mid-level
      await sb.from('journeys').delete().in('family_id', fIds)
      await Promise.all([
        sb.from('child_profiles').delete().in('family_id', fIds),
        sb.from('mother_profiles').delete().in('family_id', fIds),
      ])
      await sb.from('families').delete().eq('clinic_id', cid)
    }

    // Clinic-level
    await Promise.all([
      sb.from('coordinator_tasks').delete().eq('clinic_id', cid),
      sb.from('doctors').delete().eq('clinic_id', cid),
    ])

    if (uIds.length) {
      await Promise.all([
        sb.from('notifications').delete().in('user_id', uIds),
        sb.from('consents').delete().in('user_id', uIds),
      ])
      await sb.from('users').delete().eq('clinic_id', cid)
      for (let i = 0; i < uIds.length; i += 10) {
        await Promise.all(uIds.slice(i, i + 10).map(id => sb.auth.admin.deleteUser(id)))
      }
    }

    await sb.from('clinics').delete().eq('id', cid)
    log.push('Cleanup complete')
  }

  // ─── 1. CREATE CLINIC ────────────────────────────────────────────────────
  const { data: clinic, error: clinicErr } = await sb.from('clinics').insert({
    name: 'Клиника «Мать и Дитя»',
    slug: SLUG,
    phone: '+7 727 123 45 67',
    address: 'г. Алматы, ул. Абая 150',
    timezone: 'Asia/Almaty',
    theme_json: { primaryColor: '#2D7A5F', secondaryColor: '#E8708A', accentColor: '#E8B84D' },
    settings_json: { language: 'ru', features: { ai: true, telemedicine: true, mood_tracking: true } },
  }).select().single()

  if (clinicErr || !clinic) throw createError({ statusCode: 500, message: `Clinic: ${clinicErr?.message}` })
  log.push(`✓ Clinic: ${clinic.id}`)

  // ─── 2. CREATE AUTH USERS ────────────────────────────────────────────────
  const allUserDefs = [
    ...STAFF,
    ...MOTHERS.map(m => ({ first_name: m.first_name, last_name: m.last_name, email: m.email, role: 'mother' as const })),
  ]

  const userMap = new Map<string, string>() // email → user ID

  for (let i = 0; i < allUserDefs.length; i += 5) {
    const batch = allUserDefs.slice(i, i + 5)
    const results = await Promise.all(
      batch.map(u => sb.auth.admin.createUser({
        email: u.email,
        password: PWD,
        email_confirm: true,
        user_metadata: { first_name: u.first_name, last_name: u.last_name },
      })),
    )
    for (let j = 0; j < results.length; j++) {
      const { data, error } = results[j]
      if (error || !data?.user) throw createError({ statusCode: 500, message: `Auth ${batch[j].email}: ${error?.message}` })
      userMap.set(batch[j].email, data.user.id)
    }
  }
  log.push(`✓ Auth users: ${userMap.size}`)

  // ─── 3. INSERT USER PROFILES ─────────────────────────────────────────────
  const { error: usersErr } = await sb.from('users').insert(
    allUserDefs.map(u => ({
      id: userMap.get(u.email)!,
      email: u.email,
      role: u.role,
      clinic_id: clinic.id,
      first_name: u.first_name,
      last_name: u.last_name,
      is_active: true,
      last_seen_at: tsOffset(-Math.floor(Math.random() * 7)),
    })),
  )
  if (usersErr) throw createError({ statusCode: 500, message: `Users: ${usersErr.message}` })
  log.push(`✓ User profiles: ${allUserDefs.length}`)

  // ─── 4. CREATE DOCTOR RECORDS ────────────────────────────────────────────
  const { data: doctors, error: docErr } = await sb.from('doctors').insert(
    DOC_SPECS.map(d => ({
      clinic_id: clinic.id,
      user_id: userMap.get(d.email)!,
      specialty: d.specialty,
      experience_years: d.experience_years,
      consultation_fee: d.consultation_fee,
      is_active: true,
    })),
  ).select()
  if (docErr || !doctors) throw createError({ statusCode: 500, message: `Doctors: ${docErr?.message}` })

  const docMap = new Map<string, string>()
  DOC_SPECS.forEach((d, i) => docMap.set(d.email, doctors[i].id))
  log.push(`✓ Doctors: ${doctors.length}`)

  // ─── 5. CREATE FAMILIES ──────────────────────────────────────────────────
  const { data: families, error: famErr } = await sb.from('families').insert(
    MOTHERS.map(m => ({
      clinic_id: clinic.id,
      primary_parent_id: userMap.get(m.email)!,
      status: 'active' as const,
    })),
  ).select()
  if (famErr || !families) throw createError({ statusCode: 500, message: `Families: ${famErr?.message}` })
  log.push(`✓ Families: ${families.length}`)

  // ─── 6. CREATE MOTHER PROFILES ───────────────────────────────────────────
  const { error: mpErr } = await sb.from('mother_profiles').insert(
    MOTHERS.map((m, i) => {
      const rec: Record<string, unknown> = {
        family_id: families[i].id,
        user_id: userMap.get(m.email)!,
      }
      if (m.stage === 'pregnancy' && m.week) {
        rec.lmp_date = dateOffset(-m.week * 7)
        rec.edd_date = dateOffset((40 - m.week) * 7)
      }
      return rec
    }),
  )
  if (mpErr) throw createError({ statusCode: 500, message: `Mother profiles: ${mpErr.message}` })
  log.push('✓ Mother profiles')

  // ─── 7. CREATE CHILD PROFILES (post-birth families) ──────────────────────
  const postBirthIndices = MOTHERS
    .map((m, i) => (m.stage !== 'pregnancy' ? i : -1))
    .filter(i => i >= 0)

  const { data: children, error: childErr } = await sb.from('child_profiles').insert(
    postBirthIndices.map((mi, ci) => ({
      family_id: families[mi].id,
      name: CHILD_NAMES[ci % CHILD_NAMES.length].name,
      gender: CHILD_NAMES[ci % CHILD_NAMES.length].gender,
      dob: dateOffset(-MOTHERS[mi].monthAge! * 30),
      birth_weight: +(2.8 + Math.random() * 1.5).toFixed(2),
      birth_height: +(48 + Math.random() * 6).toFixed(2),
      apgar_1min: 7 + Math.floor(Math.random() * 3),
      apgar_5min: 8 + Math.floor(Math.random() * 2),
    })),
  ).select()
  if (childErr || !children) throw createError({ statusCode: 500, message: `Children: ${childErr?.message}` })

  const motherToChild = new Map<number, { id: string; dob: string }>()
  postBirthIndices.forEach((mi, ci) => {
    motherToChild.set(mi, { id: children[ci].id, dob: children[ci].dob })
  })
  log.push(`✓ Children: ${children.length}`)

  // ─── 8. CREATE JOURNEYS ──────────────────────────────────────────────────
  const { data: journeys, error: jErr } = await sb.from('journeys').insert(
    MOTHERS.map((m, i) => {
      const rec: Record<string, unknown> = {
        family_id: families[i].id,
        type: m.stage,
        status: 'active',
        started_at: m.stage === 'pregnancy'
          ? tsOffset(-m.week! * 7)
          : tsOffset(-m.monthAge! * 30),
      }
      const child = motherToChild.get(i)
      if (child) rec.child_id = child.id
      return rec
    }),
  ).select()
  if (jErr || !journeys) throw createError({ statusCode: 500, message: `Journeys: ${jErr?.message}` })
  log.push(`✓ Journeys: ${journeys.length}`)

  // ─── 9. CREATE JOURNEY EVENTS ────────────────────────────────────────────
  const allEvents: Record<string, unknown>[] = []

  MOTHERS.forEach((m, i) => {
    const startDate = m.stage === 'pregnancy'
      ? dateOffset(-m.week! * 7)
      : dateOffset(-m.monthAge! * 30)

    const progressDays = m.stage === 'pregnancy'
      ? m.week! * 7
      : m.monthAge! * 30

    const rate = m.adherenceRate ?? (0.6 + Math.random() * 0.35)
    allEvents.push(...makeEvents(journeys[i].id, m.stage, startDate, progressDays, rate))
  })

  const { error: evErr } = await sb.from('journey_events').insert(allEvents)
  if (evErr) throw createError({ statusCode: 500, message: `Events: ${evErr.message}` })
  log.push(`✓ Journey events: ${allEvents.length}`)

  // ─── 10. CREATE PRESCRIPTIONS ────────────────────────────────────────────
  const gynId = userMap.get('aliya@demo.kz')!
  const pedId = userMap.get('marat@demo.kz')!

  const prescInserts: Record<string, unknown>[] = []

  MOTHERS.forEach((m, i) => {
    if (m.stage === 'pregnancy' && m.week! >= 6) {
      prescInserts.push({
        family_id: families[i].id,
        child_id: null,
        medication: 'Фолиевая кислота',
        dosage: '400 мкг',
        frequency: 'Раз в день',
        time_of_day: ['morning'],
        start_date: dateOffset(-m.week! * 7 + 6 * 7),
        instructions: 'Принимать утром после еды',
        is_active: true,
        prescribed_by: gynId,
      })
    }

    const childRec = motherToChild.get(i)
    if (childRec) {
      prescInserts.push({
        family_id: families[i].id,
        child_id: childRec.id,
        medication: 'Витамин D3',
        dosage: '500 МЕ',
        frequency: 'Раз в день',
        time_of_day: ['morning'],
        start_date: childRec.dob,
        instructions: 'Давать ребёнку утром, 1 капля',
        is_active: true,
        prescribed_by: pedId,
      })
    }
  })

  const { data: prescriptions, error: prescErr } = await sb.from('prescriptions').insert(prescInserts).select()
  if (prescErr || !prescriptions) throw createError({ statusCode: 500, message: `Prescriptions: ${prescErr?.message}` })
  log.push(`✓ Prescriptions: ${prescriptions.length}`)

  // ─── 11. CREATE DOSE LOGS (14 days per prescription) ─────────────────────
  const doseLogs: Record<string, unknown>[] = []

  prescriptions.forEach(p => {
    const mi = families.findIndex(f => f.id === p.family_id)
    const adherence = MOTHERS[mi]?.adherenceRate ?? (0.6 + Math.random() * 0.35)

    for (let day = 13; day >= 0; day--) {
      const schedMs = Date.now() - day * 86_400_000
      const sched = new Date(schedMs)
      sched.setHours(8, 0, 0, 0)

      const taken = Math.random() < adherence
      const status = day === 0 ? 'pending' : (taken ? 'confirmed' : 'missed')

      doseLogs.push({
        prescription_id: p.id,
        family_id: p.family_id,
        scheduled_at: sched.toISOString(),
        status,
        confirmed_at: status === 'confirmed'
          ? new Date(sched.getTime() + Math.floor(Math.random() * 3_600_000)).toISOString()
          : null,
      })
    }
  })

  for (let i = 0; i < doseLogs.length; i += 500) {
    const chunk = doseLogs.slice(i, i + 500)
    const { error: dlErr } = await sb.from('dose_logs').insert(chunk)
    if (dlErr) throw createError({ statusCode: 500, message: `Dose logs chunk ${i}: ${dlErr.message}` })
  }
  log.push(`✓ Dose logs: ${doseLogs.length}`)

  // ─── 12. CREATE APPOINTMENTS ─────────────────────────────────────────────
  const gynDocId = docMap.get('aliya@demo.kz')!
  const pedDocId = docMap.get('marat@demo.kz')!
  const uziDocId = docMap.get('serik@demo.kz')!

  const appts: Record<string, unknown>[] = [
    // Today's appointments (6)
    { family_id: families[0].id, doctor_id: uziDocId, appointment_date: todayStr(), start_time: '09:00', end_time: '09:30', status: 'confirmed', reason: 'Плановое УЗИ (24 нед)', visit_type: 'in_person' },
    { family_id: families[13].id, doctor_id: gynDocId, appointment_date: todayStr(), start_time: '10:00', end_time: '10:30', status: 'confirmed', reason: 'Осмотр гинеколога (18 нед)', visit_type: 'in_person' },
    { family_id: families[1].id, doctor_id: pedDocId, child_id: motherToChild.get(1)?.id, appointment_date: todayStr(), start_time: '10:30', end_time: '11:00', status: 'confirmed', reason: 'Осмотр педиатра (6 мес)', visit_type: 'in_person' },
    { family_id: families[24].id, doctor_id: pedDocId, child_id: motherToChild.get(24)?.id, appointment_date: todayStr(), start_time: '11:30', end_time: '12:00', status: 'confirmed', reason: 'Вакцинация АКДС-HepB-Hib (1)', visit_type: 'in_person' },
    { family_id: families[26].id, doctor_id: pedDocId, child_id: motherToChild.get(26)?.id, appointment_date: todayStr(), start_time: '14:00', end_time: '14:30', status: 'confirmed', reason: 'Осмотр педиатра (11 мес)', visit_type: 'in_person' },
    { family_id: families[27].id, doctor_id: pedDocId, child_id: motherToChild.get(27)?.id, appointment_date: todayStr(), start_time: '15:00', end_time: '15:30', status: 'confirmed', reason: 'Осмотр педиатра (14 мес)', visit_type: 'in_person' },
    // Past appointments
    { family_id: families[0].id, doctor_id: gynDocId, appointment_date: dateOffset(-14), start_time: '09:00', end_time: '09:30', status: 'completed', reason: 'Осмотр гинеколога', visit_type: 'in_person' },
    { family_id: families[0].id, doctor_id: gynDocId, appointment_date: dateOffset(-3), start_time: '09:00', end_time: '09:30', status: 'no_show', reason: 'Плановый осмотр (пропущен)', visit_type: 'in_person' },
    { family_id: families[1].id, doctor_id: pedDocId, child_id: motherToChild.get(1)?.id, appointment_date: dateOffset(-30), start_time: '10:00', end_time: '10:30', status: 'completed', reason: 'Осмотр педиатра (4 мес)', visit_type: 'in_person' },
    { family_id: families[10].id, doctor_id: gynDocId, appointment_date: dateOffset(-7), start_time: '11:00', end_time: '11:30', status: 'completed', reason: 'УЗИ I триместр', visit_type: 'in_person' },
    { family_id: families[14].id, doctor_id: uziDocId, appointment_date: dateOffset(-5), start_time: '12:00', end_time: '12:30', status: 'completed', reason: 'УЗИ II триместр', visit_type: 'in_person' },
    { family_id: families[16].id, doctor_id: gynDocId, appointment_date: dateOffset(-10), start_time: '14:00', end_time: '14:30', status: 'completed', reason: 'Осмотр III триместр', visit_type: 'in_person' },
    { family_id: families[25].id, doctor_id: pedDocId, child_id: motherToChild.get(25)?.id, appointment_date: dateOffset(-14), start_time: '10:30', end_time: '11:00', status: 'completed', reason: 'Осмотр педиатра (8 мес)', visit_type: 'in_person' },
    { family_id: families[13].id, doctor_id: gynDocId, appointment_date: dateOffset(-2), start_time: '09:30', end_time: '10:00', status: 'no_show', reason: 'Консультация гинеколога (неявка)', visit_type: 'in_person' },
    { family_id: families[28].id, doctor_id: pedDocId, child_id: motherToChild.get(28)?.id, appointment_date: dateOffset(-21), start_time: '15:00', end_time: '15:30', status: 'completed', reason: 'Ревакцинация АКДС (4)', visit_type: 'in_person' },
    { family_id: families[29].id, doctor_id: pedDocId, child_id: motherToChild.get(29)?.id, appointment_date: dateOffset(-60), start_time: '11:00', end_time: '11:30', status: 'completed', reason: 'Осмотр педиатра (18 мес)', visit_type: 'in_person' },
    // Future appointments
    { family_id: families[17].id, doctor_id: uziDocId, appointment_date: dateOffset(3), start_time: '09:00', end_time: '09:30', status: 'confirmed', reason: 'УЗИ III триместр', visit_type: 'in_person' },
    { family_id: families[18].id, doctor_id: gynDocId, appointment_date: dateOffset(2), start_time: '10:00', end_time: '10:30', status: 'confirmed', reason: 'Предродовой осмотр', visit_type: 'in_person' },
    { family_id: families[25].id, doctor_id: pedDocId, child_id: motherToChild.get(25)?.id, appointment_date: dateOffset(5), start_time: '10:30', end_time: '11:00', status: 'requested', reason: 'Осмотр педиатра (9 мес)', visit_type: 'in_person' },
    { family_id: families[11].id, doctor_id: gynDocId, appointment_date: dateOffset(7), start_time: '11:00', end_time: '11:30', status: 'confirmed', reason: 'Осмотр гинеколога (II триместр)', visit_type: 'in_person' },
  ]

  const { error: apptErr } = await sb.from('appointments').insert(appts)
  if (apptErr) throw createError({ statusCode: 500, message: `Appointments: ${apptErr.message}` })
  log.push(`✓ Appointments: ${appts.length}`)

  // ─── 13. CREATE COORDINATOR TASKS ────────────────────────────────────────
  const coordinatorIds = [
    userMap.get('dinara@demo.kz')!,
    userMap.get('ainur@demo.kz')!,
    userMap.get('zhanna@demo.kz')!,
  ]

  const tasks: Record<string, unknown>[] = [
    { clinic_id: clinic.id, family_id: families[0].id, type: 'overdue_followup', priority: 'critical', status: 'pending', assigned_to: coordinatorIds[0], due_date: dateOffset(-3), title: 'УЗИ II триместра просрочено — Каримова А.' },
    { clinic_id: clinic.id, family_id: families[0].id, type: 'low_adherence', priority: 'high', status: 'pending', assigned_to: coordinatorIds[0], due_date: todayStr(), title: 'Adherence 45% — требует звонка (Каримова А.)' },
    { clinic_id: clinic.id, family_id: families[13].id, type: 'missed_appointment', priority: 'high', status: 'pending', assigned_to: coordinatorIds[1], due_date: dateOffset(-2), title: 'Неявка на осмотр гинеколога — Дюсенова М.' },
    { clinic_id: clinic.id, family_id: families[2].id, type: 'welcome_call', priority: 'medium', status: 'pending', assigned_to: coordinatorIds[0], due_date: todayStr(), title: 'Первичный звонок (8 нед) — Жумабаева К.' },
    { clinic_id: clinic.id, family_id: families[24].id, type: 'vaccination_reminder', priority: 'high', status: 'pending', assigned_to: coordinatorIds[1], due_date: dateOffset(3), title: 'АКДС-HepB-Hib (1) через 3 дня — Жетписбаева Н.' },
    { clinic_id: clinic.id, family_id: families[25].id, type: 'overdue_followup', priority: 'medium', status: 'pending', assigned_to: coordinatorIds[2], due_date: dateOffset(-5), title: 'Осмотр педиатра (9 мес) просрочен — Тлеуова Р.' },
    { clinic_id: clinic.id, family_id: families[3].id, type: 'welcome_call', priority: 'low', status: 'pending', assigned_to: coordinatorIds[2], due_date: dateOffset(2), title: 'Подключение (4 нед) — Садыкова Г.' },
    { clinic_id: clinic.id, family_id: families[19].id, type: 'vaccination_reminder', priority: 'medium', status: 'pending', assigned_to: coordinatorIds[1], due_date: dateOffset(1), title: 'BCG + HepB напоминание — Жаксылыкова Н.' },
    // Completed tasks
    { clinic_id: clinic.id, family_id: families[1].id, type: 'vaccination_reminder', priority: 'high', status: 'completed', assigned_to: coordinatorIds[1], due_date: dateOffset(-7), title: 'АКДС (3) напоминание — Нурланова С.', completed_at: tsOffset(-6) },
    { clinic_id: clinic.id, family_id: families[10].id, type: 'welcome_call', priority: 'low', status: 'completed', assigned_to: coordinatorIds[0], due_date: dateOffset(-14), title: 'Подключение — Алиева Д.', completed_at: tsOffset(-14) },
  ]

  const { error: taskErr } = await sb.from('coordinator_tasks').insert(tasks)
  if (taskErr) throw createError({ statusCode: 500, message: `Tasks: ${taskErr.message}` })
  log.push(`✓ Coordinator tasks: ${tasks.length}`)

  // ─── 14. CREATE VACCINATIONS ─────────────────────────────────────────────
  const allVax: Record<string, unknown>[] = []

  postBirthIndices.forEach((mi) => {
    const child = motherToChild.get(mi)
    if (!child) return
    const ageDays = MOTHERS[mi].monthAge! * 30
    allVax.push(...makeVaccinations(child.id, child.dob, ageDays, pedDocId))
  })

  if (allVax.length) {
    const { error: vaxErr } = await sb.from('vaccinations').insert(allVax)
    if (vaxErr) throw createError({ statusCode: 500, message: `Vaccinations: ${vaxErr.message}` })
  }
  log.push(`✓ Vaccinations: ${allVax.length}`)

  // ─── DONE ────────────────────────────────────────────────────────────────
  return {
    success: true,
    message: 'Seed complete',
    log,
    credentials: { password: PWD, admin: 'admin@demo.kz', coordinator: 'dinara@demo.kz', doctor: 'aliya@demo.kz', mother: 'p1@demo.kz' },
    stats: {
      clinic: 1,
      users: userMap.size,
      doctors: doctors.length,
      families: families.length,
      children: children.length,
      journeys: journeys.length,
      events: allEvents.length,
      prescriptions: prescriptions.length,
      doseLogs: doseLogs.length,
      appointments: appts.length,
      tasks: tasks.length,
      vaccinations: allVax.length,
    },
  }
})

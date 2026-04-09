/**
 * Realistic mock data for all app dashboards.
 * Provides pre-generated data for Family, Coordinator, Doctor, and Admin views.
 */

// ──── Helpers ────

function randomInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min
}

function randomFloat(min: number, max: number, decimals = 1) {
  return parseFloat((Math.random() * (max - min) + min).toFixed(decimals))
}

function randomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)]
}

function generateSparkline(length: number, base: number, variance: number): number[] {
  return Array.from({ length }, () => base + randomInt(-variance, variance))
}

function pastDays(n: number): string[] {
  const dates: string[] = []
  const now = new Date()
  for (let i = n - 1; i >= 0; i--) {
    const d = new Date(now)
    d.setDate(d.getDate() - i)
    dates.push(d.toISOString().slice(0, 10))
  }
  return dates
}

function formatDateRu(iso: string): string {
  const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек']
  const d = new Date(iso)
  return `${d.getDate()} ${months[d.getMonth()]}`
}

// ──── Types ────

interface MockJourneyEvent {
  id: string
  title: string
  description: string
  type: string
  status: 'completed' | 'overdue' | 'due' | 'upcoming'
  due_date: string
  is_mandatory: boolean
}

interface MockPrescription {
  id: string
  medication: string
  dosage: string
  frequency: string
  times: string[]
  adherencePercent: number
  todayDoses: Array<{
    id: string
    time: string
    status: 'confirmed' | 'pending' | 'missed'
  }>
}

interface MockAppointment {
  id: string
  reason: string
  doctor_name: string
  specialty: string
  appointment_date: string
  start_time: string
  status: 'confirmed' | 'requested' | 'completed' | 'cancelled'
}

interface MockChild {
  id: string
  first_name: string
  birth_date: string
  gender: 'male' | 'female'
  blood_type: string
  weight_kg: number
  height_cm: number
}

interface MockFamily {
  id: string
  mother_name: string
  phone: string
  journey_type: 'pregnancy' | 'postpartum' | 'infant' | 'toddler'
  week_or_age: string
  adherence: number
  overdue_count: number
  children: MockChild[]
  last_activity: string
}

interface MockTask {
  id: string
  type: 'overdue_followup' | 'missed_appointment' | 'low_adherence' | 'vaccination_reminder' | 'welcome_call' | 'reactivation'
  priority: 'critical' | 'high' | 'medium' | 'low'
  title: string
  family_name: string
  created_at: string
  status: 'pending' | 'done'
}

interface MockDoctorPatient {
  id: string
  mother_name: string
  journey_type: string
  last_visit: string
  next_visit: string
  children: Array<{ name: string; age: string }>
}

interface MockScheduleSlot {
  id: string
  start_time: string
  end_time: string
  patient_name?: string
  reason?: string
  is_booked: boolean
}

// ──── Mock Data Generator ────

export function useMockData() {
  // ═══════════════════════════
  //  Family Dashboard
  // ═══════════════════════════

  const familyKpi = {
    journeyProgress: { value: 68, trend: 5, sparkline: generateSparkline(7, 65, 5) },
    adherence: { value: 94, trend: 2, sparkline: generateSparkline(7, 90, 6) },
    nextEventDays: 3,
    unreadNotifications: 4,
    completedEvents: 34,
    totalEvents: 50,
  }

  const journeyEvents: MockJourneyEvent[] = [
    { id: '1', title: 'УЗИ 2 триместра', description: 'Ультразвуковое исследование 18–21 неделя', type: 'ultrasound', status: 'completed', due_date: pastDays(14)[0], is_mandatory: true },
    { id: '2', title: 'Общий анализ крови', description: 'ОАК + биохимия', type: 'analysis', status: 'completed', due_date: pastDays(10)[0], is_mandatory: true },
    { id: '3', title: 'Консультация генетика', description: 'Скрининг 2 триместра', type: 'screening', status: 'overdue', due_date: pastDays(3)[0], is_mandatory: true },
    { id: '4', title: 'Приём гинеколога', description: 'Плановый осмотр, 22 неделя', type: 'checkup', status: 'due', due_date: new Date().toISOString().slice(0, 10), is_mandatory: true },
    { id: '5', title: 'Тест на глюкозу (ОГТТ)', description: 'Глюкозотолерантный тест 24–28 неделя', type: 'analysis', status: 'upcoming', due_date: pastDays(-7)[0] || '2026-04-16', is_mandatory: true },
    { id: '6', title: 'Вакцинация от гриппа', description: 'Рекомендовано во 2 триместре', type: 'vaccination', status: 'upcoming', due_date: '2026-04-20', is_mandatory: false },
    { id: '7', title: 'Допплерометрия', description: 'Оценка кровотока плода', type: 'ultrasound', status: 'upcoming', due_date: '2026-04-25', is_mandatory: true },
    { id: '8', title: 'D-димер', description: 'Контроль коагуляции', type: 'analysis', status: 'upcoming', due_date: '2026-05-02', is_mandatory: false },
  ]

  const prescriptions: MockPrescription[] = [
    {
      id: 'rx1', medication: 'Витамин D3', dosage: '2000 МЕ', frequency: '1 раз/день',
      times: ['09:00'], adherencePercent: 96,
      todayDoses: [{ id: 'd1', time: '09:00', status: 'confirmed' }],
    },
    {
      id: 'rx2', medication: 'Железо (Ферлатум)', dosage: '40 мг', frequency: '2 раза/день',
      times: ['08:00', '20:00'], adherencePercent: 89,
      todayDoses: [
        { id: 'd2', time: '08:00', status: 'confirmed' },
        { id: 'd3', time: '20:00', status: 'pending' },
      ],
    },
    {
      id: 'rx3', medication: 'Магний B6', dosage: '100 мг', frequency: '2 раза/день',
      times: ['10:00', '22:00'], adherencePercent: 92,
      todayDoses: [
        { id: 'd4', time: '10:00', status: 'confirmed' },
        { id: 'd5', time: '22:00', status: 'pending' },
      ],
    },
    {
      id: 'rx4', medication: 'Фолиевая кислота', dosage: '400 мкг', frequency: '1 раз/день',
      times: ['09:00'], adherencePercent: 100,
      todayDoses: [{ id: 'd6', time: '09:00', status: 'confirmed' }],
    },
  ]

  const appointments: MockAppointment[] = [
    { id: 'a1', reason: 'Плановый осмотр гинеколога', doctor_name: 'Алия Касымова', specialty: 'Гинеколог', appointment_date: '2026-04-11', start_time: '10:00', status: 'confirmed' },
    { id: 'a2', reason: 'УЗИ 3 триместра', doctor_name: 'Марат Ибрагимов', specialty: 'УЗИ-специалист', appointment_date: '2026-04-18', start_time: '14:30', status: 'requested' },
    { id: 'a3', reason: 'Консультация педиатра', doctor_name: 'Динара Жумабаева', specialty: 'Педиатр', appointment_date: '2026-03-28', start_time: '11:00', status: 'completed' },
  ]

  const adherenceWeekly = pastDays(7).map(d => ({
    date: formatDateRu(d),
    taken: randomInt(3, 6),
    total: 6,
  }))

  const adherenceMonthly = pastDays(30).map(d => ({
    date: d,
    percent: randomInt(75, 100),
  }))

  // ═══════════════════════════
  //  Vaccinations
  // ═══════════════════════════

  const vaccinations = [
    { id: 'v1', name: 'BCG', date: '2026-01-15', status: 'completed' as const, dose: '1/1', batch: 'BCG-2025-KZ-44' },
    { id: 'v2', name: 'Гепатит B (1-я)', date: '2026-01-15', status: 'completed' as const, dose: '1/3', batch: 'HBV-2025-112' },
    { id: 'v3', name: 'АКДС-ГепB-Hib (1-я)', date: '2026-03-15', status: 'completed' as const, dose: '1/3', batch: 'PENTA-2026-07' },
    { id: 'v4', name: 'ИПВ (1-я)', date: '2026-03-15', status: 'completed' as const, dose: '1/3', batch: 'IPV-2026-22' },
    { id: 'v5', name: 'PCV13 (1-я)', date: '2026-03-15', status: 'completed' as const, dose: '1/3', batch: 'PCV-2026-89' },
    { id: 'v6', name: 'АКДС-ГепB-Hib (2-я)', date: '2026-04-15', status: 'upcoming' as const, dose: '2/3', batch: '' },
    { id: 'v7', name: 'ИПВ (2-я)', date: '2026-04-15', status: 'upcoming' as const, dose: '2/3', batch: '' },
    { id: 'v8', name: 'PCV13 (2-я)', date: '2026-04-15', status: 'upcoming' as const, dose: '2/3', batch: '' },
  ]

  // ═══════════════════════════
  //  Growth & Milestones
  // ═══════════════════════════

  const growthData = {
    months: [0, 1, 2, 3, 4, 5, 6],
    weight: [3.4, 4.2, 5.1, 6.0, 6.8, 7.3, 7.9],
    height: [50, 54, 57, 60, 63, 65, 67],
    head: [35, 37, 38.5, 40, 41, 42, 43],
    // WHO percentile bands (approximate)
    whoWeight3rd: [2.5, 3.4, 4.3, 5.0, 5.6, 6.1, 6.5],
    whoWeight50th: [3.3, 4.5, 5.6, 6.4, 7.0, 7.5, 7.9],
    whoWeight97th: [4.4, 5.8, 7.1, 8.0, 8.7, 9.2, 9.7],
    whoHeight3rd: [46.1, 50.8, 54.4, 57.3, 59.7, 61.7, 63.3],
    whoHeight50th: [49.9, 54.7, 58.4, 61.4, 63.9, 65.9, 67.6],
    whoHeight97th: [53.7, 58.6, 62.4, 65.5, 68.0, 70.1, 71.9],
  }

  const milestones = [
    { id: 'm1', name: 'Первая улыбка', icon: 'lucide:smile', achieved: true, date: '2026-02-20', expected: '1–2 мес' },
    { id: 'm2', name: 'Держит голову', icon: 'lucide:arrow-up-right', achieved: true, date: '2026-03-10', expected: '2–3 мес' },
    { id: 'm3', name: 'Переворот на живот', icon: 'lucide:move-right', achieved: true, date: '2026-04-05', expected: '3–5 мес' },
    { id: 'm4', name: 'Сидит с поддержкой', icon: 'lucide:user', achieved: false, date: '', expected: '5–7 мес' },
    { id: 'm5', name: 'Ползает', icon: 'lucide:move-right', achieved: false, date: '', expected: '7–10 мес' },
    { id: 'm6', name: 'Стоит у опоры', icon: 'lucide:arrow-up-right', achieved: false, date: '', expected: '9–12 мес' },
    { id: 'm7', name: 'Первые шаги', icon: 'lucide:footprints', achieved: false, date: '', expected: '11–15 мес' },
    { id: 'm8', name: 'Первые слова', icon: 'lucide:message-circle', achieved: false, date: '', expected: '12–18 мес' },
  ]

  // ═══════════════════════════
  //  Mood & Mental Health
  // ═══════════════════════════

  const moodHistory = pastDays(14).map(d => ({
    date: d,
    score: randomInt(2, 5),
  }))

  const lastEpds = { score: 8, risk: 'low' as const, date: '2026-03-25' }

  // ═══════════════════════════
  //  Sleep & Nutrition
  // ═══════════════════════════

  const sleepWeek = pastDays(7).map(d => ({
    date: formatDateRu(d),
    night: randomFloat(6, 10, 1),
    nap: randomFloat(1.5, 4, 1),
  }))

  const feedingToday = [
    { id: 'f1', type: 'breast', time: '06:30', duration: 15, side: 'L' },
    { id: 'f2', type: 'breast', time: '09:00', duration: 12, side: 'R' },
    { id: 'f3', type: 'solid', time: '12:00', food: 'Кабачок + брокколи', amount: '80 мл' },
    { id: 'f4', type: 'breast', time: '15:00', duration: 10, side: 'L' },
    { id: 'f5', type: 'solid', time: '18:00', food: 'Тыква', amount: '60 мл' },
  ]

  // ═══════════════════════════
  //  Achievements & Referral
  // ═══════════════════════════

  const streaks = {
    doses: { current: 12, longest: 18 },
    mood: { current: 7, longest: 14 },
    sleep: { current: 3, longest: 9 },
    feeding: { current: 5, longest: 11 },
  }

  const achievements = [
    { id: 'ach1', name: 'Первый визит', icon: 'lucide:stethoscope', unlocked: true, date: '2026-01-16' },
    { id: 'ach2', name: '7 дней подряд', icon: 'lucide:flame', unlocked: true, date: '2026-02-05' },
    { id: 'ach3', name: 'Все прививки до 3 мес', icon: 'lucide:shield-check', unlocked: true, date: '2026-03-16' },
    { id: 'ach4', name: '30 дней подряд', icon: 'lucide:crown', unlocked: false, date: '' },
    { id: 'ach5', name: 'Паспорт на 50%', icon: 'lucide:file-text', unlocked: false, date: '' },
    { id: 'ach6', name: '100 дней подряд', icon: 'lucide:trophy', unlocked: false, date: '' },
  ]

  const referral = {
    code: 'FAMILY-2A8X',
    invited: 5,
    registered: 3,
    bonus: '15 000 ₸',
    tier: 'Серебро',
    points: 2400,
  }

  // ═══════════════════════════
  //  Education
  // ═══════════════════════════

  const educationArticles = [
    { id: 'e1', title: 'Питание во 2 триместре', category: 'pregnancy', readTime: 5, image: null, week: '20–28 нед' },
    { id: 'e2', title: 'Как справиться с тошнотой', category: 'pregnancy', readTime: 3, image: null, week: '6–14 нед' },
    { id: 'e3', title: 'Грудное вскармливание: первые дни', category: 'breastfeeding', readTime: 7, image: null, week: '0–1 мес' },
    { id: 'e4', title: 'Сон новорождённого: нормы и советы', category: 'childcare', readTime: 6, image: null, week: '0–3 мес' },
    { id: 'e5', title: 'Введение прикорма: когда и как', category: 'nutrition', readTime: 8, image: null, week: '4–6 мес' },
    { id: 'e6', title: 'Постпартальная депрессия: что важно знать', category: 'psychology', readTime: 5, image: null, week: '0–12 мес' },
  ]

  // ═══════════════════════════
  //  Children data
  // ═══════════════════════════

  const children: MockChild[] = [
    { id: 'c1', first_name: 'Амира', birth_date: '2026-01-15', gender: 'female', blood_type: 'A+', weight_kg: 7.9, height_cm: 67 },
  ]

  // ═══════════════════════════
  //  Coordinator
  // ═══════════════════════════

  const coordinatorKpi = {
    activeFamilies: { value: 47, trend: 8, sparkline: generateSparkline(7, 44, 4) },
    criticalTasks: { value: 5, trend: -12, sparkline: generateSparkline(7, 7, 3) },
    pendingTasks: { value: 18, trend: 3, sparkline: generateSparkline(7, 16, 4) },
    todayAppointments: { value: 12, trend: 0, sparkline: generateSparkline(7, 11, 3) },
  }

  const families: MockFamily[] = [
    { id: 'fam1', mother_name: 'Айгерим Касымова', phone: '+7 707 123 4567', journey_type: 'pregnancy', week_or_age: '22 неделя', adherence: 94, overdue_count: 0, children: [], last_activity: '2ч назад' },
    { id: 'fam2', mother_name: 'Дана Нурланова', phone: '+7 701 987 6543', journey_type: 'infant', week_or_age: '3 мес 12 дней', adherence: 78, overdue_count: 2, children: [{ id: 'c2', first_name: 'Тимур', birth_date: '2025-12-28', gender: 'male', blood_type: 'B+', weight_kg: 6.2, height_cm: 61 }], last_activity: '1д назад' },
    { id: 'fam3', mother_name: 'Мадина Ержанова', phone: '+7 777 555 1234', journey_type: 'toddler', week_or_age: '14 мес', adherence: 56, overdue_count: 4, children: [{ id: 'c3', first_name: 'Аян', birth_date: '2025-02-10', gender: 'male', blood_type: 'O+', weight_kg: 10.5, height_cm: 78 }], last_activity: '5д назад' },
    { id: 'fam4', mother_name: 'Сара Абдикаримова', phone: '+7 702 345 6789', journey_type: 'postpartum', week_or_age: '6 недель', adherence: 88, overdue_count: 1, children: [{ id: 'c4', first_name: 'Алия', birth_date: '2026-02-28', gender: 'female', blood_type: 'A-', weight_kg: 4.8, height_cm: 56 }], last_activity: '3ч назад' },
    { id: 'fam5', mother_name: 'Камила Бекмуратова', phone: '+7 705 678 9012', journey_type: 'pregnancy', week_or_age: '34 неделя', adherence: 97, overdue_count: 0, children: [], last_activity: '30 мин назад' },
  ]

  const coordinatorTasks: MockTask[] = [
    { id: 't1', type: 'missed_appointment', priority: 'critical', title: 'Неявка на приём гинеколога', family_name: 'Мадина Ержанова', created_at: '2026-04-09T08:00:00', status: 'pending' },
    { id: 't2', type: 'overdue_followup', priority: 'high', title: 'Просрочен скрининг 1 триместра', family_name: 'Дана Нурланова', created_at: '2026-04-08T06:00:00', status: 'pending' },
    { id: 't3', type: 'low_adherence', priority: 'medium', title: 'Adherence <60% за 7 дней', family_name: 'Мадина Ержанова', created_at: '2026-04-08T06:00:00', status: 'pending' },
    { id: 't4', type: 'vaccination_reminder', priority: 'high', title: 'Прививка АКДС через 3 дня', family_name: 'Сара Абдикаримова', created_at: '2026-04-09T06:00:00', status: 'pending' },
    { id: 't5', type: 'welcome_call', priority: 'low', title: 'Звонок приветствия новой семье', family_name: 'Камила Бекмуратова', created_at: '2026-04-07T10:00:00', status: 'pending' },
    { id: 't6', type: 'reactivation', priority: 'medium', title: 'Не было входа >14 дней', family_name: 'Мадина Ержанова', created_at: '2026-04-05T06:00:00', status: 'done' },
  ]

  const tasksByType = [
    { name: 'Неявки', value: 5 },
    { name: 'Просрочено', value: 8 },
    { name: 'Adherence', value: 4 },
    { name: 'Прививки', value: 6 },
    { name: 'Звонки', value: 3 },
    { name: 'Реактивация', value: 2 },
  ]

  // ═══════════════════════════
  //  Doctor
  // ═══════════════════════════

  const doctorKpi = {
    todayAppointments: 8,
    totalPatients: 124,
    freeSlots: 3,
    avgRating: 4.8,
  }

  const todaySchedule: MockScheduleSlot[] = [
    { id: 's1', start_time: '09:00', end_time: '09:30', patient_name: 'Айгерим К.', reason: 'Плановый осмотр', is_booked: true },
    { id: 's2', start_time: '09:30', end_time: '10:00', patient_name: 'Дана Н.', reason: 'Повторный приём', is_booked: true },
    { id: 's3', start_time: '10:00', end_time: '10:30', is_booked: false },
    { id: 's4', start_time: '10:30', end_time: '11:00', patient_name: 'Камила Б.', reason: 'Первчный приём', is_booked: true },
    { id: 's5', start_time: '11:00', end_time: '11:30', patient_name: 'Сара А.', reason: 'Контроль после родов', is_booked: true },
    { id: 's6', start_time: '11:30', end_time: '12:00', is_booked: false },
    { id: 's7', start_time: '14:00', end_time: '14:30', patient_name: 'Мадина Е.', reason: 'Педиатрический осмотр', is_booked: true },
    { id: 's8', start_time: '14:30', end_time: '15:00', patient_name: 'Гульнар О.', reason: 'Вакцинация', is_booked: true },
    { id: 's9', start_time: '15:00', end_time: '15:30', is_booked: false },
    { id: 's10', start_time: '15:30', end_time: '16:00', patient_name: 'Жанара Т.', reason: 'Плановый осмотр', is_booked: true },
  ]

  const doctorPatients: MockDoctorPatient[] = [
    { id: 'p1', mother_name: 'Айгерим Касымова', journey_type: 'Беременность, 22 нед', last_visit: '2026-04-02', next_visit: '2026-04-16', children: [] },
    { id: 'p2', mother_name: 'Дана Нурланова', journey_type: 'Младенец, 3 мес', last_visit: '2026-03-25', next_visit: '2026-04-25', children: [{ name: 'Тимур', age: '3 мес' }] },
    { id: 'p3', mother_name: 'Мадина Ержанова', journey_type: 'Тоддлер, 14 мес', last_visit: '2026-03-10', next_visit: '2026-04-10', children: [{ name: 'Аян', age: '14 мес' }] },
    { id: 'p4', mother_name: 'Сара Абдикаримова', journey_type: 'Послеродовой, 6 нед', last_visit: '2026-03-28', next_visit: '2026-04-11', children: [{ name: 'Алия', age: '6 нед' }] },
  ]

  const weeklyLoad = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'].map(d => ({
    day: d,
    booked: randomInt(5, 10),
    total: 12,
  }))

  // ═══════════════════════════
  //  Admin
  // ═══════════════════════════

  const adminKpi = {
    totalUsers: { value: 189, trend: 12, sparkline: generateSparkline(7, 180, 10) },
    activeFamilies: { value: 47, trend: 8, sparkline: generateSparkline(7, 44, 5) },
    totalDoctors: { value: 14, trend: 0, sparkline: generateSparkline(7, 14, 1) },
    monthlyAppointments: { value: 342, trend: 15, sparkline: generateSparkline(7, 320, 30) },
  }

  // Revenue mock
  const revenueMonthly = pastDays(180).filter((_, i) => i % 30 === 0).map((d, i) => ({
    month: formatDateRu(d),
    mrr: 1200000 + i * 180000 + randomInt(-50000, 50000),
    consultations: 400000 + i * 60000 + randomInt(-20000, 20000),
    packages: 600000 + i * 90000 + randomInt(-30000, 30000),
    lab: 200000 + i * 30000 + randomInt(-10000, 10000),
  }))

  const retentionCohort = [
    { cohort: 'Янв 2026', m0: 100, m1: 92, m2: 87, m3: 84 },
    { cohort: 'Фев 2026', m0: 100, m1: 89, m2: 85 },
    { cohort: 'Мар 2026', m0: 100, m1: 91 },
    { cohort: 'Апр 2026', m0: 100 },
  ]

  const adherenceTrend = pastDays(30).map(d => ({
    date: d,
    value: randomInt(85, 98),
  }))

  const doctorPerformance = [
    { name: 'Д-р Касымова', specialty: 'Гинеколог', visits: 48, noShowRate: 5, avgDuration: 22, rating: 4.9, load: 85 },
    { name: 'Д-р Ибрагимов', specialty: 'УЗИ', visits: 36, noShowRate: 3, avgDuration: 18, rating: 4.7, load: 72 },
    { name: 'Д-р Жумабаева', specialty: 'Педиатр', visits: 52, noShowRate: 8, avgDuration: 20, rating: 4.8, load: 92 },
    { name: 'Д-р Омаров', specialty: 'Невролог', visits: 28, noShowRate: 12, avgDuration: 25, rating: 4.5, load: 60 },
  ]

  // Capacity heatmap (7 days × 9 hours blocks)
  const capacityHeatmap = Array.from({ length: 7 * 9 }, (_, i) => ({
    value: randomInt(0, 12),
    label: `${['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][i % 7]} ${9 + Math.floor(i / 7)}:00`,
  }))

  // Compliance
  const complianceOverall = 82
  const complianceProtocols = [
    { name: 'Скрининг 1 триместр', completion: 95 },
    { name: 'Скрининг 2 триместр', completion: 88 },
    { name: 'ОАК ежеквартально', completion: 76 },
    { name: 'Вакцинация 0–6 мес', completion: 91 },
    { name: 'Осмотр педиатра ежемесячно', completion: 84 },
    { name: 'Допплерометрия 28 нед', completion: 67 },
  ]

  const npsScore = 72
  const npsSplit = { promoters: 58, passives: 28, detractors: 14 }

  return {
    // Family
    familyKpi, journeyEvents, prescriptions, appointments,
    adherenceWeekly, adherenceMonthly, vaccinations,
    growthData, milestones, moodHistory, lastEpds,
    sleepWeek, feedingToday, streaks, achievements,
    referral, educationArticles, children,
    // Coordinator
    coordinatorKpi, families, coordinatorTasks, tasksByType,
    // Doctor
    doctorKpi, todaySchedule, doctorPatients, weeklyLoad,
    // Admin
    adminKpi, revenueMonthly, retentionCohort, adherenceTrend,
    doctorPerformance, capacityHeatmap, complianceOverall,
    complianceProtocols, npsScore, npsSplit,
  }
}

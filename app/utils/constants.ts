import type { UserRole } from '~/types/database'

// Roles that represent family members (mobile-first app)
export const FAMILY_ROLES: UserRole[] = ['mother', 'father']

// Roles that access the coordinator panel
export const COORDINATOR_ROLES: UserRole[] = ['coordinator']

// Roles that access the doctor panel
export const DOCTOR_ROLES: UserRole[] = ['gynecologist', 'pediatrician', 'doctor']

// Roles that access the admin panel
export const ADMIN_ROLES: UserRole[] = ['clinic_admin', 'clinic_manager', 'platform_admin', 'admin', 'superadmin']

// All staff roles (web console)
export const STAFF_ROLES: UserRole[] = [...COORDINATOR_ROLES, ...DOCTOR_ROLES, ...ADMIN_ROLES]

// Route prefix → required roles mapping
export const ROUTE_ROLE_MAP: Record<string, UserRole[]> = {
  '/family': FAMILY_ROLES,
  '/coordinator': [...COORDINATOR_ROLES, ...ADMIN_ROLES],
  '/doctor': [...DOCTOR_ROLES, ...ADMIN_ROLES],
  '/admin': ADMIN_ROLES,
}

// Default redirect after login based on role
export const ROLE_HOME_MAP: Record<string, string> = {
  mother: '/family',
  father: '/family',
  coordinator: '/coordinator',
  gynecologist: '/doctor',
  pediatrician: '/doctor',
  doctor: '/doctor',
  nurse: '/doctor',
  clinic_admin: '/admin',
  clinic_manager: '/admin',
  platform_admin: '/admin',
  admin: '/admin',
  superadmin: '/admin',
}

// Kazakh national vaccination calendar (0-24 months)
export const KZ_VACCINATION_CALENDAR = [
  { vaccine: 'BCG', dose: 1, trigger_day: 1, name: 'БЦЖ' },
  { vaccine: 'HepB', dose: 1, trigger_day: 1, name: 'Гепатит B (1-я)' },
  { vaccine: 'DTP-HepB-Hib', dose: 1, trigger_day: 60, name: 'АКДС-ГепВ-Хиб (1-я)' },
  { vaccine: 'IPV', dose: 1, trigger_day: 60, name: 'ИПВ (1-я)' },
  { vaccine: 'PCV13', dose: 1, trigger_day: 60, name: 'Пневмококк PCV13 (1-я)' },
  { vaccine: 'HepB', dose: 2, trigger_day: 60, name: 'Гепатит B (2-я)' },
  { vaccine: 'DTP-HepB-Hib', dose: 2, trigger_day: 90, name: 'АКДС-ГепВ-Хиб (2-я)' },
  { vaccine: 'IPV', dose: 2, trigger_day: 90, name: 'ИПВ (2-я)' },
  { vaccine: 'PCV13', dose: 2, trigger_day: 90, name: 'Пневмококк PCV13 (2-я)' },
  { vaccine: 'DTP-HepB-Hib', dose: 3, trigger_day: 120, name: 'АКДС-ГепВ-Хиб (3-я)' },
  { vaccine: 'IPV', dose: 3, trigger_day: 120, name: 'ИПВ (3-я)' },
  { vaccine: 'MMR', dose: 1, trigger_day: 365, name: 'КПК (1-я)' },
  { vaccine: 'PCV13', dose: 3, trigger_day: 365, name: 'Пневмококк PCV13 (3-я)' },
  { vaccine: 'DTP', dose: 4, trigger_day: 547, name: 'АКДС (ревакцинация)' },
  { vaccine: 'OPV', dose: 4, trigger_day: 547, name: 'ОПВ (ревакцинация)' },
] as const

// EPDS (Edinburgh Postnatal Depression Scale) questions
export const EPDS_QUESTIONS = [
  'Я могла смеяться и видеть весёлое',
  'Я с радостью ждала чего-то приятного',
  'Я безосновательно винила себя',
  'Я волновалась и тревожилась без причины',
  'Я чувствовала страх или панику без причины',
  'Я не справлялась',
  'Я так мало спала из-за тревоги',
  'Я чувствовала себя печальной или несчастной',
  'Я так расстраивалась, что плакала',
  'Мне приходила мысль навредить себе',
] as const

// Growth chart WHO percentiles (simplified — P3, P15, P50, P85, P97)
export const WHO_PERCENTILES = [3, 15, 50, 85, 97] as const

// Journey template event presets for pregnancy (Kazakhstan protocols)
export const PREGNANCY_EVENTS_KZ = [
  { week: 6, type: 'consultation', title: 'Первый визит гинеколога', mandatory: true },
  { week: 8, type: 'analysis', title: 'ОАК, биохимия, группа крови, резус', mandatory: true },
  { week: 8, type: 'analysis', title: 'TORCH-инфекции', mandatory: true },
  { week: 11, type: 'screening', title: 'Скрининг 1 триместра (УЗИ + РАРР-А + β-ХГЧ)', mandatory: true },
  { week: 12, type: 'consultation', title: 'Визит гинеколога (результаты скрининга)', mandatory: true },
  { week: 16, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 16, type: 'analysis', title: 'ОАК, ОАМ', mandatory: true },
  { week: 18, type: 'screening', title: 'Скрининг 2 триместра (АФП + β-ХГЧ + эстриол)', mandatory: true },
  { week: 20, type: 'ultrasound', title: 'УЗИ 2 триместра (анатомия)', mandatory: true },
  { week: 20, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 24, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 24, type: 'analysis', title: 'ОАК, глюкозотолерантный тест', mandatory: true },
  { week: 28, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 28, type: 'analysis', title: 'ОАК, Rh-антитела (при Rh-)', mandatory: true },
  { week: 30, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 32, type: 'ultrasound', title: 'УЗИ 3 триместра + КТГ', mandatory: true },
  { week: 34, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 34, type: 'analysis', title: 'ОАК, коагулограмма', mandatory: true },
  { week: 36, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 37, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 38, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 39, type: 'consultation', title: 'Визит гинеколога', mandatory: true },
  { week: 40, type: 'consultation', title: 'Визит гинеколога (ПДР)', mandatory: true },
] as const

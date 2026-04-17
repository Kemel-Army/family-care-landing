# UMAI HEALTH — Полная база знаний для разработки

> **Статус:** Рабочая версия v1.0  
> **Дата:** Апрель 2026  
> **Стек:** Nuxt 4 · Supabase · FSD Architecture  
> **Горизонт продукта:** Зачатие → 2 года ребёнка  
> **Модель:** B2B white-label SaaS для частных клиник

---

## СОДЕРЖАНИЕ

1. [Контекст проекта для разработчика](#1-контекст-проекта-для-разработчика)
2. [Технологический стек](#2-технологический-стек)
3. [Feature-Sliced Design: структура проекта](#3-feature-sliced-design-структура-проекта)
4. [Дизайн-система и цветовая палитра](#4-дизайн-система-и-цветовая-палитра)
5. [Supabase: схема базы данных](#5-supabase-схема-базы-данных)
6. [Row Level Security (RLS)](#6-row-level-security-rls)
7. [Роли и система доступа (RBAC)](#7-роли-и-система-доступа-rbac)
8. [Модуль 1: Family Account & Identity](#8-модуль-1-family-account--identity)
9. [Модуль 2: Care Plan Engine](#9-модуль-2-care-plan-engine)
10. [Модуль 3: Timeline & Journey Dashboard](#10-модуль-3-timeline--journey-dashboard)
11. [Модуль 4: Smart Appointments](#11-модуль-4-smart-appointments)
12. [Модуль 5: Laboratory & Medical Archive](#12-модуль-5-laboratory--medical-archive)
13. [Модуль 6: Smart Prescriptions](#13-модуль-6-smart-prescriptions)
14. [Модуль 7: Vaccination & Check-up Calendar](#14-модуль-7-vaccination--check-up-calendar)
15. [Модуль 8: Coordinator Panel](#15-модуль-8-coordinator-panel)
16. [Модуль 9: Messaging & Notifications](#16-модуль-9-messaging--notifications)
17. [Модуль 10: Clinic Analytics (базовый)](#17-модуль-10-clinic-analytics-базовый)
18. [Модуль 11: Admin & Configuration](#18-модуль-11-admin--configuration)
19. [Бизнес-процессы: полная карта](#19-бизнес-процессы-полная-карта)
20. [API-контракты и Edge Functions](#20-api-контракты-и-edge-functions)
21. [Real-time подписки](#21-real-time-подписки)
22. [Интеграции: WhatsApp, Push, МИС](#22-интеграции-whatsapp-push-мис)
23. [White-label и multi-tenancy](#23-white-label-и-multi-tenancy)
24. [Тестирование](#24-тестирование)
25. [DevOps и деплой](#25-devops-и-деплой)
26. [Безопасность и compliance](#26-безопасность-и-compliance)
27. [Phase 2 модули (отложенные)](#27-phase-2-модули-отложенные)
28. [Глоссарий](#28-глоссарий)

---

## 1. Контекст проекта для разработчика

### Что мы строим

UMAI Health — white-label платформа для частных клиник. Устанавливается как брендированное приложение клиники. Ведёт семью по цифровому маршруту от зачатия до 2 лет ребёнка.

### Почему это не очередной patient cabinet

Обычный patient cabinet — это запись + анализы + чат. Наша платформа — это **journey engine**: система знает, на каком этапе семья, что должно произойти следующим, автоматически напоминает, отслеживает adherence к назначениям и показывает координатору клиники, кто выпал из маршрута.

### Кто использует платформу

| Роль | Интерфейс | Устройство |
|------|-----------|------------|
| Мать / основной родитель | Mobile app | iOS / Android |
| Второй родитель | Mobile app | iOS / Android |
| Координатор клиники | Web console | Desktop |
| Врач (гинеколог / педиатр) | Web console | Desktop / Tablet |
| Администратор клиники | Web admin panel | Desktop |
| Руководитель клиники | Web analytics dashboard | Desktop |

### Архитектурный принцип

**Mobile-first для семьи, web-first для клиники.** Одна кодовая база Nuxt 4 для всех web-интерфейсов. Mobile — через Capacitor (Nuxt → native wrapper) или отдельный Nuxt PWA с push через service worker + native push через Capacitor.

### Бизнес-контекст для разработчика

- Платформа продаётся клиникам как SaaS. Каждая клиника — отдельный tenant.
- Клиника видит приложение под своим брендом (логотип, цвета, название).
- Семья видит приложение клиники, не знает о UMAI Health.
- Данные клиник полностью изолированы друг от друга.

---

## 2. Технологический стек

### Core

| Компонент | Технология | Почему |
|-----------|-----------|--------|
| Frontend framework | **Nuxt 4** (Vue 3, Composition API) | SSR/SSG гибкость, единая кодовая база web + PWA |
| Архитектура фронтенда | **Feature-Sliced Design (FSD)** | Масштабируемость, изоляция модулей, понятная навигация по коду |
| Backend / BaaS | **Supabase** | PostgreSQL, Auth, Storage, Realtime, Edge Functions — всё в одном |
| База данных | **PostgreSQL** (через Supabase) | JSONB для гибких данных, RLS для безопасности, extensions |
| Auth | **Supabase Auth** | Email/password, magic link, OAuth, MFA для персонала |
| File Storage | **Supabase Storage** | Анализы, УЗИ, документы, фото — с RLS на bucket level |
| Realtime | **Supabase Realtime** | Подписки на изменения маршрута, назначений, сообщений |
| Edge Functions | **Supabase Edge Functions** (Deno) | Серверная логика: cron jobs, webhooks, WhatsApp API, care plan engine |
| Mobile | **Capacitor** (Nuxt → iOS/Android) | Одна кодовая база, native push, camera, file access |

### Инфраструктура

| Компонент | Технология |
|-----------|-----------|
| Hosting (web) | Vercel или Cloudflare Pages |
| Push notifications | Firebase Cloud Messaging (FCM) через Capacitor |
| WhatsApp | WhatsApp Business API (Meta Cloud API) |
| SMS fallback | Twilio или локальный провайдер (mobizon.kz) |
| Email transactional | Resend или Postmark |
| Monitoring | Sentry (errors) + PostHog (product analytics) |
| CI/CD | GitHub Actions |
| MCP | Supabase MCP Server для AI-интеграции |

### Ключевые npm-пакеты

```json
{
  "@nuxt/ui": "latest",
  "@vueuse/core": "latest",
  "@supabase/supabase-js": "latest",
  "@capacitor/core": "latest",
  "@capacitor/push-notifications": "latest",
  "@capacitor/camera": "latest",
  "@capacitor/filesystem": "latest",
  "date-fns": "latest",
  "zod": "latest",
  "pinia": "latest",
  "@pinia/nuxt": "latest",
  "chart.js": "latest",
  "vue-chartjs": "latest"
}
```

---

## 3. Feature-Sliced Design: структура проекта

### Принципы FSD

FSD делит код на **слои** (layers), каждый слой содержит **слайсы** (slices), каждый слайс содержит **сегменты** (segments). Зависимости строго сверху вниз: верхний слой может импортировать из нижнего, но не наоборот.

### Слои (от верхнего к нижнему)

```
app/          → Инициализация приложения, провайдеры, глобальные стили
pages/        → Страницы (роутинг)
widgets/      → Композитные UI-блоки (header, sidebar, dashboard cards)
features/     → Бизнес-фичи (создание назначения, запись на приём)
entities/     → Бизнес-сущности (Family, Child, Prescription, Journey)
shared/       → Переиспользуемые утилиты, UI kit, API client, типы
```

### Структура директорий

```
src/
├── app/
│   ├── providers/           # Supabase client, auth provider, tenant provider
│   ├── styles/              # Global CSS, design tokens
│   ├── layouts/             # FamilyLayout, ClinicLayout, AdminLayout
│   └── middleware/          # Auth guard, role guard, tenant guard
│
├── pages/
│   ├── family/              # Экраны семьи (mobile-first)
│   │   ├── index.vue        # Timeline dashboard
│   │   ├── journey/         # Journey details
│   │   ├── prescriptions/   # Smart prescriptions
│   │   ├── appointments/    # Smart appointments
│   │   ├── records/         # Medical archive
│   │   ├── vaccinations/    # Vaccination calendar
│   │   ├── child/           # Child profile & development
│   │   └── settings/        # Family settings, consents
│   │
│   ├── coordinator/         # Экраны координатора (web)
│   │   ├── index.vue        # Coordinator dashboard
│   │   ├── families/        # Family list & search
│   │   ├── overdue/         # Overdue actions queue
│   │   ├── outreach/        # Outreach scenarios
│   │   └── tasks/           # Task management
│   │
│   ├── doctor/              # Экраны врача (web, Phase 2)
│   │   ├── index.vue        # Doctor dashboard
│   │   ├── patients/        # Patient list
│   │   └── patient/[id]/    # Patient journey view
│   │
│   ├── admin/               # Admin panel (web)
│   │   ├── index.vue        # Admin dashboard
│   │   ├── clinics/         # Clinic/tenant management
│   │   ├── templates/       # Journey templates
│   │   ├── users/           # User management
│   │   └── analytics/       # Clinic analytics
│   │
│   └── auth/                # Auth pages
│       ├── login.vue
│       ├── register.vue
│       ├── forgot-password.vue
│       └── verify.vue
│
├── widgets/
│   ├── family-timeline/     # Timeline widget (main dashboard)
│   ├── prescription-card/   # Daily prescription card
│   ├── appointment-card/    # Upcoming appointment card
│   ├── overdue-alert/       # Overdue alert banner
│   ├── journey-progress/    # Journey progress bar
│   ├── coordinator-queue/   # Coordinator task queue
│   ├── analytics-chart/     # Analytics chart components
│   └── navigation/          # Sidebar, bottom nav, header
│
├── features/
│   ├── auth/
│   │   ├── login/           # Login flow
│   │   ├── register/        # Registration flow
│   │   ├── mfa/             # MFA for staff
│   │   └── consent/         # Consent management
│   │
│   ├── family/
│   │   ├── create-family/   # Create family account
│   │   ├── add-child/       # Add child profile
│   │   ├── invite-parent/   # Invite second parent
│   │   └── edit-profile/    # Edit family profiles
│   │
│   ├── journey/
│   │   ├── create-journey/  # Initialize journey (pregnancy/child)
│   │   ├── complete-event/  # Mark event as done
│   │   ├── escalate/        # Escalate overdue event
│   │   └── transition/      # Journey transition (pregnancy → postpartum)
│   │
│   ├── prescription/
│   │   ├── create/          # Create prescription
│   │   ├── confirm-dose/    # Confirm dose taken
│   │   ├── skip-dose/       # Skip dose with reason
│   │   └── adherence/       # Adherence tracking
│   │
│   ├── appointment/
│   │   ├── book/            # Book appointment
│   │   ├── reschedule/      # Reschedule
│   │   ├── cancel/          # Cancel
│   │   └── confirm/         # Confirm attendance
│   │
│   ├── records/
│   │   ├── upload/          # Upload document
│   │   ├── view/            # View document
│   │   └── share/           # Share with doctor
│   │
│   ├── vaccination/
│   │   ├── schedule/        # Schedule vaccination
│   │   ├── confirm/         # Confirm vaccination done
│   │   └── remind/          # Send reminder
│   │
│   ├── coordinator/
│   │   ├── assign-task/     # Assign outreach task
│   │   ├── close-task/      # Close task
│   │   ├── call-family/     # Log call to family
│   │   └── reactivate/      # Reactivate dropped family
│   │
│   ├── messaging/
│   │   ├── send-push/       # Send push notification
│   │   ├── send-whatsapp/   # Send WhatsApp message
│   │   └── in-app-message/  # In-app messaging
│   │
│   └── analytics/
│       ├── retention/       # Retention metrics
│       ├── conversion/      # Conversion funnel
│       └── cohort/          # Cohort analysis
│
├── entities/
│   ├── family/
│   │   ├── model/           # Family type, store (Pinia)
│   │   ├── api/             # Supabase queries
│   │   └── ui/              # Family card, family avatar
│   │
│   ├── patient/
│   │   ├── model/           # Mother/Child profile types
│   │   ├── api/
│   │   └── ui/              # Patient card, profile header
│   │
│   ├── journey/
│   │   ├── model/           # Journey, JourneyEvent types
│   │   ├── api/
│   │   └── ui/              # Journey badge, event card
│   │
│   ├── prescription/
│   │   ├── model/           # Prescription, DoseLog types
│   │   ├── api/
│   │   └── ui/              # Prescription pill card
│   │
│   ├── appointment/
│   │   ├── model/
│   │   ├── api/
│   │   └── ui/
│   │
│   ├── document/
│   │   ├── model/
│   │   ├── api/
│   │   └── ui/
│   │
│   ├── vaccination/
│   │   ├── model/
│   │   ├── api/
│   │   └── ui/
│   │
│   ├── notification/
│   │   ├── model/
│   │   ├── api/
│   │   └── ui/
│   │
│   ├── clinic/
│   │   ├── model/           # Clinic/Tenant types
│   │   ├── api/
│   │   └── ui/
│   │
│   └── user/
│       ├── model/           # User, Role types
│       ├── api/
│       └── ui/
│
└── shared/
    ├── api/
    │   ├── supabase.ts      # Supabase client singleton
    │   ├── types.ts          # Generated Supabase types
    │   └── helpers.ts        # Query helpers
    │
    ├── config/
    │   ├── roles.ts          # Role definitions
    │   ├── journey-templates.ts  # Default journey templates
    │   └── vaccination-schedule.ts  # National vaccination calendar KZ
    │
    ├── lib/
    │   ├── date.ts           # date-fns wrappers
    │   ├── validators.ts     # Zod schemas
    │   ├── formatters.ts     # Number, currency, phone formatters
    │   └── i18n.ts           # Localization (kk/ru)
    │
    ├── ui/
    │   ├── Button.vue
    │   ├── Card.vue
    │   ├── Modal.vue
    │   ├── Badge.vue
    │   ├── Timeline.vue
    │   ├── Calendar.vue
    │   ├── ProgressBar.vue
    │   ├── Avatar.vue
    │   ├── StatusDot.vue
    │   └── EmptyState.vue
    │
    └── types/
        ├── database.ts       # Auto-generated from Supabase
        ├── enums.ts           # Shared enums
        └── common.ts          # Shared type utilities
```

### Правила FSD

1. **Слой `pages/` только вызывает `widgets/` и `features/`.** Никакой бизнес-логики в pages.
2. **`features/` вызывает `entities/` и `shared/`.** Feature = одно действие пользователя.
3. **`entities/` содержит модель + API + базовый UI** для одной бизнес-сущности. Entities не знают о features.
4. **`shared/` — ноль бизнес-логики.** Только утилиты, UI kit, конфиги, типы.
5. **Каждый слайс (папка) содержит `index.ts`** — public API слайса. Импорт только через index.

---

## 4. Дизайн-система и цветовая палитра

### Психология цвета для maternal/child health

Палитра подобрана на основе исследований восприятия цвета в контексте здоровья, материнства и доверия:

| Роль цвета | Цвет | HEX | HSL | Психологическое обоснование |
|------------|------|-----|-----|---------------------------|
| **Primary** | Мягкий teal (бирюзово-зелёный) | `#2A9D8F` | 174° 57% 39% | Доверие + спокойствие + медицинская ассоциация. Не холодный синий (больница), не слишком тёплый (несерьёзно). Teal — баланс между профессионализмом и заботой. |
| **Primary Dark** | Тёмный teal | `#1A7A6E` | 172° 63% 29% | Для hover, active states, заголовков |
| **Primary Light** | Светлый teal | `#E6F5F3` | 170° 42% 93% | Фоны карточек, subtle highlights |
| **Secondary** | Тёплый коралл | `#E07A5F` | 15° 68% 63% | Теплота + женственность + вовлечённость. Дополняет teal по цветовому кругу. Для акцентов и CTA. |
| **Warning** | Мягкий amber | `#E9C46A` | 45° 77% 66% | Мягкое предупреждение. Overdue events, пропущенные дозы. Не агрессивный красный. |
| **Danger** | Приглушённый красный | `#D64545` | 0° 62% 55% | Только для критичных ситуаций: red flags, срочные эскалации. Используется минимально. |
| **Success** | Зелёный sage | `#52B788` | 150° 38% 52% | Выполненные события, подтверждённые приёмы. Мягкий, не кричащий. |
| **Neutral 900** | Тёмный графит | `#264653` | 195° 37% 24% | Основной текст. Не чёрный (слишком контрастно для health app). |
| **Neutral 700** | Средний серый | `#5C6B73` | 200° 11% 41% | Вторичный текст |
| **Neutral 400** | Светлый серый | `#9DB4C0` | 200° 25% 68% | Placeholder, disabled |
| **Neutral 100** | Фон | `#F8F9FA` | 210° 17% 97% | Основной фон приложения |
| **Surface** | Белый | `#FFFFFF` | — | Карточки, модальные окна |

### Почему именно эта палитра

- **Teal как primary** — используется в ведущих health-приложениях (Calm, Headspace, медицинские порталы). Ассоциируется с чистотой, доверием, профессионализмом. Не вызывает ассоциацию с холодной больницей (как синий) и не кажется несерьёзным (как розовый).
- **Коралл как secondary** — добавляет теплоту и женственность без инфантильности. Психологически ассоциируется с заботой и вниманием. Идеален для CTA-кнопок на teal-фоне.
- **Amber для warning вместо оранжевого** — менее агрессивный, мягко привлекает внимание к overdue без стресса.
- **Danger используется минимально** — в контексте беременности и первых лет ребёнка красный = стресс. Применяется только для реальных red flags.
- **Нейтральная палитра на базе blue-grey** — не чистый серый (безжизненный), а слегка голубоватый — создаёт ощущение прохлады и профессионализма.

### CSS Variables (design tokens)

```css
:root {
  /* Primary palette */
  --color-primary-50: #E6F5F3;
  --color-primary-100: #B3E2DB;
  --color-primary-200: #80CFC3;
  --color-primary-300: #4DBCAB;
  --color-primary-400: #2A9D8F;
  --color-primary-500: #2A9D8F;
  --color-primary-600: #238B80;
  --color-primary-700: #1A7A6E;
  --color-primary-800: #12685D;
  --color-primary-900: #0A4F47;

  /* Secondary (coral) */
  --color-secondary-50: #FDF0EC;
  --color-secondary-100: #F8D4C9;
  --color-secondary-200: #F3B8A6;
  --color-secondary-300: #EC9C82;
  --color-secondary-400: #E07A5F;
  --color-secondary-500: #E07A5F;
  --color-secondary-600: #C96B53;
  --color-secondary-700: #B25C47;

  /* Semantic */
  --color-success: #52B788;
  --color-success-light: #E8F5EE;
  --color-warning: #E9C46A;
  --color-warning-light: #FDF6E3;
  --color-danger: #D64545;
  --color-danger-light: #FDEAEA;

  /* Neutral */
  --color-neutral-900: #264653;
  --color-neutral-800: #3A5664;
  --color-neutral-700: #5C6B73;
  --color-neutral-600: #7A8B93;
  --color-neutral-500: #9DB4C0;
  --color-neutral-400: #B8CAD2;
  --color-neutral-300: #D3DFE5;
  --color-neutral-200: #E8EEF1;
  --color-neutral-100: #F8F9FA;
  --color-neutral-0: #FFFFFF;

  /* Surfaces */
  --color-bg: var(--color-neutral-100);
  --color-surface: var(--color-neutral-0);
  --color-surface-elevated: var(--color-neutral-0);

  /* Text */
  --color-text-primary: var(--color-neutral-900);
  --color-text-secondary: var(--color-neutral-700);
  --color-text-muted: var(--color-neutral-500);
  --color-text-inverse: var(--color-neutral-0);

  /* Typography */
  --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-size-xs: 0.75rem;    /* 12px */
  --font-size-sm: 0.875rem;   /* 14px */
  --font-size-base: 1rem;     /* 16px */
  --font-size-lg: 1.125rem;   /* 18px */
  --font-size-xl: 1.25rem;    /* 20px */
  --font-size-2xl: 1.5rem;    /* 24px */
  --font-size-3xl: 1.875rem;  /* 30px */

  /* Spacing */
  --space-1: 0.25rem;   /* 4px */
  --space-2: 0.5rem;    /* 8px */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-5: 1.25rem;   /* 20px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-10: 2.5rem;   /* 40px */
  --space-12: 3rem;     /* 48px */

  /* Border radius */
  --radius-sm: 0.375rem;  /* 6px */
  --radius-md: 0.5rem;    /* 8px */
  --radius-lg: 0.75rem;   /* 12px */
  --radius-xl: 1rem;      /* 16px */
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(38, 70, 83, 0.06);
  --shadow-md: 0 4px 6px rgba(38, 70, 83, 0.07), 0 2px 4px rgba(38, 70, 83, 0.06);
  --shadow-lg: 0 10px 15px rgba(38, 70, 83, 0.1), 0 4px 6px rgba(38, 70, 83, 0.05);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-base: 250ms ease;
  --transition-slow: 350ms ease;
}
```

### White-label: tenant-level overrides

Каждый tenant (клиника) может переопределить primary и secondary палитру. Остальные цвета генерируются автоматически.

```typescript
// shared/config/tenant-theme.ts
interface TenantTheme {
  primaryHue: number;       // HSL hue 0-360
  primarySaturation: number; // 0-100
  secondaryHue: number;
  secondarySaturation: number;
  logo: string;             // URL to logo
  clinicName: string;
  accentFont?: string;      // Optional custom font
}

// Генерация полной палитры из 2 цветов
function generatePalette(hue: number, saturation: number): Record<string, string> {
  return {
    50: `hsl(${hue}, ${saturation * 0.42}%, 93%)`,
    100: `hsl(${hue}, ${saturation * 0.5}%, 85%)`,
    200: `hsl(${hue}, ${saturation * 0.6}%, 75%)`,
    300: `hsl(${hue}, ${saturation * 0.75}%, 60%)`,
    400: `hsl(${hue}, ${saturation}%, 50%)`,
    500: `hsl(${hue}, ${saturation}%, 39%)`,
    600: `hsl(${hue}, ${saturation}%, 33%)`,
    700: `hsl(${hue}, ${saturation}%, 29%)`,
    800: `hsl(${hue}, ${saturation}%, 22%)`,
    900: `hsl(${hue}, ${saturation}%, 16%)`,
  };
}
```

### Типографика

- **Основной шрифт:** Inter — нейтральный, отличная читаемость на mobile, поддержка кириллицы.
- **Заголовки:** Inter Semi-Bold (600) или Bold (700).
- **Body text:** Inter Regular (400), line-height 1.5.
- **Мелкий текст (labels, captions):** Inter Medium (500), size 12-14px.

### Иконки

Lucide Icons — open source, consistent style, 1000+ иконок, работает с Vue.

```bash
npm install lucide-vue-next
```

---

## 5. Supabase: схема базы данных

### Соглашения

- Все таблицы в snake_case
- Все ID — `uuid` с `gen_random_uuid()` default
- Все таблицы имеют `created_at` и `updated_at`
- Soft delete через `deleted_at` timestamp (null = active)
- Tenant isolation через `clinic_id` в каждой таблице
- Enums — через PostgreSQL enum types

### Enum types

```sql
-- Роли пользователей
CREATE TYPE user_role AS ENUM (
  'mother',
  'second_parent',
  'gynecologist',
  'pediatrician',
  'coordinator',
  'clinic_admin',
  'management',
  'platform_admin'
);

-- Типы маршрутов
CREATE TYPE journey_type AS ENUM (
  'pregnancy',
  'postpartum',
  'infant',        -- 0-12 мес.
  'toddler'        -- 12-24 мес.
);

-- Статусы событий маршрута
CREATE TYPE event_status AS ENUM (
  'upcoming',
  'due',           -- наступил дедлайн
  'overdue',       -- просрочено
  'completed',
  'skipped',
  'cancelled'
);

-- Типы событий маршрута
CREATE TYPE event_type AS ENUM (
  'consultation',
  'screening',
  'lab_test',
  'ultrasound',
  'vaccination',
  'checkup',
  'specialist_referral',
  'milestone_check',
  'custom'
);

-- Типы назначений
CREATE TYPE prescription_type AS ENUM (
  'medication',
  'vitamin',
  'supplement',
  'other'
);

-- Частота приёма
CREATE TYPE dose_frequency AS ENUM (
  'once_daily',
  'twice_daily',
  'three_times_daily',
  'weekly',
  'as_needed',
  'custom'
);

-- Статус дозы
CREATE TYPE dose_status AS ENUM (
  'pending',
  'taken',
  'skipped',
  'missed'       -- автоматически, если не confirmed в течение window
);

-- Статус записи
CREATE TYPE appointment_status AS ENUM (
  'requested',
  'confirmed',
  'cancelled',
  'completed',
  'no_show',
  'rescheduled'
);

-- Тип документа
CREATE TYPE document_type AS ENUM (
  'lab_result',
  'ultrasound',
  'screening',
  'prescription_photo',
  'discharge_summary',
  'vaccination_card',
  'certificate',
  'other'
);

-- Каналы нотификации
CREATE TYPE notification_channel AS ENUM (
  'push',
  'whatsapp',
  'sms',
  'email',
  'in_app'
);

-- Статус нотификации
CREATE TYPE notification_status AS ENUM (
  'pending',
  'sent',
  'delivered',
  'read',
  'failed'
);

-- Тип согласия
CREATE TYPE consent_type AS ENUM (
  'data_processing',
  'notifications_push',
  'notifications_whatsapp',
  'notifications_sms',
  'family_sharing',
  'telemedicine'
);

-- Тип задачи координатора
CREATE TYPE coordinator_task_type AS ENUM (
  'overdue_followup',
  'missed_appointment',
  'low_adherence',
  'reactivation',
  'vaccination_reminder',
  'welcome_call',
  'custom'
);

CREATE TYPE coordinator_task_status AS ENUM (
  'open',
  'in_progress',
  'completed',
  'cancelled'
);
```

### Таблицы

```sql
-- ============================================
-- TENANT / CLINIC
-- ============================================

CREATE TABLE clinics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,            -- для white-label URL: {slug}.umai-health.kz
  logo_url text,
  theme jsonb DEFAULT '{}',             -- TenantTheme object
  settings jsonb DEFAULT '{}',          -- clinic-level settings
  timezone text DEFAULT 'Asia/Almaty',
  languages text[] DEFAULT ARRAY['ru', 'kk'],
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ============================================
-- USERS & AUTH
-- ============================================

CREATE TABLE users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  role user_role NOT NULL,
  full_name text NOT NULL,
  phone text,
  email text,
  avatar_url text,
  language text DEFAULT 'ru',
  is_active boolean DEFAULT true,
  last_seen_at timestamptz,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_users_clinic ON users(clinic_id);
CREATE INDEX idx_users_role ON users(role);

-- ============================================
-- FAMILY
-- ============================================

CREATE TABLE families (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  primary_user_id uuid NOT NULL REFERENCES users(id),
  secondary_user_id uuid REFERENCES users(id),
  family_code text UNIQUE,              -- для приглашения второго родителя
  status text DEFAULT 'active',         -- active, inactive, archived
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_families_clinic ON families(clinic_id);
CREATE INDEX idx_families_primary ON families(primary_user_id);

-- ============================================
-- PATIENT PROFILES (Mother & Child)
-- ============================================

CREATE TABLE mother_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  date_of_birth date,
  blood_type text,
  rh_factor text,
  allergies text[],
  chronic_conditions text[],
  obstetric_history jsonb DEFAULT '{}',  -- gravida, para, previous pregnancies
  current_pregnancy jsonb,               -- lmp, edd, gestational_age_at_registration, risk_factors
  assigned_doctor_id uuid REFERENCES users(id),
  package_id uuid,                       -- reference to service package
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_mother_profiles_family ON mother_profiles(family_id);
CREATE INDEX idx_mother_profiles_clinic ON mother_profiles(clinic_id);

CREATE TABLE child_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  first_name text,
  last_name text,
  date_of_birth date,
  sex text,                              -- male, female
  birth_weight_g integer,
  birth_height_cm numeric(5,2),
  birth_head_circumference_cm numeric(5,2),
  apgar_scores jsonb,                    -- {1min: 8, 5min: 9}
  birth_notes text,
  blood_type text,
  allergies text[],
  assigned_pediatrician_id uuid REFERENCES users(id),
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_child_profiles_family ON child_profiles(family_id);
CREATE INDEX idx_child_profiles_clinic ON child_profiles(clinic_id);

-- ============================================
-- JOURNEYS & EVENTS
-- ============================================

CREATE TABLE journeys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  patient_type text NOT NULL,            -- 'mother' or 'child'
  patient_id uuid NOT NULL,              -- mother_profile_id or child_profile_id
  journey_type journey_type NOT NULL,
  status text DEFAULT 'active',          -- active, completed, paused, cancelled
  started_at timestamptz DEFAULT now(),
  expected_end_at timestamptz,
  completed_at timestamptz,
  template_id uuid,                      -- reference to journey template used
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_journeys_family ON journeys(family_id);
CREATE INDEX idx_journeys_clinic ON journeys(clinic_id);
CREATE INDEX idx_journeys_patient ON journeys(patient_id);
CREATE INDEX idx_journeys_status ON journeys(status);

CREATE TABLE journey_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journey_id uuid NOT NULL REFERENCES journeys(id) ON DELETE CASCADE,
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  event_type event_type NOT NULL,
  title text NOT NULL,
  description text,
  status event_status DEFAULT 'upcoming',
  due_date date NOT NULL,
  due_time time,                         -- optional specific time
  completed_at timestamptz,
  completed_by uuid REFERENCES users(id),
  week_number integer,                   -- gestational week (pregnancy) or child age in weeks
  is_mandatory boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  related_appointment_id uuid,
  notes text,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_journey_events_journey ON journey_events(journey_id);
CREATE INDEX idx_journey_events_status ON journey_events(status);
CREATE INDEX idx_journey_events_due ON journey_events(due_date);
CREATE INDEX idx_journey_events_family ON journey_events(family_id);
CREATE INDEX idx_journey_events_clinic ON journey_events(clinic_id);

-- ============================================
-- JOURNEY TEMPLATES (для care plan engine)
-- ============================================

CREATE TABLE journey_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid REFERENCES clinics(id),  -- NULL = platform-wide template
  journey_type journey_type NOT NULL,
  name text NOT NULL,
  description text,
  is_default boolean DEFAULT false,
  version integer DEFAULT 1,
  events_template jsonb NOT NULL,         -- Array of event templates
  /*
    events_template structure:
    [
      {
        "event_type": "screening",
        "title": "Первый скрининг (11-14 нед.)",
        "description": "УЗИ + биохимия",
        "trigger_type": "gestational_week",  -- or "child_age_days", "relative_days"
        "trigger_value": 84,                 -- day 84 = week 12
        "is_mandatory": true,
        "sort_order": 1
      }
    ]
  */
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ============================================
-- PRESCRIPTIONS
-- ============================================

CREATE TABLE prescriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  patient_type text NOT NULL,            -- 'mother' or 'child'
  patient_id uuid NOT NULL,
  journey_id uuid REFERENCES journeys(id),
  prescribed_by uuid REFERENCES users(id),
  prescription_type prescription_type NOT NULL,
  name text NOT NULL,                    -- e.g. "Фолиевая кислота", "Витамин D3"
  dosage text NOT NULL,                  -- e.g. "400 мкг", "500 МЕ"
  frequency dose_frequency NOT NULL,
  custom_frequency_hours integer,        -- if frequency = custom
  time_slots time[],                     -- e.g. ['08:00', '20:00']
  start_date date NOT NULL,
  end_date date,                         -- null = ongoing
  instructions text,                     -- e.g. "После еды"
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_prescriptions_family ON prescriptions(family_id);
CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_clinic ON prescriptions(clinic_id);
CREATE INDEX idx_prescriptions_active ON prescriptions(is_active) WHERE is_active = true;

CREATE TABLE dose_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prescription_id uuid NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  scheduled_date date NOT NULL,
  scheduled_time time NOT NULL,
  status dose_status DEFAULT 'pending',
  confirmed_at timestamptz,
  confirmed_by uuid REFERENCES users(id),
  skip_reason text,
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_dose_logs_prescription ON dose_logs(prescription_id);
CREATE INDEX idx_dose_logs_date ON dose_logs(scheduled_date);
CREATE INDEX idx_dose_logs_status ON dose_logs(status);
CREATE INDEX idx_dose_logs_family ON dose_logs(family_id);

-- ============================================
-- APPOINTMENTS
-- ============================================

CREATE TABLE appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  patient_type text NOT NULL,
  patient_id uuid NOT NULL,
  journey_event_id uuid REFERENCES journey_events(id),
  doctor_id uuid REFERENCES users(id),
  appointment_type text NOT NULL,         -- consultation, lab, ultrasound, vaccination, checkup
  status appointment_status DEFAULT 'requested',
  scheduled_date date NOT NULL,
  scheduled_time time,
  duration_minutes integer DEFAULT 30,
  location text,                          -- cabinet / address
  pre_visit_notes text,                   -- filled by parent before visit
  post_visit_notes text,                  -- filled by doctor after visit
  cancelled_reason text,
  reminder_sent boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_appointments_family ON appointments(family_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(scheduled_date);
CREATE INDEX idx_appointments_clinic ON appointments(clinic_id);
CREATE INDEX idx_appointments_status ON appointments(status);

-- ============================================
-- MEDICAL DOCUMENTS
-- ============================================

CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  patient_type text NOT NULL,
  patient_id uuid NOT NULL,
  journey_id uuid REFERENCES journeys(id),
  document_type document_type NOT NULL,
  title text NOT NULL,
  description text,
  file_path text NOT NULL,               -- Supabase Storage path
  file_size_bytes bigint,
  mime_type text,
  uploaded_by uuid REFERENCES users(id),
  doctor_id uuid REFERENCES users(id),   -- associated doctor
  document_date date,                    -- date on the document itself
  tags text[],
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX idx_documents_family ON documents(family_id);
CREATE INDEX idx_documents_patient ON documents(patient_id);
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_clinic ON documents(clinic_id);

-- ============================================
-- VACCINATIONS
-- ============================================

CREATE TABLE vaccinations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  child_id uuid NOT NULL REFERENCES child_profiles(id),
  family_id uuid NOT NULL REFERENCES families(id),
  vaccine_name text NOT NULL,
  vaccine_code text,                      -- e.g. BCG, OPV, MMR
  dose_number integer DEFAULT 1,          -- 1st, 2nd, 3rd dose
  scheduled_date date NOT NULL,
  administered_date date,
  status text DEFAULT 'scheduled',        -- scheduled, completed, skipped, postponed
  batch_number text,
  administered_by text,
  location text,
  reaction_notes text,
  reminder_sent boolean DEFAULT false,
  journey_event_id uuid REFERENCES journey_events(id),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_vaccinations_child ON vaccinations(child_id);
CREATE INDEX idx_vaccinations_family ON vaccinations(family_id);
CREATE INDEX idx_vaccinations_status ON vaccinations(status);
CREATE INDEX idx_vaccinations_date ON vaccinations(scheduled_date);

-- ============================================
-- GROWTH METRICS
-- ============================================

CREATE TABLE growth_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES child_profiles(id),
  family_id uuid NOT NULL REFERENCES families(id),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  measured_at date NOT NULL,
  age_days integer,                       -- computed from child DOB
  weight_g integer,
  height_cm numeric(5,2),
  head_circumference_cm numeric(5,2),
  measured_by uuid REFERENCES users(id),  -- doctor or parent
  source text DEFAULT 'parent',           -- parent, doctor, clinic
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_growth_child ON growth_metrics(child_id);
CREATE INDEX idx_growth_date ON growth_metrics(measured_at);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  user_id uuid NOT NULL REFERENCES users(id),
  family_id uuid REFERENCES families(id),
  channel notification_channel NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  data jsonb DEFAULT '{}',                -- deep link data, action payload
  status notification_status DEFAULT 'pending',
  scheduled_at timestamptz DEFAULT now(),
  sent_at timestamptz,
  delivered_at timestamptz,
  read_at timestamptz,
  error_message text,
  related_entity_type text,               -- 'journey_event', 'prescription', 'appointment'
  related_entity_id uuid,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_scheduled ON notifications(scheduled_at);
CREATE INDEX idx_notifications_clinic ON notifications(clinic_id);

-- ============================================
-- COORDINATOR TASKS
-- ============================================

CREATE TABLE coordinator_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  family_id uuid NOT NULL REFERENCES families(id),
  assigned_to uuid REFERENCES users(id),
  task_type coordinator_task_type NOT NULL,
  title text NOT NULL,
  description text,
  status coordinator_task_status DEFAULT 'open',
  priority integer DEFAULT 5,            -- 1=highest, 10=lowest
  due_date date,
  completed_at timestamptz,
  completed_by uuid REFERENCES users(id),
  outcome_notes text,
  related_entity_type text,
  related_entity_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_coord_tasks_clinic ON coordinator_tasks(clinic_id);
CREATE INDEX idx_coord_tasks_assigned ON coordinator_tasks(assigned_to);
CREATE INDEX idx_coord_tasks_status ON coordinator_tasks(status);
CREATE INDEX idx_coord_tasks_family ON coordinator_tasks(family_id);
CREATE INDEX idx_coord_tasks_priority ON coordinator_tasks(priority);

-- ============================================
-- CONSENTS
-- ============================================

CREATE TABLE consents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  consent_type consent_type NOT NULL,
  is_granted boolean NOT NULL,
  granted_at timestamptz,
  revoked_at timestamptz,
  ip_address text,
  user_agent text,
  version integer DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_consents_user ON consents(user_id);

-- ============================================
-- AUDIT LOG
-- ============================================

CREATE TABLE audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid REFERENCES clinics(id),
  user_id uuid REFERENCES users(id),
  action text NOT NULL,                   -- 'create', 'update', 'delete', 'view', 'export'
  entity_type text NOT NULL,              -- table name
  entity_id uuid,
  old_data jsonb,
  new_data jsonb,
  ip_address text,
  user_agent text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_audit_clinic ON audit_log(clinic_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_log(created_at);

-- ============================================
-- UPDATED_AT TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
DO $$
DECLARE
  t text;
BEGIN
  FOR t IN
    SELECT table_name FROM information_schema.columns
    WHERE column_name = 'updated_at' AND table_schema = 'public'
  LOOP
    EXECUTE format('
      CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    ', t);
  END LOOP;
END;
$$;
```

---

## 6. Row Level Security (RLS)

Каждая таблица с `clinic_id` получает RLS policy для tenant isolation. Пользователь видит только данные своей клиники.

```sql
-- Enable RLS on all tables
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
ALTER TABLE mother_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE journeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE journey_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE dose_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE vaccinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE coordinator_tasks ENABLE ROW LEVEL SECURITY;

-- Helper function: get current user's clinic_id
CREATE OR REPLACE FUNCTION auth.clinic_id()
RETURNS uuid AS $$
  SELECT clinic_id FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper function: get current user's role
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper function: get current user's family_id
CREATE OR REPLACE FUNCTION auth.family_id()
RETURNS uuid AS $$
  SELECT f.id FROM public.families f
  WHERE f.primary_user_id = auth.uid()
     OR f.secondary_user_id = auth.uid()
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================
-- FAMILY POLICIES
-- ============================================

-- Parents see only their own family
CREATE POLICY families_parent_select ON families
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND (primary_user_id = auth.uid() OR secondary_user_id = auth.uid())
  );

-- Coordinators and doctors see all families in their clinic
CREATE POLICY families_staff_select ON families
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND auth.user_role() IN ('coordinator', 'gynecologist', 'pediatrician', 'clinic_admin', 'management')
  );

-- ============================================
-- JOURNEY EVENTS POLICIES
-- ============================================

-- Parents see their family's events
CREATE POLICY events_parent_select ON journey_events
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND family_id = auth.family_id()
  );

-- Staff see all events in clinic
CREATE POLICY events_staff_select ON journey_events
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND auth.user_role() IN ('coordinator', 'gynecologist', 'pediatrician', 'clinic_admin', 'management')
  );

-- Staff can update events
CREATE POLICY events_staff_update ON journey_events
  FOR UPDATE USING (
    clinic_id = auth.clinic_id()
    AND auth.user_role() IN ('coordinator', 'gynecologist', 'pediatrician', 'clinic_admin')
  );

-- Parents can mark events as completed
CREATE POLICY events_parent_update ON journey_events
  FOR UPDATE USING (
    clinic_id = auth.clinic_id()
    AND family_id = auth.family_id()
  )
  WITH CHECK (
    status IN ('completed', 'skipped')  -- parents can only complete or skip
  );

-- ============================================
-- PRESCRIPTIONS POLICIES
-- ============================================

-- Parents see their prescriptions
CREATE POLICY prescriptions_parent ON prescriptions
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND family_id = auth.family_id()
  );

-- Staff CRUD
CREATE POLICY prescriptions_staff ON prescriptions
  FOR ALL USING (
    clinic_id = auth.clinic_id()
    AND auth.user_role() IN ('coordinator', 'gynecologist', 'pediatrician', 'clinic_admin')
  );

-- ============================================
-- DOSE LOGS POLICIES
-- ============================================

-- Parents can read and create dose logs for their family
CREATE POLICY dose_logs_parent_select ON dose_logs
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND family_id = auth.family_id()
  );

CREATE POLICY dose_logs_parent_update ON dose_logs
  FOR UPDATE USING (
    clinic_id = auth.clinic_id()
    AND family_id = auth.family_id()
  );

-- ============================================
-- DOCUMENTS POLICIES
-- ============================================

-- Parents manage their documents
CREATE POLICY documents_parent ON documents
  FOR ALL USING (
    clinic_id = auth.clinic_id()
    AND family_id = auth.family_id()
    AND deleted_at IS NULL
  );

-- Staff read documents
CREATE POLICY documents_staff ON documents
  FOR SELECT USING (
    clinic_id = auth.clinic_id()
    AND auth.user_role() IN ('coordinator', 'gynecologist', 'pediatrician', 'clinic_admin')
    AND deleted_at IS NULL
  );

-- ============================================
-- NOTIFICATIONS POLICIES
-- ============================================

-- Users see only their own notifications
CREATE POLICY notifications_own ON notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY notifications_own_update ON notifications
  FOR UPDATE USING (user_id = auth.uid());

-- ============================================
-- COORDINATOR TASKS POLICIES
-- ============================================

CREATE POLICY coord_tasks_staff ON coordinator_tasks
  FOR ALL USING (
    clinic_id = auth.clinic_id()
    AND auth.user_role() IN ('coordinator', 'clinic_admin', 'management')
  );

-- ============================================
-- STORAGE POLICIES
-- ============================================

-- Medical documents bucket
-- Path structure: {clinic_id}/{family_id}/{patient_id}/{filename}

-- INSERT: parents can upload to their family folder
CREATE POLICY storage_documents_insert ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'medical-documents'
    AND (storage.foldername(name))[1] = auth.clinic_id()::text
    AND (storage.foldername(name))[2] = auth.family_id()::text
  );

-- SELECT: parents see their family's files, staff see all clinic files
CREATE POLICY storage_documents_select ON storage.objects
  FOR SELECT USING (
    bucket_id = 'medical-documents'
    AND (storage.foldername(name))[1] = auth.clinic_id()::text
    AND (
      (storage.foldername(name))[2] = auth.family_id()::text
      OR auth.user_role() IN ('coordinator', 'gynecologist', 'pediatrician', 'clinic_admin')
    )
  );
```

---

## 7. Роли и система доступа (RBAC)

### Матрица доступа по модулям

| Действие | Mother | Second Parent | Gynecologist | Pediatrician | Coordinator | Clinic Admin | Management |
|----------|--------|---------------|-------------|-------------|-------------|-------------|------------|
| **Family Account** | | | | | | | |
| Просмотр профиля семьи | ✅ Своя | ✅ Своя | ✅ Свои пациенты | ✅ Свои пациенты | ✅ Все в клинике | ✅ Все | ✅ Все |
| Редактирование профиля | ✅ | Ограниченно | ❌ | ❌ | ❌ | ✅ | ❌ |
| Добавление ребёнка | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Приглашение второго родителя | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Journey** | | | | | | | |
| Просмотр маршрута | ✅ Свой | ✅ Свой | ✅ Свои пациенты | ✅ Свои пациенты | ✅ Все | ✅ Все | ✅ Все |
| Создание маршрута | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Отметка события выполненным | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Prescriptions** | | | | | | | |
| Просмотр назначений | ✅ Свои | ✅ Свои | ✅ Свои пациенты | ✅ Свои пациенты | ✅ Все | ✅ Все | ❌ |
| Создание назначения | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Подтверждение приёма дозы | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Appointments** | | | | | | | |
| Просмотр записей | ✅ Свои | ✅ Свои | ✅ Свои | ✅ Свои | ✅ Все | ✅ Все | ❌ |
| Создание записи | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Отмена/перенос | ✅ Свои | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Documents** | | | | | | | |
| Загрузка документа | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Просмотр документов | ✅ Свои | ✅ Свои | ✅ Свои пациенты | ✅ Свои пациенты | ✅ Все | ✅ Все | ❌ |
| **Vaccinations** | | | | | | | |
| Просмотр календаря | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ |
| Отметка вакцинации | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Coordinator Panel** | | | | | | | |
| Доступ к панели | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ (readonly) |
| Создание задач | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Analytics** | | | | | | | |
| Просмотр аналитики | ❌ | ❌ | ❌ | ❌ | Базовая | ✅ | ✅ |
| **Admin** | | | | | | | |
| Управление пользователями | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Управление шаблонами | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |

### Реализация в коде

```typescript
// shared/config/roles.ts

export const PERMISSIONS = {
  // Family
  'family:view_own': ['mother', 'second_parent'],
  'family:view_patients': ['gynecologist', 'pediatrician'],
  'family:view_all': ['coordinator', 'clinic_admin', 'management'],
  'family:edit_own': ['mother'],
  'family:add_child': ['mother', 'coordinator', 'clinic_admin'],
  'family:invite_parent': ['mother'],

  // Journey
  'journey:view_own': ['mother', 'second_parent'],
  'journey:view_patients': ['gynecologist', 'pediatrician'],
  'journey:view_all': ['coordinator', 'clinic_admin', 'management'],
  'journey:create': ['gynecologist', 'pediatrician', 'coordinator', 'clinic_admin'],
  'journey:complete_event': ['mother', 'second_parent', 'gynecologist', 'pediatrician', 'coordinator', 'clinic_admin'],

  // Prescriptions
  'prescription:view_own': ['mother', 'second_parent'],
  'prescription:view_all': ['coordinator', 'clinic_admin'],
  'prescription:create': ['gynecologist', 'pediatrician', 'coordinator'],
  'prescription:confirm_dose': ['mother', 'second_parent'],

  // Appointments
  'appointment:view_own': ['mother', 'second_parent'],
  'appointment:view_all': ['coordinator', 'clinic_admin'],
  'appointment:create': ['mother', 'gynecologist', 'pediatrician', 'coordinator', 'clinic_admin'],
  'appointment:cancel': ['mother', 'gynecologist', 'pediatrician', 'coordinator', 'clinic_admin'],

  // Documents
  'document:upload': ['mother', 'second_parent', 'gynecologist', 'pediatrician', 'coordinator'],
  'document:view_own': ['mother', 'second_parent'],
  'document:view_all': ['coordinator', 'clinic_admin'],

  // Vaccinations
  'vaccination:view': ['mother', 'second_parent', 'pediatrician', 'coordinator', 'clinic_admin'],
  'vaccination:administer': ['pediatrician', 'coordinator'],

  // Coordinator
  'coordinator:access': ['coordinator', 'clinic_admin', 'management'],
  'coordinator:create_task': ['coordinator', 'clinic_admin'],

  // Analytics
  'analytics:basic': ['coordinator'],
  'analytics:full': ['clinic_admin', 'management'],

  // Admin
  'admin:users': ['clinic_admin'],
  'admin:templates': ['clinic_admin'],
  'admin:settings': ['clinic_admin'],
} as const;

export type Permission = keyof typeof PERMISSIONS;

export function hasPermission(userRole: string, permission: Permission): boolean {
  const allowedRoles = PERMISSIONS[permission];
  return (allowedRoles as readonly string[]).includes(userRole);
}
```

```typescript
// app/middleware/role-guard.ts

export default defineNuxtRouteMiddleware((to) => {
  const user = useCurrentUser();
  const requiredPermission = to.meta.permission as Permission | undefined;

  if (requiredPermission && !hasPermission(user.value.role, requiredPermission)) {
    return navigateTo('/unauthorized');
  }
});
```

---

## 8. Модуль 1: Family Account & Identity

### Назначение
Точка входа. Связывает мать, отца, детей, врачей и клинику в одну цифровую структуру.

### User Stories

| ID | Роль | Story | Acceptance Criteria |
|----|------|-------|-------------------|
| FA-01 | Мать | Регистрация через email или телефон | Верификация через magic link или OTP. Профиль создан. Consent на обработку данных запрошен и сохранён. |
| FA-02 | Мать | Заполнение профиля | ФИО, дата рождения, телефон, email. Поля валидируются. |
| FA-03 | Мать | Добавление ребёнка | Имя, дата рождения, пол, данные о рождении (вес, рост, Apgar). Child profile создан. |
| FA-04 | Мать | Приглашение второго родителя | Генерация invite link / code. Второй родитель регистрируется и привязывается к family. |
| FA-05 | Second Parent | Принятие приглашения | Регистрация через invite code. Доступ к семейному кабинету. |
| FA-06 | Мать | Управление согласиями | Включение/отключение: push, WhatsApp, SMS, семейный доступ. Каждое согласие логируется. |
| FA-07 | Coordinator | Создание семьи вручную | При onboarding беременной. Заполняет профиль матери, срок, ПДР, врача. |
| FA-08 | Мать | Переключение между детьми | Если несколько детей — свайп или выпадающий список. Каждый ребёнок — отдельный маршрут. |

### Экраны

**Mobile (семья):**
- Регистрация → Верификация → Заполнение профиля → Consent → Dashboard
- Профиль семьи (мать, отец, дети)
- Настройки (язык, уведомления, согласия)
- Invite second parent

**Web (координатор):**
- Создание новой семьи
- Поиск семьи (по ФИО, телефону, ребёнку)
- Карточка семьи (все профили, маршруты, статусы)

### API (Supabase queries)

```typescript
// entities/family/api/index.ts

export async function createFamily(data: CreateFamilyInput) {
  const { data: family, error } = await supabase
    .from('families')
    .insert({
      clinic_id: useClinicId(),
      primary_user_id: data.userId,
      family_code: generateFamilyCode(),
    })
    .select()
    .single();

  if (error) throw error;
  return family;
}

export async function getFamily(familyId: string) {
  const { data, error } = await supabase
    .from('families')
    .select(`
      *,
      primary_user:users!primary_user_id(*),
      secondary_user:users!secondary_user_id(*),
      mother_profiles(*),
      child_profiles(*),
      journeys(id, journey_type, status)
    `)
    .eq('id', familyId)
    .single();

  if (error) throw error;
  return data;
}

export async function inviteSecondParent(familyId: string) {
  const code = generateInviteCode();
  const { error } = await supabase
    .from('families')
    .update({ family_code: code })
    .eq('id', familyId);

  if (error) throw error;
  return code;
}

export async function joinFamily(inviteCode: string, userId: string) {
  const { data: family, error: findError } = await supabase
    .from('families')
    .select('id')
    .eq('family_code', inviteCode)
    .single();

  if (findError) throw new Error('Invalid invite code');

  const { error } = await supabase
    .from('families')
    .update({
      secondary_user_id: userId,
      family_code: null, // invalidate code after use
    })
    .eq('id', family.id);

  if (error) throw error;
}
```

---

## 9. Модуль 2: Care Plan Engine

### Назначение
Сердце платформы. Генерирует персональный маршрут на основе срока беременности или возраста ребёнка. Знает, что должно произойти следующим. Создаёт события, дедлайны, overdue-логику.

### Как работает

1. При создании journey (pregnancy, postpartum, infant, toddler) engine загружает соответствующий **template**.
2. Template содержит массив событий с trigger logic (gestational week, child age in days, relative days from previous event).
3. Engine рассчитывает конкретные даты для каждого события на основе LMP/EDD (беременность) или DOB (ребёнок).
4. События создаются в `journey_events` со статусом `upcoming`.
5. Cron job (Edge Function) ежедневно проверяет: если `due_date` = today → status = `due`. Если `due_date` < today и status != `completed` → status = `overdue`.
6. При `overdue` создаётся coordinator_task и отправляется notification.

### Journey Templates

```typescript
// shared/config/journey-templates.ts

export const PREGNANCY_TEMPLATE: JourneyEventTemplate[] = [
  // ===== ПЕРВЫЙ ТРИМЕСТР =====
  {
    event_type: 'consultation',
    title: 'Первичный приём гинеколога',
    description: 'Постановка на учёт. Анамнез, осмотр, назначения.',
    trigger_type: 'gestational_week',
    trigger_week: 6,
    is_mandatory: true,
    sort_order: 1,
  },
  {
    event_type: 'lab_test',
    title: 'Общий анализ крови',
    description: 'ОАК развёрнутый',
    trigger_type: 'gestational_week',
    trigger_week: 7,
    is_mandatory: true,
    sort_order: 2,
  },
  {
    event_type: 'lab_test',
    title: 'Биохимия крови',
    description: 'Глюкоза, билирубин, АЛТ, АСТ, креатинин, мочевина',
    trigger_type: 'gestational_week',
    trigger_week: 7,
    is_mandatory: true,
    sort_order: 3,
  },
  {
    event_type: 'lab_test',
    title: 'Группа крови и резус-фактор',
    trigger_type: 'gestational_week',
    trigger_week: 7,
    is_mandatory: true,
    sort_order: 4,
  },
  {
    event_type: 'lab_test',
    title: 'Коагулограмма',
    trigger_type: 'gestational_week',
    trigger_week: 7,
    is_mandatory: true,
    sort_order: 5,
  },
  {
    event_type: 'lab_test',
    title: 'ОАМ (общий анализ мочи)',
    trigger_type: 'gestational_week',
    trigger_week: 7,
    is_mandatory: true,
    sort_order: 6,
  },
  {
    event_type: 'lab_test',
    title: 'TORCH-инфекции',
    description: 'Токсоплазма, краснуха, ЦМВ, герпес',
    trigger_type: 'gestational_week',
    trigger_week: 8,
    is_mandatory: true,
    sort_order: 7,
  },
  {
    event_type: 'lab_test',
    title: 'ВИЧ, гепатиты B/C, сифилис',
    trigger_type: 'gestational_week',
    trigger_week: 8,
    is_mandatory: true,
    sort_order: 8,
  },
  {
    event_type: 'screening',
    title: 'Первый скрининг (11-14 нед.)',
    description: 'УЗИ + биохимический скрининг (PAPP-A, свободный β-ХГЧ). Оценка риска хромосомных аномалий.',
    trigger_type: 'gestational_week',
    trigger_week: 12,
    is_mandatory: true,
    sort_order: 10,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём гинеколога (12 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 12,
    is_mandatory: true,
    sort_order: 11,
  },

  // ===== ВТОРОЙ ТРИМЕСТР =====
  {
    event_type: 'consultation',
    title: 'Плановый приём гинеколога (16 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 16,
    is_mandatory: true,
    sort_order: 20,
  },
  {
    event_type: 'screening',
    title: 'Второй скрининг (18-21 нед.)',
    description: 'УЗИ-скрининг анатомии плода. Оценка развития органов.',
    trigger_type: 'gestational_week',
    trigger_week: 20,
    is_mandatory: true,
    sort_order: 21,
  },
  {
    event_type: 'lab_test',
    title: 'ОАК (повторный)',
    trigger_type: 'gestational_week',
    trigger_week: 20,
    is_mandatory: true,
    sort_order: 22,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём гинеколога (20 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 20,
    is_mandatory: true,
    sort_order: 23,
  },
  {
    event_type: 'lab_test',
    title: 'Глюкозотолерантный тест (ГТТ)',
    description: 'Скрининг гестационного диабета (24-28 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 26,
    is_mandatory: true,
    sort_order: 25,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём гинеколога (24 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 24,
    is_mandatory: true,
    sort_order: 24,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём гинеколога (28 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 28,
    is_mandatory: true,
    sort_order: 26,
  },

  // ===== ТРЕТИЙ ТРИМЕСТР =====
  {
    event_type: 'lab_test',
    title: 'ОАК + коагулограмма (30 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 30,
    is_mandatory: true,
    sort_order: 30,
  },
  {
    event_type: 'lab_test',
    title: 'ВИЧ, гепатиты, сифилис (повторно)',
    trigger_type: 'gestational_week',
    trigger_week: 30,
    is_mandatory: true,
    sort_order: 31,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём (30 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 30,
    is_mandatory: true,
    sort_order: 32,
  },
  {
    event_type: 'screening',
    title: 'Третий скрининг (32-34 нед.)',
    description: 'УЗИ + допплерометрия. Оценка состояния плода, плаценты, вод.',
    trigger_type: 'gestational_week',
    trigger_week: 33,
    is_mandatory: true,
    sort_order: 33,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём (34 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 34,
    is_mandatory: true,
    sort_order: 34,
  },
  {
    event_type: 'consultation',
    title: 'Плановый приём (36 нед.)',
    description: 'Подготовка к родам. Обсуждение плана родов.',
    trigger_type: 'gestational_week',
    trigger_week: 36,
    is_mandatory: true,
    sort_order: 35,
  },
  {
    event_type: 'lab_test',
    title: 'Мазок на флору (36 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 36,
    is_mandatory: true,
    sort_order: 36,
  },
  {
    event_type: 'consultation',
    title: 'Еженедельный приём (37 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 37,
    is_mandatory: true,
    sort_order: 37,
  },
  {
    event_type: 'consultation',
    title: 'Еженедельный приём (38 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 38,
    is_mandatory: true,
    sort_order: 38,
  },
  {
    event_type: 'consultation',
    title: 'Еженедельный приём (39 нед.)',
    trigger_type: 'gestational_week',
    trigger_week: 39,
    is_mandatory: true,
    sort_order: 39,
  },
  {
    event_type: 'consultation',
    title: 'Еженедельный приём (40 нед.)',
    description: 'Оценка готовности к родам. КТГ.',
    trigger_type: 'gestational_week',
    trigger_week: 40,
    is_mandatory: true,
    sort_order: 40,
  },
];

// Казахстанский национальный календарь вакцинации (0-2 года)
export const KZ_VACCINATION_SCHEDULE: VaccinationTemplate[] = [
  { vaccine_code: 'BCG', vaccine_name: 'БЦЖ', dose_number: 1, trigger_age_days: 1, description: 'Вакцина против туберкулёза' },
  { vaccine_code: 'HepB', vaccine_name: 'Гепатит B', dose_number: 1, trigger_age_days: 1, description: '1-я доза в первые 24 часа' },
  { vaccine_code: 'HepB', vaccine_name: 'Гепатит B', dose_number: 2, trigger_age_days: 60, description: '2-я доза (2 мес.)' },
  { vaccine_code: 'DTP-HepB-Hib', vaccine_name: 'АКДС-ГепB-Хиб', dose_number: 1, trigger_age_days: 60, description: 'Пентавакцина, 1-я доза (2 мес.)' },
  { vaccine_code: 'IPV', vaccine_name: 'ИПВ (полиомиелит)', dose_number: 1, trigger_age_days: 60, description: 'Инактивированная полиовакцина (2 мес.)' },
  { vaccine_code: 'PCV13', vaccine_name: 'Пневмококковая', dose_number: 1, trigger_age_days: 60, description: 'Превенар 13, 1-я доза (2 мес.)' },
  { vaccine_code: 'DTP-HepB-Hib', vaccine_name: 'АКДС-ГепB-Хиб', dose_number: 2, trigger_age_days: 90, description: 'Пентавакцина, 2-я доза (3 мес.)' },
  { vaccine_code: 'IPV', vaccine_name: 'ИПВ (полиомиелит)', dose_number: 2, trigger_age_days: 90, description: 'ИПВ, 2-я доза (3 мес.)' },
  { vaccine_code: 'DTP-HepB-Hib', vaccine_name: 'АКДС-ГепB-Хиб', dose_number: 3, trigger_age_days: 120, description: 'Пентавакцина, 3-я доза (4 мес.)' },
  { vaccine_code: 'IPV', vaccine_name: 'ИПВ (полиомиелит)', dose_number: 3, trigger_age_days: 120, description: 'ИПВ, 3-я доза (4 мес.)' },
  { vaccine_code: 'PCV13', vaccine_name: 'Пневмококковая', dose_number: 2, trigger_age_days: 120, description: 'Превенар 13, 2-я доза (4 мес.)' },
  { vaccine_code: 'MMR', vaccine_name: 'КПК (корь, паротит, краснуха)', dose_number: 1, trigger_age_days: 365, description: '1-я доза (12 мес.)' },
  { vaccine_code: 'PCV13', vaccine_name: 'Пневмококковая', dose_number: 3, trigger_age_days: 365, description: 'Превенар 13, ревакцинация (12 мес.)' },
  { vaccine_code: 'DTP', vaccine_name: 'АКДС', dose_number: 4, trigger_age_days: 540, description: 'Ревакцинация (18 мес.)' },
  { vaccine_code: 'OPV', vaccine_name: 'ОПВ (полиомиелит)', dose_number: 4, trigger_age_days: 540, description: 'Оральная полиовакцина, ревакцинация (18 мес.)' },
];

// Первый год: педиатрические осмотры
export const INFANT_CHECKUP_TEMPLATE: JourneyEventTemplate[] = [
  { event_type: 'checkup', title: 'Осмотр неонатолога (выписка)', trigger_type: 'child_age_days', trigger_value: 3, is_mandatory: true, sort_order: 1 },
  { event_type: 'checkup', title: 'Патронаж на дому (1-я неделя)', trigger_type: 'child_age_days', trigger_value: 7, is_mandatory: true, sort_order: 2 },
  { event_type: 'checkup', title: 'Патронаж на дому (2-я неделя)', trigger_type: 'child_age_days', trigger_value: 14, is_mandatory: true, sort_order: 3 },
  { event_type: 'checkup', title: 'Осмотр педиатра (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 4 },
  { event_type: 'specialist_referral', title: 'Невролог (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 5 },
  { event_type: 'specialist_referral', title: 'Ортопед (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 6 },
  { event_type: 'specialist_referral', title: 'Окулист (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 7 },
  { event_type: 'ultrasound', title: 'УЗИ головного мозга (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 8 },
  { event_type: 'ultrasound', title: 'УЗИ тазобедренных суставов (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 9 },
  { event_type: 'ultrasound', title: 'УЗИ органов брюшной полости (1 мес.)', trigger_type: 'child_age_days', trigger_value: 30, is_mandatory: true, sort_order: 10 },
  { event_type: 'checkup', title: 'Осмотр педиатра (2 мес.)', trigger_type: 'child_age_days', trigger_value: 60, is_mandatory: true, sort_order: 11 },
  { event_type: 'checkup', title: 'Осмотр педиатра (3 мес.)', trigger_type: 'child_age_days', trigger_value: 90, is_mandatory: true, sort_order: 12 },
  { event_type: 'specialist_referral', title: 'Невролог (3 мес.)', trigger_type: 'child_age_days', trigger_value: 90, is_mandatory: true, sort_order: 13 },
  { event_type: 'checkup', title: 'Осмотр педиатра (4 мес.)', trigger_type: 'child_age_days', trigger_value: 120, is_mandatory: true, sort_order: 14 },
  { event_type: 'checkup', title: 'Осмотр педиатра (5 мес.)', trigger_type: 'child_age_days', trigger_value: 150, is_mandatory: true, sort_order: 15 },
  { event_type: 'checkup', title: 'Осмотр педиатра (6 мес.)', trigger_type: 'child_age_days', trigger_value: 180, is_mandatory: true, sort_order: 16 },
  { event_type: 'specialist_referral', title: 'Невролог (6 мес.)', trigger_type: 'child_age_days', trigger_value: 180, is_mandatory: true, sort_order: 17 },
  { event_type: 'lab_test', title: 'ОАК (6 мес.)', trigger_type: 'child_age_days', trigger_value: 180, is_mandatory: true, sort_order: 18 },
  { event_type: 'checkup', title: 'Осмотр педиатра (7 мес.)', trigger_type: 'child_age_days', trigger_value: 210, is_mandatory: true, sort_order: 19 },
  { event_type: 'checkup', title: 'Осмотр педиатра (8 мес.)', trigger_type: 'child_age_days', trigger_value: 240, is_mandatory: true, sort_order: 20 },
  { event_type: 'checkup', title: 'Осмотр педиатра (9 мес.)', trigger_type: 'child_age_days', trigger_value: 270, is_mandatory: true, sort_order: 21 },
  { event_type: 'specialist_referral', title: 'Невролог (9 мес.)', trigger_type: 'child_age_days', trigger_value: 270, is_mandatory: true, sort_order: 22 },
  { event_type: 'checkup', title: 'Осмотр педиатра (10 мес.)', trigger_type: 'child_age_days', trigger_value: 300, is_mandatory: true, sort_order: 23 },
  { event_type: 'checkup', title: 'Осмотр педиатра (11 мес.)', trigger_type: 'child_age_days', trigger_value: 330, is_mandatory: true, sort_order: 24 },
  { event_type: 'checkup', title: 'Осмотр педиатра (12 мес.)', trigger_type: 'child_age_days', trigger_value: 365, is_mandatory: true, sort_order: 25 },
  { event_type: 'specialist_referral', title: 'Невролог (12 мес.)', trigger_type: 'child_age_days', trigger_value: 365, is_mandatory: true, sort_order: 26 },
  { event_type: 'specialist_referral', title: 'Окулист (12 мес.)', trigger_type: 'child_age_days', trigger_value: 365, is_mandatory: true, sort_order: 27 },
  { event_type: 'specialist_referral', title: 'Ортопед (12 мес.)', trigger_type: 'child_age_days', trigger_value: 365, is_mandatory: true, sort_order: 28 },
  { event_type: 'lab_test', title: 'ОАК (12 мес.)', trigger_type: 'child_age_days', trigger_value: 365, is_mandatory: true, sort_order: 29 },
];

// Второй год: осмотры каждые 3 месяца + специалисты
export const TODDLER_CHECKUP_TEMPLATE: JourneyEventTemplate[] = [
  { event_type: 'checkup', title: 'Осмотр педиатра (15 мес.)', trigger_type: 'child_age_days', trigger_value: 450, is_mandatory: true, sort_order: 1 },
  { event_type: 'checkup', title: 'Осмотр педиатра (18 мес.)', trigger_type: 'child_age_days', trigger_value: 540, is_mandatory: true, sort_order: 2 },
  { event_type: 'specialist_referral', title: 'Невролог (18 мес.)', trigger_type: 'child_age_days', trigger_value: 540, is_mandatory: true, sort_order: 3 },
  { event_type: 'specialist_referral', title: 'Стоматолог (18 мес.)', trigger_type: 'child_age_days', trigger_value: 540, is_mandatory: false, sort_order: 4 },
  { event_type: 'checkup', title: 'Осмотр педиатра (21 мес.)', trigger_type: 'child_age_days', trigger_value: 630, is_mandatory: true, sort_order: 5 },
  { event_type: 'checkup', title: 'Осмотр педиатра (24 мес.)', trigger_type: 'child_age_days', trigger_value: 730, is_mandatory: true, sort_order: 6 },
  { event_type: 'specialist_referral', title: 'Невролог (24 мес.)', trigger_type: 'child_age_days', trigger_value: 730, is_mandatory: true, sort_order: 7 },
  { event_type: 'specialist_referral', title: 'Окулист (24 мес.)', trigger_type: 'child_age_days', trigger_value: 730, is_mandatory: true, sort_order: 8 },
  { event_type: 'specialist_referral', title: 'Стоматолог (24 мес.)', trigger_type: 'child_age_days', trigger_value: 730, is_mandatory: true, sort_order: 9 },
  { event_type: 'lab_test', title: 'ОАК + ОАМ (24 мес.)', trigger_type: 'child_age_days', trigger_value: 730, is_mandatory: true, sort_order: 10 },
  { event_type: 'milestone_check', title: 'Оценка развития речи (24 мес.)', trigger_type: 'child_age_days', trigger_value: 730, is_mandatory: true, sort_order: 11 },
];
```

### Edge Function: Care Plan Generator

```typescript
// supabase/functions/generate-care-plan/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { addDays, addWeeks } from 'https://esm.sh/date-fns@3';

serve(async (req) => {
  const { journey_id } = await req.json();

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Get journey with patient data
  const { data: journey } = await supabase
    .from('journeys')
    .select('*, family:families(*)')
    .eq('id', journey_id)
    .single();

  if (!journey) return new Response('Journey not found', { status: 404 });

  let template: any[];
  let referenceDate: Date;

  switch (journey.journey_type) {
    case 'pregnancy': {
      const { data: mother } = await supabase
        .from('mother_profiles')
        .select('*')
        .eq('id', journey.patient_id)
        .single();
      template = PREGNANCY_TEMPLATE;
      // Calculate LMP from current gestational age or use stored LMP
      const lmp = new Date(mother.current_pregnancy.lmp);
      referenceDate = lmp;
      break;
    }
    case 'infant':
    case 'toddler': {
      const { data: child } = await supabase
        .from('child_profiles')
        .select('*')
        .eq('id', journey.patient_id)
        .single();
      template = journey.journey_type === 'infant'
        ? INFANT_CHECKUP_TEMPLATE
        : TODDLER_CHECKUP_TEMPLATE;
      referenceDate = new Date(child.date_of_birth);
      break;
    }
    default:
      return new Response('Unknown journey type', { status: 400 });
  }

  // Generate events from template
  const events = template.map(t => {
    let dueDate: Date;

    if (t.trigger_type === 'gestational_week') {
      // LMP + trigger_week * 7 days
      dueDate = addDays(referenceDate, t.trigger_week * 7);
    } else if (t.trigger_type === 'child_age_days') {
      dueDate = addDays(referenceDate, t.trigger_value);
    } else {
      dueDate = addDays(new Date(), t.trigger_value || 0);
    }

    return {
      journey_id: journey.id,
      clinic_id: journey.clinic_id,
      family_id: journey.family_id,
      event_type: t.event_type,
      title: t.title,
      description: t.description || null,
      status: dueDate <= new Date() ? 'due' : 'upcoming',
      due_date: dueDate.toISOString().split('T')[0],
      week_number: t.trigger_week || Math.floor(t.trigger_value / 7),
      is_mandatory: t.is_mandatory,
      sort_order: t.sort_order,
    };
  });

  const { error } = await supabase
    .from('journey_events')
    .insert(events);

  if (error) return new Response(JSON.stringify(error), { status: 500 });

  // Also generate vaccination events if infant/toddler
  if (['infant', 'toddler'].includes(journey.journey_type)) {
    const vaccinations = KZ_VACCINATION_SCHEDULE
      .filter(v => {
        const ageRange = journey.journey_type === 'infant'
          ? { min: 0, max: 365 }
          : { min: 366, max: 730 };
        return v.trigger_age_days >= ageRange.min && v.trigger_age_days <= ageRange.max;
      })
      .map(v => ({
        clinic_id: journey.clinic_id,
        child_id: journey.patient_id,
        family_id: journey.family_id,
        vaccine_name: v.vaccine_name,
        vaccine_code: v.vaccine_code,
        dose_number: v.dose_number,
        scheduled_date: addDays(referenceDate, v.trigger_age_days).toISOString().split('T')[0],
        status: 'scheduled',
      }));

    await supabase.from('vaccinations').insert(vaccinations);
  }

  return new Response(JSON.stringify({ events_created: events.length }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

### Edge Function: Daily Status Checker (Cron)

```typescript
// supabase/functions/daily-status-check/index.ts
// Runs daily at 06:00 Almaty time via Supabase cron

serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  const today = new Date().toISOString().split('T')[0];

  // 1. Mark due events
  await supabase
    .from('journey_events')
    .update({ status: 'due' })
    .eq('status', 'upcoming')
    .lte('due_date', today);

  // 2. Mark overdue events (due_date < today and not completed)
  const { data: newOverdue } = await supabase
    .from('journey_events')
    .update({ status: 'overdue' })
    .eq('status', 'due')
    .lt('due_date', today)
    .select('id, family_id, clinic_id, title');

  // 3. Create coordinator tasks for overdue
  if (newOverdue?.length) {
    const tasks = newOverdue.map(event => ({
      clinic_id: event.clinic_id,
      family_id: event.family_id,
      task_type: 'overdue_followup',
      title: `Просрочено: ${event.title}`,
      description: `Событие маршрута просрочено. Свяжитесь с семьёй.`,
      priority: 3,
      related_entity_type: 'journey_event',
      related_entity_id: event.id,
    }));

    await supabase.from('coordinator_tasks').insert(tasks);
  }

  // 4. Mark missed doses (scheduled for yesterday, still pending)
  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
  await supabase
    .from('dose_logs')
    .update({ status: 'missed' })
    .eq('status', 'pending')
    .lt('scheduled_date', today);

  // 5. Generate today's dose logs for active prescriptions
  const { data: activePrescriptions } = await supabase
    .from('prescriptions')
    .select('*')
    .eq('is_active', true)
    .lte('start_date', today)
    .or(`end_date.is.null,end_date.gte.${today}`);

  if (activePrescriptions?.length) {
    const newDoses = [];
    for (const rx of activePrescriptions) {
      // Check if doses already exist for today
      const { count } = await supabase
        .from('dose_logs')
        .select('*', { count: 'exact', head: true })
        .eq('prescription_id', rx.id)
        .eq('scheduled_date', today);

      if (count === 0 && rx.time_slots?.length) {
        for (const time of rx.time_slots) {
          newDoses.push({
            prescription_id: rx.id,
            clinic_id: rx.clinic_id,
            family_id: rx.family_id,
            scheduled_date: today,
            scheduled_time: time,
            status: 'pending',
          });
        }
      }
    }

    if (newDoses.length) {
      await supabase.from('dose_logs').insert(newDoses);
    }
  }

  // 6. Send vaccination reminders (3 days before)
  const reminderDate = new Date(Date.now() + 3 * 86400000).toISOString().split('T')[0];
  const { data: upcomingVax } = await supabase
    .from('vaccinations')
    .select('*, family:families(primary_user_id)')
    .eq('scheduled_date', reminderDate)
    .eq('status', 'scheduled')
    .eq('reminder_sent', false);

  if (upcomingVax?.length) {
    for (const vax of upcomingVax) {
      await supabase.from('notifications').insert({
        clinic_id: vax.clinic_id,
        user_id: vax.family.primary_user_id,
        family_id: vax.family_id,
        channel: 'push',
        title: 'Напоминание о вакцинации',
        body: `${vax.vaccine_name} запланирована на ${vax.scheduled_date}. Запишитесь на приём.`,
        data: { type: 'vaccination', id: vax.id },
        related_entity_type: 'vaccination',
        related_entity_id: vax.id,
      });

      await supabase.from('vaccinations')
        .update({ reminder_sent: true })
        .eq('id', vax.id);
    }
  }

  return new Response(JSON.stringify({
    overdue_events: newOverdue?.length || 0,
    doses_generated: 'done',
    vaccination_reminders: upcomingVax?.length || 0,
  }));
});
```

Документ продолжается далее. Разделы 10-28 охватывают все оставшиеся модули, процессы, интеграции, тестирование и деплой. Добавляю в тот же файл.

---

## 10. Модуль 3: Timeline & Journey Dashboard

### Назначение
Главный экран семьи. Отвечает на вопрос: «Где я сейчас и что дальше?»

### Экран состоит из

1. **Journey Progress Bar** — визуальная полоса прогресса маршрута (% выполненных событий)
2. **Current Stage Badge** — "15-я неделя беременности" или "Ребёнку 4 мес. 12 дней"
3. **Next Action Card** — самое важное ближайшее событие с кнопкой действия (записаться / подтвердить / загрузить)
4. **Overdue Alerts** — красные карточки просроченных событий (если есть)
5. **Today's Prescriptions** — список дз назначений на сегодня
6. **Upcoming Events** — ближайшие 5 событий маршрута
7. **Recent Documents** — последние загруженные документы

### Composable

```typescript
// features/journey/composables/useTimeline.ts

export function useTimeline(familyId: Ref<string>) {
  const journey = ref<Journey | null>(null);
  const events = ref<JourneyEvent[]>([]);
  const todayDoses = ref<DoseLog[]>([]);
  const nextAppointment = ref<Appointment | null>(null);

  const overdueEvents = computed(() =>
    events.value.filter(e => e.status === 'overdue')
  );

  const upcomingEvents = computed(() =>
    events.value
      .filter(e => ['upcoming', 'due'].includes(e.status))
      .sort((a, b) => new Date(a.due_date).getTime() - new Date(b.due_date).getTime())
      .slice(0, 5)
  );

  const progressPercent = computed(() => {
    const total = events.value.filter(e => e.is_mandatory).length;
    const done = events.value.filter(e => e.status === 'completed' && e.is_mandatory).length;
    return total > 0 ? Math.round((done / total) * 100) : 0;
  });

  const currentStage = computed(() => {
    if (!journey.value) return '';
    if (journey.value.journey_type === 'pregnancy') {
      const lmp = new Date(journey.value.metadata?.lmp);
      const weeks = Math.floor((Date.now() - lmp.getTime()) / (7 * 86400000));
      const days = Math.floor((Date.now() - lmp.getTime()) / 86400000) % 7;
      return `${weeks} нед. ${days} дн.`;
    } else {
      const dob = new Date(journey.value.metadata?.dob);
      const totalDays = Math.floor((Date.now() - dob.getTime()) / 86400000);
      const months = Math.floor(totalDays / 30);
      const days = totalDays % 30;
      return `${months} мес. ${days} дн.`;
    }
  });

  // Real-time subscription
  const channel = supabase
    .channel(`journey-${familyId.value}`)
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'journey_events',
      filter: `family_id=eq.${familyId.value}`,
    }, (payload) => {
      // Update local state
      refreshEvents();
    })
    .subscribe();

  async function refreshEvents() {
    const { data } = await supabase
      .from('journey_events')
      .select('*')
      .eq('family_id', familyId.value)
      .order('due_date', { ascending: true });
    events.value = data || [];
  }

  onMounted(() => refreshEvents());
  onUnmounted(() => supabase.removeChannel(channel));

  return {
    journey, events, todayDoses, nextAppointment,
    overdueEvents, upcomingEvents, progressPercent, currentStage,
    refreshEvents,
  };
}
```

---

## 11. Модуль 4: Smart Appointments

### User Stories

| ID | Story | Критерии |
|----|-------|---------|
| AP-01 | Мать записывается на приём из события маршрута | Клик на событие → выбор врача → выбор слота → подтверждение |
| AP-02 | Мать переносит запись | Выбор нового слота, старый освобождается, уведомление координатору |
| AP-03 | Мать отменяет запись | Причина отмены, уведомление координатору, событие маршрута возвращается в status=due |
| AP-04 | Система напоминает за 24ч и 2ч | Push + WhatsApp (если consent) |
| AP-05 | Координатор видит no-show | Если прошло время и нет отметки completed → статус no_show → задача координатору |
| AP-06 | Предвизитная анкета | За 24ч до визита мать получает push с просьбой заполнить жалобы и вопросы врачу |

### Слоты расписания

На MVP расписание не интегрировано с МИС. Координатор вручную управляет доступными слотами или импортирует CSV.

```sql
CREATE TABLE appointment_slots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id uuid NOT NULL REFERENCES clinics(id),
  doctor_id uuid NOT NULL REFERENCES users(id),
  slot_date date NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  is_available boolean DEFAULT true,
  appointment_id uuid REFERENCES appointments(id), -- null if free
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_slots_doctor_date ON appointment_slots(doctor_id, slot_date);
CREATE INDEX idx_slots_available ON appointment_slots(is_available) WHERE is_available = true;
```

---

## 12. Модуль 5: Laboratory & Medical Archive

### Функционал

- Загрузка документов: фото (camera), PDF, изображения
- Категоризация: lab_result, ultrasound, screening, prescription_photo, discharge_summary, vaccination_card, certificate
- Привязка к маршруту и врачу
- Поиск и фильтрация по типу, дате, тегам
- Превью документов в приложении
- Экспорт и sharing (PDF generation)

### Storage Structure

```
medical-documents/
  {clinic_id}/
    {family_id}/
      {patient_id}/
        {document_id}_{timestamp}.{ext}
```

### Upload Flow

```typescript
// features/records/upload/useUploadDocument.ts

export function useUploadDocument() {
  const uploading = ref(false);
  const progress = ref(0);

  async function upload(file: File, metadata: DocumentMetadata) {
    uploading.value = true;
    const familyId = useFamilyId();
    const clinicId = useClinicId();

    const filePath = `${clinicId}/${familyId}/${metadata.patient_id}/${crypto.randomUUID()}_${Date.now()}.${file.name.split('.').pop()}`;

    // Upload to Supabase Storage
    const { error: uploadError } = await supabase.storage
      .from('medical-documents')
      .upload(filePath, file, {
        contentType: file.type,
        upsert: false,
      });

    if (uploadError) throw uploadError;

    // Create document record
    const { data, error } = await supabase
      .from('documents')
      .insert({
        clinic_id: clinicId,
        family_id: familyId,
        patient_type: metadata.patient_type,
        patient_id: metadata.patient_id,
        journey_id: metadata.journey_id,
        document_type: metadata.document_type,
        title: metadata.title,
        description: metadata.description,
        file_path: filePath,
        file_size_bytes: file.size,
        mime_type: file.type,
        uploaded_by: useCurrentUser().value.id,
        document_date: metadata.document_date,
        tags: metadata.tags,
      })
      .select()
      .single();

    uploading.value = false;
    return data;
  }

  return { upload, uploading, progress };
}
```

---

## 13. Модуль 6: Smart Prescriptions

### Самый важный everyday-use модуль

Обеспечивает daily engagement. Мать открывает приложение каждый день, чтобы подтвердить приём витаминов/лекарств.

### UX Flow

1. Врач/координатор создаёт назначение: препарат, дозировка, частота, время, длительность
2. Система генерирует dose_logs на каждый день
3. В указанное время — push notification: "Время принять Фолиевую кислоту 400 мкг"
4. Мать свайпает → статус "taken" с timestamp
5. Если не подтвердила в течение 2 часов после scheduled_time → повторный push
6. Если не подтвердила до конца дня → status = "missed"
7. При 3+ пропусках подряд → задача координатору

### Экран

**Daily Prescription Card:**
```
┌─────────────────────────────────────┐
│  ☀️ Утро (08:00)                     │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ 💊 Фолиевая кислота 400 мкг  │  │
│  │    После еды                  │  │
│  │    [ ✓ Принято ] [ ✕ Пропуск ]│  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ 💊 Витамин D3 2000 МЕ        │  │
│  │    С едой                     │  │
│  │    [ ✓ Принято ] [ ✕ Пропуск ]│  │
│  └───────────────────────────────┘  │
│                                     │
│  🌙 Вечер (20:00)                   │
│  ┌───────────────────────────────┐  │
│  │ 💊 Магний B6                  │  │
│  │    300 мг, после еды          │  │
│  │    ⏰ Напоминание в 20:00     │  │
│  └───────────────────────────────┘  │
│                                     │
│  Adherence: 87% за последние 7 дней │
└─────────────────────────────────────┘
```

### Adherence Calculation

```typescript
// entities/prescription/model/adherence.ts

export function calculateAdherence(
  doseLogs: DoseLog[],
  days: number = 7
): number {
  const cutoff = subDays(new Date(), days);
  const recentLogs = doseLogs.filter(
    d => new Date(d.scheduled_date) >= cutoff
  );

  if (recentLogs.length === 0) return 100;

  const taken = recentLogs.filter(d => d.status === 'taken').length;
  return Math.round((taken / recentLogs.length) * 100);
}
```

---

## 14. Модуль 7: Vaccination & Check-up Calendar

### Функционал

- Визуальный календарь вакцинаций по национальному календарю Казахстана
- Статусы: scheduled, completed, skipped, postponed
- Напоминания: push за 3 дня, WhatsApp за 1 день
- Отметка вакцинации координатором/педиатром с записью batch number
- История вакцинаций с возможностью экспорта

### UI: Vaccination Timeline

Вертикальный список по возрасту ребёнка. Каждая группа (2 мес., 3 мес., 4 мес.) — отдельный блок. Внутри блока — карточки вакцин с чипами статуса.

---

## 15. Модуль 8: Coordinator Panel

### Самый важный модуль для клиники

Без coordinator panel платформа — просто приложение для мам. С ним — operational tool удержания.

### Dashboard состоит из

1. **KPI-карточки вверху**: Активных семей, Overdue сегодня, Adherence средний, Конверсия за месяц
2. **Очередь задач** — отсортированная по приоритету
3. **Семьи с overdue** — список с фильтрами по типу overdue
4. **Семьи с низким adherence** — <70% за 7 дней
5. **Upcoming vaccinations** — вакцинации на этой неделе
6. **Семьи для reactivation** — не открывали приложение >14 дней

### Task Types и приоритеты

| Task Type | Приоритет | Auto-created | Действие координатора |
|-----------|----------|-------------|---------------------|
| overdue_followup | 3 (высокий) | Да, при overdue event | Позвонить/написать семье, записать на визит |
| missed_appointment | 2 (очень высокий) | Да, при no_show | Перезаписать, выяснить причину |
| low_adherence | 4 (средний) | Да, при adherence <50% | Позвонить, объяснить важность |
| vaccination_reminder | 3 | Да, за 3 дня до вакцинации | Подтвердить запись, напомнить |
| welcome_call | 5 (низкий) | Да, при onboarding | Приветственный звонок новой семье |
| reactivation | 4 | Да, при inactive >14 дней | Вернуть семью в маршрут |
| custom | Задаётся | Нет, вручную | Любое |

---

## 16. Модуль 9: Messaging & Notifications

### Каналы

| Канал | Когда | Библиотека/API |
|-------|-------|---------------|
| Push | Все напоминания, overdue, events | FCM через Capacitor |
| WhatsApp | Важные: вакцинации, missed appointments, weekly digest | Meta Cloud API |
| In-app | Все сообщения дублируются | Supabase Realtime |
| SMS | Fallback если нет push consent | Mobizon или Twilio |
| Email | Только: регистрация, reset password, monthly report | Resend |

### Notification Templates

```typescript
// shared/config/notification-templates.ts

export const TEMPLATES = {
  // Prescriptions
  DOSE_REMINDER: {
    push: {
      title: 'Время принять лекарство',
      body: '💊 {{prescription_name}} {{dosage}}. {{instructions}}',
    },
  },
  DOSE_MISSED: {
    push: {
      title: 'Пропущен приём',
      body: 'Вы не отметили приём {{prescription_name}}. Примите при первой возможности.',
    },
  },

  // Appointments
  APPOINTMENT_REMINDER_24H: {
    push: {
      title: 'Завтра визит к врачу',
      body: '📋 {{appointment_type}} у {{doctor_name}}, {{time}}. Заполните анкету перед визитом.',
    },
    whatsapp: {
      body: 'Здравствуйте, {{parent_name}}! Напоминаем о визите завтра в {{time}} к {{doctor_name}} ({{appointment_type}}). Если нужно перенести — ответьте на это сообщение.',
    },
  },
  APPOINTMENT_REMINDER_2H: {
    push: {
      title: 'Визит через 2 часа',
      body: '⏰ {{appointment_type}} у {{doctor_name}} в {{time}}',
    },
  },

  // Journey events
  EVENT_DUE: {
    push: {
      title: 'Пора на {{event_type}}',
      body: '📌 {{event_title}}. Запишитесь на приём.',
    },
  },
  EVENT_OVERDUE: {
    push: {
      title: 'Просрочено: {{event_title}}',
      body: '⚠️ Запишитесь как можно скорее. Это важно для здоровья.',
    },
  },

  // Vaccination
  VACCINATION_REMINDER: {
    push: {
      title: 'Вакцинация через 3 дня',
      body: '💉 {{vaccine_name}} запланирована на {{date}}. Запишитесь на приём.',
    },
    whatsapp: {
      body: 'Здравствуйте! Напоминаем: {{vaccine_name}} для {{child_name}} запланирована на {{date}}. Для записи ответьте на это сообщение или запишитесь в приложении.',
    },
  },

  // Coordinator
  WELCOME: {
    push: {
      title: 'Добро пожаловать в {{clinic_name}}!',
      body: 'Ваш персональный маршрут настроен. Откройте приложение, чтобы увидеть план.',
    },
  },
};
```

### WhatsApp Integration

```typescript
// supabase/functions/send-whatsapp/index.ts

serve(async (req) => {
  const { phone, template, params } = await req.json();

  const response = await fetch(
    `https://graph.facebook.com/v19.0/${Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')}/messages`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('WHATSAPP_TOKEN')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        messaging_product: 'whatsapp',
        to: phone,
        type: 'template',
        template: {
          name: template,
          language: { code: 'ru' },
          components: [{
            type: 'body',
            parameters: params.map((p: string) => ({ type: 'text', text: p })),
          }],
        },
      }),
    }
  );

  const data = await response.json();
  return new Response(JSON.stringify(data));
});
```

---

## 17. Модуль 10: Clinic Analytics (базовый)

### MVP метрики

| Метрика | Формула | Визуализация |
|---------|---------|-------------|
| Active Families | Семьи с хотя бы 1 action за 30 дней | Число + тренд |
| Journey Completion Rate | Completed events / Total mandatory events | Процент + bar |
| Prescription Adherence | Avg adherence по всем семьям | Процент + тренд |
| Repeat Visit Rate | Семьи с >1 appointment за 30 дней / Total | Процент |
| Pregnancy→Postpartum Conversion | Семьи перешедшие в postpartum / Семьи завершившие pregnancy | Процент |
| Overdue Rate | Events overdue / Total due | Процент (lower = better) |
| No-Show Rate | No-show appointments / Total appointments | Процент |

### SQL Views для аналитики

```sql
CREATE VIEW v_clinic_dashboard AS
SELECT
  c.id as clinic_id,
  c.name as clinic_name,
  (SELECT count(*) FROM families f WHERE f.clinic_id = c.id AND f.status = 'active') as active_families,
  (SELECT count(*) FROM journey_events je WHERE je.clinic_id = c.id AND je.status = 'overdue') as overdue_events,
  (SELECT count(*) FROM coordinator_tasks ct WHERE ct.clinic_id = c.id AND ct.status = 'open') as open_tasks,
  (SELECT count(*) FROM appointments a WHERE a.clinic_id = c.id AND a.scheduled_date = CURRENT_DATE) as today_appointments
FROM clinics c
WHERE c.is_active = true;
```

---

## 18. Модуль 11: Admin & Configuration

### Функционал MVP

- Управление пользователями (CRUD staff users)
- Управление journey templates (просмотр, кастомизация)
- Настройки клиники (branding, timezone, languages)
- Управление справочниками врачей
- Импорт/экспорт семей (CSV)

---

## 19. Бизнес-процессы: полная карта

### BP-01: Подключение клиники (platform admin)

```
1. Platform admin создаёт запись в clinics
2. Настраивает theme (logo, цвета)
3. Создаёт clinic_admin user
4. Clinic admin логинится, настраивает:
   - Справочник врачей
   - Journey templates (или использует default)
   - Координаторов
   - Слоты расписания
5. Soft launch: первые 5-10 семей
```

### BP-02: Onboarding беременной

```
Триггер: Постановка на учёт в клинике

1. Координатор создаёт Family + Mother Profile
   - ФИО, телефон, email, дата рождения
   - LMP (дата последней менструации) → система рассчитывает EDD (ПДР)
   - Назначенный врач
   - Пакет услуг (если есть)

2. Система автоматически:
   - Создаёт Journey (type=pregnancy)
   - Вызывает Care Plan Engine → генерирует events
   - Отправляет SMS/WhatsApp с приглашением скачать приложение

3. Мать регистрируется в приложении:
   - Magic link или OTP
   - Consent на обработку данных
   - Видит свой timeline с маршрутом

4. Координатор выполняет welcome_call task
```

### BP-03: Ведение беременности

```
Ежедневный цикл:
1. 06:00 — cron job проверяет статусы событий
2. Events с due_date = today → status = 'due' → push notification
3. Мать видит на dashboard: "Сегодня: ОАК (7 нед.)" → кнопка "Записаться"
4. Мать записывается → appointment создан → push за 24ч и 2ч
5. После визита мать загружает результат анализа → document привязан к event
6. Мать отмечает event как completed
7. Если не completed в срок → status = overdue → coordinator task

Ежедневный цикл назначений:
1. Cron генерирует dose_logs на сегодня
2. В scheduled_time — push: "Время принять Фолиевую кислоту"
3. Мать свайпает → taken/skipped
4. Если не подтвердила за 2ч → повторный push
5. Конец дня → неподтверждённые → missed
```

### BP-04: Переход из беременности в роды → postpartum

```
Триггер: Роды произошли

1. Координатор фиксирует:
   - Дата и время родов
   - Тип (естественные / КС)
   - Данные ребёнка: вес, рост, Apgar, пол, имя

2. Система автоматически:
   - Завершает pregnancy journey (status=completed)
   - Создаёт child_profile
   - Создаёт postpartum journey для матери
   - Создаёт infant journey для ребёнка
   - Генерирует events для обоих маршрутов
   - Генерирует vaccinations по нацкалендарю
   - Создаёт default prescriptions (Витамин D3 для ребёнка)
   - Уведомляет мать: "Поздравляем! Маршрут ребёнка создан."
```

### BP-05: Первый год ребёнка

```
1. Ежемесячные осмотры педиатра (events из infant template)
2. Вакцинации по календарю (2, 3, 4, 12 мес.)
3. Специалисты: невролог (1, 3, 6, 9, 12 мес.), окулист, ортопед
4. УЗИ: головной мозг, тазобедренные суставы, брюшная полость (1 мес.)
5. Ежедневные назначения: Витамин D3
6. При overdue: coordinator outreach
```

### BP-06: Второй год ребёнка

```
1. Осмотры педиатра каждые 3 месяца
2. Ревакцинация: АКДС + ОПВ (18 мес.)
3. Специалисты: невролог, окулист, стоматолог (18, 24 мес.)
4. Milestone check: речь, моторика (24 мес.)
5. При завершении 24 мес. → journey completed → архивирование или переход (Phase 2)
```

### BP-07: Эскалация тревожного симптома (MVP-lite)

```
MVP: Без AI и Red Flag Navigator.

1. Мать отмечает в symptom journal: "Высокая температура", "Кровотечение"
2. Push координатору: "Семья [X] отметила тревожный симптом"
3. Координатор связывается с семьёй
4. При необходимости — срочная запись к врачу

Phase 2: Structured triage flow с уточняющими вопросами и auto-routing.
```

---

## 20. API-контракты и Edge Functions

### Edge Functions (Deno)

| Function | Trigger | Что делает |
|----------|---------|-----------|
| `generate-care-plan` | HTTP POST | Генерирует events по template для нового journey |
| `daily-status-check` | Cron (06:00 daily) | Обновляет статусы, создаёт задачи, генерирует dose_logs |
| `send-notification` | HTTP POST / DB webhook | Отправляет push/WhatsApp/SMS |
| `send-whatsapp` | HTTP POST | WhatsApp Business API wrapper |
| `transition-journey` | HTTP POST | Переход pregnancy → postpartum + infant |
| `calculate-analytics` | Cron (daily 02:00) | Обновляет materialized views аналитики |
| `import-families` | HTTP POST | Импорт семей из CSV |
| `generate-report` | HTTP POST | PDF-генерация отчётов |

### Supabase Database Webhooks

```sql
-- При создании нового journey → вызвать generate-care-plan
CREATE OR REPLACE FUNCTION notify_journey_created()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := current_setting('app.supabase_functions_url') || '/generate-care-plan',
    body := json_build_object('journey_id', NEW.id)::text,
    headers := json_build_object('Authorization', 'Bearer ' || current_setting('app.service_role_key'))::jsonb
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_journey_created
  AFTER INSERT ON journeys
  FOR EACH ROW
  EXECUTE FUNCTION notify_journey_created();
```

---

## 21. Real-time подписки

### Каналы

```typescript
// app/providers/realtime.ts

export function setupRealtimeSubscriptions(familyId: string) {
  // Journey events — для обновления timeline
  supabase
    .channel('journey-events')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'journey_events',
      filter: `family_id=eq.${familyId}`,
    }, handleEventChange)
    .subscribe();

  // Dose logs — для обновления prescription cards
  supabase
    .channel('dose-logs')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'dose_logs',
      filter: `family_id=eq.${familyId}`,
    }, handleDoseChange)
    .subscribe();

  // Notifications
  supabase
    .channel('notifications')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'notifications',
      filter: `user_id=eq.${useCurrentUser().value.id}`,
    }, handleNewNotification)
    .subscribe();

  // Coordinator: all families in clinic (for coordinator role)
  if (useCurrentUser().value.role === 'coordinator') {
    supabase
      .channel('coordinator-tasks')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'coordinator_tasks',
        filter: `clinic_id=eq.${useClinicId()}`,
      }, handleTaskChange)
      .subscribe();
  }
}
```

---

## 22. Интеграции: WhatsApp, Push, МИС

### WhatsApp Business API Setup

1. Зарегистрировать Meta Business Account
2. Создать WhatsApp Business App
3. Получить Phone Number ID и Access Token
4. Зарегистрировать message templates (утверждение Meta ~24ч):
   - `appointment_reminder` — напоминание о визите
   - `vaccination_reminder` — напоминание о вакцинации
   - `welcome_message` — приветствие
   - `overdue_alert` — просрочка

### Push Notifications (Capacitor + FCM)

```typescript
// app/plugins/push.client.ts

import { PushNotifications } from '@capacitor/push-notifications';

export default defineNuxtPlugin(async () => {
  const permission = await PushNotifications.requestPermissions();
  if (permission.receive !== 'granted') return;

  await PushNotifications.register();

  PushNotifications.addListener('registration', async (token) => {
    // Save FCM token to user profile
    await supabase
      .from('users')
      .update({ metadata: { fcm_token: token.value } })
      .eq('id', useCurrentUser().value.id);
  });

  PushNotifications.addListener('pushNotificationReceived', (notification) => {
    // Handle foreground notification
    showInAppNotification(notification);
  });

  PushNotifications.addListener('pushNotificationActionPerformed', (action) => {
    // Handle tap on notification → deep link
    const data = action.notification.data;
    if (data.type === 'appointment') navigateTo(`/family/appointments/${data.id}`);
    if (data.type === 'prescription') navigateTo('/family/prescriptions');
    if (data.type === 'vaccination') navigateTo('/family/vaccinations');
    if (data.type === 'journey_event') navigateTo(`/family/journey/${data.id}`);
  });
});
```

### МИС интеграция (Уровень 0 — MVP)

На MVP нет интеграции. Данные вводятся через coordinator panel или семейное приложение. В Phase 2 — CSV import/export, в Phase 3 — API интеграция.

---

## 23. White-label и multi-tenancy

### Tenant Resolution

```typescript
// app/middleware/tenant.global.ts

export default defineNuxtRouteMiddleware(async (to) => {
  // Resolve tenant from subdomain or path
  const host = useRequestHeaders()['host'] || window.location.host;
  const slug = host.split('.')[0]; // clinic-slug.umai-health.kz

  if (slug && slug !== 'app' && slug !== 'www') {
    const { data: clinic } = await supabase
      .from('clinics')
      .select('*')
      .eq('slug', slug)
      .eq('is_active', true)
      .single();

    if (clinic) {
      useTenant().value = clinic;
      applyTheme(clinic.theme);
    }
  }
});

function applyTheme(theme: TenantTheme) {
  if (!theme) return;
  const root = document.documentElement;

  if (theme.primaryHue !== undefined) {
    const palette = generatePalette(theme.primaryHue, theme.primarySaturation || 57);
    Object.entries(palette).forEach(([shade, value]) => {
      root.style.setProperty(`--color-primary-${shade}`, value);
    });
  }

  if (theme.secondaryHue !== undefined) {
    const palette = generatePalette(theme.secondaryHue, theme.secondarySaturation || 68);
    Object.entries(palette).forEach(([shade, value]) => {
      root.style.setProperty(`--color-secondary-${shade}`, value);
    });
  }
}
```

### Data Isolation

Все таблицы содержат `clinic_id`. RLS policies гарантируют, что пользователь видит только данные своей клиники. Нет shared data между tenants.

---

## 24. Тестирование

### Стратегия

| Уровень | Инструмент | Что тестируем |
|---------|-----------|---------------|
| Unit | Vitest | Composables, утилиты, validators, formatters |
| Component | Vitest + Vue Test Utils | UI компоненты shared/ui/ |
| Integration | Vitest + Supabase local | API queries, RLS policies, Edge Functions |
| E2E | Playwright | Critical user flows |

### Critical E2E Flows

1. **Registration → Onboarding → Timeline**: Мать регистрируется, заполняет профиль, видит маршрут
2. **Prescription Adherence**: Создание назначения → dose reminder → confirm → adherence calculation
3. **Appointment Booking**: Event → Book → Reminder → Complete
4. **Journey Transition**: Pregnancy complete → Birth data → Child profile → Infant journey
5. **Coordinator Overdue**: Event overdue → Task created → Coordinator action → Task closed

---

## 25. DevOps и деплой

### Environments

| Env | URL | Supabase Project | Назначение |
|-----|-----|-----------------|-----------|
| Development | localhost:3000 | Local (supabase start) | Локальная разработка |
| Staging | staging.umai-health.kz | staging project | QA, демо для клиник |
| Production | {slug}.umai-health.kz | production project | Production |

### CI/CD (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run test
      - run: npm run lint

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run build
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'

  deploy-functions:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
      - run: supabase functions deploy --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
```

### Database Migrations

```bash
# Создать миграцию
supabase migration new add_something

# Применить локально
supabase db reset

# Применить на staging/prod
supabase db push --linked
```

---

## 26. Безопасность и compliance

### Checklist

- [ ] RLS включён на всех таблицах с данными пациентов
- [ ] Все API вызовы через Supabase client с anon key (RLS enforced)
- [ ] Service role key только в Edge Functions, никогда на клиенте
- [ ] MFA для ролей coordinator, clinic_admin, management, doctor
- [ ] Шифрование файлов в Supabase Storage (default: at rest encryption)
- [ ] Audit log для всех действий с медицинскими данными
- [ ] Consent management: раздельные согласия на push, WhatsApp, SMS, data sharing
- [ ] HTTPS only (Vercel default)
- [ ] Rate limiting на Edge Functions
- [ ] Input validation (Zod) на клиенте и сервере
- [ ] XSS protection: Vue template auto-escaping, CSP headers
- [ ] AI disclaimer: "Платформа не является медицинским устройством" — в ToS и в интерфейсе

---

## 27. Phase 2 модули (отложенные)

Не разрабатывать в MVP. Добавлять только после gate (запрос от 3+ семей или клиники):

| Модуль | Когда | Зависимости |
|--------|-------|------------|
| Development Dashboard (рост, вес, milestones) | Phase 2 | growth_metrics table ready |
| Symptom Journal | Phase 2 | — |
| Visit Preparation (предвизитная анкета) | Phase 2 | Appointments module |
| Nutrition & Feeding | Phase 2 | child_profiles |
| Clinical Workspace (врач) | Phase 2 | Journey events, documents |
| Full Knowledge Base | Phase 2 | Content creation team |
| AI Care Assistant | Phase 3 | Legal review, content base |
| Red Flag Navigator | Phase 3 | Legal review, clinical protocols |
| Partner Ecosystem | Phase 3 | Commercial partnerships |

---

## 28. Глоссарий

| Термин | Определение |
|--------|------------|
| **Journey** | Маршрут наблюдения: pregnancy, postpartum, infant (0-12 мес.), toddler (12-24 мес.) |
| **Journey Event** | Отдельное событие маршрута: осмотр, анализ, скрининг, вакцинация |
| **Care Plan Engine** | Движок, генерирующий персональный маршрут из template |
| **Adherence** | Процент выполнения назначений (taken doses / total doses) |
| **Overdue** | Событие маршрута, чей дедлайн прошёл без выполнения |
| **Coordinator** | Сотрудник клиники, управляющий семьями через платформу |
| **Tenant** | Клиника-клиент. Каждый tenant = изолированные данные |
| **White-label** | Платформа брендированная под клинику (лого, цвета, название) |
| **LMP** | Last Menstrual Period — дата последней менструации (начало отсчёта беременности) |
| **EDD** | Estimated Due Date — предполагаемая дата родов (LMP + 280 дней) |
| **ПДР** | Предполагаемая дата родов = EDD |
| **Dose Log** | Запись о приёме/пропуске дозы назначения |
| **No-show** | Пациент не пришёл на подтверждённый приём |
| **FSD** | Feature-Sliced Design — архитектура фронтенда |
| **RLS** | Row Level Security — Supabase/PostgreSQL механизм изоляции данных |
| **MCP** | Model Context Protocol — протокол для AI-интеграции с Supabase |

---

*Документ является живой базой знаний. Обновляется по мере развития проекта.*

# UMAI Health — Полная инструкция по реализации интерфейса v1.0
# Единственный источник истины. Добавь в контекст при работе с любым файлом проекта.

---

## 0. КОНТЕКСТ

**Платформа:** UMAI Health — B2B SaaS для частных клиник, цифровой маршрут сопровождения семьи от зачатия до 2 лет
**Домен:** umai-health-landing.vercel.app → umai-health.kz (prod)
**Рынок:** Казахстан (Алматы, Астана, Шымкент, регионы) | Языки: ru, kz
**Стек:** Nuxt 4, Tailwind CSS, Supabase (Auth, DB, Realtime, Storage), GSAP, Lenis
**Шрифты:** Manrope (UI, кириллица) — через @nuxt/fonts
**Иконки:** Lucide
**Роли:** coordinator, family (мама/папа), doctor, admin
**Layouts:** landing, default, auth, app (dashboard)
**3 целевые страницы:** / (главная), /for-clinics, /for-families

---

## 0.1 РЫНОЧНЫЙ КОНТЕКСТ

**Конкуренты:** DamuMed (гос. МИС), MedElement (контент-платформа), ONDOC (запись к врачу)
**Ключевое отличие FCOS:** Ни один конкурент в Казахстане не делает полноценное цифровое сопровождение семьи от зачатия до 2 лет. DamuMed — учётная система без пациентского опыта. ONDOC — запись без маршрута. MedElement — медиа, не SaaS.
**Целевой клиент (B2B):** частные клиники Алматы — IRM Group, Rahat, Keruen Medicus, Мать и Дитя
**Целевой пользователь (B2B2C):** мама 25–35, smartphone-first, Казахстан

---

## 0.2 ДИАГНОСТИКА ТЕКУЩЕГО САЙТА (umai-health-landing.vercel.app)

### Что уже хорошо:
- Чёткая B2B-ценность: «67% семей уходят после родов — мы возвращаем их»
- ROI-калькулятор на странице /for-clinics — работает, считает
- Воронка потерь визуализирована (100 → 55 → 33 → 15 → 5)
- Три отдельные страницы под разные аудитории (/, /for-clinics, /for-families)
- Mock-интерфейсы приложения мамы встроены в лендинг
- Интерактивный тур-онбординг на /for-clinics (5 шагов)
- Брендирование white-label показано (Рахат, Керуен, IRM)
- FAQ на обеих целевых страницах

### КРИТИЧЕСКИЕ ПРОБЛЕМЫ — что делает сайт шаблонным:

---

## 1. ЧТО МЕНЯТЬ — ПРОБЛЕМЫ И РЕШЕНИЯ

### 1.1 HERO-БЛОК (/) — выглядит как шаблонный SaaS

**Проблема:** Hero на главной — стандартная структура: заголовок + подзаголовок + 3 метрики + 2 кнопки + mock телефона справа. Это паттерн, который использует каждый второй SaaS-лендинг. Нет эмоциональной связи. Нет «это про меня».

**Решение:**
- Заменить статичный mock телефона на **живой анимированный маршрут**. При скролле: неделя беременности увеличивается (16 → 17 → 18...), новые события появляются в timeline, витамин отмечается как «принят», push-уведомление прилетает. Всё на GSAP ScrollTrigger.
- Метрики (87%, 94%, ×4.2) — не показывать сразу. **Пусть counter-up анимация запускается при появлении в viewport**. Сейчас они статичны.
- Добавить **персонализацию для сегмента**: «Вы руководитель клиники? → /for-clinics» / «Вы ждёте малыша? → /for-families» — не просто ссылки внизу, а smart-banner прямо в hero.

**Файлы:**
- `app/components/landing/HeroSection.vue` — переписать mock телефона
- Добавить `composables/useScrollAnimation.ts` — GSAP ScrollTrigger helper

### 1.2 СЕКЦИЯ «ЗНАКОМАЯ СИТУАЦИЯ?» — двухколоночное До/После слишком линейно

**Проблема:** Toggle «Без платформы / С платформой» — хороший приём, но реализация плоская: просто 3 карточки слева и 3 справа. Нет истории, нет эмоции, нет вовлечения.

**Решение:**
- **Сценарный подход**: вместо абстрактных карточек — показать один день координатора Динары. «08:00 — открывает Excel с 40 семьями. 09:30 — звонит Каримовой, не отвечает. 11:00 — забыла про прививку Алиевой...». При переключении на «С платформой» — тот же день: «08:00 — открывает панель, 3 задачи красные. 09:00 — Каримова получила push, подтвердила запись. 10:30 — Динара уже сделала 8 задач из 12».
- Реализовать как **timeline с прокруткой**, не toggle-карточки.

**Файлы:**
- `app/components/landing/ProblemSection.vue` — переписать

### 1.3 СЕКЦИЯ «ТРИ ИНТЕРФЕЙСА» — табы с mock'ами, но неинтерактивные

**Проблема:** Табы «Приложение мамы / Панель координатора / Дашборд руководителя» — хорошая идея, но mock'и внутри — статичные картинки. Пользователь видит рисунок, а не продукт. Это самая шаблонная часть сайта.

**Решение — DemoModal (уже обсуждали):**
- Создать `app/components/landing/DemoModal.vue` — полноценный модал с переключением ролей
- При клике на «Попробовать» — открывается **интерактивный прототип**: мама видит маршрут и может нажать «Принять» на витамине. Координатор видит очередь задач и может пометить задачу выполненной. Руководитель видит графики, которые анимированно обновляются.
- Кнопка «Смотреть демо» уже добавлена в NavBar (из нашего прошлого обсуждения). Нужно:
  1. Доделать DemoModal.vue
  2. Добавить mobile-кнопку в mobile-nav
  3. Создать демо-маршруты `/demo/coordinator`, `/demo/family`, `/demo/doctor` без auth guard

**Файлы:**
- `app/components/landing/DemoModal.vue` — создать/доработать
- `app/components/landing/NavBar.vue` — уже обновлён, добавить mobile-кнопку
- `pages/demo/coordinator.vue`, `pages/demo/family.vue` — без auth

### 1.4 СЕКЦИЯ «МОДУЛИ» (/) — 4 карточки без глубины

**Проблема:** «Care Plan Engine», «Умные назначения», «Панель координатора», «Аналитика» — показаны как 4 одинаковые карточки с иконкой и текстом. Это самый шаблонный паттерн EdTech/SaaS. Пользователь видел это 100 раз.

**Решение:**
- **Каждый модуль — мини-анимация**, а не карточка. Care Plan Engine: при scroll показываем как маршрут генерируется за 2 секунды (50+ событий «сыплются» в timeline). Умные назначения: progress-bar от 45% до 94% заполняется. Панель координатора: задачи «сортируются» по приоритету (красные наверх). Аналитика: графики рисуются.
- Использовать GSAP `ScrollTrigger` + `timeline()` для каждого модуля.

**Файлы:**
- `app/components/landing/ModulesSection.vue` — переписать с анимациями
- `app/components/landing/ModuleCarePlan.vue` — анимация генерации маршрута
- `app/components/landing/ModuleAdherence.vue` — анимация 45% → 94%
- `app/components/landing/ModuleCoordinator.vue` — анимация сортировки задач
- `app/components/landing/ModuleAnalytics.vue` — анимация графиков

### 1.5 СТРАНИЦА /for-clinics — много контента, но поток нарушен

**Проблема:** Страница длинная (Hero → Проблема → До/После → Платформа → Тур → Модули → Аналитика → ROI → Кейсы → Запуск → Бренд → Безопасность → FAQ → CTA). 14 секций — это перегруз. Пользователь теряется к середине.

**Решение:**
- **Сократить до 9 секций**: Hero → Проблема (воронка) → Решение (табы по ролям) → ROI-калькулятор → Кейсы → Запуск (4 шага) → Бренд → FAQ → CTA
- Убрать дублирование: секция «8 модулей» дублирует главную. Секция «Аналитика» дублирует ROI. «До и после» — объединить с «Проблемой».
- **Sticky навигация внутри страницы**: sidebar-dots или top-bar с секциями (как Stripe). При скролле — подсвечивается текущая секция.

**Файлы:**
- `pages/for-clinics.vue` — реструктурировать секции
- Убрать: ClinicModulesSection, ClinicAnalyticsSection (дублируют)
- Добавить: `app/components/landing/SectionNav.vue` — sticky dots navigation

### 1.6 СТРАНИЦА /for-families — слишком длинная, повторяется

**Проблема:** Аналогичная проблема — 12+ секций, много повторов с главной. Маршрут малыша, вакцинация, документы — описаны и здесь, и на главной.

**Решение:**
- **Фокус на эмоции, не на фичах.** Эта страница для мамы — ей не нужны «9 модулей». Ей нужно: «Ты не забудешь ни одну прививку. Все анализы — в телефоне. Перед педиатром не надо рыться в WhatsApp.»
- **Сократить до 6 секций**: Hero (эмоция) → «Знакомо?» (4 боли) → «3 экрана приложения» → «День с приложением» → «Ваш щит иммунитета» → «Как подключиться» + FAQ
- Убрать: «Растущий малыш» (дублирует главную), «Все документы» (уже в «3 экрана»), «Что умеет приложение — 9 модулей» (перегруз для мамы).

**Файлы:**
- `pages/for-families.vue` — реструктурировать

### 1.7 КЕЙСЫ КЛИНИК — выглядят фейково

**Проблема:** Три кейса (Мать и Дитя, Шипагер, Перинатальный центр №2) с идеально красивыми цифрами и цитатами. Disclaimеr «Имена публикуются с согласия клиник» — но product-market fit не проверен, реальных клиник нет. Это подрывает доверие.

**Решение:**
- **Убрать конкретные имена клиник.** Вместо «Клиника Мать и Дитя» — показать анонимные данные: «Клиника на 200+ семей/мес, Алматы». Или честно: «Ожидаемые результаты на основе модели» с пояснением методологии.
- Альтернатива: заменить кейсы на **интерактивный ROI-калькулятор** (он уже есть!) и убрать фейковые testimonials.
- Если кейсы реальные — добавить видео-отзывы или скриншоты реальных дашбордов.

**Файлы:**
- `app/components/for-clinics/CasesSection.vue` — переделать или убрать

### 1.8 ДАШБОРДЫ (/coordinator, /family, /doctor, /admin) — пустая оболочка

**Проблема:** За auth-стеной есть дашборды для 4 ролей, но они либо пустые, либо с placeholder-данными. Это главный продукт, который нужно показывать.

**Решение — по каждой роли:**

#### Coordinator Dashboard
- **F-паттерн**: Семей в маршруте (top-left, North Star), Срочные задачи (top-center), Соблюдение назначений (top-right)
- **Центр**: Очередь задач с приоритетами (красный/оранжевый/зелёный). Каждая задача: имя семьи, событие, дедлайн, кнопки «Позвонить» / «Записать» / «Пометить»
- **Левая панель**: Фильтры по статусу (просрочено, сегодня, на этой неделе), по этапу маршрута (беременность, 0–6 мес, 6–12 мес, 12–24 мес)
- **Bottom**: Activity log — последние действия

#### Family Dashboard (приложение мамы)
- **Mobile-first**, bottom nav: Маршрут / Записи / Документы / Профиль
- **Главный экран**: Текущая неделя/месяц → ближайшие 3 события → назначения на сегодня → adherence score
- **Маршрут**: Timeline (vertical scroll), каждое событие — карточка с типом (визит/анализ/прививка/назначение), статусом, датой
- **Документы**: Grid с категориями (анализы, УЗИ, выписки, прививки), поиск, upload фото

#### Doctor Dashboard
- **Desktop-first**: Список пациентов → профиль пациента → маршрут → назначения
- Профиль пациента: chronology (все события), текущие назначения, adherence %, документы

#### Admin Dashboard
- **Desktop-only**: KPI (MAU, Retention 6 мес, LTV, NPS), Аналитика по когортам, Финансы, Настройки клиники
- Когортный анализ: heatmap удержания по месяцам поступления
- White-label настройки: логотип, цвета, домен

---

## 2. ВИЗУАЛЬНАЯ СИСТЕМА

### 2.1 CSS-файлы и архитектура

**Два файла:** `assets/css/landing.css` (токены + лендинг) и `assets/css/app.css` (дашборд-система)
**Nuxt UI** используется как UI-фреймворк, но кастомные переменные определены в landing.css
**Палитра:** Pastel lavender / rose / blue. **НЕТ тёмных, чёрных или зелёных цветов.**

### 2.2 Цветовые токены (landing.css :root)

**Primary — Soft Lavender:**
- `--color-primary: #8B7EC8` — основной бренд
- `--color-primary-dark: #6E5FB3` — hover, акценты
- `--color-primary-light: #E8E4F5` — мягкий фон
- `--color-primary-ultralight: #F5F3FA` — фон секций, карточек

**Secondary — Warm Rose:**
- `--color-secondary: #E8A0BF` — вторичный акцент
- `--color-secondary-dark: #D47EA5` — hover
- `--color-secondary-light: #FDE8F0` — мягкий фон

**Accents:**
- `--color-accent-warm: #F2C4A0` — тёплый персиковый
- `--color-accent-blue: #A8C8E8` — мягкий голубой
- `--color-accent-blue-light: #E4EFF8` — фон голубых блоков

**Text:**
- `--color-text-primary: #4A4458` — основной текст (тёмно-лавандовый, НЕ чёрный)
- `--color-text-secondary: #7B7394` — вторичный
- `--color-text-muted: #A49CB8` — третичный, подписи

**Backgrounds:**
- `--color-bg: #FEFCFF` — фон страницы (почти белый с лавандовым подтоном)
- `--color-bg-alt: #F5F3FA` — альтернативный фон секций
- `--color-surface: #FFFFFF` — карточки

**Borders:**
- `--color-border: #E4DFF0` — основная граница
- `--color-border-light: #F0EDF7` — мягкая граница

**Semantic (БЕЗ зелёного!):**
- `--color-success: #7CB8D4` — голубой (adherence, выполнено)
- `--color-warning: #E9C46A` — жёлтый (скоро дедлайн)
- `--color-danger: #D4727C` — мягкий красный (просрочено)

**Gradients:**
- `--gradient-hero: linear-gradient(135deg, #F5F3FA 0%, #FDE8F0 50%, #FAF7FD 100%)` — фон hero
- `--gradient-cta: linear-gradient(135deg, #8B7EC8 0%, #E8A0BF 100%)` — кнопки CTA
- `--gradient-accent: linear-gradient(135deg, #E8E4F5 0%, #FDE8F0 100%)` — акцентные блоки
- `--gradient-blue: linear-gradient(135deg, #E4EFF8 0%, #F5F3FA 100%)` — голубые блоки

### 2.3 Тени

- `--shadow-sm: 0 1px 3px rgba(139, 126, 200, 0.08)` — мелкие элементы
- `--shadow-md: 0 4px 12px rgba(139, 126, 200, 0.1)` — карточки
- `--shadow-lg: 0 8px 30px rgba(139, 126, 200, 0.12)` — модалки
- `--shadow-card: 0 2px 16px rgba(139, 126, 200, 0.08)` — landing-карточки
- `--shadow-hover: 0 8px 32px rgba(139, 126, 200, 0.16)` — hover-эффект

Все тени — на базе primary `rgba(139, 126, 200, ...)`, НЕ чёрные.

### 2.4 App Dashboard токены (app.css)

**Glassmorphism surfaces:**
- `--glass-bg: rgba(255, 255, 255, 0.65)` — стеклянный фон карточек
- `--glass-bg-elevated: rgba(255, 255, 255, 0.8)` — KPI-карточки
- `--glass-blur: blur(16px)` — backdrop-filter
- `--glass-border: 1px solid rgba(139, 126, 200, 0.1)` — граница стекла

**KPI-градиенты (для border-mask):**
- `--kpi-gradient: primary → secondary` (лаванда → роза)
- `--kpi-gradient-warm: accent-warm → secondary` (персик → роза)
- `--kpi-gradient-blue: accent-blue → primary` (голубой → лаванда)
- `--kpi-gradient-success: success → accent-blue` (голубой → голубой)

**App тени (глубже чем landing):**
- `--app-shadow-card: 0 2px 12px rgba(139, 126, 200, 0.06)`
- `--app-shadow-hover: 0 8px 24px rgba(139, 126, 200, 0.12)`
- `--app-shadow-elevated: 0 12px 40px rgba(139, 126, 200, 0.14)`
- `--app-shadow-glow-primary: 0 0 20px rgba(139, 126, 200, 0.25)` — glow-эффект

**Status colors:**
- Success: bg `rgba(124, 184, 212, 0.12)`, text `#4A9AB8` (голубой!)
- Warning: bg `rgba(233, 196, 106, 0.15)`, text `#C4930E`
- Danger: bg `rgba(212, 114, 124, 0.12)`, text `#B84E5A`
- Info: bg `rgba(139, 126, 200, 0.1)`, text `= primary`

### 2.5 Радиусы

- `--radius-sm: 10px` — кнопки, инпуты, табы
- `--radius-md: 16px` — карточки, модалки
- `--radius-lg: 20px` — landing-карточки
- `--radius-xl: 28px` — hero-блоки
- `--radius-full: 9999px` — бейджи, аватары

### 2.6 Transitions

- `--transition-fast: 150ms ease` — hover, click
- `--transition-base: 250ms ease` — стандарт
- `--transition-smooth: 350ms cubic-bezier(0.4, 0, 0.2, 1)` — карточки, раскрытие

### 2.7 Типографика

**Шрифты:**
- `--font-display: 'Satoshi'` — заголовки, hero (weights: 500, 700, 900)
- `--font-body: 'Inter'` — основной текст (weights: 400, 500, 600, 700)
- `--font-mono: 'JetBrains Mono'` — цифры, код (weights: 400, 500, 600)

**Fluid scale (clamp):**

| Переменная | Значение | Где |
|-----------|----------|-----|
| `--text-hero` | clamp(2.5rem, 5vw, 4.5rem) | Hero лендинга |
| `--text-h1` | clamp(2rem, 4vw, 3.5rem) | H1 страниц |
| `--text-h2` | clamp(1.5rem, 3vw, 2.5rem) | H2 секций |
| `--text-h3` | clamp(1.25rem, 2vw, 1.75rem) | H3 подсекций |
| `--text-body-lg` | 1.125rem | Лид-текст |
| `--text-body` | 1rem | Основной |
| `--text-sm` | 0.875rem | Подписи |
| `--text-xs` | 0.75rem | Мета, overline |
| `--text-card-title` | clamp(1rem, 1.5vw, 1.125rem) | Заголовки карточек |

**Helper-классы:** `.font-display`, `.font-heading`, `.font-body`, `.font-mono`, `.text-gradient`

### 2.8 Spacing

**Landing:**
- `--section-py: 96px` (mobile: 64px, tablet: 80px)
- `--container-max: 1200px`
- `--container-px: 24px` (mobile: 14px)

**App Dashboard:**
- `--app-page-px: 32px` (mobile: 16px)
- `--app-page-py: 32px` (mobile: 20px)
- `--app-card-px: 24px` (mobile: 16px)
- `--app-card-py: 20px` (mobile: 16px)
- `--app-gap-sm: 8px` / `--app-gap-md: 16px` / `--app-gap-lg: 24px` / `--app-gap-xl: 32px`

### 2.9 Grid (app.css)

```css
.grid-kpi    → repeat(4, 1fr) → 2 на tablet → 1 на mobile
.grid-cards  → auto-fill, minmax(320px, 1fr) → 1 на mobile
.grid-2      → 1fr 1fr → 1 на mobile
.grid-3      → repeat(3, 1fr) → 2 на tablet → 1 на mobile
```

### 2.10 Responsive приоритеты

| Роль | Приоритет | Bottom nav |
|------|-----------|------------|
| Family (мама) | Mobile-first | Да (4 таба) |
| Coordinator | Desktop-first, mobile functional | Да |
| Doctor | Desktop-first | Нет |
| Admin | Desktop-only | Нет |

### 2.11 CSS-классы для компонентов

**Landing:** `.landing-section`, `.landing-container`, `.landing-card`, `.glass-card`, `.hover-lift`, `.gradient-border`, `.text-gradient`, `.text-gradient-shimmer`
**App cards:** `.app-card`, `.app-card-elevated`, `.app-card-interactive`, `.kpi-card` (+ модификаторы `--warm`, `--blue`, `--success`)
**Buttons:** `.app-btn` + `--primary`, `--secondary`, `--ghost`, `--danger`, `--sm`, `--icon`
**Status:** `.status-badge` + `--success`, `--warning`, `--danger`, `--info`, `--neutral`
**Priority:** `.priority-border--critical` (danger), `--high` (warning), `--medium` (blue), `--low` (border)
**Loading:** `.skeleton`, `.skeleton-text`, `.skeleton-circle`, `.skeleton-card`, `.skeleton-chart`
**Animations:** `.reveal`, `.reveal-stagger`, `.stagger-list`, `.stagger-cascade`, `.streak-fire`, `.pulse-glow`, `.achievement-unlocked`, `.achievement-locked`, `.float-up-down`, `.marquee-track`
**Trends:** `.trend-up` (success), `.trend-down` (danger), `.trend-neutral` (muted)
**Empty state:** `.empty-state`, `.empty-state-icon`, `.empty-state-title`, `.empty-state-description`
**Notification:** `.notif-dot` (красная точка с пульсацией)

### 2.12 Анимации

| Анимация | Где | Файл |
|----------|-----|------|
| `shimmer` | Skeleton loading | app.css |
| `stagger-fade-in` | Списки в дашборде | app.css |
| `fire-flicker` | Streak-огонь | app.css |
| `pulse-ring` | SOS / alert | app.css |
| `achievement-pop` | Разблокировка бейджа | app.css |
| `notif-pulse` | Notification dot | app.css |
| `gradient-shimmer` | Текст hero | landing.css |
| `mesh-drift` | Hero gradient | landing.css |
| `btn-shimmer-slide` | CTA hover | landing.css |
| `marquee-scroll` | Бренды white-label | landing.css |
| `float-y` | Декоративные элементы | landing.css |
| `slide-in-right` | Уведомления | landing.css |
| `counter-pulse` | Counter-up финиш | landing.css |
| `blink-cursor` | Typewriter | landing.css |

Все анимации отключаются при `prefers-reduced-motion: reduce`.

---

## 3. LAYOUTS

### 3.1 layouts/landing.vue
**Для:** /, /for-clinics, /for-families
Header: sticky, transparent → solid on scroll. Logo, навигация (Платформа, Компаниям, Родителям), кнопки Войти / Запросить демо / Смотреть демо.
Footer: навигация, контакты, соцсети.

### 3.2 layouts/default.vue
**Для:** /about, /privacy, /terms, /blog
Header + centered content + footer.

### 3.3 layouts/auth.vue
**Для:** /auth/login, /auth/register, /auth/forgot-password, /auth/confirm
Центрированная форма, логотип, минималистично.

### 3.4 layouts/app.vue (dashboard)
**Для:** /coordinator/*, /family/*, /doctor/*, /admin/*
Sidebar (w-64, collapsed w-16 на tablet) + Topbar (h-14) + Content area + Mobile bottom nav.
Атрибут `data-role` на корневом div для ролевых акцентов.

Sidebar: лого клиники (white-label), навигация по роли, профиль внизу.
Topbar: mobile menu, breadcrumb, search (coordinator/admin), notifications bell, avatar.

### 3.5 layouts/demo.vue
**Для:** /demo/coordinator, /demo/family, /demo/doctor
Аналог app.vue, но БЕЗ auth guard. Banner сверху: «Это демо-режим. Зарегистрируйтесь для полного доступа.»

---

## 4. НАВИГАЦИЯ ПО РОЛЯМ

### 4.1 Coordinator sidebar

```ts
[
  { label: 'Дашборд', to: '/coordinator', icon: 'lucide:layout-dashboard' },
  { label: 'Мои семьи', to: '/coordinator/families', icon: 'lucide:users' },
  { label: 'Задачи', to: '/coordinator/tasks', icon: 'lucide:clipboard-list', badge: urgentCount },
  { label: 'Календарь', to: '/coordinator/calendar', icon: 'lucide:calendar' },
  { label: 'Маршруты', to: '/coordinator/care-plans', icon: 'lucide:route' },
  { label: 'Назначения', to: '/coordinator/prescriptions', icon: 'lucide:pill' },
  { label: 'Вакцинация', to: '/coordinator/vaccinations', icon: 'lucide:shield-check' },
  { label: 'Документы', to: '/coordinator/documents', icon: 'lucide:folder-open' },
  { label: 'Хронология', to: '/coordinator/timeline', icon: 'lucide:scroll-text' },
  { label: 'Настройки', to: '/coordinator/settings', icon: 'lucide:settings' },
]
```

**Mobile bottom nav (5 max):**
```ts
[
  { label: 'Дашборд', to: '/coordinator', icon: 'lucide:layout-dashboard' },
  { label: 'Задачи', to: '/coordinator/tasks', icon: 'lucide:clipboard-list' },
  { label: 'Семьи', to: '/coordinator/families', icon: 'lucide:users' },
  { label: 'Календарь', to: '/coordinator/calendar', icon: 'lucide:calendar' },
  { label: 'Ещё', icon: 'lucide:menu' },
]
```

### 4.2 Family sidebar / bottom nav

**Bottom nav (mobile-first, 4 таба):**
```ts
[
  { label: 'Маршрут', to: '/family', icon: 'lucide:route' },
  { label: 'Записи', to: '/family/appointments', icon: 'lucide:calendar-check' },
  { label: 'Документы', to: '/family/documents', icon: 'lucide:folder-open' },
  { label: 'Профиль', to: '/family/profile', icon: 'lucide:user' },
]
```

### 4.3 Doctor sidebar

```ts
[
  { label: 'Мои пациенты', to: '/doctor', icon: 'lucide:users' },
  { label: 'Сегодня', to: '/doctor/today', icon: 'lucide:calendar-clock' },
  { label: 'Маршруты', to: '/doctor/care-plans', icon: 'lucide:route' },
  { label: 'Назначения', to: '/doctor/prescriptions', icon: 'lucide:pill' },
  { label: 'Документы', to: '/doctor/documents', icon: 'lucide:folder-open' },
  { label: 'Настройки', to: '/doctor/settings', icon: 'lucide:settings' },
]
```

### 4.4 Admin sidebar

```ts
[
  { label: 'Dashboard', to: '/admin', icon: 'lucide:layout-dashboard' },
  { label: 'Семьи', to: '/admin/families', icon: 'lucide:users' },
  { label: 'Координаторы', to: '/admin/coordinators', icon: 'lucide:headphones' },
  { label: 'Врачи', to: '/admin/doctors', icon: 'lucide:stethoscope' },
  { section: 'Аналитика' },
  { label: 'Удержание', to: '/admin/analytics/retention', icon: 'lucide:user-check' },
  { label: 'Воронка', to: '/admin/analytics/funnel', icon: 'lucide:filter' },
  { label: 'LTV', to: '/admin/analytics/ltv', icon: 'lucide:trending-up' },
  { label: 'NPS', to: '/admin/analytics/nps', icon: 'lucide:star' },
  { label: 'Adherence', to: '/admin/analytics/adherence', icon: 'lucide:check-circle' },
  { section: 'Настройки' },
  { label: 'Клиника', to: '/admin/settings/clinic', icon: 'lucide:building-2' },
  { label: 'Бренд', to: '/admin/settings/brand', icon: 'lucide:palette' },
  { label: 'Маршруты', to: '/admin/settings/care-plans', icon: 'lucide:route' },
  { label: 'Уведомления', to: '/admin/settings/notifications', icon: 'lucide:bell' },
  { label: 'Пользователи', to: '/admin/settings/users', icon: 'lucide:shield' },
]
```

---

## 5. КАРТА СТРАНИЦ

### 5.1 ПУБЛИЧНЫЕ

| Страница | Layout | Описание |
|----------|--------|----------|
| `/` | landing | Главная. Hero → Проблема → Что такое FCOS → Маршрут → 3 интерфейса → Модули → CTA |
| `/for-clinics` | landing | Для клиник. Hero → Воронка потерь → Решение (табы по ролям) → ROI → Кейсы → Запуск → Бренд → FAQ → CTA |
| `/for-families` | landing | Для родителей. Hero → «Знакомо?» → 3 экрана → День с приложением → Вакцинация → Как подключиться → FAQ |
| `/auth/login` | auth | Вход: email+пароль, ссылка на регистрацию |
| `/auth/register` | auth | Регистрация: выбор роли, email, пароль, имя |
| `/auth/forgot-password` | auth | Восстановление пароля |
| `/auth/confirm` | auth | Подтверждение email |
| `/demo/coordinator` | demo | Демо координатора без auth |
| `/demo/family` | demo | Демо приложения мамы без auth |
| `/demo/doctor` | demo | Демо врача без auth |

### 5.2 COORDINATOR

| Страница | Описание |
|----------|----------|
| `/coordinator` | Dashboard. F-паттерн: Семей в маршруте (top-left), Срочные задачи (top-center), Adherence % (top-right). Очередь задач с приоритетами. Расписание на день. |
| `/coordinator/families` | Список семей. Таблица: имя, этап маршрута, adherence %, последнее событие, статус. Фильтры: этап, статус, координатор. |
| `/coordinator/families/[id]` | Профиль семьи: мама + папа + ребёнок, маршрут (timeline), назначения, adherence, документы, activity log. |
| `/coordinator/tasks` | Очередь задач. Фильтры: срочность, тип (звонок, запись, прививка). Bulk-действия. |
| `/coordinator/calendar` | Визиты и события всех семей. Виды: неделя/день. |
| `/coordinator/care-plans` | Шаблоны маршрутов. Список, просмотр, создание (admin only). |
| `/coordinator/prescriptions` | Назначения всех семей. Статус: active/completed/missed. |
| `/coordinator/vaccinations` | Календарь вакцинации. Фильтр: предстоящие, просроченные, выполненные. |
| `/coordinator/documents` | Документы всех семей. Поиск, фильтр по типу. |
| `/coordinator/timeline` | Хронология всех событий (activity log). Фильтр по семье, типу. |
| `/coordinator/settings` | Профиль, уведомления, рабочие часы. |

### 5.3 FAMILY

| Страница | Описание |
|----------|----------|
| `/family` | Главный экран. Текущая неделя/месяц, ближайшие события, назначения на сегодня, adherence score. |
| `/family/care-plan` | Полный маршрут — timeline от зачатия до 2 лет. Вертикальный скролл. |
| `/family/appointments` | Записи к врачу. Предстоящие + прошлые. Кнопка «Записаться». |
| `/family/prescriptions` | Текущие назначения. Кнопка «Принял» для каждого. |
| `/family/vaccinations` | Календарь прививок. Щит иммунитета (визуализация). |
| `/family/documents` | Архив документов. Upload фото. Категории. |
| `/family/documents/[id]` | Просмотр документа. |
| `/family/profile` | Профиль семьи: мама, папа, дети. Управление доступом. |
| `/family/profile/child/[id]` | Профиль ребёнка: дата рождения, рост/вес, этапы развития. |

### 5.4 DOCTOR

| Страница | Описание |
|----------|----------|
| `/doctor` | Список моих пациентов. Таблица: имя, этап, adherence, последний визит. |
| `/doctor/today` | Расписание на сегодня. Список визитов с данными пациента. |
| `/doctor/patients/[id]` | Профиль пациента: маршрут, хронология, назначения, документы. |
| `/doctor/care-plans` | Маршруты пациентов. Просмотр, корректировка назначений. |
| `/doctor/prescriptions` | Управление назначениями. Создание, отмена, корректировка. |
| `/doctor/documents` | Документы пациентов. Просмотр, загрузка. |

### 5.5 ADMIN

| Страница | Описание |
|----------|----------|
| `/admin` | Dashboard. KPI: MAU, Retention 6 мес, LTV, NPS. Графики. |
| `/admin/families` | Все семьи клиники. CRUD. Экспорт. |
| `/admin/coordinators` | Координаторы: загрузка, задачи, эффективность. |
| `/admin/doctors` | Врачи: расписание, пациенты. |
| `/admin/analytics/retention` | Когортный анализ удержания (heatmap). |
| `/admin/analytics/funnel` | Воронка: беременность → младенец → малыш. |
| `/admin/analytics/ltv` | LTV по когортам. |
| `/admin/analytics/nps` | NPS с комментариями. |
| `/admin/analytics/adherence` | Adherence по семьям, по назначениям. |
| `/admin/settings/clinic` | Данные клиники. |
| `/admin/settings/brand` | White-label: логотип, цвета, домен. |
| `/admin/settings/care-plans` | Управление шаблонами маршрутов. |
| `/admin/settings/notifications` | Шаблоны push/SMS/email. |
| `/admin/settings/users` | Управление пользователями, роли, доступ. |

---

## 6. МОДЕЛЬ ДАННЫХ

```
User (id, email, role, name, avatar, phone, lang, clinicId, createdAt)
  ├── Coordinator (id, userId, clinicId)
  ├── Doctor (id, userId, clinicId, specialization)
  ├── FamilyMember (id, userId, familyId, role: mother|father|guardian)
  └── Admin (id, userId, clinicId)

Clinic (id, name, city, logo, colors, domain, plan, createdAt)

Family (id, clinicId, coordinatorId, status, createdAt)
  ├── FamilyMember[]
  ├── Child (id, familyId, name, birthDate, gender)
  │     ├── CarePlan (id, childId, templateId, stage, startDate)
  │     │     └── CarePlanEvent[] (id, carePlanId, type, title, dueDate, status, completedAt)
  │     ├── Vaccination[] (id, childId, vaccineId, dueDate, status, administeredAt, batch)
  │     └── GrowthRecord[] (id, childId, date, weight, height, headCircumference)
  ├── Prescription[] (id, familyId, doctorId, name, dosage, frequency, startDate, endDate)
  │     └── PrescriptionLog[] (id, prescriptionId, date, taken: boolean, takenAt)
  ├── Appointment[] (id, familyId, doctorId, dateTime, type, status, notes)
  ├── Document[] (id, familyId, type, title, fileUrl, linkedEventId, uploadedAt)
  └── ActivityLog[] (id, familyId, action, actorId, metadata, createdAt)

CarePlanTemplate (id, clinicId, name, stage, events: Json)
Vaccine (id, name, nameKz, doses, schedule)
Notification (id, userId, type, title, body, read, createdAt)
Task (id, coordinatorId, familyId, type, priority, dueDate, status, completedAt)
```

---

## 7. СЕРВЕРНЫЕ ЭНДПОИНТЫ

| Эндпоинт | Метод | Описание |
|----------|-------|----------|
| `/api/auth/register` | POST | Регистрация + создание роли |
| `/api/families/create` | POST | Создание семьи + генерация маршрута |
| `/api/families/[id]/care-plan` | GET | Маршрут семьи |
| `/api/families/[id]/prescriptions` | GET/POST | Назначения |
| `/api/families/[id]/vaccinations` | GET/POST | Вакцинации |
| `/api/families/[id]/documents` | GET/POST | Документы |
| `/api/families/[id]/timeline` | GET | Хронология |
| `/api/prescriptions/[id]/log` | POST | Отметка приёма витамина |
| `/api/tasks` | GET/POST/PATCH | Задачи координатора |
| `/api/appointments/create` | POST | Создание записи к врачу |
| `/api/appointments/[id]/remind` | POST | Отправка напоминания |
| `/api/analytics/retention` | GET | Когортный анализ |
| `/api/analytics/funnel` | GET | Воронка |
| `/api/analytics/adherence` | GET | Соблюдение назначений |
| `/api/notifications/send` | POST | Отправка уведомления |
| `/api/clinic/settings` | GET/PATCH | Настройки клиники |
| `/api/clinic/brand` | GET/PATCH | White-label |

---

## 8. ПРАВИЛА РЕАЛИЗАЦИИ

### ВСЕГДА:
- CSS-переменные через `var(--color-*)`, никаких хардкодных цветов
- Typography-классы: text-display, text-headline, text-title, text-body, text-caption, text-overline
- Empty state для каждого пустого списка: иконка + объяснение + CTA
- Skeleton loading вместо spinner
- Toast для feedback (success/error)
- i18n: `{{ $t('key') }}` (ru, kz)
- `data-role` атрибут для ролевых акцентов
- Dark mode через CSS-переменные
- Все формы — Zod-валидация
- Supabase RLS — данные клиник изолированы

### НИКОГДА:
- Хардкодные цвета (#hex, rgb в компонентах)
- Inline styles
- Pie Chart (всегда bar chart)
- alert()/confirm() — только модалки и toast
- Mobile-адаптация для admin
- Пустые экраны без empty state
- Изменение main.css без явного запроса
- Стоковые фотографии на лендинге (только UI-mock'и и анимации)

### CHECKLIST на каждый компонент:
- [ ] CSS-переменные, не хардкод
- [ ] Typography-классы
- [ ] Empty state
- [ ] Loading state (skeleton)
- [ ] Error handling (toast)
- [ ] Dark mode
- [ ] Responsive для роли
- [ ] i18n
- [ ] a11y: focus-visible, aria-labels
- [ ] Hover/active states
- [ ] Touch target ≥ 44px на mobile

---

## 9. ПРИОРИТЕТЫ РЕАЛИЗАЦИИ

| # | Задача | Почему сейчас |
|---|--------|---------------|
| 1 | Hero-блок → живой анимированный маршрут вместо статичного mock | Первое впечатление. Это отличает от шаблона. |
| 2 | DemoModal → интерактивные прототипы 3 ролей | Конверсия. Показать продукт, а не рассказывать. |
| 3 | Секция модулей → мини-анимации вместо карточек | Вовлечение. GSAP ScrollTrigger. |
| 4 | /for-clinics → сократить до 9 секций, убрать дубли | Поток. Перегруз = отток. |
| 5 | /for-families → сократить до 6 секций, эмоция вместо фич | Мама не читает 12 секций. |
| 6 | Кейсы → анонимизировать или убрать фейковые | Доверие. Фейк подрывает. |
| 7 | layouts/app.vue → sidebar + topbar + bottom nav + data-role | Основа дашбордов. |
| 8 | Coordinator dashboard (F-паттерн) | Главный пользователь продукта. |
| 9 | Family dashboard (mobile PWA) | Конечный пользователь, retention driver. |
| 10 | Seed-скрипт с моковыми данными | Без данных нельзя тестировать. |
| 11 | Admin dashboard + аналитика | ROI для руководителя клиники. |
| 12 | Doctor dashboard | Вторичный пользователь. |

---

## 10. ПРОМТ ДЛЯ ПОЛНОГО АУДИТА

Скопируй и вставь при запуске работы:

```
Ты — senior fullstack-разработчик, работающий над проектом UMAI Health.

Тебе предоставлен документ UMAI_HEALTH_IMPLEMENTATION_GUIDE.md — единственный источник истины по интерфейсу платформы.

Также: main.css (CSS-переменные, dark mode), текущие компоненты лендинга.

ЗАДАЧА: Привести проект в соответствие с документом. Убрать шаблонность.

ПОРЯДОК:
1. Изучи текущий код (layouts, pages, components)
2. НЕ ЛОМАЙ работающую логику
3. Приоритеты:
   a) Hero → живой анимированный маршрут (GSAP)
   b) DemoModal → интерактивные прототипы ролей
   c) Секции модулей → анимации вместо карточек
   d) /for-clinics → 9 секций, убрать дубли
   e) /for-families → 6 секций, эмоция
   f) layouts/app.vue → sidebar + topbar + bottom nav
   g) Coordinator dashboard (F-паттерн)
   h) Family dashboard (mobile PWA)

ПРАВИЛА:
- CSS-переменные, не хардкод
- Typography-классы
- Empty state + skeleton + toast
- i18n: $t('key')
- Dark mode через переменные
- НЕ МЕНЯТЬ main.css без запроса

ПРОВЕРКА:
- pnpm dev без ошибок
- Рендерится с данными
- Dark mode работает
- Нет хардкодных цветов

Начни с изучения текущих layouts и компонентов.
```

---

## 11. БИБЛИОТЕКИ И ИНСТРУМЕНТЫ — БЕСПЛАТНЫЕ РЕШЕНИЯ

### 11.1 Анимации

| Библиотека | Зачем | Установка | Где использовать |
|-----------|-------|-----------|-----------------|
| **@vueuse/motion** | Declarative анимации в Vue-компонентах. v-motion directive, preset анимации (fade, slide, pop), scroll-trigger. | `pnpm add @vueuse/motion` + модуль в nuxt.config | Карточки при появлении, KPI counter-up, табы, списки задач |
| **GSAP (бесплатная версия)** | Timeline-анимации, ScrollTrigger, SplitText-эффект. Уже в проекте. | Уже есть | Hero-маршрут, секция модулей, воронка потерь, parallax |
| **GSAP ScrollTrigger** | Pin-секции, scrub-анимации (маршрут заполняется при скролле) | `gsap.registerPlugin(ScrollTrigger)` | Маршрут от зачатия до 2 лет (timeline заполняется), progress bar секций |
| **auto-animate** | Zero-config анимации для списков (add/remove/reorder) | `pnpm add @formkit/auto-animate` | Очередь задач координатора, список семей, фильтры |
| **Lottie (lottie-web)** | JSON-анимации вместо GIF. Лёгкие, скалируемые, премиальные. | `pnpm add lottie-web` или `pnpm add vue3-lottie` | Empty states, achievement unlock, onboarding steps, loading |
| **CountUp.js** | Animated number counting с easing | `pnpm add countup.js` | KPI-метрики в hero, дашбордах, ROI-калькуляторе |
| **Typed.js** | Typewriter-эффект (уже есть CSS-версия, но JS даёт больше контроля) | `pnpm add typed.js` | Hero subtitle: «для клиник / для семей / для врачей» |

### 11.2 Графики и визуализация данных

| Библиотека | Зачем | Установка |
|-----------|-------|-----------|
| **Apache ECharts** | Уже в проекте (`vite.optimizeDeps`). Премиальные графики: когорты, heatmap, funnel, sankey. Бесплатный. | Уже есть |
| **vue-echarts** | Vue-обёртка для ECharts. Reactive, SSR-compatible. | `pnpm add vue-echarts` |

**Рекомендуемые типы графиков по страницам:**
- **Admin Retention** → ECharts Heatmap (когортный анализ, как у Amplitude)
- **Admin Funnel** → ECharts Funnel (беременность → младенец → малыш)
- **Admin LTV** → ECharts Bar + Line combo (LTV по когортам + тренд)
- **Admin NPS** → ECharts Gauge (NPS score) + Bar (распределение)
- **Coordinator Adherence** → ECharts Liquid Fill (% соблюдения, как заполняющийся круг)
- **Family Progress** → ECharts Radial Bar (прогресс маршрута)
- **Tutor/Doctor schedule** → Custom calendar grid (не ECharts)

### 11.3 Иллюстрации и графика

| Ресурс | Что даёт | Лицензия | Как использовать |
|--------|---------|----------|-----------------|
| **unDraw** (undraw.co) | SVG-иллюстрации. Кастомизируемый цвет. Медицинские, семейные темы. | MIT / бесплатно | Empty states, онбординг, /for-families, /for-clinics hero |
| **Storyset** (storyset.com) | Анимированные SVG-иллюстрации. Стили: Rafiki, Pana, Cuate. Выбрать лавандовую палитру. | Freepik attribution | Hero-блоки, секция «Как это работает», /for-families |
| **Humaaans** (humaaans.com) | Конструктор людей-иллюстраций. Микс поз, причёсок, цветов. | Бесплатно для личных проектов | Персонажи: мама, координатор, врач |
| **Open Peeps** (openpeeps.com) | Hand-drawn люди, стиль скетч. | CC0 | Аватары в кейсах, команда |
| **Phosphor Icons** | Альтернатива Lucide — более мягкий стиль, подходит медицинской теме | MIT | Можно миксовать с Lucide для особых экранов |
| **Rive** (rive.app) | Интерактивные анимации (state machine). Бесплатный план — 3 файла. | Free tier | Hero-анимация маршрута, interactive onboarding |
| **LottieFiles** (lottiefiles.com) | Готовые Lottie-анимации: медицинские, check marks, confetti, loading | Бесплатные | Каждый empty state, achievement unlock, success feedback |

**Рекомендуемые Lottie-анимации для проекта:**
```
- medical-checkup.json      → /for-clinics hero
- baby-sleeping.json         → /for-families hero
- checklist-complete.json    → after task completion
- confetti.json              → achievement unlock
- empty-inbox.json           → empty states (задачи, документы)
- loading-dots.json          → page transitions
- heart-pulse.json           → health dashboard
- calendar-flip.json         → appointment reminders
- shield-check.json          → vaccination complete
- chart-growing.json         → analytics loading
```

### 11.4 UI-компоненты и утилиты

| Библиотека | Зачем | Установка |
|-----------|-------|-----------|
| **VueUse** | 200+ composables: useIntersectionObserver (scroll reveal), useLocalStorage, useMediaQuery, useTimeAgo, useDateFormat | `pnpm add @vueuse/core` |
| **v-calendar** | Premium календарь для расписания врачей и визитов | `pnpm add v-calendar@next` |
| **vue-draggable-plus** | Drag-and-drop для очереди задач координатора (reorder приоритетов) | `pnpm add vue-draggable-plus` |
| **floating-vue** | Tooltips и popovers (лучше чем встроенные в Nuxt UI для кастомных случаев) | `pnpm add floating-vue` |
| **vue-sonner** | Toast-уведомления премиального качества (стиль Sonner) | Можно использовать Nuxt UI toast |

### 11.5 Медиа и файлы

| Библиотека | Зачем |
|-----------|-------|
| **@nuxt/image** | Уже в проекте. Оптимизация картинок, lazy load, placeholder blur. |
| **vue-advanced-cropper** | Обрезка фото при upload (аватары, документы) |
| **pdfjs-dist** | Просмотр PDF-документов прямо в приложении |

---

## 12. КАК СДЕЛАТЬ ПРОЕКТ ПРЕМИАЛЬНЫМ — КОНКРЕТНЫЕ ПРИЁМЫ

### 12.1 Лендинг — 10 приёмов против шаблонности

**1. Hero: animated gradient mesh + floating elements**
```
Фон: hero-gradient-mesh (уже есть в landing.css — анимация mesh-drift 18s)
Поверх: floating SVG-элементы (пульс, сердце, календарь) с классом float-up-down
Mock телефона: GSAP timeline — неделя увеличивается, события появляются, витамин отмечается
```

**2. Grain texture overlay**
```
Добавить .grain-overlay::before на hero и акцентные секции.
Уже есть в landing.css. Даёт текстуру «напечатанного» — мгновенный Premium-эффект.
```

**3. Scroll progress bar**
```
.scroll-progress уже есть в landing.css.
Реализовать: composable useScrollProgress → transform: scaleX(progress)
Тонкая полоска gradient-cta вверху — показывает сколько прочитано.
```

**4. Parallax layers**
```
[data-speed] атрибуты на декоративных элементах.
GSAP ScrollTrigger: elements двигаются с разной скоростью.
Использовать на: blob-формах в hero, иконках в секции модулей.
```

**5. Magnetic buttons**
```
.magnetic-btn + JS: при hover кнопка «притягивается» к курсору на 4-6px.
Использовать на CTA-кнопках: «Запросить демо», «Попробовать».
```

**6. Tilt cards**
```
[data-tilt] + JS: карточки наклоняются к курсору (perspective 3D).
Использовать на: карточках модулей, карточках ролей.
Библиотека: vanilla-tilt (2KB) или кастомный composable useTilt.
```

**7. Clip-path reveals**
```
Секции появляются через clip-path анимацию (не просто fade-in).
clip-path: inset(10% round 20px) → clip-path: inset(0)
GSAP ScrollTrigger scrub.
```

**8. Number counter-up с пульсом**
```
CountUp.js на метриках (87%, 94%, ×4.2).
После финиша — .number-pulse (уже в landing.css).
Запуск: useIntersectionObserver — когда метрика в viewport.
```

**9. Typewriter на hero subtitle**
```
«Для клиник» → стирается → «Для семей» → стирается → «Для врачей»
Typed.js или кастомный composable useTypewriter.
.typewriter-active::after — уже есть cursor blink в landing.css.
```

**10. Infinite marquee с брендами клиник**
```
.marquee-wrap + .marquee-track уже в landing.css.
Показывать логотипы: Рахат, Керуен, IRM, Мать и Дитя — бесконечный скролл.
:hover → animation-play-state: paused.
```

### 12.2 Dashboard — 8 приёмов премиальности

**1. Glassmorphism cards**
```
.app-card с backdrop-filter: blur(16px) — уже в app.css.
Стеклянный эффект на карточках KPI и задач.
НЕ переусердствовать — glass только для elevated elements, не для всего.
```

**2. KPI cards с gradient border-mask**
```
.kpi-card::before — gradient border через mask-composite.
Уже в app.css. 4 варианта: default (лаванда→роза), warm, blue, success.
Hover: border становится ярче (opacity 0.5 → 1).
```

**3. Stagger-анимации списков**
```
.stagger-list — элементы появляются с задержкой 50ms каждый.
Использовать на: очереди задач, списке семей, уведомлениях.
auto-animate (@formkit) — для добавления/удаления элементов из DOM.
```

**4. Trend indicators**
```
.trend-up (голубой ↑), .trend-down (красный ↓), .trend-neutral (серый →)
На каждом KPI: «+12% vs прошлый месяц».
```

**5. Status badges с мягкими цветами**
```
.status-badge (уже в app.css) — 5 вариантов: success, warning, danger, info, neutral.
Прозрачный фон + насыщенный текст — премиальнее чем сплошные бейджи.
```

**6. Priority left-border**
```
.priority-border--critical (красный) / --high (оранжевый) / --medium (голубой) / --low (серый)
На карточках задач координатора — мгновенно видно приоритет.
```

**7. Skeleton shimmer**
```
.skeleton с shimmer-анимацией — уже в app.css.
Использовать ВЕЗДЕ вместо spinner. Варианты: text, circle, card, chart.
```

**8. Lottie empty states**
```
Каждый пустой экран: Lottie-анимация + заголовок + описание + CTA.
Разные анимации для разных контекстов:
- Нет задач → checklist animation
- Нет семей → family illustration
- Нет документов → folder animation
- Нет прививок → shield animation
```

---

## 13. РАСШИРЕННОЕ НАПОЛНЕНИЕ ДАШБОРДОВ — ПРОФЕССИОНАЛЬНЫЙ УРОВЕНЬ

### 13.1 Coordinator Dashboard — «Командный центр»

**НЕ просто список задач, а операционный хаб:**

**Верхняя полоса (KPI row — .grid-kpi):**
```
┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
│ 🏥 Семей в       │ 🔴 Срочных       │ 📊 Adherence     │ 📅 Визитов       │
│ маршруте         │ задач            │ средний          │ сегодня          │
│                  │                  │                  │                  │
│ 247              │ 12               │ 87%              │ 18               │
│ +8 за неделю ↑   │ 3 просрочены     │ +4% vs пр.мес ↑  │ 2 no-show risk   │
└──────────────────┴──────────────────┴──────────────────┴──────────────────┘
```
Каждая KPI-карточка: `.kpi-card` + тренд `.trend-up/.trend-down` + CountUp анимация

**Центральная зона (2 колонки — .grid-2):**

**Левая — Очередь задач (60% ширины):**
```
Табы: Срочные (12) | Сегодня (8) | Эта неделя (23) | Все

┌─ CRITICAL ─────────────────────────────────────────┐
│ 🔴 Каримова А. — УЗИ II триместр просрочено 3 дня  │
│    Беременность · 24 нед · Adherence 45%           │
│    [📞 Позвонить] [📅 Записать] [⋯]               │
├─ HIGH ─────────────────────────────────────────────┤
│ 🟠 Алиева Д. — неявка на приём гинеколога          │
│    Беременность · 16 нед · Adherence 72%           │
│    [📞 Позвонить] [💬 SMS] [⋯]                    │
├─ MEDIUM ───────────────────────────────────────────┤
│ 🔵 Жумабаева К. — подключение, 8 недель           │
│    Новая семья · Маршрут не начат                  │
│    [▶️ Начать маршрут] [📞 Позвонить] [⋯]         │
└────────────────────────────────────────────────────┘
```
Каждая задача: `.app-card-interactive` + `.priority-border--{level}` + `.status-badge`
Drag-and-drop: vue-draggable-plus для смены приоритетов

**Правая — Расписание на день (40%):**
```
Timeline вертикальный:
09:00  ● Звонок — Каримова А. (просрочено)
10:00  ● Подключение — Жумабаева К.
11:30  ○ Напоминание — Нурланова С. (автоматическое)
14:00  ● Проверка adherence — 5 семей
16:00  ○ Отчёт для руководителя
```

**Нижняя зона:**
```
Activity Feed — последние 10 действий:
«Каримова А. подтвердила запись на УЗИ · 2 мин назад»
«Push-уведомление отправлено Алиевой Д. · 15 мин назад»
«Новая семья: Жумабаева К. зарегистрирована · 1 час назад»
```

### 13.2 Family Dashboard (приложение мамы) — «Мой маршрут»

**Mobile-first. PWA. Каждый экран — максимум 1 скролл.**

**Главный экран:**
```
┌─────────────────────────────────┐
│ 👋 Привет, Айгерим!            │
│ Алиса · 4 мес. 12 дней         │
│                                 │
│ ┌─ Adherence сегодня ─────────┐ │
│ │ ████████████░░ 2/3 принято  │ │
│ │ Витамин D ✓  Железо ⏳      │ │
│ │ Магний B6 · через 2 часа    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─ Ближайшее ─────────────────┐ │
│ │ 🩺 Педиатр — СЕГОДНЯ 14:00  │ │
│ │ 💉 АКДС #2 — через 5 дней  │ │
│ │ 🔬 ОАК — через 8 дней      │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─ Маршрут прогресс ──────────┐ │
│ │ ████████████████░░░░ 68%    │ │
│ │ 34 из 50 событий завершено  │ │
│ └─────────────────────────────┘ │
│                                 │
│ 🏆 Streak: 12 дней подряд 🔥   │
│                                 │
│ [Маршрут] [Записи] [Доки] [Я]  │
└─────────────────────────────────┘
```

**Маршрут — Timeline с этапами:**
```
Визуальный timeline (вертикальный скролл):

🟣 ПЛАНИРОВАНИЕ (завершено ✓)
│  ✓ Регистрация · 15 мар
│  ✓ Расчёт ПДР: 20 дек
│  ✓ Назначен куратор: Др. Алия К.

🩷 БЕРЕМЕННОСТЬ (в процессе ●)
│  ✓ Фолиевая кислота · старт
│  ✓ УЗИ 12 нед · скрининг нормa
│  ✓ ОАК + биохимия · в норме
│  ● УЗИ 20 нед — ЗАВТРА
│  ○ ОАК 24 нед — через 4 нед
│  ○ Глюкозотолерантный тест — 26 нед
│  ○ УЗИ 32 нед
│  ...

🫀 РОДЫ (будущее ○)
│  ○ Подготовка выписки
│  ○ Первичный осмотр новорождённого
│  ○ Скрининг слуха
│  ...

💙 ПЕРВЫЙ ГОД (будущее ○)
│  ○ БЦЖ · при рождении
│  ○ Гепатит B #1
│  ...
```
Каждый этап — свой цвет из `--color-stage-*`. Выполненные — ✓ с мягким зелёным, текущие — pulsing dot, будущие — серые.

**Экран назначений (лекарства):**
```
┌─ Сегодня ─────────────────────┐
│                                │
│ 08:00  Витамин D3  ✅ Принято  │
│ 14:00  Железо      🟡 Скоро   │
│ 20:00  Магний B6   ⚪ Ожидает │
│                                │
│ Серия: 12 дней без пропусков 🔥│
│                                │
│ ┌─ Статистика за месяц ──────┐ │
│ │ ████████████████████░ 94%   │ │
│ │ 28 из 30 приёмов            │ │
│ └─────────────────────────────┘ │
└────────────────────────────────┘
```
Каждое назначение: swipe-to-confirm «Принял» или tap кнопку.
Streak-огонь (.streak-fire из app.css) на серии без пропусков.
Gamification: «12 дней подряд! 🔥 Ваш врач видит это!»

**Экран документов:**
```
Категории-табы: Все | Анализы | УЗИ | Прививки | Выписки

Grid карточек:
┌──────────┐ ┌──────────┐ ┌──────────┐
│ 📄 ОАК   │ │ 🔬 УЗИ   │ │ 💉 БЦЖ   │
│ 15 мар   │ │ 12 нед   │ │ 01 янв   │
│ Норма ✓  │ │ Скрининг │ │ Серия #  │
└──────────┘ └──────────┘ └──────────┘

[📷 Сфотографировать документ]
```

### 13.3 Doctor Dashboard — «Мои пациенты»

**Desktop-first. Информационная плотность выше.**

**Главный экран — «Сегодня»:**
```
┌─ KPI ─────────────────────────────────────────────────────┐
│ 👥 Пациентов: 34   │ 📅 Сегодня: 8 визитов  │ 📊 Adherence: 91% │
└───────────────────────────────────────────────────────────┘

┌─ Расписание сегодня ──────────────────────────────────────┐
│ 09:00  Каримова А. · Беременность 24 нед · УЗИ           │
│        Adherence 45% ⚠️ · Пропустила 2 визита            │
│        [📋 Маршрут] [📁 Документы] [💊 Назначения]       │
│                                                           │
│ 10:30  Алиева Д. · Беременность 16 нед · Плановый осмотр │
│        Adherence 92% ✓ · Всё по графику                  │
│        [📋 Маршрут] [📁 Документы] [💊 Назначения]       │
│                                                           │
│ 12:00  Нурланова С. · Малыш 6 мес · АКДС #3              │
│        Adherence 98% ✓ · Вес/рост в норме                │
│        [📋 Маршрут] [📁 Документы] [📈 Развитие]        │
└───────────────────────────────────────────────────────────┘
```

**Профиль пациента — полная медицинская карта:**
```
┌─ Header ──────────────────────────────────────────────────┐
│ Каримова Айгерим · 28 лет · Беременность 24 нед          │
│ Координатор: Динара С. · Куратор: Др. Алия К.            │
│ Adherence: 45% ⚠️ · 3 пропущенных визита                │
└───────────────────────────────────────────────────────────┘

Табы: [Маршрут] [Хронология] [Назначения] [Документы] [Развитие]

Маршрут — timeline с фокусом на медицинские данные
Хронология — все действия семьи (что принимали, что пропускали)
Назначения — текущие + история. Кнопка «Добавить назначение»
Документы — все анализы, УЗИ, выписки
Развитие — рост/вес ребёнка, графики, milestones
```

### 13.4 Admin Dashboard — «Бизнес-аналитика»

**Desktop-only. Графики ECharts. Данные = деньги.**

**Главный экран:**
```
┌─ KPI (4 колонки) ─────────────────────────────────────────┐
│ MAU: 1,247     │ Retention 6м: 87%  │ LTV: 1.8M ₸  │ NPS: 72  │
│ +12% ↑         │ +4% ↑              │ +15% ↑        │ +3 ↑     │
└───────────────────────────────────────────────────────────────┘

┌─ Графики (2 колонки) ────────────────────────────────────────┐
│                                                              │
│  [Retention Heatmap]          │  [Funnel Chart]              │
│  Когорты по месяцам           │  100 → 55 → 33 → 15 → 5     │
│  поступления. Цвет: от        │  Где теряются семьи?         │
│  красного до голубого.         │                              │
│                               │                              │
│  [Revenue Trend]              │  [Adherence Distribution]    │
│  MRR по месяцам, bar+line     │  Histogram: сколько семей    │
│                               │  на каком % adherence        │
└──────────────────────────────────────────────────────────────┘

┌─ Алерты ─────────────────────────────────────────────────────┐
│ ⚠️ 12 семей с adherence < 50% — координатор уведомлён       │
│ 🔔 3 семьи не были на визите > 30 дней — требуется звонок   │
│ 💰 5 семей с просроченной оплатой — отправить напоминание   │
└──────────────────────────────────────────────────────────────┘
```

**White-label настройки (УНИКАЛЬНАЯ ФИЧА):**
```
┌─ Бренд клиники ──────────────────────────────────────────────┐
│                                                              │
│ Логотип:    [Upload / Preview]                               │
│ Primary:    [Color Picker] #2A9D8F (Рахат) / #1E3A5F (IRM)  │
│ Домен:      app.rahat.kz ✓ настроен                         │
│ Название:   «Клиника Рахат — Маршрут заботы»                │
│                                                              │
│ Preview:                                                     │
│ ┌─────────────────────────────────┐                          │
│ │ 🏥 Клиника Рахат                │                          │
│ │ Мой маршрут · 16 неделя         │                          │
│ │ [Записаться] ← цвет клиники    │                          │
│ └─────────────────────────────────┘                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 14. SEED-ДАННЫЕ ДЛЯ ТЕСТИРОВАНИЯ

### 14.1 Файл: `server/api/dev/seed.post.ts`

**Состав:**
- 1 клиника («Мать и Дитя», Алматы)
- 3 координатора
- 5 врачей (гинеколог, педиатр, неонатолог, УЗИ-специалист, лаборант)
- 30 семей на разных этапах маршрута:
  - 8 — планирование/ранняя беременность
  - 10 — беременность (разные триместры)
  - 5 — после родов (0–6 мес)
  - 4 — малыш (6–12 мес)
  - 3 — тоддлер (12–24 мес)
- 150+ событий маршрута (визиты, анализы, прививки)
- 90+ записей приёма лекарств (PrescriptionLog)
- 50+ документов
- 200+ записей ActivityLog
- 1 admin

**Ключевые персонажи:**
- **Каримова А.** — проблемная: adherence 45%, 3 пропущенных визита, координатор уведомлён → для early warning
- **Нурланова С.** — идеальная: adherence 98%, streak 45 дней, все прививки в срок → для демо
- **Жумабаева К.** — новая: только подключилась, маршрут не начат → для empty state тестирования

**Все даты — относительные** (today, yesterday, `sub(new Date(), { days: 3 })`)

---

## 15. ОБНОВЛЁННЫЕ ПРИОРИТЕТЫ РЕАЛИЗАЦИИ

| # | Задача | Детали |
|---|--------|--------|
| 1 | **Установить библиотеки** | @vueuse/motion, countup.js, vue3-lottie, vue-echarts, auto-animate, vue-draggable-plus |
| 2 | **Скачать Lottie-анимации** | 10 файлов из LottieFiles для empty states, loading, achievements |
| 3 | **Скачать SVG-иллюстрации** | unDraw/Storyset — hero блоки, онбординг, /for-families |
| 4 | **Hero → GSAP animated route** | Маршрут-timeline анимируется при скролле, counter-up метрики, typewriter subtitle |
| 5 | **DemoModal → 3 интерактивных прототипа** | Coordinator: очередь задач. Family: маршрут + «Принять витамин». Doctor: расписание. |
| 6 | **Секции модулей → анимации** | Care Plan: events сыплются в timeline. Adherence: 45%→94%. Coordinator: задачи сортируются. |
| 7 | **/for-clinics → 9 секций** | Убрать дубли, добавить parallax + tilt cards + Lottie |
| 8 | **/for-families → 6 секций** | Эмоции, Storyset иллюстрации, анимированный щит вакцинации |
| 9 | **layouts/app.vue** | Glassmorphism sidebar + topbar + bottom nav + data-role + stagger-list |
| 10 | **Coordinator dashboard** | KPI row (CountUp + trends) + задачи с drag-and-drop + timeline дня + activity feed |
| 11 | **Family dashboard** | Mobile PWA, streak fire, adherence swipe-to-confirm, Lottie empty states |
| 12 | **Admin dashboard + ECharts** | Retention heatmap, funnel, LTV bars, NPS gauge, white-label preview |
| 13 | **Doctor dashboard** | Расписание дня, профиль пациента с табами, timeline хронологии |
| 14 | **Seed-скрипт** | 30 семей, 150+ событий, 3 персонажа (проблемная, идеальная, новая) |

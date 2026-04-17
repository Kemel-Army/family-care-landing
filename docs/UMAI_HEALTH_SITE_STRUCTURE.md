# UMAI Health — Полная структура и анатомия сайта

> **Стек**: Nuxt 4 + @nuxt/ui + @nuxt/image + @nuxt/fonts + GSAP + ScrollTrigger  
> **Шрифты**: Playfair Display (display), DM Sans (heading), Inter (body)  
> **Палитра**: lavender primary `#8B7EC8`, rose secondary `#E8A0BF`, warm accent, blue accent, фон `#FEFCFF`  
> **Иконки**: Lucide (bundled client-side, ~60 иконок)

---

## Оглавление

1. [Архитектура и навигация](#1-архитектура-и-навигация)
2. [Система анимаций (composables)](#2-система-анимаций-composables)
3. [UI-компоненты (переиспользуемые)](#3-ui-компоненты-переиспользуемые)
4. [SVG-компоненты (иллюстрации)](#4-svg-компоненты-иллюстрации)
5. [Главная страница `/`](#5-главная-страница-)
6. [Страница «Для клиник» `/for-clinics`](#6-страница-для-клиник-for-clinics)
7. [Страница «Для родителей» `/for-families`](#7-страница-для-родителей-for-families)
8. [CSS Design System](#8-css-design-system)
9. [Сводная таблица анимаций](#9-сводная-таблица-анимаций)

---

## 1. Архитектура и навигация

### Layout: `landing.vue`
- **Scroll progress bar** — фиксированная полоса вверху (`scaleX` по % прокрутки)
- **NavBar** — всегда сверху
- **`<NuxtPage />`** — контент страницы
- **FooterSection** — общий подвал
- При смене роута — `scrollTo(top)` + переинициализация scroll-reveal анимаций
- Page transition: `page-fade` (opacity out-in)

### NavBar
| Элемент | Описание |
|---------|----------|
| Логотип | `UMAI Health` + иконка `lucide:heart-pulse` с gradient-фоном |
| Табы | Pill-навигация: **Платформа** `/`, **Для клиник** `/for-clinics`, **Для родителей** `/for-families` |
| CTA | `Запросить демо` → `#contact` (gradient кнопка) |
| Scroll-эффект | `backdrop-filter: blur(16px)`, transparent → solid bg при скролле >20px |
| Мобилка | Burger → slide-down меню (`translateY(-8px)` + opacity transition) |

### Структура страниц

```
/ (index)                    /for-clinics               /for-families
├── HeroSection             ├── ClinicHeroSection       ├── FamilyHeroSection
├── TrustBadgesSection      ├── ClinicProblemsSection   ├── FamilyEmotionSection
├── WhatIsSection           ├── ClinicWhatIsSection     ├── FamilyAppShowcaseSection
├── ProblemSection          ├── ClinicModulesDeepDive   ├── DayInLifeSection
├── HowItWorksSection       ├── ClinicAnalyticsShowcase ├── FamilyDocumentsSection
├── ModulesShowcase         ├── UnitEconomicsSection    ├── FamilyGrowingChildSection
├── CtaSplitSection         ├── ClinicImplementation    ├── FamilyVaccinationSection
├── FooterSection (layout)  ├── ClinicCustomization     ├── FamilySecuritySection
                            ├── ClinicSecuritySection   ├── FamilyFaqSection
                            ├── ClinicFaqSection        ├── FamilyCtaSection
                            ├── ClinicCtaSection        └── FooterSection (layout)
                            └── FooterSection (layout)
```

---

## 2. Система анимаций (composables)

### `useScrollReveal` — глобальный scroll-reveal
- Сканирует весь DOM при mount / route change
- **`data-reveal`** атрибут на элементе → GSAP ScrollTrigger, once, start: `top 88%`
- **`data-stagger`** атрибут на контейнере → дети анимируются с задержкой 0.15s
- 7 пресетов:

| Пресет | Начальное состояние |
|--------|-------------------|
| `fade-up` | `opacity: 0, y: 40` |
| `fade-down` | `opacity: 0, y: -40` |
| `fade-left` | `opacity: 0, x: -60` |
| `fade-right` | `opacity: 0, x: 60` |
| `scale-in` | `opacity: 0, scale: 0.85` |
| `blur-in` | `opacity: 0, filter: blur(10px)` |
| `clip-up` | `clipPath: inset(100% 0 0 0)` |

- Legacy фоллбэк: `.reveal` / `.reveal-stagger` через IntersectionObserver + `.is-visible`
- `prefers-reduced-motion` → мгновенная отрисовка

### `useGsap` — singleton GSAP + ScrollTrigger
- Ленивая регистрация `ScrollTrigger` один раз на клиенте
- Возвращает `{ gsap, ScrollTrigger }` для использования в компонентах

### `useCountUp` — анимация числового счётчика
- IntersectionObserver (threshold: 0.3) → GSAP `power2.out` tween `0 → target`
- Поддержка `prefix`, `suffix`, `separator` (пробел), `decimals`
- CSS-импульс `number-pulse` (scale 1→1.08) по завершении
- `prefers-reduced-motion` → мгновенное значение

### `useMorph` — SVG path morphing
- Морфит SVG path `d` атрибут между массивом состояний
- `morphTo(index)` — анимация к конкретному состоянию (0.8s, `power2.inOut`)
- `morphByProgress(0–1)` — привязка к scroll

### `useSvgLineDraw` — SVG stroke drawing
- Находит paths по `selector`, вычисляет `getTotalLength()`
- GSAP ScrollTrigger once → `strokeDashoffset: totalLength → 0`

---

## 3. UI-компоненты (переиспользуемые)

### `AnimatedCounter`
- **Props**: `target`, `prefix`, `suffix`, `duration` (1800ms)
- **Что делает**: число от 0 до target с `requestAnimationFrame` + ease-out cubic
- **Визуал**: `font-display`, `tabular-nums`, формат `ru-RU`

### `GradientBlob`
- **Props**: `top/left/right/bottom`, `size` (400px), `color`, `opacity` (0.5), `animated`, `duration` (20s)
- **Что делает**: размытый цветной blob для декоративного фона
- **Визуал**: `blur(80px)`, `position: absolute`, CSS `blob-drift` + `blob-morph` анимации

### `SectionWrapper`
- **Props**: `title`, `subtitle`, `badge`, `alternate`, `gradient`
- **Что делает**: обёртка секции с header (badge + title + subtitle) + slot контента
- **Визуал**: центрированный header, `clamp`-шрифты, badge с primary-light bg

### `PhoneMockup`
- **Props**: `small` (220×440 vs 280×560)
- **Что делает**: iPhone-подобный фрейм со слотом для контента экрана
- **Визуал**: белый корпус, radius 36px, notch, home bar, box-shadow

### `StatsCounter`
- **Props**: `target`, `prefix`, `suffix`, `label`, `sublabel`, `icon`, `iconBg`
- **Что делает**: иконка + анимированное число + подпись (через `useCountUp`)

### `TestimonialCard`
- **Props**: `name`, `role`, `clinic`, `quote`, `rating` (звёзды), `metric`, `metricLabel`, `avatarColor`
- **Что делает**: карточка отзыва с аватаром-инициалами, цитатой, рейтингом

### `TimelineConnector`
- **Props**: `direction`, `height`, `width`, `color`, `shouldAnimate`
- **Что делает**: SVG-линия между шагами (через `useSvgLineDraw`)

---

## 4. SVG-компоненты (иллюстрации)

### `TimelinePhone` — Hero-иллюстрация
- **Где**: Hero главной страницы
- **Содержание**: телефон 180×360, 5 медицинских событий на таймлайне (гинеколог/анализ/УЗИ/АКДС/педиатр), notification «Завтра: УЗИ», prescription «Витамин D3 — 08:00», 4 floating icons
- **Анимации**: GSAP timeline: line-draw → dots stagger → notification slide-down (back.out) → prescription fade → checkmark stroke-draw. CSS: `blob-breathe` (6s), `float-icon` (3.5s translateY)

### `ChaosToOrder` — Метафора проблемы
- **Где**: ProblemSection главной страницы
- **Содержание**: Слева — хаос (бумаги, 5 чатов, рассыпанные таблетки), стрелка, справа — порядок (папка, чистый экран, галочка)
- **Анимации**: GSAP timeline scroll-triggered: chaos explode → стрелка fade → order converge

### `HandWithPhone` — Hero для семей
- **Где**: FamilyHeroSection
- **Содержание**: SVG-рука с телефоном, экран «Ваш малыш: 4 мес. 12 дней», 3 event-карточки (Витамин D/Педиатр/Анализ), notification + конфетти
- **Анимации**: 7-фазный GSAP timeline: рука → телефон → экран → карточки stagger → notification → конфетти

### `BurningMoney` — Потери клиники
- **Где**: ClinicProblemsSection
- **Содержание**: стопка из 5 банкнот со знаком ₸, счётчик до `43 000 000 ₸/год`
- **Анимации**: GSAP ScrollTrigger scrub: банкноты улетают по одной (y, opacity, rotation)

### `LossFunnel` — Воронка потерь
- **Где**: ClinicLossFunnelSection
- **Содержание**: 5 баров-ступеней: 100 → 55 → 33 → 15 → 5 семей, recovery-состояние: 90 → 75 → 60
- **Анимации**: GSAP ScrollTrigger once: recovery — бары расширяются, fill меняет цвет на teal, labels обновляются cascade 0.3s

### `ImmunityShield` — Щит вакцинации
- **Где**: FamilyVaccinationSection
- **Содержание**: SVG щит 120×150 с gradient-заполнением + checkmark
- **Анимации**: GSAP ScrollTrigger scrub: `clipPath` высота 0→150. CSS: `draw-check`, `pulse-ring`

### `ModuleIcons` — 8 модулей
- **Где**: ModulesShowcase главной
- **Содержание**: grid 4×2 — CarePlan, Timeline, Prescriptions, Appointments, Archive, Vaccinations, Coordinator, Analytics
- **Анимации hover** (GSAP для каждого модуля): rotation (gear), strokeDraw (timeline), pill-bounce (rx), rotationY: 180 (calendar), folder-open (-3°), syringe (y:5), checklist-sequential (dashoffset), bar-grow (scaleY)

### `WhiteLabelDemo` — Демо white-label
- **Где**: ClinicCustomizationSection
- **Содержание**: телефон 200×380, 3 темы клиник: «Рахат» (#2A9D8F), «Керуен» (#1E40AF), «IRM» (#059669)
- **Анимации**: `setInterval(3s)` автоциклинг тем, pause/resume при mouse. CSS `transition: fill 0.5s`

---

## 5. Главная страница `/`

### 5.1 HeroSection
**Контент:**
- **H1**: `Цифровая платформа сопровождения семьи от зачатия до 2 лет`
- **Subtitle**: `Единый цифровой маршрут для клиники и семьи: назначения, напоминания, анализы, развитие ребёнка`
- **CTA**: `Для клиник` → `/for-clinics` (gradient pill), `Для родителей` → `/for-families` (outline pill)

**Визуал:**
- Grid `1fr auto`, min-height 100vh, padding-top 140px
- Справа — `TimelinePhone` SVG
- 2 декоративных `GradientBlob` (primary 500px 22s, secondary 400px 18s)
- Стрелки на кнопках двигаются `translateX(3px)` при hover

**Анимации:** `data-reveal="fade-up"` с задержками 150ms, 300ms

---

### 5.2 TrustBadgesSection
**Контент — 4 badge:**

| Число | Описание | Доля кольца |
|-------|----------|-------------|
| `40+` | Недель покрыто | 40/52 |
| `18+` | Прививок по нацкалендарю | 18/20 |
| `8` | Модулей в MVP | 8/10 |
| `24/7` | Доступ | 24/24 |

**Визуал:**
- Grid 4 колонки (2 на mobile), `margin-top: -40px` перекрытие с hero
- Каждый badge: SVG кольцо `r=34` с цветной progress-дугой + число в центре + подпись

**Анимации:**
- GSAP `countUp` (snap к целым, 1.5s, power2.out) + SVG stroke-dashoffset ring fill
- IntersectionObserver (threshold: 0.3), одноразовый запуск
- `data-stagger="scale-in"`

---

### 5.3 WhatIsSection — «Что такое UMAI Health»
**Контент:**
- Badge: `О платформе`
- **3 карты**:

| Карта | Иллюстрация | Описание |
|-------|-------------|----------|
| **Journey Engine** | SVG serpentine path с маркерами | Платформа знает, на каком этапе семья, и автоматически выстраивает следующие шаги |
| **Coordinator Panel** | SVG task list | Координатор видит все семьи, их прогресс и вовремя вмешивается |
| **Family App** | SVG mini phone | Мобильное приложение — маршрут, назначения, документы, уведомления |

**Анимации hover (GSAP):**
- Journey Engine: маркер бежит по SVG path (`getPointAtLength`), milestones подсвечиваются
- Coordinator: задача улетает, остальные сдвигаются вверх, появляется checkmark
- Family App: контент в phone clip прокручивается (`y: -60`)
- Сброс при `mouseleave`

---

### 5.4 ProblemSection — «Знакомая ситуация?»
**Контент:**
- **Боли семей (4)**:
  - «Что дальше?» — после визита нет плана
  - Анализы разбросаны по 5 чатам
  - Забыла, давала ли витамин D утром
  - После родов осталась без поддержки клиники
- **Боли клиник (4)**:
  - 67% семей уходят после родов
  - Координатор тратит 4 часа/день на звонки
  - Нет видимости в retention и adherence
  - Данные пациентов в 5+ каналах без аналитики

**Визуал:**
- Grid `1fr auto 1fr` — семьи ← `ChaosToOrder` SVG → клиники
- Красные `lucide:x` иконки, иконки колонок: `lucide:users`, `lucide:stethoscope`

**Анимации:** `data-reveal="fade-right"`, `"scale-in"`, `"fade-left"`

---

### 5.5 HowItWorksSection — Scroll-driven timeline
**Контент — 5 точек:**

| Этап | Иконка morphs | События |
|------|--------------|---------|
| Зачатие | 2 кольца → слияние | Регистрация семьи, определение LMP/EDD |
| Беременность | Силуэт → живот | Скрининги, анализы, УЗИ по графику |
| Роды | Открытые руки → ребёнок | Подготовка к родам, выписка, первый осмотр |
| 0–12 мес | Лежит → сидит → ползёт | Прививки, педиатр, витамины |
| 12–24 мес | Стоит → шагает | Ревакцинация, развитие, контрольные визиты |

**Анимации:**
- **GSAP ScrollTrigger (scrub: 1)**: прогресс-линия `strokeDashoffset: 1000 → 0`
- **SVG morph**: иконки каждой точки морфируются через `useMorph` по скроллу
- Cards: `opacity 0→1, scale 0.9→1` при активации

---

### 5.6 ModulesShowcase — 8 модулей MVP
**Контент:**
- Badge: `Платформа`, Title: `8 модулей MVP`
- Делегирует в `ModuleIcons` SVG (8 карточек с hover-анимациями)

| Модуль | Hover-анимация |
|--------|---------------|
| Care Plan Engine | Gear rotation |
| Timeline | Stroke draw |
| Prescriptions | Pill bounce |
| Appointments | Flip rotationY:180 |
| Archive | Folder open (-3°) |
| Vaccinations | Syringe dip (y:5) |
| Coordinator | Checklist sequential draw |
| Analytics | Bar grow (scaleY 0.3→1) |

---

### 5.7 CtaSplitSection — Развилка
**Контент:**

| Карта | Title | Описание | SVG |
|-------|-------|----------|-----|
| Для клиник → `/for-clinics` | Вы клиника? | Увеличить retention, автоматизировать сопровождение | Dashboard bars + trend line |
| Для семей → `/for-families` | Вы родитель? | Ничего не пропустить в маршруте ребёнка | Phone frame + timeline items |

**Анимации:**
- CSS hover на clinic: bars `scaleY(1.05–1.2)` + trend-line stroke-dashoffset draw (0.8s)
- CSS hover на family: phone items opacity 0.6→1, notification fade-in (0.4s)
- **Flex grow/shrink**: `:hover → flex: 1.15`, `:not(:hover) → flex: 0.85`

---

### 5.8 FooterSection
**Контент:**
- 4 колонки: лого + описание | Платформа (3 ссылки) | Страницы (2 ссылки) | Контакты
- `info@umai-health.kz`, `+7 700 123 45 67`, `Алматы, Казахстан`
- © {year} UMAI Health. Сделано с заботой в Казахстане.

---

## 6. Страница «Для клиник» `/for-clinics`

### 6.1 ClinicHeroSection
**Контент:**
- **H1**: `Удерживайте семью от беременности до 2 лет ребёнка`
- **3 KPI**: `×3–5 LTV семьи` | `–70% Ручной работы` | `85% Клиник ищут digital`
- **CTA**: `Запросить демо` → `#clinic-cta`

**Визуал:** Grid `1fr auto`, min-height 80vh, gradient mesh bg, `GradientBlob` (20s), KPI-карточки с surface-bg

**Анимации:** `data-reveal="fade-up"`, `data-stagger="fade-up"`, `data-reveal="fade-left"`

---

### 6.2 ClinicProblemsSection — «Что теряет клиника»
**Контент:**
- **5 болей**: Потеря семей, Ручная координация, Нет journey analytics, Нет proactive outreach, Упущенная выручка
- **Встроенная воронка**: 100 → 55 → 33 → 15 → 5 семей
- **Revenue loss**: `AnimatedCounter → 43 млн ₸/год`

**Визуал:** Grid `1fr auto`, воронка с gradient-барами убывающей ширины, `BurningMoney` SVG справа, loss card с `border-left: 4px danger`

**Анимации:** CSS `@keyframes pulse-dot` на индикаторах, `AnimatedCounter target=43`

---

### 6.3 ClinicWhatIsSection — «3 рабочих стола»
**Контент — 3 таба:**

| Таб | SVG-мокап | Bullets (4) |
|-----|-----------|-------------|
| **Координатор** | Task list с приоритетами | Pipeline, touch points, назначения, alerts |
| **Руководитель** | Bar chart + polyline | Когорты, air-traffic retention, ROI, revenue forecast |
| **Врач** | Patient card accordion | Анамнез, результаты, рекомендации, маршрут |

**Анимации GSAP при смене таба:**
- Координатор: task rows slide-in (x:-20→0) + dot цвет danger→success
- Руководитель: bars `scaleY: 0→1` + polyline stroke-dashoffset line-draw
- Врач: accordion sections expand (height:0→32) + text fade-in
- Vue `<Transition name="cross">` (crossfade opacity 0.35s)

---

### 6.4 ClinicModulesDeepDiveSection — 8 модулей (accordion)
**Контент — 8 expandable карточек:**

| # | Модуль | Subtitle |
|---|--------|----------|
| 1 | Care Plan Engine | Маршрут для каждой семьи |
| 2 | Coordinator Panel | Один экран — все семьи |
| 3 | Analytics | Данные, которые меняют решения |
| 4 | Smart Appointments | Запись без звонков |
| 5 | Medical Archive | Все документы пациента |
| 6 | Smart Prescriptions | Назначения без бумаги |
| 7 | Vaccination Calendar | 18+ прививок — автоматически |
| 8 | Timeline | Хроника жизни семьи |

Каждый: SVG wireframe-мокап (320×200) + 4–5 bullet-points

**Анимации:** Vue `<Transition name="expand">` (max-height 0→800px + opacity), chevron rotate 180°

---

### 6.5 ClinicAnalyticsShowcase — Dashboard demo
**Контент:**
- **4 KPI**: Retention 87%, Визиты 94%, Вакцинация 98%, NPS 4.8/5
- **Dashboard mock** — 3 таба:
  - Retention: cohort bars (4 месяца)
  - Задачи: priority list (danger/warning/success/blue)
  - Revenue: 3-column metrics
- **4 фичи**: Когортный анализ, Конверсия воронки, Экспорт, Realtime

**Анимации:** `AnimatedCounter` для KPI, `data-reveal="blur-in"` на dashboard, Vue `<Transition name="dash-fade">`, cohort bars `transition: width 0.6s`

---

### 6.6 UnitEconomicsSection — ROI калькулятор
**Контент:**
- Range slider: 10–100 семей (step 5, default 30)
- **Формула**: `revenue = families × 12 × 0.37 × 660,000 ₸`
- **Результат**: Потенциальная выручка | Стоимость платформы (1,200,000 ₸/год) | ROI %

**Анимации:** GSAP `gsap.to()` для animated counter при изменении slider (0.6s power2.out)

**Визуал:** Max-width 680px, centered. ROI positive: green border + glow

---

### 6.7 ClinicImplementationSection — «4 шага»
**Контент:**

| Шаг | Длительность | Описание |
|-----|-------------|----------|
| Demo | 1 день | Video call, показываем платформу |
| Setup | 2–4 недели | Настройка, интеграция, брендинг |
| Training | 1 неделя | Обучение координаторов |
| Pilot | 3 мес | Запуск на 10–20 семей |

**Анимации:**
- **Desktop**: GSAP ScrollTrigger (scrub 0.5) — progress bar + activateStep по скроллу
- **Mobile**: IntersectionObserver с sequential 400ms delays
- Stepper fill bar CSS transition, dot border + SVG scale

---

### 6.8 ClinicCustomizationSection — White-label
**Контент:**
- **Title**: `Ваш бренд, ваши цвета, ваш логотип`
- **Subtitle**: `Семья видит приложение вашей клиники`
- **4 bullet**: Логотип/цвета/шрифты, Свой домен, Свои маршруты, Свои уведомления
- `WhiteLabelDemo` SVG — 3 бренда автоциклом каждые 3s

---

### 6.9 ClinicSecuritySection — Безопасность (компактная)
**Контент — 4 пункта:**
| Пункт | SVG icon |
|-------|----------|
| Шифрование | Lock |
| Row Level Security | Shield rows |
| Audit Log | Document trail |
| GDPR-ready | Globe checkmark |

**Визуал:** 4-column grid, min-width, SVG icons 48×48

---

### 6.10 ClinicFaqSection — 7 вопросов
| Вопрос |
|--------|
| Сколько стоит UMAI Health? |
| Как быстро можно внедрить? |
| Интеграция с МИС? |
| Безопасность данных? |
| Можно без IT-отдела? |
| Можно свой бренд? |
| Какая поддержка? |

- Первый вопрос открыт по умолчанию
- Accordion с Vue `<Transition name="faq-expand">`

---

### 6.11 ClinicCtaSection — Форма заявки
**Контент:**
- **Title**: `Запросить демо`
- **Subtitle**: `Мы свяжемся в течение 1 рабочего дня`
- **Поля**: Имя, Клиника, Телефон, Email (2-col grid)
- **Кнопка**: `Запросить демо` → «Отправлено ✓»

**Визуал:** Max-width 560px, `landing-card`. Input focus: primary border + glow

---

## 7. Страница «Для родителей» `/for-families`

### 7.1 FamilyHeroSection
**Контент:**
- **H1**: `Вся забота о малыше — в одном приложении`
- **Subtitle**: `Ваша клиника ведёт вас по персональному маршруту от беременности до 2 лет`
- **CTA**: `Узнайте у вашей клиники` → `#family-faq`
- Справа: `HandWithPhone` SVG (7-фазная GSAP анимация)

---

### 7.2 FamilyEmotionSection — «Знакомые тревоги»
**Контент — 5 болей-чекбоксов:**
1. Пропустила скрининг — не знала, что пора
2. Не помню, какая прививка следующая
3. Потеряла результаты УЗИ перед приёмом
4. Не понимаю, нормально ли развивается ребёнок
5. После выписки клиника просто забыла о нас

**Resolve**: `UMAI Health решает это.`

**Анимации (CSS-only):**
- Hover: SVG чекмарк `stroke-dashoffset: 24→0` (рисуется галочка)
- Hover: `text-decoration: line-through` зелёным цветом
- `data-stagger="fade-up"` на список

---

### 7.3 FamilyAppShowcaseSection — «Что даёт приложение»
**Контент — 3 phone-экрана:**

| Таб | Контент экрана |
|-----|---------------|
| **Timeline** | 4 события: Витамин D ✓, Педиатр 10:00, АКДС #2 (5 дн), Анализ крови (20 Фев) |
| **Назначения** | 3 rx-карточки: Витамин D3 08:00 ✓, Железо 14:00 ⏳, Магний B6 20:00 ⏳ |
| **Документы** | 6 doc-thumbnails: УЗИ, ОАК, ЭКГ, Выписка, Фото, Рецепт |

**Анимации (GSAP):**
- **Prescription swipe**: `setInterval(3s)` — автоматический свайп первого ⏳ → ✓
  - `gsap.to(x:40)` → обратно + замена иконки. Когда все ✓ → сброс
- **Document scatter**: начальный разброс x/y ±120, rotation ±40°, opacity 0, scale 0.6 → `gsap.to` в нормальное положение, stagger 0.1
- IntersectionObserver threshold 0.3

**Визуал:** Desktop: 3 phone-frames flex row. Mobile: carousel с dots-навигацией

---

### 7.4 DayInLifeSection — «День с приложением»
**Контент — 4 события дня:**

| Время | Событие | Описание |
|-------|---------|----------|
| 08:00 | Витамин D — принят ✓ | Push → одно нажатие → готово |
| 10:00 | Запись к педиатру | Напоминание за 24ч, анкета заполнена |
| 14:00 | Загрузка анализа | Сфотографировали — сохранён навсегда |
| 20:00 | Вечерний магний | Последнее напоминание — спокойной ночи |

**Финал**: `Adherence сегодня: 100% 🎉`

**Анимации:**
- **Scroll-driven SVG line draw**: вертикальная линия, `lineProgress` (0→1) управляет `stroke-dashoffset`
- Dots активируются по формуле: `progress > (i + 0.5) / events.length`
- Final `.glow` при `lineProgress >= 0.95` (green box-shadow)
- `data-reveal="fade-right"` с `transitionDelay: i*150ms`

---

### 7.5 FamilyDocumentsSection — «Все документы в одном месте»
**Контент:**
- **4 категории**: Анализы (12), УЗИ (5), Выписки (3), Прививки (8)
- Каждая категория: список документов с `name`, `date`, `thumbBg`, `thumbIcon`
- **4 фичи**: Фото результатов, Быстрый поиск, Показать врачу, Привязка к маршруту

**Визуал:** Grid `1.3fr 1fr`. Слева: интерактивный файловый менеджер. Справа: feature-cards с `hover-lift`

---

### 7.6 FamilyGrowingChildSection — SVG morph child
**Контент — 5 стадий ребёнка:**

| Стадия | Возраст | SVG | События |
|--------|---------|-----|---------|
| Лежит | 0–3 мес | `childLying` | 5 визитов, 3 прививки |
| Приподымается | 3–6 мес | `childPropped` | 4 визита, 2 прививки |
| Сидит | 6–9 мес | `childSitting` | 3 визита, АКДС #3 |
| Ползает | 9–12 мес | `childCrawling` | 2 визита, КПК |
| Ходит | 12–24 мес | `childWalking` | 2 визита, ревакцинация |

**Анимации:**
- **SVG path morph по скроллу**: `scrollProgress → currentStage` → `currentPath` → `useMorph`
- IntersectionObserver + scroll listener

**Визуал:** SVG 200×150. Горизонтальная ось с dots + labels

---

### 7.7 FamilyVaccinationSection — Щит иммунитета
**Контент — 8 прививок:**

| Прививка | Статус |
|----------|--------|
| БЦЖ (Туберкулёз) | ✅ done |
| Гепатит B ×3 | ✅ done |
| АКДС ×4 | 🔵 progress |
| Полиомиелит ×4 | 🔵 progress |
| Пневмококк ×3 | ⬜ upcoming |
| КПК | ⬜ upcoming |
| Гемофильная ×3 | ⬜ upcoming |
| Гепатит A | ⬜ upcoming |

**Визуал:** Grid `auto 1fr`. Слева: `ImmunityShield` SVG (scroll-fill). Справа: список

---

### 7.8 FamilySecuritySection — «Данные под защитой»
**Контент — 3 пункта:**

| Пункт | SVG | Описание |
|-------|-----|----------|
| Данные зашифрованы | Щит + ✓ | AES-256 at rest, TLS 1.3 in transit |
| Только вы и врач | 2 человека | Ролевой доступ |
| Вы контролируете | □ + X | Удалить аккаунт в один клик |

**Анимации:**
- **Lock SVG**: IntersectionObserver → 400ms delay → shackle закрывается (path d меняется)
- **Pulse ring**: CSS `@keyframes pulse-expand` r: 25→40, opacity fade, 2s infinite (только после закрытия замка)

---

### 7.9 FamilyFaqSection — 7 вопросов
| Вопрос | Ответ (суть) |
|--------|-------------|
| Бесплатно для семьи? | Да, предоставляется клиникой |
| Как начать? | Координатор создаст аккаунт → PWA |
| Работает без интернета? | Да, PWA offline |
| Қазақша бар ма? | Пока русский, қазақша запланирован |
| Кто видит данные? | Только вы и врач |
| Добавить папу/бабушку? | Да, уровень «просмотр» |
| Удалить аккаунт? | Да, безвозвратно |

---

### 7.10 FamilyCtaSection — Финальный призыв
**Контент:**
- **H2**: `Спросите у вашей клиники о UMAI Health`
- **P**: `Приложение бесплатно для семей. Доступ — через вашу клинику.`
- **Note**: `Бесплатно · Работает offline · Все данные защищены`
- Нет кнопки/формы — только текст

---

## 8. CSS Design System

### Design Tokens (`:root`)

| Token | Значение |
|-------|----------|
| `--color-primary` | `#8B7EC8` (lavender) |
| `--color-primary-light` | `rgba(139,126,200,0.15)` |
| `--color-secondary` | `#E8A0BF` (rose) |
| `--color-accent-warm` | `#E8C170` |
| `--color-accent-blue` | `#7BB5E0` |
| `--color-success` | `#22C55E` |
| `--color-danger` | `#DC2626` |
| `--color-bg` | `#FEFCFF` |
| `--color-surface` | `#FFFFFF` |
| `--color-border` | `rgba(139,126,200,0.12)` |
| `--color-text` | `#1A1A2E` |
| `--color-text-secondary` | `#64748B` |

### Градиенты
| Имя | Значение |
|-----|----------|
| `--gradient-hero` | `linear-gradient(135deg, #FEFCFF, #F0EDFF, #FFF0F6)` |
| `--gradient-cta` | `linear-gradient(135deg, #8B7EC8, #B5A8E0)` |
| `--gradient-accent` | `linear-gradient(135deg, #E8A0BF, #E8C170)` |
| `--gradient-blue` | `linear-gradient(135deg, #7BB5E0, #8B7EC8)` |

### Utility-классы

| Класс | Описание |
|-------|----------|
| `.landing-card` | Surface bg, border, radius, padding: 24px |
| `.glass-card` | blur(12px), white/60% bg, white/20% border |
| `.hover-lift` | translateY(-6px) + shadow при hover |
| `.text-gradient` | gradient-clip text |
| `.text-gradient-shimmer` | animated gradient bg 200% (4s infinite) |
| `.btn-shimmer` | white pseudo-stripe slide на hover |
| `.gradient-border` | mask-composite trick для gradient-бордера |
| `.hero-gradient-mesh` | 18s drift анимация для hero bg |
| `.number-pulse` | scale 1→1.08 для чисел |
| `.float-up-down` | 4s translateY senoidal |
| `.marquee-track` | 30s infinite horizontal scroll |
| `.grain-overlay` | SVG noise texture |
| `.scroll-progress` | Fixed top bar, scaleX по скроллу |

### Accessibility
- 3 блока `@media (prefers-reduced-motion: reduce)`:
  - Все `animation`, `transition` отключаются
  - `.reveal`, `.reveal-stagger` → `opacity: 1, transform: none`
  - Финальный блок с `!important` на `*` — полная остановка

---

## 9. Сводная таблица анимаций

### По типам

| Тип анимации | Где используется | Composable / API |
|-------------|-----------------|------------------|
| **Scroll reveal** (GSAP ScrollTrigger once) | Все секции (data-reveal, data-stagger) | `useScrollReveal` |
| **Count up** (GSAP / rAF tween) | TrustBadges, ClinicStats, ClinicProblems, ClinicAnalytics, UnitEconomics, FamilyStats | `useCountUp` / `AnimatedCounter` |
| **SVG path morph** | HowItWorks (timeline icons), FamilyGrowingChild (ребёнок) | `useMorph` |
| **SVG line draw** (stroke-dashoffset) | HowItWorks (прогресс-линия), DayInLife (вертикальная линия), TimelinePhone (events) | `useSvgLineDraw` / manual |
| **GSAP ScrollTrigger scrub** | HowItWorks, BurningMoney, ImmunityShield, ClinicImplementation | `useGsap` |
| **GSAP timeline** (once) | ChaosToOrder, HandWithPhone, TimelinePhone | `useGsap` |
| **GSAP hover** | WhatIsSection (3 карты), ModuleIcons (8 модулей) | `useGsap` |
| **GSAP tab switch** | ClinicWhatIs (3 рабочих стола), UnitEconomics (slider) | `useGsap` |
| **Vue Transition** | FAQ (expand), Modules (expand), WhatIs (cross), ModulesDeepDive (tab-slide), Analytics (dash-fade), JourneyVisualization (tab-fade) | Vue built-in |
| **CSS keyframes** | pulse-dot, blob-breathe, float-icon, hero-gradient-mesh, number-pulse, pulse-expand, pulse-ring, draw-check | CSS |
| **CSS transition (hover)** | hover-lift, CtaSplit (flex grow), EmotionSection (line-through + checkmark draw), WhiteLabelDemo (fill 0.5s) | CSS |
| **setInterval auto-cycle** | Testimonials (carousel 4s), WhiteLabelDemo (themes 3s), FamilyAppShowcase (swipe 3s) | JS |

### По компоненту — карта анимаций

| Компонент | Анимации |
|-----------|----------|
| **NavBar** | CSS scroll-detect (blur bg), mobile menu transition |
| **HeroSection** | scroll-reveal, GradientBlob drift |
| **TrustBadgesSection** | GSAP countUp + SVG ring fill, stagger scale-in |
| **WhatIsSection** | GSAP hover (path marker, task fly, phone scroll), stagger fade-up |
| **ProblemSection** | scroll-reveal (fade-right/left/scale-in) |
| **HowItWorksSection** | ScrollTrigger scrub (line draw + morph icons), CSS active cards |
| **ModulesShowcase** | 8× GSAP hover анимаций (rotation, bounce, draw, etc.) |
| **CtaSplitSection** | CSS flex grow/shrink + hover SVG animations |
| **ClinicHeroSection** | scroll-reveal, GradientBlob |
| **ClinicProblemsSection** | BurningMoney ScrollTrigger scrub, pulse-dot CSS, AnimatedCounter |
| **ClinicWhatIsSection** | GSAP tab animations (slide-in, scaleY, accordion), Vue cross-fade |
| **ClinicModulesDeepDiveSection** | Vue expand transition, chevron rotate |
| **ClinicAnalyticsShowcase** | AnimatedCounter, Vue dash-fade, CSS bar width transition |
| **UnitEconomicsSection** | GSAP counter tween on slider change |
| **ClinicImplementationSection** | ScrollTrigger scrub (stepper), IntersectionObserver (mobile) |
| **ClinicCustomizationSection** | WhiteLabelDemo setInterval + CSS fill transition |
| **FamilyHeroSection** | HandWithPhone 7-phase GSAP timeline |
| **FamilyEmotionSection** | CSS-only (checkmark draw + line-through) |
| **FamilyAppShowcaseSection** | GSAP prescription swipe + document scatter |
| **DayInLifeSection** | Scroll-driven SVG line draw, dot activation, glow finale |
| **FamilyGrowingChildSection** | useMorph scroll-driven (5 SVG child states) |
| **FamilyVaccinationSection** | ImmunityShield ScrollTrigger scrub (fill + checkmark + pulse-ring) |
| **FamilySecuritySection** | IntersectionObserver lock close + CSS pulse-expand |
| **TestimonialsSection** | setInterval auto-scroll carousel |

---

## Неиспользуемые / альтернативные компоненты

| Компонент | Примечание |
|-----------|-----------|
| `CaseStudySection` | Не подключён ни к одной странице (2 кейса клиник с метриками) |
| `CtaSection` | Общий CTA с формой — не подключён напрямую (используется в концепции) |
| `ForFamiliesSection` | Альтернативная секция «для семей» — не подключена |
| `JourneyVisualization` | Альтернативный визуализатор маршрута с табами — не подключён |
| `TestimonialsSection` | Карусель отзывов — не подключена |
| `FaqSection` | Общий FAQ с defaults — не подключён (каждая страница имеет свой) |
| `ClinicStatsSection` | Альтернативная полоска статистики — не подключена |
| `ClinicJourneySection` | Альтернативный таймлайн глазами координатора — не подключён |
| `ClinicLossFunnelSection` | Дублирует воронку из ClinicProblemsSection — не подключён |
| `ClinicModulesDeepDive` | 11-tab вариант модулей (vs 8-accordion ClinicModulesDeepDiveSection) — не подключён к странице |
| `FamilyStatsSection` | Полоска из 5 статистик — не подключена |
| `FamilyModulesSection` | 9-tab модулей c phone-мокапами (самый большой компонент, 775 строк) — не подключён |

---

> **Итого**: 3 страницы, 15 активных секций + ~12 запасных компонентов, 8 SVG-иллюстраций, 7 UI-утилит, 5 composables, 4 data-файла с SVG paths. Все анимации уважают `prefers-reduced-motion`.

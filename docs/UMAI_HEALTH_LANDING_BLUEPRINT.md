# UMAI HEALTH — Полный Blueprint лендинга

> **Статус:** Рабочая версия v1.0  
> **Дата:** Апрель 2026  
> **Стек:** Nuxt 4 · GSAP + ScrollTrigger · Inline SVG  
> **Цель документа:** Исчерпывающая инструкция для разработки лендинга — структура, контент, анимации, SVG-иллюстрации, composables

---

## СОДЕРЖАНИЕ

1. [Диагноз текущего сайта](#1-диагноз-текущего-сайта)
2. [Принципы новой структуры](#2-принципы-новой-структуры)
3. [Главная страница `/`](#3-главная-страница-)
4. [Страница `/for-clinics`](#4-страница-for-clinics)
5. [Страница `/for-families`](#5-страница-for-families)
6. [Сводка изменений](#6-сводка-изменений)
7. [Общие принципы анимации](#7-общие-принципы-анимации)
8. [Главная `/` — анимации и SVG](#8-главная----анимации-и-svg)
9. [Страница `/for-clinics` — анимации и SVG](#9-страница-for-clinics--анимации-и-svg)
10. [Страница `/for-families` — анимации и SVG](#10-страница-for-families--анимации-и-svg)
11. [Shared SVG-иллюстрации](#11-shared-svg-иллюстрации)
12. [Composables для анимаций](#12-composables-для-анимаций)
13. [Производительность](#13-производительность)

---

## 1. Диагноз текущего сайта

85 компонентов, 62 секции на 3 страницах, ~17000 строк кода.

**Проблемы:**

- **Главная перегружена** — 21 секция, включая SWOT-анализ, MarketAnalysis, TechStack. Это контент для питч-дека инвесторам, не для клиентского лендинга.
- **Дублирование** — сравнительные таблицы, FAQ, security-секции, отзывы повторяются на всех 3 страницах с минимальными отличиями.
- **Смешение аудиторий** — главная пытается говорить одновременно с клиниками, семьями и инвесторами.
- **Нет чёткой воронки** — секции выглядят как "всё сразу", а не последовательный путь к конверсии.
- **Placeholder-данные** — клиники "Мать и Дитя", метрики, отзывы — всё вымышленное. Фейковые отзывы и партнёры вредят доверию.
- **Шаблонный визуал** — нет уникальных иллюстраций и анимаций, которые отличают от generic SaaS-лендинга.

---

## 2. Принципы новой структуры

1. **Каждая секция — одна мысль.** Не два месседжа в одном блоке.
2. **Убраны все placeholder-данные.** Фейковые отзывы, партнёры, кейсы. Когда появятся реальные — вернуть.
3. **Главная — маршрутизатор.** Не пытается продать, а объясняет суть и направляет на нужную вкладку.
4. **For-clinics — продающая.** Говорит на языке ROI, retention, LTV.
5. **For-families — эмоциональная.** Говорит на языке тревоги, спокойствия, "ничего не пропустишь".
6. **Никакого SWOT, TechStack, MarketAnalysis на сайте.** Это внутренние документы.
7. **Каждая секция усилена уникальной SVG-анимацией.** Не декоративной, а объясняющей суть секции.

---

## 3. Главная страница `/`

**Цель:** за 2 минуты объяснить суть продукта любому посетителю и направить на нужную вкладку.

### Секция 1: Hero

**Содержание:**
- Заголовок: "Цифровая платформа сопровождения семьи от зачатия до 2 лет"
- Подзаголовок: 1 предложение — "Единый цифровой маршрут для клиники и семьи: назначения, напоминания, анализы, развитие ребёнка"
- Два CTA: "Для клиник" → /for-clinics, "Для родителей" → /for-families
- Справа: анимированный SVG-телефон с живым интерфейсом

**Анимация телефона:**
- При загрузке внутри телефона рисуется timeline: линия появляется сверху вниз (stroke-dashoffset animation), на ней по одной всплывают точки-события
- Каждая точка — маленькая иконка (пробирка, шприц, стетоскоп) + короткий текст
- Когда timeline построен — сверху плавно появляется notification card: "Завтра: УЗИ 20 нед." с характерным slide-down motion как push notification
- Внизу телефона — pill-карточка назначения с анимацией checkmark: галочка рисуется одним штрихом (stroke animation)

**SVG-элементы вокруг телефона:**
- Маленькие floating иконки: сердце, пробирка, календарь, колокольчик — медленно покачиваются (CSS float animation, 3-4s cycle, разные фазы)
- Subtle gradient blob за телефоном — дышит (scale 0.95→1.05, очень медленно)

---

### Секция 2: Проблема

**Содержание:**
- Два столбца: слева 3-4 боли семьи (иконка + 1 строка), справа 3-4 боли клиники
- Между ними — вертикальная SVG-иллюстрация

**SVG "Хаос → Порядок":**

Левая сторона (семья) — SVG "Хаос":
- Разбросанные элементы: бумажка с анализом, телефон с 5 чатами, таблетки без коробки, перечёркнутый календарь
- При scroll-in элементы летят из центра наружу (explode effect)
- Красные/оранжевые accent линии, нервные

Правая сторона (клиника) — SVG "Порядок":
- Те же элементы, собранные в стройную вертикальную линию: документы в папке, телефон с одним экраном, таблетки с галочкой, календарь с точками
- При scroll-in элементы собираются из хаоса в строй (converge effect)
- Teal/green accent линии, спокойные

Transition: когда оба столбца в viewport — между ними появляется стрелка-трансформация: хаос → порядок.

---

### Секция 3: Что такое UMAI Health

**Содержание:**
- 3 карточки горизонтально: Journey Engine, Coordinator Panel, Family App
- Каждая — иконка + 2 предложения

**Анимации карточек:**

Карточка 1 — Journey Engine:
- SVG: горизонтальная дорога/тропинка с вехами
- При hover — по тропинке бежит маленький маркер (circle) от start до end, вехи подсвечиваются последовательно

Карточка 2 — Coordinator Panel:
- SVG: dashboard с 3 плашками-задачами
- При hover — верхняя задача "отлетает" вправо (completed), остальные сдвигаются вверх, снизу появляется новая

Карточка 3 — Family App:
- SVG: мини-телефон
- При hover — внутри скроллится контент (translateY animation на группе элементов внутри clipped viewBox)

---

### Секция 4: Как это работает

**Содержание:**
- Горизонтальный timeline, 5 точек: Зачатие → Беременность → Роды → 0-12 мес → 12-24 мес
- Под каждой точкой — pop-up карточка с 2-3 событиями

**Scroll-driven animation:**
- Линия timeline рисуется слева направо по мере скролла (stroke-dashoffset привязан к scrollProgress)
- Каждая точка появляется когда линия до неё дорисовалась
- Под каждой точкой — pop-up карточка, появляется с scale(0)→scale(1) и opacity

**SVG-иконки над точками (path morphing):**
- Зачатие: два кольца соединяются
- Беременность: silhouette с растущим животом (3 фазы морф)
- Роды: маленький ребёнок в руках (простой outline)
- 0-12 мес: ползущий малыш → сидящий → стоящий (3-кадровый морф)
- 12-24 мес: шагающий малыш

---

### Секция 5: Ключевые модули

**Содержание:**
- Grid 2×4: Care Plan Engine, Timeline, Smart Prescriptions, Appointments, Medical Archive, Vaccinations, Coordinator Panel, Analytics
- Каждый — иконка + название + 1 предложение

**Hover-анимации иконок:**
- Care Plan Engine: зубчатое колесо поворачивается на 60°
- Timeline: line chart рисуется
- Smart Prescriptions: таблетка подпрыгивает
- Appointments: календарная страница перелистывается
- Medical Archive: папка открывается
- Vaccinations: шприц делает "укол" вниз
- Coordinator Panel: точки в списке проставляются галочками последовательно
- Analytics: bar chart растёт

**Scroll-in:** карточки появляются парами (row by row) с stagger 100ms, slide-up + fade-in.

---

### Секция 6: Цифры

**Содержание:**
- 4 счётчика: "40+ недель покрыто", "18+ прививок по нацкалендарю", "8 модулей в MVP", "24/7 доступ"

**Анимация:**
- Каждое число имеет SVG-кольцо (circular progress) позади
- Когда секция в viewport — числа считают вверх от 0, ring заполняется по кругу
- Duration 1.5s, easeOutQuart

---

### Секция 7: CTA-разделитель

**Содержание:**
- Два больших блока: "Вы клиника?" (teal) → /for-clinics, "Вы родитель?" (coral) → /for-families

**Анимации:**

SVG в каждом блоке:
- Клиники: dashboard с графиками (svg lines animate stroke)
- Семьи: телефон с timeline (svg elements fade in)

Hover: блок слегка расширяется (flex-grow), другой сужается. Subtle, 300ms transition.

---

### Секция 8: Footer

Контакты, ссылки, копирайт. Статичный.

---

## 4. Страница `/for-clinics`

**Цель:** убедить собственника/директора клиники, что платформа решит его боль retention и даст ROI.

### Секция 1: Hero — Воронка восстановления

**Содержание:**
- Заголовок: "Удерживайте семью от беременности до 2 лет ребёнка"
- 3 KPI-карточки: "×3-5 LTV семьи", "–70% ручной работы координаторов", "85% клиник ищут digital-решение"
- CTA: "Запросить демо"

**Фоновая SVG-анимация:**
- Воронка из 5 слоёв (100 семей → 55 → 33 → 15 → 5)
- При загрузке воронка показывает потери (серые слои отпадают)
- Затем воронка "восстанавливается" — слои заполняются teal-цветом снизу вверх: 5 → 25 → 50 → 75 → 90
- Message: "С UMAI Health вы возвращаете семьи в маршрут"

---

### Секция 2: Проблема клиники — Burning Money

**Содержание:**
- 4-5 болей с иконками и 2-3 предложениями каждая: потеря семей после родов, ручная координация, нет journey analytics, нет proactive outreach, упущенная выручка
- Воронка потерь 100→55→33→15→5 интегрирована сюда как один визуал, не отдельная секция

**SVG-иллюстрация "Burning Money" (справа от текста):**
- Стопка монет/банкнот
- С каждой секундой скролла одна банкнота улетает вверх и исчезает (fade + translateY)
- Под стопкой — счётчик "Упущенная выручка: XX млн ₸/год" — число растёт
- Боли слева появляются по одной (stagger) с красной пульсирующей точкой

---

### Секция 3: Что даёт платформа — Три рабочих стола

**Содержание:**
- 3 таба: Координатор / Руководитель / Врач
- Каждый таб: мокап экрана + 3-4 bullet points

**Интерактивный переключатель ролей:**

При переключении — SVG-мокап экрана плавно морфится:

Координатор:
- Dashboard с очередью задач
- Анимация: задача из красной становится зелёной (swipe right), counter overdue уменьшается

Руководитель:
- Графики retention и revenue
- Анимация: bars растут, линия тренда поднимается

Врач:
- Карточка пациента с timeline
- Анимация: секции карточки раскрываются accordion-style

Transition между табами: crossfade 400ms.

---

### Секция 4: Модули для клиники — Deep Dive Cards

**Содержание:**
- 8 карточек модулей, раскрытие с позиции клиники
- Care Plan Engine = "автоматическая генерация маршрутов по протоколам"
- Coordinator Panel = "очередь задач с приоритетами"
- Analytics = "cohort retention, conversion, revenue per family"

**Анимация:**
- При клике карточка раскрывается в full-width блок
- FLIP animation — карточка трансформируется, остальные сдвигаются
- Каждый раскрытый модуль: слева SVG-мокап экрана, справа 4-5 bullet points
- SVG-мокап не статичный: при раскрытии элементы анимируются (числа считаются, графики рисуются, задачи появляются)

---

### Секция 5: ROI — Живой калькулятор

**Содержание:**
- Средняя стоимость pregnancy package (330-990k ₸)
- Стоимость платформы (от 1-1.5 млн/мес)
- Breakeven при удержании X семей

**Интерактив:**
- Ползунок "Количество семей в месяц": 10-100
- При движении мгновенно пересчитываются 3 числа:
  - Потенциальная выручка от удержания
  - Стоимость платформы (фиксированная)
  - ROI: (выручка - стоимость) / стоимость × 100%
- Числа анимируются при изменении (GSAP tweening)
- Когда ROI > 100% — блок подсвечивается зелёным

---

### Секция 6: Внедрение — 4 шага с прогрессом

**Содержание:**
- 4 шага горизонтально: Demo (1 день) → Setup (2-4 недели) → Training (1 неделя) → Pilot (3 мес, 50 семей)
- По 1 предложению на шаг

**Scroll-driven stepper:**
- Активный шаг перемещается слева направо при скролле
- Между шагами — линия, заполняющаяся цветом
- Активный шаг увеличивается, показывает мини-SVG:
  - Demo: экран видеозвонка
  - Setup: шестерёнки + бренд-палитра
  - Training: люди за столом
  - Pilot: ракета (маленькая, subtle)

---

### Секция 7: White-label — Живая смена бренда

**Содержание:**
- "Ваш бренд, ваши цвета, ваш логотип. Семья видит приложение вашей клиники."

**SVG-телефон с интерфейсом внутри. 3 кнопки переключения бренда:**
- При переключении цвета внутри телефона плавно меняются (CSS transition на variables)
- Логотип в header телефона fade-out → fade-in
- Название клиники меняется
- Один и тот же интерфейс, перекрашивается за 500ms
- Автоматический цикл: бренды переключаются каждые 3 секунды если не трогать

---

### Секция 8: Безопасность

**Содержание:**
- 4 иконки в строку: Шифрование, RLS, Audit log, GDPR-ready
- Без развёрнутых карточек — компактно

---

### Секция 9: FAQ

**Содержание:**
- 6-8 вопросов аккордеоном: стоимость, сроки внедрения, интеграция с МИС, что если нет IT-отдела, данные пациентов, поддержка

---

### Секция 10: CTA

**Содержание:**
- "Запросить демо"
- Форма: имя, клиника, телефон, email

---

## 5. Страница `/for-families`

**Цель:** показать маме, что приложение снимет тревогу, упростит жизнь и ничего не пропустит.

### Секция 1: Hero — Телефон в руке

**Содержание:**
- Заголовок: "Вся забота о малыше — в одном приложении"
- Подзаголовок: "Ваша клиника ведёт вас по персональному маршруту от беременности до 2 лет"
- CTA: "Узнайте у вашей клиники"

**SVG-иллюстрация: контур руки, держащей телефон. Внутри — живой интерфейс.**

Анимация при загрузке:
1. Рука появляется снизу (slide-up 600ms)
2. Экран телефона включается (white rectangle fade-in 300ms)
3. Внутри рисуется timeline ребёнка: "Ваш малыш: 4 мес. 12 дней"
4. Появляется notification: "Витамин D3 — 08:00 ✓"
5. Маленький confetti burst (3-4 частицы) при появлении галочки

---

### Секция 2: Знакомые проблемы — Checkbox Empathy

**Содержание:**
- 4-5 болей мам: "Забыла, когда следующий скрининг", "Анализы в 5 разных чатах", "Не помню, давала ли витамин D утром", "После родов осталась без поддержки", "Не знаю, нормально ли развивается ребёнок"
- Короткие, узнаваемые, без процентов

**Анимация:**
- Каждая боль — строка с пустым чекбоксом слева
- Scroll-in: боли появляются по одной (stagger 200ms)
- При наведении на боль — чекбокс анимированно проставляется (stroke animation), строка мягко перечёркивается
- Message: "UMAI Health решает это"

---

### Секция 3: Что даёт приложение — 3 экрана телефона

**Содержание:**
- 3 телефона рядом (desktop) или карусель (mobile)
- Timeline, Smart Prescriptions, Medical Archive

**Телефон 1 — Timeline:**
- Внутри: вертикальный список событий
- Анимация: события появляются сверху вниз, первое с зелёной галочкой, второе с teal "сегодня", остальные серые
- Hover: список слегка скроллится вниз

**Телефон 2 — Prescriptions:**
- Внутри: 3 карточки-таблетки с временем
- Анимация: первая таблетка — swipe right, зелёная галочка. Вторая ждёт. Третья — с часами
- Loop: каждые 4 секунды вторая таблетка тоже "свайпается"

**Телефон 3 — Medical Archive:**
- Внутри: grid из 6 маленьких документов-превью
- Анимация scroll-in: документы влетают из разных направлений, складываясь в аккуратный grid
- Message: "Из хаоса — в порядок"

---

### Секция 4: День с приложением — 24-часовой таймлайн

**Содержание:**
- Вертикальная линия слева, справа карточки-события
- 08:00 — витамины ✓, 10:00 — уведомление о записи, 14:00 — загрузка анализа, 20:00 — вечерний магний

**Scroll-driven animation:**
- Линия рисуется сверху вниз при scroll
- Когда линия достигает точки часа — карточка slide-in from right
- Каждая карточка содержит мини-SVG:
  - 08:00 — таблетка с галочкой
  - 10:00 — колокольчик
  - 14:00 — камера фотографирует бумагу
  - 20:00 — луна + таблетка
- Финал: "Adherence сегодня: 100% 🎉" с зелёным glow

---

### Секция 5: Маршрут ребёнка — Растущий малыш

**Содержание:**
- Горизонтальный timeline с 4 этапами (беременность, 0-6 мес, 6-12 мес, 12-24 мес)
- Каждый этап — 2-3 ключевых события

**Scroll-driven SVG morphing:**
- SVG малыша (15-20 path-элементов, outline, teal, минималистичный персонаж)
- По мере скролла SVG морфится: лежит → приподнимается → сидит → ползёт → стоит → идёт
- Под каждой фазой — events появляются при достижении точки

---

### Секция 6: Вакцинация — Заполняющийся щит

**Содержание:**
- "Все 18+ прививок по нацкалендарю. Напоминания за 3 дня. История вакцинаций."
- Один мокап экрана вакцинаций

**SVG-щит (иммунная защита):**
- Щит начинается пустым (outline only)
- По мере скролла щит заполняется снизу вверх (clip-path animation)
- Рядом — список прививок, каждая появляется когда щит заполняется до соответствующего уровня
- Когда щит полный — зелёный glow + "Полная защита"

---

### Секция 7: Безопасность и приватность

**Содержание:**
- 3 иконки: "Данные зашифрованы", "Только вы и ваш врач", "Вы контролируете доступ"

**SVG-анимация:**
- Замок закрытый. При scroll-in дужка опускается, вокруг появляется pulse-ring
- 3 строки текста появляются рядом

---

### Секция 8: FAQ

**Содержание:**
- 6-8 вопросов: бесплатно ли, как получить, нужен ли интернет, қазақша бар ма, кто видит данные, можно ли удалить аккаунт

---

### Секция 9: CTA

**Содержание:**
- "Спросите у вашей клиники о UMAI Health"
- Потому что семья не покупает сама — доступ через клинику

---

## 6. Сводка изменений

| Страница | Было секций | Стало секций | Было компонентов | Станет компонентов |
|----------|------------|-------------|-----------------|-------------------|
| Главная | 21 | 8 | 24 | ~10 |
| Для клиник | 22 | 10 | 22 | ~12 |
| Для родителей | 19 | 9 | 18 | ~11 |
| **Итого** | **62** | **27** | **85** | **~33 + shared** |

### Что убрано полностью (не на сайте)

- SWOT-анализ → внутренний документ
- TechStack → внутренний документ
- MarketAnalysis → внутренний документ
- BusinessProcessFlow → внутренний документ
- CaseStudy → вернуть когда появятся реальные кейсы
- Partners → вернуть когда появятся реальные партнёры
- Testimonials → вернуть когда появятся реальные отзывы
- ComparisonTable (главная) → перегруз, убрано
- UnitEconomics (отдельная секция) → интегрировано в ROI-блок на for-clinics
- Integrations (отдельная секция) → упомянуто в модулях
- Support (отдельная секция) → очевидно, убрано

---

## 7. Общие принципы анимации

### Движок

GSAP + ScrollTrigger (уже подключены в composables). Все анимации привязаны к scroll position, не к времени. Пользователь контролирует скорость через скорость скролла.

### Правило

Ни одна анимация не должна задерживать доступ к информации. Текст появляется мгновенно или за 300ms. Длинные анимации — только для иллюстративных SVG-элементов рядом с текстом, не вместо него.

### SVG

- Все SVG — inline, не img. Позволяет CSS/GSAP контроль
- Стиль: outline/line art, минималистичный, teal primary + coral accent
- Никакого фотореализма — чистые контуры, 15-30 path-элементов на иллюстрацию
- Path data — в отдельных .ts файлах, не в template

### Mobile

- Отключить scrub-анимации на mobile, оставить только scroll-in (appear)
- Морфинг и scrub-draw — desktop only
- Карусели вместо горизонтальных grid'ов
- Touch-friendly: hover-анимации заменяются на tap или scroll-in

---

## 8. Главная `/` — анимации и SVG

*(Детали анимаций описаны в секциях 1-8 главной страницы выше. Здесь — техническая спецификация.)*

### Hero: TimelinePhone.vue

```
Компоненты SVG:
- phone-frame: rounded rect 180×360, stroke #264653, fill white
- screen-clip: clipPath для контента внутри
- timeline-line: вертикальная линия, stroke-dasharray = totalLength, stroke-dashoffset анимируется от totalLength до 0
- event-dots: 5 кругов на линии, opacity 0→1 при достижении линией
- event-labels: текст рядом с каждой точкой, opacity 0→1, translateX -10→0
- notification-card: rect + text group, translateY -50→0, opacity 0→1, delay после timeline
- prescription-pill: rounded rect внизу, checkmark path внутри с stroke animation
- floating-icons: 4 группы (heart, flask, calendar, bell), CSS animation float 3-4s infinite alternate
- gradient-blob: ellipse за телефоном, CSS animation scale pulse 6s infinite
```

### Проблема: ChaosToOrder.vue

```
Две группы SVG-элементов с одинаковыми базовыми формами.

Группа "chaos" (transform-origin: center):
- paper: rect rotated 15deg, position random-ish
- phone: rect with 5 small rects inside (chats), rotated -10deg
- pills: 3 capsule shapes scattered
- calendar: rect with X mark

Группа "order" (transform-origin: center):
- paper: rect aligned, in folder shape
- phone: rect with 1 clean screen
- pills: 3 capsules in row with checkmark
- calendar: rect with dot marks

Animation: ScrollTrigger onEnter
- chaos group: elements fly outward from center (translateX/Y random 50-150px, rotate random)
- order group: elements converge to aligned positions

Arrow between: SVG path, stroke-dashoffset animation, appears after both groups settled
```

### Модули: ModuleIcons.vue

```
8 отдельных SVG-групп, каждая 40×40.

Hover animations (GSAP):
- gear: rotate 60deg, duration 0.4s
- chart-line: stroke-dashoffset totalLength→0, duration 0.6s
- pill: translateY 0→-5→0 (bounce), duration 0.3s
- calendar-page: rotateY 0→180 (flip), duration 0.4s
- folder: top-flap rotate -30deg (open), duration 0.3s
- syringe: translateY 0→5 (inject down), duration 0.3s
- checklist: 3 checkmarks appear sequentially, stagger 0.15s
- bar-chart: 3 bars scaleY 0→1, stagger 0.1s
```

---

## 9. Страница `/for-clinics` — анимации и SVG

### Hero: LossFunnel.vue

```
5 horizontal bars, stacked vertically, decreasing width:
- bar-100: width 100%, label "100 семей"
- bar-55: width 55%
- bar-33: width 33%
- bar-15: width 15%
- bar-5: width 5%, label "5 семей остаётся"

Phase 1 (load): all bars visible, gray color, bars shrink with delay (stagger 0.3s)
Phase 2 (scroll): bars refill with teal, growing from bar-5 upward
- bar-5 → bar-25 (width grows to 25%)
- bar-15 → bar-50
- bar-33 → bar-75
- bar-55 → bar-90
Labels update with number tweening

Color transition: gray → teal gradient
```

### Проблема: BurningMoney.vue

```
Stack of 5 banknote shapes (rounded rects with ₸ symbol inside)
Position: absolute, stacked with slight offset

Scroll-driven:
- Every 20% scroll progress, top banknote animates:
  - translateY: 0 → -100
  - opacity: 1 → 0
  - rotate: 0 → random(-15, 15)
  
Counter below stack:
- Text "Упущенная выручка:"
- Number tweens from 0 to 43,000,000
- Format: "43 млн ₸/год"
- Color shifts from neutral to danger-red as number grows
```

### Три рабочих стола: DashboardMockup.vue

```
Container with 3 tab buttons + SVG display area

Each tab has a complete SVG scene:

Tab "Координатор":
- 4 task-rows (rect + text + status-circle)
- On enter: top task slides right, status turns green, counter decrements
- Loop every 3s

Tab "Руководитель":
- 3 bar-chart bars + trend line
- On enter: bars grow (scaleY 0→1, stagger), line draws (stroke-dashoffset)

Tab "Врач":
- Patient card with 3 collapsible sections
- On enter: sections expand one by one (height animation)

Tab switch: crossfade (opacity) 400ms
Active tab: highlighted with primary color underline
```

### White-label: WhiteLabelDemo.vue

```
Phone SVG frame (fixed shape)
Inside: simplified app UI with dynamic colors

3 theme buttons below:
- Theme A: { primary: teal, name: "Клиника Рахат", logo: simplified R }
- Theme B: { primary: deep-blue, name: "Керуен Medicus", logo: simplified K }
- Theme C: { primary: warm-green, name: "IRM", logo: simplified I }

On theme switch (CSS transition 500ms):
- header-bg: fill transition to new primary
- clinic-name: text content swap (opacity 0→1)
- logo: opacity 0→1
- accent elements: fill transition
- button-bg: fill transition

Auto-cycle: setInterval 3000ms, pauses on hover
```

### ROI калькулятор

```
HTML/CSS interactive (не SVG):
- Range input: "Семей в месяц" 10-100, step 5
- Output cards (3):
  - "Доп. выручка": families × avgPediatricPackage (150,000₸) × retentionLift (0.3)
  - "Стоимость платформы": fixed 1,500,000₸/мес
  - "ROI": ((revenue - cost) / cost × 100) + "%"

Number animation: GSAP.to on value change, snap to integer
ROI card: background-color transitions green when ROI > 100%
```

---

## 10. Страница `/for-families` — анимации и SVG

### Hero: HandWithPhone.vue

```
SVG composition:
- hand: simplified outline hand shape (palm + 4 fingers + thumb), 
  fill: skin-tone-neutral or outline-only
- phone-in-hand: rect inside hand grip area, clipped

Load sequence (timeline):
0ms: hand at translateY: 100, opacity: 0
0-600ms: hand slides up, opacity → 1
600-900ms: phone screen white rect fades in (simulating screen on)
900-1400ms: inside phone, timeline content appears:
  - header "Ваш малыш: 4 мес. 12 дней" (typewriter or fade)
  - 3 event cards slide in from right (stagger 150ms)
1400-1800ms: notification banner slides down from top of phone screen
1800-2100ms: checkmark draws on notification (stroke animation)
2100-2300ms: 3-4 confetti particles burst from checkmark (random translateX/Y + fade)
```

### Проблемы: CheckboxEmpathy

```
No separate SVG file — CSS + minimal inline SVG for checkmark

Each pain-point row:
- Left: 20×20 SVG square (checkbox outline)
- Right: text

Scroll-in: stagger 200ms, opacity 0→1, translateY 20→0

Hover interaction:
- Checkbox: stroke animation draws checkmark inside (0.3s)
- Text: text-decoration line-through animates width 0%→100% (0.4s)
- Row: slight bg-color change to success-light

CSS:
.pain-text { 
  text-decoration: line-through;
  text-decoration-color: transparent;
  transition: text-decoration-color 0.4s;
}
.pain-row:hover .pain-text {
  text-decoration-color: var(--color-success);
}
```

### 3 телефона: PrescriptionSwipe.vue, DocumentGrid.vue

```
PrescriptionSwipe.vue:
- Phone frame
- Inside: 3 pill-cards stacked
- Animation loop (4s interval):
  - Top card: translateX 0→200, opacity 1→0, green checkmark appears briefly
  - Remaining cards: translateY shift up
  - New card appears at bottom: opacity 0→1, translateY 20→0

DocumentGrid.vue:
- Phone frame
- Inside: 6 document thumbnails (small rects with type-icons)
- Scroll-in animation:
  - Documents start at random positions outside phone bounds
  - Animate to grid positions (2×3)
  - Stagger 100ms, duration 0.6s each
  - Easing: power2.out (satisfying snap into place)
```

### День с приложением: DayTimeline (scroll-driven)

```
Vertical line (left side):
- Total height: maps to section scroll range
- stroke-dashoffset: controlled by ScrollTrigger scrub

4 time-point markers on the line:
- Circle + time label (08:00, 10:00, 14:00, 20:00)
- Each marker: opacity 0→1 when line reaches its Y position

4 event cards (right side):
- Appear with translateX: 50→0, opacity: 0→1
- Triggered when corresponding marker activates

Mini-SVG in each card:
- 08:00: pill (capsule shape) + checkmark (stroke draw)
- 10:00: bell shape with motion lines (shake animation 0.3s)
- 14:00: camera shape pointing at document rect
- 20:00: crescent moon + capsule shape

Final block:
- Appears after all cards
- "Adherence: 100%" text with green glow (box-shadow animation pulse)
```

### Растущий малыш: GrowingChild.vue

```
Central character: ~20 SVG paths forming simplified child outline

5 morph states (SVG path data stored in array):
1. lying: horizontal baby shape
2. propped: semi-reclined
3. sitting: upright torso, legs folded
4. crawling: hands-and-knees position
5. walking: upright, one leg forward

Scroll-driven morphing:
- ScrollTrigger scrub maps scroll progress 0-1 to state index 0-4
- GSAP morphSVG (or manual path d attribute interpolation)
- Duration per transition: ~0.8s equivalent in scroll distance

Below character: horizontal axis with age labels
- 0 мес, 3 мес, 6 мес, 9 мес, 12 мес, 18 мес, 24 мес
- Event cards pop up at corresponding positions

Style: outline stroke, teal color, rounded line-caps
Stroke-width: 2-3px
ViewBox: 0 0 200 150
```

### Вакцинация: ImmunityShield.vue

```
Shield shape: traditional heraldic shield outline
- ViewBox: 0 0 120 140
- Single path, stroke teal, fill transparent initially

Fill animation (clip-path):
- clipPath rect starts at bottom of shield, height: 0
- Scroll-driven: height grows from 0 to full shield height
- Fill color: teal gradient (lighter at top)

Vaccination list (right side):
- 6-8 vaccine names
- Each appears when clip reaches corresponding height level
- Fade-in + translateX: -10→0

Completion state:
- When clip fills 100%: 
  - Shield stroke: teal → success green
  - Glow effect: filter drop-shadow with green, pulsing
  - Text below: "Полная защита" appears
```

### Безопасность: LockAnimation

```
Simple padlock SVG:
- Body: rounded rect
- Shackle: arc path (open position = rotated up, closed = down)

Scroll-in:
- Lock body appears (opacity, scale)
- Shackle animates from open to closed (rotate arc path)
- Pulse ring: circle, scale 1→1.3, opacity 1→0, repeating
```

---

## 11. Shared SVG-иллюстрации

| Файл | Где используется | Тип анимации |
|------|-----------------|-------------|
| `TimelinePhone.vue` | Hero главной, Hero семей | Load sequence, stroke draw |
| `ChaosToOrder.vue` | Проблема на главной | Scroll-in explode/converge |
| `LossFunnel.vue` | Hero клиник | Load + scroll refill |
| `BurningMoney.vue` | Проблема клиник | Scroll-driven banknote fly |
| `DashboardMockup.vue` | Что даёт клинике | Tab switch, element animations |
| `WhiteLabelDemo.vue` | White-label клиник | CSS transition theme swap |
| `HandWithPhone.vue` | Hero семей | Load sequence 5-step |
| `GrowingChild.vue` | Маршрут ребёнка | Scroll-driven SVG morph |
| `ImmunityShield.vue` | Вакцинация | Scroll-driven clip-path fill |
| `PrescriptionSwipe.vue` | Что даёт приложение | Loop swipe animation |
| `DocumentGrid.vue` | Что даёт приложение | Scroll-in scatter→grid |
| `ModuleIcons.vue` | Модули на главной | Hover micro-animations |

---

## 12. Composables для анимаций

### useScrollDraw

Рисует SVG stroke по мере скролла.

```typescript
// composables/useScrollDraw.ts

export function useScrollDraw(
  svgRef: Ref<SVGElement>,
  options?: { start?: string; end?: string }
) {
  onMounted(() => {
    const paths = svgRef.value?.querySelectorAll('path[data-draw]');
    paths?.forEach(path => {
      const length = (path as SVGPathElement).getTotalLength();
      gsap.set(path, {
        strokeDasharray: length,
        strokeDashoffset: length,
      });
      ScrollTrigger.create({
        trigger: svgRef.value,
        start: options?.start || 'top 80%',
        end: options?.end || 'bottom 20%',
        scrub: 0.5,
        onUpdate: (self) => {
          gsap.set(path, {
            strokeDashoffset: length * (1 - self.progress),
          });
        },
      });
    });
  });
}
```

### useCountUp

Анимированный счётчик при scroll-in.

```typescript
// composables/useCountUp.ts

export function useCountUp(target: Ref<number>, duration = 1.5) {
  const display = ref(0);
  const el = ref<HTMLElement>();

  onMounted(() => {
    ScrollTrigger.create({
      trigger: el.value,
      start: 'top 85%',
      once: true,
      onEnter: () => {
        gsap.to(display, {
          value: target.value,
          duration,
          ease: 'power2.out',
          snap: { value: 1 },
        });
      },
    });
  });

  return { display, el };
}
```

### useMorph

SVG path morphing между состояниями.

```typescript
// composables/useMorph.ts

export function useMorph(
  pathRef: Ref<SVGPathElement>,
  states: string[]
) {
  let currentState = 0;

  function morphTo(stateIndex: number) {
    if (stateIndex === currentState || !pathRef.value) return;
    gsap.to(pathRef.value, {
      attr: { d: states[stateIndex] },
      duration: 0.8,
      ease: 'power2.inOut',
    });
    currentState = stateIndex;
  }

  return { morphTo, currentState: readonly(ref(currentState)) };
}
```

### useStagger

Staggered appearance при scroll-in.

```typescript
// composables/useStagger.ts

export function useStagger(
  containerRef: Ref<HTMLElement>,
  selector = '.stagger-item'
) {
  onMounted(() => {
    const items = containerRef.value?.querySelectorAll(selector);
    if (!items?.length) return;

    gsap.set(items, { opacity: 0, y: 30 });
    ScrollTrigger.create({
      trigger: containerRef.value,
      start: 'top 80%',
      once: true,
      onEnter: () => {
        gsap.to(items, {
          opacity: 1,
          y: 0,
          duration: 0.5,
          stagger: 0.1,
          ease: 'power2.out',
        });
      },
    });
  });
}
```

### useHoverAnimation

Micro-animation на hover для SVG-элементов.

```typescript
// composables/useHoverAnimation.ts

export function useHoverAnimation(
  elRef: Ref<HTMLElement>,
  animation: gsap.TweenVars,
  options?: { duration?: number }
) {
  let tween: gsap.core.Tween;

  onMounted(() => {
    if (!elRef.value) return;

    const target = elRef.value.querySelector('[data-hover-target]') || elRef.value;

    elRef.value.addEventListener('mouseenter', () => {
      tween = gsap.to(target, {
        ...animation,
        duration: options?.duration || 0.4,
        ease: 'power2.out',
      });
    });

    elRef.value.addEventListener('mouseleave', () => {
      tween?.reverse();
    });
  });
}
```

### useScrollProgress

Привязка значения к scroll progress секции.

```typescript
// composables/useScrollProgress.ts

export function useScrollProgress(
  sectionRef: Ref<HTMLElement>,
  options?: { start?: string; end?: string }
) {
  const progress = ref(0);

  onMounted(() => {
    ScrollTrigger.create({
      trigger: sectionRef.value,
      start: options?.start || 'top bottom',
      end: options?.end || 'bottom top',
      scrub: 0.3,
      onUpdate: (self) => {
        progress.value = self.progress;
      },
    });
  });

  return { progress };
}
```

### useThemeSwitcher

Для white-label демо — переключение CSS variables.

```typescript
// composables/useThemeSwitcher.ts

interface Theme {
  name: string;
  primary: string;
  logo: string;
}

export function useThemeSwitcher(
  themes: Theme[],
  containerRef: Ref<HTMLElement>,
  autoInterval = 3000
) {
  const currentIndex = ref(0);
  let interval: ReturnType<typeof setInterval>;
  let paused = false;

  function switchTo(index: number) {
    currentIndex.value = index;
    if (!containerRef.value) return;
    const theme = themes[index];
    containerRef.value.style.setProperty('--demo-primary', theme.primary);
  }

  function next() {
    switchTo((currentIndex.value + 1) % themes.length);
  }

  onMounted(() => {
    interval = setInterval(() => {
      if (!paused) next();
    }, autoInterval);

    containerRef.value?.addEventListener('mouseenter', () => { paused = true; });
    containerRef.value?.addEventListener('mouseleave', () => { paused = false; });
  });

  onUnmounted(() => clearInterval(interval));

  return { currentIndex, switchTo, next, currentTheme: computed(() => themes[currentIndex.value]) };
}
```

---

## 13. Производительность

| Правило | Реализация |
|---------|-----------|
| GPU-accelerated only | Все GSAP-анимации используют transform и opacity. Никаких width/height/top/left. |
| Без Lottie | Слишком тяжёлый для 12 иллюстраций. Все анимации — GSAP + inline SVG. |
| Inline SVG | Не img src. Позволяет GSAP и CSS контроль без дополнительных HTTP-запросов. |
| Lazy sections | Секции ниже fold загружаются через Intersection Observer или v-lazy. SVG-данные импортируются динамически. |
| ScrollTrigger scrub | Нативно плавный, не вызывает jank. scrub: 0.3-0.5 для smooth feel. |
| Mobile отключение | scrub-анимации и морфинг — desktop only (media query в composable). На mobile — простой scroll-in (appear). |
| Path data extraction | SVG path d-атрибуты в .ts файлах, не в template. Чистота компонентов. |
| will-change | Добавлять только на элементы, которые реально анимируются. Убирать после завершения анимации. |
| Reduce motion | `prefers-reduced-motion: reduce` — отключить все анимации, показать static state. |

```css
/* Глобально в app.css */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

*Документ является полным blueprint для разработки лендинга. Каждая секция, каждая анимация, каждый SVG-компонент описаны до уровня реализации.*

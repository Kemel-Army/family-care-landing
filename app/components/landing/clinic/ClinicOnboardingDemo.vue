<template>
  <LandingUiSectionWrapper
    id="onboarding-demo"
    badge="Интерактивный тур"
    title="Как выглядит подключение"
    subtitle="5 шагов от заявки до первых результатов — пройдите демо прямо сейчас"
  >
    <!-- Step indicators -->
    <div class="demo-progress" data-reveal="fade-up">
      <div class="progress-track">
        <div class="progress-fill" :style="{ width: progressWidth }" />
      </div>
      <div class="progress-steps">
        <button
          v-for="(step, i) in steps"
          :key="step.id"
          class="progress-dot"
          :class="{ active: i === current, done: i < current }"
          @click="goTo(i)"
        >
          <span class="dot-num">{{ i < current ? '✓' : i + 1 }}</span>
          <span class="dot-label">{{ step.short }}</span>
          <!-- Auto-play timer ring -->
          <svg v-if="i === current && isAutoPlaying" class="dot-timer" width="36" height="36" viewBox="0 0 36 36">
            <circle cx="18" cy="18" r="16" fill="none" stroke="var(--color-primary)" stroke-width="2" opacity="0.15" />
            <circle cx="18" cy="18" r="16" fill="none" stroke="var(--color-primary)" stroke-width="2"
              stroke-dasharray="100.5" :stroke-dashoffset="timerOffset"
              stroke-linecap="round" class="timer-ring" />
          </svg>
        </button>
      </div>
      <!-- Auto-play toggle -->
      <button class="autoplay-btn" :class="{ paused: !isAutoPlaying }" @click="toggleAutoPlay">
        <svg v-if="isAutoPlaying" width="14" height="14" viewBox="0 0 14 14" fill="currentColor"><rect x="2" y="2" width="4" height="10" rx="1" /><rect x="8" y="2" width="4" height="10" rx="1" /></svg>
        <svg v-else width="14" height="14" viewBox="0 0 14 14" fill="currentColor"><path d="M3 1.5 L12 7 L3 12.5Z" /></svg>
      </button>
    </div>

    <!-- Floating blobs for depth -->
    <div class="demo-blobs">
      <div class="blob blob-1" data-speed="-0.2" />
      <div class="blob blob-2" data-speed="0.15" />
    </div>

    <!-- Demo viewport -->
    <div ref="viewportRef" class="demo-viewport" data-reveal="fade-up" data-reveal-delay="200">
      <Transition :name="direction" mode="out-in" @after-enter="onSlideEnter">
        <div :key="current" class="demo-slide">
          <div class="slide-layout">
            <!-- Mockup -->
            <div class="slide-visual">
              <div class="desktop-frame" :class="{ 'is-mobile': steps[current]?.mobile }" data-tilt>
                <div class="frame-toolbar">
                  <span class="frame-dots">
                    <i /><i /><i />
                  </span>
                  <span class="frame-url font-mono">{{ steps[current]?.url }}</span>
                </div>
                <div class="frame-screen">
                  <!-- Step 1: Регистрация клиники -->
                  <svg v-if="current === 0" viewBox="0 0 520 340" fill="none" class="screen-svg">
                    <rect width="520" height="340" fill="#FEFCFF" />
                    <!-- Header -->
                    <rect x="0" y="0" width="520" height="52" fill="var(--color-primary-ultralight)" />
                    <text x="24" y="32" font-size="14" font-weight="700" fill="var(--color-primary)" font-family="Satoshi, sans-serif">UMAI Health</text>
                    <text x="180" y="32" font-size="11" fill="var(--color-text-secondary)">Регистрация клиники</text>
                    <!-- Progress bar -->
                    <rect x="24" y="68" width="472" height="4" rx="2" fill="var(--color-border-light)" />
                    <rect x="24" y="68" width="94" height="4" rx="2" fill="var(--color-primary)" class="anim-width" />
                    <text x="24" y="90" font-size="10" fill="var(--color-text-muted)">Шаг 1 из 5</text>
                    <!-- Form -->
                    <text x="24" y="120" font-size="16" font-weight="700" fill="var(--color-text-primary)" font-family="Satoshi, sans-serif">Данные клиники</text>
                    <!-- Field: Name -->
                    <text x="24" y="148" font-size="10" fill="var(--color-text-secondary)">Название</text>
                    <rect x="24" y="154" width="220" height="32" rx="8" fill="white" stroke="var(--color-primary)" stroke-width="1.5" />
                    <text x="36" y="175" font-size="12" fill="var(--color-text-primary)">Клиника «Ваше название»</text>
                    <!-- Field: City -->
                    <text x="260" y="148" font-size="10" fill="var(--color-text-secondary)">Город</text>
                    <rect x="260" y="154" width="220" height="32" rx="8" fill="white" stroke="var(--color-border)" stroke-width="1" />
                    <text x="272" y="175" font-size="12" fill="var(--color-text-primary)">Алматы</text>
                    <!-- Field: Contact -->
                    <text x="24" y="210" font-size="10" fill="var(--color-text-secondary)">Контактное лицо</text>
                    <rect x="24" y="216" width="220" height="32" rx="8" fill="white" stroke="var(--color-border)" stroke-width="1" />
                    <text x="36" y="237" font-size="12" fill="var(--color-text-primary)">Имя контактного лица</text>
                    <!-- Field: Phone -->
                    <text x="260" y="210" font-size="10" fill="var(--color-text-secondary)">Телефон</text>
                    <rect x="260" y="216" width="220" height="32" rx="8" fill="white" stroke="var(--color-border)" stroke-width="1" />
                    <text x="272" y="237" font-size="12" fill="var(--color-text-primary)">+7 (7XX) XXX-XX-XX</text>
                    <!-- Field: Email -->
                    <text x="24" y="272" font-size="10" fill="var(--color-text-secondary)">Email</text>
                    <rect x="24" y="278" width="456" height="32" rx="8" fill="white" stroke="var(--color-border)" stroke-width="1" />
                    <text x="36" y="299" font-size="12" fill="var(--color-text-primary)">admin@example.kz</text>
                    <!-- Button -->
                    <rect x="340" y="320" width="140" height="0" rx="0" fill="none" />
                  </svg>

                  <!-- Step 2: Настройка маршрутов -->
                  <svg v-else-if="current === 1" viewBox="0 0 520 340" fill="none" class="screen-svg">
                    <rect width="520" height="340" fill="#FEFCFF" />
                    <!-- Sidebar -->
                    <rect x="0" y="0" width="140" height="340" fill="var(--color-primary-ultralight)" />
                    <text x="16" y="28" font-size="11" font-weight="700" fill="var(--color-primary)">⚙ Настройки</text>
                    <rect x="8" y="44" width="124" height="28" rx="6" fill="var(--color-primary)" />
                    <text x="20" y="62" font-size="10" fill="white" font-weight="600">Маршруты</text>
                    <text x="16" y="92" font-size="10" fill="var(--color-text-secondary)">Бренд</text>
                    <text x="16" y="112" font-size="10" fill="var(--color-text-secondary)">Роли</text>
                    <text x="16" y="132" font-size="10" fill="var(--color-text-secondary)">Уведомления</text>
                    <!-- Main content -->
                    <text x="156" y="28" font-size="14" font-weight="700" fill="var(--color-text-primary)" font-family="Satoshi, sans-serif">Маршруты наблюдения</text>
                    <text x="156" y="48" font-size="10" fill="var(--color-text-secondary)">Автогенерация по протоколам МЗ РК</text>
                    <!-- Route cards -->
                    <rect x="156" y="62" width="168" height="120" rx="10" fill="white" stroke="var(--color-primary)" stroke-width="1.5" />
                    <rect x="168" y="74" width="36" height="36" rx="8" fill="var(--color-primary-light)" />
                    <text x="178" y="97" font-size="16">🤰</text>
                    <text x="168" y="126" font-size="11" font-weight="600" fill="var(--color-text-primary)">Беременность</text>
                    <text x="168" y="142" font-size="9" fill="var(--color-text-secondary)">40 недель • 14 визитов</text>
                    <text x="168" y="158" font-size="9" fill="var(--color-text-secondary)">23 анализа • 3 скрининга</text>
                    <rect x="168" y="166" width="50" height="6" rx="3" fill="var(--color-success)" opacity="0.3" />
                    <rect x="168" y="166" width="50" height="6" rx="3" fill="var(--color-success)" class="anim-width" />

                    <rect x="340" y="62" width="168" height="120" rx="10" fill="white" stroke="var(--color-border)" stroke-width="1" />
                    <rect x="352" y="74" width="36" height="36" rx="8" fill="var(--color-secondary-light)" />
                    <text x="362" y="97" font-size="16">👶</text>
                    <text x="352" y="126" font-size="11" font-weight="600" fill="var(--color-text-primary)">Грудничок</text>
                    <text x="352" y="142" font-size="9" fill="var(--color-text-secondary)">0–12 мес • 12 визитов</text>
                    <text x="352" y="158" font-size="9" fill="var(--color-text-secondary)">18 прививок • 6 анализов</text>

                    <rect x="156" y="198" width="168" height="120" rx="10" fill="white" stroke="var(--color-border)" stroke-width="1" />
                    <rect x="168" y="210" width="36" height="36" rx="8" fill="var(--color-accent-blue-light)" />
                    <text x="178" y="233" font-size="16">🧒</text>
                    <text x="168" y="262" font-size="11" font-weight="600" fill="var(--color-text-primary)">Малыш 1–2 года</text>
                    <text x="168" y="278" font-size="9" fill="var(--color-text-secondary)">12–24 мес • 8 визитов</text>
                    <text x="168" y="294" font-size="9" fill="var(--color-text-secondary)">6 прививок • осмотры</text>

                    <!-- + Add card -->
                    <rect x="340" y="198" width="168" height="120" rx="10" fill="none" stroke="var(--color-border)" stroke-width="1" stroke-dasharray="6 4" />
                    <text x="400" y="262" font-size="24" fill="var(--color-text-muted)" text-anchor="middle">+</text>
                    <text x="400" y="284" font-size="10" fill="var(--color-text-muted)" text-anchor="middle">Свой маршрут</text>
                  </svg>

                  <!-- Step 3: Добавление семьи -->
                  <svg v-else-if="current === 2" viewBox="0 0 520 340" fill="none" class="screen-svg">
                    <rect width="520" height="340" fill="#FEFCFF" />
                    <!-- Header bar -->
                    <rect x="0" y="0" width="520" height="48" fill="var(--color-primary-ultralight)" />
                    <text x="24" y="30" font-size="13" font-weight="700" fill="var(--color-text-primary)" font-family="Satoshi, sans-serif">Координатор  ‹  Новая семья</text>
                    <!-- Avatar + info block -->
                    <circle cx="56" cy="90" r="24" fill="var(--color-secondary-light)" />
                    <text x="44" y="95" font-size="18">👩</text>
                    <text x="92" y="82" font-size="14" font-weight="600" fill="var(--color-text-primary)">Семья А.</text>
                    <text x="92" y="100" font-size="10" fill="var(--color-text-secondary)">28 лет • Срок: 12 недель • Первая беременность</text>
                    <rect x="92" y="108" width="60" height="18" rx="9" fill="var(--color-primary-light)" />
                    <text x="103" y="121" font-size="9" fill="var(--color-primary)" font-weight="600">Низкий риск</text>
                    <!-- Auto-generated route -->
                    <text x="24" y="152" font-size="12" font-weight="700" fill="var(--color-text-primary)">Автосгенерированный маршрут</text>
                    <text x="24" y="168" font-size="9" fill="var(--color-success)">✓ 52 события на 24 месяца создано за 2 сек</text>
                    <!-- Timeline events -->
                    <line x1="40" y1="184" x2="40" y2="316" stroke="var(--color-border)" stroke-width="2" />
                    <!-- Event 1 -->
                    <circle cx="40" cy="194" r="6" fill="var(--color-primary)" />
                    <rect x="56" y="180" width="440" height="32" rx="6" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="68" y="194" font-size="9" fill="var(--color-text-muted)">Сегодня</text>
                    <text x="68" y="206" font-size="10" font-weight="600" fill="var(--color-text-primary)">Первичный приём — УЗИ скрининг 1 триместра</text>
                    <rect x="420" y="186" width="64" height="20" rx="6" fill="var(--color-primary)" />
                    <text x="432" y="200" font-size="9" fill="white" font-weight="600">Записать</text>
                    <!-- Event 2 -->
                    <circle cx="40" cy="230" r="6" fill="var(--color-accent-blue)" />
                    <rect x="56" y="216" width="440" height="32" rx="6" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="68" y="230" font-size="9" fill="var(--color-text-muted)">Через 2 нед</text>
                    <text x="68" y="242" font-size="10" font-weight="600" fill="var(--color-text-primary)">Анализ крови + ОАМ</text>
                    <rect x="420" y="222" width="64" height="20" rx="6" fill="white" stroke="var(--color-primary)" stroke-width="1" />
                    <text x="430" y="236" font-size="9" fill="var(--color-primary)" font-weight="600">Записать</text>
                    <!-- Event 3 -->
                    <circle cx="40" cy="266" r="6" fill="var(--color-accent-blue)" />
                    <rect x="56" y="252" width="440" height="32" rx="6" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="68" y="266" font-size="9" fill="var(--color-text-muted)">Через 4 нед</text>
                    <text x="68" y="278" font-size="10" font-weight="600" fill="var(--color-text-primary)">Консультация генетика — скрининг Дауна</text>
                    <!-- Event 4 -->
                    <circle cx="40" cy="302" r="6" fill="var(--color-border)" />
                    <rect x="56" y="288" width="440" height="32" rx="6" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="68" y="302" font-size="9" fill="var(--color-text-muted)">Через 8 нед</text>
                    <text x="68" y="314" font-size="10" font-weight="600" fill="var(--color-text-primary)">УЗИ скрининг 2 триместра + допплер</text>
                  </svg>

                  <!-- Step 4: Push-уведомление семье -->
                  <svg v-else-if="current === 3" viewBox="0 0 520 340" fill="none" class="screen-svg">
                    <rect width="520" height="340" fill="#FEFCFF" />
                    <!-- Split: left = coordinator sending, right = phone preview -->
                    <!-- LEFT: Coordinator panel -->
                    <text x="16" y="24" font-size="12" font-weight="700" fill="var(--color-text-primary)" font-family="Satoshi, sans-serif">Координатор</text>
                    <!-- Task card -->
                    <rect x="16" y="36" width="244" height="80" rx="10" fill="white" stroke="var(--color-danger)" stroke-width="1.5" />
                    <circle cx="32" cy="52" r="5" fill="var(--color-danger)" />
                    <text x="44" y="56" font-size="10" font-weight="600" fill="var(--color-text-primary)">Семья А. — пропущен визит</text>
                    <text x="44" y="72" font-size="9" fill="var(--color-text-secondary)">УЗИ 2 триместра • Просрочено 3 дня</text>
                    <!-- Action buttons -->
                    <rect x="28" y="86" width="70" height="22" rx="6" fill="var(--color-primary)" />
                    <text x="38" y="101" font-size="9" fill="white" font-weight="600">📞 Позвонить</text>
                    <rect x="106" y="86" width="90" height="22" rx="6" fill="white" stroke="var(--color-primary)" stroke-width="1" />
                    <text x="114" y="101" font-size="9" fill="var(--color-primary)" font-weight="600">📩 Уведомить</text>
                    <!-- Arrow -->
                    <text x="274" y="76" font-size="20" fill="var(--color-primary)">→</text>
                    <!-- RIGHT: Phone mockup -->
                    <rect x="310" y="16" width="190" height="310" rx="24" fill="white" stroke="var(--color-border)" stroke-width="2" />
                    <!-- Phone notch -->
                    <rect x="370" y="16" width="70" height="16" rx="0 0 8 8" fill="var(--color-border-light)" />
                    <!-- Status bar -->
                    <text x="324" y="44" font-size="8" fill="var(--color-text-muted)">9:41</text>
                    <text x="470" y="44" font-size="8" fill="var(--color-text-muted)">📶 🔋</text>
                    <!-- Push notification -->
                    <rect x="322" y="56" width="166" height="68" rx="12" fill="white" stroke="var(--color-border)" stroke-width="1" class="anim-slide-in" />
                    <rect x="330" y="64" width="24" height="24" rx="6" fill="var(--color-primary-light)" />
                    <text x="337" y="81" font-size="10">🏥</text>
                    <text x="360" y="76" font-size="9" font-weight="600" fill="var(--color-text-primary)">Ваша клиника</text>
                    <text x="360" y="90" font-size="8" fill="var(--color-text-secondary)">У вас назначено УЗИ</text>
                    <text x="360" y="102" font-size="8" fill="var(--color-text-secondary)">2 триместра. Записать на</text>
                    <text x="360" y="114" font-size="8" fill="var(--color-primary)" font-weight="600">завтра, 10:00? →</text>
                    <!-- App screen behind -->
                    <rect x="322" y="136" width="166" height="40" rx="8" fill="var(--color-primary-ultralight)" />
                    <text x="334" y="152" font-size="9" fill="var(--color-text-primary)" font-weight="600">📅 Ближайшие визиты</text>
                    <text x="334" y="168" font-size="8" fill="var(--color-text-secondary)">Всё по плану — 0 пропусков</text>
                    <!-- Card: vaccine -->
                    <rect x="322" y="186" width="166" height="36" rx="8" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="334" y="200" font-size="9" fill="var(--color-text-primary)">💉 Вакцинация через 2 нед</text>
                    <text x="334" y="214" font-size="8" fill="var(--color-success)" font-weight="600">Подробнее →</text>
                    <!-- Card: result -->
                    <rect x="322" y="230" width="166" height="36" rx="8" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="334" y="244" font-size="9" fill="var(--color-text-primary)">📋 Результат анализа крови</text>
                    <text x="334" y="258" font-size="8" fill="var(--color-success)">✓ Норма</text>
                    <!-- Home bar -->
                    <rect x="380" y="308" width="50" height="4" rx="2" fill="var(--color-border)" />
                  </svg>

                  <!-- Step 5: Панель координатора -->
                  <svg v-else viewBox="0 0 520 340" fill="none" class="screen-svg">
                    <rect width="520" height="340" fill="#FEFCFF" />
                    <!-- Header -->
                    <rect x="0" y="0" width="520" height="48" fill="var(--color-primary-ultralight)" />
                    <text x="24" y="20" font-size="8" fill="var(--color-text-muted)">Ваша клиника</text>
                    <text x="24" y="36" font-size="14" font-weight="700" fill="var(--color-text-primary)" font-family="Satoshi, sans-serif">Панель координатора</text>
                    <!-- KPI strip -->
                    <rect x="260" y="6" width="62" height="36" rx="8" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="272" y="22" font-size="16" font-weight="700" fill="var(--color-primary)" font-family="JetBrains Mono">—</text>
                    <text x="272" y="36" font-size="7" fill="var(--color-text-muted)">Удержание</text>
                    <rect x="330" y="6" width="62" height="36" rx="8" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="342" y="22" font-size="16" font-weight="700" fill="var(--color-success)" font-family="JetBrains Mono">—</text>
                    <text x="342" y="36" font-size="7" fill="var(--color-text-muted)">Визиты</text>
                    <rect x="400" y="6" width="62" height="36" rx="8" fill="white" stroke="var(--color-border-light)" stroke-width="1" />
                    <text x="412" y="22" font-size="16" font-weight="700" fill="var(--color-accent-warm)" font-family="JetBrains Mono">4.8</text>
                    <text x="412" y="36" font-size="7" fill="var(--color-text-muted)">NPS</text>
                    <rect x="470" y="6" width="38" height="36" rx="8" fill="var(--color-primary)" />
                    <text x="478" y="28" font-size="10" fill="white" font-weight="600">+ ↗</text>
                    <!-- Tabs -->
                    <rect x="24" y="58" width="68" height="24" rx="6" fill="var(--color-primary)" />
                    <text x="34" y="74" font-size="9" fill="white" font-weight="600">Задачи (6)</text>
                    <text x="104" y="74" font-size="9" fill="var(--color-text-muted)">Семьи</text>
                    <text x="190" y="74" font-size="9" fill="var(--color-text-muted)">Аналитика</text>
                    <!-- Task list -->
                    <!-- Task 1: overdue -->
                    <rect x="24" y="92" width="472" height="44" rx="8" fill="white" stroke="var(--color-danger)" stroke-width="1" />
                    <circle cx="40" cy="114" r="5" fill="var(--color-danger)" />
                    <text x="52" y="108" font-size="10" font-weight="600" fill="var(--color-text-primary)">Семья А. — УЗИ 2 триместра</text>
                    <text x="52" y="124" font-size="8" fill="var(--color-danger)">Просрочено 3 дня</text>
                    <rect x="380" y="102" width="52" height="20" rx="6" fill="var(--color-primary)" />
                    <text x="388" y="116" font-size="8" fill="white" font-weight="600">Связаться</text>
                    <rect x="438" y="102" width="48" height="20" rx="6" fill="white" stroke="var(--color-primary)" stroke-width="1" />
                    <text x="446" y="116" font-size="8" fill="var(--color-primary)" font-weight="600">Записать</text>
                    <!-- Task 2: today -->
                    <rect x="24" y="144" width="472" height="44" rx="8" fill="white" stroke="var(--color-warning)" stroke-width="1" />
                    <circle cx="40" cy="166" r="5" fill="var(--color-warning)" />
                    <text x="52" y="160" font-size="10" font-weight="600" fill="var(--color-text-primary)">Семья Б. — вакцинация АКДС</text>
                    <text x="52" y="176" font-size="8" fill="var(--color-warning)">Сегодня, 14:00</text>
                    <rect x="380" y="154" width="52" height="20" rx="6" fill="var(--color-primary)" />
                    <text x="386" y="168" font-size="8" fill="white" font-weight="600">Напомн.</text>
                    <rect x="438" y="154" width="48" height="20" rx="6" fill="white" stroke="var(--color-primary)" stroke-width="1" />
                    <text x="446" y="168" font-size="8" fill="var(--color-primary)" font-weight="600">Записать</text>
                    <!-- Task 3: upcoming -->
                    <rect x="24" y="196" width="472" height="44" rx="8" fill="white" stroke="var(--color-success)" stroke-width="1" />
                    <circle cx="40" cy="218" r="5" fill="var(--color-success)" />
                    <text x="52" y="212" font-size="10" font-weight="600" fill="var(--color-text-primary)">Семья В. — приём педиатра</text>
                    <text x="52" y="228" font-size="8" fill="var(--color-success)">Завтра, 11:00 • Подтверждено</text>
                    <!-- Task 4: scheduled -->
                    <rect x="24" y="248" width="472" height="44" rx="8" fill="white" stroke="var(--color-accent-blue)" stroke-width="1" />
                    <circle cx="40" cy="270" r="5" fill="var(--color-accent-blue)" />
                    <text x="52" y="264" font-size="10" font-weight="600" fill="var(--color-text-primary)">Семья Г. — выписка</text>
                    <text x="52" y="280" font-size="8" fill="var(--color-accent-blue)">Через 3 дня • Переход: Грудничок</text>
                    <!-- Summary footer -->
                    <rect x="24" y="304" width="472" height="28" rx="8" fill="var(--color-primary-ultralight)" />
                    <text x="36" y="322" font-size="9" fill="var(--color-text-secondary)">
                      🔴 2 просрочено  •  🟡 1 сегодня  •  🟢 8 по расписанию  •  Все семьи в маршруте
                    </text>
                  </svg>
                </div>
              </div>
            </div>

            <!-- Info panel -->
            <div ref="infoRef" class="slide-info">
              <span class="step-badge font-heading">Шаг {{ current + 1 }}</span>
              <h3 class="slide-title font-display">{{ steps[current]?.title }}</h3>
              <p class="slide-desc">{{ steps[current]?.desc }}</p>
              <ul class="slide-highlights">
                <li v-for="(h, hi) in steps[current]?.highlights" :key="h" class="highlight-item" :style="{ animationDelay: `${hi * 120 + 200}ms` }">{{ h }}</li>
              </ul>
              <div class="slide-actions">
                <button v-if="current > 0" class="btn-prev" @click="prev">← Назад</button>
                <button v-if="current < steps.length - 1" class="btn-next btn-shimmer" @click="next">
                  Далее →
                </button>
                <a v-else href="#clinic-cta" class="btn-next btn-cta btn-shimmer">Запросить демо →</a>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </div>
  </LandingUiSectionWrapper>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useGsap } from '~/composables/useGsap'

const { gsap } = useGsap()

const current = ref(0)
const direction = ref('slide-left')
const viewportRef = ref<HTMLElement | null>(null)
const infoRef = ref<HTMLElement | null>(null)

// Auto-play
const isAutoPlaying = ref(true)
const timerOffset = ref(100.5)
let autoPlayInterval: ReturnType<typeof setInterval> | null = null
let timerTween: gsap.core.Tween | null = null
const AUTO_PLAY_DELAY = 6000

function startAutoPlay() {
  stopAutoPlay()
  isAutoPlaying.value = true
  timerOffset.value = 100.5
  timerTween = gsap.to(timerOffset, {
    value: 0,
    duration: AUTO_PLAY_DELAY / 1000,
    ease: 'none',
    onComplete: () => {
      if (current.value < steps.length - 1) {
        next()
      } else {
        goTo(0)
      }
    },
  })
}

function stopAutoPlay() {
  timerTween?.kill()
  if (autoPlayInterval) clearInterval(autoPlayInterval)
  autoPlayInterval = null
}

function toggleAutoPlay() {
  if (isAutoPlaying.value) {
    isAutoPlaying.value = false
    stopAutoPlay()
  } else {
    startAutoPlay()
  }
}

watch(current, () => {
  if (isAutoPlaying.value) startAutoPlay()
})

function onSlideEnter() {
  // GSAP stagger animation for highlights
  if (!infoRef.value) return
  const items = infoRef.value.querySelectorAll('.highlight-item')
  gsap.fromTo(items, { opacity: 0, x: -16 }, { opacity: 1, x: 0, stagger: 0.1, duration: 0.4, ease: 'power2.out' })
  // Animate SVG elements inside the screen
  if (!viewportRef.value) return
  const svgRects = viewportRef.value.querySelectorAll('.screen-svg rect[stroke]')
  gsap.fromTo(svgRects, { opacity: 0, y: 6 }, { opacity: 1, y: 0, stagger: 0.03, duration: 0.35, ease: 'power2.out', delay: 0.1 })
}

// Keyboard navigation
function onKeyDown(e: KeyboardEvent) {
  if (e.key === 'ArrowRight') next()
  else if (e.key === 'ArrowLeft') prev()
}

onMounted(() => {
  document.addEventListener('keydown', onKeyDown)
  startAutoPlay()
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeyDown)
  stopAutoPlay()
})

const steps = [
  {
    id: 'register',
    short: 'Регистрация',
    title: 'Регистрация клиники',
    url: 'app.umai-health.kz/onboarding',
    desc: 'Заполняете базовые данные — название, контакт, город. За 2 минуты создаётся аккаунт клиники с вашим брендом.',
    mobile: false,
    highlights: [
      'Аккаунт создаётся за 2 минуты',
      'Мы настроим ваш логотип и цвета',
      'Домен вида app.вашаклиника.kz',
    ],
  },
  {
    id: 'routes',
    short: 'Маршруты',
    title: 'Настройка маршрутов',
    url: 'app.umai-health.kz/settings/routes',
    desc: 'Платформа автоматически генерирует маршруты наблюдения по протоколам МЗ РК. Беременность, грудничок, малыш — или создайте свой.',
    mobile: false,
    highlights: [
      'Автогенерация по протоколам МЗ РК',
      '3 готовых маршрута + свои шаблоны',
      '52+ событий за 24 мес на семью',
    ],
  },
  {
    id: 'family',
    short: 'Семья',
    title: 'Добавление семьи',
    url: 'app.umai-health.kz/coordinator/new-family',
    desc: 'Координатор вносит маму — платформа за 2 секунды создаёт полный маршрут на 24 месяца: визиты, анализы, прививки, скрининги.',
    mobile: false,
    highlights: [
      'Маршрут создаётся за 2 секунды',
      'Автоматическая привязка к протоколу',
      'Группа риска определяется сразу',
    ],
  },
  {
    id: 'notify',
    short: 'Уведомления',
    title: 'Первое уведомление',
    url: 'app.umai-health.kz/coordinator/tasks',
    desc: 'Пропущен визит? Платформа создаёт задачу координатору и отправляет push семье. Один клик — и визит перезаписан.',
    mobile: false,
    highlights: [
      'Автоматические push + SMS напоминания',
      'Координатор видит задачу в очереди',
      'Семья записывается прямо из уведомления',
    ],
  },
  {
    id: 'dashboard',
    short: 'Результат',
    title: 'Панель координатора',
    url: 'app.umai-health.kz/coordinator',
    desc: 'Все семьи на одном экране. Приоритеты, просроченные, сегодняшние задачи. KPI в реальном времени. Без Excel, без обзвонов.',
    mobile: false,
    highlights: [
      'Все семьи — один экран',
      'Приоритеты: 🔴 просрочено → 🟡 сегодня → 🟢 по плану',
      'Удержание, визиты, NPS — всё на одном экране',
    ],
  },
]

const progressWidth = computed(() => `${(current.value / (steps.length - 1)) * 100}%`)

function next() {
  if (current.value < steps.length - 1) {
    direction.value = 'slide-left'
    current.value++
  }
}
function prev() {
  if (current.value > 0) {
    direction.value = 'slide-right'
    current.value--
  }
}
function goTo(i: number) {
  direction.value = i > current.value ? 'slide-left' : 'slide-right'
  current.value = i
}
</script>

<style scoped>
/* Progress */
.demo-progress {
  margin-bottom: 40px;
}
.progress-track {
  height: 3px;
  background: var(--color-border-light);
  border-radius: 2px;
  margin-bottom: 16px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: var(--gradient-cta);
  border-radius: 2px;
  transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}
.progress-steps {
  display: flex;
  justify-content: space-between;
}
.progress-dot {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
}
.dot-num {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  background: var(--color-border-light);
  color: var(--color-text-muted);
  transition: all var(--transition-smooth);
}
.progress-dot.active .dot-num {
  background: var(--color-primary);
  color: white;
  box-shadow: 0 0 0 4px var(--color-primary-light);
}
.progress-dot.done .dot-num {
  background: var(--color-success);
  color: white;
}
.dot-label {
  font-size: 11px;
  color: var(--color-text-muted);
  transition: color var(--transition-smooth);
  font-weight: 500;
}
.progress-dot.active .dot-label,
.progress-dot.done .dot-label {
  color: var(--color-text-primary);
}

/* Viewport */
.demo-viewport {
  overflow: hidden;
}

/* Slide */
.slide-layout {
  display: grid;
  grid-template-columns: 1.3fr 1fr;
  gap: 48px;
  align-items: start;
}

/* Desktop frame */
.desktop-frame {
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border);
  overflow: hidden;
  box-shadow: var(--shadow-lg);
  background: var(--color-surface);
}
.frame-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 16px;
  background: var(--color-bg-alt);
  border-bottom: 1px solid var(--color-border-light);
}
.frame-dots {
  display: flex;
  gap: 6px;
}
.frame-dots i {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--color-border);
}
.frame-dots i:first-child { background: #D4727C; }
.frame-dots i:nth-child(2) { background: #E9C46A; }
.frame-dots i:last-child { background: #7CB8D4; }
.frame-url {
  font-size: 11px;
  color: var(--color-text-muted);
  background: white;
  padding: 3px 12px;
  border-radius: var(--radius-full);
  border: 1px solid var(--color-border-light);
  flex: 1;
  max-width: 320px;
}
.frame-screen {
  aspect-ratio: 520 / 340;
  overflow: hidden;
}
.screen-svg {
  width: 100%;
  height: 100%;
  display: block;
}

/* Info panel */
.slide-info {
  padding-top: 16px;
}
.step-badge {
  display: inline-block;
  padding: 4px 14px;
  border-radius: var(--radius-full);
  background: var(--color-primary-light);
  color: var(--color-primary);
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 16px;
}
.slide-title {
  font-size: var(--text-h3);
  color: var(--color-text-primary);
  margin-bottom: 12px;
  line-height: var(--leading-tight);
}
.slide-desc {
  font-size: var(--text-body);
  color: var(--color-text-secondary);
  line-height: var(--leading-normal);
  margin-bottom: 20px;
}
.slide-highlights {
  list-style: none;
  padding: 0;
  margin: 0 0 28px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.slide-highlights li {
  font-size: 14px;
  color: var(--color-text-primary);
  padding-left: 24px;
  position: relative;
  line-height: 1.5;
}
.slide-highlights li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: var(--color-success);
  font-weight: 700;
}

/* Buttons */
.slide-actions {
  display: flex;
  gap: 12px;
}
.btn-prev,
.btn-next {
  padding: 10px 24px;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-smooth);
  border: none;
  font-family: inherit;
}
.btn-prev {
  background: var(--color-bg-alt);
  color: var(--color-text-secondary);
}
.btn-prev:hover {
  background: var(--color-border-light);
}
.btn-next {
  background: var(--color-primary);
  color: white;
}
.btn-next:hover {
  background: var(--color-primary-dark);
}
.btn-cta {
  background: var(--gradient-cta);
  text-decoration: none;
  display: inline-flex;
  align-items: center;
}

/* Auto-play button */
.autoplay-btn {
  position: absolute;
  right: 0;
  top: -4px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  color: var(--color-primary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-smooth);
}
.autoplay-btn:hover {
  background: var(--color-primary-light);
  border-color: var(--color-primary);
}
.demo-progress {
  position: relative;
}

/* Timer ring */
.dot-timer {
  position: absolute;
  top: -4px;
  left: -4px;
  transform: rotate(-90deg);
  pointer-events: none;
}
.timer-ring {
  transition: none;
}

/* Floating blobs */
.demo-blobs {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
  z-index: -1;
}
.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.3;
}
.blob-1 {
  width: 300px;
  height: 300px;
  background: var(--color-primary-light);
  top: -60px;
  left: -80px;
  animation: blobFloat1 12s ease-in-out infinite;
}
.blob-2 {
  width: 200px;
  height: 200px;
  background: var(--color-secondary-light);
  bottom: -40px;
  right: -60px;
  animation: blobFloat2 15s ease-in-out infinite;
}
@keyframes blobFloat1 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(40px, 30px) scale(1.1); }
}
@keyframes blobFloat2 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(-30px, -20px) scale(1.15); }
}

/* Shimmer on buttons */
.btn-shimmer {
  position: relative;
  overflow: hidden;
}
.btn-shimmer::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  animation: shimmer 3s ease-in-out infinite;
}
@keyframes shimmer {
  0% { left: -100%; }
  50%, 100% { left: 100%; }
}

/* Desktop frame glow on active step */
.desktop-frame {
  transition: box-shadow 0.6s ease;
}
.desktop-frame:hover {
  box-shadow: var(--shadow-hover), 0 0 60px rgba(139, 126, 200, 0.08);
}

/* Highlight items stagger entrance */
.highlight-item {
  opacity: 0;
  animation: highlightIn 0.4s ease-out forwards;
}
@keyframes highlightIn {
  from { opacity: 0; transform: translateX(-12px); }
  to { opacity: 1; transform: translateX(0); }
}

/* Transitions */
.slide-left-enter-active,
.slide-left-leave-active,
.slide-right-enter-active,
.slide-right-leave-active {
  transition: all 0.45s cubic-bezier(0.4, 0, 0.2, 1);
}
.slide-left-enter-from { opacity: 0; transform: translateX(60px) scale(0.98); }
.slide-left-leave-to { opacity: 0; transform: translateX(-40px) scale(0.98); }
.slide-right-enter-from { opacity: 0; transform: translateX(-60px) scale(0.98); }
.slide-right-leave-to { opacity: 0; transform: translateX(40px) scale(0.98); }

/* SVG animations — enhanced */
.anim-width {
  animation: growWidth 1.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
@keyframes growWidth {
  from { transform: scaleX(0); transform-origin: left; }
  to { transform: scaleX(1); transform-origin: left; }
}
.anim-slide-in {
  animation: slideInBounce 0.7s cubic-bezier(0.34, 1.56, 0.64, 1) 0.3s both;
}
@keyframes slideInBounce {
  from { opacity: 0; transform: translateY(-16px) scale(0.95); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

/* Frame screen inner glow */
.frame-screen {
  position: relative;
}
.frame-screen::after {
  content: '';
  position: absolute;
  inset: 0;
  pointer-events: none;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
  box-shadow: inset 0 0 40px rgba(139, 126, 200, 0.04);
}

/* Responsive */
@media (max-width: 900px) {
  .slide-layout {
    grid-template-columns: 1fr;
    gap: 28px;
  }
  .progress-steps {
    gap: 4px;
  }
  .dot-label {
    font-size: 9px;
  }
}

@media (max-width: 480px) {
  .dot-label {
    display: none;
  }
  .slide-actions {
    flex-direction: column;
  }
  .btn-prev,
  .btn-next {
    width: 100%;
    text-align: center;
  }
}
</style>

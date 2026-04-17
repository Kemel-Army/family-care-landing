<template>
  <div class="legal-page landing-container">
    <h1 class="legal-title font-display">Политика конфиденциальности</h1>
    <p class="legal-updated">Дата обновления: 13 апреля 2026 г.</p>

    <div class="legal-content">
      <section>
        <h2>1. Общие положения</h2>
        <p>
          Настоящая Политика конфиденциальности определяет порядок обработки и защиты персональных данных
          пользователей сайта umai-health.kz (далее — «Сайт»), принадлежащего команде UMAI Health (далее — «Оператор»).
        </p>
        <p>
          Политика разработана в соответствии с Законом Республики Казахстан от 21 мая 2013 года № 94-V
          «О персональных данных и их защите».
        </p>
      </section>

      <section>
        <h2>2. Какие данные мы собираем</h2>
        <p>Через формы на Сайте мы можем собирать следующие данные:</p>
        <ul>
          <li>Имя</li>
          <li>Название организации</li>
          <li>Адрес электронной почты (email)</li>
          <li>Номер телефона или мессенджер</li>
          <li>Текст комментария (при наличии)</li>
        </ul>
        <p>
          В демо-режиме платформы используются исключительно тестовые (фиктивные) данные.
          Реальные персональные данные пользователей в демо-режиме не обрабатываются.
        </p>
      </section>

      <section>
        <h2>3. Цели обработки</h2>
        <p>Персональные данные обрабатываются для следующих целей:</p>
        <ul>
          <li>Обработка заявки на подключение платформы</li>
          <li>Связь с пользователем по вопросам сотрудничества</li>
          <li>Улучшение качества обслуживания</li>
        </ul>
      </section>

      <section>
        <h2>4. Передача данных третьим лицам</h2>
        <p>
          Мы не передаём персональные данные третьим лицам, за исключением случаев,
          предусмотренных законодательством Республики Казахстан.
        </p>
      </section>

      <section>
        <h2>5. Хранение данных</h2>
        <p>
          Данные хранятся на серверах Supabase (облачная инфраструктура).
          Мы применяем организационные и технические меры для защиты данных от несанкционированного доступа.
        </p>
      </section>

      <section>
        <h2>6. Права пользователя</h2>
        <p>Вы имеете право:</p>
        <ul>
          <li>Запросить информацию о ваших персональных данных</li>
          <li>Потребовать их изменения или удаления</li>
          <li>Отозвать согласие на обработку</li>
        </ul>
        <p>Для реализации этих прав направьте запрос на <a href="mailto:info@umai-health.kz">info@umai-health.kz</a>.</p>
      </section>

      <section>
        <h2>7. Файлы cookie</h2>
        <p>
          Сайт может использовать cookie-файлы для обеспечения работы аналитических сервисов.
          Вы можете отключить cookie в настройках браузера.
        </p>
      </section>

      <section>
        <h2>8. Изменения политики</h2>
        <p>
          Оператор вправе вносить изменения в настоящую Политику. Актуальная версия
          всегда доступна по адресу
          <NuxtLink to="/privacy">umai-health.kz/privacy</NuxtLink>.
        </p>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'landing' })

useSeoMeta({
  title: 'Политика конфиденциальности — UMAI Health',
  description: 'Политика обработки персональных данных сайта UMAI Health.',
})
</script>

<style scoped>
.legal-page {
  padding: 140px 0 80px;
  max-width: 720px;
}

.legal-title {
  font-size: 2rem;
  font-weight: 700;
  margin: 0 0 8px;
}

.legal-updated {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0 0 40px;
}

.legal-content section {
  margin-bottom: 32px;
}

.legal-content h2 {
  font-size: 1.15rem;
  font-weight: 600;
  margin: 0 0 12px;
}

.legal-content p {
  font-size: 15px;
  line-height: 1.7;
  color: var(--color-text-secondary);
  margin: 0 0 12px;
}

.legal-content ul {
  padding-left: 20px;
  margin: 0 0 12px;
}

.legal-content li {
  font-size: 15px;
  line-height: 1.7;
  color: var(--color-text-secondary);
  margin-bottom: 4px;
}

.legal-content a {
  color: var(--color-primary);
  text-decoration: none;
}

.legal-content a:hover {
  text-decoration: underline;
}
</style>

<template>
  <div class="legal-page landing-container">
    <h1 class="legal-title font-display">Условия использования</h1>
    <p class="legal-updated">Дата обновления: 13 апреля 2026 г.</p>

    <div class="legal-content">
      <section>
        <h2>1. Общие положения</h2>
        <p>
          Настоящие Условия регулируют использование сайта umai-health.kz (далее — «Сайт»)
          и демо-режима платформы UMAI Health.
        </p>
        <p>Используя Сайт, вы соглашаетесь с настоящими Условиями.</p>
      </section>

      <section>
        <h2>2. Информационный характер</h2>
        <p>
          Сайт носит информационный характер и предназначен для ознакомления с возможностями
          платформы UMAI Health. Информация на Сайте не является публичной офертой.
        </p>
      </section>

      <section>
        <h2>3. Демо-режим</h2>
        <p>
          Демо-режим платформы предоставляется для ознакомительных целей. Все данные в демо-режиме
          являются тестовыми и не отражают реальных пациентов, семей или медицинских записей.
        </p>
        <p>
          Демо-данные не могут быть использованы для принятия медицинских или иных решений.
        </p>
      </section>

      <section>
        <h2>4. Платформа</h2>
        <p>
          Доступ к полнофункциональной платформе UMAI Health предоставляется клиникам
          на основании отдельного договора. Условия подключения, стоимость и объём услуг
          определяются индивидуально.
        </p>
      </section>

      <section>
        <h2>5. Ограничение ответственности</h2>
        <p>
          Оператор не несёт ответственности за содержание демо-данных, а также за решения,
          принятые на их основании. Платформа не заменяет медицинскую консультацию.
        </p>
      </section>

      <section>
        <h2>6. Интеллектуальная собственность</h2>
        <p>
          Все материалы Сайта (тексты, дизайн, программный код, иллюстрации) являются
          интеллектуальной собственностью команды UMAI Health и защищены законодательством
          Республики Казахстан.
        </p>
      </section>

      <section>
        <h2>7. Изменения условий</h2>
        <p>
          Оператор вправе изменять настоящие Условия. Актуальная версия доступна по адресу
          <NuxtLink to="/terms">umai-health.kz/terms</NuxtLink>.
        </p>
      </section>

      <section>
        <h2>8. Контакты</h2>
        <p>По вопросам, связанным с использованием Сайта: <a href="mailto:info@umai-health.kz">info@umai-health.kz</a></p>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'landing' })

useSeoMeta({
  title: 'Условия использования — UMAI Health',
  description: 'Условия использования сайта и демо-режима платформы UMAI Health.',
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

.legal-content a {
  color: var(--color-primary);
  text-decoration: none;
}

.legal-content a:hover {
  text-decoration: underline;
}
</style>

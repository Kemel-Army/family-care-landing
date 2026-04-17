<template>
  <LandingUiSectionWrapper
    badge="FAQ"
    title="Частые вопросы от клиник"
    subtitle="Ответы на вопросы, которые задают руководители и координаторы"
  >
    <div class="faq-grid" data-stagger="fade-up">
      <div v-for="(faq, i) in faqs" :key="faq.q" class="faq-item landing-card">
        <button class="faq-toggle" @click="toggleFaq(i)">
          <span class="faq-q">{{ faq.q }}</span>
          <Icon :name="openIndex === i ? 'lucide:chevron-up' : 'lucide:chevron-down'" class="faq-chevron" />
        </button>
        <Transition name="faq-expand">
          <div v-show="openIndex === i" class="faq-a">
            <p>{{ faq.a }}</p>
          </div>
        </Transition>
      </div>
    </div>
  </LandingUiSectionWrapper>
</template>

<script setup lang="ts">
const openIndex = ref<number | null>(0)

function toggleFaq(i: number) {
  openIndex.value = openIndex.value === i ? null : i
}

const faqs = [
  {
    q: 'Сколько стоит подключение?',
    a: 'Стоимость рассчитывается индивидуально в зависимости от объёма семей и набора модулей. Оставьте заявку — подготовим персональное предложение.',
  },
  {
    q: 'Чем это отличается от МИС?',
    a: 'МИС — это учёт пациентов и меддокументация. UMAI Health — это удержание и сопровождение: маршруты, напоминания, координация, аналитика удержания. Платформа работает автономно, но может интегрироваться с МИС через API.',
  },
  {
    q: 'Можно попробовать до покупки?',
    a: 'Да. Вы можете изучить платформу прямо сейчас в демо-режиме с тестовыми данными — без регистрации и обязательств. После этого можем обсудить пилот.',
  },
  {
    q: 'Что если у нас нет IT-отдела?',
    a: 'Всё настраиваем мы. Координатору нужен только браузер. Проводим обучение на месте — работаем рядом с вашей командой.',
  },
  {
    q: 'Как обеспечивается безопасность данных?',
    a: 'Шифрование AES-256 at rest и TLS 1.3 in transit. Row Level Security изолирует данные каждой клиники. Журнал действий фиксирует каждую операцию. Полное соответствие закону РК «О персональных данных».',
  },
  {
    q: 'Можно ли использовать свой бренд?',
    a: 'Да, полное брендирование под вашу клинику. Ваш логотип, цвета, домен. Семьи видят только вашу клинику.',
  },
  {
    q: 'Где физически хранятся данные пациентов?',
    a: 'Данные хранятся на зашифрованных серверах с AES-256. Для клиник с требованием локализации — возможно развёртывание на серверах в Казахстане. Ежедневные автоматические бэкапы.',
  },
  {
    q: 'Может ли персонал одной клиники видеть данные другой?',
    a: 'Нет. Row Level Security (RLS) на уровне базы данных полностью изолирует данные клиник. Обойти это невозможно даже через прямые API-запросы.',
  },
]
</script>

<style scoped>
.faq-grid {
  max-width: var(--content-medium);
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.faq-item {
  padding: 0;
  overflow: hidden;
}

.faq-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 18px 24px;
  border: none;
  background: transparent;
  cursor: pointer;
  text-align: left;
}

.faq-q {
  font-size: clamp(13px, 4vw, 15px);
  font-weight: 600;
  color: var(--color-text-primary);
  flex: 1;
  padding-right: 16px;
}

.faq-chevron {
  width: 18px;
  height: 18px;
  color: var(--color-text-muted);
  flex-shrink: 0;
  transition: transform var(--transition-fast);
}

.faq-a {
  padding: 0 24px 18px;
}

.faq-a p {
  font-size: 14px;
  line-height: 170%;
  color: var(--color-text-secondary);
  margin: 0;
  overflow-wrap: break-word;
  word-break: break-word;
}

.faq-expand-enter-active,
.faq-expand-leave-active {
  transition: all 0.2s ease;
  overflow: hidden;
}

.faq-expand-enter-from,
.faq-expand-leave-to {
  opacity: 0;
  max-height: 0;
  padding-top: 0;
  padding-bottom: 0;
}
</style>

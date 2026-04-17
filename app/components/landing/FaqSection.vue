<template>
  <LandingUiSectionWrapper
    id="faq"
    badge="FAQ"
    :title="title"
    :subtitle="subtitle"
  >
    <div class="faq-list" data-stagger="fade-up">
      <div
        v-for="(item, i) in items"
        :key="i"
        class="faq-item"
        :class="{ open: openIndex === i }"
      >
        <button class="faq-question" @click="toggle(i)">
          <span class="faq-q-text font-heading">{{ item.q }}</span>
          <Icon
            name="lucide:chevron-down"
            size="20"
            class="faq-chevron"
          />
        </button>
        <Transition name="faq-expand">
          <div v-if="openIndex === i" class="faq-answer">
            <p>{{ item.a }}</p>
          </div>
        </Transition>
      </div>
    </div>
  </LandingUiSectionWrapper>
</template>

<script lang="ts">
interface FaqItem {
  q: string
  a: string
}

const defaultFaqs: FaqItem[] = [
  {
    q: 'Что такое UMAI Health?',
    a: 'Это цифровая платформа-маршрут для частных клиник. Названная в честь Умай — тюркской богини-покровительницы матерей и детей, — она ведёт семью по персональному маршруту наблюдения от зачатия до 2 лет ребёнка, автоматизирует напоминания, координацию и контроль назначений.',
  },
  {
    q: 'Это мобильное приложение?',
    a: 'Платформа — это PWA (Progressive Web App), которое устанавливается на телефон из браузера без App Store. Работает офлайн, отправляет пуш-уведомления, занимает минимум места. Для клиники — web-панель на компьютере.',
  },
  {
    q: 'Мои данные в безопасности?',
    a: 'Да. Row Level Security изолирует данные каждой клиники. AES-256 шифрование, TLS 1.3, MFA для персонала, аудит-логи 3 года. Полное соответствие законодательству РК о персональных данных.',
  },
  {
    q: 'Какие клиники уже подключены?',
    a: 'Платформа находится на стадии запуска с первыми клиниками-партнёрами в Казахстане. Мы приглашаем клиники присоединиться на этапе пилота с особыми условиями.',
  },
  {
    q: 'Сколько стоит платформа?',
    a: 'Модель — ежемесячная подписка для клиники. Базовый пакет включает все 11 модулей. Стоимость зависит от объёма пациентов — запросите демо для индивидуального предложения.',
  },
  {
    q: 'Какие языки поддерживаются?',
    a: 'На старте — казахский и русский. Архитектура позволяет добавить любой язык. В планах — узбекский, кыргызский и английский.',
  },
]
</script>

<script setup lang="ts">
import { ref } from 'vue'

const props = withDefaults(defineProps<{
  title?: string
  subtitle?: string
  items?: FaqItem[]
}>(), {
  title: 'Частые вопросы',
  subtitle: 'Ответы на ключевые вопросы о платформе',
  items: () => defaultFaqs,
})

const openIndex = ref<number | null>(null)

function toggle(i: number) {
  openIndex.value = openIndex.value === i ? null : i
}
</script>

<style scoped>
.faq-list {
  max-width: 760px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.faq-item {
  border-radius: var(--radius-lg);
  background: var(--color-bg-card);
  border: 1px solid var(--color-border);
  overflow: hidden;
  transition: var(--transition-base);
}

.faq-item.open {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 1px rgba(139, 126, 200, 0.15);
}

.faq-question {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 18px 20px;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
}

.faq-q-text {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.faq-chevron {
  color: var(--color-text-muted);
  transition: transform 0.25s ease;
  flex-shrink: 0;
}

.faq-item.open .faq-chevron {
  transform: rotate(180deg);
  color: var(--color-primary);
}

.faq-answer {
  padding: 0 20px 18px;
}

.faq-answer p {
  font-size: 14px;
  line-height: 1.65;
  color: var(--color-text-secondary);
  margin: 0;
}

/* Expand animation */
.faq-expand-enter-active,
.faq-expand-leave-active {
  transition: all 0.25s ease;
  max-height: 300px;
  opacity: 1;
}

.faq-expand-enter-from,
.faq-expand-leave-to {
  max-height: 0;
  opacity: 0;
  padding-top: 0;
  padding-bottom: 0;
}
</style>

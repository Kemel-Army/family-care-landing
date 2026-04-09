<template>
  <div class="epds-page">
    <header class="page-header">
      <NuxtLink to="/family/mood" class="back-link">
        <Icon name="lucide:chevron-left" size="16" /> Назад
      </NuxtLink>
      <h1 class="page-title">EPDS-скрининг</h1>
    </header>

    <!-- Questions -->
    <div v-if="!submitted" class="epds-form">
      <p class="epds-intro">
        Отметьте ответ, который наиболее точно описывает ваше состояние за последние 7 дней.
      </p>

      <div v-for="(q, idx) in questions" :key="idx" class="question-block">
        <h3 class="question-number">Вопрос {{ idx + 1 }} из {{ questions.length }}</h3>
        <p class="question-text">{{ q.text }}</p>
        <div class="options">
          <button
            v-for="(opt, optIdx) in q.options"
            :key="optIdx"
            class="option-btn"
            :class="{ selected: answers[idx] === optIdx }"
            @click="answers[idx] = optIdx"
          >
            {{ opt }}
          </button>
        </div>
      </div>

      <button
        class="btn-submit"
        :disabled="!allAnswered || submitting"
        @click="submit"
      >
        {{ submitting ? 'Отправка...' : 'Получить результат' }}
      </button>
    </div>

    <!-- Result -->
    <div v-else class="epds-result">
      <div class="result-card" :class="riskLevel">
        <div class="result-score">{{ totalScore }}</div>
        <div class="result-max">из 30 баллов</div>
      </div>
      <h2 class="result-title">{{ resultTitle }}</h2>
      <p class="result-desc">{{ resultDescription }}</p>

      <div class="result-actions">
        <NuxtLink to="/family/mood" class="btn-back">Вернуться</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { EPDS_QUESTIONS } from '~/utils/constants'

definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const userId = useSupabaseUserId()

const questions = EPDS_QUESTIONS
const answers = reactive<number[]>(new Array(10).fill(-1))
const submitted = ref(false)
const submitting = ref(false)
const totalScore = ref(0)

const allAnswered = computed(() => answers.every(a => a >= 0))

const riskLevel = computed(() => {
  if (totalScore.value >= 13) return 'high'
  if (totalScore.value >= 10) return 'medium'
  return 'low'
})

const resultTitle = computed(() => {
  if (totalScore.value >= 13) return 'Высокий риск'
  if (totalScore.value >= 10) return 'Средний риск'
  return 'Низкий риск'
})

const resultDescription = computed(() => {
  if (totalScore.value >= 13) return 'Рекомендуем как можно скорее обратиться к психологу или психотерапевту. Послеродовая депрессия — это не ваша вина, и она хорошо поддаётся лечению.'
  if (totalScore.value >= 10) return 'Рекомендуем обратиться к специалисту для консультации. Раннее обращение помогает предотвратить ухудшение.'
  return 'Ваш результат в пределах нормы. Продолжайте следить за своим самочувствием и не стесняйтесь обращаться за помощью при необходимости.'
})

async function submit() {
  if (!allAnswered.value || !user.value) return
  submitting.value = true

  // Calculate score (questions 0,1,2 are scored 0-3; questions 3-9 are reverse scored 3-0)
  const scores = answers.map((a, i) => {
    if (i <= 2) return a // 0-3
    return 3 - a // reverse: 3,2,1,0
  })
  totalScore.value = scores.reduce((sum, s) => sum + s, 0)

  await supabase.from('epds_screenings').insert({
    user_id: userId.value,
    answers: scores,
    total_score: totalScore.value,
    risk_level: riskLevel.value,
  })

  submitted.value = true
  submitting.value = false
}
</script>

<style scoped>
.epds-page { max-width: 640px; margin: 0 auto; padding: 24px 16px; }
.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
.back-link { display: flex; align-items: center; gap: 4px; color: var(--color-text-secondary); text-decoration: none; font-size: 0.85rem; }
.page-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }

.epds-intro { font-size: 0.9rem; color: var(--color-text-secondary); margin-bottom: 24px; line-height: 1.5; }

.question-block { margin-bottom: 24px; }
.question-number { font-size: 0.75rem; color: var(--color-text-muted); margin-bottom: 6px; }
.question-text { font-size: 0.95rem; font-weight: 500; margin-bottom: 12px; }

.options { display: flex; flex-direction: column; gap: 6px; }
.option-btn {
  text-align: left; padding: 12px 16px; border: 1px solid var(--color-border);
  border-radius: var(--radius-sm); background: var(--color-surface); font-size: 0.85rem;
  cursor: pointer; transition: all var(--transition-fast); font-family: var(--font-body); width: 100%;
}
.option-btn:hover { border-color: var(--color-primary-light); }
.option-btn.selected { border-color: var(--color-primary); background: var(--color-primary-ultralight); color: var(--color-primary); font-weight: 600; }

.btn-submit {
  width: 100%; padding: 14px; background: var(--gradient-cta); color: white; border: none;
  border-radius: var(--radius-sm); font-size: 1rem; font-weight: 600; cursor: pointer;
  font-family: var(--font-body); margin-top: 8px;
}
.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }

/* Result */
.epds-result { text-align: center; padding: 24px 0; }
.result-card {
  width: 120px; height: 120px; border-radius: 50%; margin: 0 auto 20px;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
}
.result-card.low { background: rgba(124, 184, 212, 0.15); color: var(--color-success); }
.result-card.medium { background: rgba(233, 196, 106, 0.15); color: var(--color-warning); }
.result-card.high { background: rgba(231, 111, 81, 0.15); color: var(--color-danger); }
.result-score { font-size: 2.5rem; font-weight: 700; font-family: var(--font-mono); }
.result-max { font-size: 0.75rem; }
.result-title { font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; margin-bottom: 8px; }
.result-desc { font-size: 0.9rem; color: var(--color-text-secondary); line-height: 1.5; max-width: 480px; margin: 0 auto 24px; }
.result-actions { margin-top: 20px; }
.btn-back {
  display: inline-block; padding: 10px 24px; background: var(--color-surface);
  border: 1px solid var(--color-border); border-radius: var(--radius-sm);
  text-decoration: none; color: var(--color-text-primary); font-weight: 600;
}
</style>

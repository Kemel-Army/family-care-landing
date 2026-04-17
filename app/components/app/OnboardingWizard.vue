<template>
  <div class="onboard-overlay">
    <div class="onboard-card">
      <!-- Progress bar -->
      <div class="onboard-progress">
        <div class="onboard-progress-fill" :style="{ width: `${progressPercent}%` }" />
      </div>
      <div class="onboard-step-label">Шаг {{ currentStep + 1 }} из {{ steps.length }}</div>

      <!-- Step content -->
      <Transition name="slide" mode="out-in">
        <div :key="currentStep" class="onboard-step">
          <!-- Step 1: Welcome -->
          <div v-if="currentStep === 0" class="step-content">
            <div class="step-icon-wrap">
              <Icon name="lucide:heart-pulse" size="48" class="step-icon" />
            </div>
            <h2>Добро пожаловать в UMAI Health!</h2>
            <p>Мы поможем вам заботиться о здоровье вашей семьи. Давайте настроим ваш профиль.</p>
          </div>

          <!-- Step 2: Profile basics -->
          <div v-if="currentStep === 1" class="step-content step-form">
            <h2>Ваш профиль</h2>
            <p>Как к вам обращаться?</p>
            <div class="form-row">
              <input v-model="form.firstName" type="text" placeholder="Имя" class="onboard-input" />
              <input v-model="form.lastName" type="text" placeholder="Фамилия" class="onboard-input" />
            </div>
            <input v-model="form.phone" type="tel" placeholder="Телефон (необязательно)" class="onboard-input" />
          </div>

          <!-- Step 3: Your journey -->
          <div v-if="currentStep === 2" class="step-content">
            <h2>Ваш этап</h2>
            <p>На каком этапе вы сейчас?</p>
            <div class="journey-options">
              <button
                v-for="opt in journeyOptions"
                :key="opt.value"
                class="journey-btn"
                :class="{ active: form.journeyType === opt.value }"
                @click="form.journeyType = opt.value as typeof form.journeyType"
              >
                <Icon :name="opt.icon" size="24" />
                <span>{{ opt.label }}</span>
              </button>
            </div>
          </div>

          <!-- Step 4: Child info (conditional) -->
          <div v-if="currentStep === 3" class="step-content step-form">
            <h2>{{ form.journeyType === 'pregnancy' ? 'О беременности' : 'О ребёнке' }}</h2>
            <template v-if="form.journeyType === 'pregnancy'">
              <p>Укажите предполагаемую дату родов (ПДР)</p>
              <input v-model="form.dueDate" type="date" class="onboard-input" />
            </template>
            <template v-else>
              <p>Информация о малыше</p>
              <input v-model="form.childName" type="text" placeholder="Имя ребёнка" class="onboard-input" />
              <input v-model="form.childBirthDate" type="date" class="onboard-input" />
              <div class="gender-row">
                <button
                  class="gender-btn"
                  :class="{ active: form.childGender === 'female' }"
                  @click="form.childGender = 'female'"
                >
                  Девочка
                </button>
                <button
                  class="gender-btn"
                  :class="{ active: form.childGender === 'male' }"
                  @click="form.childGender = 'male'"
                >
                  Мальчик
                </button>
              </div>
            </template>
          </div>

          <!-- Step 5: All set -->
          <div v-if="currentStep === 4" class="step-content">
            <div class="step-icon-wrap">
              <Icon name="lucide:party-popper" size="48" class="step-icon" />
            </div>
            <h2>Всё готово!</h2>
            <p>Ваш маршрут заботы настроен. Добро пожаловать!</p>
          </div>
        </div>
      </Transition>

      <!-- Navigation -->
      <div class="onboard-nav">
        <button v-if="currentStep > 0" class="nav-btn secondary" @click="currentStep--">
          Назад
        </button>
        <div v-else />
        <button
          class="nav-btn primary"
          :disabled="!canProceed || saving"
          @click="handleNext"
        >
          <span v-if="saving" class="spinner" />
          {{ currentStep === steps.length - 1 ? 'Начать' : 'Далее' }}
        </button>
      </div>

      <!-- Skip -->
      <button v-if="currentStep < steps.length - 1" class="skip-btn" @click="handleSkip">
        Пропустить
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const emit = defineEmits<{ (e: 'complete'): void }>()

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const authStore = useAuthStore()

const currentStep = ref(0)
const saving = ref(false)

const steps = ['welcome', 'profile', 'journey', 'details', 'done']

const form = reactive({
  firstName: authStore.profile?.first_name || '',
  lastName: authStore.profile?.last_name || '',
  phone: '',
  journeyType: '' as '' | 'pregnancy' | 'postpartum' | 'infant' | 'toddler',
  dueDate: '',
  childName: '',
  childBirthDate: '',
  childGender: '' as '' | 'male' | 'female',
})

const journeyOptions = [
  { value: 'pregnancy', label: 'Беременность', icon: 'lucide:baby' },
  { value: 'postpartum', label: 'Послеродовой', icon: 'lucide:heart-handshake' },
  { value: 'infant', label: 'Младенец (0-1)', icon: 'lucide:smile' },
  { value: 'toddler', label: 'Тоддлер (1-3)', icon: 'lucide:footprints' },
]

const progressPercent = computed(() => ((currentStep.value + 1) / steps.length) * 100)

const canProceed = computed(() => {
  switch (currentStep.value) {
    case 0: return true
    case 1: return form.firstName.trim().length > 0
    case 2: return form.journeyType !== ''
    case 3:
      if (form.journeyType === 'pregnancy') return form.dueDate !== ''
      return form.childName.trim().length > 0
    case 4: return true
    default: return true
  }
})

async function handleNext() {
  if (currentStep.value < steps.length - 1) {
    currentStep.value++
    return
  }

  // Final step — save everything
  saving.value = true
  try {
    // Update profile
    if (user.value) {
        await supabase.from('users').update({
          first_name: form.firstName.trim(),
          last_name: form.lastName.trim(),
          phone: form.phone.trim() || null,
        }).eq('id', user.value.id)
      }

    // Add child if not pregnancy
    if (form.journeyType !== 'pregnancy' && form.childName && authStore.familyId) {
      await supabase.from('child_profiles').insert({
        family_id: authStore.familyId,
        name: form.childName.trim(),
        dob: form.childBirthDate || null,        gender: form.childGender || 'female',
      })    }

    // Refresh auth store
    await authStore.initialize()
    emit('complete')
  }
  catch (err) {
    console.error('Onboarding save error:', err)
  }
  finally {
    saving.value = false
  }
}

function handleSkip() {
  emit('complete')
}
</script>

<style scoped>
.onboard-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 16px;
}

.onboard-card {
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: 20px;
  padding: 32px;
  max-width: 480px;
  width: 100%;
  position: relative;
}

.onboard-progress {
  height: 4px;
  background: var(--color-border);
  border-radius: 2px;
  margin-bottom: 8px;
  overflow: hidden;
}

.onboard-progress-fill {
  height: 100%;
  background: var(--color-primary);
  border-radius: 2px;
  transition: width 0.3s ease;
}

.onboard-step-label {
  font-size: 12px;
  color: var(--color-text-muted);
  margin-bottom: 24px;
}

.step-content {
  text-align: center;
  min-height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.step-content h2 {
  font-size: 22px;
  font-weight: 700;
  color: var(--color-text);
  margin: 0;
}

.step-content p {
  font-size: 15px;
  color: var(--color-text-muted);
  margin: 0;
  max-width: 360px;
}

.step-icon-wrap {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  background: var(--color-primary-bg);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8px;
}

.step-icon {
  color: var(--color-primary);
}

.step-form {
  width: 100%;
}

.step-form .form-row {
  display: flex;
  gap: 8px;
  width: 100%;
}

.onboard-input {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--color-border);
  border-radius: 10px;
  background: var(--color-bg-alt);
  color: var(--color-text);
  font-size: 15px;
  outline: none;
  transition: border-color 0.2s;
}

.onboard-input:focus {
  border-color: var(--color-primary);
}

.journey-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  width: 100%;
  margin-top: 8px;
}

.journey-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  border: 1.5px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-bg-alt);
  color: var(--color-text-muted);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.journey-btn:hover {
  border-color: var(--color-primary);
  color: var(--color-text);
}

.journey-btn.active {
  border-color: var(--color-primary);
  background: var(--color-primary-bg);
  color: var(--color-primary);
}

.gender-row {
  display: flex;
  gap: 8px;
  width: 100%;
}

.gender-btn {
  flex: 1;
  padding: 12px;
  border: 1.5px solid var(--color-border);
  border-radius: 10px;
  background: var(--color-bg-alt);
  color: var(--color-text-muted);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.gender-btn.active {
  border-color: var(--color-primary);
  background: var(--color-primary-bg);
  color: var(--color-primary);
}

.onboard-nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 24px;
  gap: 12px;
}

.nav-btn {
  padding: 10px 24px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.2s;
}

.nav-btn.primary {
  background: var(--color-primary);
  color: white;
}

.nav-btn.primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.nav-btn.secondary {
  background: var(--color-bg-alt);
  color: var(--color-text-muted);
  border: 1px solid var(--color-border);
}

.skip-btn {
  display: block;
  margin: 12px auto 0;
  background: none;
  border: none;
  color: var(--color-text-muted);
  font-size: 13px;
  cursor: pointer;
  text-decoration: underline;
  opacity: 0.7;
}

.skip-btn:hover {
  opacity: 1;
}

.spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
  margin-right: 6px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Slide transition */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.25s ease;
}

.slide-enter-from {
  transform: translateX(20px);
  opacity: 0;
}

.slide-leave-to {
  transform: translateX(-20px);
  opacity: 0;
}
</style>

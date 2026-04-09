<template>
  <div class="verify-wrap">
    <h2 class="auth-title">Подтверждение</h2>
    <div class="verify-content">
      <div class="check-ring">
        <svg class="check-svg" viewBox="0 0 52 52">
          <circle class="check-circle" cx="26" cy="26" r="24" fill="none" />
          <path class="check-path" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8" />
        </svg>
      </div>
      <p class="verify-text">Ваш email подтверждён</p>
      <p class="verify-sub">Перенаправляем в личный кабинет...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ROLE_HOME_MAP } from '~/utils/constants'
import type { UserRole } from '~/types/database'

definePageMeta({ layout: 'auth' })

const user = useSupabaseUser()

onMounted(() => {
  setTimeout(() => {
    if (user.value) {
      const role = (user.value.user_metadata?.role as UserRole) || 'mother'
      navigateTo(ROLE_HOME_MAP[role])
    } else {
      navigateTo('/auth/login')
    }
  }, 1500)
})
</script>

<style scoped>
.verify-wrap { display: flex; flex-direction: column; align-items: center; }
.auth-title { text-align: center; font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; margin-bottom: 24px; }

.verify-content { display: flex; flex-direction: column; align-items: center; gap: 14px; padding: 20px 0; }

.check-ring { width: 64px; height: 64px; }
.check-svg { width: 64px; height: 64px; }
.check-circle { stroke: var(--color-success); stroke-width: 2; stroke-dasharray: 166; stroke-dashoffset: 166; animation: circleStroke 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards; }
.check-path { stroke: var(--color-success); stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; stroke-dasharray: 48; stroke-dashoffset: 48; animation: checkStroke 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.4s forwards; }

.verify-text { font-size: 1rem; font-weight: 600; animation: fadeUp 0.4s ease 0.6s both; }
.verify-sub { font-size: 0.82rem; color: var(--color-text-muted); animation: fadeUp 0.4s ease 0.8s both; }

@keyframes circleStroke { to { stroke-dashoffset: 0; } }
@keyframes checkStroke { to { stroke-dashoffset: 0; } }
@keyframes fadeUp { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
</style>

.verify-icon {
  color: var(--color-success);
}
</style>

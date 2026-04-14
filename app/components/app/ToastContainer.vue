<template>
  <Teleport to="body">
    <TransitionGroup name="toast" tag="div" class="toast-container">
      <div
        v-for="t in toasts"
        :key="t.id"
        class="toast-item"
        :class="`toast-item--${t.type}`"
      >
        <Icon :name="toastIcon(t.type)" size="16" />
        {{ t.message }}
      </div>
    </TransitionGroup>
  </Teleport>
</template>

<script setup lang="ts">
const { toasts } = useToast()

function toastIcon(type: string) {
  if (type === 'success') return 'lucide:check-circle'
  if (type === 'error') return 'lucide:alert-circle'
  return 'lucide:info'
}
</script>

<style scoped>
.toast-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 10000;
  display: flex;
  flex-direction: column;
  gap: 8px;
  pointer-events: none;
}

.toast-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
  color: #fff;
  backdrop-filter: blur(12px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  pointer-events: auto;
}

.toast-item--success {
  background: rgba(34, 197, 94, 0.92);
}

.toast-item--error {
  background: rgba(239, 68, 68, 0.92);
}

.toast-item--info {
  background: rgba(99, 102, 241, 0.92);
}

.toast-enter-active {
  transition: all 0.3s ease;
}

.toast-leave-active {
  transition: all 0.25s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(40px);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(40px);
}

@media (max-width: 640px) {
  .toast-container {
    bottom: 80px;
    right: 12px;
    left: 12px;
  }
}
</style>

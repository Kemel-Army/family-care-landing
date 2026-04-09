<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="modelValue" class="demo-modal-overlay" @click.self="close">
        <div class="demo-modal">
          <!-- Header -->
          <div class="demo-modal-header">
            <h2 class="demo-modal-title font-display">Попробуйте платформу</h2>
            <p class="demo-modal-desc">Выберите роль и откройте интерактивный прототип</p>
            <button class="demo-modal-close" @click="close" aria-label="Закрыть">
              <Icon name="lucide:x" size="20" />
            </button>
          </div>

          <!-- Role cards -->
          <div class="demo-roles">
            <NuxtLink
              v-for="role in roles"
              :key="role.to"
              :to="role.to"
              class="demo-role-card"
              @click="close"
            >
              <div class="role-icon" :style="{ background: role.gradient }">
                <Icon :name="role.icon" size="28" />
              </div>
              <div class="role-body">
                <h3 class="role-title font-heading">{{ role.title }}</h3>
                <p class="role-desc">{{ role.description }}</p>
                <ul class="role-features">
                  <li v-for="f in role.features" :key="f">{{ f }}</li>
                </ul>
              </div>
              <div class="role-arrow">
                <Icon name="lucide:arrow-right" size="18" />
              </div>
            </NuxtLink>
          </div>

          <!-- Footer hint -->
          <p class="demo-modal-hint">
            Данные демо-режима — фиктивные. Для полного доступа
            <NuxtLink to="/auth/register" class="demo-modal-link" @click="close">зарегистрируйтесь</NuxtLink>.
          </p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
const props = defineProps<{
  modelValue: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

function close() {
  emit('update:modelValue', false)
}

const roles = [
  {
    to: '/demo/family',
    icon: 'lucide:heart',
    title: 'Приложение мамы',
    description: 'Маршрут заботы от зачатия до 2 лет',
    gradient: 'linear-gradient(135deg, var(--color-secondary), var(--color-accent-warm))',
    features: ['Принять витамин', 'Просмотр маршрута', 'Ближайшие записи'],
  },
  {
    to: '/demo/coordinator',
    icon: 'lucide:clipboard-list',
    title: 'Панель координатора',
    description: 'Управление семьями и задачами',
    gradient: 'var(--gradient-cta)',
    features: ['Очередь задач', 'Расписание дня', 'KPI метрики'],
  },
  {
    to: '/demo/doctor',
    icon: 'lucide:stethoscope',
    title: 'Кабинет врача',
    description: 'Расписание и карты пациентов',
    gradient: 'linear-gradient(135deg, var(--color-accent-blue), var(--color-primary))',
    features: ['Расписание визитов', 'Adherence пациентов', 'Медицинская карта'],
  },
]

// Close on Escape
function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') close()
}

watch(() => props.modelValue, (open) => {
  if (open) {
    document.addEventListener('keydown', onKeydown)
    document.body.style.overflow = 'hidden'
  } else {
    document.removeEventListener('keydown', onKeydown)
    document.body.style.overflow = ''
  }
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeydown)
  document.body.style.overflow = ''
})
</script>

<style scoped>
/* Overlay */
.demo-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 200;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: rgba(74, 68, 88, 0.4);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

/* Modal */
.demo-modal {
  background: var(--color-surface);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-lg);
  max-width: 680px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  padding: 32px;
  position: relative;
}

.demo-modal-header {
  margin-bottom: 28px;
  padding-right: 40px;
}

.demo-modal-title {
  font-size: var(--text-h2);
  color: var(--color-text-primary);
  margin: 0 0 6px;
}

.demo-modal-desc {
  font-size: var(--text-body);
  color: var(--color-text-secondary);
  margin: 0;
}

.demo-modal-close {
  position: absolute;
  top: 24px;
  right: 24px;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border-light);
  background: transparent;
  color: var(--color-text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.demo-modal-close:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

/* Role cards */
.demo-roles {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 24px;
}

.demo-role-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-light);
  text-decoration: none;
  transition: all var(--transition-smooth);
}

.demo-role-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-md);
  transform: translateX(4px);
}

.role-icon {
  width: 56px;
  height: 56px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.role-body { flex: 1; }

.role-title {
  font-size: var(--text-body-lg);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 4px;
}

.role-desc {
  font-size: var(--text-sm);
  color: var(--color-text-secondary);
  margin: 0 0 8px;
}

.role-features {
  display: flex;
  gap: 12px;
  list-style: none;
  padding: 0;
  margin: 0;
}

.role-features li {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  padding: 2px 8px;
  background: var(--color-bg-alt);
  border-radius: var(--radius-full);
}

.role-arrow {
  color: var(--color-text-muted);
  opacity: 0;
  transform: translateX(-8px);
  transition: all var(--transition-fast);
}

.demo-role-card:hover .role-arrow {
  opacity: 1;
  transform: translateX(0);
}

/* Hint */
.demo-modal-hint {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  text-align: center;
  margin: 0;
}

.demo-modal-link {
  color: var(--color-primary);
  font-weight: 600;
  text-decoration: none;
}

.demo-modal-link:hover {
  text-decoration: underline;
}

/* Transitions */
.modal-enter-active {
  transition: opacity 0.3s ease;
}
.modal-enter-active .demo-modal {
  transition: transform 0.3s cubic-bezier(0.22, 0.61, 0.36, 1), opacity 0.3s ease;
}
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-leave-active .demo-modal {
  transition: transform 0.2s ease, opacity 0.2s ease;
}
.modal-enter-from {
  opacity: 0;
}
.modal-enter-from .demo-modal {
  transform: scale(0.95) translateY(16px);
  opacity: 0;
}
.modal-leave-to {
  opacity: 0;
}
.modal-leave-to .demo-modal {
  transform: scale(0.98);
  opacity: 0;
}

/* Responsive */
@media (max-width: 640px) {
  .demo-modal {
    padding: 24px 20px;
    border-radius: var(--radius-lg);
  }

  .role-icon {
    width: 44px;
    height: 44px;
  }

  .role-features {
    flex-wrap: wrap;
    gap: 6px;
  }

  .role-arrow {
    display: none;
  }
}
</style>

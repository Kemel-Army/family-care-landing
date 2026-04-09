<template>
  <div class="empty-state">
    <ClientOnly>
      <div class="empty-state-lottie">
        <LottiePlayer
          :animation-link="`/lottie/${animationFile}.json`"
          :height="120"
          :width="120"
          :loop="true"
          :auto-play="true"
        />
      </div>
      <template #fallback>
        <div class="empty-state-icon">
          <Icon :name="icon" :size="36" />
        </div>
      </template>
    </ClientOnly>
    <h3 class="empty-state-title">{{ title }}</h3>
    <p class="empty-state-description">{{ description }}</p>
    <button v-if="actionLabel" class="app-btn app-btn--primary app-btn--sm" @click="$emit('action')">
      <Icon v-if="actionIcon" :name="actionIcon" size="16" />
      {{ actionLabel }}
    </button>
  </div>
</template>

<script setup lang="ts">
import { defineAsyncComponent, computed } from 'vue'

const LottiePlayer = defineAsyncComponent(() =>
  import('vue3-lottie').then((m) => m.Vue3Lottie),
)

const props = withDefaults(defineProps<{
  icon?: string
  title: string
  description?: string
  actionLabel?: string
  actionIcon?: string
}>(), {
  icon: 'lucide:inbox',
  description: '',
})

defineEmits<{ action: [] }>()

const iconToAnimation: Record<string, string> = {
  'lucide:stethoscope': 'empty-medical',
  'lucide:pill': 'empty-medical',
  'lucide:heart-pulse': 'empty-medical',
  'lucide:folder-open': 'empty-document',
  'lucide:file-text': 'empty-document',
  'lucide:calendar-check': 'empty-calendar',
  'lucide:calendar': 'empty-calendar',
  'lucide:route': 'empty-calendar',
  'lucide:search': 'empty-search',
}

const animationFile = computed(() => iconToAnimation[props.icon] || 'empty-inbox')
</script>

<template>
  <div class="empty-state">
    <div class="empty-state-icon">
      <Icon :name="icon" :size="36" />
    </div>
    <h3 class="empty-state-title">{{ title }}</h3>
    <p class="empty-state-description">{{ description }}</p>
    <button v-if="actionLabel" class="app-btn app-btn--primary app-btn--sm" @click="$emit('action')">
      <Icon v-if="actionIcon" :name="actionIcon" size="16" />
      {{ actionLabel }}
    </button>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
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
</script>

<template>
  <div class="page-header">
    <div class="page-header-top">
      <div>
        <div v-if="breadcrumbs.length" class="page-breadcrumbs">
          <template v-for="(crumb, i) in breadcrumbs" :key="i">
            <NuxtLink v-if="crumb.to" :to="crumb.to" class="breadcrumb-link">{{ crumb.label }}</NuxtLink>
            <span v-else class="breadcrumb-current">{{ crumb.label }}</span>
            <Icon v-if="i < breadcrumbs.length - 1" name="lucide:chevron-right" size="12" class="breadcrumb-sep" />
          </template>
        </div>
        <h1 class="page-title">{{ title }}</h1>
        <p v-if="description" class="page-description">{{ description }}</p>
      </div>
      <div v-if="$slots.actions" class="page-actions">
        <slot name="actions" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  title: string
  description?: string
  breadcrumbs?: Array<{ label: string; to?: string }>
}>(), {
  description: '',
  breadcrumbs: () => [],
})
</script>

<style scoped>
.page-header {
  margin-bottom: var(--app-gap-lg);
}

.page-header-top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.page-breadcrumbs {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 8px;
  font-size: 0.8rem;
}

.breadcrumb-link {
  color: var(--color-text-muted);
  text-decoration: none;
  transition: color var(--transition-fast);
}

.breadcrumb-link:hover {
  color: var(--color-primary);
}

.breadcrumb-current {
  color: var(--color-text-secondary);
  font-weight: 500;
}

.breadcrumb-sep {
  color: var(--color-text-muted);
}

.page-title {
  font-family: var(--font-display);
  font-size: clamp(1.25rem, 3vw, 1.75rem);
  font-weight: 700;
  color: var(--color-text-primary);
  line-height: 1.2;
  margin: 0;
}

.page-description {
  font-size: 0.9rem;
  color: var(--color-text-muted);
  margin-top: 6px;
  line-height: 1.5;
}

.page-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}
</style>

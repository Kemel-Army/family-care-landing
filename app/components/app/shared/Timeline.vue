<template>
  <div class="timeline-wrapper">
    <div
      v-for="(item, i) in items"
      :key="item.id"
      class="timeline-item"
      :class="[`timeline-item--${item.status}`, { 'timeline-item--last': i === items.length - 1 }]"
    >
      <div class="timeline-track">
        <div class="timeline-dot" :class="[`timeline-dot--${item.status}`]">
          <Icon v-if="item.status === 'completed'" name="lucide:check" size="12" />
          <Icon v-else-if="item.status === 'overdue'" name="lucide:circle-alert" size="12" />
          <span v-else class="timeline-dot-inner" />
        </div>
        <div v-if="i < items.length - 1" class="timeline-line" :class="[`timeline-line--${item.status}`]" />
      </div>
      <div class="timeline-content">
        <div class="timeline-header">
          <span class="timeline-title">{{ item.title }}</span>
          <span v-if="item.date" class="timeline-date">{{ item.date }}</span>
        </div>
        <p v-if="item.description" class="timeline-description">{{ item.description }}</p>
        <span v-if="item.badge" class="status-badge" :class="[`status-badge--${item.status === 'overdue' ? 'danger' : item.status === 'active' ? 'warning' : item.status === 'completed' ? 'success' : 'neutral'}`]">
          {{ item.badge }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  items: Array<{
    id: string | number
    title: string
    description?: string
    date?: string
    badge?: string
    status: 'completed' | 'active' | 'overdue' | 'upcoming'
  }>
}>()
</script>

<style scoped>
.timeline-wrapper {
  position: relative;
}

.timeline-item {
  display: flex;
  gap: 16px;
  padding-bottom: 24px;
}

.timeline-item--last {
  padding-bottom: 0;
}

.timeline-track {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex-shrink: 0;
  width: 24px;
}

.timeline-dot {
  width: 24px;
  height: 24px;
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  position: relative;
  z-index: 1;
}

.timeline-dot--completed {
  background: var(--color-success);
  color: white;
}

.timeline-dot--active {
  background: var(--color-primary);
  color: white;
  box-shadow: 0 0 0 4px rgba(139, 126, 200, 0.2);
}

.timeline-dot--overdue {
  background: var(--color-danger);
  color: white;
  box-shadow: 0 0 0 4px rgba(212, 114, 124, 0.2);
}

.timeline-dot--upcoming {
  background: var(--color-border);
  border: 2px solid var(--color-border-light);
}

.timeline-dot-inner {
  width: 8px;
  height: 8px;
  border-radius: var(--radius-full);
  background: white;
}

.timeline-line {
  width: 2px;
  flex: 1;
  min-height: 20px;
  background: var(--color-border);
  margin-top: 4px;
}

.timeline-line--completed { background: var(--color-success); }
.timeline-line--active { background: linear-gradient(to bottom, var(--color-primary), var(--color-border)); }

.timeline-content {
  flex: 1;
  padding-top: 2px;
}

.timeline-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 4px;
}

.timeline-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.timeline-item--upcoming .timeline-title {
  color: var(--color-text-muted);
}

.timeline-date {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  font-family: var(--font-mono);
  white-space: nowrap;
}

.timeline-description {
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  line-height: 1.4;
  margin: 0 0 6px;
}
</style>

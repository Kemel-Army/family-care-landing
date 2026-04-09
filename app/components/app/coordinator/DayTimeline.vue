<template>
  <div class="day-timeline">
    <div v-for="slot in schedule" :key="slot.time" class="timeline-slot">
      <span class="timeline-time font-mono">{{ slot.time }}</span>
      <div class="timeline-rail">
        <div class="timeline-dot" :class="{ 'dot-active': slot.active, 'dot-past': slot.past }" />
        <div class="timeline-line" />
      </div>
      <div class="timeline-event" :class="{ 'event-active': slot.active }">
        <span class="event-name">{{ slot.event }}</span>
        <span v-if="slot.detail" class="event-detail">{{ slot.detail }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  schedule: Array<{
    time: string
    event: string
    detail?: string | null
    active?: boolean
    past?: boolean
  }>
}>()
</script>

<style scoped>
.day-timeline {
  display: flex;
  flex-direction: column;
}

.timeline-slot {
  display: flex;
  gap: 12px;
  min-height: 48px;
}

.timeline-time {
  width: 44px;
  font-size: 11px;
  color: var(--color-text-muted);
  padding-top: 2px;
  flex-shrink: 0;
}

.timeline-rail {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 16px;
  flex-shrink: 0;
}

.timeline-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--color-border);
  flex-shrink: 0;
  margin-top: 4px;
}

.dot-active {
  background: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(139, 126, 200, 0.2);
}

.dot-past {
  background: var(--color-success);
}

.timeline-line {
  width: 2px;
  flex: 1;
  background: var(--color-border-light);
  min-height: 20px;
}

.timeline-slot:last-child .timeline-line {
  display: none;
}

.timeline-event {
  flex: 1;
  padding-bottom: 12px;
}

.event-active {
  font-weight: 600;
}

.event-name {
  display: block;
  font-size: var(--text-sm);
  color: var(--color-text-primary);
}

.event-detail {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}
</style>

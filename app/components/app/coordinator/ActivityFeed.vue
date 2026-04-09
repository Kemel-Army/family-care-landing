<template>
  <div class="activity-feed">
    <div v-for="item in items" :key="item.id" class="feed-item">
      <div class="feed-dot" />
      <div class="feed-content">
        <span class="feed-text">{{ item.text }}</span>
        <span class="feed-time">{{ item.time }}</span>
      </div>
    </div>
    <div v-if="!items.length" class="feed-empty">
      <Icon name="lucide:inbox" size="24" style="opacity: 0.3" />
      <span>Нет последних событий</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  items: Array<{
    id: number | string
    text: string
    time: string
  }>
}>()
</script>

<style scoped>
.activity-feed {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.feed-item {
  display: flex;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border-light);
}

.feed-item:last-child {
  border-bottom: none;
}

.feed-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--color-primary);
  opacity: 0.5;
  flex-shrink: 0;
  margin-top: 6px;
}

.feed-content {
  flex: 1;
}

.feed-text {
  display: block;
  font-size: var(--text-sm);
  color: var(--color-text-primary);
  line-height: 1.4;
}

.feed-time {
  font-size: var(--text-xs);
  color: var(--color-text-muted);
}

.feed-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 24px;
  color: var(--color-text-muted);
  font-size: var(--text-sm);
}
</style>

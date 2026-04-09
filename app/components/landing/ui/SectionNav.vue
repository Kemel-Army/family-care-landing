<template>
  <nav class="section-nav" aria-label="Навигация по секциям">
    <div class="section-nav-track">
      <button
        v-for="(section, i) in sections"
        :key="section.id"
        class="section-nav-dot"
        :class="{ active: activeIndex === i }"
        :aria-label="section.label"
        @click="scrollTo(section.id)"
      >
        <span class="dot-indicator" />
        <Transition name="dot-label">
          <span v-if="activeIndex === i" class="dot-label">{{ section.label }}</span>
        </Transition>
      </button>
    </div>
  </nav>
</template>

<script setup lang="ts">
interface SectionDef {
  id: string
  label: string
}

const props = defineProps<{
  sections: SectionDef[]
}>()

const activeIndex = ref(0)
let observer: IntersectionObserver | null = null

function scrollTo(id: string) {
  const el = document.getElementById(id)
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

onMounted(() => {
  observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          const idx = props.sections.findIndex(s => s.id === entry.target.id)
          if (idx >= 0) activeIndex.value = idx
        }
      }
    },
    { rootMargin: '-30% 0px -60% 0px', threshold: 0 }
  )

  for (const section of props.sections) {
    const el = document.getElementById(section.id)
    if (el) observer.observe(el)
  }
})

onUnmounted(() => {
  observer?.disconnect()
})
</script>

<style scoped>
.section-nav {
  position: fixed;
  right: 24px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 40;
  display: flex;
  flex-direction: column;
}

.section-nav-track {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.section-nav-dot {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  flex-direction: row-reverse;
}

.dot-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-border);
  transition: all var(--transition-smooth);
  flex-shrink: 0;
}

.section-nav-dot.active .dot-indicator {
  background: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(139, 126, 200, 0.2);
  width: 10px;
  height: 10px;
}

.section-nav-dot:hover .dot-indicator {
  background: var(--color-primary-dark);
}

.dot-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--color-primary);
  white-space: nowrap;
  background: var(--color-surface);
  padding: 4px 10px;
  border-radius: var(--radius-full);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--color-border-light);
}

.dot-label-enter-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.dot-label-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.dot-label-enter-from,
.dot-label-leave-to {
  opacity: 0;
  transform: translateX(8px);
}

@media (max-width: 1024px) {
  .section-nav {
    display: none;
  }
}
</style>

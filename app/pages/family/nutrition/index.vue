<template>
  <div class="nutr-page">
    <!-- Hero -->
    <div class="nutr-hero">
      <div>
        <h1 class="nutr-hero-title">Питание</h1>
        <p class="nutr-hero-sub">{{ mock.children[0].first_name }} · {{ mock.feedingToday.length }} кормлений сегодня</p>
      </div>
      <div class="nutr-hero-stat">
        <Icon name="lucide:flame" size="18" style="color: var(--color-warning)" />
        <span class="nutr-hero-streak">{{ mock.streaks.feeding.current }} дн</span>
      </div>
    </div>

    <!-- Today's feedings -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:list" size="16" /> Сегодня</h2>
      </div>
      <div class="nutr-list">
        <div v-for="f in mock.feedingToday" :key="f.id" class="nutr-row">
          <div class="nutr-icon" :class="`nutr-icon--${f.type}`">
            <span>{{ typeEmoji(f.type) }}</span>
          </div>
          <div class="nutr-info">
            <span class="nutr-name">{{ typeLabel(f.type) }}</span>
            <span class="nutr-meta">
              <template v-if="f.duration">{{ f.duration }} мин · {{ f.side }}</template>
              <template v-if="f.food">{{ f.food }} · {{ f.amount }}</template>
            </span>
          </div>
          <span class="nutr-time">{{ f.time }}</span>
        </div>
      </div>
    </div>

    <!-- Food intro -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:apple" size="16" /> Введённые продукты</h2>
      </div>
      <div class="food-tags">
        <span class="food-tag">Кабачок</span>
        <span class="food-tag">Брокколи</span>
        <span class="food-tag">Тыква</span>
        <span class="food-tag">Яблоко</span>
        <span class="food-tag">Рис</span>
        <span class="food-tag food-tag--alert">Яйцо <Icon name="lucide:alert-triangle" size="11" /></span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()

function typeEmoji(t: string) {
  const m: Record<string, string> = { breast: '🤱', bottle: '🍼', formula: '🥛', solid: '🥣' }
  return m[t] || '🍽️'
}
function typeLabel(t: string) {
  const m: Record<string, string> = { breast: 'Грудь', bottle: 'Бутылка', formula: 'Смесь', solid: 'Прикорм' }
  return m[t] || t
}
</script>

<style scoped>
.nutr-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.nutr-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(242,196,160,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(242,196,160,0.12); border-radius: 16px; padding: 24px 28px;
}
.nutr-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.nutr-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.nutr-hero-stat { display: flex; align-items: center; gap: 6px; }
.nutr-hero-streak { font-size: 1.1rem; font-weight: 700; font-family: var(--font-mono); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.nutr-list { display: flex; flex-direction: column; gap: 4px; }
.nutr-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.nutr-row:hover { background: rgba(242,196,160,0.04); }

.nutr-icon { width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 1.1rem; }
.nutr-icon--breast { background: rgba(232,160,191,0.1); }
.nutr-icon--solid { background: rgba(242,196,160,0.1); }
.nutr-icon--bottle, .nutr-icon--formula { background: rgba(168,200,232,0.1); }

.nutr-info { flex: 1; min-width: 0; }
.nutr-name { display: block; font-size: 0.85rem; font-weight: 500; }
.nutr-meta { display: block; font-size: 0.72rem; color: var(--color-text-muted); margin-top: 1px; }
.nutr-time { font-size: 0.78rem; font-family: var(--font-mono); color: var(--color-text-secondary); }

.food-tags { display: flex; gap: 8px; flex-wrap: wrap; }
.food-tag {
  padding: 6px 14px; border-radius: 20px; font-size: 0.78rem; font-weight: 500;
  background: rgba(124,184,212,0.08); color: var(--color-success);
  display: flex; align-items: center; gap: 4px;
}
.food-tag--alert { background: rgba(212,114,124,0.08); color: var(--color-danger); }
</style>

<template>
  <div class="ref-page">
    <!-- Hero -->
    <div class="ref-hero">
      <div>
        <h1 class="ref-hero-title">Реферальная программа</h1>
        <p class="ref-hero-sub">Приглашайте друзей — получайте бонусы</p>
      </div>
      <div class="tier-chip" :class="mock.referral.tier.toLowerCase()">{{ mock.referral.tier }}</div>
    </div>

    <!-- Stats strip -->
    <div class="stats-strip">
      <div class="stat-item">
        <span class="stat-val">{{ mock.referral.invited }}</span>
        <span class="stat-lbl">Приглашено</span>
      </div>
      <div class="stat-item">
        <span class="stat-val">{{ mock.referral.registered }}</span>
        <span class="stat-lbl">Зареистрировались</span>
      </div>
      <div class="stat-item">
        <span class="stat-val">{{ mock.referral.bonus }}</span>
        <span class="stat-lbl">Заработано</span>
      </div>
      <div class="stat-item">
        <span class="stat-val">{{ mock.referral.points }}</span>
        <span class="stat-lbl">Баллов</span>
      </div>
    </div>

    <!-- Referral Code Card -->
    <div class="code-card">
      <div class="code-card-inner">
        <span class="code-label">Ваш реферальный код</span>
        <div class="code-row">
          <span class="code-value">{{ mock.referral.code }}</span>
          <button class="btn-icon" @click="copyCode">
            <Icon :name="copied ? 'lucide:check' : 'lucide:copy'" size="16" />
          </button>
        </div>
      </div>
      <div class="share-row">
        <button class="share-btn wa" @click="shareWhatsApp">
          <Icon name="lucide:message-circle" size="16" /> WhatsApp
        </button>
        <button class="share-btn link" @click="copyLink">
          <Icon name="lucide:link" size="16" /> Ссылка
        </button>
      </div>
    </div>

    <!-- Loyalty -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:gem" size="16" /> Баланс лояльности</h2>
      </div>
      <div class="loyalty-row">
        <div>
          <span class="loyalty-balance">{{ mock.referral.bonus }}</span>
          <span class="loyalty-sub">Доступно</span>
        </div>
        <div class="loyalty-progress">
          <div class="tier-bar">
            <div class="tier-bar-fill" :style="{ width: `${Math.min(100, mock.referral.points / 50)}%` }" />
          </div>
          <span class="tier-text">{{ mock.referral.points }}/5000 до Золота</span>
        </div>
      </div>
    </div>

    <!-- History -->
    <div class="card">
      <div class="card-header">
        <h2 class="card-title"><Icon name="lucide:clock" size="16" /> История бонусов</h2>
      </div>
      <div class="hist-list">
        <div v-for="h in bonusHistory" :key="h.id" class="hist-row">
          <div class="hist-icon" :class="h.type">
            <Icon :name="h.type === 'earn' ? 'lucide:plus' : 'lucide:minus'" size="14" />
          </div>
          <div class="hist-info">
            <span class="hist-desc">{{ h.description }}</span>
            <span class="hist-date">{{ h.date }}</span>
          </div>
          <span class="hist-amount" :class="h.type">{{ h.type === 'earn' ? '+' : '-' }}{{ h.amount }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'app' })

const mock = useMockData()
const copied = ref(false)

const bonusHistory = [
  { id: 1, type: 'earn', description: 'Регистрация Камилы Б.', date: '12 мая', amount: '5 000 ₸' },
  { id: 2, type: 'earn', description: 'Регистрация Даны Н.', date: '8 мая', amount: '5 000 ₸' },
  { id: 3, type: 'earn', description: 'Регистрация Айгерим К.', date: '3 мая', amount: '5 000 ₸' },
  { id: 4, type: 'earn', description: 'Бонус за активность', date: '1 мая', amount: '2 000 ₸' },
]

function copyCode() {
  navigator.clipboard.writeText(mock.referral.code)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}

function copyLink() {
  navigator.clipboard.writeText(`${window.location.origin}/auth/invite/${mock.referral.code}`)
}

function shareWhatsApp() {
  const url = `${window.location.origin}/auth/invite/${mock.referral.code}`
  window.open(`https://wa.me/?text=${encodeURIComponent(`Присоединяйтесь к Family Care OS! ${url}`)}`, '_blank')
}
</script>

<style scoped>
.ref-page { max-width: 640px; margin: 0 auto; display: flex; flex-direction: column; gap: 18px; }

.ref-hero {
  display: flex; align-items: center; justify-content: space-between;
  background: linear-gradient(135deg, rgba(139,126,200,0.08), rgba(232,160,191,0.06));
  border: 1px solid rgba(139,126,200,0.12); border-radius: 16px; padding: 24px 28px;
}
.ref-hero-title { font-family: var(--font-display); font-size: 1.4rem; font-weight: 700; }
.ref-hero-sub { font-size: 0.82rem; color: var(--color-text-muted); margin-top: 4px; }
.tier-chip { padding: 6px 14px; border-radius: 20px; font-size: 0.72rem; font-weight: 700; }
.tier-chip.серебро { background: rgba(192,192,192,0.15); color: #888; }
.tier-chip.золото { background: rgba(255,215,0,0.15); color: #B8860B; }
.tier-chip.бронза { background: rgba(205,127,50,0.15); color: #CD7F32; }

.stats-strip { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
@media (max-width: 500px) { .stats-strip { grid-template-columns: repeat(2, 1fr); } }
.stat-item { text-align: center; background: white; border: 1px solid var(--color-border-light); border-radius: 12px; padding: 14px 8px; }
.stat-val { display: block; font-size: 1.1rem; font-weight: 700; font-family: var(--font-mono); }
.stat-lbl { font-size: 0.68rem; color: var(--color-text-muted); }

.code-card {
  background: linear-gradient(135deg, rgba(139,126,200,0.12), rgba(232,160,191,0.08));
  border: 1px solid rgba(139,126,200,0.18); border-radius: 16px; padding: 24px;
}
.code-label { font-size: 0.78rem; color: var(--color-text-secondary); font-weight: 500; }
.code-row { display: flex; align-items: center; gap: 10px; margin-top: 8px; }
.code-value { font-size: 1.6rem; font-weight: 700; font-family: var(--font-mono); letter-spacing: 0.08em; color: var(--color-primary); }
.btn-icon { width: 36px; height: 36px; border-radius: 10px; border: 1px solid var(--color-border-light); background: white; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--color-text-secondary); transition: all 0.15s; }
.btn-icon:hover { background: rgba(139,126,200,0.06); }
.share-row { display: flex; gap: 8px; margin-top: 18px; }
.share-btn { display: flex; align-items: center; gap: 6px; padding: 10px 18px; border: none; border-radius: 10px; font-size: 0.82rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); transition: all 0.15s; }
.share-btn.wa { background: #25D366; color: white; }
.share-btn.wa:hover { background: #20bd5a; }
.share-btn.link { background: white; border: 1px solid var(--color-border-light); color: var(--color-text-primary); }
.share-btn.link:hover { background: rgba(139,126,200,0.04); }

.card { background: white; border: 1px solid var(--color-border-light); border-radius: 14px; padding: 20px; }
.card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.card-title { font-size: 0.9rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

.loyalty-row { display: flex; align-items: center; justify-content: space-between; gap: 20px; }
.loyalty-balance { font-size: 1.4rem; font-weight: 700; font-family: var(--font-mono); display: block; }
.loyalty-sub { font-size: 0.7rem; color: var(--color-text-muted); }
.loyalty-progress { flex: 1; max-width: 220px; }
.tier-bar { height: 6px; border-radius: 3px; background: var(--color-border-light); overflow: hidden; }
.tier-bar-fill { height: 100%; border-radius: 3px; background: linear-gradient(90deg, var(--color-primary), var(--color-accent-rose)); transition: width 0.4s; }
.tier-text { font-size: 0.65rem; color: var(--color-text-muted); margin-top: 4px; display: block; text-align: right; }

.hist-list { display: flex; flex-direction: column; gap: 4px; }
.hist-row { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 10px; transition: background 0.15s; }
.hist-row:hover { background: rgba(139,126,200,0.04); }
.hist-icon { width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.hist-icon.earn { background: rgba(124,184,212,0.12); color: var(--color-success); }
.hist-icon.spend { background: rgba(212,114,124,0.12); color: var(--color-danger); }
.hist-info { flex: 1; }
.hist-desc { font-size: 0.82rem; font-weight: 500; display: block; }
.hist-date { font-size: 0.65rem; color: var(--color-text-muted); }
.hist-amount { font-weight: 700; font-family: var(--font-mono); font-size: 0.82rem; }
.hist-amount.earn { color: var(--color-success); }
.hist-amount.spend { color: var(--color-danger); }
</style>

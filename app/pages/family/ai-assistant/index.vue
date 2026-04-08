<template>
  <div class="ai-page">
    <header class="chat-header">
      <div class="header-left">
        <NuxtLink to="/family" class="back-btn">
          <Icon name="lucide:chevron-left" size="18" />
        </NuxtLink>
        <div>
          <h1 class="header-title">Care AI</h1>
          <p class="header-sub">Ваш помощник</p>
        </div>
      </div>
    </header>

    <!-- Disclaimer -->
    <div class="disclaimer">
      <Icon name="lucide:info" size="14" />
      <span>AI-помощник не заменяет врача. Не используйте для диагностики и лечения.</span>
    </div>

    <!-- Messages -->
    <div ref="messagesRef" class="messages-container">
      <div v-if="!messages.length" class="welcome">
        <Icon name="lucide:bot" size="40" class="welcome-icon" />
        <h2>Здравствуйте!</h2>
        <p>Задайте вопрос о здоровье ребёнка, питании, сне или развитии.</p>
        <div class="quick-prompts">
          <button v-for="q in quickPrompts" :key="q" class="prompt-btn" @click="sendMessage(q)">{{ q }}</button>
        </div>
      </div>

      <div v-for="msg in messages" :key="msg.id" class="message" :class="msg.role">
        <div class="message-bubble">
          <div class="message-text">{{ msg.content }}</div>
          <span class="message-time">{{ formatTime(msg.created_at) }}</span>
        </div>
        <div v-if="msg.role === 'assistant'" class="feedback">
          <button class="fb-btn" @click="feedback(msg.id, 'helpful')">
            <Icon name="lucide:thumbs-up" size="14" />
          </button>
          <button class="fb-btn" @click="feedback(msg.id, 'not_helpful')">
            <Icon name="lucide:thumbs-down" size="14" />
          </button>
        </div>
      </div>

      <div v-if="loading" class="message assistant">
        <div class="message-bubble typing">
          <span class="dot" /><span class="dot" /><span class="dot" />
        </div>
      </div>
    </div>

    <!-- Input -->
    <div class="input-area">
      <textarea
        v-model="input"
        class="chat-input"
        placeholder="Введите вопрос..."
        rows="1"
        @keydown.enter.exact.prevent="sendMessage()"
      />
      <button class="send-btn" :disabled="!input.trim() || loading" @click="sendMessage()">
        <Icon name="lucide:send" size="18" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import dayjs from 'dayjs'

definePageMeta({ layout: 'app' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const authStore = useAuthStore()

interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  created_at: string
}

const messages = ref<ChatMessage[]>([])
const input = ref('')
const loading = ref(false)
const messagesRef = ref<HTMLElement>()
const conversationId = ref('')

const quickPrompts = [
  'Нормы сна для 4-месячного ребёнка',
  'Когда начинать прикорм?',
  'Признаки колик у новорождённого',
  'Как увеличить лактацию?',
]

function formatTime(dt: string) { return dayjs(dt).format('HH:mm') }

function scrollToBottom() {
  nextTick(() => {
    if (messagesRef.value) {
      messagesRef.value.scrollTop = messagesRef.value.scrollHeight
    }
  })
}

async function sendMessage(text?: string) {
  const msg = text || input.value.trim()
  if (!msg || !user.value) return

  input.value = ''

  // Create conversation if needed
  if (!conversationId.value) {
    const { data } = await supabase.from('ai_conversations').insert({
      user_id: user.value.id,
      title: msg.slice(0, 60),
    }).select().single()
    if (data) conversationId.value = data.id
  }

  // Add user message
  const userMsg: ChatMessage = {
    id: crypto.randomUUID(),
    role: 'user',
    content: msg,
    created_at: new Date().toISOString(),
  }
  messages.value.push(userMsg)
  scrollToBottom()

  // Save user message
  await supabase.from('ai_messages').insert({
    conversation_id: conversationId.value,
    role: 'user',
    content: msg,
  })

  // Get AI response
  loading.value = true
  try {
    // Build child context from store
    const activeChild = authStore.children?.[0]
    const childContext = activeChild
      ? {
          name: activeChild.name,
          age_months: activeChild.dob
            ? Math.floor((Date.now() - new Date(activeChild.dob).getTime()) / (30.44 * 24 * 60 * 60 * 1000))
            : undefined,
          gender: activeChild.gender,
        }
      : undefined

    let aiContent: string
    try {
      const data = await $fetch('/api/ai/chat', {
        method: 'POST',
        body: { message: msg, child_context: childContext },
      })
      aiContent = data?.response || 'Не удалось получить ответ.'
    }
    catch {
      aiContent = 'Извините, произошла ошибка. Попробуйте позже.'
    }

    const aiMsg: ChatMessage = {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: aiContent,
      created_at: new Date().toISOString(),
    }
    messages.value.push(aiMsg)

    // Save AI response
    await supabase.from('ai_messages').insert({
      conversation_id: conversationId.value,
      role: 'assistant',
      content: aiContent,
    })
  }
  finally {
    loading.value = false
    scrollToBottom()
  }
}

async function feedback(messageId: string, type: string) {
  await supabase.from('ai_feedback').insert({
    message_id: messageId,
    user_id: user.value?.id,
    type,
  })
}

onMounted(async () => {
  // Load recent conversations
  if (!user.value) return
  const { data } = await supabase
    .from('ai_conversations')
    .select('id')
    .eq('user_id', user.value.id)
    .order('created_at', { ascending: false })
    .limit(1)

  if (data?.[0]) {
    conversationId.value = data[0].id
    const { data: msgs } = await supabase
      .from('ai_messages')
      .select('*')
      .eq('conversation_id', conversationId.value)
      .order('created_at')
      .limit(50)

    messages.value = (msgs as ChatMessage[]) || []
    scrollToBottom()
  }
})
</script>

<style scoped>
.ai-page { display: flex; flex-direction: column; height: calc(100vh - 64px); max-width: 700px; margin: 0 auto; }

.chat-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid var(--color-border-light); flex-shrink: 0; }
.header-left { display: flex; align-items: center; gap: 10px; }
.back-btn { color: var(--color-text-secondary); }
.header-title { font-family: var(--font-display); font-size: 1rem; font-weight: 700; }
.header-sub { font-size: 0.75rem; color: var(--color-text-muted); }

.disclaimer { display: flex; align-items: center; gap: 6px; padding: 8px 16px; background: rgba(233, 196, 106, 0.1); font-size: 0.75rem; color: var(--color-warning); flex-shrink: 0; }

.messages-container { flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 12px; }

.welcome { text-align: center; padding: 40px 16px; }
.welcome-icon { color: var(--color-primary); margin-bottom: 12px; }
.welcome h2 { font-family: var(--font-display); font-size: 1.2rem; margin-bottom: 6px; }
.welcome p { font-size: 0.9rem; color: var(--color-text-secondary); margin-bottom: 20px; }
.quick-prompts { display: flex; flex-direction: column; gap: 8px; max-width: 360px; margin: 0 auto; }
.prompt-btn { padding: 10px 16px; background: var(--color-surface); border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.85rem; cursor: pointer; text-align: left; font-family: var(--font-body); transition: border-color var(--transition-fast); }
.prompt-btn:hover { border-color: var(--color-primary); }

.message { display: flex; flex-direction: column; max-width: 85%; }
.message.user { align-self: flex-end; align-items: flex-end; }
.message.assistant { align-self: flex-start; align-items: flex-start; }

.message-bubble { padding: 10px 14px; border-radius: 14px; font-size: 0.9rem; line-height: 1.5; }
.message.user .message-bubble { background: var(--color-primary); color: white; border-bottom-right-radius: 4px; }
.message.assistant .message-bubble { background: var(--color-surface); border: 1px solid var(--color-border-light); border-bottom-left-radius: 4px; }
.message-time { font-size: 0.65rem; color: var(--color-text-muted); margin-top: 4px; display: block; }
.message.user .message-time { color: rgba(255,255,255,0.6); }

.feedback { display: flex; gap: 4px; margin-top: 4px; }
.fb-btn { padding: 4px; border: none; background: none; color: var(--color-text-muted); cursor: pointer; border-radius: 4px; }
.fb-btn:hover { background: var(--color-surface); color: var(--color-primary); }

.typing { display: flex; gap: 4px; padding: 14px 18px; }
.dot { width: 6px; height: 6px; border-radius: 50%; background: var(--color-text-muted); animation: blink 1.4s infinite; }
.dot:nth-child(2) { animation-delay: 0.2s; }
.dot:nth-child(3) { animation-delay: 0.4s; }
@keyframes blink { 0%, 60%, 100% { opacity: 0.3; } 30% { opacity: 1; } }

.input-area { display: flex; align-items: flex-end; gap: 8px; padding: 12px 16px; border-top: 1px solid var(--color-border-light); flex-shrink: 0; }
.chat-input { flex: 1; padding: 10px 14px; border: 1px solid var(--color-border); border-radius: 20px; font-size: 0.9rem; font-family: var(--font-body); resize: none; outline: none; max-height: 100px; }
.chat-input:focus { border-color: var(--color-primary); }
.send-btn { width: 40px; height: 40px; border-radius: 50%; border: none; background: var(--gradient-cta); color: white; cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.send-btn:disabled { opacity: 0.5; cursor: not-allowed; }
</style>

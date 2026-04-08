<template>
  <div class="video-page">
    <!-- Pre-call -->
    <div v-if="!inCall && !callEnded" class="pre-call">
      <div class="pre-call-card">
        <Icon name="lucide:video" size="40" class="video-icon" />
        <h1>Видеоконсультация</h1>
        <div v-if="appointment" class="appointment-info">
          <p class="doctor-name">{{ appointment.doctor_name }}</p>
          <p class="appt-time">{{ formatDateTime(appointment.date) }}</p>
        </div>

        <div class="device-check">
          <div class="device-item" :class="{ ok: cameraOk }">
            <Icon :name="cameraOk ? 'lucide:camera' : 'lucide:camera-off'" size="18" />
            <span>{{ cameraOk ? 'Камера готова' : 'Камера недоступна' }}</span>
          </div>
          <div class="device-item" :class="{ ok: micOk }">
            <Icon :name="micOk ? 'lucide:mic' : 'lucide:mic-off'" size="18" />
            <span>{{ micOk ? 'Микрофон готов' : 'Микрофон недоступен' }}</span>
          </div>
        </div>

        <button class="btn-join" @click="joinCall">
          <Icon name="lucide:video" size="18" /> Присоединиться
        </button>
      </div>
    </div>

    <!-- In-call -->
    <div v-if="inCall" class="call-room">
      <div class="video-grid">
        <div class="video-remote">
          <div class="video-placeholder">
            <Icon name="lucide:user" size="48" />
            <p>{{ appointment?.doctor_name || 'Врач' }}</p>
          </div>
        </div>
        <div class="video-local">
          <div class="video-placeholder small">
            <Icon name="lucide:user" size="24" />
          </div>
        </div>
      </div>

      <div class="call-controls">
        <button class="ctrl-btn" :class="{ off: !micEnabled }" @click="micEnabled = !micEnabled">
          <Icon :name="micEnabled ? 'lucide:mic' : 'lucide:mic-off'" size="20" />
        </button>
        <button class="ctrl-btn" :class="{ off: !cameraEnabled }" @click="cameraEnabled = !cameraEnabled">
          <Icon :name="cameraEnabled ? 'lucide:camera' : 'lucide:camera-off'" size="20" />
        </button>
        <button class="ctrl-btn end" @click="endCall">
          <Icon name="lucide:phone-off" size="20" />
        </button>
      </div>

      <div class="call-timer">{{ callDuration }}</div>
    </div>

    <!-- Post-call -->
    <div v-if="callEnded" class="post-call">
      <div class="post-call-card">
        <Icon name="lucide:check-circle" size="40" class="done-icon" />
        <h2>Консультация завершена</h2>
        <p>Длительность: {{ callDuration }}</p>

        <div class="rating-section">
          <h3>Оцените консультацию</h3>
          <div class="stars">
            <button
              v-for="s in 5"
              :key="s"
              class="star-btn"
              :class="{ filled: rating >= s }"
              @click="rating = s"
            >★</button>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Комментарий (необязательно)</label>
          <textarea v-model="reviewComment" rows="2" class="form-textarea" placeholder="Ваши впечатления..." />
        </div>

        <div class="post-actions">
          <button class="btn-submit" @click="submitReview">Отправить отзыв</button>
          <NuxtLink to="/family/appointments" class="btn-back">К записям</NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { formatDateTime } from '~/utils/formatters'

definePageMeta({ layout: 'app' })

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const appointmentId = route.params.id as string
const appointment = ref<Record<string, unknown> | null>(null)
const inCall = ref(false)
const callEnded = ref(false)
const micEnabled = ref(true)
const cameraEnabled = ref(true)
const cameraOk = ref(false)
const micOk = ref(false)
const rating = ref(0)
const reviewComment = ref('')
const callSeconds = ref(0)
let timer: ReturnType<typeof setInterval> | null = null

const callDuration = computed(() => {
  const m = Math.floor(callSeconds.value / 60)
  const s = callSeconds.value % 60
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
})

async function checkDevices() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true })
    cameraOk.value = true
    micOk.value = true
    stream.getTracks().forEach(t => t.stop())
  }
  catch {
    // Try audio only
    try {
      const audio = await navigator.mediaDevices.getUserMedia({ audio: true })
      micOk.value = true
      audio.getTracks().forEach(t => t.stop())
    }
    catch { /* no devices */ }
  }
}

function joinCall() {
  inCall.value = true
  callSeconds.value = 0
  timer = setInterval(() => { callSeconds.value++ }, 1000)
}

async function endCall() {
  if (timer) clearInterval(timer)
  inCall.value = false
  callEnded.value = true

  // Mark appointment as completed
  if (appointmentId) {
    await supabase.from('appointments')
      .update({ status: 'completed' })
      .eq('id', appointmentId)
  }
}

async function submitReview() {
  if (!user.value || !appointmentId) return

  if (rating.value > 0) {
    const { data: appt } = await supabase.from('appointments').select('family_id').eq('id', appointmentId).single()
    await supabase.from('visit_ratings').insert({
      appointment_id: appointmentId,
      family_id: appt?.family_id,
      rating: rating.value,
      comment: reviewComment.value || null,
    })
  }

  navigateTo('/family/appointments')
}

onMounted(async () => {
  checkDevices()

  if (appointmentId) {
    const { data } = await supabase
      .from('appointments')
      .select('*, doctors(user_id, specialty, users(first_name, last_name))')
      .eq('id', appointmentId)
      .single()

    if (data) {
      const doc = (data as Record<string, unknown>).doctors as Record<string, unknown> | null
      const docUser = doc?.users as Record<string, unknown> | null
      appointment.value = {
        ...data,
        doctor_name: docUser ? `${docUser.first_name || ''} ${docUser.last_name || ''}`.trim() : 'Врач',
      }
    }
  }
})

onUnmounted(() => { if (timer) clearInterval(timer) })
</script>

<style scoped>
.video-page { height: calc(100vh - 64px); display: flex; align-items: center; justify-content: center; }

/* Pre-call */
.pre-call-card { text-align: center; padding: 40px 32px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); max-width: 420px; }
.video-icon { color: var(--color-primary); margin-bottom: 16px; }
.pre-call-card h1 { font-family: var(--font-display); font-size: 1.25rem; margin-bottom: 12px; }
.appointment-info { margin-bottom: 20px; }
.doctor-name { font-weight: 600; font-size: 1rem; }
.appt-time { font-size: 0.85rem; color: var(--color-text-secondary); }

.device-check { display: flex; flex-direction: column; gap: 8px; margin-bottom: 24px; }
.device-item { display: flex; align-items: center; gap: 8px; padding: 8px 14px; border-radius: 8px; background: rgba(231, 111, 81, 0.08); color: var(--color-danger); font-size: 0.85rem; }
.device-item.ok { background: rgba(124, 184, 212, 0.08); color: var(--color-success); }

.btn-join { display: flex; align-items: center; gap: 8px; margin: 0 auto; padding: 12px 28px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-size: 1rem; font-weight: 600; cursor: pointer; font-family: var(--font-body); }

/* In-call */
.call-room { position: relative; width: 100%; height: 100%; background: #111; display: flex; flex-direction: column; }
.video-grid { flex: 1; position: relative; }
.video-remote { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; }
.video-placeholder { display: flex; flex-direction: column; align-items: center; gap: 8px; color: rgba(255,255,255,0.4); }
.video-placeholder p { font-size: 0.85rem; }
.video-local { position: absolute; bottom: 80px; right: 16px; width: 120px; height: 90px; border-radius: 10px; background: #222; display: flex; align-items: center; justify-content: center; border: 2px solid rgba(255,255,255,0.15); }
.video-placeholder.small { color: rgba(255,255,255,0.3); }

.call-controls { position: absolute; bottom: 20px; left: 50%; transform: translateX(-50%); display: flex; gap: 16px; }
.ctrl-btn { width: 50px; height: 50px; border-radius: 50%; border: none; background: rgba(255,255,255,0.15); color: white; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.ctrl-btn.off { background: rgba(231, 111, 81, 0.3); }
.ctrl-btn.end { background: var(--color-danger); }

.call-timer { position: absolute; top: 16px; left: 50%; transform: translateX(-50%); color: white; font-size: 0.9rem; font-family: var(--font-mono); background: rgba(0,0,0,0.5); padding: 4px 14px; border-radius: 20px; }

/* Post-call */
.post-call { width: 100%; display: flex; justify-content: center; }
.post-call-card { text-align: center; padding: 40px 32px; background: var(--color-surface); border: 1px solid var(--color-border-light); border-radius: var(--radius-md); max-width: 420px; width: 100%; }
.done-icon { color: var(--color-success); margin-bottom: 12px; }
.post-call-card h2 { font-family: var(--font-display); font-size: 1.2rem; margin-bottom: 6px; }
.post-call-card > p { font-size: 0.9rem; color: var(--color-text-secondary); margin-bottom: 20px; }

.rating-section { margin-bottom: 16px; }
.rating-section h3 { font-size: 0.9rem; font-weight: 600; margin-bottom: 8px; }
.stars { display: flex; gap: 4px; justify-content: center; }
.star-btn { font-size: 1.5rem; border: none; background: none; cursor: pointer; color: var(--color-border); }
.star-btn.filled { color: #F59E0B; }

.form-group { margin-bottom: 16px; text-align: left; }
.form-label { font-size: 0.85rem; font-weight: 600; display: block; margin-bottom: 6px; }
.form-textarea { width: 100%; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-sm); font-size: 0.9rem; font-family: var(--font-body); resize: none; outline: none; box-sizing: border-box; }

.post-actions { display: flex; flex-direction: column; gap: 8px; }
.btn-submit { padding: 12px; background: var(--gradient-cta); color: white; border: none; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer; font-family: var(--font-body); }
.btn-back { padding: 10px; background: none; border: 1px solid var(--color-border); border-radius: var(--radius-sm); text-decoration: none; color: var(--color-text-primary); text-align: center; }
</style>

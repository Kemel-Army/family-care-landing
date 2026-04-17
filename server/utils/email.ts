// Shared email service using Resend
import { Resend } from 'resend'

let _resend: Resend | null = null

function getResend(): Resend {
  if (!_resend) {
    const apiKey = process.env.RESEND_API_KEY
    if (!apiKey) throw new Error('RESEND_API_KEY not configured')
    _resend = new Resend(apiKey)
  }
  return _resend
}

interface EmailOptions {
  to: string | string[]
  subject: string
  html: string
  text?: string
}

const FROM_EMAIL = process.env.EMAIL_FROM || 'UMAI Health <noreply@umai-health.kz>'

export async function sendEmail(opts: EmailOptions) {
  const resend = getResend()
  const { data, error } = await resend.emails.send({
    from: FROM_EMAIL,
    to: Array.isArray(opts.to) ? opts.to : [opts.to],
    subject: opts.subject,
    html: opts.html,
    text: opts.text,
  })
  if (error) throw new Error(`Email send failed: ${error.message}`)
  return data
}

// ─── Email Templates ───

export function appointmentConfirmationEmail(opts: {
  patientName: string
  doctorName: string
  date: string
  time: string
}) {
  return {
    subject: `Запись подтверждена — ${opts.date} в ${opts.time}`,
    html: `
      <div style="font-family: Inter, sans-serif; max-width: 500px; margin: auto;">
        <div style="background: #6B4EAA; color: white; padding: 24px; border-radius: 12px 12px 0 0; text-align: center;">
          <h1 style="margin: 0; font-size: 20px;">UMAI Health</h1>
        </div>
        <div style="padding: 24px; background: #f9fafb; border-radius: 0 0 12px 12px;">
          <p>Здравствуйте, <strong>${opts.patientName}</strong>!</p>
          <p>Ваша запись подтверждена:</p>
          <div style="background: white; border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; margin: 16px 0;">
            <p style="margin: 4px 0;"><strong>Врач:</strong> ${opts.doctorName}</p>
            <p style="margin: 4px 0;"><strong>Дата:</strong> ${opts.date}</p>
            <p style="margin: 4px 0;"><strong>Время:</strong> ${opts.time}</p>
          </div>
          <p style="color: #6b7280; font-size: 14px;">Если вам нужно перенести или отменить запись, зайдите в приложение.</p>
        </div>
      </div>
    `,
    text: `Здравствуйте, ${opts.patientName}! Ваша запись подтверждена: ${opts.doctorName}, ${opts.date} в ${opts.time}.`,
  }
}

export function reminderEmail(opts: {
  patientName: string
  eventTitle: string
  date: string
  type: 'appointment' | 'vaccination' | 'screening'
}) {
  const typeLabels = { appointment: 'Приём', vaccination: 'Вакцинация', screening: 'Скрининг' }
  return {
    subject: `Напоминание: ${typeLabels[opts.type]} — ${opts.date}`,
    html: `
      <div style="font-family: Inter, sans-serif; max-width: 500px; margin: auto;">
        <div style="background: #6B4EAA; color: white; padding: 24px; border-radius: 12px 12px 0 0; text-align: center;">
          <h1 style="margin: 0; font-size: 20px;">UMAI Health</h1>
        </div>
        <div style="padding: 24px; background: #f9fafb; border-radius: 0 0 12px 12px;">
          <p>Здравствуйте, <strong>${opts.patientName}</strong>!</p>
          <p>Напоминаем о предстоящем событии:</p>
          <div style="background: white; border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; margin: 16px 0;">
            <p style="margin: 4px 0;"><strong>${typeLabels[opts.type]}:</strong> ${opts.eventTitle}</p>
            <p style="margin: 4px 0;"><strong>Дата:</strong> ${opts.date}</p>
          </div>
        </div>
      </div>
    `,
    text: `Напоминание: ${opts.eventTitle} — ${opts.date}`,
  }
}

export function welcomeEmail(opts: { name: string; clinicName: string }) {
  return {
    subject: `Добро пожаловать в ${opts.clinicName}!`,
    html: `
      <div style="font-family: Inter, sans-serif; max-width: 500px; margin: auto;">
        <div style="background: #6B4EAA; color: white; padding: 24px; border-radius: 12px 12px 0 0; text-align: center;">
          <h1 style="margin: 0; font-size: 20px;">${opts.clinicName}</h1>
        </div>
        <div style="padding: 24px; background: #f9fafb; border-radius: 0 0 12px 12px;">
          <p>Здравствуйте, <strong>${opts.name}</strong>!</p>
          <p>Добро пожаловать в UMAI Health — вашу цифровую платформу заботы о здоровье.</p>
          <p>Что вас ждёт:</p>
          <ul>
            <li>Персональный маршрут наблюдения</li>
            <li>Напоминания о прививках и лекарствах</li>
            <li>Удобная запись к врачу</li>
            <li>AI-помощник для вопросов</li>
          </ul>
          <p>Войдите в приложение, чтобы начать! 🎉</p>
        </div>
      </div>
    `,
    text: `Добро пожаловать, ${opts.name}! Войдите в UMAI Health, чтобы начать пользоваться платформой.`,
  }
}

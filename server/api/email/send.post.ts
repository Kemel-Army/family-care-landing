// POST /api/email/send — send an email (internal use by server/cron)
import { z } from 'zod'
import { serverSupabaseUser } from '#supabase/server'

const schema = z.object({
  template: z.enum(['appointment_confirmation', 'reminder', 'welcome']),
  to: z.string().email(),
  data: z.record(z.string(), z.string()),
})

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user) throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })

  const body = await readValidatedBody(event, schema.parse)

  let emailContent: { subject: string; html: string; text?: string }

  switch (body.template) {
    case 'appointment_confirmation':
      emailContent = appointmentConfirmationEmail({
        patientName: body.data.patientName || '',
        doctorName: body.data.doctorName || '',
        date: body.data.date || '',
        time: body.data.time || '',
      })
      break
    case 'reminder':
      emailContent = reminderEmail({
        patientName: body.data.patientName || '',
        eventTitle: body.data.eventTitle || '',
        date: body.data.date || '',
        type: (body.data.type as 'appointment' | 'vaccination' | 'screening') || 'appointment',
      })
      break
    case 'welcome':
      emailContent = welcomeEmail({
        name: body.data.name || '',
        clinicName: body.data.clinicName || 'UMAI Health',
      })
      break
    default:
      throw createError({ statusCode: 400, statusMessage: 'Unknown template' })
  }

  const result = await sendEmail({
    to: body.to,
    ...emailContent,
  })

  return { success: true, id: result?.id }
})

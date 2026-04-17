import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).max(200),
  organization: z.string().max(200).optional(),
  email: z.string().min(1).max(200),
  phone_or_messenger: z.string().max(200).optional(),
  comment: z.string().max(2000).optional(),
  type: z.enum(['clinic_inquiry', 'demand_family']),
})

const NOTIFY_EMAIL = process.env.CONTACT_NOTIFY_EMAIL || 'info@umai-health.kz'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const parsed = schema.safeParse(body)

  if (!parsed.success) {
    throw createError({ statusCode: 400, message: 'Invalid form data' })
  }

  const data = parsed.data

  const supabaseUrl = process.env.SUPABASE_URL
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !supabaseKey) {
    throw createError({ statusCode: 500, message: 'Server configuration error' })
  }

  try {
    await $fetch(`${supabaseUrl}/rest/v1/contact_requests`, {
      method: 'POST',
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: {
        name: data.name,
        organization: data.organization || null,
        email: data.email,
        phone_or_messenger: data.phone_or_messenger || null,
        comment: data.comment || null,
        type: data.type,
      },
    })
  }
  catch (err) {
    console.error('Failed to store contact request:', err)
    throw createError({ statusCode: 500, message: 'Failed to save request' })
  }

  // Email notification (non-blocking — don't fail the request if email fails)
  const typeLabel = data.type === 'clinic_inquiry' ? 'Клиника' : 'Семья'
  sendEmail({
    to: NOTIFY_EMAIL,
    subject: `Новая заявка: ${typeLabel} — ${data.name}`,
    html: `
      <div style="font-family: Inter, sans-serif; max-width: 520px; margin: auto;">
        <div style="background: #6B4EAA; color: white; padding: 24px; border-radius: 12px 12px 0 0; text-align: center;">
          <h1 style="margin: 0; font-size: 20px;">Новая заявка на UMAI Health</h1>
        </div>
        <div style="padding: 24px; background: #f9fafb; border-radius: 0 0 12px 12px;">
          <div style="background: white; border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; margin: 8px 0;">
            <p style="margin: 4px 0;"><strong>Тип:</strong> ${typeLabel}</p>
            <p style="margin: 4px 0;"><strong>Имя:</strong> ${data.name}</p>
            ${data.organization ? `<p style="margin: 4px 0;"><strong>Организация:</strong> ${data.organization}</p>` : ''}
            <p style="margin: 4px 0;"><strong>Email:</strong> ${data.email}</p>
            ${data.phone_or_messenger ? `<p style="margin: 4px 0;"><strong>Контакт:</strong> ${data.phone_or_messenger}</p>` : ''}
            ${data.comment ? `<p style="margin: 4px 0;"><strong>Сообщение:</strong> ${data.comment}</p>` : ''}
          </div>
        </div>
      </div>
    `,
    text: `Новая заявка (${typeLabel}): ${data.name}, ${data.email}${data.organization ? `, ${data.organization}` : ''}${data.comment ? `. ${data.comment}` : ''}`,
  }).catch((err: unknown) => console.error('Failed to send contact notification email:', err))

  return { success: true }
})

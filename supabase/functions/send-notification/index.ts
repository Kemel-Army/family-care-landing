import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createSupabaseAdmin, jsonResponse, errorResponse, corsHeaders } from '../_shared/supabase.ts'

/**
 * send-notification
 *
 * Multi-channel notification dispatcher.
 * Input: {
 *   user_id,
 *   type,              // e.g. 'dose_reminder', 'appointment_reminder_24h', 'event_due'
 *   title,
 *   body,
 *   channels?: string[], // ['in_app', 'push', 'whatsapp'] — defaults to ['in_app']
 *   data?: object        // extra payload
 * }
 *
 * Respects user consents — skips channels the user hasn't opted into.
 */
serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() })
  }

  try {
    const supabase = createSupabaseAdmin()
    const body = await req.json()

    const { user_id, type, title, body: notifBody, channels, data } = body

    if (!user_id || !type || !title) {
      return errorResponse('Missing required fields: user_id, type, title')
    }

    const requestedChannels: string[] = channels || ['in_app']
    const results: Record<string, string> = {}

    // Fetch user consents
    const { data: consents } = await supabase
      .from('consents')
      .select('type, granted')
      .eq('user_id', user_id)

    const consentMap = new Map<string, boolean>()
    if (consents) {
      for (const c of consents) {
        consentMap.set(c.type, c.granted)
      }
    }

    for (const channel of requestedChannels) {
      // Check consent (in_app always allowed)
      if (channel !== 'in_app') {
        const consentKey = channel === 'push' ? 'push' : channel
        if (!consentMap.get(consentKey)) {
          results[channel] = 'skipped_no_consent'
          continue
        }
      }

      // Create notification record
      const { error: insertError } = await supabase.from('notifications').insert({
        user_id,
        type,
        channel,
        title,
        body: notifBody || null,
        data: data || {},
        status: channel === 'in_app' ? 'delivered' : 'pending',
        sent_at: channel === 'in_app' ? new Date().toISOString() : null,
      })

      if (insertError) {
        results[channel] = `error: ${insertError.message}`
        continue
      }

      // Dispatch to external channels
      if (channel === 'push') {
        const sent = await sendPushNotification(user_id, title, notifBody || '', data)
        results[channel] = sent ? 'sent' : 'failed'
      } else if (channel === 'whatsapp') {
        const sent = await sendWhatsApp(user_id, type, title, notifBody || '', supabase)
        results[channel] = sent ? 'sent' : 'failed'
      } else if (channel === 'sms') {
        results[channel] = 'not_implemented'
      } else if (channel === 'email') {
        const sent = await sendEmail(user_id, title, notifBody || '', supabase)
        results[channel] = sent ? 'sent' : 'failed'
      } else {
        results[channel] = 'delivered'
      }
    }

    return jsonResponse({
      success: true,
      user_id,
      type,
      channels: results,
    })
  } catch (err) {
    return errorResponse(`Internal error: ${(err as Error).message}`, 500)
  }
})

/**
 * Send Firebase Cloud Messaging push notification.
 */
async function sendPushNotification(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, unknown>,
): Promise<boolean> {
  const fcmKey = Deno.env.get('FCM_SERVER_KEY')
  if (!fcmKey) return false

  const supabase = createSupabaseAdmin()

  // Lookup user's active FCM tokens
  const { data: tokens } = await supabase
    .from('push_tokens')
    .select('token')
    .eq('user_id', userId)
    .eq('is_active', true)

  if (!tokens || tokens.length === 0) return false

  let anySuccess = false

  for (const { token } of tokens) {
    try {
      const response = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Authorization': `key=${fcmKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          to: token,
          notification: { title, body },
          data: data || {},
        }),
      })

      if (response.ok) {
        const result = await response.json()
        if (result.success === 1) {
          anySuccess = true
        } else {
          // Token is invalid — deactivate it
          await supabase
            .from('push_tokens')
            .update({ is_active: false, updated_at: new Date().toISOString() })
            .eq('user_id', userId)
            .eq('token', token)
        }
      }
    } catch {
      // Network error — skip this token
    }
  }

  return anySuccess
}

/**
 * Send WhatsApp message via Meta Cloud API.
 */
async function sendWhatsApp(
  userId: string,
  _templateType: string,
  _title: string,
  _body: string,
  supabase: ReturnType<typeof createSupabaseAdmin>,
): Promise<boolean> {
  const token = Deno.env.get('WHATSAPP_TOKEN')
  const phoneNumberId = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')
  if (!token || !phoneNumberId) return false

  // Get user's phone number
  const { data: user } = await supabase
    .from('users')
    .select('phone')
    .eq('id', userId)
    .single()

  if (!user?.phone) return false

  // Format phone for WhatsApp API (remove + prefix)
  const phone = user.phone.replace(/^\+/, '')

  try {
    const response = await fetch(
      `https://graph.facebook.com/v18.0/${phoneNumberId}/messages`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: phone,
          type: 'text',
          text: { body: `${_title}\n\n${_body}` },
        }),
      },
    )

    return response.ok
  } catch {
    return false
  }
}

/**
 * Send email notification via Resend.
 */
async function sendEmail(
  userId: string,
  title: string,
  body: string,
  supabase: ReturnType<typeof createSupabaseAdmin>,
): Promise<boolean> {
  const resendKey = Deno.env.get('RESEND_API_KEY')
  if (!resendKey) return false

  const { data: user } = await supabase
    .from('users')
    .select('email, first_name')
    .eq('id', userId)
    .single()

  if (!user?.email) return false

  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Family Care <noreply@familycare.kz>',
        to: [user.email],
        subject: title,
        html: `
          <div style="font-family:Inter,sans-serif;max-width:600px;margin:0 auto;padding:24px">
            <h2 style="color:#1e293b;margin-bottom:16px">${title}</h2>
            <p style="color:#475569;font-size:16px;line-height:1.6">${body}</p>
            <hr style="border:none;border-top:1px solid #e2e8f0;margin:24px 0">
            <p style="color:#94a3b8;font-size:12px">Family Care OS — ${user.first_name || 'Пользователь'}</p>
          </div>
        `,
      }),
    })

    return response.ok
  } catch {
    return false
  }
}

import { PDFDocument, StandardFonts, rgb } from 'pdf-lib'
import { createClient } from '@supabase/supabase-js'
import { serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  // Require authenticated user
  const user = await serverSupabaseUser(event)
  if (!user) {
    throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })
  }

  const config = useRuntimeConfig()
  const query = getQuery(event)
  const childId = query.child_id as string

  if (!childId || typeof childId !== 'string') {
    throw createError({ statusCode: 400, statusMessage: 'child_id is required' })
  }

  // Validate UUID format
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(childId)) {
    throw createError({ statusCode: 400, statusMessage: 'Invalid child_id format' })
  }

  const supabaseUrl = process.env.SUPABASE_URL || ''
  const supabaseKey = config.supabaseServiceKey

  if (!supabaseUrl || !supabaseKey) {
    throw createError({ statusCode: 500, statusMessage: 'Supabase not configured' })
  }

  const supabase = createClient(supabaseUrl, supabaseKey)

  // Fetch child profile
  const { data: child } = await supabase.from('child_profiles').select('*').eq('id', childId).single()
  if (!child) {
    throw createError({ statusCode: 404, statusMessage: 'Child not found' })
  }

  // Parallel fetches
  const [vaccResult, entriesResult, eventsResult] = await Promise.all([
    supabase.from('vaccinations').select('*').eq('child_id', childId).order('scheduled_date'),
    supabase.from('health_passport_entries').select('*').eq('child_id', childId).order('date', { ascending: false }),
    supabase.from('journey_events')
      .select('title, type, status, due_date, completed_at, journeys!inner(child_id)')
      .eq('journeys.child_id', childId)
      .eq('status', 'completed')
      .order('completed_at', { ascending: false })
      .limit(50),
  ])

  const vaccinations = vaccResult.data || []
  const entries = entriesResult.data || []
  const completedEvents = eventsResult.data || []

  // Build PDF
  const pdf = await PDFDocument.create()
  const font = await pdf.embedFont(StandardFonts.Helvetica)
  const fontBold = await pdf.embedFont(StandardFonts.HelveticaBold)

  const PAGE_W = 595
  const PAGE_H = 842
  const MARGIN = 50
  const LINE_H = 16
  const COL_W = PAGE_W - 2 * MARGIN

  let page = pdf.addPage([PAGE_W, PAGE_H])
  let y = PAGE_H - MARGIN

  function addPage() {
    page = pdf.addPage([PAGE_W, PAGE_H])
    y = PAGE_H - MARGIN
  }

  function checkSpace(needed: number) {
    if (y - needed < MARGIN) addPage()
  }

  function drawText(text: string, opts: { size?: number; bold?: boolean; color?: ReturnType<typeof rgb>; x?: number } = {}) {
    const size = opts.size || 10
    const f = opts.bold ? fontBold : font
    const color = opts.color || rgb(0.15, 0.15, 0.15)
    const x = opts.x || MARGIN
    checkSpace(size + 4)
    page.drawText(text, { x, y, size, font: f, color })
    y -= LINE_H
  }

  function drawLine() {
    checkSpace(10)
    page.drawLine({ start: { x: MARGIN, y }, end: { x: PAGE_W - MARGIN, y }, thickness: 0.5, color: rgb(0.8, 0.8, 0.8) })
    y -= 8
  }

  function sectionTitle(title: string) {
    y -= 8
    drawText(title, { size: 13, bold: true, color: rgb(0.3, 0.2, 0.5) })
    drawLine()
  }

  // Header
  drawText('ПАСПОРТ ЗДОРОВЬЯ РЕБЁНКА', { size: 18, bold: true, color: rgb(0.3, 0.2, 0.5) })
  drawText('UMAI Health', { size: 9, color: rgb(0.5, 0.5, 0.5) })
  y -= 6
  drawLine()

  // Child info
  sectionTitle('Основные данные')
  drawText(`Имя: ${child.name || '—'}`)
  if (child.date_of_birth) {
    const dob = new Date(child.date_of_birth)
    drawText(`Дата рождения: ${dob.toLocaleDateString('ru-RU')}`)
    const ageMs = Date.now() - dob.getTime()
    const ageMonths = Math.floor(ageMs / (30.44 * 24 * 60 * 60 * 1000))
    drawText(`Возраст: ${ageMonths < 12 ? `${ageMonths} мес.` : `${Math.floor(ageMonths / 12)} г. ${ageMonths % 12} мес.`}`)
  }
  if (child.gender) drawText(`Пол: ${child.gender === 'male' ? 'Мальчик' : 'Девочка'}`)
  if (child.blood_type) drawText(`Группа крови: ${child.blood_type}`)
  if (child.birth_weight_g) drawText(`Вес при рождении: ${child.birth_weight_g} г`)
  if (child.birth_height_cm) drawText(`Рост при рождении: ${child.birth_height_cm} см`)
  if (child.apgar_score) drawText(`Оценка по Апгар: ${child.apgar_score}`)

  // Allergies & Chronic
  if (child.allergies?.length) {
    y -= 4
    drawText(`Аллергии: ${child.allergies.join(', ')}`, { color: rgb(0.7, 0.3, 0.2) })
  }
  if (child.chronic_conditions?.length) {
    drawText(`Хронические: ${child.chronic_conditions.join(', ')}`, { color: rgb(0.7, 0.3, 0.2) })
  }

  // Vaccinations
  if (vaccinations.length) {
    sectionTitle(`Прививки (${vaccinations.length})`)
    for (const v of vaccinations) {
      checkSpace(LINE_H)
      const status = v.status === 'completed' ? '✓' : v.status === 'scheduled' ? '○' : '—'
      const date = v.administered_date
        ? new Date(v.administered_date).toLocaleDateString('ru-RU')
        : v.scheduled_date
          ? `план: ${new Date(v.scheduled_date).toLocaleDateString('ru-RU')}`
          : ''
      drawText(`${status}  ${v.vaccine_name} (доза ${v.dose_number}) — ${date}`)
    }
  }

  // Health passport entries
  const diagnoses = entries.filter((e: any) => e.entry_type === 'diagnosis' || e.type === 'diagnosis')
  const allergiesEntries = entries.filter((e: any) => e.entry_type === 'allergy' || e.type === 'allergy')
  const surgeries = entries.filter((e: any) => e.entry_type === 'surgery' || e.type === 'surgery')
  const hospitalizations = entries.filter((e: any) => e.entry_type === 'hospitalization' || e.type === 'hospitalization')

  if (diagnoses.length) {
    sectionTitle('Диагнозы')
    for (const d of diagnoses) {
      drawText(`• ${d.title}${d.date ? ` (${new Date(d.date).toLocaleDateString('ru-RU')})` : ''}`)
      if (d.description) drawText(`  ${d.description}`, { size: 9, color: rgb(0.4, 0.4, 0.4) })
    }
  }

  if (allergiesEntries.length) {
    sectionTitle('Аллергии (записи)')
    for (const a of allergiesEntries) {
      drawText(`• ${a.title}${a.date ? ` (${new Date(a.date).toLocaleDateString('ru-RU')})` : ''}`)
    }
  }

  if (surgeries.length) {
    sectionTitle('Операции')
    for (const s of surgeries) {
      drawText(`• ${s.title}${s.date ? ` (${new Date(s.date).toLocaleDateString('ru-RU')})` : ''}`)
      if (s.description) drawText(`  ${s.description}`, { size: 9, color: rgb(0.4, 0.4, 0.4) })
    }
  }

  if (hospitalizations.length) {
    sectionTitle('Госпитализации')
    for (const h of hospitalizations) {
      drawText(`• ${h.title}${h.date ? ` (${new Date(h.date).toLocaleDateString('ru-RU')})` : ''}`)
    }
  }

  // Completed medical events
  if (completedEvents.length) {
    sectionTitle(`Пройденные обследования (${completedEvents.length})`)
    for (const e of completedEvents.slice(0, 30)) {
      const date = e.completed_at ? new Date(e.completed_at).toLocaleDateString('ru-RU') : ''
      drawText(`✓ ${e.title}${date ? ` — ${date}` : ''}`)
    }
  }

  // Footer
  y -= 12
  drawLine()
  const now = new Date()
  drawText(`Документ сформирован: ${now.toLocaleDateString('ru-RU')} ${now.toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' })}`, { size: 8, color: rgb(0.5, 0.5, 0.5) })
  drawText('UMAI Health — электронный паспорт здоровья ребёнка', { size: 8, color: rgb(0.5, 0.5, 0.5) })

  const pdfBytes = await pdf.save()

  setResponseHeaders(event, {
    'Content-Type': 'application/pdf',
    'Content-Disposition': `attachment; filename="health-passport-${childId.slice(0, 8)}.pdf"`,
    'Content-Length': String(pdfBytes.length),
  })

  return pdfBytes
})

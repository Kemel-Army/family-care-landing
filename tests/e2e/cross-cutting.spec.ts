import { test, expect } from '@playwright/test'
import { demoLogin, collectConsoleErrors, isDemoAvailable } from './helpers/auth'

// ─── Navigation ─────────────────────────────────────────

test.describe('Cross-cutting — Navigation', () => {
  test('back to home from demo', async ({ page }) => {
    await page.goto('/demo')
    await expect(page.locator('.demo-back')).toBeVisible()
    await page.locator('.demo-back').click()
    await page.waitForURL('/', { timeout: 10000 })
    expect(page.url()).toMatch(/\/$/)
  })

  test('can navigate between landing pages', async ({ page }) => {
    await page.goto('/')
    const familiesLink = page.locator('a[href="/for-families"]').first()
    if (await familiesLink.isVisible()) {
      await familiesLink.click()
      await page.waitForURL(/for-families/, { timeout: 10000 })
    }
  })

  test('demo login → back to demo → choose another role', async ({ page }) => {
    const available = await isDemoAvailable(page)
    test.skip(!available, 'Supabase not available')
    await demoLogin(page, 'mom')
    // Go back to demo
    await page.goto('/demo')
    await expect(page.locator('.demo-roles')).toBeVisible({ timeout: 15000 })
    // Login as doctor
    const card = page.locator('.demo-role-card', {
      has: page.locator('.role-title:text-is("Врач")'),
    })
    await card.click()
    await page.waitForURL(/\/demo\/doctor/, { timeout: 20000 })
    expect(page.url()).toContain('/demo/doctor')
  })
})

// ─── Responsive ─────────────────────────────────────────

test.describe('Cross-cutting — Responsive (mobile viewport)', () => {
  test.use({ viewport: { width: 375, height: 812 } }) // iPhone 14

  test('homepage renders on mobile', async ({ page }) => {
    await page.goto('/')
    await expect(page.locator('body')).toBeVisible()
    // Check no horizontal overflow
    const bodyWidth = await page.evaluate(() => document.body.scrollWidth)
    const viewportWidth = await page.evaluate(() => window.innerWidth)
    expect(bodyWidth).toBeLessThanOrEqual(viewportWidth + 5) // Allow small rounding
  })

  test('login page is usable on mobile', async ({ page }) => {
    await page.goto('/auth/login')
    await expect(page.locator('input[type="email"]')).toBeVisible()
    await expect(page.locator('.btn-primary')).toBeVisible()
  })

  test('demo page cards stack vertically on mobile', async ({ page }) => {
    await page.goto('/demo')
    await expect(page.locator('.demo-role-card').first()).toBeVisible({ timeout: 10000 })
    const cards = page.locator('.demo-role-card')
    const count = await cards.count()
    expect(count).toBe(4)
  })

  test('demo family dashboard works on mobile', async ({ page }) => {
    const available = await isDemoAvailable(page)
    test.skip(!available, 'Supabase not available')
    await demoLogin(page, 'mom')
    await expect(page.locator('.demo-dash, .dashboard').first()).toBeVisible({ timeout: 15000 })
  })
})

// ─── Error states ───────────────────────────────────────

test.describe('Cross-cutting — Error states', () => {
  test('404 page for unknown route', async ({ page }) => {
    await page.goto('/nonexistent-page-12345')
    // Should show error page or redirect
    await page.waitForLoadState('domcontentloaded')
    const body = await page.locator('body').textContent()
    // Either shows 404 error or redirects to login/home
    const url = page.url()
    const is404 = body?.includes('404') || body?.includes('не найдена') || body?.includes('not found')
    const isRedirected = url.includes('/auth/login') || url === '/' || url.endsWith('/')
    expect(is404 || isRedirected).toBe(true)
  })

  test('API health endpoint responds', async ({ page }) => {
    const response = await page.request.get('/api/health')
    expect(response.ok()).toBe(true)
  })
})

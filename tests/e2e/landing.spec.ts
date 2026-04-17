import { test, expect } from '@playwright/test'

test.describe('Landing — Homepage', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
  })

  test('page loads with correct title', async ({ page }) => {
    await expect(page).toHaveTitle(/UMAI Health/)
  })

  test('hero section is visible', async ({ page }) => {
    await expect(page.locator('.hero, .hero-banner, [class*="hero"]').first()).toBeVisible({ timeout: 10000 })
  })

  test('navigation header is visible', async ({ page }) => {
    await expect(page.locator('header, nav, .header, .navbar').first()).toBeVisible()
  })

  test('has link to /for-families', async ({ page }) => {
    const link = page.locator('a[href="/for-families"], a[href*="for-families"]').first()
    await expect(link).toBeVisible()
  })

  test('has link to /for-clinics', async ({ page }) => {
    const link = page.locator('a[href="/for-clinics"], a[href*="for-clinics"]').first()
    await expect(link).toBeVisible()
  })

  test('has CTA button linking to demo or auth', async ({ page }) => {
    const cta = page.locator('a[href="/demo"], a[href="/auth/login"], a[href="/auth/register"], .btn-primary, .cta-btn').first()
    await expect(cta).toBeVisible()
  })

  test('footer is visible at bottom', async ({ page }) => {
    const footer = page.locator('footer, .footer, .landing-footer').first()
    if (await footer.count() > 0) {
      await footer.scrollIntoViewIfNeeded()
      await expect(footer).toBeVisible()
    }
  })
})

test.describe('Landing — For Families page', () => {
  test('page loads', async ({ page }) => {
    await page.goto('/for-families')
    await expect(page.locator('body')).toBeVisible()
  })

  test('has hero or main heading', async ({ page }) => {
    await page.goto('/for-families')
    const heading = page.locator('h1, .hero-title, [class*="hero"]').first()
    await expect(heading).toBeVisible({ timeout: 10000 })
  })
})

test.describe('Landing — For Clinics page', () => {
  test('page loads', async ({ page }) => {
    await page.goto('/for-clinics')
    await expect(page.locator('body')).toBeVisible()
  })

  test('has hero or main heading', async ({ page }) => {
    await page.goto('/for-clinics')
    const heading = page.locator('h1, .hero-title, [class*="hero"]').first()
    await expect(heading).toBeVisible({ timeout: 10000 })
  })
})

test.describe('Landing — Privacy & Terms', () => {
  test('privacy page loads with content', async ({ page }) => {
    await page.goto('/privacy')
    await expect(page.locator('h1, .doc-page, .page-title').first()).toBeVisible({ timeout: 10000 })
  })

  test('terms page loads with content', async ({ page }) => {
    await page.goto('/terms')
    await expect(page.locator('h1, .doc-page, .page-title').first()).toBeVisible({ timeout: 10000 })
  })
})

test.describe('Landing — Demo page', () => {
  test('shows 4 role cards', async ({ page }) => {
    await page.goto('/demo')
    await expect(page.locator('.demo-role-card')).toHaveCount(4)
  })

  test('shows page title "Попробуйте платформу"', async ({ page }) => {
    await page.goto('/demo')
    await expect(page.locator('.demo-title')).toContainText('Попробуйте платформу')
  })

  test('has back link to home', async ({ page }) => {
    await page.goto('/demo')
    await expect(page.locator('.demo-back')).toBeVisible()
  })
})

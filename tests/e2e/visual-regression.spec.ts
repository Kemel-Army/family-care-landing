import { test, expect } from '@playwright/test'

/**
 * Visual regression tests — screenshot comparison for key pages.
 * Run: npx playwright test visual-regression.spec.ts --update-snapshots (first time)
 * Then: npx playwright test visual-regression.spec.ts (subsequent runs compare)
 */

test.describe('Visual Regression — Landing Pages', () => {
  test('homepage above the fold', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('domcontentloaded')

    // Wait for hero animations to settle
    await page.waitForTimeout(2000)

    await expect(page).toHaveScreenshot('homepage-hero.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    })
  })

  test('homepage full page', async ({ page }) => {
    test.setTimeout(60000)
    await page.goto('/')
    await page.waitForLoadState('domcontentloaded')
    await page.waitForTimeout(3000)

    await expect(page).toHaveScreenshot('homepage-full.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.05,
      animations: 'disabled',
      timeout: 20000,
    })
  })

  test('for-families page', async ({ page }) => {
    await page.goto('/for-families')
    await page.waitForLoadState('domcontentloaded')
    await page.waitForTimeout(2000)

    await expect(page).toHaveScreenshot('for-families.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    })
  })

  test('for-clinics page', async ({ page }) => {
    await page.goto('/for-clinics')
    await page.waitForLoadState('domcontentloaded')
    await page.waitForTimeout(2000)

    await expect(page).toHaveScreenshot('for-clinics.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
      animations: 'disabled',
      timeout: 15000,
    })
  })

  test('privacy page', async ({ page }) => {
    await page.goto('/privacy')
    await page.waitForLoadState('networkidle')

    await expect(page).toHaveScreenshot('privacy.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.02,
    })
  })

  test('terms page', async ({ page }) => {
    await page.goto('/terms')
    await page.waitForLoadState('networkidle')

    await expect(page).toHaveScreenshot('terms.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.02,
    })
  })
})

test.describe('Visual Regression — Auth Pages', () => {
  test('login page', async ({ page }) => {
    await page.goto('/auth/login')
    await page.waitForLoadState('networkidle')
    await page.waitForTimeout(500)

    await expect(page).toHaveScreenshot('login.png', {
      maxDiffPixelRatio: 0.03,
    })
  })

  test('register page', async ({ page }) => {
    await page.goto('/auth/register')
    await page.waitForLoadState('networkidle')
    await page.waitForTimeout(500)

    // May redirect to /demo — screenshot whatever loads
    await expect(page).toHaveScreenshot('register.png', {
      maxDiffPixelRatio: 0.03,
    })
  })
})

test.describe('Visual Regression — Demo Page', () => {
  test('demo landing', async ({ page }) => {
    await page.goto('/demo')
    await page.waitForLoadState('networkidle')
    await page.waitForTimeout(1000)

    await expect(page).toHaveScreenshot('demo-landing.png', {
      maxDiffPixelRatio: 0.05,
    })
  })
})

test.describe('Visual Regression — Mobile', () => {
  test.use({ viewport: { width: 390, height: 844 } })

  test('homepage mobile', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('domcontentloaded')
    await page.waitForTimeout(2000)

    await expect(page).toHaveScreenshot('homepage-mobile.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    })
  })

  test('for-families mobile', async ({ page }) => {
    await page.goto('/for-families')
    await page.waitForLoadState('domcontentloaded')
    await page.waitForTimeout(2000)

    await expect(page).toHaveScreenshot('for-families-mobile.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    })
  })

  test('login mobile', async ({ page }) => {
    await page.goto('/auth/login')
    await page.waitForLoadState('networkidle')
    await page.waitForTimeout(500)

    await expect(page).toHaveScreenshot('login-mobile.png', {
      maxDiffPixelRatio: 0.03,
    })
  })
})

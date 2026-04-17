import { test, expect } from '@playwright/test'

test.describe('Landing pages', () => {
  test('homepage loads', async ({ page }) => {
    await page.goto('/')
    await expect(page).toHaveTitle(/UMAI Health/)
  })

  test('for-families page loads', async ({ page }) => {
    await page.goto('/for-families')
    await expect(page.locator('body')).toBeVisible()
  })

  test('for-clinics page loads', async ({ page }) => {
    await page.goto('/for-clinics')
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Auth flow', () => {
  test('login page shows form', async ({ page }) => {
    await page.goto('/auth/login')
    await expect(page.locator('input[type="email"]')).toBeVisible()
    await expect(page.locator('input[type="password"]')).toBeVisible()
  })

  test('register page shows form or redirects to demo', async ({ page }) => {
    await page.goto('/auth/register')
    // Register page may redirect to /demo via middleware
    const url = page.url()
    if (url.includes('/demo')) {
      await expect(page.locator('.demo-title, .demo-roles').first()).toBeVisible()
    } else {
      await expect(page.locator('input[type="email"]')).toBeVisible()
    }
  })

  test('unauthenticated user redirected from /family', async ({ page }) => {
    await page.goto('/family')
    await page.waitForURL(/\/auth\/login/)
    expect(page.url()).toContain('/auth/login')
  })
})

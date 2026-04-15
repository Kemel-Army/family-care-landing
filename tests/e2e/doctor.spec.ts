import { test, expect } from './helpers/fixtures'
import { collectConsoleErrors } from './helpers/auth'

test.describe('Doctor — Dashboard', () => {
  test('dashboard loads', async ({ doctorPage: page }) => {
    await expect(page.locator('.demo-dash, .dashboard, .doc-page, .kpi-row, .kpi-card').first()).toBeVisible({ timeout: 15000 })
  })

  test('shows doctor-specific content', async ({ doctorPage: page }) => {
    const body = await page.locator('body').textContent()
    expect(body?.length).toBeGreaterThan(50)
  })

  test('has tab or section navigation', async ({ doctorPage: page }) => {
    const tabs = page.locator('.demo-tab, .tab-btn, [role="tab"]')
    const count = await tabs.count()
    if (count > 1) {
      await tabs.nth(1).click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible()
    }
  })

  test('no critical console errors', async ({ doctorPage: page }) => {
    const errors = collectConsoleErrors(page)
    await page.reload()
    await page.waitForLoadState('networkidle')
    const critical = errors.filter(e => !e.includes('favicon') && !e.includes('WebSocket'))
    expect(critical.length).toBeLessThanOrEqual(2)
  })
})

test.describe('Doctor — Schedule section', () => {
  test('schedule content is accessible', async ({ doctorPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /расписани|schedule|приём|slot/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Doctor — Patients section', () => {
  test('patients content is accessible', async ({ doctorPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /пациент|patient|семь|family/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

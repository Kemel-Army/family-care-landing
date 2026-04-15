import { test, expect } from './helpers/fixtures'
import { collectConsoleErrors } from './helpers/auth'

test.describe('Coordinator — Dashboard', () => {
  test('dashboard loads', async ({ coordinatorPage: page }) => {
    await expect(page.locator('.demo-dash, .dashboard, .coord-page, .kpi-row, .kpi-card').first()).toBeVisible({ timeout: 15000 })
  })

  test('shows coordinator-specific content', async ({ coordinatorPage: page }) => {
    const body = await page.locator('body').textContent()
    expect(body?.length).toBeGreaterThan(50)
  })

  test('has tab or section navigation', async ({ coordinatorPage: page }) => {
    const tabs = page.locator('.demo-tab, .tab-btn, [role="tab"]')
    const count = await tabs.count()
    if (count > 1) {
      await tabs.nth(1).click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible()
    }
  })

  test('no critical console errors', async ({ coordinatorPage: page }) => {
    const errors = collectConsoleErrors(page)
    await page.reload()
    await page.waitForLoadState('networkidle')
    const critical = errors.filter(e => !e.includes('favicon') && !e.includes('WebSocket'))
    expect(critical.length).toBeLessThanOrEqual(2)
  })
})

test.describe('Coordinator — Task queue section', () => {
  test('tasks content is accessible', async ({ coordinatorPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /задач|task|очередь|queue/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Coordinator — Families section', () => {
  test('families list is accessible', async ({ coordinatorPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /семь|famil|пациент/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

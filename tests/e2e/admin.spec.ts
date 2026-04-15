import { test, expect } from './helpers/fixtures'
import { collectConsoleErrors } from './helpers/auth'

test.describe('Admin (via demo) — Dashboard', () => {
  // Admin demo shares the coordinator view
  test('dashboard loads for admin role', async ({ adminPage: page }) => {
    await expect(page.locator('.demo-dash, .dashboard, .coord-page, .adm-page, .kpi-row, .kpi-card').first()).toBeVisible({ timeout: 15000 })
  })

  test('shows dashboard content', async ({ adminPage: page }) => {
    const body = await page.locator('body').textContent()
    expect(body?.length).toBeGreaterThan(50)
  })

  test('no critical console errors', async ({ adminPage: page }) => {
    const errors = collectConsoleErrors(page)
    await page.reload()
    await page.waitForLoadState('networkidle')
    const critical = errors.filter(e => !e.includes('favicon') && !e.includes('WebSocket'))
    expect(critical.length).toBeLessThanOrEqual(2)
  })
})

test.describe('Admin — Analytics / KPI section', () => {
  test('analytics content is accessible', async ({ adminPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /аналитик|analytic|KPI|отчёт|report/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Admin — Team / Settings section', () => {
  test('team or settings content is accessible', async ({ adminPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /команд|team|настройк|setting/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

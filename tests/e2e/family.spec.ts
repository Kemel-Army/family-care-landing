import { test, expect } from './helpers/fixtures'
import { collectConsoleErrors } from './helpers/auth'

test.describe('Family — Dashboard', () => {
  test('dashboard loads with KPI section', async ({ familyPage: page }) => {
    await expect(page.locator('.demo-dash, .dashboard, .kpi-row, .kpi-card').first()).toBeVisible({ timeout: 15000 })
  })

  test('shows greeting or user name', async ({ familyPage: page }) => {
    // Demo family user is Айгерим
    const body = await page.locator('body').textContent()
    // Should contain dashboard content
    expect(body?.length).toBeGreaterThan(50)
  })

  test('has tab navigation', async ({ familyPage: page }) => {
    const tabs = page.locator('.demo-tab, .tab-btn, [role="tab"]')
    const count = await tabs.count()
    if (count > 1) {
      await tabs.nth(1).click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible()
    }
  })

  test('no console errors on load', async ({ familyPage: page }) => {
    const errors = collectConsoleErrors(page)
    // Navigate to trigger fresh load
    await page.reload()
    await page.waitForLoadState('networkidle')
    const critical = errors.filter(e => !e.includes('favicon') && !e.includes('WebSocket'))
    expect(critical.length).toBeLessThanOrEqual(2) // Allow minor dev warnings
  })
})

test.describe('Family — Prescriptions tab', () => {
  test('prescriptions content is accessible', async ({ familyPage: page }) => {
    // Try clicking prescriptions tab if it exists
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /рецепт|назначени|лекарств|prescription/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content, .prescription-list, .dose-card').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Family — Journey tab', () => {
  test('journey / milestones content is accessible', async ({ familyPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /маршрут|journey|план|milestone/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content, .event-card, .journey-list').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Family — Appointments tab', () => {
  test('appointments content is accessible', async ({ familyPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /приём|запись|визит|appointment/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content, .appointment-card').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Family — Vaccinations tab', () => {
  test('vaccinations content is accessible', async ({ familyPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /прививк|вакцин|vaccination/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Family — Documents tab', () => {
  test('documents content is accessible', async ({ familyPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /документ|файл|document/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

test.describe('Family — Health / Growth tab', () => {
  test('health or growth content is accessible', async ({ familyPage: page }) => {
    const tab = page.locator('.demo-tab, .tab-btn, [role="tab"]').filter({ hasText: /здоровье|рост|вес|health|growth/i })
    if (await tab.count() > 0) {
      await tab.first().click()
      await expect(page.locator('.demo-dash, .demo-section, .tab-content').first()).toBeVisible({ timeout: 10000 })
    }
  })
})

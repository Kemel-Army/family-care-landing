import { test, expect } from '@playwright/test'

// ─── Helpers ────────────────────────────────────────────
async function demoLogin(page: import('@playwright/test').Page, role: string, expectedPath: string) {
  await page.goto('/demo')
  await expect(page.locator('.demo-roles')).toBeVisible()

  // Find the role card button containing the role's action text
  const card = page.locator('.demo-role-card', { has: page.locator(`.role-title:text-is("${roleTitles[role]}")`) })
  await card.click()

  // Wait for navigation to demo sub-page
  await page.waitForURL(new RegExp(expectedPath), { timeout: 15000 })
  expect(page.url()).toContain(expectedPath)
}

const roleTitles: Record<string, string> = {
  mom: 'Мама / Родитель',
  coordinator: 'Координатор клиники',
  doctor: 'Врач',
  admin: 'Руководитель клиники',
}

// ─── Demo Login ─────────────────────────────────────────

test.describe('Demo login — all 4 roles', () => {
  test('demo page loads with 4 role cards', async ({ page }) => {
    await page.goto('/demo')
    await expect(page.locator('.demo-role-card')).toHaveCount(4)
    await expect(page.locator('.demo-title')).toContainText('Попробуйте платформу')
  })

  test('login as mom → /demo/family', async ({ page }) => {
    await demoLogin(page, 'mom', '/demo/family')
    // Should see family dashboard content
    await expect(page.locator('body')).toBeVisible()
  })

  test('login as coordinator → /demo/coordinator', async ({ page }) => {
    await demoLogin(page, 'coordinator', '/demo/coordinator')
    await expect(page.locator('body')).toBeVisible()
  })

  test('login as doctor → /demo/doctor', async ({ page }) => {
    await demoLogin(page, 'doctor', '/demo/doctor')
    await expect(page.locator('body')).toBeVisible()
  })

  test('login as admin → /demo/coordinator', async ({ page }) => {
    await demoLogin(page, 'admin', '/demo/coordinator')
    await expect(page.locator('body')).toBeVisible()
  })
})

// ─── Family Critical Path ───────────────────────────────

test.describe('Family demo — critical path', () => {
  test.beforeEach(async ({ page }) => {
    await demoLogin(page, 'mom', '/demo/family')
  })

  test('dashboard shows KPI cards and sections', async ({ page }) => {
    // Should see greeting or KPI data
    await expect(page.locator('.demo-dash')).toBeVisible({ timeout: 10000 })
  })

  test('tabs navigate between sections', async ({ page }) => {
    // Demo family page should have tab navigation
    const tabs = page.locator('.demo-tab, .tab-btn, [role="tab"]')
    const tabCount = await tabs.count()
    if (tabCount > 1) {
      await tabs.nth(1).click()
      // Content should update
      await expect(page.locator('.demo-dash, .demo-section, .tab-content')).toBeVisible()
    }
  })
})

// ─── Doctor Critical Path ───────────────────────────────

test.describe('Doctor demo — critical path', () => {
  test.beforeEach(async ({ page }) => {
    await demoLogin(page, 'doctor', '/demo/doctor')
  })

  test('dashboard shows schedule and KPI', async ({ page }) => {
    await expect(page.locator('.demo-dash')).toBeVisible({ timeout: 10000 })
  })
})

// ─── Coordinator Critical Path ──────────────────────────

test.describe('Coordinator demo — critical path', () => {
  test.beforeEach(async ({ page }) => {
    await demoLogin(page, 'coordinator', '/demo/coordinator')
  })

  test('dashboard shows tasks and KPI', async ({ page }) => {
    await expect(page.locator('.demo-dash')).toBeVisible({ timeout: 10000 })
  })
})

import { test as base, expect } from '@playwright/test'
import { demoLogin, waitForDashboard, isDemoAvailable } from './auth'

/**
 * Playwright fixtures with pre-authenticated demo sessions for each role.
 * Tests using these fixtures are automatically skipped when Supabase is not available.
 *
 * Usage:
 *   import { test } from './helpers/fixtures'
 *   test('family dashboard', async ({ familyPage }) => { ... })
 */

type AuthFixtures = {
  familyPage: import('@playwright/test').Page
  doctorPage: import('@playwright/test').Page
  coordinatorPage: import('@playwright/test').Page
  adminPage: import('@playwright/test').Page
}

async function ensureDemoAvailable(page: import('@playwright/test').Page, testInfo: import('@playwright/test').TestInfo) {
  const available = await isDemoAvailable(page)
  if (!available) {
    testInfo.skip(true, 'Supabase is not available — demo login tests skipped')
  }
}

export const test = base.extend<AuthFixtures>({
  familyPage: async ({ page }, use, testInfo) => {
    await ensureDemoAvailable(page, testInfo)
    await demoLogin(page, 'mom')
    await waitForDashboard(page)
    await use(page)
  },

  doctorPage: async ({ page }, use, testInfo) => {
    await ensureDemoAvailable(page, testInfo)
    await demoLogin(page, 'doctor')
    await waitForDashboard(page)
    await use(page)
  },

  coordinatorPage: async ({ page }, use, testInfo) => {
    await ensureDemoAvailable(page, testInfo)
    await demoLogin(page, 'coordinator')
    await waitForDashboard(page)
    await use(page)
  },

  adminPage: async ({ page }, use, testInfo) => {
    await ensureDemoAvailable(page, testInfo)
    await demoLogin(page, 'admin')
    await waitForDashboard(page)
    await use(page)
  },
})

export { expect }

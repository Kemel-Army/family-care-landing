import { type Page, expect } from '@playwright/test'

/**
 * Check if the demo-login API is available (Supabase must be running).
 * Returns true only if we get a successful login response with tokens.
 */
export async function isDemoAvailable(page: Page): Promise<boolean> {
  try {
    const response = await page.request.post('/api/auth/demo-login', {
      data: { role: 'mom' },
      timeout: 15000,
    })
    if (!response.ok()) return false
    const body = await response.json()
    return !!(body?.access_token && body?.refresh_token)
  } catch {
    return false
  }
}

/**
 * Demo-login helper: calls /api/auth/demo-login, then sets session via cookie-based Supabase.
 * Works without real credentials by leveraging the auto-provisioning demo endpoint.
 */
export async function demoLogin(
  page: Page,
  role: 'mom' | 'coordinator' | 'doctor' | 'admin',
) {
  // Navigate to demo page and click the role card
  await page.goto('/demo')
  await expect(page.locator('.demo-roles')).toBeVisible({ timeout: 15000 })

  const roleTitles: Record<string, string> = {
    mom: 'Мама / Родитель',
    coordinator: 'Координатор клиники',
    doctor: 'Врач',
    admin: 'Руководитель клиники',
  }

  const expectedHome: Record<string, string> = {
    mom: '/demo/family',
    coordinator: '/demo/coordinator',
    doctor: '/demo/doctor',
    admin: '/demo/coordinator',
  }

  const card = page.locator('.demo-role-card', {
    has: page.locator(`.role-title:text-is("${roleTitles[role]}")`),
  })
  await card.click()

  // Wait for navigation to complete
  await page.waitForURL(new RegExp(expectedHome[role]), { timeout: 20000 })
  expect(page.url()).toContain(expectedHome[role])
}

/**
 * Wait for the demo dashboard to fully load.
 */
export async function waitForDashboard(page: Page) {
  await expect(
    page.locator('.demo-dash, .dashboard, .app-layout, .coord-page, .doc-page, .adm-page').first(),
  ).toBeVisible({ timeout: 15000 })
}

/**
 * Assert no console errors on the page (excluding known benign messages).
 */
export function collectConsoleErrors(page: Page): string[] {
  const errors: string[] = []
  page.on('console', (msg) => {
    if (msg.type() === 'error') {
      const text = msg.text()
      // Ignore dev-mode HMR and favicon 404s
      if (text.includes('favicon') || text.includes('[HMR]') || text.includes('WebSocket')) return
      errors.push(text)
    }
  })
  return errors
}

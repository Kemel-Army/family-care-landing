const BASE = process.env.TEST_BASE_URL || 'http://localhost:3000'

interface FetchOptions {
  method?: string
  body?: unknown
  headers?: Record<string, string>
  query?: Record<string, string>
}

/**
 * $fetch wrapper for API integration tests.
 * Returns { status, data, headers } without throwing on non-2xx.
 */
export async function apiFetch<T = unknown>(
  path: string,
  options: FetchOptions = {},
): Promise<{ status: number; data: T; headers: Headers }> {
  const url = new URL(path, BASE)

  if (options.query) {
    for (const [k, v] of Object.entries(options.query)) {
      url.searchParams.set(k, v)
    }
  }

  const res = await fetch(url.toString(), {
    method: options.method || 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
  })

  let data: T
  try {
    data = await res.json() as T
  }
  catch {
    data = null as T
  }

  return { status: res.status, data, headers: res.headers }
}

/**
 * Check if the dev server is reachable.
 */
export async function isServerAvailable(): Promise<boolean> {
  try {
    const res = await fetch(`${BASE}/api/health`, { signal: AbortSignal.timeout(5000) })
    return res.ok
  }
  catch {
    return false
  }
}

/**
 * Try demo login to get auth tokens. Returns null if Supabase not available.
 */
export async function getDemoTokens(role: 'mom' | 'coordinator' | 'admin' | 'doctor'): Promise<{
  access_token: string
  refresh_token: string
} | null> {
  try {
    const { status, data } = await apiFetch<{ access_token?: string; refresh_token?: string }>('/api/auth/demo-login', {
      method: 'POST',
      body: { role },
    })

    if (status === 200 && data?.access_token && data?.refresh_token) {
      return { access_token: data.access_token, refresh_token: data.refresh_token }
    }
    return null
  }
  catch {
    return null
  }
}

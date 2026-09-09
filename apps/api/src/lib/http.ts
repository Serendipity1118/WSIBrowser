// Small helpers shared by the routes.

// Bindings and vars come from worker-configuration.d.ts (`npm run types`).
export type Env = Cloudflare.Env;

export const PLUGIN_ID_RE = /^[a-zA-Z0-9-]{1,64}$/;
export const VERSION_RE = /^[0-9A-Za-z.+-]{1,64}$/;

const CORS_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Max-Age': '86400',
};

export function json(data: unknown, init: ResponseInit = {}): Response {
  const headers = new Headers(init.headers);
  headers.set('Content-Type', 'application/json; charset=utf-8');
  for (const [k, v] of Object.entries(CORS_HEADERS)) headers.set(k, v);
  return new Response(JSON.stringify(data), { ...init, headers });
}

export function error(status: number, message: string, extra: Record<string, unknown> = {}): Response {
  return json({ error: message, ...extra }, { status, headers: { 'Cache-Control': 'no-store' } });
}

export function cors(): Response {
  return new Response(null, { status: 204, headers: CORS_HEADERS });
}

export function withCors(res: Response): Response {
  const headers = new Headers(res.headers);
  for (const [k, v] of Object.entries(CORS_HEADERS)) headers.set(k, v);
  return new Response(res.body, { status: res.status, statusText: res.statusText, headers });
}

export function intVar(value: string | undefined, fallback: number): number {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 ? n : fallback;
}

export async function sha256Hex(text: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, '0')).join('');
}

/** Semver-ish compare (major.minor.patch, prerelease sorts lower). */
export function compareVersions(a: string, b: string): number {
  const core = (v: string) => v.split('+')[0].split('-')[0].split('.').map((p) => parseInt(p, 10) || 0);
  const ca = core(a);
  const cb = core(b);
  for (let i = 0; i < 3; i++) {
    const x = ca[i] ?? 0;
    const y = cb[i] ?? 0;
    if (x !== y) return x - y;
  }
  const pa = a.split('+')[0].includes('-');
  const pb = b.split('+')[0].includes('-');
  if (pa && !pb) return -1;
  if (!pa && pb) return 1;
  return 0;
}

// POST /v1/feedback  { pluginId, device?, body }  ->  { ok: true, id }
// Body size limit and a per-client rate limit (sha256 of the client IP,
// counted in D1 over a sliding window). No authentication (決定事項).
import { type Env, json, error, intVar, sha256Hex, PLUGIN_ID_RE } from '../lib/http';

export async function postFeedback(env: Env, request: Request): Promise<Response> {
  const maxBytes = intVar(env.FEEDBACK_MAX_BODY_BYTES, 4096);
  const limit = intVar(env.FEEDBACK_RATE_LIMIT, 5);
  const windowSec = intVar(env.FEEDBACK_RATE_WINDOW_SECONDS, 600);

  const raw = await request.text();
  if (raw.length > maxBytes * 4) return error(413, 'payload too large');
  let payload: { pluginId?: unknown; device?: unknown; body?: unknown };
  try {
    payload = JSON.parse(raw);
  } catch {
    return error(400, 'invalid json');
  }
  const pluginId = typeof payload.pluginId === 'string' ? payload.pluginId : '';
  const body = typeof payload.body === 'string' ? payload.body.trim() : '';
  if (!PLUGIN_ID_RE.test(pluginId)) return error(400, 'invalid pluginId');
  if (!body) return error(400, 'body is required');
  if (new TextEncoder().encode(body).length > maxBytes) return error(413, `body exceeds ${maxBytes} bytes`);
  const device = payload.device && typeof payload.device === 'object' ? JSON.stringify(payload.device).slice(0, 1024) : null;

  const ip = request.headers.get('CF-Connecting-IP') ?? request.headers.get('X-Forwarded-For') ?? 'unknown';
  const ipHash = await sha256Hex(ip);
  const since = new Date(Date.now() - windowSec * 1000).toISOString();
  const recent = await env.wsi_api
    .prepare('SELECT COUNT(*) AS n FROM feedback WHERE ip_hash = ? AND created_at > ?')
    .bind(ipHash, since)
    .first<{ n: number }>();
  if ((recent?.n ?? 0) >= limit) {
    return error(429, 'too many requests', { retryAfterSeconds: windowSec });
  }

  const res = await env.wsi_api
    .prepare('INSERT INTO feedback (plugin_id, device, body, ip_hash) VALUES (?, ?, ?, ?)')
    .bind(pluginId, device, body, ipHash)
    .run();
  return json({ ok: true, id: res.meta.last_row_id }, { status: 201, headers: { 'Cache-Control': 'no-store' } });
}

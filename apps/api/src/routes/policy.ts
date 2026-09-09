// GET /v1/plugins/:id/policy  ->  { pluginId, values: { key: value }, updatedAt }
// Values are stored as JSON text in plugin_policies. 404 when the plugin has no rows.
import { type Env, json, error, intVar } from '../lib/http';

export async function getPolicy(env: Env, pluginId: string): Promise<Response> {
  const rows = await env.wsi_api
    .prepare('SELECT key, value, updated_at FROM plugin_policies WHERE plugin_id = ?')
    .bind(pluginId)
    .all<{ key: string; value: string; updated_at: string }>();
  if (!rows.results.length) return error(404, 'no policy for plugin', { pluginId });

  const values: Record<string, unknown> = {};
  let updatedAt = '';
  for (const r of rows.results) {
    try {
      values[r.key] = JSON.parse(r.value);
    } catch {
      values[r.key] = r.value;
    }
    if (r.updated_at > updatedAt) updatedAt = r.updated_at;
  }
  const maxAge = intVar(env.POLICY_CACHE_SECONDS, 300);
  return json({ pluginId, values, updatedAt }, { headers: { 'Cache-Control': `public, max-age=${maxAge}` } });
}

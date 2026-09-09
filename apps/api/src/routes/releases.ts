// GET /v1/plugins/:id/releases/:version.zip  ->  the ZIP from the private R2 bucket.
// Only versions registered in plugin_releases are served, so the bucket
// contents are never enumerable from outside.
import { type Env, error } from '../lib/http';

export function r2KeyFor(pluginId: string, version: string): string {
  return `plugins/${pluginId}/${version}.zip`;
}

export async function getReleaseZip(env: Env, pluginId: string, version: string): Promise<Response> {
  const row = await env.wsi_api
    .prepare('SELECT r2_key FROM plugin_releases WHERE plugin_id = ? AND version = ?')
    .bind(pluginId, version)
    .first<{ r2_key: string | null }>();
  if (!row) return error(404, 'release not found', { pluginId, version });
  const key = row.r2_key ?? r2KeyFor(pluginId, version);
  const obj = await env.wsi_plugins.get(key);
  if (!obj) return error(404, 'zip not found in storage', { pluginId, version });
  const headers = new Headers();
  obj.writeHttpMetadata(headers);
  headers.set('Content-Type', 'application/zip');
  headers.set('Content-Disposition', `attachment; filename="${pluginId}-${version}.zip"`);
  headers.set('ETag', obj.httpEtag);
  headers.set('Cache-Control', 'public, max-age=31536000, immutable');
  headers.set('Access-Control-Allow-Origin', '*');
  return new Response(obj.body, { headers });
}

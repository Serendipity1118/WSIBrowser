// GET /v1/plugins/:id/latest  ->  { id, version, zipUrl, notes, releasedAt }
// The newest row of plugin_releases by version (semver order), which is what
// plugin.json's updateUrl points at (F-02-6). zipUrl is absolute.
import { type Env, json, error, intVar, compareVersions } from '../lib/http';

export interface Release {
  plugin_id: string;
  version: string;
  zip_url: string;
  r2_key: string | null;
  notes: string | null;
  released_at: string;
}

export async function latestRelease(env: Env, pluginId: string): Promise<Release | null> {
  const rows = await env.wsi_api
    .prepare('SELECT plugin_id, version, zip_url, r2_key, notes, released_at FROM plugin_releases WHERE plugin_id = ?')
    .bind(pluginId)
    .all<Release>();
  if (!rows.results.length) return null;
  return rows.results.sort((a, b) => compareVersions(b.version, a.version))[0];
}

export function absoluteZipUrl(origin: string, r: Release): string {
  if (/^https?:\/\//.test(r.zip_url)) return r.zip_url;
  return `${origin}/v1/plugins/${encodeURIComponent(r.plugin_id)}/releases/${encodeURIComponent(r.version)}.zip`;
}

export async function getLatest(env: Env, pluginId: string, origin: string): Promise<Response> {
  const r = await latestRelease(env, pluginId);
  if (!r) return error(404, 'no release for plugin', { pluginId });
  const maxAge = intVar(env.POLICY_CACHE_SECONDS, 300);
  return json(
    { id: r.plugin_id, version: r.version, zipUrl: absoluteZipUrl(origin, r), notes: r.notes ?? '', releasedAt: r.released_at },
    { headers: { 'Cache-Control': `public, max-age=${maxAge}` } },
  );
}

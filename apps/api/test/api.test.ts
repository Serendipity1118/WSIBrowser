// Endpoint tests on workerd (vitest-pool-workers): D1 and R2 are real local
// bindings, the schema is applied from migrations/ before each test.
import { env, SELF } from 'cloudflare:test';
import { beforeEach, describe, expect, it } from 'vitest';

async function resetDb() {
  await env.wsi_api.batch([
    env.wsi_api.prepare('DELETE FROM plugin_policies'),
    env.wsi_api.prepare('DELETE FROM plugin_releases'),
    env.wsi_api.prepare('DELETE FROM feedback'),
  ]);
}

async function seedRelease(pluginId: string, version: string, notes = 'notes', zip = new Uint8Array([0x50, 0x4b, 3, 4])) {
  const key = `plugins/${pluginId}/${version}.zip`;
  await env.wsi_plugins.put(key, zip);
  await env.wsi_api
    .prepare('INSERT INTO plugin_releases (plugin_id, version, zip_url, r2_key, notes) VALUES (?, ?, ?, ?, ?)')
    .bind(pluginId, version, '', key, notes)
    .run();
}

const get = (path: string, headers: Record<string, string> = {}) => SELF.fetch(`https://wsi-api.test${path}`, { headers });
const post = (path: string, body: unknown, headers: Record<string, string> = {}) =>
  SELF.fetch(`https://wsi-api.test${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...headers },
    body: typeof body === 'string' ? body : JSON.stringify(body),
  });

beforeEach(resetDb);

describe('GET /v1/plugins/:id/policy', () => {
  it('returns the JSON values of the plugin with Cache-Control', async () => {
    await env.wsi_api.batch([
      env.wsi_api.prepare("INSERT INTO plugin_policies (plugin_id, key, value) VALUES ('pokepara', 'minActionIntervalMs', '3000')"),
      env.wsi_api.prepare("INSERT INTO plugin_policies (plugin_id, key, value) VALUES ('pokepara', 'features', '{\"cruise\":true}')"),
      env.wsi_api.prepare("INSERT INTO plugin_policies (plugin_id, key, value) VALUES ('other', 'x', '1')"),
    ]);
    const res = await get('/v1/plugins/pokepara/policy');
    expect(res.status).toBe(200);
    expect(res.headers.get('Cache-Control')).toBe('public, max-age=300');
    expect(res.headers.get('Access-Control-Allow-Origin')).toBe('*');
    const body = await res.json<{ pluginId: string; values: Record<string, unknown>; updatedAt: string }>();
    expect(body.pluginId).toBe('pokepara');
    expect(body.values).toEqual({ minActionIntervalMs: 3000, features: { cruise: true } });
    expect(body.updatedAt).toMatch(/^\d{4}-/);
  });

  it('404 for an unknown plugin, 400 for a bad id', async () => {
    expect((await get('/v1/plugins/nope/policy')).status).toBe(404);
    expect((await get('/v1/plugins/bad%20id/policy')).status).toBe(400);
    expect((await SELF.fetch('https://wsi-api.test/v1/plugins/x/policy', { method: 'POST' })).status).toBe(405);
  });
});

describe('GET /v1/plugins/:id/latest', () => {
  it('returns the highest version with an absolute zipUrl on this worker', async () => {
    await seedRelease('pokepara', '1.9.0', 'old');
    await seedRelease('pokepara', '1.10.0', 'new');
    await seedRelease('pokepara', '2.0.0-beta.1', 'beta');
    const res = await get('/v1/plugins/pokepara/latest');
    expect(res.status).toBe(200);
    const body = await res.json<{ id: string; version: string; zipUrl: string; notes: string }>();
    expect(body.version).toBe('2.0.0-beta.1');
    expect(body.zipUrl).toBe('https://wsi-api.test/v1/plugins/pokepara/releases/2.0.0-beta.1.zip');
    expect(body.notes).toBe('beta');
  });

  it('keeps an external https zip_url as is', async () => {
    await env.wsi_api
      .prepare("INSERT INTO plugin_releases (plugin_id, version, zip_url) VALUES ('ext', '1.0.0', 'https://cdn.example/ext.zip')")
      .run();
    const body = await (await get('/v1/plugins/ext/latest')).json<{ zipUrl: string }>();
    expect(body.zipUrl).toBe('https://cdn.example/ext.zip');
  });

  it('404 when there is no release', async () => {
    expect((await get('/v1/plugins/none/latest')).status).toBe(404);
  });
});

describe('GET /v1/plugins/:id/releases/:version.zip', () => {
  it('streams the object from R2 with zip headers', async () => {
    await seedRelease('pokepara', '1.0.0');
    const res = await get('/v1/plugins/pokepara/releases/1.0.0.zip');
    expect(res.status).toBe(200);
    expect(res.headers.get('Content-Type')).toBe('application/zip');
    expect(res.headers.get('Content-Disposition')).toContain('pokepara-1.0.0.zip');
    expect(new Uint8Array(await res.arrayBuffer())).toEqual(new Uint8Array([0x50, 0x4b, 3, 4]));
  });

  it('404 for unregistered versions even if an object exists (no bucket enumeration)', async () => {
    await env.wsi_plugins.put('plugins/pokepara/9.9.9.zip', new Uint8Array([1]));
    expect((await get('/v1/plugins/pokepara/releases/9.9.9.zip')).status).toBe(404);
    await seedRelease('pokepara', '1.0.0');
    await env.wsi_plugins.delete('plugins/pokepara/1.0.0.zip');
    expect((await get('/v1/plugins/pokepara/releases/1.0.0.zip')).status).toBe(404);
  });
});

describe('POST /v1/feedback', () => {
  it('stores feedback and returns its id', async () => {
    const res = await post('/v1/feedback', { pluginId: 'pokepara', body: 'ボタンが押せない', device: { os: 'android', osVersion: '14' } }, { 'CF-Connecting-IP': '203.0.113.1' });
    expect(res.status).toBe(201);
    const body = await res.json<{ ok: boolean; id: number }>();
    expect(body.ok).toBe(true);
    const row = await env.wsi_api.prepare('SELECT plugin_id, body, device, ip_hash FROM feedback WHERE id = ?').bind(body.id).first<Record<string, string>>();
    expect(row?.plugin_id).toBe('pokepara');
    expect(row?.body).toBe('ボタンが押せない');
    expect(JSON.parse(row!.device)).toEqual({ os: 'android', osVersion: '14' });
    expect(row?.ip_hash).toMatch(/^[0-9a-f]{64}$/);
    expect(row?.ip_hash).not.toContain('203.0.113.1');
  });

  it('validates the payload', async () => {
    expect((await post('/v1/feedback', '{oops')).status).toBe(400);
    expect((await post('/v1/feedback', { pluginId: 'bad id', body: 'x' })).status).toBe(400);
    expect((await post('/v1/feedback', { pluginId: 'ok', body: '   ' })).status).toBe(400);
    expect((await post('/v1/feedback', { pluginId: 'ok', body: 'x'.repeat(5000) })).status).toBe(413);
    expect((await get('/v1/feedback')).status).toBe(405);
  });

  it('rate limits per client (5 per window by default)', async () => {
    for (let i = 0; i < 5; i++) {
      expect((await post('/v1/feedback', { pluginId: 'p', body: `m${i}` }, { 'CF-Connecting-IP': '198.51.100.7' })).status).toBe(201);
    }
    const blocked = await post('/v1/feedback', { pluginId: 'p', body: 'one more' }, { 'CF-Connecting-IP': '198.51.100.7' });
    expect(blocked.status).toBe(429);
    expect((await blocked.json<{ retryAfterSeconds: number }>()).retryAfterSeconds).toBe(600);
    // another client is unaffected
    expect((await post('/v1/feedback', { pluginId: 'p', body: 'hi' }, { 'CF-Connecting-IP': '198.51.100.8' })).status).toBe(201);
  });
});

describe('distribution page', () => {
  it('renders the page with a QR of the wsi://install link', async () => {
    await seedRelease('pokepara', '1.2.3', 'Release notes <b>escaped</b>');
    const res = await get('/p/pokepara');
    expect(res.status).toBe(200);
    expect(res.headers.get('Content-Type')).toContain('text/html');
    const html = await res.text();
    expect(html).toContain('pokepara');
    expect(html).toContain('v1.2.3');
    expect(html).toContain('&lt;b&gt;escaped&lt;/b&gt;');
    expect(html).toContain('href="wsi://install?url=https%3A%2F%2Fwsi-api.test%2Fv1%2Fplugins%2Fpokepara%2Freleases%2F1.2.3.zip"');
    expect(html).toContain('<svg');
    const qr = await get('/p/pokepara/qr.svg');
    expect(qr.status).toBe(200);
    expect(qr.headers.get('Content-Type')).toBe('image/svg+xml');
    expect(await qr.text()).toContain('<svg');
  });

  it('404 without a release; static landing page and stylesheet are served', async () => {
    expect((await get('/p/none')).status).toBe(404);
    const index = await get('/');
    expect(index.status).toBe(200);
    expect(await index.text()).toContain('プラグイン配布');
    expect((await get('/style.css')).headers.get('Content-Type')).toContain('text/css');
    expect((await get('/v1/unknown')).status).toBe(404);
    expect((await get('/health')).status).toBe(200);
  });
});

describe('CORS', () => {
  it('answers preflight and adds the origin header to API responses', async () => {
    const pre = await SELF.fetch('https://wsi-api.test/v1/feedback', { method: 'OPTIONS' });
    expect(pre.status).toBe(204);
    expect(pre.headers.get('Access-Control-Allow-Methods')).toContain('POST');
  });
});

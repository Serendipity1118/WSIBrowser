// wsi-plugin dev-serve: serve the packed plugin over HTTPS from this PC so a
// phone running WSI Browser (developer mode) can import it.
//
//   GET /            small HTML page with the install link and QR
//   GET /plugin.zip  the ZIP (re-packed lazily when a source file changed)
//   GET /plugin.json the manifest
//   GET /latest      { version, zipUrl, notes } (same shape as the update endpoint)
//
// The certificate is self-signed and generated per run; developer mode in the
// host is expected to accept it for the LAN address printed here.
import { createServer } from 'node:https';
import { watch } from 'node:fs';
import { networkInterfaces } from 'node:os';
import { join } from 'node:path';
import { pack } from './index.js';

function lanAddresses() {
  const out = [];
  for (const list of Object.values(networkInterfaces())) {
    for (const a of list || []) {
      if (a.family === 'IPv4' && !a.internal) out.push(a.address);
    }
  }
  return out;
}

async function makeCert(hosts) {
  const { default: selfsigned } = await import('selfsigned');
  const attrs = [{ name: 'commonName', value: 'wsi-plugin dev-serve' }];
  const altNames = [
    { type: 2, value: 'localhost' },
    ...hosts.map((ip) => ({ type: 7, ip })),
    { type: 7, ip: '127.0.0.1' },
  ];
  const pems = await selfsigned.generate(attrs, {
    keySize: 2048,
    days: 30,
    algorithm: 'sha256',
    extensions: [{ name: 'subjectAltName', altNames }],
  });
  return { key: pems.private, cert: pems.cert };
}

function html(installUrl, zipUrl, def) {
  return `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${def.name} (dev)</title>
<style>body{font-family:sans-serif;max-width:480px;margin:40px auto;line-height:1.6}code{background:#eee;padding:2px 4px}</style>
<h1>${def.name} <small>v${def.version}</small></h1>
<p><a href="${installUrl}">WSI Browser にインストール</a></p>
<p><a href="${zipUrl}">ZIP をダウンロード</a> / <a href="/plugin.json">plugin.json</a> / <a href="/latest">latest</a></p>
<p>id: <code>${def.id}</code><br>domains: <code>${(def.domains || []).join(', ')}</code></p>`;
}

/**
 * @param {string} dir plugin directory
 * @param {{port?: number, host?: string, minify?: boolean}} opts
 */
export async function serve(dir, opts = {}) {
  const port = opts.port || 8443;
  const addresses = lanAddresses();
  const host = opts.host || addresses[0] || 'localhost';
  const cert = await makeCert(addresses);

  let cached = null;
  let dirty = true;
  const repack = async () => {
    if (!dirty && cached) return cached;
    cached = await pack(dir, { out: join(dir, 'dist', 'dev.zip'), minify: opts.minify });
    dirty = false;
    return cached;
  };

  const watchers = [];
  for (const w of ['plugin.json', 'style.css', 'src', 'pages', 'assets']) {
    try {
      watchers.push(watch(join(dir, w), { recursive: true }, () => { dirty = true; }));
    } catch { /* missing optional dir */ }
  }

  const base = `https://${host}:${port}`;
  const zipUrl = `${base}/plugin.zip`;
  const installUrl = `wsi://install?url=${encodeURIComponent(zipUrl)}`;

  const server = createServer(cert, async (req, res) => {
    try {
      const url = new URL(req.url, base);
      if (url.pathname === '/plugin.zip') {
        const { buffer, def } = await repack();
        res.writeHead(200, {
          'Content-Type': 'application/zip',
          'Content-Disposition': `attachment; filename="${def.id}-${def.version}.zip"`,
          'Cache-Control': 'no-store',
        });
        res.end(buffer);
        console.log(`[dev-serve] ${new Date().toLocaleTimeString()} served plugin.zip (${buffer.length} bytes)`);
        return;
      }
      if (url.pathname === '/plugin.json') {
        const { def } = await repack();
        res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
        res.end(JSON.stringify(def, null, 2));
        return;
      }
      if (url.pathname === '/latest') {
        const { def } = await repack();
        res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
        res.end(JSON.stringify({ id: def.id, version: def.version, zipUrl, notes: 'dev-serve' }));
        return;
      }
      if (url.pathname === '/') {
        const { def } = await repack();
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' });
        res.end(html(installUrl, zipUrl, def));
        return;
      }
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('not found');
    } catch (e) {
      res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end(String(e && e.message ? e.message : e));
      console.error('[dev-serve]', e && e.message ? e.message : e);
    }
  });

  await new Promise((resolveListen, reject) => {
    server.once('error', reject);
    server.listen(port, '0.0.0.0', resolveListen);
  });

  const { def } = await repack();
  console.log(`[dev-serve] ${def.name} v${def.version}`);
  console.log(`[dev-serve] page:    ${base}/`);
  console.log(`[dev-serve] zip:     ${zipUrl}`);
  console.log(`[dev-serve] install: ${installUrl}`);
  if (addresses.length > 1) console.log(`[dev-serve] other addresses: ${addresses.filter((a) => a !== host).join(', ')}`);
  if (!opts.noQr) {
    const { default: qrcode } = await import('qrcode-terminal');
    qrcode.generate(installUrl, { small: true });
  }
  const close = () => new Promise((r) => {
    for (const w of watchers) w.close();
    server.close(() => r());
    if (typeof server.closeAllConnections === 'function') server.closeAllConnections();
  });
  return { server, base, zipUrl, installUrl, close };
}

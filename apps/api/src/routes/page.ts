// GET /p/:id           distribution page: name, version, notes, QR of the install link
// GET /p/:id/qr.svg    the QR alone
// The install link is wsi://install?url=<zip url>; the QR encodes that link so
// WSI Browser's scanner opens the import preview directly (F-02-1).
import QRCode from 'qrcode-svg';

import { type Env, error } from '../lib/http';
import { latestRelease, absoluteZipUrl } from './latest';

const ESCAPES: Record<string, string> = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };

function escapeHtml(s: string): string {
  return s.replace(/[&<>"']/g, (c) => ESCAPES[c]);
}

export function installLink(zipUrl: string): string {
  return `wsi://install?url=${encodeURIComponent(zipUrl)}`;
}

export function qrSvg(content: string, size = 256): string {
  return new QRCode({ content, padding: 2, width: size, height: size, color: '#000000', background: '#ffffff', ecl: 'M', join: true }).svg();
}

export async function getQr(env: Env, pluginId: string, origin: string): Promise<Response> {
  const r = await latestRelease(env, pluginId);
  if (!r) return error(404, 'no release for plugin', { pluginId });
  const svg = qrSvg(installLink(absoluteZipUrl(origin, r)));
  return new Response(svg, { headers: { 'Content-Type': 'image/svg+xml', 'Cache-Control': 'public, max-age=300' } });
}

export async function getPage(env: Env, pluginId: string, origin: string): Promise<Response> {
  const r = await latestRelease(env, pluginId);
  if (!r) return error(404, 'no release for plugin', { pluginId });
  const zipUrl = absoluteZipUrl(origin, r);
  const link = installLink(zipUrl);
  const notes = r.notes ? `<p class="notes">${escapeHtml(r.notes)}</p>` : '';
  const html = [
    '<!doctype html>',
    '<html lang="ja">',
    '<head>',
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    `<title>${escapeHtml(r.plugin_id)} v${escapeHtml(r.version)} - WSI Browser plugin</title>`,
    '<link rel="stylesheet" href="/style.css">',
    '</head>',
    '<body>',
    '<main class="card">',
    '  <p class="eyebrow">WSI Browser plugin</p>',
    `  <h1>${escapeHtml(r.plugin_id)} <small>v${escapeHtml(r.version)}</small></h1>`,
    `  ${notes}`,
    `  <p class="released">released ${escapeHtml(r.released_at)}</p>`,
    `  <div class="qr">${qrSvg(link, 220)}</div>`,
    `  <p><a class="button" href="${escapeHtml(link)}">WSI Browser にインストール</a></p>`,
    `  <p class="alt"><a href="${escapeHtml(zipUrl)}">ZIP をダウンロード</a> / <a href="/v1/plugins/${encodeURIComponent(r.plugin_id)}/latest">latest (JSON)</a></p>`,
    '  <p class="hint">スマートフォンで QR を読むか、WSI Browser の「プラグイン → インポート → QR コードを読む」から取り込めます。</p>',
    '</main>',
    '</body>',
    '</html>',
  ].join('\n');
  return new Response(html, { headers: { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'public, max-age=300' } });
}

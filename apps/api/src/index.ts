// WSI Browser backend (要件定義 F-13). Routes:
//   GET  /v1/plugins/:id/policy
//   GET  /v1/plugins/:id/latest
//   GET  /v1/plugins/:id/releases/:version.zip
//   POST /v1/feedback
//   GET  /p/:id, /p/:id/qr.svg          distribution page + QR
//   GET  /* (static assets in public/)  landing page, stylesheet
import { type Env, cors, error, PLUGIN_ID_RE, VERSION_RE } from './lib/http';
import { getPolicy } from './routes/policy';
import { getLatest } from './routes/latest';
import { getReleaseZip } from './routes/releases';
import { postFeedback } from './routes/feedback';
import { getPage, getQr } from './routes/page';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const origin = `${url.protocol}//${url.host}`;
    const path = url.pathname;

    if (request.method === 'OPTIONS') return cors();

    const plugin = path.match(/^\/v1\/plugins\/([^/]+)\/(policy|latest)$/);
    if (plugin) {
      if (request.method !== 'GET' && request.method !== 'HEAD') return error(405, 'method not allowed');
      const id = decodeURIComponent(plugin[1]);
      if (!PLUGIN_ID_RE.test(id)) return error(400, 'invalid plugin id');
      return plugin[2] === 'policy' ? getPolicy(env, id) : getLatest(env, id, origin);
    }

    const release = path.match(/^\/v1\/plugins\/([^/]+)\/releases\/([^/]+)\.zip$/);
    if (release) {
      if (request.method !== 'GET' && request.method !== 'HEAD') return error(405, 'method not allowed');
      const id = decodeURIComponent(release[1]);
      const version = decodeURIComponent(release[2]);
      if (!PLUGIN_ID_RE.test(id) || !VERSION_RE.test(version)) return error(400, 'invalid plugin id or version');
      return getReleaseZip(env, id, version);
    }

    if (path === '/v1/feedback') {
      if (request.method !== 'POST') return error(405, 'method not allowed');
      return postFeedback(env, request);
    }

    const page = path.match(/^\/p\/([^/]+)(\/qr\.svg)?\/?$/);
    if (page) {
      const id = decodeURIComponent(page[1]);
      if (!PLUGIN_ID_RE.test(id)) return error(400, 'invalid plugin id');
      return page[2] ? getQr(env, id, origin) : getPage(env, id, origin);
    }

    if (path === '/health') {
      return new Response('ok', { headers: { 'Cache-Control': 'no-store' } });
    }

    if (path.startsWith('/v1/')) return error(404, 'not found');
    const asset = await env.ASSETS.fetch(request);
    if (asset.status !== 404) return asset;
    return error(404, 'not found');
  },
} satisfies ExportedHandler<Env>;

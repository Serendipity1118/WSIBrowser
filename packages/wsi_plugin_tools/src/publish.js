// wsi-plugin publish: pack the plugin, upload the ZIP to the private R2 bucket
// and register the release in D1, both through wrangler (uses the developer's
// wrangler login; there is no public write endpoint on the API).
//
//   wsi-plugin publish [dir] [--notes "..."] [--bucket wsi-plugins] [--database wsi-api]
//                      [--base-url https://wsi-api.pokeplus-dev.workers.dev] [--dry-run]
//
// After publishing, GET <base-url>/v1/plugins/<id>/latest returns the new
// version and <base-url>/p/<id> shows the QR page.
import { spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pack } from './index.js';

export const DEFAULTS = {
  bucket: 'wsi-plugins',
  database: 'wsi-api',
  baseUrl: 'https://wsi-api.pokeplus-dev.workers.dev',
};

export function r2KeyFor(id, version) {
  return `plugins/${id}/${version}.zip`;
}

function sqlString(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

export function releaseInsertSql({ id, version, notes, key }) {
  return `INSERT OR REPLACE INTO plugin_releases (plugin_id, version, zip_url, r2_key, notes) VALUES (${sqlString(id)}, ${sqlString(version)}, '', ${sqlString(key)}, ${notes ? sqlString(notes) : 'NULL'});`;
}

/** Locate wrangler's entry script (installed next to the plugin or next to this CLI); null -> use npx. */
function findWrangler(fromDir) {
  const req = createRequire(join(fromDir, 'package.json'));
  for (const r of [req, createRequire(import.meta.url)]) {
    try {
      return r.resolve('wrangler/bin/wrangler.js');
    } catch { /* not installed here */ }
  }
  return null;
}

function runWrangler(args, { dryRun, cwd }) {
  const entry = findWrangler(cwd);
  const cmd = entry ? process.execPath : (process.platform === 'win32' ? 'npx.cmd' : 'npx');
  const full = entry ? [entry, ...args] : ['wrangler', ...args];
  console.log(`$ ${entry ? 'wrangler' : 'npx wrangler'} ${args.join(' ')}`);
  if (dryRun) return { status: 0, stdout: '' };
  const res = spawnSync(cmd, full, { stdio: ['ignore', 'pipe', 'inherit'], encoding: 'utf8', cwd, shell: !entry && process.platform === 'win32' });
  if (res.status !== 0) {
    throw new Error(`wrangler ${args[0]} ${args[1] || ''} failed (exit ${res.status})`);
  }
  return res;
}

/**
 * @param {string} dir plugin directory
 * @param {{notes?: string, bucket?: string, database?: string, baseUrl?: string, dryRun?: boolean, minify?: boolean}} opts
 */
export async function publish(dir, opts = {}) {
  const bucket = opts.bucket || DEFAULTS.bucket;
  const database = opts.database || DEFAULTS.database;
  const baseUrl = (opts.baseUrl || DEFAULTS.baseUrl).replace(/\/$/, '');
  const dryRun = !!opts.dryRun;

  const { zipPath, def } = await pack(dir, { minify: opts.minify });
  const key = r2KeyFor(def.id, def.version);

  runWrangler(['r2', 'object', 'put', `${bucket}/${key}`, '--file', zipPath, '--content-type', 'application/zip', '--remote'], { dryRun, cwd: dir });
  // the SQL goes through a file: a --command argument gets split by the shell on Windows
  const tmp = mkdtempSync(join(tmpdir(), 'wsi-publish-'));
  const sqlFile = join(tmp, 'release.sql');
  writeFileSync(sqlFile, `${releaseInsertSql({ id: def.id, version: def.version, notes: opts.notes, key })}\n`);
  try {
    runWrangler(['d1', 'execute', database, '--remote', '--file', sqlFile], { dryRun, cwd: dir });
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }

  const latestUrl = `${baseUrl}/v1/plugins/${encodeURIComponent(def.id)}/latest`;
  const pageUrl = `${baseUrl}/p/${encodeURIComponent(def.id)}`;
  const zipUrl = `${baseUrl}/v1/plugins/${encodeURIComponent(def.id)}/releases/${encodeURIComponent(def.version)}.zip`;
  return { id: def.id, version: def.version, key, zipUrl, latestUrl, pageUrl, dryRun };
}

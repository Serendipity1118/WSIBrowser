import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

export const here = dirname(fileURLToPath(import.meta.url));
export const pkgRoot = join(here, '..');
export const repoRoot = join(pkgRoot, '..', '..');
export const distDir = join(pkgRoot, 'dist');
export const fixturesDir = join(here, 'fixtures');
export const samplesDir = join(repoRoot, 'plugins', 'samples');

export const WSI_REPO = resolve(process.env.WSI_REPO || join(repoRoot, '..', 'WebSystemInjection'));
export const EXTENSION_PATH = join(WSI_REPO, 'src');

export function fixture(name) {
  return readFileSync(join(fixturesDir, name), 'utf8');
}

/** Load plugins/samples/<id> as the record the Chrome extension stores in chrome.storage.local.plugins */
export function loadSamplePlugin(id) {
  const dir = join(samplesDir, id);
  const def = JSON.parse(readFileSync(join(dir, 'plugin.json'), 'utf8'));
  const code = readFileSync(join(dir, def.scripts.main), 'utf8');
  let css = '';
  for (const s of def.styles || []) {
    const f = join(dir, s);
    if (existsSync(f)) css += readFileSync(f, 'utf8');
  }
  return {
    id: def.id,
    name: def.name,
    version: def.version,
    description: def.description || '',
    author: def.author || '',
    domains: def.domains,
    runAt: (def.scripts && def.scripts.runAt) || 'document_idle',
    enabled: true,
    code,
    css,
    config: def.config || {},
    formatVersion: def.formatVersion || 1,
    permissions: Array.isArray(def.permissions) ? def.permissions : undefined,
    installedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

export function sampleIds() {
  const index = join(samplesDir, 'index.json');
  if (existsSync(index)) return JSON.parse(readFileSync(index, 'utf8')).ids;
  return readdirSync(samplesDir, { withFileTypes: true }).filter((d) => d.isDirectory()).map((d) => d.name);
}

/** Serve fixture HTML for the URLs the sample plugins target. */
export async function routeFixtures(context) {
  await context.route('https://example.com/**', (route) =>
    route.fulfill({ status: 200, contentType: 'text/html; charset=utf-8', body: fixture('article.html') }));
  await context.route('https://example.org/**', (route) =>
    route.fulfill({ status: 200, contentType: 'text/html; charset=utf-8', body: fixture('article.html') }));
  await context.route('https://nipponsteel.com/**', (route) =>
    route.fulfill({ status: 200, contentType: 'text/html; charset=utf-8', body: fixture('dijaw40.html') }));
}

export const DIJAW40_URL = 'https://nipponsteel.com/esys969/dij_web/webapp/page/DijAW40';

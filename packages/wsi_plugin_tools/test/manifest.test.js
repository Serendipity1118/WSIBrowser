import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateManifest, referencedFiles, PERMISSIONS } from '../src/manifest.js';

const files = new Set(['dist/main.js', 'main.js', 'style.css', 'dist/worker.js', 'pages/settings.html']);
const exists = (f) => files.has(f);

const v1 = () => ({
  id: 'hello-world', name: 'Hello', version: '1.0.0', domains: ['example.com'],
  scripts: { main: 'main.js', runAt: 'document_idle' }, styles: ['style.css'], config: {},
});

const v2 = () => ({
  formatVersion: 2, id: 'example-site', name: 'Example', version: '2.0.0-beta.1',
  domains: ['example.com', '*.example.com', '*'], paths: ['/manage/**'],
  scripts: { main: 'dist/main.js' }, styles: ['style.css'], background: 'dist/worker.js',
  pages: { settings: { file: 'pages/settings.html', display: 'sheet' } },
  menu: [{ id: 'settings', label: 'Settings', type: 'page', page: 'settings' }, { type: 'separator' }, { id: 'go', label: 'Go', type: 'action' }],
  permissions: ['fetch', 'tabs', 'pages', 'menu', 'policy'],
  settingsSchema: [{ key: 'n', type: 'number', default: 2 }, { key: 'mode', type: 'select', options: ['a', 'b'] }],
  policy: { url: 'https://api.example.workers.dev/v1/plugins/example-site/policy', ttlSeconds: 3600, defaults: { minActionIntervalMs: 3000 } },
  updateUrl: 'https://api.example.workers.dev/v1/plugins/example-site/latest',
  config: { targetPath: '/manage/' },
});

test('valid v1 and v2 manifests pass', () => {
  assert.deepEqual(validateManifest(v1(), exists), []);
  assert.deepEqual(validateManifest(v2(), exists), []);
});

test('required fields', () => {
  const errors = validateManifest({}, exists);
  for (const needle of ['id is required', 'name is required', 'version is required', 'domains must be', 'scripts.main is required']) {
    assert.ok(errors.some((e) => e.includes(needle)), needle);
  }
});

test('id / version / domains formats', () => {
  assert.ok(validateManifest({ ...v1(), id: 'bad id!' }, exists).some((e) => e.includes('id must match')));
  assert.ok(validateManifest({ ...v1(), version: '1.0' }, exists).some((e) => e.includes('version must be semantic')));
  assert.ok(validateManifest({ ...v1(), domains: ['not a domain'] }, exists).some((e) => e.includes('domains[0]')));
  assert.equal(validateManifest({ ...v1(), domains: ['*.example.com'] }, exists).length, 0);
});

test('referenced files must exist', () => {
  assert.ok(validateManifest({ ...v1(), scripts: { main: 'missing.js' } }, exists).some((e) => e.includes('scripts.main not found')));
  assert.ok(validateManifest({ ...v1(), styles: ['nope.css'] }, exists).some((e) => e.includes('styles[0] not found')));
  assert.ok(validateManifest({ ...v2(), background: 'nope.js' }, exists).some((e) => e.includes('background not found')));
  assert.ok(validateManifest({ ...v2(), pages: { s: { file: 'pages/none.html' } } }, exists).some((e) => e.includes('pages.s.file not found')));
});

test('runAt / display / menu type / permissions are enumerated', () => {
  assert.ok(validateManifest({ ...v1(), scripts: { main: 'main.js', runAt: 'later' } }, exists).some((e) => e.includes('scripts.runAt')));
  assert.ok(validateManifest({ ...v2(), pages: { s: { file: 'pages/settings.html', display: 'popup' } } }, exists).some((e) => e.includes('display')));
  assert.ok(validateManifest({ ...v2(), menu: [{ id: 'x', label: 'x', type: 'link' }] }, exists).some((e) => e.includes('menu[0].type')));
  assert.ok(validateManifest({ ...v2(), permissions: ['root'] }, exists).some((e) => e.includes('permissions[0] is unknown')));
  assert.equal(PERMISSIONS.length, 16);
});

test('cross references: menu.page -> pages, pages/menu/policy need their permission', () => {
  assert.ok(validateManifest({ ...v2(), menu: [{ id: 'q', label: 'Q', type: 'page', page: 'queue' }] }, exists).some((e) => e.includes('unknown page: queue')));
  const noPerm = validateManifest({ ...v2(), permissions: ['fetch'] }, exists);
  assert.ok(noPerm.some((e) => e.includes('"pages" permission')));
  assert.ok(noPerm.some((e) => e.includes('"menu" permission')));
  assert.ok(noPerm.some((e) => e.includes('"policy" permission')));
});

test('policy and updateUrl rules', () => {
  const policyErrors = validateManifest({ ...v2(), policy: { url: 'http://x/', ttlSeconds: 10, defaults: [] } }, exists).filter((e) => e.startsWith('policy'));
  assert.equal(policyErrors.length, 3);
  assert.ok(validateManifest({ ...v2(), updateUrl: 'ftp://x' }, exists).some((e) => e.includes('updateUrl')));
});

test('v2-only fields are rejected on format v1', () => {
  const errors = validateManifest({ ...v1(), permissions: ['fetch'], background: 'dist/worker.js' }, exists);
  assert.ok(errors.some((e) => e === 'permissions requires formatVersion 2'));
  assert.ok(errors.some((e) => e === 'background requires formatVersion 2'));
});

test('referencedFiles lists manifest, script, styles, background and pages', () => {
  assert.deepEqual(referencedFiles(v2()), ['plugin.json', 'dist/main.js', 'style.css', 'dist/worker.js', 'pages/settings.html']);
});

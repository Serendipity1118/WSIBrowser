import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, existsSync, readFileSync, rmSync, writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { create, validate, build, pack, collectFiles } from '../src/index.js';

function tmp() {
  return mkdtempSync(join(tmpdir(), 'wsi-plugin-'));
}

test('create substitutes placeholders and yields a valid plugin', async () => {
  const root = tmp();
  try {
    const dir = create('my-plugin', { dir: join(root, 'p'), name: 'My Plugin' });
    const def = JSON.parse(readFileSync(join(dir, 'plugin.json'), 'utf8'));
    assert.equal(def.id, 'my-plugin');
    assert.equal(def.name, 'My Plugin');
    assert.equal(def.formatVersion, 2);
    assert.ok(readFileSync(join(dir, 'README.md'), 'utf8').includes('# My Plugin'));
    assert.ok(!readFileSync(join(dir, 'src', 'main.js'), 'utf8').includes('__NAME__'));
    assert.deepEqual(validate(dir).errors, []);
    assert.throws(() => create('my-plugin', { dir: join(root, 'p') }), /not empty/);
    assert.throws(() => create('bad id', { dir: join(root, 'q') }), /must match/);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('build bundles src/main.js and src/worker.js into dist/', async () => {
  const root = tmp();
  try {
    const dir = create('b', { dir: join(root, 'b') });
    writeFileSync(join(dir, 'src', 'worker.js'), 'import { name } from "./features/example.js"; WSI.log(name);');
    const outputs = await build(dir);
    assert.equal(outputs.length, 2);
    const main = readFileSync(join(dir, 'dist', 'main.js'), 'utf8');
    assert.ok(main.includes('WSI.getConfig()'), 'WSI stays a free variable');
    assert.ok(!main.includes('import '), 'imports are resolved');
    const worker = readFileSync(join(dir, 'dist', 'worker.js'), 'utf8');
    assert.ok(worker.includes('WSI.log'));
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('pack validates, builds and zips referenced files plus pages/ and assets/', async () => {
  const root = tmp();
  try {
    const dir = create('z', { dir: join(root, 'z') });
    mkdirSync(join(dir, 'pages'));
    writeFileSync(join(dir, 'pages', 'settings.html'), '<p>hi</p>');
    writeFileSync(join(dir, 'pages', 'settings.js'), 'console.log(1)');
    mkdirSync(join(dir, 'assets', 'img'), { recursive: true });
    writeFileSync(join(dir, 'assets', 'img', 'a.txt'), 'x');
    const def = JSON.parse(readFileSync(join(dir, 'plugin.json'), 'utf8'));
    def.pages = { settings: { file: 'pages/settings.html', display: 'sheet' } };
    def.permissions = ['storage', 'pages'];
    writeFileSync(join(dir, 'plugin.json'), JSON.stringify(def, null, 2));

    const { zipPath, files } = await pack(dir);
    assert.ok(existsSync(zipPath));
    assert.ok(zipPath.endsWith('z-0.1.0.zip'));
    assert.deepEqual(files, ['assets/img/a.txt', 'dist/main.js', 'pages/settings.html', 'pages/settings.js', 'plugin.json', 'style.css']);
    assert.deepEqual(collectFiles(dir, def), files);

    const { default: JSZip } = await import('jszip');
    const zip = await JSZip.loadAsync(readFileSync(zipPath));
    assert.deepEqual(Object.values(zip.files).filter((f) => !f.dir).map((f) => f.name).sort(), files);
    const stored = JSON.parse(await zip.file('plugin.json').async('string'));
    assert.equal(stored.id, 'z');
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('pack refuses an invalid manifest', async () => {
  const root = tmp();
  try {
    const dir = create('bad', { dir: join(root, 'bad') });
    const def = JSON.parse(readFileSync(join(dir, 'plugin.json'), 'utf8'));
    def.domains = [];
    writeFileSync(join(dir, 'plugin.json'), JSON.stringify(def));
    await assert.rejects(() => pack(dir), /domains must be a non-empty array/);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('publish builds the R2 key and the release SQL', async () => {
  const { r2KeyFor, releaseInsertSql } = await import('../src/publish.js');
  assert.equal(r2KeyFor('pokepara', '2.0.0'), 'plugins/pokepara/2.0.0.zip');
  const sql = releaseInsertSql({ id: 'p', version: '1.0.0', notes: "it's new", key: 'plugins/p/1.0.0.zip' });
  assert.ok(sql.startsWith('INSERT OR REPLACE INTO plugin_releases'));
  assert.ok(sql.includes("'it''s new'"), 'quotes are escaped');
  assert.ok(releaseInsertSql({ id: 'p', version: '1', key: 'k' }).endsWith('NULL);'));
});

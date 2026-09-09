// Programmatic API of wsi-plugin. The CLI (bin/wsi-plugin.js) is a thin wrapper.
import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync, statSync, cpSync } from 'node:fs';
import { join, resolve, relative, dirname, basename, posix } from 'node:path';
import { fileURLToPath } from 'node:url';
import { validateManifest, referencedFiles } from './manifest.js';

export { validateManifest, referencedFiles, PERMISSIONS } from './manifest.js';

const here = dirname(fileURLToPath(import.meta.url));
// The template's source of truth is plugins/_template in the WSIBrowser repo.
// `npm run sync:template` (run automatically by prepack) copies it into this
// package as template/ so the published npm package is self-contained.
const PACKAGED_TEMPLATE = join(here, '..', 'template');
const REPO_TEMPLATE = join(here, '..', '..', '..', 'plugins', '_template');
export const TEMPLATE_DIR = existsSync(PACKAGED_TEMPLATE) ? PACKAGED_TEMPLATE : REPO_TEMPLATE;

/** Read and parse plugin.json in `dir`. */
export function readManifest(dir) {
  const file = join(dir, 'plugin.json');
  if (!existsSync(file)) throw new Error(`plugin.json not found in ${dir}`);
  let def;
  try {
    def = JSON.parse(readFileSync(file, 'utf8'));
  } catch (e) {
    throw new Error(`plugin.json is not valid JSON: ${e.message}`);
  }
  return def;
}

/** Validate the plugin in `dir`. Returns the error list (empty = valid). */
export function validate(dir) {
  const def = readManifest(dir);
  const isFile = (rel) => existsSync(join(dir, rel)) && statSync(join(dir, rel)).isFile();
  // dist/<name>.js is produced by `build`; before the first build accept it when src/<name>.js exists
  const fileExists = (rel) => isFile(rel)
    || (/^dist\/(main|worker)\.js$/.test(rel) && isFile(rel.replace(/^dist\//, 'src/')));
  return { def, errors: validateManifest(def, fileExists) };
}

/**
 * Create a plugin directory from the template.
 * @param {string} id  plugin id ([a-zA-Z0-9-])
 * @param {{dir?: string, name?: string, template?: string}} opts
 */
export function create(id, opts = {}) {
  if (!/^[a-zA-Z0-9-]+$/.test(id)) throw new Error('id must match ^[a-zA-Z0-9-]+$');
  const target = resolve(opts.dir || id);
  if (existsSync(target) && readdirSync(target).length > 0) throw new Error(`${target} already exists and is not empty`);
  const template = opts.template || TEMPLATE_DIR;
  if (!existsSync(template)) throw new Error(`template not found: ${template}`);
  const name = opts.name || id;

  mkdirSync(target, { recursive: true });
  cpSync(template, target, { recursive: true });
  // substitute placeholders in text files
  const walk = (d) => {
    for (const entry of readdirSync(d, { withFileTypes: true })) {
      const p = join(d, entry.name);
      if (entry.isDirectory()) { walk(p); continue; }
      if (!/\.(json|js|css|md|html|txt)$/.test(entry.name)) continue;
      const text = readFileSync(p, 'utf8');
      if (!text.includes('__ID__') && !text.includes('__NAME__')) continue;
      writeFileSync(p, text.replace(/__ID__/g, id).replace(/__NAME__/g, name));
    }
  };
  walk(target);
  return target;
}

/**
 * Bundle src/main.js (and src/worker.js when present) into dist/ with esbuild.
 * A plugin without src/ (format v1 layout: main.js at the root) is left alone.
 */
export async function build(dir, opts = {}) {
  const { build: esbuild } = await import('esbuild');
  const entries = [];
  for (const name of ['main', 'worker']) {
    const src = join(dir, 'src', `${name}.js`);
    if (existsSync(src)) entries.push({ name, src, out: join(dir, 'dist', `${name}.js`) });
  }
  if (entries.length === 0) return [];
  mkdirSync(join(dir, 'dist'), { recursive: true });
  const outputs = [];
  for (const e of entries) {
    await esbuild({
      entryPoints: [e.src],
      bundle: true,
      format: 'iife',
      // plugin code runs inside new Function('WSI', code): WSI is a free variable, keep it global
      target: ['es2019', 'safari15', 'chrome90'],
      platform: 'browser',
      minify: !!opts.minify,
      sourcemap: opts.sourcemap ? 'inline' : false,
      legalComments: 'none',
      outfile: e.out,
      logLevel: 'silent',
    });
    outputs.push(e.out);
  }
  return outputs;
}

/** Everything under pages/ and assets/ plus the referenced files. Returns relative posix paths. */
export function collectFiles(dir, def) {
  const files = new Set(referencedFiles(def));
  const addDir = (sub) => {
    const root = join(dir, sub);
    if (!existsSync(root)) return;
    const walk = (d) => {
      for (const entry of readdirSync(d, { withFileTypes: true })) {
        const p = join(d, entry.name);
        if (entry.isDirectory()) walk(p);
        else files.add(relative(dir, p).split('\\').join('/'));
      }
    };
    walk(root);
  };
  addDir('pages');
  addDir('assets');
  return Array.from(files).map((f) => f.split('\\').join('/')).sort();
}

/**
 * validate + build + zip. Returns { zipPath, files }.
 * @param {string} dir
 * @param {{out?: string, skipBuild?: boolean}} opts
 */
export async function pack(dir, opts = {}) {
  if (!opts.skipBuild) await build(dir, opts);
  const { def, errors } = validate(dir);
  if (errors.length) {
    const e = new Error(`plugin.json is invalid:\n  - ${errors.join('\n  - ')}`);
    e.errors = errors;
    throw e;
  }
  const { default: JSZip } = await import('jszip');
  const zip = new JSZip();
  const files = collectFiles(dir, def);
  for (const rel of files) {
    const abs = join(dir, rel);
    if (!existsSync(abs)) throw new Error(`referenced file missing: ${rel}`);
    zip.file(rel, readFileSync(abs), { date: new Date(0) });
  }
  const buffer = await zip.generateAsync({ type: 'nodebuffer', compression: 'DEFLATE', compressionOptions: { level: 9 } });
  const zipPath = resolve(opts.out || join(dir, 'dist', `${def.id}-${def.version}.zip`));
  mkdirSync(dirname(zipPath), { recursive: true });
  writeFileSync(zipPath, buffer);
  return { zipPath, files, def, buffer };
}

/** posix join helper for URLs */
export const urlJoin = (...parts) => posix.join(...parts);
export { basename };

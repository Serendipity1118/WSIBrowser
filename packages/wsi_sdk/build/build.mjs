// Bundle the SDK core with each adapter into dist/.
//   dist/wsi-sdk-chrome.js        Chrome extension
//   dist/wsi-sdk-inappwebview.js  WSI Browser
//   dist/wsi-sdk-mock.js          contract tests only
import { build } from 'esbuild';
import { readFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..');
const pkg = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
const dist = join(root, 'dist');
mkdirSync(dist, { recursive: true });

const targets = [
  { entry: 'chrome', out: 'wsi-sdk-chrome.js' },
  { entry: 'inappwebview', out: 'wsi-sdk-inappwebview.js' },
  { entry: 'mock', out: 'wsi-sdk-mock.js' },
];

for (const t of targets) {
  await build({
    entryPoints: [join(root, 'src', 'entry', `${t.entry}.js`)],
    bundle: true,
    format: 'iife',
    target: ['es2019', 'safari15', 'chrome90'],
    platform: 'browser',
    minify: false,
    legalComments: 'none',
    outfile: join(dist, t.out),
    banner: {
      js: `/* WSI SDK ${pkg.version} (${t.entry} adapter). Generated from packages/wsi_sdk - do not edit by hand. */`,
    },
    define: { __WSI_SDK_VERSION__: JSON.stringify(pkg.version) },
  });
  console.log(`built dist/${t.out}`);
}

// Copy the Chrome bundle into the WebSystemInjection repository.
//   node build/sync_to_wsi.mjs [--wsi <path>]
// Default path: $WSI_REPO or ../../../WebSystemInjection (sibling of WSIBrowser).
import { copyFileSync, existsSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..');
const args = process.argv.slice(2);
const flag = args.indexOf('--wsi');
const wsi = resolve(flag >= 0 ? args[flag + 1] : process.env.WSI_REPO || join(root, '..', '..', '..', 'WebSystemInjection'));

const src = join(root, 'dist', 'wsi-sdk-chrome.js');
if (!existsSync(src)) {
  console.error('dist/wsi-sdk-chrome.js not found. Run `npm run build` first.');
  process.exit(1);
}
if (!existsSync(join(wsi, 'src', 'manifest.json'))) {
  console.error(`WSI repository not found at ${wsi} (src/manifest.json missing)`);
  process.exit(1);
}
const destDir = join(wsi, 'src', 'sdk');
mkdirSync(destDir, { recursive: true });
const dest = join(destDir, 'wsi-sdk.js');
copyFileSync(src, dest);
console.log(`copied ${src} -> ${dest}`);

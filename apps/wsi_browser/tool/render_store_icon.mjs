// Rasterize assets/brand/logo.svg into the store icons.
//   node tool/render_store_icon.mjs
// Writes assets/brand/store/play-icon-512.png (Google Play) and
// app-store-icon-1024.png (App Store Connect).
//
// Both stores round the corners themselves and neither supports transparency
// (Google Play renders alpha as black, App Store Connect rejects it), so the
// square is drawn full bleed with rx="0" and flattened onto the brand gradient.
// Re-run after editing the SVG.
import { createRequire } from 'node:module';
import { readFileSync, mkdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const app = resolve(here, '..');
const brand = join(app, 'assets', 'brand');
const outDir = join(brand, 'store');
const require = createRequire(resolve(app, '..', '..', 'packages', 'wsi_sdk', 'package.json'));
const { chromium } = require('@playwright/test');

const svg = readFileSync(join(brand, 'logo.svg'), 'utf8');

/** The logo with square corners, so the artwork bleeds to the edges. */
const squared = svg.replace(
  '<rect x="0" y="0" width="1024" height="1024" rx="224" fill="url(#bg)"/>',
  '<rect x="0" y="0" width="1024" height="1024" fill="url(#bg)"/>',
);
if (squared === svg) throw new Error('background rect not found in logo.svg');

async function render(page, markup, out, size) {
  await page.setViewportSize({ width: size, height: size });
  const inner = markup.replace(
    'viewBox="0 0 1024 1024" width="1024" height="1024"',
    `viewBox="0 0 1024 1024" width="${size}" height="${size}"`,
  );
  // No omitBackground: the store icons must be fully opaque.
  await page.setContent(
    `<html><body style="margin:0;background:#2A56C6">${inner}</body></html>`,
  );
  await page.screenshot({ path: out, clip: { x: 0, y: 0, width: size, height: size } });
  console.log('wrote', out);
}

const browser = await chromium.launch();
const page = await browser.newPage();
mkdirSync(outDir, { recursive: true });
await render(page, squared, join(outDir, 'play-icon-512.png'), 512);
await render(page, squared, join(outDir, 'app-store-icon-1024.png'), 1024);
await browser.close();

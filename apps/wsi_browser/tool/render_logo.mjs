// Rasterize assets/brand/logo.svg with the Playwright Chromium of packages/wsi_sdk.
//   node tool/render_logo.mjs
// Writes assets/brand/logo-1024.png (launcher icon source), logo-fg-1024.png
// (adaptive-icon foreground: the artwork on a transparent canvas with safe
// margins) and splash-icon-1024.png (white artwork on transparent, for the
// splash screen). Re-run after editing the SVG.
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const app = resolve(here, '..');
const brand = join(app, 'assets', 'brand');
const require = createRequire(resolve(app, '..', '..', 'packages', 'wsi_sdk', 'package.json'));
const { chromium } = require('@playwright/test');

const svg = readFileSync(join(brand, 'logo.svg'), 'utf8');

/** The artwork without the rounded background (foreground layers). */
function foreground(white) {
  let s = svg.replace(/<rect x="0" y="0" width="1024" height="1024" rx="224" fill="url\(#bg\)"\/>/, '');
  if (white) {
    s = s
      .replace(/fill="url\(#piece\)"/, 'fill="#FFFFFF"')
      .replace(/fill="#2A56C6"/g, 'fill="#FFFFFF" fill-opacity="0.55"')
      .replace(/fill="#4E95FF"/g, 'fill="#FFFFFF" fill-opacity="0.7"')
      .replace(/fill="#9DBEFF"/g, 'fill="#FFFFFF" fill-opacity="0.85"');
  }
  return s;
}

async function render(page, markup, out, { scale = 1, size = 1024 } = {}) {
  await page.setViewportSize({ width: size, height: size });
  const inner = markup.replace('viewBox="0 0 1024 1024" width="1024" height="1024"', `viewBox="0 0 1024 1024" width="${1024 * scale}" height="${1024 * scale}"`);
  const offset = (size - 1024 * scale) / 2;
  await page.setContent(`<html><body style="margin:0;background:transparent"><div style="position:absolute;left:${offset}px;top:${offset}px">${inner}</div></body></html>`);
  await page.screenshot({ path: out, omitBackground: true, clip: { x: 0, y: 0, width: size, height: size } });
  console.log('wrote', out);
}

const browser = await chromium.launch();
const page = await browser.newPage();
mkdirSync(brand, { recursive: true });
await render(page, svg, join(brand, 'logo-1024.png'));
// adaptive icon foreground: Android masks to the inner 66%, so scale the art to ~0.62
await render(page, foreground(false), join(brand, 'logo-fg-1024.png'), { scale: 0.62 });
await render(page, foreground(true), join(brand, 'splash-icon-1024.png'), { scale: 0.7 });
await browser.close();

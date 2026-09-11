// Rasterize the Google Play feature graphic (1024x500) from assets/brand/logo.svg.
//   node tool/render_feature_graphic.mjs
// Writes assets/brand/store/play-feature-1024x500.png.
//
// Google Play crops and scales this image for different placements, so the logo
// and the wordmark stay well inside the middle. No transparency.
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

/** The logo artwork without its own background, so it sits on the banner. */
const artwork = svg
  .replace(/<rect x="0" y="0" width="1024" height="1024" rx="224" fill="url\(#bg\)"\/>/, '')
  .replace(/^<svg[^>]*>/, '')
  .replace(/<\/svg>\s*$/, '');

const banner = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 500" width="1024" height="500">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#4E95FF"/>
      <stop offset="1" stop-color="#2A56C6"/>
    </linearGradient>
    <linearGradient id="piece" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFFFFF"/>
      <stop offset="1" stop-color="#E3ECFF"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="18" stdDeviation="22" flood-color="#0B2A6B" flood-opacity="0.35"/>
    </filter>
  </defs>
  <rect x="0" y="0" width="1024" height="500" fill="url(#bg)"/>
  <g transform="translate(96 90) scale(0.313)">${artwork}</g>
  <text x="450" y="238" fill="#FFFFFF"
    font-family="Arial, Helvetica, sans-serif" font-size="76" font-weight="700"
    letter-spacing="1">WSI Browser</text>
  <text x="452" y="306" fill="#FFFFFF" fill-opacity="0.85"
    font-family="Arial, Helvetica, sans-serif" font-size="34" font-weight="400">
    Bring your own extensions</text>
</svg>`;

const browser = await chromium.launch();
const page = await browser.newPage();
await page.setViewportSize({ width: 1024, height: 500 });
await page.setContent(`<html><body style="margin:0;background:#2A56C6">${banner}</body></html>`);
mkdirSync(outDir, { recursive: true });
const out = join(outDir, 'play-feature-1024x500.png');
await page.screenshot({ path: out, clip: { x: 0, y: 0, width: 1024, height: 500 } });
console.log('wrote', out);
await browser.close();

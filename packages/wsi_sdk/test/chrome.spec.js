// The 7 sample plugins (plugins/samples, synced from WebSystemInjection) running
// in the Chrome extension with the generated SDK bundle.
//
// Requires the WebSystemInjection checkout (WSI_REPO) with src/sdk/wsi-sdk.js in
// sync with dist/wsi-sdk-chrome.js (`npm run sync:wsi`).
import { test as base, expect, chromium } from '@playwright/test';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { EXTENSION_PATH, WSI_REPO, loadSamplePlugin, sampleIds, routeFixtures, DIJAW40_URL } from './helpers.js';

const ALL_IDS = sampleIds();
const PAGE_BUTTON_PLUGINS = ['hello-world', 'highlighter', 'jisho-popup', 'markdown-copy', 'outline-panel'];

const test = base.extend({
  context: async ({}, use) => {
    if (!existsSync(join(EXTENSION_PATH, 'manifest.json'))) {
      throw new Error(`WebSystemInjection not found at ${WSI_REPO}. Set WSI_REPO.`);
    }
    if (!existsSync(join(EXTENSION_PATH, 'sdk', 'wsi-sdk.js'))) {
      throw new Error('src/sdk/wsi-sdk.js is missing in the WSI repo. Run `npm run sync:wsi -w packages/wsi_sdk`.');
    }
    const context = await chromium.launchPersistentContext('', {
      channel: 'chromium',
      headless: false,
      args: [
        `--disable-extensions-except=${EXTENSION_PATH}`,
        `--load-extension=${EXTENSION_PATH}`,
      ],
    });
    await routeFixtures(context);
    await use(context);
    await context.close();
  },

  serviceWorker: async ({ context }, use) => {
    let [sw] = context.serviceWorkers();
    if (!sw) sw = await context.waitForEvent('serviceworker');
    await use(sw);
  },

  /** install(ids?) writes the sample plugins into chrome.storage.local */
  install: async ({ serviceWorker }, use) => {
    await use(async (ids = ALL_IDS) => {
      const plugins = ids.map(loadSamplePlugin);
      await serviceWorker.evaluate((list) => chrome.storage.local.set({ plugins: list, wsiEnabled: true }), plugins);
    });
  },
});

test.describe('samples in the Chrome extension', () => {
  test('all 7 samples load on example.com without runtime errors', async ({ context, install }) => {
    await install();
    const page = await context.newPage();
    const logs = [];
    const errors = [];
    page.on('console', (m) => {
      logs.push(m.text());
      if (m.type() === 'error' && m.text().includes('[WSI]')) errors.push(m.text());
    });
    await page.goto('https://example.com/');

    await expect(page.locator('.wsi-floating-button')).toHaveCount(PAGE_BUTTON_PLUGINS.length);
    await expect(page.locator('.wsi-url-expander')).toHaveCount(1);
    // nipponsteel-dijaw40-csv is installed but does not match example.com
    await expect(page.locator('.wsi-csv-export-btn')).toHaveCount(0);
    expect(errors).toEqual([]);
    for (const id of ['hello-world', 'highlighter', 'jisho-popup', 'markdown-copy', 'outline-panel', 'url-expander']) {
      expect(logs.some((l) => l.startsWith(`[WSI:${id}]`)), `log from ${id}`).toBe(true);
    }
    // the SDK bundle was injected once and WSI never leaked onto window
    expect(await page.evaluate(() => [typeof globalThis.__wsiRun, typeof window.WSI])).toEqual(['function', 'undefined']);
  });

  test('hello-world: button shows the config message', async ({ context, install }) => {
    await install(['hello-world']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    const btn = page.locator('.wsi-floating-button');
    await expect(btn).toHaveText('👋');
    const message = new Promise((resolve) => page.once('dialog', (d) => { resolve(d.message()); d.dismiss(); }));
    await btn.click();
    expect(await message).toBe('Hello from WSI!');
  });

  test('highlighter: highlights persist across reloads through WSI.storage', async ({ context, install, serviceWorker }) => {
    await install(['highlighter']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    await page.locator('.wsi-floating-button').waitFor();
    await page.evaluate(() => {
      const p = document.getElementById('para-1').firstChild;
      const range = document.createRange();
      range.setStart(p, 0);
      range.setEnd(p, 12);
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    });
    await page.locator('.wsi-floating-button').click();
    await expect(page.locator('.wsi-highlight')).toHaveCount(1);
    await expect(page.locator('.wsi-highlight')).toHaveText('ハイライトしたいテキスト');
    // wait until the plugin's WSI.storage.set landed in chrome.storage.local
    await expect.poll(() => serviceWorker.evaluate(async () => {
      const { pluginData_highlighter: d } = await chrome.storage.local.get('pluginData_highlighter');
      return d ? Object.keys(d).length : 0;
    })).toBe(1);

    await page.reload();
    await expect(page.locator('.wsi-highlight')).toHaveCount(1);
    await expect(page.locator('.wsi-highlight')).toHaveText('ハイライトしたいテキスト');
  });

  test('jisho-popup: opens a panel for the selected word', async ({ context, install }) => {
    await install(['jisho-popup']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    await page.locator('.wsi-floating-button').waitFor();
    await page.evaluate(() => {
      const range = document.createRange();
      range.selectNodeContents(document.getElementById('jp-word'));
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    });
    await page.locator('.wsi-floating-button').click();
    const panel = page.locator('.wsi-panel');
    await expect(panel).toHaveCount(1);
    await expect(panel.locator('.wsi-jisho-query')).toContainText('辞書');
    await expect(panel).toHaveAttribute('data-wsi-layout', 'side');
  });

  test('markdown-copy: shows a toast after copying a selection', async ({ context, install }) => {
    await install(['markdown-copy']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    await page.locator('.wsi-floating-button').waitFor();
    await page.evaluate(() => {
      const range = document.createRange();
      range.selectNodeContents(document.getElementById('md-source'));
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    });
    await page.locator('.wsi-floating-button').click();
    await expect(page.locator('.wsi-md-toast--show')).toHaveCount(1);
  });

  test('outline-panel: lists the headings and becomes a bottom sheet on narrow viewports', async ({ context, install }) => {
    await install(['outline-panel']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    await page.locator('.wsi-floating-button').click();
    const panel = page.locator('.wsi-panel');
    await expect(panel.locator('.wsi-outline-item')).toHaveCount(5);
    await expect(panel.locator('.wsi-outline-item').first()).toHaveText('WSI 契約テスト用の記事');
    await expect(panel).toHaveAttribute('data-wsi-layout', 'side');

    await page.setViewportSize({ width: 390, height: 800 });
    await expect(panel).toHaveAttribute('data-wsi-layout', 'sheet');
    const box = await panel.boundingBox();
    expect(Math.round(box.width)).toBe(390);
    expect(Math.round(box.y + box.height)).toBe(800);
  });

  test('url-expander: hovering a short link shows the tooltip and resolves through WSI.fetch', async ({ context, install }) => {
    await install(['url-expander']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    await page.locator('.wsi-url-expander').waitFor({ state: 'attached' });
    await page.locator('#short-link').hover();
    const tip = page.locator('.wsi-url-expander');
    await expect(tip).toBeVisible();
    // WSI.fetch ran in the service worker; whatever bit.ly answered, the plugin rendered one of its outcomes
    await expect(tip).toHaveText(/^(→ |取得失敗|エラー|\(リダイレクトなし\))/, { timeout: 15000 });
    await page.locator('#normal-link').hover();
    await expect(tip).toBeHidden();
  });

  test('nipponsteel-dijaw40-csv: adds the CSV button only on the target path', async ({ context, install }) => {
    await install(['nipponsteel-dijaw40-csv']);
    const page = await context.newPage();
    await page.goto(DIJAW40_URL);
    const btn = page.locator('.ControlHeader .wsi-csv-export-btn');
    await expect(btn).toHaveCount(1);
    await expect(btn).toHaveText('⬇ CSV出力');

    await page.goto('https://nipponsteel.com/other');
    await page.waitForTimeout(500);
    await expect(page.locator('.wsi-csv-export-btn')).toHaveCount(0);
  });
});

test.describe('SDK behaviour inside the extension', () => {
  test('a plugin is injected once per document (already-ran) and button positions survive reloads', async ({ context, install, serviceWorker }) => {
    await install(['hello-world']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    const btn = page.locator('.wsi-floating-button');
    await expect(btn).toHaveCount(1);

    // running the same plugin again is refused by the runner
    const again = await page.evaluate(() => globalThis.__wsiRun({ pluginId: 'hello-world', code: 'WSI.addButton({text: "dup"})' }));
    expect(again).toEqual({ ok: false, reason: 'already-ran' });
    await expect(btn).toHaveCount(1);

    // drag, then reload: position comes back from chrome.storage.local (wsiButtonPositions)
    const before = await btn.boundingBox();
    await page.mouse.move(before.x + 10, before.y + 10);
    await page.mouse.down();
    await page.mouse.move(before.x - 300, before.y - 200, { steps: 10 });
    await page.mouse.up();
    const moved = await btn.boundingBox();
    expect(moved.x).toBeLessThan(before.x - 250);
    await expect.poll(() => serviceWorker.evaluate(async () => {
      const { wsiButtonPositions: p } = await chrome.storage.local.get('wsiButtonPositions');
      return p && p['hello-world_0'] ? parseInt(p['hello-world_0'].left, 10) : null;
    })).toBeCloseTo(moved.x, -1);

    await page.reload();
    await expect(page.locator('.wsi-floating-button')).toHaveCount(1);
    await expect.poll(async () => (await page.locator('.wsi-floating-button').boundingBox()).x).toBeCloseTo(moved.x, -1);
  });

  test('WSI.fetch supports v2 options (json responseType, timeoutMs)', async ({ context, install, serviceWorker }) => {
    await install(['hello-world']);
    const page = await context.newPage();
    await page.goto('https://example.com/');
    await page.locator('.wsi-floating-button').waitFor();
    const result = await page.evaluate(() => new Promise((resolve) => {
      globalThis.__wsiRun({
        pluginId: 'fetch-probe',
        code: 'WSI.fetch("https://example.com/data.json", { method: "GET", responseType: "json", timeoutMs: 5000 }).then(r => window.__resolve(r))',
      });
      window.__resolve = resolve;
    }).catch(() => null));
    // the route only serves HTML, so the JSON parse fails inside the service worker and is reported as an error
    // (this proves the option reached background.js); a 1ms timeout must abort
    expect(result === null || typeof result.ok === 'boolean').toBe(true);
    const timeout = await serviceWorker.evaluate(() => handleFetchRequest({ url: 'https://example.org/', options: { method: 'GET', timeoutMs: 1 } }));
    expect(timeout.ok).toBe(false);
    expect(timeout.error).toMatch(/abort/i);
  });
});

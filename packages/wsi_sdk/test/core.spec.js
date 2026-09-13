// SDK core contract, exercised through the mock adapter (no host involved).
// The same fixture (test/fixtures/core.html) is reused by the Flutter host in P2-15.
import { test, expect } from '@playwright/test';
import { join } from 'node:path';
import { distDir, fixture } from './helpers.js';

const MOCK_BUNDLE = join(distDir, 'wsi-sdk-mock.js');

async function loadCore(page, { viewport } = {}) {
  if (viewport) await page.setViewportSize(viewport);
  await page.route('https://core.test/**', (route) =>
    route.fulfill({ status: 200, contentType: 'text/html; charset=utf-8', body: fixture('core.html') }));
  await page.goto('https://core.test/');
  await page.addScriptTag({ path: MOCK_BUNDLE });
}

/** Run plugin code in the page through globalThis.__wsiRun and return the RunResult. */
function run(page, spec) {
  return page.evaluate((s) => globalThis.__wsiRun(s), spec);
}

const mock = (page) => page.evaluate(() => JSON.parse(JSON.stringify(globalThis.__wsiMock)));

test.describe('runner', () => {
  test('__wsiRun is defined once and rejects invalid specs', async ({ page }) => {
    await loadCore(page);
    expect(await page.evaluate(() => typeof globalThis.__wsiRun)).toBe('function');
    expect(await page.evaluate(() => globalThis.__wsiSdkVersion)).toBe('2.0.0');
    expect(await run(page, {})).toEqual({ ok: false, reason: 'invalid spec' });
    // loading the bundle twice keeps the first runner
    const before = await page.evaluate(() => String(globalThis.__wsiRun));
    await page.addScriptTag({ path: MOCK_BUNDLE });
    expect(await page.evaluate(() => String(globalThis.__wsiRun))).toBe(before);
  });

  test('WSI is passed as an argument, not placed on window', async ({ page }) => {
    await loadCore(page);
    const r = await run(page, { pluginId: 'a', code: 'window.__seen = typeof WSI; window.__pid = WSI._pluginId;' });
    expect(r).toEqual({ ok: true });
    expect(await page.evaluate(() => [window.__seen, window.__pid, typeof window.WSI])).toEqual(['object', 'a', 'undefined']);
  });

  test('a plugin is not executed twice in the same document unless forced', async ({ page }) => {
    await loadCore(page);
    const code = 'window.__count = (window.__count || 0) + 1;';
    expect(await run(page, { pluginId: 'dup', code })).toEqual({ ok: true });
    expect(await run(page, { pluginId: 'dup', code })).toEqual({ ok: false, reason: 'already-ran' });
    expect(await run(page, { pluginId: 'dup', code, force: true })).toEqual({ ok: true });
    expect(await page.evaluate(() => window.__count)).toBe(2);
  });

  test('runtime errors are isolated per plugin and reported', async ({ page }) => {
    await loadCore(page);
    const bad = await run(page, { pluginId: 'bad', code: 'throw new Error("boom")' });
    expect(bad).toEqual({ ok: false, reason: 'boom' });
    const good = await run(page, { pluginId: 'good', code: 'window.__good = true' });
    expect(good).toEqual({ ok: true });
    expect(await page.evaluate(() => window.__good)).toBe(true);
    const state = await mock(page);
    expect(state.logs.some((l) => l.pluginId === 'bad' && l.level === 'error' && l.message.includes('boom'))).toBe(true);
    // a failed plugin may run again (it was not registered as ran)
    expect(await run(page, { pluginId: 'bad', code: 'window.__fixed = 1' })).toEqual({ ok: true });
  });
});

test.describe('getConfig / log / permissions', () => {
  test('getConfig returns a deep copy', async ({ page }) => {
    await loadCore(page);
    await run(page, {
      pluginId: 'cfg',
      config: { a: 1, nested: { b: [1, 2] } },
      code: 'const c = WSI.getConfig(); c.nested.b.push(3); window.__c1 = c; window.__c2 = WSI.getConfig();',
    });
    expect(await page.evaluate(() => [window.__c1.nested.b, window.__c2.nested.b])).toEqual([[1, 2, 3], [1, 2]]);
  });

  test('log goes to console with the plugin prefix and to the adapter', async ({ page }) => {
    await loadCore(page);
    const messages = [];
    page.on('console', (m) => messages.push(m.text()));
    await run(page, { pluginId: 'logger', code: 'WSI.log("hello")' });
    expect(messages).toContain('[WSI:logger] hello');
    const state = await mock(page);
    expect(state.logs).toContainEqual({ pluginId: 'logger', level: 'log', message: 'hello' });
  });

  test('permissions: v1 plugins get storage + fetch, v2 plugins get what they declare (+storage)', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'v1', code: 'window.__v1 = [WSI.permissions.has("storage"), WSI.permissions.has("fetch"), WSI.permissions.has("tabs")]' });
    await run(page, { pluginId: 'v2', permissions: ['tabs'], code: 'window.__v2 = [WSI.permissions.has("storage"), WSI.permissions.has("fetch"), WSI.permissions.has("tabs"), WSI.permissions.list()]' });
    expect(await page.evaluate(() => window.__v1)).toEqual([true, true, false]);
    expect(await page.evaluate(() => window.__v2)).toEqual([true, false, true, ['storage', 'tabs']]);
  });
});

test.describe('storage / fetch', () => {
  test('storage is namespaced per plugin', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'p1', code: 'window.__p1 = WSI.storage.set("k", {v: 1}).then(() => WSI.storage.get("k"))' });
    await run(page, { pluginId: 'p2', code: 'window.__p2 = WSI.storage.get("k")' });
    expect(await page.evaluate(() => window.__p1)).toEqual({ v: 1 });
    expect(await page.evaluate(() => window.__p2)).toBeUndefined();
    await run(page, { pluginId: 'p1', force: true, code: 'window.__all = WSI.storage.set("k2", 2).then(() => WSI.storage.getAll()); window.__rm = window.__all.then(() => WSI.storage.remove("k")).then(() => WSI.storage.getAll())' });
    expect(await page.evaluate(() => window.__all)).toEqual({ k: { v: 1 }, k2: 2 });
    expect(await page.evaluate(() => window.__rm)).toEqual({ k2: 2 });
  });

  test('fetch forwards url and options to the adapter and returns its result', async ({ page }) => {
    await loadCore(page);
    await page.evaluate(() => { globalThis.__wsiMock.fetchResponses.push({ ok: true, status: 200, url: 'https://x/final', redirected: true, body: 'hi' }); });
    await run(page, { pluginId: 'f', code: 'window.__r = WSI.fetch("https://x/short", { method: "GET", responseType: "text", timeoutMs: 500, credentials: "site" })' });
    expect(await page.evaluate(() => window.__r)).toEqual({ ok: true, status: 200, url: 'https://x/final', redirected: true, body: 'hi' });
    const state = await mock(page);
    expect(state.fetchCalls).toEqual([{ url: 'https://x/short', options: { method: 'GET', responseType: 'text', timeoutMs: 500, credentials: 'site' } }]);
  });
});

test.describe('addButton', () => {
  test('renders a 44px+ floating button that handles click', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'btn', code: 'WSI.addButton({ text: "Go", icon: "▶", position: "top-left", onClick: () => { document.title = "clicked"; } })' });
    const btn = page.locator('.wsi-floating-button');
    await expect(btn).toHaveCount(1);
    await expect(btn).toHaveText('▶ Go');
    const box = await btn.boundingBox();
    expect(box.width).toBeGreaterThanOrEqual(44);
    expect(box.height).toBeGreaterThanOrEqual(44);
    expect(box.x).toBeLessThan(100); // top-left
    expect(box.y).toBeLessThan(100);
    await btn.click();
    await expect(page).toHaveTitle('clicked');
  });

  test('drag with pointer events moves the button, persists the position, and suppresses the click', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'drag', code: 'WSI.addButton({ text: "Drag", onClick: () => { document.title = "clicked"; } })' });
    const btn = page.locator('.wsi-floating-button');
    const before = await btn.boundingBox();
    await page.mouse.move(before.x + 10, before.y + 10);
    await page.mouse.down();
    await page.mouse.move(before.x - 200, before.y - 150, { steps: 8 });
    await page.mouse.up();
    const after = await btn.boundingBox();
    expect(Math.round(before.x - after.x)).toBe(210);
    expect(Math.round(before.y - after.y)).toBe(160);
    await expect(page).not.toHaveTitle('clicked');

    const state = await mock(page);
    expect(state.buttonPos['drag_0']).toEqual({ left: `${Math.round(after.x)}px`, top: `${Math.round(after.y)}px` });

    // a second button of the same plugin gets its own index
    await run(page, { pluginId: 'drag', force: true, code: 'WSI.addButton({ text: "B" }); WSI.addButton({ text: "C" });' });
    const idx = await page.locator('.wsi-floating-button').evaluateAll((els) => els.map((e) => e.dataset.wsiButtonIndex));
    expect(idx).toEqual(['0', '0', '1']);
  });

  test('a persisted position is restored and clamped to the viewport', async ({ page }) => {
    await loadCore(page, { viewport: { width: 500, height: 400 } });
    await page.evaluate(() => { globalThis.__wsiMock.buttonPos['restore_0'] = { left: '5000px', top: '30px' }; });
    await run(page, { pluginId: 'restore', code: 'WSI.addButton({ text: "R" })' });
    const btn = page.locator('.wsi-floating-button');
    await expect(btn).toHaveCSS('top', '30px');
    const box = await btn.boundingBox();
    expect(box.x + box.width).toBeLessThanOrEqual(500);
  });
});

test.describe('addPanel', () => {
  const PANEL_CODE = 'window.__panel = WSI.addPanel({ title: "T", width: "320px", position: "right", content: "<p id=\\"pc\\">body</p>", onOpen: () => { window.__opened = true; }, onClose: () => { window.__closed = true; } })';

  test('side panel on wide viewports keeps the 1.x DOM contract', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'panel', code: PANEL_CODE });
    const panel = page.locator('.wsi-panel');
    await expect(panel).toHaveAttribute('data-wsi-layout', 'side');
    const box = await panel.boundingBox();
    expect(Math.round(box.width)).toBe(320);
    expect(Math.round(box.x + box.width)).toBe(1280);
    expect(Math.round(box.height)).toBe(720);
    expect(await page.evaluate(() => [window.__panel.children.length, window.__panel.children[1].querySelector('#pc').textContent, window.__opened])).toEqual([2, 'body', true]);
    await panel.locator('button[aria-label="close"]').click();
    await expect(panel).toHaveCount(0);
    expect(await page.evaluate(() => window.__closed)).toBe(true);
  });

  test('bottom sheet below 600px', async ({ page }) => {
    await loadCore(page, { viewport: { width: 400, height: 700 } });
    await run(page, { pluginId: 'panel', code: PANEL_CODE });
    const panel = page.locator('.wsi-panel');
    await expect(panel).toHaveAttribute('data-wsi-layout', 'sheet');
    const box = await panel.boundingBox();
    expect(Math.round(box.width)).toBe(400);
    expect(Math.round(box.x)).toBe(0);
    expect(Math.round(box.y + box.height)).toBe(700);
    expect(box.height).toBeLessThanOrEqual(700 * 0.7 + 1);
    // resizing to a wide viewport switches back to a side panel
    await page.setViewportSize({ width: 900, height: 700 });
    await expect(panel).toHaveAttribute('data-wsi-layout', 'side');
  });
});

test.describe('onPageLoad', () => {
  test('fires on pushState, popstate and the host urlchange event, once per URL change', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'spa', code: 'window.__urls = []; WSI.onPageLoad((u) => window.__urls.push(u));' });
    await page.evaluate(async () => {
      history.pushState({}, '', '/a');
      document.body.appendChild(document.createElement('div')); // MutationObserver fallback
      await new Promise((r) => setTimeout(r, 50));
      history.pushState({}, '', '/b');
      window.dispatchEvent(new CustomEvent('wsi:urlchange')); // host notification
      await new Promise((r) => setTimeout(r, 50));
      window.dispatchEvent(new CustomEvent('wsi:urlchange')); // same URL: ignored
      history.back();
      await new Promise((r) => setTimeout(r, 100));
    });
    expect(await page.evaluate(() => window.__urls.map((u) => new URL(u).pathname))).toEqual(['/a', '/b', '/a']);
  });
});

test.describe('contexts', () => {
  test('page-only APIs throw in the worker context', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'w', context: 'worker', code: 'window.__ctx = WSI._context; try { WSI.addButton({}); } catch (e) { window.__err = e.message; } window.__s = WSI.storage.set("k", 1)' });
    expect(await page.evaluate(() => window.__ctx)).toBe('worker');
    expect(await page.evaluate(() => window.__err)).toContain('not available');
    expect(await page.evaluate(() => window.__s)).toBe(true);
  });
});

test.describe('v2 API (WSI Browser hosts only)', () => {
  test('namespaces exist only when the adapter declares v2', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'v2', token: 't1', permissions: ['tabs'], code: 'window.__has = [typeof WSI.toast, typeof WSI.settings, typeof WSI.tabs, typeof WSI.policy, typeof WSI.runtime]' });
    expect(await page.evaluate(() => window.__has)).toEqual(['function', 'object', 'object', 'object', 'object']);
    await page.evaluate(() => { globalThis.__wsiMock.v2 = false; });
    await run(page, { pluginId: 'v1host', code: 'window.__none = [typeof WSI.toast, typeof WSI.settings, typeof WSI.tabs]' });
    expect(await page.evaluate(() => window.__none)).toEqual(['undefined', 'undefined', 'undefined']);
  });

  test('calls go through adapter.call with dotted op names and unwrap host errors', async ({ page }) => {
    await loadCore(page);
    await page.evaluate(() => {
      globalThis.__wsiMock.callResponses['settings.get'] = 3;
      globalThis.__wsiMock.callResponses['policy.get'] = { error: 'permission denied' };
      globalThis.__wsiMock.callResponses['dialog'] = 1;
    });
    await run(page, {
      pluginId: 'ops', token: 't2', permissions: ['policy'],
      code: `
        WSI.toast('hi', { duration: 1000 });
        window.__s = WSI.settings.get('n');
        window.__d = WSI.dialog({ title: 'T', message: 'M', buttons: ['OK', 'Cancel'] });
        window.__p = WSI.policy.get('x').catch(e => 'err:' + e.message);
        window.__c = WSI.credentials.set('main', { id: 'u', password: 'p' });
      `,
    });
    expect(await page.evaluate(() => window.__s)).toBe(3);
    expect(await page.evaluate(() => window.__d)).toBe(1);
    expect(await page.evaluate(() => window.__p)).toBe('err:permission denied');
    expect(await page.evaluate(() => window.__c)).toEqual({ ok: true });
    const state = await mock(page);
    const ops = state.calls.map((c) => c.op);
    expect(ops).toEqual(expect.arrayContaining(['toast', 'settings.get', 'dialog', 'policy.get', 'credentials.set']));
    expect(state.calls.find((c) => c.op === 'toast').payload).toEqual({ message: 'hi', duration: 1000 });
  });

  test('app-only information ops and onChange watch / unwatch', async ({ page }) => {
    await loadCore(page);
    await page.evaluate(() => {
      globalThis.__wsiMock.callResponses['device.key'] = 'abc';
      globalThis.__wsiMock.callResponses['biometrics.authenticate'] = { success: false, reason: 'userCanceled' };
    });
    await run(page, {
      pluginId: 'info', token: 'tInfo', permissions: ['device', 'location', 'network', 'battery', 'biometrics'],
      code: `
        window.__k = WSI.device.key();
        WSI.app.info(); WSI.locale.get();
        WSI.location.permission(); WSI.location.request(); WSI.location.getCurrent({ accuracy: 'low', maxAge: 60000 });
        WSI.network.status(); WSI.battery.status(); WSI.biometrics.status();
        window.__b = WSI.biometrics.authenticate('ログインのため');
        window.__net = [];
        const off1 = WSI.network.onChange((s) => window.__net.push(s));
        const off2 = WSI.network.onChange(() => {});
        window.__off = () => { off1(); off1(); off2(); };
        WSI.battery.onChange(() => {});
      `,
    });
    expect(await page.evaluate(() => window.__k)).toBe('abc');
    expect(await page.evaluate(() => window.__b)).toEqual({ success: false, reason: 'userCanceled' });
    await page.evaluate(() => globalThis.__wsiEmit('tInfo', 'network.change', { online: false, types: [] }));
    expect(await page.evaluate(() => window.__net)).toEqual([{ online: false, types: [] }]);
    await page.evaluate(() => window.__off());

    const state = await mock(page);
    const ops = state.calls.map((c) => c.op);
    expect(ops).toEqual(expect.arrayContaining([
      'device.key', 'app.info', 'locale.get', 'location.permission', 'location.request', 'location.getCurrent',
      'network.status', 'battery.status', 'biometrics.status', 'biometrics.authenticate', 'battery.watch',
    ]));
    expect(ops.filter((o) => o === 'network.watch')).toHaveLength(1);
    expect(ops.filter((o) => o === 'network.unwatch')).toHaveLength(1);
    expect(state.calls.find((c) => c.op === 'location.getCurrent').payload).toEqual({ accuracy: 'low', maxAge: 60000 });
    expect(state.calls.find((c) => c.op === 'biometrics.authenticate').payload).toEqual({ reason: 'ログインのため' });
  });

  test('host events reach the right plugin instance through __wsiEmit and reply-style listeners answer', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'a', token: 'tokA', code: 'window.__a = []; WSI.settings.onChange((c) => window.__a.push(c)); WSI.runtime.onMessage((m, s) => { window.__a.push([m, s]); return "reply-from-a"; });' });
    await run(page, { pluginId: 'b', token: 'tokB', permissions: ['tabs'], code: 'window.__b = []; WSI.settings.onChange((c) => window.__b.push(c)); WSI.tabs.onDialog((d) => ({ action: d.type === "confirm" ? "accept" : "show" })); WSI.navigation.intercept((url) => url.includes("deny") ? "deny" : undefined);' });

    const r1 = await page.evaluate(() => globalThis.__wsiEmit('tokA', 'settings.change', { key: 'k', value: 1 }));
    await page.evaluate(() => globalThis.__wsiEmit('tokA', 'runtime.message', { hello: 1 }, { context: 'worker' }));
    expect(await page.evaluate(() => window.__a)).toEqual([{ key: 'k', value: 1 }, [{ hello: 1 }, { context: 'worker' }]]);
    expect(await page.evaluate(() => window.__b)).toEqual([]);
    expect(r1).toBeUndefined();

    expect(await page.evaluate(() => globalThis.__wsiEmit('tokB', 'tabs.dialog', { type: 'confirm', message: 'x' }))).toEqual({ action: 'accept' });
    expect(await page.evaluate(() => globalThis.__wsiEmit('tokB', 'tabs.dialog', { type: 'alert', message: 'x' }))).toEqual({ action: 'show' });
    expect(await page.evaluate(() => globalThis.__wsiEmit('tokB', 'navigation.intercept', 'https://deny.me/'))).toBe('deny');
    expect(await page.evaluate(() => globalThis.__wsiEmit('tokB', 'navigation.intercept', 'https://ok/'))).toBeUndefined();
    expect(await page.evaluate(() => globalThis.__wsiEmit('unknown', 'settings.change', {}))).toBeUndefined();
  });

  test('menu.register keeps callbacks in the page and sends only ids to the host', async ({ page }) => {
    await loadCore(page);
    await run(page, { pluginId: 'm', token: 'tokM', permissions: ['menu'], code: 'window.__sel = []; WSI.menu.register([{ id: "s", label: "Settings", type: "page", page: "settings", onSelect: () => window.__sel.push("s") }, { type: "separator" }, { id: "t", label: "Toggle", type: "toggle", checked: true, onChange: (v) => window.__sel.push(v) }]);' });
    const state = await mock(page);
    const reg = state.calls.find((c) => c.op === 'menu.register');
    expect(reg.payload.items).toEqual([
      { id: 's', label: 'Settings', type: 'page', page: 'settings' },
      { type: 'separator' },
      { id: 't', label: 'Toggle', type: 'toggle', checked: true },
    ]);
    await page.evaluate(() => globalThis.__wsiEmit('tokM', 'menu.select:s', {}));
    await page.evaluate(() => globalThis.__wsiEmit('tokM', 'menu.change:t', false));
    expect(await page.evaluate(() => window.__sel)).toEqual(['s', false]);
  });
});

// WSI SDK core. Host independent; everything privileged goes through an adapter
// (see ../adapters/adapter.d.ts).
//
// Public entry points:
//   createWSI(spec, adapter)      -> the `WSI` object handed to plugin code
//   runPlugin(spec, adapter)      -> evaluates plugin code with `WSI` (new Function('WSI', code))
//   installRunner(adapterFactory) -> defines globalThis.__wsiRun(spec) for the host to call

import { createButton } from './button.js';
import { createPanel } from './panel.js';
import { onPageLoad } from './page_load.js';
import { installV2, createEventBus } from './v2.js';

export { URL_CHANGE_EVENT } from './page_load.js';
export { BOTTOM_SHEET_MAX_WIDTH } from './panel.js';

export const SDK_VERSION = '2.0.0';

/** Permissions implied by a format v1 plugin (no `permissions` field). */
export const V1_PERMISSIONS = Object.freeze(['storage', 'fetch']);

/** Permissions that are always granted. */
const IMPLICIT_PERMISSIONS = new Set(['storage']);

function normalizePermissions(list) {
  const set = new Set(IMPLICIT_PERMISSIONS);
  for (const p of Array.isArray(list) ? list : V1_PERMISSIONS) {
    if (typeof p === 'string') set.add(p);
  }
  return set;
}

function deepCopy(value) {
  return value === undefined ? undefined : JSON.parse(JSON.stringify(value));
}

/**
 * @param {import('../adapters/adapter').RunSpec} spec
 * @param {import('../adapters/adapter').WSIAdapter} adapter
 */
export function createWSI(spec, adapter, events = createEventBus()) {
  const pluginId = spec.pluginId;
  const config = spec.config || {};
  const context = spec.context || 'page';
  const permissions = normalizePermissions(spec.permissions);
  const inPage = context === 'page';

  let buttonCount = 0;

  const log = (message) => {
    const text = String(message);
    console.log(`[WSI:${pluginId}] ${text}`);
    if (typeof adapter.log === 'function') {
      try { adapter.log('log', text); } catch { /* ignore */ }
    }
  };

  const host = { adapter, log };

  const notAvailable = (name) => () => {
    throw new Error(`WSI.${name} is not available in the '${context}' context`);
  };

  const WSI = {
    _pluginId: pluginId,
    _config: config,
    _context: context,
    _version: SDK_VERSION,

    addButton: inPage
      ? (options) => createButton(host, buttonCount++, options)
      : notAvailable('addButton'),

    addPanel: inPage
      ? (options) => createPanel(host, options)
      : notAvailable('addPanel'),

    onPageLoad: inPage ? onPageLoad : notAvailable('onPageLoad'),

    storage: {
      get: (key) => adapter.storage.get(key),
      set: (key, value) => adapter.storage.set(key, value),
      remove: (key) => adapter.storage.remove(key),
      getAll: () => adapter.storage.getAll(),
    },

    fetch: (url, options) => adapter.fetch(String(url), options || {}),

    getConfig: () => deepCopy(config),

    log,

    permissions: {
      has: (name) => permissions.has(name),
      list: () => Array.from(permissions),
    },
  };

  if (adapter.v2 === true) {
    installV2(WSI, adapter, events);
  }

  return WSI;
}

/**
 * Evaluate plugin code with a fresh WSI object. Errors are caught per plugin so
 * one broken plugin cannot take the others (or the host) down.
 *
 * @returns {import('../adapters/adapter').RunResult}
 */
export function runPlugin(spec, adapter, events) {
  const WSI = createWSI(spec, adapter, events);
  try {
    const fn = new Function('WSI', spec.code);
    fn(WSI);
    if (typeof adapter.onRun === 'function') adapter.onRun();
    return { ok: true };
  } catch (e) {
    console.error(`[WSI] Plugin runtime error (${spec.pluginId}):`, e);
    if (typeof adapter.log === 'function') {
      try { adapter.log('error', `Plugin runtime error: ${e && e.message ? e.message : e}`); } catch { /* ignore */ }
    }
    return { ok: false, reason: e && e.message ? e.message : String(e) };
  }
}

const RAN_KEY = '__wsiRanPlugins';

/**
 * Define globalThis.__wsiRun(spec). Idempotent: loading the bundle twice keeps
 * the first definition and the per-document "already ran" registry.
 *
 * @param {import('../adapters/adapter').AdapterFactory} adapterFactory
 */
export function installRunner(adapterFactory) {
  const g = globalThis;
  if (typeof g.__wsiRun === 'function') return g.__wsiRun;

  const ran = new Set();
  Object.defineProperty(g, RAN_KEY, { value: ran, enumerable: false, configurable: true });

  // token -> event bus, so the host can push events to a specific plugin instance
  const buses = new Map();

  const run = (spec) => {
    if (!spec || typeof spec.pluginId !== 'string' || typeof spec.code !== 'string') {
      return { ok: false, reason: 'invalid spec' };
    }
    if (!spec.force && ran.has(spec.pluginId)) {
      return { ok: false, reason: 'already-ran' };
    }
    const adapter = adapterFactory({
      pluginId: spec.pluginId,
      token: spec.token,
      context: spec.context || 'page',
    });
    ran.add(spec.pluginId);
    const events = createEventBus();
    if (spec.token) buses.set(spec.token, events);
    const result = runPlugin(spec, adapter, events);
    if (!result.ok) {
      ran.delete(spec.pluginId);
      if (spec.token) buses.delete(spec.token);
    }
    return result;
  };

  /**
   * Host -> plugin event. Returns a Promise of the first listener's reply
   * (used by reply-style events such as tabs.dialog and navigation.intercept).
   */
  const emit = (token, event, payload, sender) => {
    const bus = buses.get(token);
    if (!bus) return Promise.resolve(undefined);
    return bus.emit(event, payload, sender);
  };

  Object.defineProperty(g, '__wsiRun', { value: run, enumerable: false, configurable: true });
  Object.defineProperty(g, '__wsiEmit', { value: emit, enumerable: false, configurable: true });
  Object.defineProperty(g, '__wsiSdkVersion', { value: SDK_VERSION, enumerable: false, configurable: true });
  return run;
}

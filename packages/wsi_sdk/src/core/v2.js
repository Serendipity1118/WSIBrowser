// v2 API surface (WSI Browser only). Added to the WSI object when the adapter
// declares `v2: true`; the Chrome extension leaves these undefined so plugins
// branch with WSI.permissions.has(...) (要件定義「後方互換」).
//
// Every call goes through adapter.call(op, payload) and resolves with whatever
// the host returns. Host -> plugin events (settings changes, runtime messages,
// suspend / resume, tab events) arrive through globalThis.__wsiEmit(token, event, payload),
// installed by the runner, and are dispatched to the listeners registered here.

/**
 * @param {object} WSI  the object being built
 * @param {import('../adapters/adapter').WSIAdapter} adapter
 * @param {object} events  per-plugin event bus { on(event, cb), emit(event, payload) }
 */
export function installV2(WSI, adapter, events) {
  const call = (op, payload) => adapter.call(op, payload);
  const unwrap = async (op, payload) => {
    const r = await call(op, payload);
    if (r && typeof r === 'object' && 'error' in r && Object.keys(r).length <= 2) {
      throw new Error(String(r.error));
    }
    return r;
  };

  // UI
  WSI.toast = (message, options) => { call('toast', { message: String(message), ...(options || {}) }); };
  WSI.dialog = (options) => unwrap('dialog', options || {});
  WSI.ui = {
    openPage: (name, params) => unwrap('ui.openPage', { name, params: params || {} }),
    openUrl: (url, options) => unwrap('ui.openUrl', { url: String(url), ...(options || {}) }),
    closePage: () => { call('ui.closePage', {}); },
  };

  // Settings (plugin.json settingsSchema)
  WSI.settings = {
    get: (key) => unwrap('settings.get', { key }),
    set: (key, value) => unwrap('settings.set', { key, value }),
    getAll: () => unwrap('settings.getAll', {}),
    onChange: (cb) => events.on('settings.change', cb),
  };

  // Policy
  WSI.policy = {
    get: (key) => unwrap('policy.get', { key }),
    getAll: () => unwrap('policy.getAll', {}),
    refresh: () => unwrap('policy.refresh', {}),
  };

  // Menu
  WSI.menu = {
    register: (items) => {
      const list = Array.isArray(items) ? items : [];
      // callbacks stay in the page; the host only gets ids
      for (const item of list) {
        if (item && item.id) {
          if (typeof item.onSelect === 'function') events.on(`menu.select:${item.id}`, item.onSelect);
          if (typeof item.onChange === 'function') events.on(`menu.change:${item.id}`, item.onChange);
        }
      }
      return unwrap('menu.register', {
        items: list.map((i) => ({ id: i.id, label: i.label, icon: i.icon, type: i.type, page: i.page, checked: i.checked })),
      });
    },
    update: (id, patch) => unwrap('menu.update', { id, ...(patch || {}) }),
  };

  // Messaging and lifecycle
  WSI.runtime = {
    sendMessage: (message) => unwrap('runtime.sendMessage', { message }),
    onMessage: (cb) => events.on('runtime.message', cb, { reply: true }),
    onSuspend: (cb) => events.on('runtime.suspend', cb),
    onResume: (cb) => events.on('runtime.resume', cb),
  };

  // Tabs (worker only; the host rejects other contexts)
  WSI.tabs = {
    open: (url, options) => unwrap('tabs.open', { url, ...(options || {}) }),
    navigate: (tabId, url) => unwrap('tabs.navigate', { tabId, url }),
    run: (tabId, code) => unwrap('tabs.run', { tabId, code: String(code) }),
    close: (tabId) => unwrap('tabs.close', { tabId }),
    list: () => unwrap('tabs.list', {}),
    onLoad: (cb) => events.on('tabs.load', (p) => cb(p.tabId, p.url, p.error)),
    onClose: (cb) => events.on('tabs.close', (p) => cb(p.tabId)),
    /**
     * Dialogs of tabs this worker opened. Android runs every WebView in one
     * renderer, so a blocking alert() in a tab also freezes this worker: the
     * host cannot wait for [cb] there and answers with `options.default`
     * ('accept' | 'dismiss' | 'show', default 'accept') right away, then
     * delivers the event to [cb] afterwards. iOS asks [cb] first.
     */
    onDialog: (cb, options) => {
      call('tabs.dialogPolicy', { action: (options && options.default) || 'accept' });
      return events.on('tabs.dialog', cb, { reply: true });
    },
  };

  // Native features
  WSI.credentials = {
    set: (profile, value) => unwrap('credentials.set', { profile, value }),
    get: (profile) => unwrap('credentials.get', { profile }),
    remove: (profile) => unwrap('credentials.remove', { profile }),
    list: () => unwrap('credentials.list', {}),
  };
  WSI.device = {
    id: () => unwrap('device.id', {}),
    info: () => unwrap('device.info', {}),
    // same value for this plugin on this device, unrelated between plugins
    key: () => unwrap('device.key', {}),
  };
  WSI.share = (options) => unwrap('share', options || {});
  WSI.files = {
    save: (name, data, options) => unwrap('files.save', { name, data, ...(options || {}) }),
    pick: (options) => unwrap('files.pick', options || {}),
  };
  WSI.clipboard = {
    write: (text) => unwrap('clipboard.write', { text: String(text) }),
    read: () => unwrap('clipboard.read', {}),
  };
  WSI.wakeLock = { acquire: () => unwrap('wakeLock.acquire', {}), release: () => unwrap('wakeLock.release', {}) };
  WSI.pip = { enter: () => unwrap('pip.enter', {}), exit: () => unwrap('pip.exit', {}), isSupported: () => unwrap('pip.isSupported', {}) };
  WSI.blockResources = (options) => unwrap('blockResources', options || {});
  WSI.siteData = { clear: (options) => unwrap('siteData.clear', options || {}) };
  WSI.navigation = {
    intercept: (cb) => events.on('navigation.intercept', cb, { reply: true }),
  };

  // App and system information
  WSI.app = { info: () => unwrap('app.info', {}) };
  WSI.locale = { get: () => unwrap('locale.get', {}) };
  WSI.location = {
    permission: () => unwrap('location.permission', {}),
    request: () => unwrap('location.request', {}),
    getCurrent: (options) => unwrap('location.getCurrent', options || {}),
  };
  WSI.network = { status: () => unwrap('network.status', {}), onChange: watched('network', 'network.change') };
  WSI.battery = { status: () => unwrap('battery.status', {}), onChange: watched('battery', 'battery.change') };
  WSI.biometrics = {
    status: () => unwrap('biometrics.status', {}),
    authenticate: (options) => unwrap('biometrics.authenticate', typeof options === 'string' ? { reason: options } : options || {}),
  };

  // onChange(cb) for host streams: the host is asked to watch while at least one listener exists.
  function watched(family, event) {
    return (cb) => {
      if (typeof cb !== 'function') return () => {};
      const off = events.on(event, cb);
      if (events.count(event) === 1) call(`${family}.watch`, {});
      let removed = false;
      return () => {
        if (removed) return;
        removed = true;
        off();
        if (events.count(event) === 0) call(`${family}.unwatch`, {});
      };
    };
  }
}

/** Minimal event bus: listeners per event name; `emit` returns the first reply for reply-style events. */
export function createEventBus() {
  const listeners = new Map();
  return {
    on(event, cb, options) {
      if (typeof cb !== 'function') return () => {};
      const list = listeners.get(event) || [];
      const entry = { cb, reply: !!(options && options.reply) };
      list.push(entry);
      listeners.set(event, list);
      return () => {
        const l = listeners.get(event) || [];
        const i = l.indexOf(entry);
        if (i >= 0) l.splice(i, 1);
      };
    },
    async emit(event, payload, sender) {
      const list = listeners.get(event) || [];
      let reply;
      for (const entry of list) {
        try {
          const r = await entry.cb(payload, sender);
          if (entry.reply && reply === undefined && r !== undefined) reply = r;
        } catch (e) {
          console.error(`[WSI] listener error (${event}):`, e);
        }
      }
      return reply;
    },
    count(event) {
      return (listeners.get(event) || []).length;
    },
  };
}

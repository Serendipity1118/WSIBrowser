// flutter_inappwebview adapter (WSI Browser).
//
// Single bridge handler 'wsi'. Every call is
//   window.flutter_inappwebview.callHandler('wsi', { token, op, payload })
// and resolves with whatever the Dart side returns. The token was issued by
// the host for this injection and maps to (pluginId, WebView, permissions);
// the page never names its own pluginId.
//
// Ops used by the core (the host's bridge_ops/registry.dart must implement them):
//   storage.get {key} / storage.set {key, value} / storage.remove {key} / storage.getAll {}
//   fetch {url, options}
//   buttonPos.get {index} / buttonPos.set {index, position}
//   log {level, message}
// Any other op is forwarded as-is (v2 APIs: toast, dialog, policy.get, tabs.open, ...).

const HANDLER = 'wsi';
const READY_EVENT = 'flutterInAppWebViewPlatformReady';

let readyPromise = null;

function whenReady() {
  if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
    return Promise.resolve();
  }
  if (!readyPromise) {
    readyPromise = new Promise((resolve) => {
      window.addEventListener(READY_EVENT, () => resolve(), { once: true });
    });
  }
  return readyPromise;
}

/** @type {import('./adapter').AdapterFactory} */
export function createInAppWebViewAdapter({ token }) {
  const call = async (op, payload) => {
    await whenReady();
    try {
      const result = await window.flutter_inappwebview.callHandler(HANDLER, { token, op, payload: payload ?? {} });
      return result;
    } catch (e) {
      return { error: e && e.message ? e.message : String(e) };
    }
  };

  return {
    storage: {
      get: (key) => call('storage.get', { key }),
      set: (key, value) => call('storage.set', { key, value }),
      remove: (key) => call('storage.remove', { key }),
      getAll: () => call('storage.getAll', {}),
    },

    fetch: (url, options) => call('fetch', { url, options: options || {} }),

    buttonPos: {
      get: (index) => call('buttonPos.get', { index }),
      set: (index, position) => call('buttonPos.set', { index, position }),
    },

    call,

    log: (level, message) => { call('log', { level, message }); },
  };
}

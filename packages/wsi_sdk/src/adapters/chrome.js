// Chrome extension adapter.
//
// Plugin code runs in the page's MAIN world and cannot touch chrome.* APIs.
// Every request is posted to window and answered by the content script
// (src/content-loader.js in the WebSystemInjection repo), which talks to
// chrome.storage.local and the service worker. Message shapes are unchanged
// from WSI 1.x so the existing content script keeps working.

// The content script (document_idle) can be installed slightly after the
// service worker injected the plugin ("complete" fires first on fast pages), so
// a request posted too early has no listener yet. Re-post it until it is
// answered; all bridge operations are idempotent.
const RETRY_INTERVAL_MS = 250;
const MAX_ATTEMPTS = 40; // 10 s

function request(type, resultType, fields) {
  return new Promise((resolve) => {
    const id = `wsi_${Date.now()}_${Math.random()}`;
    const message = { type, id, ...fields };
    let attempts = 0;
    let timer = null;

    const handler = (e) => {
      if (e.source !== window) return;
      if (e.data && e.data.type === resultType && e.data.id === id) {
        window.removeEventListener('message', handler);
        clearTimeout(timer);
        resolve(e.data.result);
      }
    };
    window.addEventListener('message', handler);

    const post = () => {
      attempts += 1;
      window.postMessage(message, '*');
      if (attempts < MAX_ATTEMPTS) {
        timer = setTimeout(post, RETRY_INTERVAL_MS);
      } else {
        window.removeEventListener('message', handler);
        resolve(type === 'WSI_FETCH_REQUEST' ? { error: 'WSI bridge unavailable', ok: false, status: 0 } : undefined);
      }
    };
    post();
  });
}

/** @type {import('./adapter').AdapterFactory} */
export function createChromeAdapter({ pluginId }) {
  const storageRequest = (action, key, value) =>
    request('WSI_STORAGE_REQUEST', 'WSI_STORAGE_RESULT', { pluginId, action, key, value });

  return {
    storage: {
      get: (key) => storageRequest('get', key),
      set: (key, value) => storageRequest('set', key, value),
      remove: (key) => storageRequest('remove', key),
      getAll: () => storageRequest('getAll'),
    },

    fetch: (url, options) =>
      request('WSI_FETCH_REQUEST', 'WSI_FETCH_RESULT', { url, options: options || {} }),

    buttonPos: {
      get: (buttonIndex) =>
        request('WSI_BUTTON_POS_REQUEST', 'WSI_BUTTON_POS_RESULT', {
          action: 'get', pluginId, buttonIndex,
        }),
      set: (buttonIndex, position) =>
        request('WSI_BUTTON_POS_REQUEST', 'WSI_BUTTON_POS_RESULT', {
          action: 'set', pluginId, buttonIndex, position,
        }),
    },

    // v2 operations are not available in the Chrome extension.
    call: (op) => Promise.resolve({ error: `unsupported op in chrome: ${op}` }),
  };
}

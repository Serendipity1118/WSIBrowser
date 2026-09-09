// In-memory adapter for the contract tests (test/core.spec.js).
//
// State lives on globalThis.__wsiMock so a test can inspect what the plugin
// stored, seed fetch responses, and read the log.

export function getMockState() {
  const g = globalThis;
  if (!g.__wsiMock) {
    g.__wsiMock = {
      storage: {},        // pluginId -> { key: value }
      buttonPos: {},      // `${pluginId}_${index}` -> { left, top }
      fetchResponses: [], // queue of results returned by fetch()
      fetchCalls: [],     // [{ url, options }]
      calls: [],          // [{ op, payload }]
      logs: [],           // [{ pluginId, level, message }]
      runs: [],           // pluginIds that ran
    };
  }
  return g.__wsiMock;
}

/** @type {import('./adapter').AdapterFactory} */
export function createMockAdapter({ pluginId }) {
  const state = getMockState();
  const store = () => (state.storage[pluginId] ||= {});

  return {
    storage: {
      get: async (key) => store()[key],
      set: async (key, value) => { store()[key] = value; return true; },
      remove: async (key) => { delete store()[key]; return true; },
      getAll: async () => ({ ...store() }),
    },

    fetch: async (url, options) => {
      state.fetchCalls.push({ url, options });
      if (state.fetchResponses.length) return state.fetchResponses.shift();
      return { ok: true, status: 200, url, redirected: false, body: '' };
    },

    buttonPos: {
      get: async (index) => state.buttonPos[`${pluginId}_${index}`] || null,
      set: async (index, position) => { state.buttonPos[`${pluginId}_${index}`] = position; return true; },
    },

    call: async (op, payload) => {
      state.calls.push({ op, payload });
      return { ok: true };
    },

    log: (level, message) => { state.logs.push({ pluginId, level, message }); },

    onRun: () => { state.runs.push(pluginId); },
  };
}

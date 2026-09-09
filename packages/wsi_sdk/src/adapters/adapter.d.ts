/**
 * WSI SDK adapter contract.
 *
 * The SDK core (src/core) is host independent. Everything that needs a
 * privileged host (storage, network, button positions, native features)
 * goes through an adapter. Two adapters exist:
 *
 * - chrome.js        : Chrome extension. window.postMessage -> content script -> chrome.storage / service worker
 * - inappwebview.js  : WSI Browser (Flutter). window.flutter_inappwebview.callHandler('wsi', {token, op, payload})
 *
 * A third adapter (mock.js) is an in-memory implementation used by the contract tests.
 */

export type RunContext = 'page' | 'plugin-page' | 'worker';

export interface AdapterContext {
  /** Plugin ID from plugin.json */
  pluginId: string;
  /**
   * Per-injection token issued by the host. The Chrome adapter does not use it
   * (the content script trusts the page it lives in). The inappwebview adapter
   * sends it with every call so the host can map the call back to a plugin.
   */
  token?: string;
  context: RunContext;
}

export interface FetchOptions {
  /** Default 'HEAD' (kept for compatibility with WSI 1.x) */
  method?: string;
  redirect?: 'follow' | 'manual' | 'error';
  headers?: Record<string, string>;
  body?: string;
  /** v2: 'site' sends the site's cookies, 'omit' sends none. Default 'omit'. */
  credentials?: 'site' | 'omit';
  /** v2: how the body is returned. Default 'text'. 'arraybuffer' is delivered as base64 in `body` with bodyEncoding 'base64'. */
  responseType?: 'text' | 'json' | 'arraybuffer';
  /** v2: abort after this many milliseconds */
  timeoutMs?: number;
}

export interface FetchResult {
  ok: boolean;
  status: number;
  url?: string;
  redirected?: boolean;
  body?: unknown;
  bodyEncoding?: 'base64';
  error?: string;
}

export interface ButtonPosition {
  left: string;
  top: string;
}

export interface WSIAdapter {
  /** true when the host implements the v2 ops (WSI Browser). The Chrome adapter leaves it unset so v2 namespaces stay undefined. */
  v2?: boolean;
  /** Key/value store scoped to the plugin (pluginData_<id> in Chrome, plugin_data table in WSI Browser). */
  storage: {
    get(key: string): Promise<unknown>;
    set(key: string, value: unknown): Promise<boolean>;
    remove(key: string): Promise<boolean>;
    getAll(): Promise<Record<string, unknown>>;
  };
  /** Network request executed by the host, bypassing the page's CSP / CORS. */
  fetch(url: string, options: FetchOptions): Promise<FetchResult>;
  /** Persisted drag position of addButton() buttons, keyed by button index within the plugin. */
  buttonPos: {
    get(index: number): Promise<ButtonPosition | null>;
    set(index: number, position: ButtonPosition): Promise<boolean>;
  };
  /**
   * Generic v2 operation. `op` is a dotted name such as 'toast', 'policy.get', 'tabs.open'.
   * The host rejects unknown ops and ops the plugin has no permission for
   * with { error: 'permission denied' } / { error: 'unknown op' }.
   * The Chrome adapter rejects everything (v2 ops are not available in the extension).
   */
  call(op: string, payload?: unknown): Promise<unknown>;
  /** Optional: forward WSI.log() to the host's log screen. */
  log?(level: 'log' | 'error', message: string): void;
  /** Optional: called when the plugin was executed (used by hosts that keep an injection registry). */
  onRun?(): void;
}

export type AdapterFactory = (ctx: AdapterContext) => WSIAdapter;

/** Argument of globalThis.__wsiRun(spec), evaluated by the host after the SDK bundle is loaded. */
export interface RunSpec {
  pluginId: string;
  /** plugin.json config */
  config?: Record<string, unknown>;
  /** main.js source */
  code: string;
  /** plugin.json permissions (v2). Missing means format v1: storage only. */
  permissions?: string[];
  token?: string;
  context?: RunContext;
  /** Re-run even if the plugin already ran in this document. */
  force?: boolean;
}

export interface RunResult {
  ok: boolean;
  /** 'already-ran' when deduplicated, otherwise the error message */
  reason?: string;
}

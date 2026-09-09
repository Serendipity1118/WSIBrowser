// Bundle entry for WSI Browser (flutter_inappwebview).
// Output: dist/wsi-sdk-inappwebview.js -> copied to apps/wsi_browser/assets/sdk/wsi-sdk-core.js
// The host registers this as a UserScript (AT_DOCUMENT_START) and later evaluates
// globalThis.__wsiRun({ pluginId, token, config, code, permissions, context }).
import { installRunner } from '../core/index.js';
import { createInAppWebViewAdapter } from '../adapters/inappwebview.js';

installRunner(createInAppWebViewAdapter);

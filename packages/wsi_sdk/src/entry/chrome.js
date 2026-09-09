// Bundle entry for the Chrome extension (WebSystemInjection).
// Output: dist/wsi-sdk-chrome.js -> copied to <WSI repo>/src/sdk/wsi-sdk.js
// The service worker injects this file into the MAIN world, then calls
// globalThis.__wsiRun({ pluginId, config, code, permissions }).
import { installRunner } from '../core/index.js';
import { createChromeAdapter } from '../adapters/chrome.js';

installRunner(createChromeAdapter);

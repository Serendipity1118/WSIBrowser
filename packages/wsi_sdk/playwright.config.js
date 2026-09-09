// Contract tests for the WSI SDK.
//   test/core.spec.js   : SDK core + mock adapter (no host)
//   test/chrome.spec.js : the 7 sample plugins running in the Chrome extension (WebSystemInjection)
// Set WSI_REPO to the WebSystemInjection checkout (default: ../../../WebSystemInjection).
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './test',
  timeout: 30000,
  retries: 0,
  workers: 1,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    headless: false,
    viewport: { width: 1280, height: 720 },
    actionTimeout: 10000,
    screenshot: 'only-on-failure',
  },
});

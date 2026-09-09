// Test-only binding injected by vitest.config.ts (miniflare.bindings).
declare namespace Cloudflare {
  interface Env {
    TEST_MIGRATIONS: import('@cloudflare/vitest-pool-workers').D1Migration[];
  }
}

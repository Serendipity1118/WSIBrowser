# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

WSI Browser: a Flutter (iOS / Android) browser that hosts "plugins" (ZIP bundles of `plugin.json` + JS + CSS) and injects them into matching sites, the mobile counterpart of the Chrome extension [WebSystemInjection](https://github.com/Serendipity1118/WebSystemInjection). The host knows nothing about any specific site. Site-specific plugins live in private repositories; this repository is PUBLIC.

Specs: [doc/要件定義.md](doc/要件定義.md) (requirements), [doc/実装プラン.md](doc/実装プラン.md) (phased plan with per-phase completion records in section 4), [doc/plugin-guide.md](doc/plugin-guide.md) (plugin developer guide).

## Hard rules

- Never reference Firebase or the existing pokePlus app's backend. `tools/check_no_firebase.ps1` (also in CI) fails the build on `firebase`, `firestore`, `pokeplus-6e417`, `jp.serendipy.pokeplus` in tracked non-doc files.
- No site-specific selectors, URLs or logic in this repository. Put them in the private plugin repository.
- `packages/wsi_sdk/dist/*` and the copies in `WebSystemInjection/src/sdk/wsi-sdk.js` and `apps/wsi_browser/assets/sdk/wsi-sdk-core.js` are generated. Edit `packages/wsi_sdk/src`, then `npm run build:sdk`, `npm run sync:wsi -w packages/wsi_sdk`, and copy `dist/wsi-sdk-inappwebview.js` to the Flutter assets.
- Bump `plugin.json` `version` whenever a plugin ZIP is rebuilt; bump WSI's `manifest.json` when its bundle changes.
- App icon and splash come from `apps/wsi_browser/assets/brand/logo.svg`: `node tool/render_logo.mjs` (Playwright Chromium) → `dart run flutter_launcher_icons` → `dart run flutter_native_splash:create`. Do not edit the generated mipmap / drawable / xcassets files by hand. Store icons (Google Play 512, App Store 1024) come from the same SVG via `node tool/render_store_icon.mjs` into `assets/brand/store/`; they are square and opaque because neither store supports transparency.
- Commits are one per phase (see the plan); do not push unless asked.

## Layout

```
apps/wsi_browser/     Flutter host (jp.serendipy.wsibrowser, iOS 15+, Android 8+)
apps/api/             Cloudflare Workers + D1 + R2 (policy, latest, feedback, ZIP distribution, QR page)
packages/wsi_sdk/     SDK core (JS) + adapters (chrome, inappwebview, mock) + Playwright contract tests
packages/wsi_plugin_tools/  `wsi-plugin` CLI: create / validate / build / pack / dev-serve / publish
plugins/_template     scaffold; plugins/samples (synced from WSI); banner-demo (P3); cruise-demo (P4, M2)
tools/                sync_wsi_samples.ps1, check_no_firebase.ps1
codemagic.yaml        iOS builds (no local iOS toolchain: the dev machine is Windows)
```

## Commands

```
npm install                          # workspaces
npm run build:sdk && npm run test:sdk    # SDK bundles + contract tests (test:chrome needs ../WebSystemInjection)
npm run test:tools                   # CLI tests (node --test)
npm test -w apps/api                 # backend tests on workerd (vitest 4 + @cloudflare/vitest-pool-workers)
npm run check:no-firebase
cd apps/wsi_browser
  flutter gen-l10n && dart run build_runner build --delete-conflicting-outputs
  flutter analyze && flutter test
  node integration_test/gen_samples.mjs   # after changing plugins/samples, banner-demo or cruise-demo (build them first)
  flutter test integration_test/samples_test.dart -d <device>   # M1 + M2 on an Android emulator (~35 s)
```

Deploy the API from `apps/api` with `npm run migrate:remote` and `npm run deploy` (account develop@serendipy.jp, worker `wsi-api`).

## Architecture in one screen

- The browser layer (`apps/wsi_browser/lib/browser`) never imports the runtime. It exposes `WebViewTabHooks` (user scripts, load events, wsi:// links, request interception) and `AppMenuSource`; `lib/runtime/runtime.dart` (PluginRuntime) plugs into them from `main.dart`.
- Every plugin call is `window.flutter_inappwebview.callHandler('wsi', { token, op, payload })`. `runtime/bridge.dart` validates token → WebView → installed + enabled → domain (page context) → op → permission → context, then dispatches to `bridge_ops/*` (one file per op family; new native features are one file + an entry in `kAllPermissions`).
- Host → plugin events go through `globalThis.__wsiEmit(token, event, payload)` (settings.change, runtime.message, tabs.*, navigation.intercept, menu.*).
- Injection: the SDK core is a document-start UserScript; `document_start/end` plugins are guarded UserScripts; `document_idle` plugins run from onLoadStop via `__wsiRun(spec)`. The SDK refuses to run the same plugin twice per document.
- Workers: `runtime/worker_manager.dart` runs `background` scripts in a HeadlessInAppWebView at `wsi://plugin/<id>/__worker.html`; `runtime/tab_controller.dart` implements `WSI.tabs`.
- Plugin pages: `wsi://plugin/<id>/<path>` served from the `plugin_files` table by `runtime/page_host.dart`; `window.WSI` is provided at document start.

## Things learned the hard way

- flutter_inappwebview hands a *different* controller object to every callback: identify WebViews by a key (tab id / `worker:<id>` / `wtab:<n>`), never by controller identity.
- Android runs every WebView in one renderer: a pending `alert()` in a hidden tab freezes the worker's JS too, so `tabs.onDialog` answers with the declared default immediately and notifies the worker afterwards.
- A second `loadUrl` on a HeadlessInAppWebView never started loading on Android (API 36) and is ignored on iOS: `tabs.navigate` recreates the WebView.
- Android fires `onUpdateVisitedHistory` before `onLoadStop`; SPA injection is skipped while `tab.isLoading`.
- On fast pages the Chrome content script (document_idle) can attach after the plugin ran; the chrome adapter re-posts bridge requests until answered.
- `WSI.addButton` / `WSI.addPanel` stay in the light DOM (samples style them with page CSS); host-drawn v2 UI uses Flutter widgets.
- `flutter test integration_test` and `adb install` can reset the app's database (developer mode goes back to OFF) before manual dev-serve imports.
- Bash heredocs with long JS / Dart or Japanese content sometimes fail in this environment; write files with the Write tool instead.
- Do not dispose a dialog's `TextEditingController` right after `showDialog` returns, and do not look up inherited widgets in `dispose()`: both end in the red `'_dependents.isEmpty'` screen. Use `ui/text_prompt_dialog.dart` for text input dialogs.

## Conventions

- Dart: `flutter analyze` clean, tests next to the feature under `test/`, l10n strings in all four `.arb` files (ja default, en, ko, zh).
- JS (SDK, CLI): ESM, no build step for the CLI, esbuild for bundles; contract tests are the source of truth for SDK behaviour.
- Docs are in Japanese; code comments and commit bodies may be either.

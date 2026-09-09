# apps/wsi_browser

WSI Browser の Flutter ホスト。プラグインの種類を知らない汎用ブラウザ。

- Application ID / Bundle ID: `jp.serendipy.wsibrowser`
- 対応 OS: iOS 15 以上、Android 8 (API 26) 以上。compileSdk 37
- WebView: flutter_inappwebview 6 / DB: drift / HTTP: dio
- SDK コア: `assets/sdk/wsi-sdk-core.js` は `packages/wsi_sdk` の `dist/wsi-sdk-inappwebview.js` をコピーしたもの (手で編集しない)

## 構成 (P5 時点)

```
lib/
  main.dart               起動 (AppServices + PluginRuntime + AppLinksHandler)
  app/                    app.dart (MaterialApp, i18n), app_scope.dart (DI), bootstrap.dart, app_links_handler.dart (wsi://, 他アプリから開く)
  browser/                tab_manager, web_view_tab (WebViewTabHooks), url_bar, browser_screen, tab_switcher,
                          navigation_policy, js_dialogs, cookie_store, file_chooser
  runtime/                manifest (検証), importer (ZIP), repository (一覧・照合), domain_matcher,
                          injector (UserScript / 注入), bridge (トークン・op ディスパッチ), log_sink,
                          update_checker, dev_reloader, policy_cache, page_host (wsi://), menu_bus,
                          worker_manager (Headless ワーカー), tab_controller (WSI.tabs), resource_blocker,
                          backup, runtime (ファサード)
  bridge_ops/             registry + storage / fetch / log / ui / settings / policy / menu / runtime / tabs /
                          credentials / native (device, share, files, clipboard, wakeLock, pip) / block_resources。
                          新機能は 1 ファイル追加
  settings/               host_settings.dart
  db/                     database.dart (drift スキーマ v1), open_database.dart
  ui/                     start_page, host_settings_page, plugin_list_page, import_page, log_page,
                          plugin_settings_page, start_plugin_summary, permission_labels
  l10n/                   app_ja / app_en / app_ko / app_zh (.arb)。既定 ja
integration_test/         samples_test.dart (M1: 7 サンプル), fixtures.dart, samples_data.g.dart (gen_samples.mjs で生成)
```

ブラウザ層はプラグインを知らない。ランタイムは `WebViewTabHooks` と `AppServices.extras['runtime']` で接続する。

## コマンド

```
flutter pub get
flutter gen-l10n                                   # lib/l10n/generated
dart run build_runner build --delete-conflicting-outputs   # lib/db/database.g.dart
flutter analyze
flutter test
flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk
node integration_test/gen_samples.mjs                           # plugins/samples を埋め込み直す
flutter test integration_test/samples_test.dart -d <device>     # M1 結合テスト (エミュレーター / 実機)
```

SDK を更新したら `packages/wsi_sdk` で `npm run build` し、`dist/wsi-sdk-inappwebview.js` を `assets/sdk/wsi-sdk-core.js` にコピーする。

開発中のプラグインは `npx wsi-plugin dev-serve <dir>` で配信し、設定で開発者モードを ON にしてから `wsi://install?url=https://<PC>:8443/plugin.zip` を開く (Android エミュレーターからは 10.0.2.2)。

iOS はローカルでビルドできない (Windows)。リポジトリルートの `codemagic.yaml` (ios-unsigned / ios-appstore) で Codemagic がビルドし TestFlight に配信する。

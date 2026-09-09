# apps/wsi_browser

WSI Browser の Flutter ホスト。プラグインの種類を知らない汎用ブラウザ。

- Application ID / Bundle ID: `jp.serendipy.wsibrowser`
- 対応 OS: iOS 15 以上、Android 8 (API 26) 以上。compileSdk 37
- WebView: flutter_inappwebview 6 / DB: drift / HTTP: dio
- SDK コア: `assets/sdk/wsi-sdk-core.js` は `packages/wsi_sdk` の `dist/wsi-sdk-inappwebview.js` をコピーしたもの (手で編集しない)

## 構成 (P1 時点)

```
lib/
  main.dart               起動
  app/                    app.dart (MaterialApp, i18n), app_scope.dart (DI), bootstrap.dart
  browser/                tab_manager, web_view_tab, url_bar, browser_screen, tab_switcher,
                          navigation_policy (https->http 読み直し, 外部リンク), js_dialogs,
                          cookie_store (Cookie 共有 / 消去, UA), file_chooser (ダウンロード)
  settings/               host_settings.dart (host_settings テーブルの typed ラッパー)
  db/                     database.dart (drift スキーマ v1), open_database.dart
  ui/                     start_page.dart, host_settings_page.dart
  l10n/                   app_ja / app_en / app_ko / app_zh (.arb)。既定 ja
```

P2 以降のランタイムは `browser/web_view_tab.dart` の `WebViewTabHooks` (UserScript、onLoadStart / onLoadStop / onUpdateVisitedHistory、wsi:// リンク) と `AppServices.isPluginHost` から接続する。

## コマンド

```
flutter pub get
flutter gen-l10n                                   # lib/l10n/generated
dart run build_runner build --delete-conflicting-outputs   # lib/db/database.g.dart
flutter analyze
flutter test
flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

iOS はローカルでビルドできない (Windows)。リポジトリルートの `codemagic.yaml` (ios-unsigned / ios-appstore) で Codemagic がビルドし TestFlight に配信する。

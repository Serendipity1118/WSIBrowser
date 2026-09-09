# apps/wsi_browser

WSI Browser の Flutter ホスト。P1 (ホスト骨格) で `flutter create` により生成する。

- Bundle ID / Application ID: `jp.serendipy.wsibrowser`
- 対応 OS: iOS 15 以上、Android 8 (API 26) 以上
- WebView: flutter_inappwebview 6 系
- SDK コア: `assets/sdk/wsi-sdk-core.js` は `packages/wsi_sdk` のビルド成果物をコピーする (手で編集しない)

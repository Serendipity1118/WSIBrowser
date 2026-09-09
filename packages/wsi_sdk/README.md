# @wsi/sdk

WSI SDK のコア。Chrome 拡張版 [WebSystemInjection](https://github.com/Serendipity1118/WebSystemInjection) と WSI Browser (Flutter) が同じソースから生成したバンドルを使う。

```
src/core/        ホスト非依存の SDK 本体
  index.js         createWSI / runPlugin / installRunner (globalThis.__wsiRun)
  button.js        WSI.addButton  (Pointer Events、44px タップ領域、safe area)
  panel.js         WSI.addPanel   (600px 未満はボトムシート)
  page_load.js     WSI.onPageLoad (wsi:urlchange イベント + popstate + MutationObserver)
  v2.js            v2 API (toast / dialog / settings / policy / menu / runtime / tabs / ネイティブ機能)。
                   アダプタが v2: true のときだけ生える。Chrome では未定義のまま
src/adapters/    ホストごとの特権操作
  adapter.d.ts     アダプタ契約 (storage / fetch / buttonPos / call / log)
  chrome.js        window.postMessage -> content script (WSI 1.x と同じメッセージ形式、再送あり)
  inappwebview.js  window.flutter_inappwebview.callHandler('wsi', {token, op, payload})
  mock.js          契約テスト用のインメモリ実装
src/entry/       バンドルのエントリ (core + adapter)
build/           esbuild でバンドル、WSI リポジトリへのコピー
test/            契約テスト (Playwright)
```

## コマンド

```
npm run build          # dist/wsi-sdk-{chrome,inappwebview,mock}.js
npm run sync:wsi       # dist/wsi-sdk-chrome.js -> <WSI repo>/src/sdk/wsi-sdk.js  (WSI_REPO で場所を指定可)
npm run test:core      # SDK コア + mock アダプタ (ホスト不要)
npm run test:chrome    # Chrome 拡張で plugins/samples の 7 サンプルを実行 (WSI リポジトリが必要)
npm test               # 両方
```

初回は `npm run playwright:install` で Chromium を入れる。

## ホストとの契約

1. ホストはバンドルをページの MAIN ワールド (Chrome) / UserScript (WSI Browser) として読み込む。`globalThis.__wsiRun(spec)` が定義される
2. プラグインごとに `__wsiRun({ pluginId, config, code, permissions, token, context })` を評価する。戻り値は `{ ok }` または `{ ok: false, reason }` (`already-ran` は同一ドキュメントでの二重実行)
3. `WSI` は `new Function('WSI', code)` の引数として渡し、`window` には置かない
4. SPA 遷移をホストが検知したら `window.dispatchEvent(new CustomEvent('wsi:urlchange'))` を発火する (WSI Browser は `onUpdateVisitedHistory` から)
5. `permissions` 未指定 (形式 v1) は `storage` + `fetch` とみなす
6. v2 の API は `adapter.call(op, payload)` に集約され、ホストは `{error}` で拒否を返す。ホストからプラグインへのイベントは `globalThis.__wsiEmit(token, event, payload)` で届き、`settings.change` / `runtime.message` / `tabs.dialog` / `navigation.intercept` などは対応するリスナーに配られる (返答が必要なイベントは最初のリスナーの戻り値を返す)

`WSI.addButton` / `WSI.addPanel` はサンプルプラグインが CSS と DOM 構造 (`panel.children[1]` など) に依存しているため、Shadow DOM ではなく light DOM に描画する。ホストが描く v2 の UI (toast / dialog) は Shadow DOM を使う。

## 変更の流れ

`src/core` を変更 → `npm test` → `npm run sync:wsi` → WSI リポジトリで e2e (`npm run test:e2e`) と `manifest.json` の version 更新 → WSI Browser 側は `apps/wsi_browser/assets/sdk/wsi-sdk-core.js` にコピー (P1 以降)。

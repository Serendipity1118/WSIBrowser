# Cruise Demo

WSI Browser / WSI (Chrome) 向けプラグイン。

## 開発

```
npx wsi-plugin validate      # plugin.json と参照ファイルの検証
npx wsi-plugin build         # src/ を esbuild で dist/ に束ねる
npx wsi-plugin pack          # 検証 + ビルド + ZIP (dist/cruise-demo-<version>.zip)
npx wsi-plugin dev-serve     # HTTPS でこの PC から配信し、開発者モードの WSI Browser で受け取る
```

## 構成

- `plugin.json` : マニフェスト (プラグイン形式 v2)
- `src/main.js` : `location.pathname` を見て features を振り分けるだけ
- `src/features/*.js` : 1 機能 1 ファイル。`name` / `matches(path)` / `run(WSI, ctx)` を export する
- `style.css` : 注入する CSS
- `dist/` : ビルド成果物 (git 管理しない)

## バージョン

ZIP を作り直すときは必ず `plugin.json` の `version` を上げる (patch / minor / major)。

# @wsi/plugin-tools

プラグイン開発 CLI `wsi-plugin`。公開プラグイン (このリポジトリの `plugins/`) と非公開プラグイン (別リポジトリ) の両方から devDependency として使う。

```
wsi-plugin create <id> [--dir <path>] [--name <name>]   雛形 (plugins/_template) から生成
wsi-plugin validate [dir]                                plugin.json を検証 (要件定義の検証表)
wsi-plugin build [dir] [--minify] [--sourcemap]          src/main.js と src/worker.js を esbuild で dist/ に束ねる
wsi-plugin pack [dir] [--out <file>]                     validate + build + ZIP (dist/<id>-<version>.zip)
wsi-plugin dev-serve [dir] [--port 8443] [--host <ip>]   自己署名 HTTPS で配信。QR と wsi://install?url= リンクを表示
wsi-plugin publish [dir]                                 (PB-07 で実装) R2 に置き plugin_releases に登録
```

ZIP には `plugin.json`、`scripts.main`、`styles`、`background`、`pages.*.file` と `pages/`、`assets/` 配下の全ファイルが入る。`src/` は入らない。

## dev-serve のエンドポイント

| パス | 内容 |
|---|---|
| `/` | インストールリンク付きの簡易ページ |
| `/plugin.zip` | ZIP (ソース変更後の初回アクセスで再パック) |
| `/plugin.json` | マニフェスト |
| `/latest` | `{ id, version, zipUrl, notes }` (更新チェックの応答と同じ形) |

証明書は起動ごとに生成する自己署名。WSI Browser の開発者モードで受け入れる (P2)。

## 開発

```
npm test                 # node --test (validate / create / build / pack)
npm run sync:template    # plugins/_template を template/ にコピー (npm publish 前に prepack で自動実行)
```

`template/` は git 管理しない。雛形の正は `plugins/_template`。

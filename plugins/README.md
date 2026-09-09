# plugins/

公開してよいプラグインと雛形だけを置く。1 ディレクトリ = 1 プラグイン。サイト固有プラグインは非公開リポジトリで管理し、ここには置かない。

| ディレクトリ | 内容 |
|---|---|
| `_template/` | `wsi-plugin create` の雛形 |
| `samples/` | Chrome 版 WSI の samples を `tools/sync_wsi_samples.ps1` で取り込んだもの (契約テスト用。手で編集しない) |
| `banner-demo/` | (P3) pages と menu の検証用 |
| `cruise-demo/` | (P4) ワーカーと tabs の検証用 |

## プラグインの内部規約

- `src/main.js` は `location.pathname` を見て `src/features/*` の `matches` と照合し、一致した feature の `run(WSI, ctx)` を呼ぶだけにする
- 機能は `src/features/` に 1 機能 1 ファイル
- `wsi-plugin build` が esbuild で `src/main.js` (と `src/worker.js`) を `dist/` に束ね、`plugin.json` の `scripts.main` は `dist/main.js` を指す

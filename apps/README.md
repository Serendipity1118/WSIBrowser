# apps/

| ディレクトリ | 内容 | 状態 |
|---|---|---|
| `wsi_browser/` | Flutter ホストアプリ (`jp.serendipy.wsibrowser`)。プラグインの種類を知らない汎用ブラウザ | P1 で作成 |
| `api/` | Cloudflare Workers + D1 + R2。ポリシー配信、更新情報、フィードバック、プラグイン ZIP 配信 | PB で作成 |

ホストへの変更が必要なのは新しいネイティブ機能を足すときだけで、`wsi_browser/lib/bridge_ops/` に 1 ファイル追加し `registry.dart` に追記する形に限定する (実装プラン第 2 章)。

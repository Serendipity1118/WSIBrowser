# WSIBrowser

**WSI Browser** — Web System Injection のスマートフォン版 (iOS / Android)。

Chrome 拡張版 [WebSystemInjection](https://github.com/Serendipity1118/WebSystemInjection) と同じプラグイン形式・SDK を、flutter_inappwebview ベースの自前ブラウザで動かす汎用ホストです。サイト固有の機能はすべてプラグイン (ZIP) として別配布し、アプリ本体はプラグインの種類を知りません。

## 構成

| ディレクトリ | 内容 |
|---|---|
| `apps/wsi_browser/` | Flutter ホストアプリ (`jp.serendipy.wsibrowser`) |
| `apps/api/` | Cloudflare Workers + D1 (ポリシー配信、更新情報、フィードバック) |
| `packages/wsi_sdk/` | SDK コア (JS)。Chrome 版 WSI と共有 |
| `packages/wsi_plugin_tools/` | プラグイン開発 CLI |
| `plugins/` | プラグイン開発ディレクトリ (1 ディレクトリ = 1 プラグイン) |
| `tools/` | サンプル同期、バックエンド参照検査 |
| `doc/` | 要件定義、実装プラン |

## 開発

```
npm install                 # workspaces (packages/*, apps/api)
npm run build:sdk           # SDK バンドルを生成
npm run test:sdk            # SDK 契約テスト (Playwright。Chrome 版は ../WebSystemInjection が必要)
npm run test:tools          # プラグイン CLI のテスト
npm run sync:samples        # WSI の samples を plugins/samples に取り込む
npm run check:no-firebase   # Firebase / 既存アプリ参照の検査 (CI でも実行)
npx wsi-plugin --help       # プラグイン CLI
npm test -w apps/api        # バックエンドのテスト (workerd)
```

進捗は [doc/実装プラン.md](doc/実装プラン.md) のフェーズ表を参照。

## ドキュメント

- [doc/要件定義.md](doc/要件定義.md) — 機能要件、プラグイン形式 v2、SDK API、バックエンド
- [doc/実装プラン.md](doc/実装プラン.md) — Flutter 実装のフェーズ別タスクと完了記録
- [doc/plugin-guide.md](doc/plugin-guide.md) — プラグイン開発ガイド (雛形から公開まで、SDK リファレンス)

## 絶対条件

- ホストはサイト固有の知識を持たない。サイト固有プラグインは非公開リポジトリで管理し、本リポジトリには含めない
- 既存アプリのバックエンド (Firebase 等) には一切アクセスしない・依存しない
- バックエンドは Firebase ではなく Cloudflare Workers + D1 を使う

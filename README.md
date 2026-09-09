# WSIBrowser

**WSI Browser** — Web System Injection のスマートフォン版 (iOS / Android)。

Chrome 拡張版 [WebSystemInjection](https://github.com/Serendipity1118/WebSystemInjection) と同じプラグイン形式・SDK を、flutter_inappwebview ベースの自前ブラウザで動かす汎用ホストです。サイト固有の機能はすべてプラグイン (ZIP) として別配布し、アプリ本体はプラグインの種類を知りません。

## 構成 (予定)

| ディレクトリ | 内容 |
|---|---|
| `apps/wsi_browser/` | Flutter ホストアプリ (`jp.serendipy.wsibrowser`) |
| `apps/api/` | Cloudflare Workers + D1 (ポリシー配信、更新情報、フィードバック) |
| `packages/wsi_sdk/` | SDK コア (JS)。Chrome 版 WSI と共有 |
| `packages/wsi_plugin_tools/` | プラグイン開発 CLI |
| `plugins/` | プラグイン開発ディレクトリ (1 ディレクトリ = 1 プラグイン) |
| `doc/` | 要件定義、移植プラン |

## ドキュメント

- [doc/要件定義.md](doc/要件定義.md) — 機能要件、プラグイン形式 v2、SDK API、バックエンド
- [doc/実装プラン.md](doc/実装プラン.md) — Flutter 実装のフェーズ別タスク

## 絶対条件

- ホストはサイト固有の知識を持たない。サイト固有プラグインは非公開リポジトリで管理し、本リポジトリには含めない
- 既存アプリのバックエンド (Firebase 等) には一切アクセスしない・依存しない
- バックエンドは Firebase ではなく Cloudflare Workers + D1 を使う

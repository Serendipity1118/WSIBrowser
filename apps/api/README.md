# apps/api

Cloudflare Workers + D1 + R2 のバックエンド (要件定義 F-13)。本番: https://wsi-api.pokeplus-dev.workers.dev

| リソース | 名前 | バインディング |
|---|---|---|
| Worker | `wsi-api` | - |
| D1 | `wsi-api` | `wsi_api` |
| R2 | `wsi-plugins` (非公開) | `wsi_plugins` |
| 静的アセット | `public/` | `ASSETS` |

## エンドポイント

| パス | 内容 |
|---|---|
| `GET /v1/plugins/:id/policy` | `{ pluginId, values, updatedAt }` (plugin_policies) |
| `GET /v1/plugins/:id/latest` | `{ id, version, zipUrl, notes, releasedAt }` (plugin_releases の最新版) |
| `GET /v1/plugins/:id/releases/:version.zip` | R2 の ZIP (登録済みの版のみ) |
| `POST /v1/feedback` | `{ pluginId, device?, body }` → 201。4096 バイト、IP ハッシュ単位で 10 分 5 件 |
| `GET /p/:id`, `GET /p/:id/qr.svg` | 配布ページと QR (`wsi://install?url=...`) |
| `GET /health`, `GET /` | 死活確認、案内ページ |

認証は当面なし。書き込みは feedback と、開発者の wrangler 経由の publish だけ。既存アプリのバックエンド (Firebase 等) には一切アクセスしない。

## コマンド

```
npm run dev              # wrangler dev (ローカル D1 / R2)
npm run migrate:local    # ローカル D1 にマイグレーション
npm run migrate:remote   # 本番 D1 にマイグレーション
npm test                 # vitest (workerd 上で実行)
npm run typecheck        # tsc
npm run types            # wrangler types -> worker-configuration.d.ts (wrangler.jsonc 変更後)
npm run deploy           # wrangler deploy
```

ポリシー値の登録は D1 に直接行う:

```
npx wrangler d1 execute wsi-api --remote --command "INSERT OR REPLACE INTO plugin_policies (plugin_id, key, value) VALUES ('pokepara', 'minActionIntervalMs', '3000')"
```

プラグインの公開は `npx wsi-plugin publish <dir> --notes "..."` (packages/wsi_plugin_tools)。

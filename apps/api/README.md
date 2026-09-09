# apps/api

Cloudflare Workers + D1 + R2 のバックエンド。PB (バックエンド) で実装する。

| リソース | 名前 | バインディング |
|---|---|---|
| Worker | `wsi-api` | - |
| D1 | `wsi-api` | `wsi_api` |
| R2 | `wsi-plugins` (非公開) | `wsi_plugins` |

エンドポイント (要件定義 F-13):

- `GET /v1/plugins/:id/policy`
- `GET /v1/plugins/:id/latest`
- `GET /v1/plugins/:id/releases/:version.zip` (R2 から返す)
- `POST /v1/feedback` (レート制限)
- 静的アセット: 配布ページ (QR と `wsi://install?url=` リンク)

認証は当面なし。既存アプリのバックエンド (Firebase 等) には一切アクセスしない。

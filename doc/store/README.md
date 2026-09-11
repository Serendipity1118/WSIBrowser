# ストア素材

Google Play と App Store の掲載に必要なものと、その置き場所。

## この中のファイル

| ファイル | 内容 |
| --- | --- |
| [listing-ja.md](listing-ja.md) | 日本語の掲載文 (アプリ名、簡単な説明、詳しい説明、キーワードなど) |
| [listing-en.md](listing-en.md) | 英語の掲載文 |
| [review-notes.md](review-notes.md) | 審査ノート。プラグイン方式の説明と、想定される指摘への答え |
| [screenshots.md](screenshots.md) | スクリーンショットの撮り方と、どの画面を撮るか |

画像は `apps/wsi_browser/assets/brand/store/` にある。すべて `logo.svg` から生成する。

| ファイル | 用途 | サイズ |
| --- | --- | --- |
| `play-icon-512.png` | Google Play のアプリアイコン | 512 x 512 |
| `play-feature-1024x500.png` | Google Play のフィーチャーグラフィック | 1024 x 500 |
| `app-store-icon-1024.png` | App Store のアプリアイコン | 1024 x 1024 |
| `screenshots/android-ja/*.png` | Play のスマートフォン用スクリーンショット (日本語、5 枚) | 1080 x 1920 |

### 画像の作り直し

```
cd apps/wsi_browser
node tool/render_store_icon.mjs        # アイコン 2 種
node tool/render_feature_graphic.mjs   # フィーチャーグラフィック
```

どちらも `packages/wsi_sdk` の Playwright Chromium を使うので、先に `npm install` が要る。
角丸と透過を持たせないのは、ストア側が角丸を付け、透過に対応しないため。
Google Play は透過部分を黒く塗り、App Store Connect は透過を含む画像を弾く。

## Google Play に必要なもの

| 項目 | 状態 |
| --- | --- |
| アプリ名 (30 文字以内) | [listing-ja.md](listing-ja.md) |
| 簡単な説明 (80 文字以内) | 同上 |
| 詳しい説明 (4000 文字以内) | 同上 |
| アプリアイコン 512 x 512 | `play-icon-512.png` |
| フィーチャーグラフィック 1024 x 500 | `play-feature-1024x500.png` |
| スマートフォンのスクリーンショット 2〜8 枚 | [screenshots.md](screenshots.md) |
| プライバシーポリシー URL | <https://wsi-api.pokeplus-dev.workers.dev/privacy> (公開済み) |
| データセーフティ | 下の表のとおり申告する |
| コンテンツレーティング | アンケートに回答する |
| ターゲット層と広告 | 13 歳以上、広告なし |

### データセーフティの申告内容

本アプリは利用者のデータを収集も共有もしない。申告は次のようになる。

| 質問 | 回答 |
| --- | --- |
| アプリはユーザーデータを収集または共有するか | いいえ |
| データは転送時に暗号化されるか | はい (通信はすべて HTTPS) |
| ユーザーはデータの削除をリクエストできるか | 該当なし (収集していない)。端末内のデータはアプリの削除で消える |

閲覧履歴やプラグインの設定は端末内にのみ保存され、当方のサーバーへは送られない。
プラグインが指定した URL への通信は発生しうるが、その通信先はプラグインの製作者が
決めるものであり、アプリ自身が利用者のデータを送るわけではない。詳しくは
[review-notes.md](review-notes.md) を参照。

## App Store に必要なもの

| 項目 | 状態 |
| --- | --- |
| 名前、サブタイトル、キーワード、説明 | [listing-en.md](listing-en.md) と [listing-ja.md](listing-ja.md) |
| アプリアイコン 1024 x 1024 | `app-store-icon-1024.png` |
| スクリーンショット (6.9 インチと 6.5 インチ) | [screenshots.md](screenshots.md) |
| プライバシーポリシー URL | Google Play と同じ <https://wsi-api.pokeplus-dev.workers.dev/privacy> |
| App Privacy (Nutrition Label) | 「データを収集しません」を選ぶ |
| 審査ノート | [review-notes.md](review-notes.md) の英語版 |
| 年齢制限 | 17+ (制限のないウェブアクセスがあるため。ブラウザは通常この扱いになる) |

## 絶対に守ること

- **特定サイトの名前を出さない。** 掲載文、スクリーンショット、審査ノートのすべてで。
  このリポジトリは公開で、ストアの掲載内容も公開される
- スクリーンショットにデバッグ表示や、私的なサイトの画面を写さない

## プライバシーポリシーの公開

本文は `apps/api/public/privacy.html`。`apps/api` の静的アセットなので、
`cd apps/api && npm run deploy` で公開される。**末尾の `.html` は落ちる**ので、
登録する URL は `/privacy` のほう。`/privacy.html` は 307 で `/privacy` に転送される。

<https://wsi-api.pokeplus-dev.workers.dev/privacy> (2026-09-11 公開)

将来カスタムドメインに移すときは、両ストアに登録した URL も差し替えること。

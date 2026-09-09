# プラグイン開発ガイド

WSI Browser (iOS / Android) と Chrome 拡張版 WSI の両方で動くプラグインを、雛形の生成から公開まで一通り説明する。ホストの仕様は [要件定義.md](要件定義.md)、ホスト側の作業計画は [実装プラン.md](実装プラン.md) を参照。

## 1. 前提

- Node.js 20 以上 (`wsi-plugin` CLI と esbuild)
- 公開してよいプラグインは WSIBrowser リポジトリの `plugins/` に、サイト固有のものは非公開リポジトリに置く。公開リポジトリには対象サイトのセレクタや URL など固有情報を置かない
- 端末側は WSI Browser の「設定 → 開発者モード」を ON にする (自己署名 HTTPS と `wsi://dev` を許可する)

## 2. 雛形を作る

```
npx wsi-plugin create my-plugin --name "My Plugin"      # 公開: plugins/my-plugin、非公開: 別リポジトリ
cd my-plugin
```

生成物:

```
plugin.json          マニフェスト (形式 v2)
src/main.js          location.pathname で features を振り分けるだけ
src/features/*.js    1 機能 1 ファイル。name / matches(path) / run(WSI, ctx) を export
src/worker.js        (任意) ワーカー。WSI.tabs などバックグラウンド処理
pages/               (任意) プラグインページ (Vanilla HTML / CSS / JS)
style.css            注入する CSS
dist/                wsi-plugin build の出力 (git 管理しない)
```

feature の形:

```js
export const name = 'csv-export';
export function matches(path) { return path.startsWith('/manage/'); }
export function run(WSI, ctx) {
  WSI.addButton({ text: 'CSV', onClick: () => WSI.log('clicked') });
}
```

`src/main.js` は雛形のままで、`features` 配列に 1 行足すだけにする。

## 3. plugin.json

```json
{
  "formatVersion": 2,
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "0.1.0",
  "domains": ["example.com", "*.example.com"],
  "paths": ["/manage/**"],
  "scripts": { "main": "dist/main.js", "runAt": "document_idle" },
  "styles": ["style.css"],
  "background": "dist/worker.js",
  "pages": { "settings": { "file": "pages/settings.html", "display": "sheet" } },
  "menu": [{ "id": "settings", "label": "設定", "type": "page", "page": "settings" }],
  "permissions": ["storage", "fetch", "pages", "menu"],
  "settingsSchema": [{ "key": "text", "type": "string", "label": "文言", "default": "Hi" }],
  "policy": { "url": "https://wsi-api.pokeplus-dev.workers.dev/v1/plugins/my-plugin/policy", "ttlSeconds": 3600, "defaults": {} },
  "updateUrl": "https://wsi-api.pokeplus-dev.workers.dev/v1/plugins/my-plugin/latest",
  "config": {}
}
```

| フィールド | 意味 |
|---|---|
| `domains` | 完全一致、`*.example.com` (サブドメイン含む)、`*` (全サイト) |
| `paths` | glob。`*` は 1 セグメント、`**` は複数。`/x/**` は `/x` も含む。省略で全パス |
| `scripts.runAt` | `document_start` / `document_end` (UserScript として注入) / `document_idle` (既定、読み込み完了後) |
| `background` | ワーカー。アプリ起動時と有効化時に Headless WebView で起動し、同じ ID のプラグインを上書きインストールすると再起動する |
| `pages` | `wsi://plugin/<id>/<file>` で表示する画面。`fullscreen` か `sheet` |
| `menu` | メニュー項目の宣言 (検証用)。実際の表示は `WSI.menu.register` で行う。ページからの登録はそのページの間だけ、ワーカーからの登録はナビゲーションをまたいで残るので、常設の項目はワーカーで登録する。`page` は `pages` に存在すること。`menu` 権限が必要 |
| `permissions` | 下の一覧。`storage` は常に許可。`formatVersion` 1 (または未指定) は Chrome 版互換で `storage` + `fetch` |
| `settingsSchema` | ホストが設定画面を自動生成する。`string` / `number` / `boolean` / `select` (`options`) |
| `policy` | サーバー配信の値。取得失敗時は前回値 → `defaults` |
| `updateUrl` | 更新チェック先。`{ version, zipUrl, notes }` を返す URL |

権限: `storage` `fetch` `credentials` `device` `share` `files` `clipboard` `wakeLock` `pip` `blockResources` `tabs` `pages` `menu` `navigation` `policy`。`credentials` `files` `device` `clipboard` `tabs` `navigation` はインポート時に利用者の同意チェックが必要。

`npx wsi-plugin validate` が要件定義の検証表どおりに検査する。

## 4. SDK

ページの `main.js` には `WSI` が引数として渡る (`window` には無い)。プラグインページでは `window.WSI` が使える。ワーカーでは DOM 系 (`addButton` / `addPanel` / `onPageLoad`) を除く全部が使える。

### Chrome 版と共通 (v1)

```js
WSI.addButton({ text, icon, position, onClick })   // ドラッグ可、位置は保存される
WSI.addPanel({ title, width, position, content, onOpen, onClose })  // 600px 未満はボトムシート
WSI.storage.get / set / remove / getAll             // プラグイン専用の KV
WSI.fetch(url, { method, headers, body, redirect, credentials: 'site', responseType: 'json', timeoutMs })
WSI.getConfig()   WSI.log(msg)   WSI.onPageLoad(cb)   WSI.permissions.has('tabs')
```

Chrome 版では v2 の API は `undefined` になるので、`WSI.permissions.has('tabs')` や `typeof WSI.tabs === 'object'` で分岐する。

### WSI Browser のみ (v2)

```js
WSI.toast(msg, { duration })
await WSI.dialog({ title, message, buttons: ['OK', 'キャンセル'] })   // 押されたボタンの index
await WSI.ui.openPage('settings', params);  WSI.ui.closePage()
WSI.settings.get / set / getAll;  WSI.settings.onChange(({ key, value }) => {})
await WSI.policy.get(key) / getAll() / refresh()
WSI.menu.register([{ id, label, type: 'page'|'action'|'toggle'|'separator', page, checked, onSelect, onChange }])
WSI.menu.update(id, { label, checked })
await WSI.runtime.sendMessage(msg)   // 同じプラグインの他の文脈へ。{ delivered, reply }
WSI.runtime.onMessage((msg, sender) => reply)
WSI.runtime.onSuspend(async () => {})  WSI.runtime.onResume(async () => {})   // ワーカー
// ワーカー限定
const tabId = await WSI.tabs.open(url, { hidden: true })
await WSI.tabs.navigate(tabId, url);  await WSI.tabs.run(tabId, 'document.title');  await WSI.tabs.close(tabId)
await WSI.tabs.list();  WSI.tabs.onLoad((tabId, url, error) => {});  WSI.tabs.onClose((tabId) => {})
WSI.tabs.onDialog(({ tabId, type, message }) => ({ action: 'accept' }), { default: 'accept' })
WSI.navigation.intercept((url) => 'allow' | 'deny' | 'external' | undefined)
// ネイティブ
WSI.credentials.set(profile, { id, password }) / get / remove / list
WSI.device.id() / info();  WSI.share({ text, url, files });  WSI.files.save(name, data, { encoding: 'base64', share: true }) / pick({ accept })
WSI.clipboard.write(text) / read();  WSI.wakeLock.acquire() / release();  WSI.pip.enter() / exit() / isSupported()
WSI.blockResources({ images: true, media: true, urls: ['/ads/'] })
```

注意点:

- ホストへの要求はすべて `{ token, op, payload }` で 1 本のハンドラを通る。トークンは注入ごとにホストが発行するので、プラグインが自分の ID を名乗ることはできない
- 未宣言の権限の op は `{ error: 'permission denied' }` になる (v2 API は `Error` を throw する)
- Android は全 WebView が 1 つのレンダラを共有するため、隠しタブの `alert()` が保留中はワーカーの JS も止まる。`tabs.onDialog` は登録時に宣言した既定 (`default`) で即時応答され、コールバックには事後に届く。iOS はコールバックに先に問い合わせる
- `tabs.navigate` は WebView を作り直す (iOS の loadRequest 無視、Android Headless の 2 回目 loadUrl 不発への対策)。ページ側の状態は残らない
- 背面移行でワーカーは `onSuspend` を受ける。進捗は `WSI.storage` に保存し、`onResume` で続きから再開する。iOS のバックグラウンド実行は延長しない
- 値の制限 (最小間隔など) はコードに埋め込まず `WSI.policy` から読む

## 5. 開発サイクル

```
npx wsi-plugin validate
npx wsi-plugin build            # esbuild で dist/ に束ねる
npx wsi-plugin dev-serve        # 自己署名 HTTPS で配信。QR と wsi://install?url= を表示
```

端末側:

1. 設定 → 開発者モード ON (必要なら Web インスペクタも)
2. 表示された QR を「プラグイン → インポート → QR コードを読む」で読むか、`wsi://install?url=https://<PC>:8443/plugin.zip` を開く (Android エミュレーターは `10.0.2.2`)
3. ライブリロード: `wsi://dev?url=https://<PC>:8443/plugin.zip&interval=10` を開くと、PC で保存するたびに再取得して再インストールし、対象タブを再読み込みする
4. ログはプラグイン一覧の右上、またはブラウザメニューから。Web インスペクタは iOS が Safari、Android が `chrome://inspect`

Chrome 版で試すときは `npx wsi-plugin pack` の ZIP を拡張のポップアップからインポートする。

## 6. 公開

```
npx wsi-plugin pack                              # dist/<id>-<version>.zip
npx wsi-plugin publish --notes "変更点"           # R2 に置き、D1 の plugin_releases に登録 (wrangler ログインが必要)
```

公開後:

- `https://wsi-api.pokeplus-dev.workers.dev/p/<id>` が配布ページ (QR 付き)
- `.../v1/plugins/<id>/latest` を `updateUrl` に書いておくと、利用者のホストが起動時と 1 日 1 回に更新を検知して一覧にバッジを出す。適用は利用者の操作で行われる (自動適用しない)
- ZIP を作り直すときは必ず `version` を上げる

ポリシー値は D1 に直接入れる:

```
npx wrangler d1 execute wsi-api --remote --command "INSERT OR REPLACE INTO plugin_policies (plugin_id, key, value) VALUES ('my-plugin', 'minActionIntervalMs', '3000')"
```

## 7. サンプル

- `plugins/samples/*`: Chrome 版 WSI の 7 サンプル (v1 API のみ)
- `plugins/banner-demo`: 設定ページ (sheet)、メニュー、`WSI.settings`、`runtime.sendMessage`、自己診断
- `plugins/cruise-demo`: ワーカー、`WSI.tabs`、`onDialog`、suspend / resume、`navigation.intercept`、結果ページ

## 8. テスト

- プラグイン単体: vitest + jsdom で `run(WSI, ctx)` に mock の `WSI` を渡す
- SDK 契約: `packages/wsi_sdk` の Playwright テスト (mock アダプタと Chrome 拡張)。Flutter 側は `apps/wsi_browser/integration_test/samples_test.dart` が同じ fixture を使う

# スクリーンショット

ストアに載せるスクリーンショットの撮り方。画像は
`apps/wsi_browser/assets/brand/store/screenshots/` に置く。

## 守ること

- **リリースビルドで撮る。** デバッグビルドは右上に赤い DEBUG の帯が出る
- **特定サイトを写さない。** このリポジトリもストアの掲載内容も公開される。
  私的なサイト、ログイン済みの画面、実在の個人情報を写さない
- サンプルプラグインと、一般に公開されているページだけを使う

## 撮る画面

| # | 画面 | 何を見せるか |
| --- | --- | --- |
| 1 | スタートページ | ふつうのブラウザとして使えること |
| 2 | プラグイン一覧 | 読み込んだプラグインを個別に有効・無効にできること |
| 3 | インポートのプレビュー | 読み込む前に対象サイトと権限が出て、同意を求められること |
| 4 | プラグインの設定画面 | プラグインごとに設定を持てること |
| 5 | タブ一覧 | 複数タブに対応していること |

Google Play はスマートフォン用に 2〜8 枚を求める。App Store は 6.9 インチと
6.5 インチのそれぞれに最低 1 枚が要る。

## サイズ

| ストア | 要件 |
| --- | --- |
| Google Play (スマートフォン) | 各辺 320〜3840 px、縦横比は 2:1 を超えないこと |
| App Store 6.9 インチ | 1290 x 2796 |
| App Store 6.5 インチ | 1242 x 2688 |

**Pixel 9a のエミュレーターは 1080 x 2424 で、縦横比が 2.24:1 になり Play の上限を
超える。** 撮る前に一時的に 16:9 へ落とす。

```
adb shell wm size 1080x1920
adb shell wm density 420
```

解像度を変えると一度システム UI が固まり「プロセス system は応答していません」の
ダイアログが出ることがある。待機を選んで数秒待てば復帰する。

撮り終えたら必ず戻す。

```
adb shell wm size reset
adb shell wm density reset
```

## 手順

リリース APK を用意する。パスに日本語を含むワークツリーでは AOT ビルドが失敗するので、
ASCII だけのパス (本チェックアウト) で作る。

```
cd apps/wsi_browser
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

デバッグビルドが入っている端末には署名が違うため上書きできない。別の端末を使うか、
先にアンインストールする。**アンインストールすると端末内のプラグインと設定が消える。**

撮影は次のコマンドで行う。

```
adb exec-out screencap -p > 01-start.png
```

## 撮った画像

`apps/wsi_browser/assets/brand/store/screenshots/android-ja/` に日本語版が 5 枚ある。
いずれも 1080 x 1920 (16:9)。

| ファイル | 内容 |
| --- | --- |
| `01-start.png` | スタートページ |
| `02-import-consent.png` | インポートの確認 (対象ドメインと権限の提示) |
| `03-plugins.png` | プラグイン一覧 (個別の有効・無効、削除、ZIP 書き出し) |
| `04-plugin-running.png` | Wikipedia の記事で Outline Panel が目次を生成している画面 |
| `05-tabs.png` | タブ一覧 |

`screenshots/android-en/` に英語版が 5 枚ある。構成は同じだが 4 枚目だけ違う。

| ファイル | 内容 |
| --- | --- |
| `01-start.png` | スタートページ |
| `02-import-consent.png` | インポートの確認 (Hello World、対象ドメインと権限) |
| `03-plugins.png` | プラグイン一覧 |
| `04-plugin-running.png` | 英語版 Wikipedia でプラグインのボタンが出ている画面 |
| `05-tabs.png` | タブ一覧 |

使ったサンプルは Highlighter、Markdown Copy、Outline Panel、URL Expander の 4 つ。
表示しているページは Wikipedia の HTML の記事 (日本語版と英語版) で、公開されている中立な内容。

### 英語版で気をつけた点

**アプリの UI は英語になるが、プラグインの名前・説明・プラグインが描く UI は日本語のまま。**
`plugin.json` の `description` は 1 つの文字列で、多言語に分かれていない。プラグインが
ページに描く文言もプラグイン側のものなので、ホストの言語設定では変わらない。

- `03-plugins.png` は説明文が日本語で残る。プラグインの作者が書いた文字列なので実物どおり
- Outline Panel のパネル見出しは「目次 (40件)」と出る。英語版では見栄えが悪いので、
  4 枚目は**パネルを開かず**、ページ上にプラグインのボタンが出ている画面にした

英語圏向けに見栄えを整えたい場合は、サンプル側に英語の説明を持たせる必要がある。
ただし `plugins/samples` は `tools/sync_wsi_samples.ps1` で WSI から同期しているので、
直すなら WSI 側が先になる。

## App Store 用

**まだ無い。** Windows では iOS シミュレーターを動かせないため、Android の画面を
リサイズして流用すると、ステータスバーや UI が実物と違って審査で弾かれる。
TestFlight が入っている実機で撮るか、Codemagic の Mac でシミュレーターを回す。
必要なサイズは 6.9 インチ (1290 x 2796) と 6.5 インチ (1242 x 2688)。

## 撮影の実務メモ (2026-09-11)

- **エミュレーターは撮影専用に作った方が早い。** 既存の AVD は他アプリで容量が埋まっていて
  76 MB の APK が入らなかった。`avdmanager create avd` で新しく作り、
  config.ini の `hw.lcd.width` / `hw.lcd.height` を 1080 x 1920 にしてから起動する。
  起動後に `wm size` で変えるとシステム UI が固まることがある
- **エミュレーター用なら `--target-platform android-x64` で APK が半分になる** (76 MB → 42 MB)
- **アプリだけ日本語にできる。** `adb shell cmd locale set-app-locales jp.serendipy.wsibrowser
  --locales ja-JP`。端末全体の言語を変えるより副作用が少ない
- **日本語 IME が `adb shell input text` のローマ字を仮名に変換してしまう。**
  URL を打つと「きぺぢあ。おrg」になる。変換候補に正しい文字列が出るので、それをタップする
- **http の URL からのインポートには開発者モードが要る** (`importer.fromUrl(allowInsecure:)`)。
  設定の一番下で切り替える。撮影が終わったら戻すこと
- ZIP は `node packages/wsi_plugin_tools/bin/wsi-plugin.js pack plugins/samples/<id>` で作り、
  `python -m http.server 8099 --bind 127.0.0.1` で配信する。エミュレーターからは 10.0.2.2 で届く

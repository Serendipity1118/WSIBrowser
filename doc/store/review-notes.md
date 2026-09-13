# 審査ノート

App Store Connect の「App Review Information」の Notes に貼る文面。**特定サイトの名前を出さない。**
Google Play には審査ノートを貼る欄が無い (「アプリのアクセス権」はログインが必要な場合の欄で、
WSI Browser は「特別なアクセス権なし」なので使わない)。Play から問い合わせが来たら下の日本語版と
「想定される指摘と答え」で返答する。

プラグイン方式は審査で誤解されやすい。「利用者が持ち込む ZIP を読み込む」形は、
実行コードのダウンロードや審査回避に見えることがある。何が起きるのかを先に説明しておく。

## 英語 (App Store Connect の Review Notes)

```
WSI Browser is a general-purpose web browser. It has no site-specific behavior of
its own.

How plugins work

The app can load a "plugin": a ZIP archive containing a manifest, JavaScript and
CSS. A plugin is supplied by the user, not by us, and none ship with the app. The
user picks a file, enters a URL, scans a QR code, or shares one in from another
app. Before installing, the app shows the plugin's name, author, target sites and
requested permissions, and the user has to confirm.

A plugin's code runs inside the WebView, in the page context, on the sites the
plugin declares in its manifest. It cannot run on any other site. It is ordinary
web content executed in a web view, the same category of thing as a bookmarklet or
a user style sheet. It is not native code, it is not downloaded into the app
binary, and it cannot change the app itself.

Permissions

Each plugin declares the capabilities it needs. Storage, network access and page
manipulation are the basics. Anything more sensitive (stored credentials, files,
device information, location, clipboard, tab control, navigation control) requires
the user to tick a consent box at install time. At runtime the app checks every
bridge call against the declared and consented permissions and rejects the rest.

Location and Face ID

The app asks for location (when in use only) and Face ID / biometrics only on behalf
of a plugin the user installed and consented to. Location is requested the moment
such a plugin asks for the current position; the app never tracks location in the
background and has no background location permission. Biometric prompts return
only success or failure to the plugin, and the prompt names the plugin that asked.
Neither location nor biometric results are sent to our servers. Without such a
plugin, neither permission dialog ever appears.

What we do not do

The app does not bundle, recommend, or distribute any plugin. It does not download
executable code on its own. It does not modify itself. There is no advertising SDK
and no third-party analytics.

Backend

The app talks to our own Cloudflare Workers endpoint for three things: policy
values that plugins must obey (such as minimum intervals), update information for
plugins the user already installed, and user-submitted feedback. No account is
required to use the app.

How to try it

The browser works on its own with no plugin installed; open any site and use it as
a browser. To see the plugin flow, the sample plugins and the authoring guide are
published in the project repository at
https://github.com/Serendipity1118/WSIBrowser (see doc/plugin-guide.md and the
plugins/samples directory).
```

## 日本語 (Google Play から日本語で問い合わせが来た場合など)

```
WSI Browser は汎用のウェブブラウザです。特定サイト向けの動作はアプリ自体には
ありません。

プラグインの仕組み

アプリは「プラグイン」を読み込めます。プラグインは manifest と JavaScript、CSS を
まとめた ZIP です。提供するのは利用者であり、アプリには 1 つも同梱していません。
ファイル選択、URL 指定、QR コード読み取り、他アプリからの共有のいずれかで読み込み
ます。読み込む前に、名前、作者、対象サイト、要求する権限を表示し、利用者の確認を
求めます。

プラグインのコードは WebView の中のページコンテキストで動き、manifest が宣言した
サイトでのみ実行されます。それ以外のサイトでは動きません。ブックマークレットや
ユーザースタイルシートと同種の、ウェブビュー内で動くウェブコンテンツです。
ネイティブコードではなく、アプリのバイナリに取り込まれることもなく、アプリ自体を
書き換えることもできません。

権限

プラグインは必要な機能を事前に宣言します。保存領域、通信、ページ操作は基本的な
ものです。ログイン情報の保管、ファイル、端末情報、現在地、クリップボード、タブ操作、
ページ遷移の制御については、読み込み時に利用者の同意チェックが必要です。実行時も
毎回、宣言と同意の範囲かをアプリ側で検査し、範囲外は拒否します。

位置情報と生体認証

位置情報 (アプリ使用中のみ) と生体認証は、利用者が同意して読み込んだプラグインが
求めたときにだけ使います。位置情報はプラグインが現在地を求めた時点で OS の許可を
求め、バックグラウンドでの取得は行いません (バックグラウンド位置情報の権限も
ありません)。生体認証はプラグインに成否だけを返し、ダイアログには求めたプラグインの
名前を表示します。どちらも当方のサーバーへは送信しません。該当するプラグインが
なければ、これらの許可ダイアログは表示されません。

行っていないこと

プラグインの同梱、推奨、配布は行いません。アプリが独自に実行コードをダウンロード
することはありません。アプリ自体の書き換えも行いません。広告 SDK と第三者の分析
ツールは入っていません。

バックエンド

自前の Cloudflare Workers に対して 3 つの通信を行います。プラグインが従うべき
ポリシー値の取得、利用者が既に入れたプラグインの更新情報、利用者が送る
フィードバックです。利用にアカウントは不要です。

確認方法

プラグインを 1 つも入れなくてもブラウザとして動きます。任意のサイトを開いて
お試しください。プラグインの流れを確認する場合、サンプルと作成手順は
https://github.com/Serendipity1118/WSIBrowser で公開しています
(doc/plugin-guide.md と plugins/samples を参照)。
```

## 想定される指摘と答え

| 指摘 | 答え |
| --- | --- |
| 実行コードを後からダウンロードしているのでは | プラグインは WebView 内で動くウェブコンテンツで、アプリのコードは変わらない。ブラウザがウェブページの JavaScript を実行するのと同じ範囲 |
| 審査を回避して機能を追加しているのでは | アプリの機能はプラグインの有無に関わらず同じ。プラグインが増やせるのはページ側の見た目と操作であり、アプリのネイティブ機能は増えない |
| 利用者が危険なプラグインを入れられるのでは | 読み込み前に対象サイトと権限を提示して同意を求め、実行時も宣言と同意の範囲で検査する。対象サイト外では動かない |
| 位置情報の権限を使う機能が見当たらない | 位置情報の権限を持つプラグインが `WSI.location` を呼んだときにだけ使う。アプリ単体では使わない。バックグラウンド位置情報は宣言していない (geolocator の前景サービスも manifest から除去済み) |
| Face ID / USE_BIOMETRIC の用途は | 生体認証の権限を持つプラグインが `WSI.biometrics.authenticate` を呼んだときの本人確認。プラグインには成否だけを返す |
| 位置情報を収集しているのでは (データセーフティ / App Privacy) | アプリも当方のサーバーも位置情報を受け取らない。端末内で処理し、利用者が同意したプラグインへ渡すだけ。プラグインの通信先は利用者が選んだプラグインの製作者に属する (ブラウザでウェブサイトが Geolocation API を使うのと同じ扱い) |
| アカウント情報が必要か | 不要。審査用のテストアカウントは要らない |

## テストアカウント

不要。アプリの利用にログインはない。

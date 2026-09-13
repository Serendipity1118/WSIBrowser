# System Info Demo

P5 追加 (P5-11〜15) で入れた「アプリでしか取れない情報」の API を、実機で 1 つずつ試すための検証用プラグイン。WSI Browser 専用 (Chrome 版では v2 API が無いので動かない)。

## 確認できること

| 場所 | 内容 |
|---|---|
| メニュー「端末とアプリの情報」 | プラグインページ (fullscreen)。各 API のボタンと戻り値の表示 |
| ページ: 端末 | `WSI.device.id()` / `info()` / `key()`。key を 2 回押して同じ値になるか |
| ページ: アプリと言語 | `WSI.app.info()` / `WSI.locale.get()` (権限不要) |
| ページ: 位置情報 | `WSI.location.permission()` / `request()` / `getCurrent({ accuracy, timeout, maxAge })`。OS の許可ダイアログ、位置情報 OFF のエラー |
| ページ: ネットワーク / バッテリー | `status()` と、`onChange` の監視トグル (機内モード、充電ケーブルの抜き差し) |
| ページ: 生体認証 | `WSI.biometrics.status()` / `authenticate({ reason, biometricOnly })`。ダイアログのプラグイン名、キャンセル時の `{ success: false, reason }` |
| メニュー「接続と充電の変化を通知」 | ワーカーで `network.onChange` / `battery.onChange` を購読し、変化をトーストで出す。状態は再起動後も残る |
| example.com | 右下の「端末情報」ボタンでページを開く。ページ文脈からの `device.key` をログに出す |

インポート時は `device` と `location` に同意チェックが必要。

## 実機での手順 (Android エミュレーター)

```
npx wsi-plugin build plugins/system-info-demo
npx wsi-plugin dev-serve plugins/system-info-demo --host 10.0.2.2
```

アプリの設定で開発者モードを ON にしてから、次でインポート画面を開く。

```
adb shell am start -a android.intent.action.VIEW -d "wsi://install?url=https%3A%2F%2F10.0.2.2%3A8443%2Fplugin.zip" jp.serendipy.wsibrowser
```

`device` と `location` の同意にチェックして読み込み、メニューの「端末とアプリの情報」を開く。

エミュレーターでは、位置情報は拡張コントロールの Location、ネットワークは機内モード、バッテリーは拡張コントロールの Battery で変えられる。生体認証は設定で指紋を登録し、拡張コントロールの Fingerprint で触れる。

## 開発

```
npx wsi-plugin validate      # plugin.json と参照ファイルの検証
npx wsi-plugin build         # src/ を esbuild で dist/ に束ねる
npx wsi-plugin pack          # 検証 + ビルド + ZIP (dist/system-info-demo-<version>.zip)
```

ZIP を作り直すときは必ず `plugin.json` の `version` を上げる。

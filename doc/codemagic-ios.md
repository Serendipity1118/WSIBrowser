# Codemagic iOS ビルド設定手順

WSI Browser (`jp.serendipy.wsibrowser`) の iOS ビルドを Codemagic で行い、
TestFlight へ配信するまでの手順。開発機は Windows なので、iOS はここでしか確認できない。

関連: [doc/codemagic-android.md](codemagic-android.md)

## 決定事項

| 項目 | 決定 |
| --- | --- |
| ワークフロー | `ios-appstore` を直接使う (`ios-unsigned` はコンパイル確認用に残す) |
| 署名 | App Store 配布プロファイルを Apple で手動作成し、Codemagic に取り込む |
| ビルド番号 | TestFlight の最新ビルド番号 + 1 (初回は 1)。Android の Play 最新 + 1 と同じ方式 |
| 輸出コンプライアンス | `ITSAppUsesNonExemptEncryption=false` を Info.plist に入れる。HTTPS と OS 標準の暗号しか使わないため適用外 |
| 配信 | TestFlight の内部テストグループ |

## 使う識別子

| 項目 | 値 |
| --- | --- |
| Bundle ID | `jp.serendipy.wsibrowser` |
| App Store Connect のアプリ ID | `6810292242` |
| Apple Team ID | `TZ62JCFSJ9` |
| Codemagic の連携キー名 | `Codemagic` (Key ID `XWS9KGRK5S`、アクセス権は管理者) |
| プロビジョニングプロファイル | Apple 側の名前 `WSIBrowser AppStore` / Codemagic の参照名 `wsibrowser_appstore` |
| 配布証明書 | `kazumi takayanagi` (Distribution)。Codemagic には `PokePlus Distribution` の名前で入っている。証明書はチーム共通なのでアプリごとに作らない |

## 手順

### 1. Apple Developer で配布プロファイルを作る (手動)

**Codemagic はプロビジョニングプロファイルを自動作成しない。** 公式ドキュメントにも
「アップロードするか、事前に取得しておくこと」とある。これを知らずに `ios_signing` だけ
書くと、ビルドが始まる前に
`No matching profiles found for bundle identifier "..." and distribution type "app_store"`
で止まる。

1. <https://developer.apple.com/account/resources/profiles/add> を開く
2. Distribution の「App Store Connect」を選んで Continue
3. App ID で「WSI Browser (jp.serendipy.wsibrowser)」を選んで Continue
4. Certificates で既存の「kazumi takayanagi」(Distribution) にチェックして Continue
5. 名前を `WSIBrowser AppStore` にして Generate

ダウンロードは不要。次の手順で Codemagic が API 経由で取得する。

### 2. Codemagic にプロファイルを取り込む (手動)

1. Codemagic → Settings → codemagic.yaml settings → Code signing identities
2. 「iOS provisioning profiles」タブ (真ん中。左は iOS certificates で別物)
3. 「Get profiles from Apple Developer Portal」の Fetch profiles
4. App Store profiles の中の `WSIBrowser AppStore` にチェック
5. 参照名に `wsibrowser_appstore` を入力
6. **ダイアログを下までスクロールして Fetch selected を押す** (ここを押さないと入らない)
7. Available provisioning profiles に `wsibrowser_appstore` が並び、Certificate が緑になることを確認

証明書は既にチーム共通のものが入っているので、追加の取り込みは要らない。

### 3. codemagic.yaml (コード変更、対応済み)

`ios-appstore` に次を入れてある。

```yaml
      vars:
        BUNDLE_ID: jp.serendipy.wsibrowser
        APP_STORE_APP_ID: 6810292242
    scripts:
      ...
      - name: Determine build number
        script: |
          LATEST=$(app-store-connect get-latest-testflight-build-number \
            "$APP_STORE_APP_ID" 2>/dev/null || true)
          case "$LATEST" in
            ''|*[!0-9]*) LATEST=0 ;;
          esac
          echo "BUILD_NUMBER=$((LATEST + 1))" >> "$CM_ENV"
      - name: Flutter build ipa
        script: |
          set -e
          cd apps/wsi_browser
          flutter build ipa --release \
            --build-number=$BUILD_NUMBER \
            --export-options-plist=/Users/builder/export_options.plist
```

ビルド番号を渡さないと `pubspec.yaml` の `+1` が毎回使われ、2 回目のアップロードが
重複で弾かれる。

### 4. Info.plist (コード変更、対応済み)

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

これが無いと TestFlight に上がるたびに App Store Connect で輸出コンプライアンスの
手動回答を求められる。

### 5. TestFlight の内部テストグループ (手動)

1. App Store Connect → WSI Browser → TestFlight
2. 「内部テスト」の + でグループを作成
3. テスターに App Store Connect のユーザーを追加
4. ビルドをグループに追加 (ビルドが「処理中」の間は追加できない)

内部テストは Apple の審査なしで配信できる。社外の人に配る場合は外部テストになり、
審査とプライバシーポリシーなどの入力が要る。

## 完了状況 (2026-09-11)

| 手順 | 状態 |
| --- | --- |
| 配布プロファイル作成 | 完了 (`WSIBrowser AppStore`) |
| Codemagic への取り込み | 完了 (`wsibrowser_appstore`) |
| codemagic.yaml のビルド番号採番 | 完了 |
| Info.plist の輸出コンプライアンス宣言 | 完了 |
| ios-appstore ビルド | 成功 |
| TestFlight へのアップロード | 完了 (0.1.0 (1)) |
| 内部テストグループへの配信 | 完了 |

## 踏んだもの

- **Codemagic はプロファイルを自動作成しない。** 「automatic code signing」という名前から
  作ってくれそうに見えるが、実際は Code signing identities に登録済みのものを照合するだけ。
  Apple 側で作り、Codemagic に Fetch する 2 段構えが要る
- **Fetch のダイアログは参照名の入力とスクロール先のボタンで完了する。** チェックを入れただけ、
  参照名を入れただけでは登録されない
- **タブを間違えやすい。** iOS certificates と iOS provisioning profiles は別のタブで、
  それぞれに Fetch ボタンがある
- App Store Connect API キーの「最終使用日」は、署名の事前検査で失敗した日には更新されない。
  キーが使われる前に止まっているかどうかの判断材料になる

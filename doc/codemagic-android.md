# Codemagic Android ビルド設定手順

WSI Browser (`jp.serendipy.wsibrowser`) の Android リリースビルドを Codemagic で行い、
Google Play の内部テスト (Internal testing) トラックへ自動アップロードするまでの手順。

## 決定事項 (一問一答の結果)

| 項目 | 決定 |
| --- | --- |
| 目的 | 署名済みリリース AAB + APK |
| keystore | 新規作成 (upload key)。アプリ署名鍵は Play App Signing に任せる |
| Codemagic への登録 | Team settings → Code signing identities → Android keystores にアップロード |
| Play 配信 | Internal testing トラックへ自動アップロード |
| サービスアカウント | pokePlus 用の既存 SA を流用 (変数グループ `google_play` / `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` が登録済み) |
| versionCode | Play の最新ビルド番号 + 1 (初回は Play にビルドが無いので 1 にフォールバック) |

現状の確認結果:

- Codemagic チーム `serendipity` に WSIBrowser は追加済み (「Finish build setup」表示)
- Android keystores には `chikenportal_upload` のみ。WSI Browser 用は未登録
- Global variables and secrets に変数グループ `google_play` があり `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` が入っている
- Play Console のアプリは PokePlus+ と 治験ポータルナビ の 2 件のみ。WSI Browser は未作成
- `apps/wsi_browser/android/app/build.gradle.kts` の release は今も debug 鍵で署名している

## 手順

### 1. upload keystore を作成する (ローカル、手動)

リポジトリの外に置く。例として `C:\Users\takayanagi\keys\` に作る。

`keytool` は PATH に無いので Android Studio 同梱の JDK のものを使う。

```powershell
mkdir C:\Users\takayanagi\keys -Force
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v `
  -keystore C:\Users\takayanagi\keys\wsibrowser_upload.jks `
  -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10950 `
  -alias wsibrowser `
  -dname "CN=Kazumi Takayanagi, O=Serendipity, C=JP"
```

パスワードを 2 回聞かれる (storepass と keypass)。同じものにしてよい。
`-storetype JKS` は keytool が非推奨の警告を出すので PKCS12 にする。拡張子は `.jks` のままでよい。
パスワードは password manager に保存する。**紛失すると同じ upload key で更新できなくなる。**

> `.jks` は絶対にコミットしない。`.gitignore` に `*.jks` と `key.properties` を追加する。

### 2. Codemagic に keystore を登録する (手動)

1. Codemagic → Settings (Team settings) → codemagic.yaml settings → Code signing identities
2. Android keystores タブ → Choose a file で `wsibrowser_upload.jks` を選択
3. Reference name に `wsibrowser_upload`、Key alias に `wsibrowser`、keystore / key の各パスワードを入力
4. 保存後、Available keystores に `wsibrowser_upload` が並ぶことを確認

`codemagic.yaml` からは reference name だけで参照する。ビルド時に Codemagic が
`CM_KEYSTORE_PATH` / `CM_KEYSTORE_PASSWORD` / `CM_KEY_ALIAS` / `CM_KEY_PASSWORD` を環境変数に展開する。

### 3. Gradle をリリース署名に切り替える (コード変更)

`apps/wsi_browser/android/key.properties` を読む標準の Flutter 方式にする。
ファイル自体はコミットせず、ローカルとビルドマシンでそれぞれ生成する。

`android/app/build.gradle.kts` の変更点:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // key.properties が無い環境 (CI 以外) では debug 鍵にフォールバックする
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
```

`.gitignore` に追記:

```
apps/wsi_browser/android/key.properties
*.jks
*.keystore
```

### 4. codemagic.yaml に android-release ワークフローを追加する (コード変更)

既存の `android-debug` / `android-integration` は残し、新しく追加する。

```yaml
  android-release:
    name: Android Release (AAB + APK → Play internal)
    max_build_duration: 60
    instance_type: linux_x2
    environment:
      flutter: 3.41.4
      java: 17
      groups:
        - google_play          # GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
      android_signing:
        - wsibrowser_upload
      vars:
        PACKAGE_NAME: jp.serendipy.wsibrowser
    scripts:
      - name: Set up key.properties
        script: |
          cat > apps/wsi_browser/android/key.properties <<EOF
          storePassword=$CM_KEYSTORE_PASSWORD
          keyPassword=$CM_KEY_PASSWORD
          keyAlias=$CM_KEY_ALIAS
          storeFile=$CM_KEYSTORE_PATH
          EOF
      - *pub_get
      - *gen
      - *test
      - name: Determine build number
        script: |
          # The first build runs before the app exists on Google Play, so fall back to 0.
          LATEST=$(google-play get-latest-build-number \
            --package-name "$PACKAGE_NAME" \
            --credentials @env:GCLOUD_SERVICE_ACCOUNT_CREDENTIALS 2>/dev/null || true)
          case "$LATEST" in
            ''|*[!0-9]*) LATEST=0 ;;
          esac
          echo "BUILD_NUMBER=$((LATEST + 1))" >> "$CM_ENV"
      - name: Install the Android SDK platform for compileSdk
        script: |
          set -e
          SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/usr/local/share/android-sdk}}"
          SDKMANAGER=$(ls "$SDK_ROOT"/cmdline-tools/*/bin/sdkmanager 2>/dev/null | head -n 1)
          if [ -z "$SDKMANAGER" ]; then
            SDKMANAGER=$(command -v sdkmanager || true)
          fi
          if [ -z "$SDKMANAGER" ]; then
            echo "sdkmanager not found under $SDK_ROOT" >&2
            exit 1
          fi
          echo "y" | "$SDKMANAGER" --install "platforms;android-37" \
            || echo "y" | "$SDKMANAGER" --install "platforms;android-37.0"
          ls "$SDK_ROOT/platforms"
      - name: Build AAB and APK
        script: |
          set -e
          cd apps/wsi_browser
          flutter build appbundle --release --build-number=$BUILD_NUMBER
          flutter build apk --release --build-number=$BUILD_NUMBER
    artifacts:
      - apps/wsi_browser/build/app/outputs/bundle/release/*.aab
      - apps/wsi_browser/build/app/outputs/flutter-apk/*.apk
      - apps/wsi_browser/build/app/outputs/mapping/release/mapping.txt
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        submit_as_draft: false
```

初回は Play にアプリもビルドも無いので、まず `publishing:` ブロックをコメントアウトした
状態でビルドし、AAB を手でアップロードした (手順 5、6)。SA の権限を付けたあと
(手順 7) に `publishing:` を有効にしてある。

### 5. Play Console にアプリを作成する (手動)

1. Play Console → すべてのアプリ → 「アプリを作成」
2. アプリ名 `WSI Browser`、デフォルトの言語 日本語、アプリ / ゲーム = アプリ、無料
3. 作成後、パッケージ名は最初の AAB アップロード時に `jp.serendipy.wsibrowser` で確定する
4. テスト → 内部テスト でトラックを作り、テスターのメールアドレスリストを登録

### 6. 初回 AAB を手でアップロードする (手動)

Codemagic の `android-release` を `publishing:` 無しで 1 回流し、artifacts から
`.aab` をダウンロードして内部テストにアップロードする。
このとき Play App Signing が有効になり、upload key が確定する。

### 7. サービスアカウントに WSI Browser の権限を付ける (手動)

pokePlus 用の SA を流用するので、Play Console 側でアプリを 1 つ足すだけでよい。

1. Play Console → ユーザーとアクセス権 → 該当のサービスアカウント (pokePlus で使っているもの) を開く
2. 「アプリの権限」タブ → アプリを追加 → WSI Browser
3. 権限は「リリース」→ 製品版以外のトラックへのリリース、アプリ情報の閲覧 を付与
4. 招待を保存

SA の JSON 自体は変更不要。Codemagic の `google_play` 変数グループをそのまま使う。

### 8. publishing を有効にして自動アップロードを確認する (コード変更 + ビルド)

`codemagic.yaml` の `android-release` に `publishing:` ブロックを戻し、
ビルドを流して内部テストに新しいビルドが並ぶことを確認する。

## 補足

- `flutter.targetSdkVersion` は Flutter 3.41 では 36。Play の要件は満たしている
- Play Console の初回提出にはプライバシーポリシー URL、データセーフティ、コンテンツレーティングの入力が必要。
  内部テストだけなら一部は後回しにできるが、いずれ必要になる
- iOS と違い `android-debug` ワークフローはそのまま残す。M3〜M5 の実機検証で使える

## ローカル検証の記録 (2026-09-10)

- `.gitignore` に `key.properties` / `*.jks` / `*.keystore` を追加済み
- `build.gradle.kts` を key.properties 方式に変更。key.properties が無い場合の debug フォールバックを
  `flutter build apk --debug` で確認 (成功)
- 使い捨て keystore を置いて `gradlew :app:signingReport` を実行し、release バリアントが
  release 署名設定 (指定した keystore と alias) を使うことを確認
- `codemagic.yaml` に `android-release` を追加済み
- **注意**: このワークツリーはパスに日本語 (`codemagic対応-Andoroid`) を含むため、Windows では
  Gradle が `Your project path contains non-ASCII characters` で止まり、release の AOT ビルドも
  `Unable to read file: ... app.dill` で失敗する。ローカルで release APK を作る場合は
  ASCII のみのパス (本チェックアウト側) で行うこと。Codemagic の Linux 環境では影響しない

## Codemagic での初回ビルドで踏んだもの (2026-09-10)

- **変数グループのアプリ許可**: `Application does not have access to variable group(s): google_play` でビルドが
  始まらない。Team settings → Global variables and secrets → `google_play` の鉛筆 →
  Application access で WSIBrowser を on にする。新しいアプリはここが全部 off のままになる
- **compileSdk 37 のプラットフォーム未インストール**: Linux イメージに platform 37 が無く、
  最初の `bundleRelease` が `Failed to find target with hash string 'android-37'` で落ちる。
  Gradle が自分でダウンロードしても、SDK の索引を読んだ後に届くので同じ実行では間に合わない。
  その失敗中に入った SDK のおかげで、続けて走る `assembleRelease` だけ成功してしまう。
  対策としてビルド前に `sdkmanager --install` するステップを入れた
- **sdkmanager は PATH に無い**: Codemagic の Linux イメージでは `sdkmanager: command not found`
  になる。さらに cmdline-tools が `latest` ではなく `latest-2` に入っていることがあるので、
  `$ANDROID_SDK_ROOT/cmdline-tools/*/bin/sdkmanager` を glob で探してから実行する
- **ステップが失敗を見逃す**: Codemagic の script は途中のコマンドが失敗しても止まらず、
  最後のコマンドの終了コードで判定される。複数コマンドを並べるステップには `set -e` を入れる

## 完了状況 (2026-09-10)

| 手順 | 状態 |
| --- | --- |
| 1. upload keystore 作成 | 完了 (`C:\Users\takayanagi\keys\wsibrowser_upload.jks`、PKCS12、alias `wsibrowser`) |
| 2. Codemagic に登録 | 完了 (reference name `wsibrowser_upload`) |
| 3. Gradle のリリース署名 | 完了 |
| 4. android-release ワークフロー | 完了 |
| 5. Play Console にアプリ作成 | 完了 (`jp.serendipy.wsibrowser`) |
| 6. 初回 AAB を手動アップロード | 完了 (versionCode 1 / 0.1.0、内部テストに保存) |
| 7. SA にアプリ権限を付与 | 完了 (アプリ情報の閲覧 + テスト版リリースの管理) |
| 8. publishing を有効化 | 完了 (versionCode 3 が内部テストへ自動公開されるのを確認) |

### 8 で踏んだもの

- **Play Console に空の未公開リリースが残っていると自動公開が反映されない**。手動アップロードの
  流れで「新しいリリースを作成」を余計に開くと空の下書きが残る。内部テストのページに
  「リリース（無名）未公開」が出ていたら「未公開のリリースの破棄」で消す。
  下書きを消したあとのビルドでは、API が作ったリリースがそのまま公開された
- **「バージョン コード: 1 件」は番号ではなく件数**。実際の番号はリリース行の「概要を表示」で見る。
  ここを読み違えると、公開できていないように見える
- Codemagic の CLI が `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` を非推奨と警告する。
  将来 `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS` に変える必要があるが、
  この変数グループは pokePlus と共用なので、名前を変えるときは両方のワークフローを直すこと

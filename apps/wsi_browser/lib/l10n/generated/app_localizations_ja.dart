// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'WSI Browser';

  @override
  String get startPageTitle => 'WSI Browser';

  @override
  String get startPageSubtitle => 'プラグインで拡張できるブラウザ';

  @override
  String get startPageUrlHint => 'URL を入力';

  @override
  String get startPageOpen => '開く';

  @override
  String get startPagePlugins => 'プラグイン';

  @override
  String get startPageSettings => '設定';

  @override
  String get startPageNoPlugins => 'プラグインはまだありません';

  @override
  String get urlBarHint => 'URL または検索語';

  @override
  String urlBarBadgeTooltip(int count) {
    return '$count 件のプラグインが有効';
  }

  @override
  String get actionBack => '戻る';

  @override
  String get actionForward => '進む';

  @override
  String get actionReload => '再読み込み';

  @override
  String get actionStop => '中止';

  @override
  String get actionShare => '共有';

  @override
  String get actionNewTab => '新しいタブ';

  @override
  String get actionCloseTab => 'タブを閉じる';

  @override
  String get actionTabs => 'タブ';

  @override
  String get actionHome => 'ホーム';

  @override
  String get actionOpenExternal => '外部ブラウザで開く';

  @override
  String get actionCopyUrl => 'URL をコピー';

  @override
  String get tabsTitle => 'タブ';

  @override
  String tabsLimitReached(int limit) {
    return 'タブは最大 $limit 個までです';
  }

  @override
  String get tabUntitled => '(無題)';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogCancel => 'キャンセル';

  @override
  String get dialogClose => '閉じる';

  @override
  String jsDialogTitle(String host) {
    return '$host からのメッセージ';
  }

  @override
  String downloadStarted(String name) {
    return 'ダウンロード中: $name';
  }

  @override
  String downloadDone(String name) {
    return '保存しました: $name';
  }

  @override
  String downloadFailed(String reason) {
    return 'ダウンロードに失敗しました: $reason';
  }

  @override
  String get externalLinkOpened => '外部ブラウザで開きました';

  @override
  String navigationBlocked(String url) {
    return 'この URL は開けません: $url';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionBrowser => 'ブラウザ';

  @override
  String get settingsSectionPlugins => 'プラグイン';

  @override
  String get settingsSectionDeveloper => '開発者';

  @override
  String get settingsInitialUrl => '初期 URL';

  @override
  String get settingsInitialUrlDesc => '起動時に開くページ。空ならスタートページ';

  @override
  String get settingsTabLimit => 'タブの上限';

  @override
  String get settingsExternalLinks => '外部リンクの扱い';

  @override
  String get settingsExternalLinksDesc => 'プラグインが担当しないサイトへのリンク';

  @override
  String get settingsExternalLinksInApp => 'アプリ内で開く';

  @override
  String get settingsExternalLinksExternal => '外部ブラウザで開く';

  @override
  String get settingsUserAgent => 'User-Agent';

  @override
  String get settingsUserAgentDesc => '空なら OS 標準のブラウザ相当';

  @override
  String get settingsClearCookies => 'Cookie を消去';

  @override
  String get settingsClearCookiesDesc => 'すべてのサイトのログイン状態が消えます';

  @override
  String get settingsClearCookiesConfirm => 'Cookie をすべて消去しますか?';

  @override
  String get settingsClearCookiesDone => 'Cookie を消去しました';

  @override
  String get settingsUpdateCheck => 'プラグインの更新を確認する';

  @override
  String get settingsUpdateCheckDesc => '起動時と 1 日 1 回';

  @override
  String get settingsLogRetention => 'ログの保持件数';

  @override
  String get settingsDeveloperMode => '開発者モード';

  @override
  String get settingsDeveloperModeDesc => 'URL からのライブリロードと Web インスペクタを有効にする';

  @override
  String get settingsWebInspector => 'Web インスペクタ';

  @override
  String get settingsWebInspectorDesc =>
      'iOS は Safari、Android は chrome://inspect';

  @override
  String get settingsAbout => 'バージョン';

  @override
  String get settingsSaved => '保存しました';

  @override
  String get settingsEdit => '編集';

  @override
  String get settingsUseDefault => '既定値';

  @override
  String commonError(String message) {
    return 'エラー: $message';
  }

  @override
  String get pluginsTitle => 'プラグイン';

  @override
  String get pluginsEmpty => 'プラグインはまだありません。ZIP をインポートしてください。';

  @override
  String get pluginsGlobalToggle => 'プラグインを有効にする';

  @override
  String get pluginsGlobalToggleOff => 'すべてのプラグインが停止しています';

  @override
  String get pluginsImport => 'インポート';

  @override
  String pluginsCurrentHost(String host) {
    return 'このサイト: $host';
  }

  @override
  String pluginVersion(String version) {
    return 'v$version';
  }

  @override
  String pluginUpdateAvailable(String version) {
    return '更新あり: v$version';
  }

  @override
  String get pluginUpdate => '更新';

  @override
  String get pluginDelete => '削除';

  @override
  String pluginDeleteConfirm(String name) {
    return '$name を削除しますか? 保存データと設定もすべて消えます。';
  }

  @override
  String get pluginDeleted => '削除しました';

  @override
  String get pluginSettings => '設定';

  @override
  String get pluginExport => 'ZIP を書き出す';

  @override
  String get pluginDetails => '詳細';

  @override
  String get pluginDomains => '対象ドメイン';

  @override
  String get pluginPermissions => '権限';

  @override
  String get pluginAuthor => '作者';

  @override
  String get pluginInstalledAt => 'インストール';

  @override
  String get pluginCheckUpdates => '更新を確認';

  @override
  String get pluginLogs => 'ログ';

  @override
  String get importTitle => 'プラグインをインポート';

  @override
  String get importFromFile => 'ファイルを選ぶ';

  @override
  String get importFromUrl => 'URL から';

  @override
  String get importFromQr => 'QR コードを読む';

  @override
  String get importUrlHint => 'https://.../plugin.zip';

  @override
  String get importPreviewTitle => 'インポートの確認';

  @override
  String importOverwrite(String version) {
    return '同じ ID のプラグイン (v$version) を上書きします。保存データは引き継がれます。';
  }

  @override
  String get importSensitive => 'このプラグインは次の権限を要求します';

  @override
  String get importConsent => '上記の権限を許可する';

  @override
  String get importInstall => 'インストール';

  @override
  String importDone(String name) {
    return '$name をインストールしました';
  }

  @override
  String importFailed(String reason) {
    return 'インポートできません: $reason';
  }

  @override
  String get importDownloading => 'ダウンロード中...';

  @override
  String get importInsecureUrl => 'https 以外の URL は開発者モードでのみ使えます';

  @override
  String get qrScanHint => 'wsi://install または ZIP の URL の QR を読み取ります';

  @override
  String get logsTitle => 'ログ';

  @override
  String get logsEmpty => 'ログはありません';

  @override
  String get logsClear => '消去';

  @override
  String get logsShare => '書き出す';

  @override
  String get logsFilterAll => 'すべて';

  @override
  String settingsPluginTitle(String name) {
    return '$name の設定';
  }

  @override
  String get settingsPluginEmpty => 'このプラグインに設定項目はありません';

  @override
  String get permissionDesc_storage => 'データの保存';

  @override
  String get permissionDesc_fetch => 'ネットワークアクセス';

  @override
  String get permissionDesc_credentials => 'ログイン情報の保存 (Keychain / Keystore)';

  @override
  String get permissionDesc_device => '端末 ID の取得';

  @override
  String get permissionDesc_share => '共有シート';

  @override
  String get permissionDesc_files => 'ファイルの保存と選択';

  @override
  String get permissionDesc_clipboard => 'クリップボードへの書き込み';

  @override
  String get permissionDesc_wakeLock => '画面のスリープ防止';

  @override
  String get permissionDesc_pip => 'ピクチャ・イン・ピクチャ';

  @override
  String get permissionDesc_blockResources => '画像・動画の読み込み抑制';

  @override
  String get permissionDesc_tabs => 'バックグラウンドでのタブ操作';

  @override
  String get permissionDesc_pages => '独自画面の表示';

  @override
  String get permissionDesc_menu => 'メニューへの項目追加';

  @override
  String get permissionDesc_navigation => 'ページ遷移の横取り';

  @override
  String get permissionDesc_policy => 'サーバーからのポリシー値取得';

  @override
  String get settingsWorkerTabLimit => 'ワーカーのタブ上限';

  @override
  String get settingsWorkerTabLimitDesc => 'プラグインごとに同時に開けるタブ数 (WSI.tabs)';

  @override
  String get backupTitle => 'バックアップと復元';

  @override
  String get backupDesc => 'プラグインのデータと設定を暗号化 JSON で書き出す / 読み込む。ログイン情報は含まれません';

  @override
  String get backupPassword => 'パスワード';

  @override
  String get backupPasswordHint => '4 文字以上。復元時に必要です';

  @override
  String get backupExport => '書き出す (共有)';

  @override
  String get backupRestore => 'ファイルを選んで復元';

  @override
  String get backupExported => 'バックアップを書き出しました';

  @override
  String backupRestored(int count) {
    return '$count 件のプラグインを復元しました';
  }

  @override
  String backupFailed(String reason) {
    return '失敗しました: $reason';
  }

  @override
  String get backupRestoreConfirm => 'インストール済みプラグインの保存データと設定を上書きします。続けますか?';
}

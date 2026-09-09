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
}

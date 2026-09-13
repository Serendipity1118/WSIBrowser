import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'WSI Browser'**
  String get appTitle;

  /// No description provided for @startPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'WSI Browser'**
  String get startPageTitle;

  /// No description provided for @startPageSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'プラグインで拡張できるブラウザ'**
  String get startPageSubtitle;

  /// No description provided for @startPageUrlHint.
  ///
  /// In ja, this message translates to:
  /// **'URL を入力'**
  String get startPageUrlHint;

  /// No description provided for @startPageOpen.
  ///
  /// In ja, this message translates to:
  /// **'開く'**
  String get startPageOpen;

  /// No description provided for @startPagePlugins.
  ///
  /// In ja, this message translates to:
  /// **'プラグイン'**
  String get startPagePlugins;

  /// No description provided for @startPageSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get startPageSettings;

  /// No description provided for @startPageNoPlugins.
  ///
  /// In ja, this message translates to:
  /// **'プラグインはまだありません'**
  String get startPageNoPlugins;

  /// No description provided for @urlBarHint.
  ///
  /// In ja, this message translates to:
  /// **'URL または検索語'**
  String get urlBarHint;

  /// No description provided for @urlBarBadgeTooltip.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件のプラグインが有効'**
  String urlBarBadgeTooltip(int count);

  /// No description provided for @actionBack.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get actionBack;

  /// No description provided for @actionForward.
  ///
  /// In ja, this message translates to:
  /// **'進む'**
  String get actionForward;

  /// No description provided for @actionReload.
  ///
  /// In ja, this message translates to:
  /// **'再読み込み'**
  String get actionReload;

  /// No description provided for @actionStop.
  ///
  /// In ja, this message translates to:
  /// **'中止'**
  String get actionStop;

  /// No description provided for @actionShare.
  ///
  /// In ja, this message translates to:
  /// **'共有'**
  String get actionShare;

  /// No description provided for @actionNewTab.
  ///
  /// In ja, this message translates to:
  /// **'新しいタブ'**
  String get actionNewTab;

  /// No description provided for @actionCloseTab.
  ///
  /// In ja, this message translates to:
  /// **'タブを閉じる'**
  String get actionCloseTab;

  /// No description provided for @actionTabs.
  ///
  /// In ja, this message translates to:
  /// **'タブ'**
  String get actionTabs;

  /// No description provided for @actionHome.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get actionHome;

  /// No description provided for @actionOpenExternal.
  ///
  /// In ja, this message translates to:
  /// **'外部ブラウザで開く'**
  String get actionOpenExternal;

  /// No description provided for @actionCopyUrl.
  ///
  /// In ja, this message translates to:
  /// **'URL をコピー'**
  String get actionCopyUrl;

  /// No description provided for @tabsTitle.
  ///
  /// In ja, this message translates to:
  /// **'タブ'**
  String get tabsTitle;

  /// No description provided for @tabsLimitReached.
  ///
  /// In ja, this message translates to:
  /// **'タブは最大 {limit} 個までです'**
  String tabsLimitReached(int limit);

  /// No description provided for @tabUntitled.
  ///
  /// In ja, this message translates to:
  /// **'(無題)'**
  String get tabUntitled;

  /// No description provided for @dialogOk.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @dialogCancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get dialogCancel;

  /// No description provided for @dialogClose.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get dialogClose;

  /// No description provided for @jsDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'{host} からのメッセージ'**
  String jsDialogTitle(String host);

  /// No description provided for @downloadStarted.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード中: {name}'**
  String downloadStarted(String name);

  /// No description provided for @downloadDone.
  ///
  /// In ja, this message translates to:
  /// **'保存しました: {name}'**
  String downloadDone(String name);

  /// No description provided for @downloadFailed.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロードに失敗しました: {reason}'**
  String downloadFailed(String reason);

  /// No description provided for @externalLinkOpened.
  ///
  /// In ja, this message translates to:
  /// **'外部ブラウザで開きました'**
  String get externalLinkOpened;

  /// No description provided for @navigationBlocked.
  ///
  /// In ja, this message translates to:
  /// **'この URL は開けません: {url}'**
  String navigationBlocked(String url);

  /// No description provided for @settingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @settingsSectionBrowser.
  ///
  /// In ja, this message translates to:
  /// **'ブラウザ'**
  String get settingsSectionBrowser;

  /// No description provided for @settingsSectionPlugins.
  ///
  /// In ja, this message translates to:
  /// **'プラグイン'**
  String get settingsSectionPlugins;

  /// No description provided for @settingsSectionDeveloper.
  ///
  /// In ja, this message translates to:
  /// **'開発者'**
  String get settingsSectionDeveloper;

  /// No description provided for @settingsInitialUrl.
  ///
  /// In ja, this message translates to:
  /// **'初期 URL'**
  String get settingsInitialUrl;

  /// No description provided for @settingsInitialUrlDesc.
  ///
  /// In ja, this message translates to:
  /// **'起動時に開くページ。空ならスタートページ'**
  String get settingsInitialUrlDesc;

  /// No description provided for @settingsTabLimit.
  ///
  /// In ja, this message translates to:
  /// **'タブの上限'**
  String get settingsTabLimit;

  /// No description provided for @settingsExternalLinks.
  ///
  /// In ja, this message translates to:
  /// **'外部リンクの扱い'**
  String get settingsExternalLinks;

  /// No description provided for @settingsExternalLinksDesc.
  ///
  /// In ja, this message translates to:
  /// **'プラグインが担当しないサイトへのリンク'**
  String get settingsExternalLinksDesc;

  /// No description provided for @settingsExternalLinksInApp.
  ///
  /// In ja, this message translates to:
  /// **'アプリ内で開く'**
  String get settingsExternalLinksInApp;

  /// No description provided for @settingsExternalLinksExternal.
  ///
  /// In ja, this message translates to:
  /// **'外部ブラウザで開く'**
  String get settingsExternalLinksExternal;

  /// No description provided for @settingsUserAgent.
  ///
  /// In ja, this message translates to:
  /// **'User-Agent'**
  String get settingsUserAgent;

  /// No description provided for @settingsUserAgentDesc.
  ///
  /// In ja, this message translates to:
  /// **'空なら OS 標準のブラウザ相当'**
  String get settingsUserAgentDesc;

  /// No description provided for @settingsClearCookies.
  ///
  /// In ja, this message translates to:
  /// **'Cookie を消去'**
  String get settingsClearCookies;

  /// No description provided for @settingsClearCookiesDesc.
  ///
  /// In ja, this message translates to:
  /// **'すべてのサイトのログイン状態が消えます'**
  String get settingsClearCookiesDesc;

  /// No description provided for @settingsClearCookiesConfirm.
  ///
  /// In ja, this message translates to:
  /// **'Cookie をすべて消去しますか?'**
  String get settingsClearCookiesConfirm;

  /// No description provided for @settingsClearCookiesDone.
  ///
  /// In ja, this message translates to:
  /// **'Cookie を消去しました'**
  String get settingsClearCookiesDone;

  /// No description provided for @settingsUpdateCheck.
  ///
  /// In ja, this message translates to:
  /// **'プラグインの更新を確認する'**
  String get settingsUpdateCheck;

  /// No description provided for @settingsUpdateCheckDesc.
  ///
  /// In ja, this message translates to:
  /// **'起動時と 1 日 1 回'**
  String get settingsUpdateCheckDesc;

  /// No description provided for @settingsLogRetention.
  ///
  /// In ja, this message translates to:
  /// **'ログの保持件数'**
  String get settingsLogRetention;

  /// No description provided for @settingsDeveloperMode.
  ///
  /// In ja, this message translates to:
  /// **'開発者モード'**
  String get settingsDeveloperMode;

  /// No description provided for @settingsDeveloperModeDesc.
  ///
  /// In ja, this message translates to:
  /// **'URL からのライブリロードと Web インスペクタを有効にする'**
  String get settingsDeveloperModeDesc;

  /// No description provided for @settingsWebInspector.
  ///
  /// In ja, this message translates to:
  /// **'Web インスペクタ'**
  String get settingsWebInspector;

  /// No description provided for @settingsWebInspectorDesc.
  ///
  /// In ja, this message translates to:
  /// **'iOS は Safari、Android は chrome://inspect'**
  String get settingsWebInspectorDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get settingsAbout;

  /// No description provided for @settingsSaved.
  ///
  /// In ja, this message translates to:
  /// **'保存しました'**
  String get settingsSaved;

  /// No description provided for @settingsEdit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get settingsEdit;

  /// No description provided for @settingsUseDefault.
  ///
  /// In ja, this message translates to:
  /// **'既定値'**
  String get settingsUseDefault;

  /// No description provided for @commonError.
  ///
  /// In ja, this message translates to:
  /// **'エラー: {message}'**
  String commonError(String message);

  /// No description provided for @pluginsTitle.
  ///
  /// In ja, this message translates to:
  /// **'プラグイン'**
  String get pluginsTitle;

  /// No description provided for @pluginsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'プラグインはまだありません。ZIP をインポートしてください。'**
  String get pluginsEmpty;

  /// No description provided for @pluginsGlobalToggle.
  ///
  /// In ja, this message translates to:
  /// **'プラグインを有効にする'**
  String get pluginsGlobalToggle;

  /// No description provided for @pluginsGlobalToggleOff.
  ///
  /// In ja, this message translates to:
  /// **'すべてのプラグインが停止しています'**
  String get pluginsGlobalToggleOff;

  /// No description provided for @pluginsImport.
  ///
  /// In ja, this message translates to:
  /// **'インポート'**
  String get pluginsImport;

  /// No description provided for @pluginsCurrentHost.
  ///
  /// In ja, this message translates to:
  /// **'このサイト: {host}'**
  String pluginsCurrentHost(String host);

  /// No description provided for @pluginVersion.
  ///
  /// In ja, this message translates to:
  /// **'v{version}'**
  String pluginVersion(String version);

  /// No description provided for @pluginUpdateAvailable.
  ///
  /// In ja, this message translates to:
  /// **'更新あり: v{version}'**
  String pluginUpdateAvailable(String version);

  /// No description provided for @pluginUpdate.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get pluginUpdate;

  /// No description provided for @pluginDelete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get pluginDelete;

  /// No description provided for @pluginDeleteConfirm.
  ///
  /// In ja, this message translates to:
  /// **'{name} を削除しますか? 保存データと設定もすべて消えます。'**
  String pluginDeleteConfirm(String name);

  /// No description provided for @pluginDeleted.
  ///
  /// In ja, this message translates to:
  /// **'削除しました'**
  String get pluginDeleted;

  /// No description provided for @pluginSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get pluginSettings;

  /// No description provided for @pluginExport.
  ///
  /// In ja, this message translates to:
  /// **'ZIP を書き出す'**
  String get pluginExport;

  /// No description provided for @pluginDetails.
  ///
  /// In ja, this message translates to:
  /// **'詳細'**
  String get pluginDetails;

  /// No description provided for @pluginDomains.
  ///
  /// In ja, this message translates to:
  /// **'対象ドメイン'**
  String get pluginDomains;

  /// No description provided for @pluginPermissions.
  ///
  /// In ja, this message translates to:
  /// **'権限'**
  String get pluginPermissions;

  /// No description provided for @pluginAuthor.
  ///
  /// In ja, this message translates to:
  /// **'作者'**
  String get pluginAuthor;

  /// No description provided for @pluginInstalledAt.
  ///
  /// In ja, this message translates to:
  /// **'インストール'**
  String get pluginInstalledAt;

  /// No description provided for @pluginCheckUpdates.
  ///
  /// In ja, this message translates to:
  /// **'更新を確認'**
  String get pluginCheckUpdates;

  /// No description provided for @pluginLogs.
  ///
  /// In ja, this message translates to:
  /// **'ログ'**
  String get pluginLogs;

  /// No description provided for @importTitle.
  ///
  /// In ja, this message translates to:
  /// **'プラグインをインポート'**
  String get importTitle;

  /// No description provided for @importFromFile.
  ///
  /// In ja, this message translates to:
  /// **'ファイルを選ぶ'**
  String get importFromFile;

  /// No description provided for @importFromUrl.
  ///
  /// In ja, this message translates to:
  /// **'URL から'**
  String get importFromUrl;

  /// No description provided for @importFromQr.
  ///
  /// In ja, this message translates to:
  /// **'QR コードを読む'**
  String get importFromQr;

  /// No description provided for @importUrlHint.
  ///
  /// In ja, this message translates to:
  /// **'https://.../plugin.zip'**
  String get importUrlHint;

  /// No description provided for @importPreviewTitle.
  ///
  /// In ja, this message translates to:
  /// **'インポートの確認'**
  String get importPreviewTitle;

  /// No description provided for @importOverwrite.
  ///
  /// In ja, this message translates to:
  /// **'同じ ID のプラグイン (v{version}) を上書きします。保存データは引き継がれます。'**
  String importOverwrite(String version);

  /// No description provided for @importSensitive.
  ///
  /// In ja, this message translates to:
  /// **'このプラグインは次の権限を要求します'**
  String get importSensitive;

  /// No description provided for @importConsent.
  ///
  /// In ja, this message translates to:
  /// **'上記の権限を許可する'**
  String get importConsent;

  /// No description provided for @importInstall.
  ///
  /// In ja, this message translates to:
  /// **'インストール'**
  String get importInstall;

  /// No description provided for @importDone.
  ///
  /// In ja, this message translates to:
  /// **'{name} をインストールしました'**
  String importDone(String name);

  /// No description provided for @importFailed.
  ///
  /// In ja, this message translates to:
  /// **'インポートできません: {reason}'**
  String importFailed(String reason);

  /// No description provided for @importDownloading.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード中...'**
  String get importDownloading;

  /// No description provided for @importInsecureUrl.
  ///
  /// In ja, this message translates to:
  /// **'https 以外の URL は開発者モードでのみ使えます'**
  String get importInsecureUrl;

  /// No description provided for @qrScanHint.
  ///
  /// In ja, this message translates to:
  /// **'wsi://install または ZIP の URL の QR を読み取ります'**
  String get qrScanHint;

  /// No description provided for @logsTitle.
  ///
  /// In ja, this message translates to:
  /// **'ログ'**
  String get logsTitle;

  /// No description provided for @logsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'ログはありません'**
  String get logsEmpty;

  /// No description provided for @logsClear.
  ///
  /// In ja, this message translates to:
  /// **'消去'**
  String get logsClear;

  /// No description provided for @logsShare.
  ///
  /// In ja, this message translates to:
  /// **'書き出す'**
  String get logsShare;

  /// No description provided for @logsFilterAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get logsFilterAll;

  /// No description provided for @settingsPluginTitle.
  ///
  /// In ja, this message translates to:
  /// **'{name} の設定'**
  String settingsPluginTitle(String name);

  /// No description provided for @settingsPluginEmpty.
  ///
  /// In ja, this message translates to:
  /// **'このプラグインに設定項目はありません'**
  String get settingsPluginEmpty;

  /// No description provided for @permissionDesc_storage.
  ///
  /// In ja, this message translates to:
  /// **'データの保存'**
  String get permissionDesc_storage;

  /// No description provided for @permissionDesc_fetch.
  ///
  /// In ja, this message translates to:
  /// **'ネットワークアクセス'**
  String get permissionDesc_fetch;

  /// No description provided for @permissionDesc_credentials.
  ///
  /// In ja, this message translates to:
  /// **'ログイン情報の保存 (Keychain / Keystore)'**
  String get permissionDesc_credentials;

  /// No description provided for @permissionDesc_device.
  ///
  /// In ja, this message translates to:
  /// **'端末 ID の取得'**
  String get permissionDesc_device;

  /// No description provided for @permissionDesc_share.
  ///
  /// In ja, this message translates to:
  /// **'共有シート'**
  String get permissionDesc_share;

  /// No description provided for @permissionDesc_files.
  ///
  /// In ja, this message translates to:
  /// **'ファイルの保存と選択'**
  String get permissionDesc_files;

  /// No description provided for @permissionDesc_clipboard.
  ///
  /// In ja, this message translates to:
  /// **'クリップボードへの書き込み'**
  String get permissionDesc_clipboard;

  /// No description provided for @permissionDesc_wakeLock.
  ///
  /// In ja, this message translates to:
  /// **'画面のスリープ防止'**
  String get permissionDesc_wakeLock;

  /// No description provided for @permissionDesc_pip.
  ///
  /// In ja, this message translates to:
  /// **'ピクチャ・イン・ピクチャ'**
  String get permissionDesc_pip;

  /// No description provided for @permissionDesc_blockResources.
  ///
  /// In ja, this message translates to:
  /// **'画像・動画の読み込み抑制'**
  String get permissionDesc_blockResources;

  /// No description provided for @permissionDesc_tabs.
  ///
  /// In ja, this message translates to:
  /// **'バックグラウンドでのタブ操作'**
  String get permissionDesc_tabs;

  /// No description provided for @permissionDesc_pages.
  ///
  /// In ja, this message translates to:
  /// **'独自画面の表示'**
  String get permissionDesc_pages;

  /// No description provided for @permissionDesc_menu.
  ///
  /// In ja, this message translates to:
  /// **'メニューへの項目追加'**
  String get permissionDesc_menu;

  /// No description provided for @permissionDesc_navigation.
  ///
  /// In ja, this message translates to:
  /// **'ページ遷移の横取り'**
  String get permissionDesc_navigation;

  /// No description provided for @permissionDesc_policy.
  ///
  /// In ja, this message translates to:
  /// **'サーバーからのポリシー値取得'**
  String get permissionDesc_policy;

  /// No description provided for @permissionDesc_siteData.
  ///
  /// In ja, this message translates to:
  /// **'対象サイトの Cookie とサイトデータの消去'**
  String get permissionDesc_siteData;

  /// No description provided for @permissionDesc_location.
  ///
  /// In ja, this message translates to:
  /// **'現在地の取得 (アプリ使用中のみ)'**
  String get permissionDesc_location;

  /// No description provided for @permissionDesc_network.
  ///
  /// In ja, this message translates to:
  /// **'ネットワーク接続状態の取得'**
  String get permissionDesc_network;

  /// No description provided for @permissionDesc_battery.
  ///
  /// In ja, this message translates to:
  /// **'バッテリー残量と充電状態の取得'**
  String get permissionDesc_battery;

  /// No description provided for @permissionDesc_biometrics.
  ///
  /// In ja, this message translates to:
  /// **'生体認証による本人確認'**
  String get permissionDesc_biometrics;

  /// No description provided for @settingsWorkerTabLimit.
  ///
  /// In ja, this message translates to:
  /// **'ワーカーのタブ上限'**
  String get settingsWorkerTabLimit;

  /// No description provided for @settingsWorkerTabLimitDesc.
  ///
  /// In ja, this message translates to:
  /// **'プラグインごとに同時に開けるタブ数 (WSI.tabs)'**
  String get settingsWorkerTabLimitDesc;

  /// No description provided for @backupTitle.
  ///
  /// In ja, this message translates to:
  /// **'バックアップと復元'**
  String get backupTitle;

  /// No description provided for @backupDesc.
  ///
  /// In ja, this message translates to:
  /// **'プラグインのデータと設定を暗号化 JSON で書き出す / 読み込む。ログイン情報は含まれません'**
  String get backupDesc;

  /// No description provided for @backupPassword.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get backupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In ja, this message translates to:
  /// **'4 文字以上。復元時に必要です'**
  String get backupPasswordHint;

  /// No description provided for @backupExport.
  ///
  /// In ja, this message translates to:
  /// **'書き出す (共有)'**
  String get backupExport;

  /// No description provided for @backupRestore.
  ///
  /// In ja, this message translates to:
  /// **'ファイルを選んで復元'**
  String get backupRestore;

  /// No description provided for @backupExported.
  ///
  /// In ja, this message translates to:
  /// **'バックアップを書き出しました'**
  String get backupExported;

  /// No description provided for @backupRestored.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件のプラグインを復元しました'**
  String backupRestored(int count);

  /// No description provided for @backupFailed.
  ///
  /// In ja, this message translates to:
  /// **'失敗しました: {reason}'**
  String backupFailed(String reason);

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In ja, this message translates to:
  /// **'インストール済みプラグインの保存データと設定を上書きします。続けますか?'**
  String get backupRestoreConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

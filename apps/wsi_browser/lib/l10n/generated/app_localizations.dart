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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WSI Browser';

  @override
  String get startPageTitle => 'WSI Browser';

  @override
  String get startPageSubtitle => 'A browser you extend with plugins';

  @override
  String get startPageUrlHint => 'Enter a URL';

  @override
  String get startPageOpen => 'Open';

  @override
  String get startPagePlugins => 'Plugins';

  @override
  String get startPageSettings => 'Settings';

  @override
  String get startPageNoPlugins => 'No plugins installed yet';

  @override
  String get urlBarHint => 'URL or search';

  @override
  String urlBarBadgeTooltip(int count) {
    return '$count plugin(s) active';
  }

  @override
  String get actionBack => 'Back';

  @override
  String get actionForward => 'Forward';

  @override
  String get actionReload => 'Reload';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionShare => 'Share';

  @override
  String get actionNewTab => 'New tab';

  @override
  String get actionCloseTab => 'Close tab';

  @override
  String get actionTabs => 'Tabs';

  @override
  String get actionHome => 'Home';

  @override
  String get actionOpenExternal => 'Open in external browser';

  @override
  String get actionCopyUrl => 'Copy URL';

  @override
  String get tabsTitle => 'Tabs';

  @override
  String tabsLimitReached(int limit) {
    return 'You can open at most $limit tabs';
  }

  @override
  String get tabUntitled => '(untitled)';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogClose => 'Close';

  @override
  String jsDialogTitle(String host) {
    return 'Message from $host';
  }

  @override
  String downloadStarted(String name) {
    return 'Downloading: $name';
  }

  @override
  String downloadDone(String name) {
    return 'Saved: $name';
  }

  @override
  String downloadFailed(String reason) {
    return 'Download failed: $reason';
  }

  @override
  String get externalLinkOpened => 'Opened in the external browser';

  @override
  String navigationBlocked(String url) {
    return 'Cannot open this URL: $url';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionBrowser => 'Browser';

  @override
  String get settingsSectionPlugins => 'Plugins';

  @override
  String get settingsSectionDeveloper => 'Developer';

  @override
  String get settingsInitialUrl => 'Initial URL';

  @override
  String get settingsInitialUrlDesc =>
      'Page opened at launch. Empty means the start page';

  @override
  String get settingsTabLimit => 'Tab limit';

  @override
  String get settingsExternalLinks => 'External links';

  @override
  String get settingsExternalLinksDesc => 'Links to sites no plugin handles';

  @override
  String get settingsExternalLinksInApp => 'Open in this app';

  @override
  String get settingsExternalLinksExternal => 'Open in the external browser';

  @override
  String get settingsUserAgent => 'User-Agent';

  @override
  String get settingsUserAgentDesc => 'Empty means the OS default browser';

  @override
  String get settingsClearCookies => 'Clear cookies';

  @override
  String get settingsClearCookiesDesc => 'You will be signed out of every site';

  @override
  String get settingsClearCookiesConfirm => 'Clear all cookies?';

  @override
  String get settingsClearCookiesDone => 'Cookies cleared';

  @override
  String get settingsUpdateCheck => 'Check for plugin updates';

  @override
  String get settingsUpdateCheckDesc => 'At launch and once a day';

  @override
  String get settingsLogRetention => 'Log entries to keep';

  @override
  String get settingsDeveloperMode => 'Developer mode';

  @override
  String get settingsDeveloperModeDesc =>
      'Enable live reload from a URL and the web inspector';

  @override
  String get settingsWebInspector => 'Web inspector';

  @override
  String get settingsWebInspectorDesc =>
      'Safari on iOS, chrome://inspect on Android';

  @override
  String get settingsAbout => 'Version';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsEdit => 'Edit';

  @override
  String get settingsUseDefault => 'Default';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }
}

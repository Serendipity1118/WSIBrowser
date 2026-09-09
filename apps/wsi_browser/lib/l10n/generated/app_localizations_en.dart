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

  @override
  String get pluginsTitle => 'Plugins';

  @override
  String get pluginsEmpty => 'No plugins yet. Import a ZIP.';

  @override
  String get pluginsGlobalToggle => 'Enable plugins';

  @override
  String get pluginsGlobalToggleOff => 'All plugins are stopped';

  @override
  String get pluginsImport => 'Import';

  @override
  String pluginsCurrentHost(String host) {
    return 'This site: $host';
  }

  @override
  String pluginVersion(String version) {
    return 'v$version';
  }

  @override
  String pluginUpdateAvailable(String version) {
    return 'Update available: v$version';
  }

  @override
  String get pluginUpdate => 'Update';

  @override
  String get pluginDelete => 'Delete';

  @override
  String pluginDeleteConfirm(String name) {
    return 'Delete $name? Its stored data and settings will be removed too.';
  }

  @override
  String get pluginDeleted => 'Deleted';

  @override
  String get pluginSettings => 'Settings';

  @override
  String get pluginExport => 'Export ZIP';

  @override
  String get pluginDetails => 'Details';

  @override
  String get pluginDomains => 'Domains';

  @override
  String get pluginPermissions => 'Permissions';

  @override
  String get pluginAuthor => 'Author';

  @override
  String get pluginInstalledAt => 'Installed';

  @override
  String get pluginCheckUpdates => 'Check for updates';

  @override
  String get pluginLogs => 'Logs';

  @override
  String get importTitle => 'Import plugin';

  @override
  String get importFromFile => 'Choose a file';

  @override
  String get importFromUrl => 'From URL';

  @override
  String get importFromQr => 'Scan QR code';

  @override
  String get importUrlHint => 'https://.../plugin.zip';

  @override
  String get importPreviewTitle => 'Confirm import';

  @override
  String importOverwrite(String version) {
    return 'A plugin with the same ID (v$version) will be overwritten. Stored data is kept.';
  }

  @override
  String get importSensitive =>
      'This plugin requests the following permissions';

  @override
  String get importConsent => 'Allow these permissions';

  @override
  String get importInstall => 'Install';

  @override
  String importDone(String name) {
    return 'Installed $name';
  }

  @override
  String importFailed(String reason) {
    return 'Cannot import: $reason';
  }

  @override
  String get importDownloading => 'Downloading...';

  @override
  String get importInsecureUrl =>
      'Non-https URLs are only allowed in developer mode';

  @override
  String get qrScanHint => 'Scan a QR code with a wsi://install or ZIP URL';

  @override
  String get logsTitle => 'Logs';

  @override
  String get logsEmpty => 'No log entries';

  @override
  String get logsClear => 'Clear';

  @override
  String get logsShare => 'Export';

  @override
  String get logsFilterAll => 'All';

  @override
  String settingsPluginTitle(String name) {
    return '$name settings';
  }

  @override
  String get settingsPluginEmpty => 'This plugin has no settings';

  @override
  String get permissionDesc_storage => 'Store data';

  @override
  String get permissionDesc_fetch => 'Network access';

  @override
  String get permissionDesc_credentials =>
      'Save login credentials (Keychain / Keystore)';

  @override
  String get permissionDesc_device => 'Read the device ID';

  @override
  String get permissionDesc_share => 'Share sheet';

  @override
  String get permissionDesc_files => 'Save and pick files';

  @override
  String get permissionDesc_clipboard => 'Write to the clipboard';

  @override
  String get permissionDesc_wakeLock => 'Keep the screen awake';

  @override
  String get permissionDesc_pip => 'Picture in picture';

  @override
  String get permissionDesc_blockResources => 'Block images and media';

  @override
  String get permissionDesc_tabs => 'Control tabs in the background';

  @override
  String get permissionDesc_pages => 'Show its own screens';

  @override
  String get permissionDesc_menu => 'Add menu items';

  @override
  String get permissionDesc_navigation => 'Intercept navigation';

  @override
  String get permissionDesc_policy => 'Fetch policy values from a server';

  @override
  String get settingsWorkerTabLimit => 'Worker tab limit';

  @override
  String get settingsWorkerTabLimitDesc =>
      'Tabs a plugin may keep open at once (WSI.tabs)';
}

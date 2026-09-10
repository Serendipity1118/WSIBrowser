import '../l10n/generated/app_localizations.dart';

String permissionLabel(AppLocalizations l, String permission) {
  switch (permission) {
    case 'storage':
      return l.permissionDesc_storage;
    case 'fetch':
      return l.permissionDesc_fetch;
    case 'credentials':
      return l.permissionDesc_credentials;
    case 'device':
      return l.permissionDesc_device;
    case 'share':
      return l.permissionDesc_share;
    case 'files':
      return l.permissionDesc_files;
    case 'clipboard':
      return l.permissionDesc_clipboard;
    case 'wakeLock':
      return l.permissionDesc_wakeLock;
    case 'pip':
      return l.permissionDesc_pip;
    case 'blockResources':
      return l.permissionDesc_blockResources;
    case 'tabs':
      return l.permissionDesc_tabs;
    case 'pages':
      return l.permissionDesc_pages;
    case 'menu':
      return l.permissionDesc_menu;
    case 'navigation':
      return l.permissionDesc_navigation;
    case 'policy':
      return l.permissionDesc_policy;
    case 'siteData':
      return l.permissionDesc_siteData;
    default:
      return permission;
  }
}

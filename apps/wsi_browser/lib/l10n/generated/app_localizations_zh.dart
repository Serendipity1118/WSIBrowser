// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WSI Browser';

  @override
  String get startPageTitle => 'WSI Browser';

  @override
  String get startPageSubtitle => '可用插件扩展的浏览器';

  @override
  String get startPageUrlHint => '输入 URL';

  @override
  String get startPageOpen => '打开';

  @override
  String get startPagePlugins => '插件';

  @override
  String get startPageSettings => '设置';

  @override
  String get startPageNoPlugins => '尚未安装插件';

  @override
  String get urlBarHint => 'URL 或搜索词';

  @override
  String urlBarBadgeTooltip(int count) {
    return '$count 个插件已启用';
  }

  @override
  String get actionBack => '后退';

  @override
  String get actionForward => '前进';

  @override
  String get actionReload => '刷新';

  @override
  String get actionStop => '停止';

  @override
  String get actionShare => '分享';

  @override
  String get actionNewTab => '新标签页';

  @override
  String get actionCloseTab => '关闭标签页';

  @override
  String get actionTabs => '标签页';

  @override
  String get actionHome => '主页';

  @override
  String get actionOpenExternal => '在外部浏览器中打开';

  @override
  String get actionCopyUrl => '复制 URL';

  @override
  String get tabsTitle => '标签页';

  @override
  String tabsLimitReached(int limit) {
    return '最多只能打开 $limit 个标签页';
  }

  @override
  String get tabUntitled => '(无标题)';

  @override
  String get dialogOk => '确定';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogClose => '关闭';

  @override
  String jsDialogTitle(String host) {
    return '来自 $host 的消息';
  }

  @override
  String downloadStarted(String name) {
    return '正在下载: $name';
  }

  @override
  String downloadDone(String name) {
    return '已保存: $name';
  }

  @override
  String downloadFailed(String reason) {
    return '下载失败: $reason';
  }

  @override
  String get externalLinkOpened => '已在外部浏览器中打开';

  @override
  String navigationBlocked(String url) {
    return '无法打开此 URL: $url';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionBrowser => '浏览器';

  @override
  String get settingsSectionPlugins => '插件';

  @override
  String get settingsSectionDeveloper => '开发者';

  @override
  String get settingsInitialUrl => '初始 URL';

  @override
  String get settingsInitialUrlDesc => '启动时打开的页面。留空则显示起始页';

  @override
  String get settingsTabLimit => '标签页上限';

  @override
  String get settingsExternalLinks => '外部链接处理';

  @override
  String get settingsExternalLinksDesc => '指向没有插件负责的网站的链接';

  @override
  String get settingsExternalLinksInApp => '在本应用内打开';

  @override
  String get settingsExternalLinksExternal => '在外部浏览器中打开';

  @override
  String get settingsUserAgent => 'User-Agent';

  @override
  String get settingsUserAgentDesc => '留空则与系统默认浏览器相同';

  @override
  String get settingsClearCookies => '清除 Cookie';

  @override
  String get settingsClearCookiesDesc => '所有网站的登录状态都会被清除';

  @override
  String get settingsClearCookiesConfirm => '要清除所有 Cookie 吗?';

  @override
  String get settingsClearCookiesDone => '已清除 Cookie';

  @override
  String get settingsUpdateCheck => '检查插件更新';

  @override
  String get settingsUpdateCheckDesc => '启动时及每天一次';

  @override
  String get settingsLogRetention => '日志保留条数';

  @override
  String get settingsDeveloperMode => '开发者模式';

  @override
  String get settingsDeveloperModeDesc => '启用从 URL 实时重载和 Web 检查器';

  @override
  String get settingsWebInspector => 'Web 检查器';

  @override
  String get settingsWebInspectorDesc =>
      'iOS 使用 Safari，Android 使用 chrome://inspect';

  @override
  String get settingsAbout => '版本';

  @override
  String get settingsSaved => '已保存';

  @override
  String get settingsEdit => '编辑';

  @override
  String get settingsUseDefault => '默认值';

  @override
  String commonError(String message) {
    return '错误: $message';
  }

  @override
  String get pluginsTitle => '插件';

  @override
  String get pluginsEmpty => '尚无插件。请导入 ZIP。';

  @override
  String get pluginsGlobalToggle => '启用插件';

  @override
  String get pluginsGlobalToggleOff => '所有插件已停止';

  @override
  String get pluginsImport => '导入';

  @override
  String pluginsCurrentHost(String host) {
    return '当前网站: $host';
  }

  @override
  String pluginVersion(String version) {
    return 'v$version';
  }

  @override
  String pluginUpdateAvailable(String version) {
    return '有更新: v$version';
  }

  @override
  String get pluginUpdate => '更新';

  @override
  String get pluginDelete => '删除';

  @override
  String pluginDeleteConfirm(String name) {
    return '要删除 $name 吗? 其保存的数据和设置也会一并删除。';
  }

  @override
  String get pluginDeleted => '已删除';

  @override
  String get pluginSettings => '设置';

  @override
  String get pluginExport => '导出 ZIP';

  @override
  String get pluginDetails => '详情';

  @override
  String get pluginDomains => '目标域名';

  @override
  String get pluginPermissions => '权限';

  @override
  String get pluginAuthor => '作者';

  @override
  String get pluginInstalledAt => '安装';

  @override
  String get pluginCheckUpdates => '检查更新';

  @override
  String get pluginLogs => '日志';

  @override
  String get importTitle => '导入插件';

  @override
  String get importFromFile => '选择文件';

  @override
  String get importFromUrl => '从 URL';

  @override
  String get importFromQr => '扫描二维码';

  @override
  String get importUrlHint => 'https://.../plugin.zip';

  @override
  String get importPreviewTitle => '确认导入';

  @override
  String importOverwrite(String version) {
    return '将覆盖相同 ID 的插件 (v$version)。已保存的数据会保留。';
  }

  @override
  String get importSensitive => '此插件请求以下权限';

  @override
  String get importConsent => '允许上述权限';

  @override
  String get importInstall => '安装';

  @override
  String importDone(String name) {
    return '已安装 $name';
  }

  @override
  String importFailed(String reason) {
    return '无法导入: $reason';
  }

  @override
  String get importDownloading => '正在下载...';

  @override
  String get importInsecureUrl => '非 https 的 URL 仅在开发者模式下可用';

  @override
  String get qrScanHint => '扫描包含 wsi://install 或 ZIP URL 的二维码';

  @override
  String get logsTitle => '日志';

  @override
  String get logsEmpty => '没有日志';

  @override
  String get logsClear => '清除';

  @override
  String get logsShare => '导出';

  @override
  String get logsFilterAll => '全部';

  @override
  String settingsPluginTitle(String name) {
    return '$name 的设置';
  }

  @override
  String get settingsPluginEmpty => '此插件没有设置项';

  @override
  String get permissionDesc_storage => '保存数据';

  @override
  String get permissionDesc_fetch => '网络访问';

  @override
  String get permissionDesc_credentials => '保存登录信息 (Keychain / Keystore)';

  @override
  String get permissionDesc_device => '读取设备 ID';

  @override
  String get permissionDesc_share => '分享面板';

  @override
  String get permissionDesc_files => '保存和选择文件';

  @override
  String get permissionDesc_clipboard => '写入剪贴板';

  @override
  String get permissionDesc_wakeLock => '防止屏幕休眠';

  @override
  String get permissionDesc_pip => '画中画';

  @override
  String get permissionDesc_blockResources => '阻止加载图片和媒体';

  @override
  String get permissionDesc_tabs => '在后台控制标签页';

  @override
  String get permissionDesc_pages => '显示自定义界面';

  @override
  String get permissionDesc_menu => '添加菜单项';

  @override
  String get permissionDesc_navigation => '拦截页面跳转';

  @override
  String get permissionDesc_policy => '从服务器获取策略值';

  @override
  String get permissionDesc_siteData => '清除目标站点的 Cookie 和站点数据';

  @override
  String get settingsWorkerTabLimit => 'Worker 标签页上限';

  @override
  String get settingsWorkerTabLimitDesc => '每个插件可同时打开的标签页数 (WSI.tabs)';

  @override
  String get backupTitle => '备份与恢复';

  @override
  String get backupDesc => '将插件数据和设置导出 / 导入为加密 JSON。不包含登录信息';

  @override
  String get backupPassword => '密码';

  @override
  String get backupPasswordHint => '至少 4 个字符。恢复时需要';

  @override
  String get backupExport => '导出 (分享)';

  @override
  String get backupRestore => '选择文件并恢复';

  @override
  String get backupExported => '已导出备份';

  @override
  String backupRestored(int count) {
    return '已恢复 $count 个插件';
  }

  @override
  String backupFailed(String reason) {
    return '失败: $reason';
  }

  @override
  String get backupRestoreConfirm => '将覆盖已安装插件的保存数据和设置。是否继续?';
}

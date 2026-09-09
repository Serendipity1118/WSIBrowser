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
}

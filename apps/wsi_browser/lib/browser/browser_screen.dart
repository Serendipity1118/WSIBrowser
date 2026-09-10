// The main screen: URL bar on top, one WebViewTab per tab kept alive in an
// IndexedStack, the start page rendered as a widget for tabs at wsi://start.
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../ui/host_settings_page.dart';
import '../ui/start_page.dart';
import 'app_menu.dart';
import 'navigation_policy.dart';
import 'tab_manager.dart';
import 'tab_switcher.dart';
import 'url_bar.dart';
import 'web_view_tab.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key, this.hooks = const WebViewTabHooks(), this.pluginSummary, this.onPlugins, this.menuSource});

  /// Runtime hooks handed to every WebViewTab (P2+).
  final WebViewTabHooks hooks;
  final Widget? pluginSummary;
  final VoidCallback? onPlugins;

  /// Plugin menu sections for the URL bar (P3).
  final AppMenuSource? menuSource;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Give JS dialogs a context to show on.
    AppScope.of(context).dialogs.contextProvider = () => mounted ? context : null;
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final tabs = services.tabs;
    return ListenableBuilder(
      listenable: widget.menuSource == null ? tabs : Listenable.merge([tabs, widget.menuSource!]),
      builder: (context, _) {
        final active = tabs.active;
        if (active == null) return const SizedBox.shrink();
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (active.canGoBack) {
              await active.controller?.goBack();
            } else if (!active.isStartPage) {
              await active.load(kStartPageUrl);
            } else if (tabs.tabs.length > 1) {
              tabs.close(active);
            }
          },
          child: Scaffold(
            body: Column(
              children: [
                UrlBar(
                  tab: active,
                  tabCount: tabs.tabs.length,
                  onSubmit: (text) => _open(active, text),
                  onBack: () => active.controller?.goBack(),
                  onForward: () => active.controller?.goForward(),
                  onReload: () => active.controller?.reload(),
                  onStop: () => active.controller?.stopLoading(),
                  onShare: () => _share(active),
                  onTabs: () => showTabSwitcher(context),
                  onNewTab: () => _newTab(context),
                  onHome: () => active.load(kStartPageUrl),
                  onSettings: () => _openSettings(context),
                  onOpenExternal: () => launchUrl(Uri.parse(active.url), mode: LaunchMode.externalApplication),
                  onPlugins: widget.onPlugins,
                  pluginSections: () => widget.menuSource?.sections ?? const [],
                ),
                Expanded(
                  child: IndexedStack(
                    index: tabs.activeIndex,
                    children: [
                      for (final tab in tabs.tabs)
                        _TabView(key: ValueKey('tab-${tab.id}'), tab: tab, hooks: widget.hooks, screen: this),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _open(BrowserTab tab, String text) {
    final uri = NavigationPolicy.normalizeInput(text);
    if (uri.scheme == 'about') return;
    if (uri.scheme == 'wsi') {
      widget.hooks.onAppLink?.call(uri);
      return;
    }
    tab.load(uri.toString());
  }

  void _newTab(BuildContext context) {
    final services = AppScope.of(context);
    final tab = services.tabs.open(kStartPageUrl);
    if (tab == null) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.tabsLimitReached(services.tabs.limit))));
    }
  }

  Future<void> _share(BrowserTab tab) async {
    if (tab.isStartPage) return;
    await SharePlus.instance.share(ShareParams(uri: Uri.parse(tab.url), title: tab.title.isEmpty ? null : tab.title));
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HostSettingsPage()));
  }
}

/// Start page or WebView for one tab. Keeps the WebView alive once created
/// (a tab that navigated away from the start page keeps its WebView even if
/// the user later returns to the start page, so history survives).
class _TabView extends StatefulWidget {
  const _TabView({super.key, required this.tab, required this.hooks, required this.screen});
  final BrowserTab tab;
  final WebViewTabHooks hooks;
  final _BrowserScreenState screen;

  @override
  State<_TabView> createState() => _TabViewState();
}

class _TabViewState extends State<_TabView> {
  bool _webViewCreated = false;

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    return ListenableBuilder(
      listenable: tab,
      builder: (context, _) {
        if (!tab.isStartPage) _webViewCreated = true;
        return Stack(
          children: [
            if (_webViewCreated)
              Offstage(
                offstage: tab.isStartPage,
                child: WebViewTab(tab: tab, hooks: widget.hooks),
              ),
            if (tab.isStartPage)
              StartPage(
                onOpen: (text) => widget.screen._open(tab, text),
                onSettings: () => widget.screen._openSettings(context),
                onPlugins: widget.screen.widget.onPlugins,
                pluginSummary: widget.screen.widget.pluginSummary,
              ),
          ],
        );
      },
    );
  }
}

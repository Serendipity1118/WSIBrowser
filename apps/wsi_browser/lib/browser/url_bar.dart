// URL bar (F-01-2): input, back / forward / reload / stop, share, plugin badge,
// tab count and the overflow menu. Pure presentation; actions are callbacks.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_menu.dart';
import 'tab_manager.dart';

class UrlBar extends StatefulWidget {
  const UrlBar({
    super.key,
    required this.tab,
    required this.tabCount,
    required this.onSubmit,
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.onStop,
    required this.onShare,
    required this.onTabs,
    required this.onNewTab,
    required this.onHome,
    required this.onSettings,
    required this.onOpenExternal,
    this.onPlugins,
    this.pluginSections = _noSections,
  });

  final BrowserTab tab;
  final int tabCount;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final VoidCallback onStop;
  final VoidCallback onShare;
  final VoidCallback onTabs;
  final VoidCallback onNewTab;
  final VoidCallback onHome;
  final VoidCallback onSettings;
  final VoidCallback onOpenExternal;
  final VoidCallback? onPlugins;

  /// Plugin-provided menu sections (F-08-2), shown after the host items.
  /// Read when the menu opens so registrations dropped while the screen was
  /// not rebuilt (a tab closing) never show stale items.
  final List<AppMenuSection> Function() pluginSections;

  @override
  State<UrlBar> createState() => _UrlBarState();
}

class _UrlBarState extends State<UrlBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _editing = _focus.hasFocus);
      if (_focus.hasFocus) {
        _controller.text = widget.tab.isStartPage ? '' : widget.tab.url;
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tab = widget.tab;
    final theme = Theme.of(context);

    if (!_editing) {
      _controller.text = tab.isStartPage ? '' : tab.url;
    }

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l.actionBack,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: tab.canGoBack ? widget.onBack : null,
                ),
                IconButton(
                  tooltip: l.actionForward,
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: tab.canGoForward ? widget.onForward : null,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          tab.url.startsWith('https://') ? Icons.lock_outline : Icons.public,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.go,
                            autocorrect: false,
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: l.urlBarHint,
                            ),
                            onSubmitted: (v) {
                              _focus.unfocus();
                              widget.onSubmit(v);
                            },
                          ),
                        ),
                        if (tab.pluginCount > 0)
                          Tooltip(
                            message: l.urlBarBadgeTooltip(tab.pluginCount),
                            child: Container(
                              key: const Key('plugin-badge'),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tab.pluginCount}',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ),
                        if (!tab.isStartPage)
                          IconButton(
                            tooltip: tab.isLoading ? l.actionStop : l.actionReload,
                            icon: Icon(tab.isLoading ? Icons.close : Icons.refresh, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: tab.isLoading ? widget.onStop : widget.onReload,
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.actionTabs,
                  onPressed: widget.onTabs,
                  icon: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.onSurface, width: 1.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('${widget.tabCount}', style: theme.textTheme.labelSmall),
                  ),
                ),
                PopupMenuButton<Object>(
                  onSelected: (item) {
                    if (item is _MenuItem) {
                      _onMenu(context, item);
                    } else if (item is AppMenuItem) {
                      item.onSelect?.call(item.type == AppMenuItemType.toggle ? !(item.checked ?? false) : null);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: _MenuItem.newTab, child: ListTile(leading: const Icon(Icons.add), title: Text(l.actionNewTab))),
                    PopupMenuItem(value: _MenuItem.home, child: ListTile(leading: const Icon(Icons.home_outlined), title: Text(l.actionHome))),
                    PopupMenuItem(value: _MenuItem.share, enabled: !tab.isStartPage, child: ListTile(leading: const Icon(Icons.share_outlined), title: Text(l.actionShare))),
                    PopupMenuItem(value: _MenuItem.copy, enabled: !tab.isStartPage, child: ListTile(leading: const Icon(Icons.copy_outlined), title: Text(l.actionCopyUrl))),
                    PopupMenuItem(value: _MenuItem.external, enabled: !tab.isStartPage, child: ListTile(leading: const Icon(Icons.open_in_browser), title: Text(l.actionOpenExternal))),
                    const PopupMenuDivider(),
                    if (widget.onPlugins != null)
                      PopupMenuItem(value: _MenuItem.plugins, child: ListTile(leading: const Icon(Icons.extension_outlined), title: Text(l.startPagePlugins))),
                    PopupMenuItem(value: _MenuItem.settings, child: ListTile(leading: const Icon(Icons.settings_outlined), title: Text(l.settingsTitle))),
                    for (final section in widget.pluginSections()) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem<Object>(
                        enabled: false,
                        height: 32,
                        child: Text(section.title, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                      ),
                      for (final item in section.items)
                        if (item.type == AppMenuItemType.separator)
                          const PopupMenuDivider()
                        else
                          PopupMenuItem<Object>(
                            value: item,
                            child: ListTile(
                              leading: item.type == AppMenuItemType.toggle
                                  ? Icon(item.checked == true ? Icons.check_box : Icons.check_box_outline_blank)
                                  : item.icon != null
                                      ? Text(item.icon!, style: const TextStyle(fontSize: 20))
                                      : Icon(item.type == AppMenuItemType.page ? Icons.article_outlined : Icons.play_arrow_outlined),
                              title: Text(item.label),
                            ),
                          ),
                    ],
                  ],
                ),
              ],
            ),
            if (tab.isLoading)
              LinearProgressIndicator(value: tab.progress > 0 && tab.progress < 1 ? tab.progress : null, minHeight: 2),
          ],
        ),
      ),
    );
  }

  void _onMenu(BuildContext context, _MenuItem item) {
    switch (item) {
      case _MenuItem.newTab:
        widget.onNewTab();
      case _MenuItem.home:
        widget.onHome();
      case _MenuItem.share:
        widget.onShare();
      case _MenuItem.copy:
        Clipboard.setData(ClipboardData(text: widget.tab.url));
      case _MenuItem.external:
        widget.onOpenExternal();
      case _MenuItem.plugins:
        widget.onPlugins?.call();
      case _MenuItem.settings:
        widget.onSettings();
    }
  }
}

enum _MenuItem { newTab, home, share, copy, external, plugins, settings }

List<AppMenuSection> _noSections() => const [];

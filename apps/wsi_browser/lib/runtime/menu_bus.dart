// WSI.menu (F-08, P3-04). Items are registered per bridge session: entries
// from a site page live as long as that injection (they vanish on
// navigation), entries from a worker persist (F-08-1). The URL bar shows one
// section per plugin, in the order plugins registered.
import 'package:flutter/material.dart';

import '../bridge_ops/registry.dart';
import '../browser/app_menu.dart';
import 'bridge.dart';
import 'manifest.dart';
import 'repository.dart';

class MenuEntry {
  MenuEntry({required this.id, required this.type, required this.label, this.icon, this.page, this.checked});
  final String id;
  final String type;
  final String label;
  final String? icon;
  final String? page;
  bool? checked;
}

class _Registration {
  _Registration(this.session, this.items);
  final BridgeSession session;
  List<MenuEntry> items;
}

typedef OpenPage = Future<void> Function(InstalledPlugin plugin, PluginPage page, Map<String, String>? params);

class MenuBus extends ChangeNotifier implements AppMenuSource {
  MenuBus({required this.bridge, required this.repository, required this.openPage});

  final Bridge bridge;
  final PluginRepository repository;
  final OpenPage openPage;

  /// pluginId -> registrations (one per session that called register)
  final Map<String, List<_Registration>> _byPlugin = {};

  void register(BridgeSession session, List<MenuEntry> items) {
    final list = _byPlugin.putIfAbsent(session.pluginId, () => []);
    final existing = list.where((r) => identical(r.session, session)).firstOrNull;
    if (existing != null) {
      existing.items = items;
    } else {
      list.add(_Registration(session, items));
    }
    notifyListeners();
  }

  /// Update label / checked of an item registered by any session of the plugin.
  bool update(String pluginId, String id, {String? label, bool? checked}) {
    var changed = false;
    for (final r in _byPlugin[pluginId] ?? const <_Registration>[]) {
      final index = r.items.indexWhere((e) => e.id == id);
      if (index < 0) continue;
      final e = r.items[index];
      r.items[index] = MenuEntry(id: e.id, type: e.type, label: label ?? e.label, icon: e.icon, page: e.page, checked: checked ?? e.checked);
      changed = true;
    }
    if (changed) notifyListeners();
    return changed;
  }

  /// Drop registrations of sessions that belong to a WebView (page navigated away / closed).
  void dropSessions(Object webViewKey) {
    var changed = false;
    for (final list in _byPlugin.values) {
      final before = list.length;
      list.removeWhere((r) => r.session.webViewKey == webViewKey || r.session.revoked);
      if (list.length != before) changed = true;
    }
    if (changed) notifyListeners();
  }

  void dropPlugin(String pluginId) {
    if (_byPlugin.remove(pluginId) != null) notifyListeners();
  }

  /// Remove revoked sessions (called before building the menu).
  void _prune() {
    for (final list in _byPlugin.values) {
      list.removeWhere((r) => r.session.revoked);
    }
  }

  @override
  List<AppMenuSection> get sections {
    _prune();
    final out = <AppMenuSection>[];
    for (final entry in _byPlugin.entries) {
      final plugin = repository.byId(entry.key);
      if (plugin == null || !plugin.enabled) continue;
      final items = <AppMenuItem>[];
      for (final r in entry.value) {
        for (final e in r.items) {
          items.add(_toItem(plugin, r.session, e));
        }
      }
      if (items.isNotEmpty) out.add(AppMenuSection(title: plugin.manifest.name, items: items));
    }
    return out;
  }

  AppMenuItem _toItem(InstalledPlugin plugin, BridgeSession session, MenuEntry e) {
    final type = switch (e.type) {
      'page' => AppMenuItemType.page,
      'toggle' => AppMenuItemType.toggle,
      'separator' => AppMenuItemType.separator,
      _ => AppMenuItemType.action,
    };
    return AppMenuItem(
      id: '${plugin.id}:${e.id}',
      type: type,
      label: e.label,
      icon: e.icon,
      checked: e.checked,
      onSelect: type == AppMenuItemType.separator
          ? null
          : (value) async {
              switch (type) {
                case AppMenuItemType.page:
                  final page = plugin.manifest.pages.where((p) => p.name == e.page).firstOrNull;
                  if (page != null) await openPage(plugin, page, null);
                  await bridge.emit(session, 'menu.select:${e.id}', {'id': e.id});
                case AppMenuItemType.toggle:
                  final next = value ?? !(e.checked ?? false);
                  update(plugin.id, e.id, checked: next);
                  await bridge.emit(session, 'menu.change:${e.id}', next);
                case AppMenuItemType.action:
                  await bridge.emit(session, 'menu.select:${e.id}', {'id': e.id});
                case AppMenuItemType.separator:
                  break;
              }
            },
    );
  }

  @visibleForTesting
  int registrationCount(String pluginId) => _byPlugin[pluginId]?.length ?? 0;
}

/// Currently open plugin pages (for WSI.ui.closePage).
class PageStack extends ChangeNotifier {
  final List<({String pluginId, String page})> _open = [];

  void push(String pluginId, String page) {
    _open.add((pluginId: pluginId, page: page));
    notifyListeners();
  }

  void pop(String pluginId, String page) {
    final i = _open.lastIndexWhere((e) => e.pluginId == pluginId && e.page == page);
    if (i >= 0) _open.removeAt(i);
    notifyListeners();
  }

  bool isOpen(String pluginId) => _open.any((e) => e.pluginId == pluginId);
  List<({String pluginId, String page})> get open => List.unmodifiable(_open);
}

/// Widget-side helper: pops the topmost route when a plugin asks to close its page.
void closeTopmostPluginPage(BuildContext context) {
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) nav.pop();
}

/// Pops every open plugin page of [pluginId] (ui.openUrl hands over to the site).
void closeAllPluginPages(BuildContext context, PageStack stack, String pluginId) {
  final nav = Navigator.of(context, rootNavigator: true);
  var n = stack.open.where((e) => e.pluginId == pluginId).length;
  while (n-- > 0 && nav.canPop()) {
    nav.pop();
  }
}

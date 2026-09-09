// Service locator for the widget tree. Everything long-lived (database,
// settings, tab manager, browser services) is created once in main.dart and
// reached through AppScope.of(context).
import 'package:flutter/widgets.dart';

import '../browser/cookie_store.dart';
import '../browser/file_chooser.dart';
import '../browser/js_dialogs.dart';
import '../browser/navigation_policy.dart';
import '../browser/tab_manager.dart';
import '../db/database.dart';
import '../settings/host_settings.dart';

class AppServices {
  AppServices({
    required this.db,
    required this.settings,
    required this.tabs,
    required this.cookies,
    required this.downloader,
    required this.dialogs,
    required this.navigation,
  });

  final AppDatabase db;
  final HostSettings settings;
  final TabManager tabs;
  final CookieStore cookies;
  final Downloader downloader;
  final JsDialogs dialogs;
  final NavigationPolicy navigation;

  /// Plugins active on [host]. P2 replaces this with the runtime's matcher.
  bool Function(String host) isPluginHost = (_) => true;

  /// Services added by later phases (P2: 'runtime'). Keeps this class free of
  /// runtime imports so the browser layer stays plugin-agnostic.
  final Map<String, Object> extras = {};

  static AppServices create(AppDatabase db) {
    final settings = HostSettings(db);
    final cookies = CookieStore(settings);
    late AppServices services;
    services = AppServices(
      db: db,
      settings: settings,
      tabs: TabManager(tabLimit: () => settings.tabLimit),
      cookies: cookies,
      downloader: Downloader(cookies),
      dialogs: JsDialogs(contextProvider: () => null),
      navigation: NavigationPolicy(
        externalLinks: () => settings.externalLinks,
        isPluginHost: (host) => services.isPluginHost(host),
      ),
    );
    return services;
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found above this widget');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}

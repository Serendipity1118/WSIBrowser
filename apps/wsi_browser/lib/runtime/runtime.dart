// PluginRuntime: wires repository, bridge, ops, injector, importer and the
// update checker together and exposes them to the browser through
// WebViewTabHooks (P1's connection points). The browser never learns what a
// plugin is; it only forwards WebView events here.
import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../app/app_scope.dart';
import '../bridge_ops/fetch_ops.dart';
import '../bridge_ops/log_ops.dart';
import '../bridge_ops/registry.dart';
import '../bridge_ops/settings_ops.dart';
import '../bridge_ops/storage_ops.dart';
import '../bridge_ops/ui_ops.dart';
import '../browser/tab_manager.dart';
import '../browser/web_view_tab.dart';
import 'bridge.dart';
import 'dev_reloader.dart';
import 'importer.dart';
import 'injector.dart';
import 'log_sink.dart';
import 'repository.dart';
import 'update_checker.dart';

class PluginRuntime {
  PluginRuntime(this.services)
      : repository = PluginRepository(services.db, services.settings),
        logs = LogSink(services.db, services.settings),
        registry = OpRegistry(),
        importer = ZipImporter() {
    bridge = Bridge(repository: repository, registry: registry, logs: logs);
    settingsStore = PluginSettingsStore(services.db);
    updateChecker = UpdateChecker(repository, services.settings);
    devReloader = DevReloader(importer: importer, repository: repository, logs: logs, tabs: services.tabs);
    registerStorageOps(registry, services.db);
    registerFetchOps(registry, services.cookies);
    registerLogOps(registry, logs);
    registerUiOps(registry, () => services.dialogs.contextProvider());
    registerSettingsOps(registry, settingsStore, bridge);
  }

  final AppServices services;
  final PluginRepository repository;
  final LogSink logs;
  final OpRegistry registry;
  final ZipImporter importer;
  late final Bridge bridge;
  late final PluginSettingsStore settingsStore;
  late final UpdateChecker updateChecker;
  late final Injector injector;
  late final DevReloader devReloader;

  /// Set by the app layer: called for wsi://install?url=... and wsi://dev?url=...
  Future<bool> Function(Uri url)? onAppLink;

  final Map<int, InAppWebViewController> _controllers = {};

  static const sdkAsset = 'assets/sdk/wsi-sdk-core.js';

  Future<void> init() async {
    final sdk = await rootBundle.loadString(sdkAsset);
    injector = Injector(sdkSource: sdk, repository: repository, bridge: bridge, logs: logs);
    await repository.load();
    services.isPluginHost = repository.isPluginHost;
    repository.addListener(_onPluginsChanged);
    unawaited(updateChecker.checkAll());
  }

  WebViewTabHooks get hooks => WebViewTabHooks(
        userScripts: () => injector.initialUserScripts(),
        onWebViewCreated: (tab, controller) {
          _controllers[tab.id] = controller;
          unawaited(injector.attach(controller, tab));
        },
        onWebViewDisposed: (tab, controller) {
          _controllers.remove(tab.id);
          injector.detach(controller, tab);
        },
        onLoadStart: (tab, controller, url) async {
          injector.onLoadStart(controller, tab, url);
          tab.update(pluginCount: repository.forUrl(url).length);
        },
        onLoadStop: (tab, controller, url) async {
          final n = await injector.onLoadStop(controller, tab, url);
          tab.update(pluginCount: n);
        },
        onUpdateVisitedHistory: (tab, controller, url) async {
          final n = await injector.onUrlChanged(controller, tab, url);
          tab.update(pluginCount: n);
        },
        onAppLink: (url) async => (await onAppLink?.call(url)) ?? false,
      );

  /// Plugins changed (install / enable / delete): rebuild the UserScripts of
  /// every open tab so the next load picks the change up (F-02-4).
  void _onPluginsChanged() {
    for (final entry in _controllers.entries) {
      final tab = services.tabs.tabs.where((t) => t.id == entry.key).firstOrNull;
      unawaited(injector.rebuildUserScripts(entry.value, tab));
    }
    _refreshBadges();
  }

  void _refreshBadges() {
    for (final tab in services.tabs.tabs) {
      if (tab.isStartPage) continue;
      final uri = Uri.tryParse(tab.url);
      if (uri != null) tab.update(pluginCount: repository.forUrl(uri).length);
    }
  }

  /// The controller of a tab (used by the plugin list to reload the current tab).
  InAppWebViewController? controllerOf(BrowserTab tab) => _controllers[tab.id];

  void dispose() {
    repository.removeListener(_onPluginsChanged);
  }
}

/// Access from widgets: AppServices carries the runtime once initialised.
extension RuntimeAccess on AppServices {
  PluginRuntime get runtime => extras['runtime'] as PluginRuntime;
  PluginRuntime? get runtimeOrNull => extras['runtime'] as PluginRuntime?;
}

/// Convenience for widgets.
PluginRuntime runtimeOf(BuildContext context) => AppScope.of(context).runtime;

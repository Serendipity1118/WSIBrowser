// PluginRuntime: wires repository, bridge, ops, injector, importer and the
// update checker together and exposes them to the browser through
// WebViewTabHooks (P1's connection points). The browser never learns what a
// plugin is; it only forwards WebView events here.
import 'dart:async';

import 'dart:io' show Platform;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../app/app_scope.dart';
import '../bridge_ops/block_resources_ops.dart';
import '../bridge_ops/site_data_ops.dart';
import '../bridge_ops/credentials_ops.dart';
import '../bridge_ops/fetch_ops.dart';
import '../bridge_ops/native_ops.dart';
import '../bridge_ops/log_ops.dart';
import '../bridge_ops/menu_ops.dart';
import '../bridge_ops/policy_ops.dart';
import '../bridge_ops/runtime_ops.dart';
import '../bridge_ops/registry.dart';
import '../bridge_ops/settings_ops.dart';
import '../bridge_ops/storage_ops.dart';
import '../bridge_ops/tabs_ops.dart';
import '../bridge_ops/ui_ops.dart';
import '../browser/tab_manager.dart';
import '../browser/web_view_tab.dart';
import '../ui/plugin_page_view.dart';
import 'backup.dart';
import 'bridge.dart';
import 'dev_reloader.dart';
import 'importer.dart';
import 'injector.dart';
import 'log_sink.dart';
import 'manifest.dart';
import 'menu_bus.dart';
import 'page_host.dart';
import 'policy_cache.dart';
import 'repository.dart';
import 'resource_blocker.dart';
import 'tab_controller.dart';
import 'update_checker.dart';
import 'worker_manager.dart';
import 'domain_matcher.dart';

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
    policyCache = PolicyStore(services.db, repository, logs);
    pageHost = PageHost(repository);
    pageStack = PageStack();
    menuBus = MenuBus(bridge: bridge, repository: repository, openPage: openPage);
    registerStorageOps(registry, services.db);
    registerFetchOps(registry, services.cookies);
    registerLogOps(registry, logs);
    registerUiOps(registry, () => services.dialogs.contextProvider(), openPage: openPage);
    registerSettingsOps(registry, settingsStore, bridge);
    registerPolicyOps(registry, policyCache);
    registerMenuOps(registry, menuBus);
    registerRuntimeOps(registry, bridge);
    // native features (P5)
    resourceBlocker = ResourceBlocker(repository);
    wakeLocks = WakeLockRegistry();
    backup = BackupService(services.db, repository);
    registerCredentialsOps(registry);
    registerDeviceOps(registry);
    registerShareOps(registry);
    registerFilesOps(registry);
    registerClipboardOps(registry);
    registerWakeLockOps(registry, wakeLocks);
    registerPipOps(registry, PipChannel());
    registerBlockResourcesOps(registry, resourceBlocker);
    registerSiteDataOps(registry);
  }

  /// WSI.navigation.intercept (F-01-3, P4-08): ask every running worker whose
  /// plugin has the 'navigation' permission and matches the target host.
  Future<String?> _interceptNavigation(Uri url) async {
    for (final handle in workers.workers.values) {
      final plugin = repository.byId(handle.pluginId);
      final session = handle.session;
      if (plugin == null || session == null || !plugin.manifest.has('navigation')) continue;
      if (!matchesDomain(url.host, plugin.manifest.domains)) continue;
      final verdict = await bridge.emit(session, 'navigation.intercept', url.toString()).timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (verdict == 'allow' || verdict == 'deny' || verdict == 'external') return verdict as String;
    }
    return null;
  }

  /// Open a plugin page on the browser screen (menu, WSI.ui.openPage, workers).
  Future<void> openPage(InstalledPlugin plugin, PluginPage page, Map<String, String>? params) async {
    final context = services.dialogs.contextProvider();
    if (context == null || !context.mounted) {
      logs.add(pluginId: plugin.id, level: 'warn', message: 'openPage(${page.name}): no UI available');
      return;
    }
    await openPluginPage(context, this, plugin, page, params: params);
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
  late final PolicyStore policyCache;
  late final PageHost pageHost;
  late final PageStack pageStack;
  late final MenuBus menuBus;
  late final WorkerManager workers;
  late final TabController tabController;
  late final ResourceBlocker resourceBlocker;
  late final WakeLockRegistry wakeLocks;
  late final BackupService backup;

  /// Set by the app layer: called for wsi://install?url=... and wsi://dev?url=...
  Future<bool> Function(Uri url)? onAppLink;

  final Map<int, InAppWebViewController> _controllers = {};

  static const sdkAsset = 'assets/sdk/wsi-sdk-core.js';

  Future<void> init() async {
    final sdk = await rootBundle.loadString(sdkAsset);
    injector = Injector(sdkSource: sdk, repository: repository, bridge: bridge, logs: logs);
    workers = WorkerManager(db: services.db, settings: services.settings, repository: repository, bridge: bridge, injector: injector, logs: logs, menuBus: menuBus);
    tabController = TabController(
      bridge: bridge,
      injector: injector,
      logs: logs,
      tabs: services.tabs,
      cookies: services.cookies,
      dialogs: services.dialogs,
      limitPerPlugin: () => services.settings.workerTabLimit,
    );
    registerTabsOps(registry, tabController);
    services.navigation.asyncInterceptor = _interceptNavigation;
    await repository.load();
    services.isPluginHost = repository.isPluginHost;
    repository.addListener(_onPluginsChanged);
    _lastWsiEnabled = services.settings.wsiEnabled;
    services.settings.addListener(_onSettingsChanged);
    unawaited(updateChecker.checkAll());
    unawaited(policyCache.refreshAll());
    unawaited(workers.sync());
  }

  bool _lastWsiEnabled = true;
  void _onSettingsChanged() {
    final enabled = services.settings.wsiEnabled;
    if (enabled != _lastWsiEnabled) {
      _lastWsiEnabled = enabled;
      unawaited(workers.sync().then((_) => _closeOrphanTabs()));
      _refreshBadges();
    }
  }

  WebViewTabHooks get hooks => WebViewTabHooks(
        userScripts: () => injector.initialUserScripts(),
        onWebViewCreated: (tab, controller) {
          _controllers[tab.id] = controller;
          unawaited(injector.attach(controller, tab));
        },
        onWebViewDisposed: (tab, controller) {
          _controllers.remove(tab.id);
          menuBus.dropSessions(Injector.keyOf(tab, controller));
          injector.detach(controller, tab);
          tabController.onBrowserTabClosed(tab);
        },
        onLoadStart: (tab, controller, url) async {
          // page-registered menu items die with the document (F-08-1)
          menuBus.dropSessions(Injector.keyOf(tab, controller));
          injector.onLoadStart(controller, tab, url);
          tabController.onBrowserTabLoadStart(tab, url);
          tab.update(pluginCount: repository.forUrl(url).length);
        },
        onLoadStop: (tab, controller, url) async {
          final n = await injector.onLoadStop(controller, tab, url);
          tab.update(pluginCount: n);
          tabController.onBrowserTabLoadStop(tab, controller, url);
        },
        onUpdateVisitedHistory: (tab, controller, url) async {
          final n = await injector.onUrlChanged(controller, tab, url);
          tab.update(pluginCount: n);
        },
        onAppLink: (url) async => (await onAppLink?.call(url)) ?? false,
        shouldInterceptRequest: Platform.isAndroid ? _interceptRequest : null,
        beforeLoad: Platform.isIOS ? _applyContentBlockers : null,
      );

  Future<WebResourceResponse?> _interceptRequest(BrowserTab tab, WebResourceRequest request) async {
    if (resourceBlocker.rules.isEmpty) return null;
    final host = Uri.tryParse(tab.url)?.host ?? '';
    return resourceBlocker.shouldBlock(host, request) ? ResourceBlocker.blockedResponse() : null;
  }

  Future<void> _applyContentBlockers(BrowserTab tab, InAppWebViewController controller, Uri url) async {
    final blockers = resourceBlocker.contentBlockersFor(url.host);
    try {
      await controller.setSettings(settings: InAppWebViewSettings(contentBlockers: blockers));
    } catch (e) {
      logs.add(level: 'warn', message: 'contentBlockers failed: $e');
    }
  }

  /// Plugins changed (install / enable / delete): rebuild the UserScripts of
  /// every open tab so the next load picks the change up (F-02-4).
  void _onPluginsChanged() {
    for (final p in repository.all) {
      if (!p.enabled) {
        menuBus.dropPlugin(p.id);
        resourceBlocker.clear(p.id);
        unawaited(wakeLocks.releaseAll(p.id));
      }
    }
    for (final id in resourceBlocker.rules.keys.toList()) {
      if (repository.byId(id) == null) resourceBlocker.clear(id);
    }
    unawaited(workers.sync().then((_) => _closeOrphanTabs()));
    for (final entry in _controllers.entries) {
      final tab = services.tabs.tabs.where((t) => t.id == entry.key).firstOrNull;
      unawaited(injector.rebuildUserScripts(entry.value, tab));
    }
    _refreshBadges();
  }

  /// Tabs of plugins whose worker is gone are closed with it.
  void _closeOrphanTabs() {
    for (final t in tabController.all.values.toList()) {
      if (workers.handleOf(t.pluginId) == null) unawaited(tabController.closeAll(t.pluginId));
    }
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
    services.settings.removeListener(_onSettingsChanged);
    workers.dispose();
  }
}

/// Access from widgets: AppServices carries the runtime once initialised.
extension RuntimeAccess on AppServices {
  PluginRuntime get runtime => extras['runtime'] as PluginRuntime;
  PluginRuntime? get runtimeOrNull => extras['runtime'] as PluginRuntime?;
}

/// Convenience for widgets.
PluginRuntime runtimeOf(BuildContext context) => AppScope.of(context).runtime;

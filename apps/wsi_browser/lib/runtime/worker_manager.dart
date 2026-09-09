// Workers (F-05, P4-01 / P4-09). A plugin with `background` in plugin.json
// runs that script in a HeadlessInAppWebView whose document is
// wsi://plugin/<id>/__worker.html (served by PageHost). The SDK core and the
// runner are document-start UserScripts, so the worker code executes with a
// `WSI` whose DOM APIs throw (context 'worker').
//
// Lifecycle: start at app start / enable, stop at disable / delete / global
// off, restart with exponential backoff (1, 2, 4, 8, 16 s; max 5) when the
// web content process dies. Background transitions emit runtime.suspend /
// runtime.resume and are recorded in worker_state.
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bridge_ops/registry.dart';
import '../db/database.dart';
import '../settings/host_settings.dart';
import 'bridge.dart';
import 'injector.dart';
import 'log_sink.dart';
import 'menu_bus.dart';
import 'page_host.dart';
import 'repository.dart';

class WorkerHandle {
  WorkerHandle({required this.pluginId, required this.key});
  final String pluginId;
  final Object key;
  HeadlessInAppWebView? webView;
  InAppWebViewController? controller;
  BridgeSession? session;
  int restartCount = 0;
  Timer? restartTimer;
  bool stopping = false;
  bool suspended = false;
  DateTime? startedAt;
  /// updatedAt of the plugin whose code this worker runs; a newer install
  /// (update / reinstall, dev reload) restarts the worker in [WorkerManager.sync].
  DateTime? codeUpdatedAt;
}

class WorkerManager extends ChangeNotifier {
  WorkerManager({
    required this.db,
    required this.settings,
    required this.repository,
    required this.bridge,
    required this.injector,
    required this.logs,
    required this.menuBus,
  });

  final AppDatabase db;
  final HostSettings settings;
  final PluginRepository repository;
  final Bridge bridge;
  final Injector injector;
  final LogSink logs;
  final MenuBus menuBus;

  static const maxRestarts = 5;
  static const suspendTimeout = Duration(seconds: 3);

  final Map<String, WorkerHandle> _workers = {};
  bool _appSuspended = false;

  Map<String, WorkerHandle> get workers => UnmodifiableMapView(_workers);
  WorkerHandle? handleOf(String pluginId) => _workers[pluginId];
  BridgeSession? sessionOf(String pluginId) => _workers[pluginId]?.session;
  bool get isSuspended => _appSuspended;

  static Object keyFor(String pluginId) => 'worker:$pluginId';

  /// Start workers for every enabled plugin that declares one; stop the rest.
  Future<void> sync() async {
    final wanted = <String>{};
    if (settings.wsiEnabled) {
      for (final p in repository.all) {
        if (p.enabled && p.manifest.background != null) wanted.add(p.id);
      }
    }
    for (final id in _workers.keys.toList()) {
      if (!wanted.contains(id)) await stop(id);
    }
    for (final id in wanted) {
      final running = _workers[id];
      if (running == null) {
        await start(id);
        continue;
      }
      final installed = repository.byId(id);
      if (installed != null && running.codeUpdatedAt != null && installed.updatedAt != running.codeUpdatedAt) {
        logs.add(pluginId: id, level: 'info', message: 'plugin updated, restarting worker');
        await restart(id);
      }
    }
  }

  Future<void> start(String pluginId, {bool restart = false}) async {
    final plugin = repository.byId(pluginId);
    if (plugin == null || plugin.manifest.background == null) return;
    final existing = _workers[pluginId];
    if (existing != null && !restart) return;

    final handle = existing ?? WorkerHandle(pluginId: pluginId, key: keyFor(pluginId));
    handle.stopping = false;
    handle.codeUpdatedAt = plugin.updatedAt;
    _workers[pluginId] = handle;

    final code = await repository.code(pluginId);
    final workerJs = code.workerJs ?? '';
    final session = bridge.issue(pluginId: pluginId, webViewKey: handle.key, context: BridgeContext.worker, origin: PageHost.workerUrl(pluginId));
    handle.session = session;

    final spec = jsonEncode({
      'pluginId': pluginId,
      'config': plugin.manifest.config,
      'code': workerJs,
      'permissions': plugin.manifest.permissions,
      'token': session.token,
      'context': 'worker',
    });

    final webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri.uri(PageHost.workerUrl(pluginId))),
      initialSettings: InAppWebViewSettings(
        resourceCustomSchemes: const [PageHost.scheme],
        javaScriptEnabled: true,
        isInspectable: settings.developerMode && settings.webInspector,
        allowFileAccess: false,
      ),
      initialUserScripts: UnmodifiableListView([
        ...injector.initialUserScripts(),
        UserScript(
          groupName: 'wsi-worker',
          source: 'if (typeof globalThis.__wsiRun === "function") { var r = globalThis.__wsiRun($spec); if (r && !r.ok) console.error("[WSI] worker failed: " + r.reason); }',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: true,
        ),
      ]),
      onWebViewCreated: (controller) {
        handle.controller = controller;
        bridge.attach(controller, handle.key);
        bridge.rebind(session, controller);
      },
      onLoadResourceWithCustomScheme: (controller, request) async {
        final url = request.url.uriValue;
        if (PageHost.isWorkerUrl(url, pluginId)) {
          return CustomSchemeResponse(data: utf8.encode(PageHost.workerHtml(pluginId)), contentType: 'text/html', contentEncoding: 'utf-8');
        }
        return _pageHostResolve(request, pluginId);
      },
      onLoadStop: (controller, url) async {
        handle.startedAt = DateTime.now();
        await _record(pluginId, startedAt: handle.startedAt, error: null);
        logs.add(pluginId: pluginId, level: 'info', message: 'worker started${restart ? ' (restart ${handle.restartCount})' : ''}');
        notifyListeners();
      },
      onConsoleMessage: (controller, message) {
        if (message.messageLevel == ConsoleMessageLevel.ERROR) {
          logs.add(pluginId: pluginId, level: 'error', message: 'worker: ${message.message}');
        }
      },
      onRenderProcessGone: (controller, detail) async {
        await _crashed(handle, 'render process gone (${detail.didCrash == true ? 'crash' : 'killed'})');
      },
      onWebContentProcessDidTerminate: (controller) async {
        await _crashed(handle, 'web content process terminated');
      },
    );
    handle.webView = webView;
    try {
      await webView.run();
    } catch (e) {
      logs.add(pluginId: pluginId, level: 'error', message: 'worker failed to start: $e');
      await _record(pluginId, error: '$e');
    }
    notifyListeners();
  }

  Future<CustomSchemeResponse?> _pageHostResolve(WebResourceRequest request, String pluginId) async {
    final parsed = PageHost.parse(request.url.uriValue);
    if (parsed == null || parsed.pluginId != pluginId) return null;
    final bytes = await repository.readFile(pluginId, parsed.path);
    if (bytes == null) return null;
    return CustomSchemeResponse(data: bytes, contentType: 'application/octet-stream', contentEncoding: 'binary');
  }

  Future<void> _crashed(WorkerHandle handle, String reason) async {
    if (handle.stopping) return;
    logs.add(pluginId: handle.pluginId, level: 'error', message: 'worker crashed: $reason');
    await _record(handle.pluginId, error: reason, restartCount: handle.restartCount + 1);
    await _dispose(handle);
    if (handle.restartCount >= maxRestarts) {
      logs.add(pluginId: handle.pluginId, level: 'error', message: 'worker gave up after $maxRestarts restarts');
      _workers.remove(handle.pluginId);
      notifyListeners();
      return;
    }
    handle.restartCount++;
    final delay = Duration(seconds: 1 << (handle.restartCount - 1));
    handle.restartTimer = Timer(delay, () => start(handle.pluginId, restart: true));
  }

  Future<void> stop(String pluginId) async {
    final handle = _workers.remove(pluginId);
    if (handle == null) return;
    handle.stopping = true;
    handle.restartTimer?.cancel();
    await _dispose(handle);
    logs.add(pluginId: pluginId, level: 'info', message: 'worker stopped');
    notifyListeners();
  }

  Future<void> _dispose(WorkerHandle handle) async {
    final session = handle.session;
    if (session != null) bridge.revoke(session);
    menuBus.dropSessions(handle.key);
    bridge.revokeForWebView(handle.key);
    try {
      await handle.webView?.dispose();
    } catch (_) {}
    handle.webView = null;
    handle.controller = null;
    handle.session = null;
  }

  Future<void> stopAll() async {
    for (final id in _workers.keys.toList()) {
      await stop(id);
    }
  }

  /// Restart on demand (e.g. after a code update).
  Future<void> restart(String pluginId) async {
    await stop(pluginId);
    await start(pluginId);
  }

  // ---- suspend / resume (F-05-2) --------------------------------------------

  Future<void> suspendAll() async {
    if (_appSuspended) return;
    _appSuspended = true;
    for (final handle in _workers.values) {
      final session = handle.session;
      if (session == null || handle.suspended) continue;
      handle.suspended = true;
      try {
        await bridge.emit(session, 'runtime.suspend', {}).timeout(suspendTimeout);
      } catch (e) {
        logs.add(pluginId: handle.pluginId, level: 'warn', message: 'suspend handler timed out: $e');
      }
      await _record(handle.pluginId, suspendedAt: DateTime.now());
    }
    notifyListeners();
  }

  Future<void> resumeAll() async {
    if (!_appSuspended) return;
    _appSuspended = false;
    for (final handle in _workers.values) {
      final session = handle.session;
      if (session == null || !handle.suspended) continue;
      handle.suspended = false;
      await bridge.emit(session, 'runtime.resume', {});
      await _record(handle.pluginId, clearSuspended: true);
    }
    notifyListeners();
  }

  Future<void> _record(String pluginId, {DateTime? startedAt, String? error, int? restartCount, DateTime? suspendedAt, bool clearSuspended = false}) async {
    try {
      await db.into(db.workerState).insertOnConflictUpdate(WorkerStateCompanion(
        pluginId: Value(pluginId),
        lastStartedAt: startedAt != null ? Value(startedAt) : const Value.absent(),
        lastError: error != null ? Value(error) : (startedAt != null ? const Value(null) : const Value.absent()),
        restartCount: restartCount != null ? Value(restartCount) : const Value.absent(),
        suspendedAt: clearSuspended ? const Value(null) : (suspendedAt != null ? Value(suspendedAt) : const Value.absent()),
      ));
    } catch (e) {
      debugPrint('worker_state update failed: $e');
    }
  }

  @override
  void dispose() {
    unawaited(stopAll());
    super.dispose();
  }
}

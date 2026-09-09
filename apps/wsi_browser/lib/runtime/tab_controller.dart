// WSI.tabs (F-06, P4-03 .. P4-07): tabs a worker opens and drives.
//
//   hidden: true   -> HeadlessInAppWebView owned by this controller
//   hidden: false  -> a normal BrowserTab through TabManager (visible to the user)
//
// Both kinds get plugins injected like any site tab (through Injector with an
// explicit WebView key), report onLoad / onClose to the owning worker, and
// forward JS dialogs to WSI.tabs.onDialog. On iOS a headless WebView is
// recreated on every navigate (F-06-4); Android reuses it.
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bridge_ops/registry.dart';
import '../browser/cookie_store.dart';
import '../browser/js_dialogs.dart';
import '../browser/tab_manager.dart';
import 'bridge.dart';
import 'injector.dart';
import 'log_sink.dart';

class WorkerTab {
  WorkerTab({required this.id, required this.pluginId, required this.hidden, required this.owner});

  final String id;
  final String pluginId;
  final bool hidden;

  /// The worker session that opened the tab (events go there).
  final BridgeSession owner;

  HeadlessInAppWebView? headless;
  BrowserTab? browserTab;
  InAppWebViewController? controller;
  Uri? url;
  bool loading = false;
  Completer<void>? _loaded;

  Object get key => 'wtab:$id';

  Future<void> waitLoaded({Duration timeout = const Duration(seconds: 60)}) {
    final c = _loaded;
    if (c == null || c.isCompleted) return Future.value();
    return c.future.timeout(timeout, onTimeout: () {});
  }
}

class TabController {
  TabController({
    required this.bridge,
    required this.injector,
    required this.logs,
    required this.tabs,
    required this.cookies,
    required this.dialogs,
    required this.limitPerPlugin,
  });

  final Bridge bridge;
  final Injector injector;
  final LogSink logs;
  final TabManager tabs;
  final CookieStore cookies;
  final JsDialogs dialogs;
  final int Function() limitPerPlugin;

  final Map<String, WorkerTab> _tabs = {};
  int _next = 1;

  /// Default dialog answer per plugin, declared by WSI.tabs.onDialog (F-06-1).
  final Map<String, String> dialogPolicies = {};

  /// Android runs every WebView in one renderer process, so a blocking
  /// alert() in a hidden tab also freezes the worker's JS: the worker cannot
  /// be asked while the dialog is pending. iOS (WKWebView) can.
  bool get canAskWorkerDuringDialog => Platform.isIOS;

  /// F-06-4 planned to reuse the headless WebView on Android and recreate it
  /// on iOS, but on Android (emulator, API 36) a second loadUrl on a
  /// HeadlessInAppWebView never started loading either, so every navigate
  /// recreates the WebView on both platforms. Visible tabs are reused.
  bool get recreateOnNavigate => true;

  /// Kept for the platform check in logs / diagnostics.
  bool get isIOS => Platform.isIOS;

  Map<String, WorkerTab> get all => UnmodifiableMapView(_tabs);

  List<Map<String, Object?>> list(String pluginId) => [
        for (final t in _tabs.values)
          if (t.pluginId == pluginId) {'tabId': t.id, 'url': t.url?.toString(), 'hidden': t.hidden, 'loading': t.loading},
      ];

  WorkerTab _require(String pluginId, String tabId) {
    final t = _tabs[tabId];
    if (t == null || t.pluginId != pluginId) throw OpError('tabs: unknown tab "$tabId"');
    return t;
  }

  Future<String> open(BridgeSession owner, Uri url, {bool hidden = true}) async {
    final mine = _tabs.values.where((t) => t.pluginId == owner.pluginId).length;
    if (mine >= limitPerPlugin()) throw OpError('tabs.open: limit of ${limitPerPlugin()} tabs per plugin reached');
    final tab = WorkerTab(id: 'w${_next++}', pluginId: owner.pluginId, hidden: hidden, owner: owner);
    _tabs[tab.id] = tab;
    if (hidden) {
      await _createHeadless(tab, url);
    } else {
      final bt = tabs.open(url.toString(), activate: true);
      if (bt == null) {
        _tabs.remove(tab.id);
        throw OpError('tabs.open: the browser tab limit is reached');
      }
      tab.browserTab = bt;
      tab.url = url;
      tab.loading = true;
      tab._loaded = Completer<void>();
      // the visible tab's WebView is created by the browser; the runtime hooks
      // report its events through [attachBrowserTab] / [onBrowserTabLoad]
    }
    logs.add(pluginId: owner.pluginId, level: 'info', message: 'tabs.open ${tab.id} ${hidden ? '(hidden)' : '(visible)'} $url');
    return tab.id;
  }

  Future<void> navigate(String pluginId, String tabId, Uri url) async {
    final tab = _require(pluginId, tabId);
    logs.add(pluginId: pluginId, level: 'info', message: 'tabs.navigate ${tab.id} $url');
    tab.url = url;
    tab.loading = true;
    tab._loaded = Completer<void>();
    if (tab.hidden && (recreateOnNavigate || tab.controller == null)) {
      await _disposeHeadless(tab);
      logs.add(pluginId: pluginId, level: 'info', message: 'tab ${tab.id} disposed, recreating');
      await _createHeadless(tab, url);
      logs.add(pluginId: pluginId, level: 'info', message: 'tab ${tab.id} recreated');
      return;
    }
    final c = tab.controller ?? tab.browserTab?.controller;
    if (c == null) throw OpError('tabs.navigate: tab has no WebView yet');
    if (tab.browserTab != null) {
      await tab.browserTab!.load(url.toString());
    } else {
      await c.loadUrl(urlRequest: URLRequest(url: WebUri.uri(url)));
    }
  }

  /// Evaluate [code] in the tab. Expressions and statements both work and
  /// promises are awaited (eval inside an async function).
  Future<Object?> run(String pluginId, String tabId, String code) async {
    final tab = _require(pluginId, tabId);
    final c = tab.controller ?? tab.browserTab?.controller;
    if (c == null) throw OpError('tabs.run: tab has no WebView yet');
    final result = await c.callAsyncJavaScript(functionBody: 'return await (async () => eval(${jsonEncode(code)}))();');
    if (result == null) return null;
    if (result.error != null) throw OpError('tabs.run: ${result.error}');
    return result.value;
  }

  Future<void> close(String pluginId, String tabId) async {
    final tab = _require(pluginId, tabId);
    await _close(tab, notify: false);
  }

  Future<void> _close(WorkerTab tab, {bool notify = true}) async {
    _tabs.remove(tab.id);
    if (tab.hidden) {
      await _disposeHeadless(tab);
    } else {
      final bt = tab.browserTab;
      if (bt != null && tabs.tabs.contains(bt)) tabs.close(bt);
    }
    if (notify) await bridge.emit(tab.owner, 'tabs.close', {'tabId': tab.id});
    logs.add(pluginId: tab.pluginId, level: 'info', message: 'tabs.close ${tab.id}');
  }

  /// Close every tab of a plugin (worker stopped).
  Future<void> closeAll(String pluginId) async {
    for (final t in _tabs.values.where((t) => t.pluginId == pluginId).toList()) {
      await _close(t, notify: false);
    }
  }

  // ---- headless ------------------------------------------------------------

  Future<void> _createHeadless(WorkerTab tab, Uri url) async {
    tab.url = url;
    tab.loading = true;
    tab._loaded = Completer<void>();
    final headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri.uri(url)),
      initialSettings: cookies.webViewSettings(),
      initialUserScripts: UnmodifiableListView(injector.initialUserScripts()),
      initialSize: const Size(412, 915),
      onWebViewCreated: (controller) {
        tab.controller = controller;
        unawaited(injector.attach(controller, null, key: tab.key));
      },
      onLoadStart: (controller, u) async {
        final uri = u?.uriValue;
        if (uri == null) return;
        tab.url = uri;
        tab.loading = true;
        injector.onLoadStart(controller, null, uri, key: tab.key);
      },
      onLoadStop: (controller, u) async {
        final uri = u?.uriValue;
        if (uri != null) {
          tab.url = uri;
          await injector.onLoadStop(controller, null, uri, key: tab.key);
        }
        _finishLoad(tab);
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame ?? true) {
          logs.add(pluginId: tab.pluginId, level: 'warn', message: 'tab ${tab.id} load error: ${error.description}');
          _finishLoad(tab, error: error.description);
        }
      },
      onUpdateVisitedHistory: (controller, u, isReload) async {
        final uri = u?.uriValue;
        if (uri != null) {
          tab.url = uri;
          await injector.onUrlChanged(controller, null, uri, key: tab.key, loading: tab.loading);
        }
      },
      onJsAlert: (controller, request) => _dialog(tab, request.message, 'alert', () => dialogs.onAlert(request),
          accept: (_) => JsAlertResponse(handledByClient: true, action: JsAlertResponseAction.CONFIRM),
          dismiss: () => JsAlertResponse(handledByClient: true, action: JsAlertResponseAction.CONFIRM)),
      onJsConfirm: (controller, request) => _dialog(tab, request.message, 'confirm', () => dialogs.onConfirm(request),
          accept: (_) => JsConfirmResponse(handledByClient: true, action: JsConfirmResponseAction.CONFIRM),
          dismiss: () => JsConfirmResponse(handledByClient: true, action: JsConfirmResponseAction.CANCEL)),
      onJsPrompt: (controller, request) => _dialog(tab, request.message, 'prompt', () => dialogs.onPrompt(request),
          accept: (value) => JsPromptResponse(handledByClient: true, action: JsPromptResponseAction.CONFIRM, value: value ?? request.defaultValue),
          dismiss: () => JsPromptResponse(handledByClient: true, action: JsPromptResponseAction.CANCEL)),
      onRenderProcessGone: (controller, detail) async {
        logs.add(pluginId: tab.pluginId, level: 'error', message: 'tab ${tab.id} render process gone');
        _finishLoad(tab, error: 'render process gone');
      },
    );
    tab.headless = headless;
    await headless.run();
  }

  Future<void> _disposeHeadless(WorkerTab tab) async {
    final controller = tab.controller;
    if (controller != null) injector.detach(controller, null, key: tab.key);
    bridge.revokeForWebView(tab.key);
    try {
      await tab.headless?.dispose();
    } catch (_) {}
    tab.headless = null;
    tab.controller = null;
  }

  void _finishLoad(WorkerTab tab, {String? error}) {
    tab.loading = false;
    logs.add(pluginId: tab.pluginId, level: 'info', message: 'tab ${tab.id} loaded ${tab.url}${error == null ? '' : ' (error: $error)'}');
    final c = tab._loaded;
    if (c != null && !c.isCompleted) c.complete();
    unawaited(bridge.emit(tab.owner, 'tabs.load', {'tabId': tab.id, 'url': tab.url?.toString(), 'error': ?error}));
  }

  /// Dialog forwarding (F-01-4, P4-05). iOS: ask the worker, fall back to the
  /// declared policy. Android: answer with the policy immediately and tell the
  /// worker afterwards (see [canAskWorkerDuringDialog]). No policy and no
  /// worker answer -> the host dialog is shown (or dismissed when hidden and
  /// there is no UI).
  Future<T> _dialog<T>(
    WorkerTab tab,
    String? message,
    String type,
    Future<T> Function() show, {
    required T Function(String? value) accept,
    required T Function() dismiss,
  }) async {
    final payload = {'tabId': tab.id, 'type': type, 'message': message ?? ''};
    final policy = dialogPolicies[tab.pluginId];
    logs.add(pluginId: tab.pluginId, level: 'info', message: 'tab ${tab.id} $type dialog: "${message ?? ''}" (policy: ${policy ?? 'none'})');

    if (canAskWorkerDuringDialog) {
      try {
        final reply = await bridge.emit(tab.owner, 'tabs.dialog', payload).timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (reply is Map) {
          final action = reply['action'];
          if (action == 'accept') return accept(reply['value'] is String ? reply['value'] as String : null);
          if (action == 'dismiss') return dismiss();
          if (action == 'show') return show();
        }
      } catch (e) {
        logs.add(pluginId: tab.pluginId, level: 'warn', message: 'tabs.dialog handler failed: $e');
      }
    } else if (policy != null) {
      // inform the worker once the dialog is answered (its JS is frozen until then)
      unawaited(Future<void>.delayed(Duration.zero, () => bridge.emit(tab.owner, 'tabs.dialog', {...payload, 'answered': policy})));
    }

    switch (policy) {
      case 'accept':
        return accept(null);
      case 'dismiss':
        return dismiss();
      case 'show':
        return show();
    }
    if (tab.hidden && dialogs.contextProvider() == null) return dismiss();
    return show();
  }

  // ---- visible tabs (events come through the browser hooks) --------------

  WorkerTab? forBrowserTab(BrowserTab bt) => _tabs.values.where((t) => t.browserTab == bt).firstOrNull;

  void onBrowserTabLoadStart(BrowserTab bt, Uri url) {
    final t = forBrowserTab(bt);
    if (t == null) return;
    t.url = url;
    t.loading = true;
  }

  void onBrowserTabLoadStop(BrowserTab bt, InAppWebViewController controller, Uri url) {
    final t = forBrowserTab(bt);
    if (t == null) return;
    t.controller = controller;
    t.url = url;
    _finishLoad(t);
  }

  void onBrowserTabClosed(BrowserTab bt) {
    final t = forBrowserTab(bt);
    if (t == null) return;
    _tabs.remove(t.id);
    unawaited(bridge.emit(t.owner, 'tabs.close', {'tabId': t.id}));
  }
}

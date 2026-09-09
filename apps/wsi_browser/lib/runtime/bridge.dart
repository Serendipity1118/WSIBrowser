// The single 'wsi' JavaScript handler (F-04-1). Every call is
// { token, op, payload }; the token was issued by the host for one plugin in
// one WebView, so the page never names its own pluginId.
//
// Checks, in order: token known and not revoked, same WebView, plugin still
// installed and enabled, page context is on a matching domain, op known,
// permission declared, context allowed. Failures return { error } and are logged.
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bridge_ops/registry.dart';
import '../browser/tab_manager.dart';
import 'domain_matcher.dart';
import 'log_sink.dart';
import 'repository.dart';

class Bridge {
  Bridge({required this.repository, required this.registry, required this.logs});

  final PluginRepository repository;
  final OpRegistry registry;
  final LogSink logs;

  static const handlerName = 'wsi';
  final Map<String, BridgeSession> _sessions = {};
  final Random _random = Random.secure();

  /// Register the handler on a WebView (once per WebView). [webViewKey]
  /// identifies the WebView in every later call (see BridgeSession.webViewKey).
  void attach(InAppWebViewController controller, Object webViewKey) {
    controller.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) => handle(webViewKey, args),
    );
  }

  BridgeSession issue({
    required String pluginId,
    required Object webViewKey,
    InAppWebViewController? controller,
    required BridgeContext context,
    BrowserTab? tab,
    Uri? origin,
  }) {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    final token = base64UrlEncode(bytes).replaceAll('=', '');
    final session = BridgeSession(token: token, pluginId: pluginId, context: context, controller: controller, webViewKey: webViewKey, tab: tab, origin: origin);
    _sessions[token] = session;
    return session;
  }

  BridgeSession? session(String token) => _sessions[token];

  /// Attach the real controller to a session issued before the WebView existed.
  void rebind(BridgeSession session, InAppWebViewController controller) {
    session.controller = controller;
  }

  Iterable<BridgeSession> sessionsFor(Object webViewKey) =>
      _sessions.values.where((s) => s.webViewKey == webViewKey && !s.revoked);

  Iterable<BridgeSession> sessionsForPlugin(String pluginId) =>
      _sessions.values.where((s) => s.pluginId == pluginId && !s.revoked);

  void revoke(BridgeSession session) {
    session.revoked = true;
    _sessions.remove(session.token);
  }

  void revokeForWebView(Object webViewKey) {
    for (final s in sessionsFor(webViewKey).toList()) {
      revoke(s);
    }
  }

  /// Update the origin of every session of a WebView (main-frame navigation).
  void setOrigin(Object webViewKey, Uri origin) {
    for (final s in sessionsFor(webViewKey)) {
      s.origin = origin;
    }
  }

  Future<Object?> handle(Object webViewKey, List<dynamic> args) async {
    final Map<String, Object?> req;
    if (args.isNotEmpty && args.first is Map) {
      req = (args.first as Map).cast<String, Object?>();
    } else {
      return _reject(null, 'invalid request');
    }
    final token = req['token'];
    final op = req['op'];
    final payloadRaw = req['payload'];
    final payload = payloadRaw is Map ? payloadRaw.cast<String, Object?>() : <String, Object?>{};
    if (token is! String || op is! String) return _reject(null, 'invalid request');

    final session = _sessions[token];
    if (session == null || session.revoked) return _reject(null, 'invalid token', op: op);
    if (session.webViewKey != webViewKey) return _reject(session, 'token does not belong to this WebView', op: op);

    final plugin = repository.byId(session.pluginId);
    if (plugin == null) return _reject(session, 'plugin is not installed', op: op);
    if (!plugin.enabled) return _reject(session, 'plugin is disabled', op: op);

    if (session.context == BridgeContext.page) {
      final origin = session.origin;
      if (origin == null || !matchesDomain(origin.host, plugin.manifest.domains)) {
        return _reject(session, 'origin does not match plugin domains', op: op);
      }
    }

    final entry = registry.lookup(op);
    if (entry == null) return _reject(session, 'unknown op', op: op);
    if (entry.permission != null && !plugin.manifest.has(entry.permission!)) {
      return _reject(session, 'permission denied', op: op);
    }
    if (entry.contexts != null && !entry.contexts!.contains(session.context)) {
      return _reject(session, 'op not available in ${bridgeContextToString(session.context)} context', op: op);
    }

    final call = BridgeCall(session: session, plugin: plugin, op: op, payload: payload);
    try {
      return await entry.handler(call);
    } on OpError catch (e) {
      return _reject(session, e.message, op: op, level: 'warn');
    } catch (e, st) {
      debugPrint('op $op failed: $e\n$st');
      return _reject(session, 'internal error: $e', op: op);
    }
  }

  Map<String, Object?> _reject(BridgeSession? session, String message, {String? op, String level = 'error'}) {
    logs.add(pluginId: session?.pluginId, level: level, message: 'bridge${op == null ? '' : ' $op'}: $message');
    return {'error': message};
  }

  /// Host -> plugin event. Resolves with the plugin's reply (reply-style events).
  Future<Object?> emit(BridgeSession session, String event, Object? payload, {Object? sender}) async {
    final controller = session.controller;
    if (session.revoked || controller == null) return null;
    final js = 'globalThis.__wsiEmit && globalThis.__wsiEmit(${jsonEncode(session.token)}, ${jsonEncode(event)}, ${jsonEncode(payload)}, ${jsonEncode(sender)})';
    try {
      final result = await controller.callAsyncJavaScript(functionBody: 'return await ($js);');
      if (result == null) return null;
      if (result.error != null) {
        logs.add(pluginId: session.pluginId, level: 'error', message: 'emit $event: ${result.error}');
        return null;
      }
      return result.value;
    } catch (e) {
      logs.add(pluginId: session.pluginId, level: 'error', message: 'emit $event failed: $e');
      return null;
    }
  }

  /// Broadcast to every live session of a plugin (settings.change, runtime.message, ...).
  Future<void> broadcast(String pluginId, String event, Object? payload, {BridgeSession? except, Object? sender}) async {
    for (final s in sessionsForPlugin(pluginId).toList()) {
      if (except != null && identical(s, except)) continue;
      await emit(s, event, payload, sender: sender);
    }
  }
}

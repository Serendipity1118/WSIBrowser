// op name -> handler + required permission (F-04-1, F-04-2).
//
// Adding a native feature = one file in bridge_ops/ that calls
// registry.register(...) for its ops, plus an entry in kAllPermissions.
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../browser/tab_manager.dart';
import '../runtime/repository.dart';

/// Where a WSI call comes from.
enum BridgeContext { page, pluginPage, worker }

BridgeContext bridgeContextFromString(String? s) {
  switch (s) {
    case 'worker':
      return BridgeContext.worker;
    case 'plugin-page':
      return BridgeContext.pluginPage;
    default:
      return BridgeContext.page;
  }
}

String bridgeContextToString(BridgeContext c) {
  switch (c) {
    case BridgeContext.worker:
      return 'worker';
    case BridgeContext.pluginPage:
      return 'plugin-page';
    case BridgeContext.page:
      return 'page';
  }
}

/// One injected plugin instance (token) in one WebView.
class BridgeSession {
  BridgeSession({
    required this.token,
    required this.pluginId,
    required this.context,
    required this.webViewKey,
    this.controller,
    this.tab,
    this.origin,
  });

  final String token;
  final String pluginId;
  final BridgeContext context;

  /// Set once the WebView exists (plugin pages issue their token before creation).
  InAppWebViewController? controller;

  /// Identifies the WebView across callbacks (the controller object handed to
  /// each callback is not guaranteed to be the same instance): tab id for
  /// site tabs, a generated key for headless / plugin-page WebViews.
  final Object webViewKey;
  final BrowserTab? tab;

  /// Last known main-frame URL of the WebView (kept current by the runtime).
  Uri? origin;
  bool revoked = false;
}

class BridgeCall {
  BridgeCall({required this.session, required this.plugin, required this.op, required this.payload});

  final BridgeSession session;
  final InstalledPlugin plugin;
  final String op;
  final Map<String, Object?> payload;

  String get pluginId => plugin.id;

  T? arg<T>(String key) {
    final v = payload[key];
    return v is T ? v : null;
  }

  String requireString(String key) {
    final v = payload[key];
    if (v is! String) throw OpError('$op: "$key" must be a string');
    return v;
  }
}

/// Thrown by handlers; turned into { error: message } for the plugin.
class OpError implements Exception {
  OpError(this.message);
  final String message;
  @override
  String toString() => message;
}

typedef OpHandler = Future<Object?> Function(BridgeCall call);

class OpEntry {
  const OpEntry({required this.handler, this.permission, this.contexts});
  final OpHandler handler;

  /// Required permission (null = none beyond being an installed plugin).
  final String? permission;

  /// Allowed contexts (null = all).
  final Set<BridgeContext>? contexts;
}

class OpRegistry {
  final Map<String, OpEntry> _ops = {};

  void register(String op, OpHandler handler, {String? permission, Set<BridgeContext>? contexts}) {
    assert(!_ops.containsKey(op), 'op $op registered twice');
    _ops[op] = OpEntry(handler: handler, permission: permission, contexts: contexts);
  }

  OpEntry? lookup(String op) => _ops[op];
  Iterable<String> get ops => _ops.keys;
}

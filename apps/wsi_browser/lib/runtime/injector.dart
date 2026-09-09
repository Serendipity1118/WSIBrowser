// Plugin injection (F-03). Per WebView:
//   - the SDK core is an AT_DOCUMENT_START UserScript (forMainFrameOnly)
//   - plugins with runAt document_start / document_end are UserScripts too,
//     each guarded by an inline domain / path check, with a token issued for
//     the WebView's lifetime (group 'wsi-plugins', rebuilt when plugins change)
//   - plugins with runAt document_idle (the default) run from onLoadStop via
//     evaluateJavascript with a token issued per load
// Every path ends in globalThis.__wsiRun(spec); the SDK refuses to run the
// same plugin twice in one document.
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bridge_ops/registry.dart';
import '../browser/tab_manager.dart';
import 'bridge.dart';
import 'domain_matcher.dart';
import 'log_sink.dart';
import 'repository.dart';

class Injector {
  Injector({required this.sdkSource, required this.repository, required this.bridge, required this.logs});

  final String sdkSource;
  final PluginRepository repository;
  final Bridge bridge;
  final LogSink logs;

  static const sdkGroup = 'wsi-sdk';
  static const pluginGroup = 'wsi-plugins';

  /// Sessions baked into UserScripts (kept across loads), keyed by WebView key.
  final Map<Object, List<BridgeSession>> _scriptSessions = {};

  /// Per-load sessions (document_idle), keyed by WebView key.
  final Map<Object, List<BridgeSession>> _loadSessions = {};

  static Object keyOf(BrowserTab? tab, InAppWebViewController controller) => tab?.id ?? controller;

  List<UserScript> initialUserScripts() => [
        UserScript(
          groupName: sdkGroup,
          source: sdkSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: true,
        ),
      ];

  /// Called from onWebViewCreated.
  Future<void> attach(InAppWebViewController controller, BrowserTab? tab) async {
    bridge.attach(controller, keyOf(tab, controller));
    await rebuildUserScripts(controller, tab);
  }

  void detach(InAppWebViewController controller, BrowserTab? tab) {
    final key = keyOf(tab, controller);
    bridge.revokeForWebView(key);
    _scriptSessions.remove(key);
    _loadSessions.remove(key);
  }

  /// (Re)register the document_start / document_end plugin scripts.
  Future<void> rebuildUserScripts(InAppWebViewController controller, BrowserTab? tab) async {
    final key = keyOf(tab, controller);
    for (final s in _scriptSessions.remove(key) ?? const <BridgeSession>[]) {
      bridge.revoke(s);
    }
    try {
      await controller.removeUserScriptsByGroupName(groupName: pluginGroup);
    } catch (_) {/* not supported before first load on some platforms */}

    final scripts = <UserScript>[];
    final sessions = <BridgeSession>[];
    for (final p in repository.all) {
      if (!p.enabled || p.manifest.runAt == 'document_idle') continue;
      final code = await repository.code(p.id);
      final session = bridge.issue(pluginId: p.id, controller: controller, webViewKey: key, context: BridgeContext.page, tab: tab);
      sessions.add(session);
      scripts.add(UserScript(
        groupName: pluginGroup,
        source: _guardedScript(p, code, session.token),
        injectionTime: p.manifest.runAt == 'document_start'
            ? UserScriptInjectionTime.AT_DOCUMENT_START
            : UserScriptInjectionTime.AT_DOCUMENT_END,
        forMainFrameOnly: true,
      ));
    }
    _scriptSessions[key] = sessions;
    if (scripts.isNotEmpty) {
      await controller.addUserScripts(userScripts: scripts);
    }
  }

  /// New document: forget last load's idle sessions, record the origin.
  void onLoadStart(InAppWebViewController controller, BrowserTab? tab, Uri url) {
    final key = keyOf(tab, controller);
    for (final s in _loadSessions.remove(key) ?? const <BridgeSession>[]) {
      bridge.revoke(s);
    }
    bridge.setOrigin(key, url);
  }

  /// Document finished: inject document_idle plugins. Returns the number of
  /// plugins that apply to [url] (all runAt kinds) for the badge.
  Future<int> onLoadStop(InAppWebViewController controller, BrowserTab? tab, Uri url) async {
    bridge.setOrigin(keyOf(tab, controller), url);
    final matched = repository.forUrl(url);
    final key = keyOf(tab, controller);
    for (final p in matched) {
      if (p.manifest.runAt != 'document_idle') continue;
      // Android fires onUpdateVisitedHistory before onLoadStop: the plugin may already be running
      final already = (_loadSessions[key] ?? const []).any((s) => s.pluginId == p.id);
      if (!already) await _runIdle(controller, tab, p, url);
    }
    return matched.length;
  }

  /// SPA navigation (F-03-5): tell the SDK, then run any plugin that now
  /// matches (dedupe inside __wsiRun keeps the rest untouched).
  Future<int> onUrlChanged(InAppWebViewController controller, BrowserTab? tab, Uri url) async {
    final key = keyOf(tab, controller);
    bridge.setOrigin(key, url);
    try {
      await controller.evaluateJavascript(source: "window.dispatchEvent(new CustomEvent('wsi:urlchange'))");
    } catch (_) {}
    final matched = repository.forUrl(url);
    // While the document is still loading this is the initial navigation
    // (Android reports it before onLoadStop); onLoadStop injects then.
    if (tab?.isLoading == true) return matched.length;
    for (final p in matched) {
      if (p.manifest.runAt != 'document_idle') continue;
      final already = (_loadSessions[key] ?? const []).any((s) => s.pluginId == p.id);
      if (!already) await _runIdle(controller, tab, p, url);
    }
    return matched.length;
  }

  Future<void> _runIdle(InAppWebViewController controller, BrowserTab? tab, InstalledPlugin p, Uri url) async {
    final code = await repository.code(p.id);
    final key = keyOf(tab, controller);
    final session = bridge.issue(pluginId: p.id, controller: controller, webViewKey: key, context: BridgeContext.page, tab: tab, origin: url);
    (_loadSessions[key] ??= []).add(session);
    try {
      if (code.css.isNotEmpty) {
        await controller.injectCSSCode(source: code.css);
      }
      final result = await controller.evaluateJavascript(source: _runCall(p, code.mainJs, session.token));
      _report(p.id, result);
    } catch (e) {
      logs.add(pluginId: p.id, level: 'error', message: 'injection failed: $e');
    }
  }

  void _report(String pluginId, Object? result) {
    if (result is Map && result['ok'] != true && result['reason'] != 'already-ran') {
      logs.add(pluginId: pluginId, level: 'error', message: 'plugin runtime error: ${result['reason']}');
    } else if (result is Map && result['ok'] == true) {
      logs.add(pluginId: pluginId, level: 'info', message: 'injected');
    }
  }

  String _spec(InstalledPlugin p, String code, String token) => jsonEncode({
        'pluginId': p.id,
        'config': p.manifest.config,
        'code': code,
        'permissions': p.manifest.permissions,
        'token': token,
        'context': 'page',
      });

  String _runCall(InstalledPlugin p, String code, String token) =>
      '(function(){ if (typeof globalThis.__wsiRun !== "function") return {ok:false, reason:"sdk not loaded"}; return globalThis.__wsiRun(${_spec(p, code, token)}); })()';

  /// document_start / document_end script: domain + path guard, CSS, run.
  String _guardedScript(InstalledPlugin p, PluginCode code, String token) {
    final domains = jsonEncode(p.manifest.domains);
    final paths = jsonEncode(p.manifest.paths.map((g) => globToRegExp(g).pattern).toList());
    final css = jsonEncode(code.css);
    return '''
(function () {
  var host = location.hostname.toLowerCase();
  var domains = $domains;
  var ok = domains.some(function (d) {
    d = d.toLowerCase();
    if (d === '*') return true;
    if (d.indexOf('*.') === 0) { var s = d.slice(2); return host === s || host.slice(-s.length - 1) === '.' + s; }
    return host === d;
  });
  if (!ok) return;
  var paths = $paths;
  if (paths.length && !paths.some(function (re) { return new RegExp(re).test(location.pathname || '/'); })) return;
  var css = $css;
  if (css) {
    var style = document.createElement('style');
    style.setAttribute('data-wsi-plugin', ${jsonEncode(p.id)});
    style.textContent = css;
    (document.head || document.documentElement).appendChild(style);
  }
  if (typeof globalThis.__wsiRun === 'function') globalThis.__wsiRun(${_spec(p, code.mainJs, token)});
})();
''';
  }
}

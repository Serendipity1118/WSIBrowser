// Plugin page (F-07-2, F-07-3, P3-02): an InAppWebView showing
// wsi://plugin/<id>/<file>, as a full screen or a bottom sheet. The SDK core
// is a document-start UserScript, followed by a runner that exposes
// `window.WSI` for the page's own scripts (a plugin page is the plugin's own
// document, so there is nothing to isolate it from).
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bridge_ops/registry.dart';
import '../runtime/manifest.dart';
import '../runtime/page_host.dart';
import '../runtime/repository.dart';
import '../runtime/runtime.dart';

/// Open a declared page. Returns when the page is closed.
Future<void> openPluginPage(BuildContext context, PluginRuntime runtime, InstalledPlugin plugin, PluginPage page, {Map<String, String>? params}) {
  final url = PageHost.pageUrl(plugin.id, page.file, params);
  runtime.pageStack.push(plugin.id, page.name);
  final Future<void> done;
  if (page.display == 'sheet') {
    done = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.7,
        child: PluginPageView(plugin: plugin, page: page, url: url),
      ),
    );
  } else {
    done = Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(page.name == 'settings' ? plugin.manifest.name : '${plugin.manifest.name} / ${page.name}')),
        body: PluginPageView(plugin: plugin, page: page, url: url),
      ),
    ));
  }
  return done.whenComplete(() => runtime.pageStack.pop(plugin.id, page.name));
}

class PluginPageView extends StatefulWidget {
  const PluginPageView({super.key, required this.plugin, required this.page, required this.url});

  final InstalledPlugin plugin;
  final PluginPage page;
  final Uri url;

  @override
  State<PluginPageView> createState() => _PluginPageViewState();
}

class _PluginPageViewState extends State<PluginPageView> {
  static int _counter = 0;
  late final Object _key = 'plugin-page:${widget.plugin.id}:${_counter++}';
  BridgeSession? _session;
  PluginRuntime? _runtime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // dispose() must not look up inherited widgets (the element is already
    // deactivated when the route is popped with the back key), so keep it.
    _runtime = runtimeOf(context);
  }

  @override
  void dispose() {
    final runtime = _runtime;
    if (runtime != null) {
      runtime.bridge.revokeForWebView(_key);
      runtime.menuBus.dropSessions(_key);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runtime = runtimeOf(context);
    final services = runtime.services;
    final manifest = widget.plugin.manifest;

    // token issued at creation: the runner script below needs it before the page's own scripts run
    final session = _session ??= runtime.bridge.issue(
      pluginId: widget.plugin.id,
      webViewKey: _key,
      context: BridgeContext.pluginPage,
      origin: widget.url,
    );

    final spec = jsonEncode({
      'pluginId': widget.plugin.id,
      'config': manifest.config,
      'code': 'window.WSI = WSI;',
      'permissions': manifest.permissions,
      'token': session.token,
      'context': 'plugin-page',
    });

    return InAppWebView(
      key: ValueKey(_key),
      initialUrlRequest: URLRequest(url: WebUri.uri(widget.url)),
      initialSettings: InAppWebViewSettings(
        resourceCustomSchemes: const [PageHost.scheme],
        javaScriptEnabled: true,
        isInspectable: services.settings.developerMode && services.settings.webInspector,
        allowFileAccess: false,
        allowUniversalAccessFromFileURLs: false,
        supportZoom: false,
        transparentBackground: true,
      ),
      initialUserScripts: UnmodifiableListView([
        ...runtime.injector.initialUserScripts(),
        UserScript(
          groupName: 'wsi-plugin-page',
          source: 'if (typeof globalThis.__wsiRun === "function") globalThis.__wsiRun($spec);',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: true,
        ),
      ]),
      onWebViewCreated: (controller) {
        runtime.bridge.attach(controller, _key);
        runtime.bridge.rebind(session, controller);
      },
      onLoadResourceWithCustomScheme: (controller, request) =>
          runtime.pageHost.onLoadResource(request, allowedPluginId: widget.plugin.id),
      shouldOverrideUrlLoading: (controller, action) async {
        final target = action.request.url?.uriValue;
        if (target == null) return NavigationActionPolicy.CANCEL;
        // stay inside the plugin's own files; anything else is not for this WebView
        return target.scheme == PageHost.scheme ? NavigationActionPolicy.ALLOW : NavigationActionPolicy.CANCEL;
      },
      onJsAlert: (controller, request) => services.dialogs.onAlert(request),
      onJsConfirm: (controller, request) => services.dialogs.onConfirm(request),
      onJsPrompt: (controller, request) => services.dialogs.onPrompt(request),
      onConsoleMessage: (controller, message) {
        if (message.messageLevel == ConsoleMessageLevel.ERROR) {
          runtime.logs.add(pluginId: widget.plugin.id, level: 'error', message: 'page ${widget.page.name}: ${message.message}');
        }
      },
    );
  }
}

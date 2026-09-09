// One InAppWebView per BrowserTab. Wires the WebView callbacks to the tab
// state, the navigation policy, JS dialogs and downloads. Plugin injection
// hooks (onLoadStart / onLoadStop / onUpdateVisitedHistory) are exposed as
// [WebViewTabHooks] so the runtime (P2) can attach without editing this file.
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';
import '../l10n/generated/app_localizations.dart';
import 'file_chooser.dart';
import 'navigation_policy.dart';
import 'tab_manager.dart';

/// Runtime hooks (P2+). All optional.
class WebViewTabHooks {
  const WebViewTabHooks({
    this.userScripts,
    this.onWebViewCreated,
    this.onWebViewDisposed,
    this.onLoadStart,
    this.onLoadStop,
    this.onUpdateVisitedHistory,
    this.onAppLink,
  });

  /// UserScripts registered at WebView creation (the SDK core, P2).
  final List<UserScript> Function()? userScripts;
  final void Function(BrowserTab tab, InAppWebViewController controller)? onWebViewCreated;
  final void Function(BrowserTab tab, InAppWebViewController controller)? onWebViewDisposed;
  final Future<void> Function(BrowserTab tab, InAppWebViewController controller, Uri url)? onLoadStart;
  final Future<void> Function(BrowserTab tab, InAppWebViewController controller, Uri url)? onLoadStop;
  final Future<void> Function(BrowserTab tab, InAppWebViewController controller, Uri url)? onUpdateVisitedHistory;

  /// wsi:// links (install, dev). Returning false lets the default handling run.
  final Future<bool> Function(Uri url)? onAppLink;
}

class WebViewTab extends StatefulWidget {
  const WebViewTab({super.key, required this.tab, this.hooks = const WebViewTabHooks()});

  final BrowserTab tab;
  final WebViewTabHooks hooks;

  @override
  State<WebViewTab> createState() => _WebViewTabState();
}

class _WebViewTabState extends State<WebViewTab> {
  Uri? _currentUri;
  InAppWebViewController? _controller;

  @override
  void dispose() {
    final c = _controller;
    if (c != null) widget.hooks.onWebViewDisposed?.call(widget.tab, c);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final tab = widget.tab;
    final initial = tab.isStartPage ? null : URLRequest(url: WebUri(tab.url));

    return InAppWebView(
      key: ValueKey('webview-${tab.id}'),
      initialUrlRequest: initial,
      initialSettings: services.cookies.webViewSettings(),
      initialUserScripts: UnmodifiableListView(widget.hooks.userScripts?.call() ?? const <UserScript>[]),
      onWebViewCreated: (controller) {
        _controller = controller;
        tab.controller = controller;
        widget.hooks.onWebViewCreated?.call(tab, controller);
      },
      onLoadStart: (controller, url) async {
        final uri = url?.uriValue;
        _currentUri = uri;
        tab.update(url: uri?.toString(), loading: true, progress: 0);
        if (uri != null) await widget.hooks.onLoadStart?.call(tab, controller, uri);
      },
      onProgressChanged: (controller, progress) {
        tab.update(progress: progress / 100);
      },
      onTitleChanged: (controller, title) {
        tab.update(title: title ?? '');
      },
      onLoadStop: (controller, url) async {
        final uri = url?.uriValue;
        _currentUri = uri;
        await _refreshNav(controller, uri);
        tab.update(loading: false, progress: 1);
        if (uri != null) await widget.hooks.onLoadStop?.call(tab, controller, uri);
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame ?? true) tab.update(loading: false);
      },
      onUpdateVisitedHistory: (controller, url, isReload) async {
        final uri = url?.uriValue;
        if (uri != null) {
          _currentUri = uri;
          await _refreshNav(controller, uri);
          await widget.hooks.onUpdateVisitedHistory?.call(tab, controller, uri);
        }
      },
      shouldOverrideUrlLoading: (controller, action) => _shouldOverride(context, services, controller, action),
      onJsAlert: (controller, request) => services.dialogs.onAlert(request),
      onJsConfirm: (controller, request) => services.dialogs.onConfirm(request),
      onJsPrompt: (controller, request) => services.dialogs.onPrompt(request),
      onDownloadStartRequest: (controller, request) => _download(context, services, request),
      onCreateWindow: (controller, action) async {
        // target=_blank: open in the same tab (no popup windows in a plugin host)
        final url = action.request.url;
        if (url != null) await controller.loadUrl(urlRequest: URLRequest(url: url));
        return false;
      },
    );
  }

  Future<void> _refreshNav(InAppWebViewController controller, Uri? uri) async {
    final back = await controller.canGoBack();
    final fwd = await controller.canGoForward();
    widget.tab.update(url: uri?.toString(), canGoBack: back, canGoForward: fwd);
  }

  Future<NavigationActionPolicy> _shouldOverride(
    BuildContext context,
    AppServices services,
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final target = action.request.url?.uriValue;
    if (target == null) return NavigationActionPolicy.CANCEL;
    final isLinkClick = action.navigationType == NavigationType.LINK_ACTIVATED || (action.hasGesture ?? false);
    final decision = services.navigation.decide(
      target: target,
      current: _currentUri,
      isMainFrame: action.isForMainFrame,
      isRedirect: action.isRedirect ?? false,
      isLinkClick: isLinkClick,
    );
    switch (decision.action) {
      case NavAction.allow:
        return NavigationActionPolicy.ALLOW;
      case NavAction.cancel:
        return NavigationActionPolicy.CANCEL;
      case NavAction.loadInstead:
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(decision.url!)));
        return NavigationActionPolicy.CANCEL;
      case NavAction.external:
        await _openExternal(context, decision.url!);
        return NavigationActionPolicy.CANCEL;
      case NavAction.app:
        final handled = await widget.hooks.onAppLink?.call(decision.url!) ?? false;
        if (!handled && context.mounted) {
          _snack(context, AppLocalizations.of(context).navigationBlocked(decision.url.toString()));
        }
        return NavigationActionPolicy.CANCEL;
    }
  }

  Future<void> _openExternal(BuildContext context, Uri url) async {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    _snack(context, ok ? l.externalLinkOpened : l.navigationBlocked(url.toString()));
  }

  Future<void> _download(BuildContext context, AppServices services, DownloadStartRequest request) async {
    final l = AppLocalizations.of(context);
    final name = Downloader.fileNameFor(request);
    _snack(context, l.downloadStarted(name));
    try {
      final result = await services.downloader.download(request, userAgent: services.settings.userAgent);
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(l.downloadDone(result.name)),
        action: SnackBarAction(label: l.actionShare, onPressed: () => services.downloader.share(result)),
      ));
    } catch (e) {
      if (context.mounted) _snack(context, l.downloadFailed(e.toString()));
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
  }
}

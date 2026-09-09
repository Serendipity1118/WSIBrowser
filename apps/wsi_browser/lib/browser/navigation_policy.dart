// Navigation control (F-01-3). Pure decision logic so it can be unit tested;
// WebViewTab feeds it from shouldOverrideUrlLoading.
//
// Rules, in order:
//   1. wsi://          -> handled by the app (install / dev links), never loaded in the WebView
//   2. mailto/tel/sms/intent/market/itms... -> opened with the OS (external)
//   3. other non-http schemes -> cancelled
//   4. https -> http redirect -> reload the same URL as https (Android cleartext /
//      iOS ATS would otherwise block the whole redirect chain)
//   5. link clicks to hosts no plugin handles -> external browser when the host
//      setting says so; typed URLs and same-host navigation always stay in-app
//   6. WSI.navigation.intercept (P4) is consulted before rule 5 via [interceptor]
import '../settings/host_settings.dart';

enum NavAction { allow, cancel, loadInstead, external, app }

class NavigationDecision {
  const NavigationDecision._(this.action, [this.url]);

  final NavAction action;

  /// Target for loadInstead / external / app.
  final Uri? url;

  static const allow = NavigationDecision._(NavAction.allow);
  static const cancel = NavigationDecision._(NavAction.cancel);
  factory NavigationDecision.loadInstead(Uri url) => NavigationDecision._(NavAction.loadInstead, url);
  factory NavigationDecision.external(Uri url) => NavigationDecision._(NavAction.external, url);
  factory NavigationDecision.app(Uri url) => NavigationDecision._(NavAction.app, url);

  @override
  String toString() => 'NavigationDecision(${action.name}${url == null ? '' : ', $url'})';
}

/// Result of a plugin's WSI.navigation.intercept (P4). null = no opinion.
typedef NavigationInterceptor = String? Function(Uri url);

/// Async variant used by the runtime (asks workers over the bridge).
typedef AsyncNavigationInterceptor = Future<String?> Function(Uri url);

class NavigationPolicy {
  NavigationPolicy({
    required ExternalLinkMode Function() externalLinks,
    required bool Function(String host) isPluginHost,
    this.interceptor,
  })  : _externalLinks = externalLinks,
        _isPluginHost = isPluginHost;

  final ExternalLinkMode Function() _externalLinks;
  final bool Function(String host) _isPluginHost;
  NavigationInterceptor? interceptor;
  AsyncNavigationInterceptor? asyncInterceptor;

  static const _osSchemes = {'mailto', 'tel', 'sms', 'intent', 'market', 'itms', 'itms-apps', 'itms-appss', 'maps', 'geo'};

  /// [decide] plus the async interceptor (WSI.navigation.intercept of workers).
  Future<NavigationDecision> decideAsync({
    required Uri target,
    Uri? current,
    bool isMainFrame = true,
    bool isRedirect = false,
    bool isLinkClick = false,
  }) async {
    String? verdict;
    final scheme = target.scheme.toLowerCase();
    if (isMainFrame && (scheme == 'http' || scheme == 'https') && asyncInterceptor != null) {
      try {
        verdict = await asyncInterceptor!(target);
      } catch (_) {
        verdict = null;
      }
    }
    return decide(target: target, current: current, isMainFrame: isMainFrame, isRedirect: isRedirect, isLinkClick: isLinkClick, pluginVerdict: verdict);
  }

  NavigationDecision decide({
    required Uri target,
    Uri? current,
    bool isMainFrame = true,
    bool isRedirect = false,
    bool isLinkClick = false,
    String? pluginVerdict,
  }) {
    final scheme = target.scheme.toLowerCase();

    if (scheme == 'wsi') return NavigationDecision.app(target);
    if (_osSchemes.contains(scheme)) return NavigationDecision.external(target);
    if (scheme != 'http' && scheme != 'https') {
      if (scheme == 'about' || scheme == 'blob' || scheme == 'data' || scheme == 'javascript') {
        return NavigationDecision.allow;
      }
      return NavigationDecision.cancel;
    }

    // rule 4: https -> http redirect
    if (isMainFrame && scheme == 'http' && isRedirect && current?.scheme == 'https') {
      return NavigationDecision.loadInstead(target.replace(scheme: 'https', port: target.hasPort && target.port != 80 ? target.port : null));
    }

    if (!isMainFrame) return NavigationDecision.allow;

    // rule 6: plugin interceptor
    final verdict = pluginVerdict ?? interceptor?.call(target);
    if (verdict == 'deny') return NavigationDecision.cancel;
    if (verdict == 'external') return NavigationDecision.external(target);
    if (verdict == 'allow') return NavigationDecision.allow;

    // rule 5: external links
    if (isLinkClick && _externalLinks() == ExternalLinkMode.external) {
      final sameHost = current != null && current.host.toLowerCase() == target.host.toLowerCase();
      if (!sameHost && !_isPluginHost(target.host)) {
        return NavigationDecision.external(target);
      }
    }

    return NavigationDecision.allow;
  }

  /// Turn what the user typed into a URL: adds https:// when the scheme is
  /// missing, and leaves search words to a search engine.
  static Uri normalizeInput(String input, {String searchUrl = 'https://www.google.com/search?q='}) {
    final text = input.trim();
    if (text.isEmpty) return Uri.parse('about:blank');
    final parsed = Uri.tryParse(text);
    if (parsed != null && parsed.hasScheme && (parsed.scheme == 'http' || parsed.scheme == 'https' || parsed.scheme == 'wsi')) {
      return parsed;
    }
    final looksLikeHost = RegExp(r'^([\w-]+\.)+[a-zA-Z]{2,}(:\d+)?(/.*)?$').hasMatch(text) ||
        RegExp(r'^localhost(:\d+)?(/.*)?$').hasMatch(text) ||
        RegExp(r'^\d{1,3}(\.\d{1,3}){3}(:\d+)?(/.*)?$').hasMatch(text);
    if (looksLikeHost && !text.contains(' ')) {
      return Uri.parse('https://$text');
    }
    return Uri.parse('$searchUrl${Uri.encodeQueryComponent(text)}');
  }
}

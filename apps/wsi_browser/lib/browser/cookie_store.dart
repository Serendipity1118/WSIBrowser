// Cookies and User-Agent (F-01-5, F-01-7).
//
// flutter_inappwebview shares one cookie store between every InAppWebView
// (and HeadlessInAppWebView) on both platforms, so "shared cookies" is the
// default. This class only adds: clearing, reading cookies for WSI.fetch
// (credentials: 'site', P2), and the UA override applied to every WebView.
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../settings/host_settings.dart';

class CookieStore {
  CookieStore(this._settings);

  final HostSettings _settings;
  final CookieManager _cookies = CookieManager.instance();

  Future<void> clearAll() async {
    await _cookies.deleteAllCookies();
  }

  /// "name=value; name2=value2" for the given URL (used by WSI.fetch with credentials: 'site').
  Future<String> cookieHeaderFor(Uri url) async {
    final list = await _cookies.getCookies(url: WebUri.uri(url));
    return list.map((c) => '${c.name}=${c.value}').join('; ');
  }

  /// Apply Set-Cookie headers received by dio (WSI.fetch) back into the shared store.
  Future<void> storeSetCookies(Uri url, List<String> setCookieHeaders) async {
    for (final header in setCookieHeaders) {
      final parts = header.split(';');
      final nv = parts.first.split('=');
      if (nv.length < 2) continue;
      final name = nv.first.trim();
      final value = nv.sublist(1).join('=').trim();
      String? path;
      String? domain;
      bool secure = false;
      bool httpOnly = false;
      for (final attr in parts.skip(1)) {
        final a = attr.trim();
        final lower = a.toLowerCase();
        if (lower.startsWith('path=')) path = a.substring(5);
        if (lower.startsWith('domain=')) domain = a.substring(7);
        if (lower == 'secure') secure = true;
        if (lower == 'httponly') httpOnly = true;
      }
      await _cookies.setCookie(
        url: WebUri.uri(url),
        name: name,
        value: value,
        path: path ?? '/',
        domain: domain,
        isSecure: secure,
        isHttpOnly: httpOnly,
      );
    }
  }

  /// Settings shared by every site WebView: UA override, inspector, media.
  InAppWebViewSettings webViewSettings() {
    final ua = _settings.userAgent;
    return InAppWebViewSettings(
      userAgent: ua.isEmpty ? null : ua,
      isInspectable: _settings.developerMode && _settings.webInspector,
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      supportMultipleWindows: false,
      useShouldOverrideUrlLoading: true,
      useOnDownloadStart: true,
      mediaPlaybackRequiresUserGesture: true,
      allowsInlineMediaPlayback: true,
      allowsBackForwardNavigationGestures: true,
      sharedCookiesEnabled: true,
      thirdPartyCookiesEnabled: true,
      // iframes never get plugins (F-03-6); UserScripts are registered forMainFrameOnly.
      useHybridComposition: true,
    );
  }
}

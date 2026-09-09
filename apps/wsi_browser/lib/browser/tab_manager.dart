// Tabs (F-01-1). Each BrowserTab owns one InAppWebView kept alive in an
// IndexedStack; the manager only tracks the list, the active index and the
// per-tab navigation state that the URL bar shows.
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Special URL for the host's start page (rendered as a Flutter widget, not a WebView).
const String kStartPageUrl = 'wsi://start';

class BrowserTab extends ChangeNotifier {
  BrowserTab({required this.id, required String initialUrl}) : _url = initialUrl;

  final int id;
  InAppWebViewController? controller;

  String _url;
  String _title = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _loading = false;
  double _progress = 0;
  int _pluginCount = 0;

  String get url => _url;
  String get title => _title;
  bool get canGoBack => _canGoBack;
  bool get canGoForward => _canGoForward;
  bool get isLoading => _loading;
  double get progress => _progress;

  /// Number of plugins active on the current host (URL bar badge). Set by the runtime in P2.
  int get pluginCount => _pluginCount;

  bool get isStartPage => _url == kStartPageUrl;

  String get host {
    final u = Uri.tryParse(_url);
    return u?.host ?? '';
  }

  void update({
    String? url,
    String? title,
    bool? canGoBack,
    bool? canGoForward,
    bool? loading,
    double? progress,
    int? pluginCount,
  }) {
    var changed = false;
    if (url != null && url != _url) { _url = url; changed = true; }
    if (title != null && title != _title) { _title = title; changed = true; }
    if (canGoBack != null && canGoBack != _canGoBack) { _canGoBack = canGoBack; changed = true; }
    if (canGoForward != null && canGoForward != _canGoForward) { _canGoForward = canGoForward; changed = true; }
    if (loading != null && loading != _loading) { _loading = loading; changed = true; }
    if (progress != null && progress != _progress) { _progress = progress; changed = true; }
    if (pluginCount != null && pluginCount != _pluginCount) { _pluginCount = pluginCount; changed = true; }
    if (changed) notifyListeners();
  }

  /// Navigate this tab. The start page is a Flutter widget, so loading a real
  /// URL from it means the WebView takes over (BrowserScreen switches the view).
  Future<void> load(String url) async {
    update(url: url, title: '', loading: url != kStartPageUrl);
    if (url == kStartPageUrl) return;
    final c = controller;
    if (c != null) {
      await c.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    }
    // if the controller is not created yet, WebViewTab loads [url] as its initial request
  }
}

class TabManager extends ChangeNotifier {
  TabManager({required int Function() tabLimit}) : _tabLimit = tabLimit;

  final int Function() _tabLimit;
  final List<BrowserTab> _tabs = [];
  int _active = -1;
  int _nextId = 1;

  List<BrowserTab> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _active;
  BrowserTab? get active => _active >= 0 && _active < _tabs.length ? _tabs[_active] : null;
  int get limit => _tabLimit();
  bool get canOpenMore => _tabs.length < limit;

  /// Open a new tab. Returns null when the limit is reached.
  BrowserTab? open(String url, {bool activate = true}) {
    if (!canOpenMore) return null;
    final tab = BrowserTab(id: _nextId++, initialUrl: url);
    tab.addListener(notifyListeners);
    _tabs.add(tab);
    if (activate || _active < 0) _active = _tabs.length - 1;
    notifyListeners();
    return tab;
  }

  void activate(int index) {
    if (index < 0 || index >= _tabs.length || index == _active) return;
    _active = index;
    notifyListeners();
  }

  void activateTab(BrowserTab tab) => activate(_tabs.indexOf(tab));

  /// Close a tab. The last tab is replaced by a fresh start page so there is
  /// always something to show.
  void close(BrowserTab tab) {
    final index = _tabs.indexOf(tab);
    if (index < 0) return;
    tab.removeListener(notifyListeners);
    _tabs.removeAt(index);
    tab.dispose();
    if (_tabs.isEmpty) {
      _active = -1;
      open(kStartPageUrl);
      return;
    }
    if (_active >= _tabs.length) {
      _active = _tabs.length - 1;
    } else if (index < _active) {
      _active -= 1;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final t in _tabs) {
      t.removeListener(notifyListeners);
      t.dispose();
    }
    _tabs.clear();
    super.dispose();
  }
}

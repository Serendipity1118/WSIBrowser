import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/browser/tab_manager.dart';

void main() {
  test('open / activate / close respect the limit and keep an active tab', () {
    var limit = 2;
    final tabs = TabManager(tabLimit: () => limit);
    var notified = 0;
    tabs.addListener(() => notified++);

    final a = tabs.open(kStartPageUrl)!;
    final b = tabs.open('https://example.com')!;
    expect(tabs.open('https://x'), isNull, reason: 'limit reached');
    expect(tabs.tabs.length, 2);
    expect(tabs.active, b);

    tabs.activate(0);
    expect(tabs.active, a);

    limit = 3;
    expect(tabs.canOpenMore, isTrue);

    tabs.close(a);
    expect(tabs.tabs, [b]);
    expect(tabs.active, b);

    tabs.close(b);
    expect(tabs.tabs.length, 1, reason: 'last tab is replaced by a start page');
    expect(tabs.active!.isStartPage, isTrue);
    expect(notified, greaterThan(0));
  });

  test('closing a tab before the active one shifts the active index', () {
    final tabs = TabManager(tabLimit: () => 5);
    final a = tabs.open('https://a')!;
    tabs.open('https://b');
    final c = tabs.open('https://c')!;
    expect(tabs.activeIndex, 2);
    tabs.close(a);
    expect(tabs.activeIndex, 1);
    expect(tabs.active, c);
  });

  test('tab state changes propagate to the manager', () {
    final tabs = TabManager(tabLimit: () => 5);
    final t = tabs.open('https://a')!;
    var n = 0;
    tabs.addListener(() => n++);
    t.update(title: 'T', canGoBack: true, pluginCount: 2);
    expect(n, 1);
    expect(t.host, 'a');
    t.update(title: 'T'); // unchanged -> no notification
    expect(n, 1);
  });
}

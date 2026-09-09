import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/browser/navigation_policy.dart';
import 'package:wsi_browser/settings/host_settings.dart';

void main() {
  NavigationPolicy policy({ExternalLinkMode mode = ExternalLinkMode.inApp, Set<String> pluginHosts = const {}}) =>
      NavigationPolicy(externalLinks: () => mode, isPluginHost: pluginHosts.contains);

  test('schemes: wsi -> app, mailto/tel -> external, unknown -> cancel', () {
    final p = policy();
    expect(p.decide(target: Uri.parse('wsi://install?url=x')).action, NavAction.app);
    expect(p.decide(target: Uri.parse('mailto:a@b')).action, NavAction.external);
    expect(p.decide(target: Uri.parse('tel:123')).action, NavAction.external);
    expect(p.decide(target: Uri.parse('foo://bar')).action, NavAction.cancel);
    expect(p.decide(target: Uri.parse('about:blank')).action, NavAction.allow);
  });

  test('https -> http redirect is reloaded as https (main frame only)', () {
    final p = policy();
    final d = p.decide(
      target: Uri.parse('http://example.com/a?b=1'),
      current: Uri.parse('https://example.com/'),
      isRedirect: true,
    );
    expect(d.action, NavAction.loadInstead);
    expect(d.url.toString(), 'https://example.com/a?b=1');
    // not a redirect: plain http navigation is left alone
    expect(
      p.decide(target: Uri.parse('http://example.com/'), current: Uri.parse('https://example.com/')).action,
      NavAction.allow,
    );
    // redirect from an http page stays http
    expect(
      p.decide(target: Uri.parse('http://x/'), current: Uri.parse('http://y/'), isRedirect: true).action,
      NavAction.allow,
    );
    // subframes are never rewritten
    expect(
      p.decide(target: Uri.parse('http://x/'), current: Uri.parse('https://y/'), isRedirect: true, isMainFrame: false).action,
      NavAction.allow,
    );
  });

  test('external link mode applies to link clicks to non-plugin hosts', () {
    final p = policy(mode: ExternalLinkMode.external, pluginHosts: {'sp.example.jp'});
    final current = Uri.parse('https://sp.example.jp/page');
    expect(p.decide(target: Uri.parse('https://other.com/'), current: current, isLinkClick: true).action, NavAction.external);
    expect(p.decide(target: Uri.parse('https://sp.example.jp/next'), current: current, isLinkClick: true).action,
        NavAction.allow,
        reason: 'plugin host');
    expect(
        p.decide(target: Uri.parse('https://other.com/'), current: Uri.parse('https://other.com/x'), isLinkClick: true).action,
        NavAction.allow,
        reason: 'same host');
    expect(p.decide(target: Uri.parse('https://other.com/'), current: current, isLinkClick: false).action, NavAction.allow,
        reason: 'typed URL');
    expect(
        policy(pluginHosts: {'sp.example.jp'})
            .decide(target: Uri.parse('https://other.com/'), current: current, isLinkClick: true)
            .action,
        NavAction.allow,
        reason: 'in-app mode');
  });

  test('plugin interceptor overrides the external setting', () {
    final p = policy(mode: ExternalLinkMode.external);
    p.interceptor = (url) => url.host == 'deny.me' ? 'deny' : (url.host == 'keep.me' ? 'allow' : null);
    expect(p.decide(target: Uri.parse('https://deny.me/'), isLinkClick: true).action, NavAction.cancel);
    expect(p.decide(target: Uri.parse('https://keep.me/'), current: Uri.parse('https://a/'), isLinkClick: true).action,
        NavAction.allow);
    expect(p.decide(target: Uri.parse('https://other/'), current: Uri.parse('https://a/'), isLinkClick: true).action,
        NavAction.external);
  });

  test('normalizeInput adds https, keeps schemes, searches words', () {
    expect(NavigationPolicy.normalizeInput('example.com').toString(), 'https://example.com');
    expect(NavigationPolicy.normalizeInput('sp.pokepara.jp/manage/').toString(), 'https://sp.pokepara.jp/manage/');
    expect(NavigationPolicy.normalizeInput('http://example.com/a').toString(), 'http://example.com/a');
    expect(NavigationPolicy.normalizeInput('localhost:8443/x').toString(), 'https://localhost:8443/x');
    expect(NavigationPolicy.normalizeInput('192.168.1.13:8443').toString(), 'https://192.168.1.13:8443');
    expect(NavigationPolicy.normalizeInput('wsi://install?url=https%3A%2F%2Fx').scheme, 'wsi');
    expect(NavigationPolicy.normalizeInput('flutter inappwebview').toString(),
        'https://www.google.com/search?q=flutter+inappwebview');
    expect(NavigationPolicy.normalizeInput('  ').toString(), 'about:blank');
  });
}

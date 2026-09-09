// M1: the 7 WSI sample plugins running in WSI Browser (P2-15).
//
// A local HTTP server inside the test process serves the same fixture pages
// the SDK contract tests use (packages/wsi_sdk/test/fixtures). Samples that
// target example.com / nipponsteel.com are installed with their domains
// rewritten to 127.0.0.1; the '*' samples are installed untouched.
//
//   flutter test integration_test/samples_test.dart -d <device>
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wsi_browser/app/app.dart';
import 'package:wsi_browser/app/app_scope.dart';
import 'package:wsi_browser/browser/tab_manager.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/runtime/runtime.dart';

import 'fixtures.dart';
import 'samples_data.g.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late HttpServer server;
  late String base;
  late AppServices services;
  late PluginRuntime runtime;

  Uint8List zipOf(Map<String, String> files) {
    final a = Archive();
    for (final e in files.entries) {
      final bytes = utf8.encode(e.value);
      a.addFile(ArchiveFile(e.key, bytes.length, bytes));
    }
    return Uint8List.fromList(ZipEncoder().encode(a));
  }

  Future<void> installSample(String id, {List<String>? domains}) async {
    final files = Map<String, String>.from(kSampleFiles[id]!);
    if (domains != null) {
      final def = jsonDecode(files['plugin.json']!) as Map<String, dynamic>;
      def['domains'] = domains;
      files['plugin.json'] = jsonEncode(def);
    }
    await runtime.repository.install(runtime.importer.open(zipOf(files)));
  }

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = 'http://127.0.0.1:${server.port}';
    server.listen((req) {
      final body = req.uri.path.contains('DijAW40') ? kDijaw40Html : kArticleHtml;
      req.response.headers.contentType = ContentType('text', 'html', charset: 'utf-8');
      req.response.write(body);
      req.response.close();
    });

    services = AppServices.create(AppDatabase(NativeDatabase.memory()));
    await services.settings.load();
    runtime = PluginRuntime(services);
    services.extras['runtime'] = runtime;
    await runtime.init();

    await installSample('hello-world', domains: ['127.0.0.1']);
    await installSample('nipponsteel-dijaw40-csv', domains: ['127.0.0.1']);
    await installSample('banner-demo', domains: ['127.0.0.1']);
    for (final id in ['highlighter', 'jisho-popup', 'markdown-copy', 'outline-panel', 'url-expander']) {
      await installSample(id);
    }
    services.tabs.open(kStartPageUrl);
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  /// Evaluate JS in the active tab.
  Future<Object?> js(String source) async {
    final c = services.tabs.active!.controller!;
    return c.evaluateJavascript(source: source);
  }

  /// Poll [source] until it returns [expected] (JSON-comparable) or time out.
  Future<void> waitJs(WidgetTester tester, String source, Object? expected, {Duration timeout = const Duration(seconds: 20)}) async {
    final deadline = DateTime.now().add(timeout);
    Object? last;
    while (DateTime.now().isBefore(deadline)) {
      try {
        last = await js(source);
      } catch (_) {
        last = null;
      }
      if (jsonEncode(last) == jsonEncode(expected)) return;
      await tester.pump(const Duration(milliseconds: 250));
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    fail('timeout waiting for `$source` == ${jsonEncode(expected)}, last: ${jsonEncode(last)}');
  }

  Future<void> load(WidgetTester tester, String path) async {
    final tab = services.tabs.active!;
    await tab.load('$base$path');
    // wait for the WebView and the injection to settle
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!tab.isLoading && tab.controller != null && tab.url.startsWith(base)) {
        final ready = await js('typeof globalThis.__wsiRun') == 'function';
        if (ready) return;
      }
    }
    fail('page did not load: $path');
  }

  Future<void> selectText(String selector, {int? start, int? end}) => js('''
    (function(){ var el = document.querySelector('$selector'); var r = document.createRange();
      ${start == null ? "r.selectNodeContents(el);" : "r.setStart(el.firstChild, $start); r.setEnd(el.firstChild, $end);"}
      var s = window.getSelection(); s.removeAllRanges(); s.addRange(r); return true; })()''');

  testWidgets('M1: the 7 WSI samples run in WSI Browser', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(WsiBrowserApp(services: services, hooks: runtime.hooks));
      await tester.pump(const Duration(milliseconds: 500));

      // ---- all 6 universal / example.com samples on the article page ----
      await load(tester, '/article.html');
      await waitJs(tester, "document.querySelectorAll('.wsi-floating-button').length", 5);
      await waitJs(tester, "document.querySelectorAll('.wsi-url-expander').length", 1);
      expect(await js("document.querySelectorAll('.wsi-csv-export-btn').length"), 0, reason: 'nipponsteel does not match this path');
      expect(await js('typeof window.WSI'), 'undefined', reason: 'WSI never leaks onto window');
      await waitJs(tester, "typeof globalThis.__wsiEmit", 'function');
      // badge: 8 = 5 '*' samples + hello-world + nipponsteel + banner-demo (rewritten to 127.0.0.1, no paths)
      expect(services.tabs.active!.pluginCount, 8);

      // ---- banner-demo (P3): settings, menu, wsi:// pages ----
      await waitJs(tester, "document.querySelector('[data-banner-demo]') && document.querySelector('[data-banner-demo]').textContent", 'Hello from banner-demo');
      final banner = runtime.repository.byId('banner-demo')!;
      await runtime.settingsStore.set(banner.manifest, 'text', 'Changed by host');
      await runtime.bridge.broadcast('banner-demo', 'settings.change', {'key': 'text', 'value': 'Changed by host'});
      await waitJs(tester, "document.querySelector('[data-banner-demo]').textContent", 'Changed by host');
      final section = runtime.menuBus.sections.where((sec) => sec.title == 'Banner Demo').single;
      expect(section.items.map((i) => i.type.name).toList(), ['page', 'toggle', 'separator', 'action']);
      await section.items[1].onSelect!(false); // toggle -> plugin sets visible=false
      await waitJs(tester, "document.querySelector('[data-banner-demo]').classList.contains('banner-demo--hidden')", true);
      expect(await runtime.settingsStore.get(banner.manifest, 'visible'), false);
      final settingsHtml = await runtime.pageHost.resolve(Uri.parse('wsi://plugin/banner-demo/pages/settings.html'));
      expect(settingsHtml, isNotNull);
      expect(settingsHtml!.mime, 'text/html');
      expect(await runtime.pageHost.resolve(Uri.parse('wsi://plugin/hello-world/pages/settings.html'), allowedPluginId: 'banner-demo'), isNull);

      // ---- hello-world: button opens alert -> Flutter dialog with the config message ----
      // alert() blocks the page until the Flutter dialog is answered, so do not await the click
      unawaited(js("document.querySelector('.wsi-floating-button[title^=\"👋\"]').click()"));
      for (var i = 0; i < 20 && find.text('Hello from WSI!').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      expect(find.text('Hello from WSI!'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(milliseconds: 300));

      // ---- highlighter: WSI.storage round trip survives a reload ----
      await selectText('#para-1', start: 0, end: 12);
      await js("document.querySelector('.wsi-floating-button[title^=\"🖍️\"]').click()");
      await waitJs(tester, "document.querySelectorAll('.wsi-highlight').length", 1);
      await waitJs(tester, "document.querySelector('.wsi-highlight').textContent", 'ハイライトしたいテキスト');
      await Future<void>.delayed(const Duration(milliseconds: 500)); // let storage.set land
      await services.tabs.active!.controller!.reload();
      await Future<void>.delayed(const Duration(seconds: 1));
      await waitJs(tester, "document.querySelectorAll('.wsi-highlight').length", 1);
      await waitJs(tester, "document.querySelectorAll('.wsi-floating-button').length", 5); // every plugin re-injected

      // ---- outline-panel: panel lists the 5 headings as a bottom sheet (narrow viewport) ----
      await js("document.querySelector('.wsi-floating-button[title^=\"📑\"]').click()");
      await waitJs(tester, "document.querySelectorAll('.wsi-panel .wsi-outline-item').length", 5);
      expect(await js("document.querySelector('.wsi-panel').dataset.wsiLayout"), 'sheet');
      await js("document.querySelector('.wsi-panel button[aria-label=close]').click()");
      await waitJs(tester, "document.querySelectorAll('.wsi-panel').length", 0);

      // ---- jisho-popup: panel for the selected word ----
      await selectText('#jp-word');
      await js("document.querySelector('.wsi-floating-button[title^=\"辞\"]').click()");
      await waitJs(tester, "document.querySelectorAll('.wsi-panel .wsi-jisho-query').length", 1);
      await js("document.querySelector('.wsi-panel button[aria-label=close]').click()");

      // ---- markdown-copy: toast after copying ----
      await selectText('#md-source');
      await js("document.querySelector('.wsi-floating-button[title^=\"📋\"]').click()");
      await waitJs(tester, "document.querySelectorAll('.wsi-md-toast--show').length", 1);

      // ---- url-expander: hover -> tooltip, resolved through WSI.fetch (dio) ----
      await js("document.querySelector('#short-link').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))");
      await waitJs(tester, "getComputedStyle(document.querySelector('.wsi-url-expander')).display", 'block');
      await waitJs(tester, "/^(→ |取得失敗|エラー|\\(リダイレクトなし\\))/.test(document.querySelector('.wsi-url-expander').textContent)", true, timeout: const Duration(seconds: 30));

      // ---- nipponsteel: CSV button only on the DijAW40 path ----
      await load(tester, '/esys969/dij_web/webapp/page/DijAW40');
      await waitJs(tester, "document.querySelectorAll('.ControlHeader .wsi-csv-export-btn').length", 1);
      await waitJs(tester, "document.querySelectorAll('.wsi-floating-button').length", 5); // '*' samples run here too
      expect(services.tabs.active!.pluginCount, 8);

      // ---- disabling a plugin takes effect on the next load, global switch stops all ----
      await runtime.repository.setEnabled('hello-world', false);
      await load(tester, '/article.html');
      await waitJs(tester, "document.querySelectorAll('.wsi-floating-button').length", 4);
      expect(services.tabs.active!.pluginCount, 7);
      await services.settings.setWsiEnabled(false);
      await load(tester, '/article.html');
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(await js("document.querySelectorAll('.wsi-floating-button').length"), 0);
      expect(services.tabs.active!.pluginCount, 0);
      await services.settings.setWsiEnabled(true);
      await runtime.repository.setEnabled('hello-world', true);
    });
  }, timeout: const Timeout(Duration(minutes: 5)));

  // keep the binding referenced (framePolicy tuning is not needed on device)
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
}

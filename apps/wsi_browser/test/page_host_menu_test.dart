import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/bridge_ops/registry.dart';
import 'package:wsi_browser/browser/app_menu.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/runtime/bridge.dart';
import 'package:wsi_browser/runtime/importer.dart';
import 'package:wsi_browser/runtime/log_sink.dart';
import 'package:wsi_browser/runtime/menu_bus.dart';
import 'package:wsi_browser/runtime/page_host.dart';
import 'package:wsi_browser/runtime/repository.dart';
import 'package:wsi_browser/settings/host_settings.dart';

Uint8List zipOf(Map<String, String> files) {
  final a = Archive();
  for (final e in files.entries) {
    final b = utf8.encode(e.value);
    a.addFile(ArchiveFile(e.key, b.length, b));
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}

final manifest = {
  'formatVersion': 2,
  'id': 'pg',
  'name': 'Pages plugin',
  'version': '1.0.0',
  'domains': ['example.com'],
  'scripts': {'main': 'main.js'},
  'permissions': ['pages', 'menu'],
  'pages': {
    'settings': {'file': 'pages/settings.html', 'display': 'sheet'}
  },
};

void main() {
  late AppDatabase db;
  late PluginRepository repo;
  late HostSettings settings;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = HostSettings(db);
    await settings.load();
    FlutterSecureStorage.setMockInitialValues({});
    repo = PluginRepository(db, settings, secureStorage: const FlutterSecureStorage());
    await repo.load();
    await repo.install(ZipImporter().open(zipOf({
      'plugin.json': jsonEncode(manifest),
      'main.js': '',
      'pages/settings.html': '<p>hi</p>',
      'pages/settings.js': 'x',
    })));
  });

  tearDown(() => db.close());

  group('PageHost', () {
    test('builds and parses wsi://plugin URLs', () {
      final url = PageHost.pageUrl('pg', 'pages/settings.html', {'a': '1'});
      expect(url.toString(), 'wsi://plugin/pg/pages/settings.html?a=1');
      expect(PageHost.parse(url), (pluginId: 'pg', path: 'pages/settings.html'));
      // Uri normalises '..' before we see it: the resulting URL points at another plugin,
      // which resolve() rejects through allowedPluginId (see below)
      expect(PageHost.parse(Uri.parse('wsi://plugin/pg/../other/main.js')), (pluginId: 'other', path: 'main.js'));
      expect(PageHost.parse(Uri(scheme: 'wsi', host: 'plugin', pathSegments: ['pg', '..', 'x.js'])), isNull, reason: 'raw traversal');
      expect(PageHost.parse(Uri.parse('wsi://plugin/pg')), isNull, reason: 'no path');
      expect(PageHost.parse(Uri.parse('wsi://install?url=x')), isNull);
      expect(PageHost.parse(Uri.parse('https://plugin/pg/main.js')), isNull);
      expect(PageHost.parse(Uri.parse('wsi://plugin/bad%20id/main.js')), isNull);
    });

    test('resolves files of the plugin only', () async {
      final host = PageHost(repo);
      final r = await host.resolve(Uri.parse('wsi://plugin/pg/pages/settings.html'));
      expect(utf8.decode(r!.bytes), '<p>hi</p>');
      expect(r.mime, 'text/html');
      expect((await host.resolve(Uri.parse('wsi://plugin/pg/pages/settings.js')))!.mime, 'text/javascript');
      expect(await host.resolve(Uri.parse('wsi://plugin/pg/missing.js')), isNull);
      expect(await host.resolve(Uri.parse('wsi://plugin/other/pages/settings.html')), isNull, reason: 'not installed');
      expect(await host.resolve(Uri.parse('wsi://plugin/pg/pages/settings.html'), allowedPluginId: 'other'), isNull, reason: 'cross-plugin');
    });
  });

  group('MenuBus', () {
    late Bridge bridge;
    late MenuBus bus;
    final opened = <String>[];

    setUp(() {
      bridge = Bridge(repository: repo, registry: OpRegistry(), logs: LogSink(db, settings));
      bus = MenuBus(bridge: bridge, repository: repo, openPage: (p, page, params) async => opened.add('${p.id}:${page.name}'));
      opened.clear();
    });

    test('sections follow registrations, page items open pages, toggles flip', () async {
      final session = bridge.issue(pluginId: 'pg', webViewKey: 1, context: BridgeContext.page);
      var notified = 0;
      bus.addListener(() => notified++);
      bus.register(session, [
        MenuEntry(id: 'settings', type: 'page', label: '設定', page: 'settings'),
        MenuEntry(id: 'on', type: 'toggle', label: 'On', checked: true),
        MenuEntry(id: 'sep', type: 'separator', label: ''),
        MenuEntry(id: 'go', type: 'action', label: 'Go'),
      ]);
      expect(notified, 1);
      final sections = bus.sections;
      expect(sections.length, 1);
      expect(sections.first.title, 'Pages plugin');
      expect(sections.first.items.map((i) => i.type), [AppMenuItemType.page, AppMenuItemType.toggle, AppMenuItemType.separator, AppMenuItemType.action]);

      await sections.first.items.first.onSelect!(null);
      expect(opened, ['pg:settings']);

      await sections.first.items[1].onSelect!(false);
      expect(bus.sections.first.items[1].checked, isFalse);
      expect(bus.update('pg', 'go', label: 'Run'), isTrue);
      expect(bus.sections.first.items.last.label, 'Run');
      expect(bus.update('pg', 'nope'), isFalse);

      // re-registering from the same session replaces its items
      bus.register(session, [MenuEntry(id: 'only', type: 'action', label: 'Only')]);
      expect(bus.sections.first.items.length, 1);
      expect(bus.registrationCount('pg'), 1);
    });

    test('page sessions are dropped with their WebView, disabled plugins are hidden', () async {
      final page = bridge.issue(pluginId: 'pg', webViewKey: 'tab1', context: BridgeContext.page);
      final worker = bridge.issue(pluginId: 'pg', webViewKey: 'worker:pg', context: BridgeContext.worker);
      bus.register(page, [MenuEntry(id: 'a', type: 'action', label: 'A')]);
      bus.register(worker, [MenuEntry(id: 'b', type: 'action', label: 'B')]);
      expect(bus.sections.first.items.length, 2);

      bus.dropSessions('tab1');
      expect(bus.sections.first.items.map((i) => i.label), ['B'], reason: 'worker items survive navigation');

      bridge.revoke(worker);
      expect(bus.sections, isEmpty, reason: 'revoked sessions are pruned');

      bus.register(bridge.issue(pluginId: 'pg', webViewKey: 'w2', context: BridgeContext.worker), [MenuEntry(id: 'c', type: 'action', label: 'C')]);
      await repo.setEnabled('pg', false);
      expect(bus.sections, isEmpty);
      bus.dropPlugin('pg');
      expect(bus.registrationCount('pg'), 0);
    });
  });

  test('PageStack tracks open pages', () {
    final stack = PageStack();
    stack.push('pg', 'settings');
    stack.push('pg', 'queue');
    expect(stack.isOpen('pg'), isTrue);
    stack.pop('pg', 'settings');
    expect(stack.open.map((e) => e.page), ['queue']);
    stack.pop('pg', 'queue');
    expect(stack.isOpen('pg'), isFalse);
  });
}

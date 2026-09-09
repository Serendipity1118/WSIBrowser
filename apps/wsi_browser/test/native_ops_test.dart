import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/bridge_ops/credentials_ops.dart';
import 'package:wsi_browser/bridge_ops/registry.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/runtime/backup.dart';
import 'package:wsi_browser/runtime/importer.dart';
import 'package:wsi_browser/runtime/repository.dart';
import 'package:wsi_browser/runtime/resource_blocker.dart';
import 'package:wsi_browser/settings/host_settings.dart';

Uint8List zipOf(Map<String, String> files) {
  final a = Archive();
  for (final e in files.entries) {
    final b = utf8.encode(e.value);
    a.addFile(ArchiveFile(e.key, b.length, b));
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}

Map<String, Object?> manifest(String id, {List<String> domains = const ['example.com'], List<String> permissions = const ['credentials', 'blockResources']}) => {
      'formatVersion': 2,
      'id': id,
      'name': 'Plugin $id',
      'version': '1.0.0',
      'domains': domains,
      'scripts': {'main': 'main.js'},
      'permissions': permissions,
      'settingsSchema': [
        {'key': 'n', 'type': 'number', 'default': 1}
      ],
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
    await repo.install(ZipImporter().open(zipOf({'plugin.json': jsonEncode(manifest('a')), 'main.js': ''})));
    await repo.install(ZipImporter().open(zipOf({'plugin.json': jsonEncode(manifest('b', domains: ['*.other.jp'])), 'main.js': ''})));
  });

  tearDown(() => db.close());

  group('backup', () {
    test('export is encrypted and restores data + settings of installed plugins', () async {
      await db.setPluginData('a', 'k', {'x': 1});
      await db.setPluginData('b', 'k', 'bee');
      await db.into(db.pluginSettings).insert(PluginSettingsCompanion.insert(pluginId: 'a', key: 'n', value: 7));
      final service = BackupService(db, repo, iterations: 1000);
      final file = await service.export('pass1234');
      final text = utf8.decode(file);
      expect(text, contains('"format":"wsi-backup-1"'));
      expect(text, isNot(contains('bee')), reason: 'plaintext never appears');
      expect(text, isNot(contains('"x":1')));

      // wrong password
      await expectLater(service.restore(file, 'nope'), throwsA(isA<BackupException>()));

      // wipe, then restore
      await db.removePluginData('a', 'k');
      await db.removePluginData('b', 'k');
      await (db.delete(db.pluginSettings)).go();
      await repo.delete('b');
      final restored = await service.restore(file, 'pass1234');
      expect(restored, ['a'], reason: 'b is no longer installed and is skipped');
      expect(await db.getPluginData('a', 'k'), {'x': 1});
      final n = await (db.select(db.pluginSettings)..where((t) => t.pluginId.equals('a'))).getSingle();
      expect(n.value, 7);
      expect(() => service.export('abc'), throwsA(isA<BackupException>()), reason: 'short password');
      await expectLater(service.restore(Uint8List.fromList(utf8.encode('{}')), 'pass1234'), throwsA(isA<BackupException>()));
    });
  });

  group('credentials ops', () {
    test('namespaced per plugin and profile, listable, removable', () async {
      final registry = OpRegistry();
      registerCredentialsOps(registry, storage: const FlutterSecureStorage());
      final session = BridgeSession(token: 't', pluginId: 'a', context: BridgeContext.page, webViewKey: 1);
      final plugin = repo.byId('a')!;
      Future<Object?> call(String op, Map<String, Object?> payload) =>
          registry.lookup(op)!.handler(BridgeCall(session: session, plugin: plugin, op: op, payload: payload));

      expect(await call('credentials.get', {'profile': 'main'}), isNull);
      await call('credentials.set', {'profile': 'main', 'value': {'id': 'user', 'password': 'p@ss'}});
      await call('credentials.set', {'profile': 'sub', 'value': {'id': 'u2', 'password': 'x'}});
      expect(await call('credentials.get', {'profile': 'main'}), {'id': 'user', 'password': 'p@ss'});
      expect(await call('credentials.list', {}), unorderedEquals(['main', 'sub']));
      await call('credentials.remove', {'profile': 'main'});
      expect(await call('credentials.get', {'profile': 'main'}), isNull);
      expect(() => call('credentials.set', {'profile': 'bad name', 'value': {'id': '', 'password': ''}}), throwsA(isA<OpError>()));
      expect(() => call('credentials.set', {'profile': 'x', 'value': 'nope'}), throwsA(isA<OpError>()));
      expect(registry.lookup('credentials.get')!.permission, 'credentials');
      // the repository's delete cleans the plugin's credentials
      await repo.delete('a');
      expect(await const FlutterSecureStorage().read(key: credentialKey('a', 'sub')), isNull);
    });
  });

  group('resource blocker', () {
    test('merges rules of plugins matching the page host and decides per request', () {
      final blocker = ResourceBlocker(repo);
      blocker.set('a', BlockRules.fromPayload({'images': true, 'urls': ['/ads/', '*.tracker.com/*']}));
      blocker.set('b', BlockRules.fromPayload({'media': true}));

      final onExample = blocker.effectiveFor('example.com');
      expect(onExample.images, isTrue);
      expect(onExample.media, isFalse, reason: 'b does not match example.com');
      expect(blocker.effectiveFor('www.other.jp').media, isTrue);

      WebResourceRequest req(String url, {bool main = false, Map<String, String>? headers}) =>
          WebResourceRequest(url: WebUri(url), isForMainFrame: main, headers: headers);
      expect(blocker.shouldBlock('example.com', req('https://cdn.example.com/a.png')), isTrue);
      expect(blocker.shouldBlock('example.com', req('https://cdn.example.com/a.png', main: true)), isFalse, reason: 'main frame never blocked');
      expect(blocker.shouldBlock('example.com', req('https://x/y', headers: {'Accept': 'image/webp,*/*'})), isTrue);
      expect(blocker.shouldBlock('example.com', req('https://x/ads/banner.js')), isTrue);
      expect(blocker.shouldBlock('example.com', req('https://a.tracker.com/pixel')), isTrue);
      expect(blocker.shouldBlock('example.com', req('https://x/app.js')), isFalse);
      expect(blocker.shouldBlock('example.com', req('https://x/movie.mp4')), isFalse, reason: 'media not blocked on example.com');
      expect(blocker.shouldBlock('www.other.jp', req('https://x/movie.mp4')), isTrue);

      blocker.set('a', const BlockRules());
      expect(blocker.rules.containsKey('a'), isFalse, reason: 'empty rules clear the entry');
      blocker.clear('b');
      expect(blocker.shouldBlock('www.other.jp', req('https://x/movie.mp4')), isFalse);
    });
  });
}

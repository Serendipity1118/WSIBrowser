import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/runtime/importer.dart';
import 'package:wsi_browser/runtime/log_sink.dart';
import 'package:wsi_browser/runtime/manifest.dart';
import 'package:wsi_browser/runtime/policy_cache.dart';
import 'package:wsi_browser/runtime/repository.dart';
import 'package:wsi_browser/settings/host_settings.dart';

/// Canned HTTP adapter: returns [responses] in order (a String body or an Exception).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responses);
  final List<Object> responses;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    calls++;
    final r = responses.removeAt(0);
    if (r is Exception) throw r;
    return ResponseBody.fromString(r as String, 200, headers: {
      'content-type': ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late AppDatabase db;
  late PluginRepository repo;
  late _FakeAdapter adapter;
  late PolicyStore cache;

  final manifest = {
    'formatVersion': 2,
    'id': 'pol',
    'name': 'Policy plugin',
    'version': '1.0.0',
    'domains': ['*'],
    'scripts': {'main': 'main.js'},
    'permissions': ['policy'],
    'policy': {'url': 'https://api.example/v1/plugins/pol/policy', 'ttlSeconds': 60, 'defaults': {'minActionIntervalMs': 3000, 'onlyDefault': 1}},
  };

  Uint8List zip() {
    final a = Archive();
    for (final e in {'plugin.json': jsonEncode(manifest), 'main.js': ''}.entries) {
      final b = utf8.encode(e.value);
      a.addFile(ArchiveFile(e.key, b.length, b));
    }
    return Uint8List.fromList(ZipEncoder().encode(a));
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = HostSettings(db);
    await settings.load();
    FlutterSecureStorage.setMockInitialValues({});
    repo = PluginRepository(db, settings, secureStorage: const FlutterSecureStorage());
    await repo.load();
    await repo.install(ZipImporter().open(zip()));
    adapter = _FakeAdapter([]);
    final dio = Dio()..httpClientAdapter = adapter;
    cache = PolicyStore(db, repo, LogSink(db, settings), dio: dio);
  });

  tearDown(() => db.close());

  test('fetches, merges with defaults, then serves from cache within the TTL', () async {
    adapter.responses.add(jsonEncode({'pluginId': 'pol', 'values': {'minActionIntervalMs': 5000, 'features': {'x': true}}}));
    final m = repo.byId('pol')!.manifest;
    expect(await cache.get(m, 'minActionIntervalMs'), 5000);
    expect(await cache.get(m, 'onlyDefault'), 1, reason: 'defaults fill missing keys');
    expect(await cache.get(m, 'features'), {'x': true});
    expect(adapter.calls, 1);
    await cache.values(m);
    expect(adapter.calls, 1, reason: 'no refetch within ttl');

    // persisted: a fresh cache instance reads the row without a network call
    final again = PolicyStore(db, repo, LogSink(db, HostSettings(db)), dio: Dio()..httpClientAdapter = _FakeAdapter([]));
    expect(await again.get(m, 'minActionIntervalMs'), 5000);
  });

  test('network failure falls back to the stale cache, and to defaults when there is none', () async {
    final m = repo.byId('pol')!.manifest;
    adapter.responses.add(Exception('offline'));
    expect(await cache.values(m), {'minActionIntervalMs': 3000, 'onlyDefault': 1}, reason: 'defaults when nothing cached');

    adapter.responses.add(jsonEncode({'values': {'minActionIntervalMs': 7000}}));
    expect(await cache.get(m, 'minActionIntervalMs'), 7000);
    adapter.responses.add(Exception('offline'));
    expect(await cache.get(m, 'minActionIntervalMs'), 7000, reason: 'forced refresh fails -> stale cache');
    expect((await cache.values(m, force: true))['minActionIntervalMs'], 7000);
  });

  test('plugins without a policy block get an empty map', () async {
    final noPolicy = PluginManifestNoPolicy.of(repo.byId('pol')!.manifest);
    expect(await cache.values(noPolicy), isEmpty);
    expect(adapter.calls, 0);
  });
}

extension PluginManifestNoPolicy on PluginManifest {
  static PluginManifest of(PluginManifest m) => PluginManifest.parse({...m.raw}..remove('policy'));
}

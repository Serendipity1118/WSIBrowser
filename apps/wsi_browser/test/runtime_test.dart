import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/runtime/domain_matcher.dart';
import 'package:wsi_browser/runtime/importer.dart';
import 'package:wsi_browser/runtime/manifest.dart';
import 'package:wsi_browser/runtime/repository.dart';
import 'package:wsi_browser/settings/host_settings.dart';

Map<String, Object?> v1() => {
      'id': 'hello-world',
      'name': 'Hello',
      'version': '1.0.0',
      'domains': ['example.com'],
      'scripts': {'main': 'main.js', 'runAt': 'document_idle'},
      'styles': ['style.css'],
      'config': {'message': 'hi'},
    };

Map<String, Object?> v2() => {
      'formatVersion': 2,
      'id': 'example-site',
      'name': 'Example',
      'version': '2.0.0-beta.1',
      'domains': ['example.com', '*.example.com', '*'],
      'paths': ['/manage/**'],
      'scripts': {'main': 'dist/main.js'},
      'styles': ['style.css'],
      'background': 'dist/worker.js',
      'pages': {
        'settings': {'file': 'pages/settings.html', 'display': 'sheet'}
      },
      'menu': [
        {'id': 'settings', 'label': 'Settings', 'type': 'page', 'page': 'settings'},
        {'type': 'separator'},
        {'id': 'go', 'label': 'Go', 'type': 'action'},
      ],
      'permissions': ['fetch', 'tabs', 'pages', 'menu', 'policy', 'credentials'],
      'settingsSchema': [
        {'key': 'n', 'type': 'number', 'default': 2},
        {'key': 'mode', 'type': 'select', 'options': ['a', 'b']},
      ],
      'policy': {'url': 'https://api.example.workers.dev/v1/plugins/example-site/policy', 'ttlSeconds': 3600, 'defaults': {'minActionIntervalMs': 3000}},
      'updateUrl': 'https://api.example.workers.dev/v1/plugins/example-site/latest',
      'config': {'targetPath': '/manage/'},
    };

final files = {'dist/main.js', 'main.js', 'style.css', 'dist/worker.js', 'pages/settings.html'};
bool exists(String f) => files.contains(f);

Uint8List zipOf(Map<String, String> entries) {
  final a = Archive();
  for (final e in entries.entries) {
    final bytes = utf8.encode(e.value);
    a.addFile(ArchiveFile(e.key, bytes.length, bytes));
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}

void main() {
  group('validateManifest (same rules as wsi-plugin validate)', () {
    test('valid v1 and v2', () {
      expect(validateManifest(v1(), fileExists: exists), isEmpty);
      expect(validateManifest(v2(), fileExists: exists), isEmpty);
    });

    test('required fields and formats', () {
      final errors = validateManifest(<String, Object?>{}, fileExists: exists);
      for (final needle in ['id is required', 'name is required', 'version is required', 'domains must be', 'scripts.main is required']) {
        expect(errors.any((e) => e.contains(needle)), isTrue, reason: needle);
      }
      expect(validateManifest({...v1(), 'id': 'bad id!'}, fileExists: exists).any((e) => e.contains('id must match')), isTrue);
      expect(validateManifest({...v1(), 'version': '1.0'}, fileExists: exists).any((e) => e.contains('semantic')), isTrue);
      expect(validateManifest({...v1(), 'domains': ['not a domain']}, fileExists: exists).any((e) => e.contains('domains[0]')), isTrue);
      expect(validateManifest({...v1(), 'scripts': {'main': 'missing.js'}}, fileExists: exists).any((e) => e.contains('not found')), isTrue);
      expect(validateManifest({...v1(), 'scripts': {'main': 'main.js', 'runAt': 'later'}}, fileExists: exists).any((e) => e.contains('runAt')), isTrue);
    });

    test('cross references and permissions', () {
      expect(validateManifest({...v2(), 'menu': [{'id': 'q', 'label': 'Q', 'type': 'page', 'page': 'queue'}]}, fileExists: exists).any((e) => e.contains('unknown page')), isTrue);
      final noPerm = validateManifest({...v2(), 'permissions': ['fetch']}, fileExists: exists);
      expect(noPerm.where((e) => e.contains('permission')).length, 3);
      expect(validateManifest({...v2(), 'permissions': ['root']}, fileExists: exists).any((e) => e.contains('unknown')), isTrue);
      expect(validateManifest({...v2(), 'policy': {'url': 'http://x/', 'ttlSeconds': 10, 'defaults': []}}, fileExists: exists).where((e) => e.startsWith('policy')).length, 3);
      expect(validateManifest({...v1(), 'permissions': ['fetch']}, fileExists: exists), contains('permissions requires formatVersion 2'));
    });

    test('parse: v1 gets storage + fetch, v2 what it declares plus storage', () {
      final a = PluginManifest.parse(v1());
      expect(a.permissions, ['storage', 'fetch']);
      expect(a.runAt, 'document_idle');
      expect(a.config, {'message': 'hi'});
      expect(a.isV2, isFalse);
      final b = PluginManifest.parse(v2());
      expect(b.permissions, ['storage', 'fetch', 'tabs', 'pages', 'menu', 'policy', 'credentials']);
      expect(b.sensitivePermissions, ['tabs', 'credentials']);
      expect(b.pages.single.display, 'sheet');
      expect(b.menu.length, 3);
      expect(b.policy!.defaults['minActionIntervalMs'], 3000);
      expect(b.referencedFiles, ['plugin.json', 'dist/main.js', 'style.css', 'dist/worker.js', 'pages/settings.html']);
      expect(() => PluginManifest.parse({...v1(), 'id': ''}), throwsA(isA<ManifestException>()));
    });
  });

  group('domain matcher (WSI matchesDomain + paths)', () {
    test('exact, wildcard subdomain, match-all', () {
      expect(matchesDomain('example.com', ['example.com']), isTrue);
      expect(matchesDomain('www.example.com', ['example.com']), isFalse);
      expect(matchesDomain('www.example.com', ['*.example.com']), isTrue);
      expect(matchesDomain('example.com', ['*.example.com']), isTrue);
      expect(matchesDomain('notexample.com', ['*.example.com']), isFalse);
      expect(matchesDomain('anything.org', ['*']), isTrue);
      expect(matchesDomain('EXAMPLE.com', ['example.com']), isTrue);
      expect(matchesDomain('', ['*']), isFalse);
    });

    test('paths globs', () {
      expect(matchesPath('/anything', []), isTrue);
      expect(matchesPath('/manage/a/b', ['/manage/**']), isTrue);
      expect(matchesPath('/manage', ['/manage/**']), isTrue);
      expect(matchesPath('/manager', ['/manage/**']), isFalse);
      expect(matchesPath('/blog/2024', ['/blog/*']), isTrue);
      expect(matchesPath('/blog/2024/x', ['/blog/*']), isFalse);
      expect(matchesPath('/esys969/dij_web/webapp/page/DijAW40', ['/esys969/**/DijAW40']), isTrue);
      expect(matchesUrl(Uri.parse('https://sp.example.jp/manage/x'), ['*.example.jp'], ['/manage/**']), isTrue);
      expect(matchesUrl(Uri.parse('https://sp.example.jp/other'), ['*.example.jp'], ['/manage/**']), isFalse);
    });
  });

  group('ZipImporter', () {
    final importer = ZipImporter();

    test('extracts, validates against real files, reads code and css', () {
      final zip = zipOf({'plugin.json': jsonEncode(v1()), 'main.js': 'WSI.log(1)', 'style.css': 'body{}'});
      final pkg = importer.open(zip);
      expect(pkg.manifest.id, 'hello-world');
      expect(pkg.mainJs, 'WSI.log(1)');
      expect(pkg.css, 'body{}');
      expect(pkg.files.keys, containsAll(['plugin.json', 'main.js', 'style.css']));
    });

    test('accepts a zipped directory and drops metadata / traversal entries', () {
      final zip = zipOf({
        'my-plugin/plugin.json': jsonEncode(v1()),
        'my-plugin/main.js': '1',
        'my-plugin/style.css': '',
        '__MACOSX/my-plugin/._main.js': 'x',
        'my-plugin/.DS_Store': 'x',
        'my-plugin/../evil.js': 'x',
      });
      final pkg = importer.open(zip);
      expect(pkg.files.keys.toSet(), {'plugin.json', 'main.js', 'style.css'});
    });

    test('rejects missing manifest, invalid json, missing files, bad zip', () {
      expect(() => importer.open(zipOf({'main.js': '1'})), throwsA(isA<ImportException>()));
      expect(() => importer.open(zipOf({'plugin.json': '{oops'})), throwsA(isA<ImportException>()));
      expect(
        () => importer.open(zipOf({'plugin.json': jsonEncode(v1()), 'main.js': '1'})),
        throwsA(predicate((e) => e is ImportException && e.details.any((d) => d.contains('styles[0] not found')))),
      );
      expect(() => importer.open(Uint8List.fromList([1, 2, 3])), throwsA(isA<ImportException>()));
    });
  });

  group('PluginRepository', () {
    late AppDatabase db;
    late PluginRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final settings = HostSettings(db);
      await settings.load();
      FlutterSecureStorage.setMockInitialValues({});
      repo = PluginRepository(db, settings, secureStorage: const FlutterSecureStorage());
      await repo.load();
    });

    tearDown(() => db.close());

    ImportPackage pkg(Map<String, Object?> manifest, {String main = 'WSI.log(1)'}) =>
        ZipImporter().open(zipOf({'plugin.json': jsonEncode(manifest), 'main.js': main, 'style.css': 'a{}', 'dist/main.js': main, 'dist/worker.js': '', 'pages/settings.html': ''}));

    test('install, match by url, toggle, overwrite keeps data, delete cascades', () async {
      await repo.install(pkg(v1()));
      await repo.install(pkg({...v2(), 'domains': ['sp.example.jp']}));
      expect(repo.all.length, 2);
      expect(repo.forUrl(Uri.parse('https://example.com/')).map((p) => p.id), ['hello-world']);
      expect(repo.forUrl(Uri.parse('https://sp.example.jp/manage/x')).map((p) => p.id), ['example-site']);
      expect(repo.forUrl(Uri.parse('https://sp.example.jp/other')), isEmpty, reason: 'paths');
      expect(repo.isPluginHost('example.com'), isTrue);
      expect(repo.isPluginHost('other.com'), isFalse);

      final code = await repo.code('hello-world');
      expect(code.mainJs, 'WSI.log(1)');
      expect(code.css, 'a{}');

      await repo.setEnabled('hello-world', false);
      expect(repo.forUrl(Uri.parse('https://example.com/')), isEmpty);
      expect(repo.isPluginHost('example.com'), isFalse);

      await db.setPluginData('hello-world', 'k', 1);
      final installedAt = repo.byId('hello-world')!.installedAt;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repo.install(pkg({...v1(), 'version': '1.1.0'}, main: 'WSI.log(2)'));
      final updated = repo.byId('hello-world')!;
      expect(updated.manifest.version, '1.1.0');
      expect(updated.enabled, isFalse, reason: 'enabled state survives overwrite');
      expect(updated.installedAt, installedAt);
      expect(await db.getPluginData('hello-world', 'k'), 1, reason: 'plugin_data survives overwrite');
      expect((await repo.code('hello-world')).mainJs, 'WSI.log(2)', reason: 'code cache invalidated');

      await repo.delete('hello-world');
      expect(repo.byId('hello-world'), isNull);
      expect(await db.getPluginData('hello-world', 'k'), isNull);
      expect(await repo.filePaths('hello-world'), isEmpty);
    });

    test('global switch hides every plugin', () async {
      await repo.install(pkg(v1()));
      final settings = HostSettings(db);
      await settings.load();
      await settings.setWsiEnabled(false);
      final repo2 = PluginRepository(db, settings, secureStorage: const FlutterSecureStorage());
      await repo2.load();
      expect(repo2.forUrl(Uri.parse('https://example.com/')), isEmpty);
    });

    test('update bookkeeping and semver', () async {
      await repo.install(pkg(v1()));
      await repo.recordUpdateCheck('hello-world', latestVersion: '1.2.0');
      expect(repo.byId('hello-world')!.hasUpdate, isTrue);
      await repo.recordUpdateCheck('hello-world');
      expect(repo.byId('hello-world')!.hasUpdate, isFalse);
      expect(compareSemver('1.2.0', '1.10.0'), lessThan(0));
      expect(compareSemver('2.0.0', '2.0.0-beta.1'), greaterThan(0));
      expect(compareSemver('1.0.0+build', '1.0.0'), 0);
    });
  });
}

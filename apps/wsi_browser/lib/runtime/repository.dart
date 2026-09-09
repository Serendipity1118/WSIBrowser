// Installed plugins (F-02-3 .. F-02-5). In-memory index over the plugins /
// plugin_files tables; the runtime asks it which plugins apply to a URL.
import 'dart:convert';

import 'package:drift/drift.dart' show Value, BooleanExpressionOperators;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../db/database.dart';
import '../settings/host_settings.dart';
import 'domain_matcher.dart';
import 'importer.dart';
import 'manifest.dart';

class InstalledPlugin {
  InstalledPlugin({
    required this.manifest,
    required this.enabled,
    required this.installedAt,
    required this.updatedAt,
    this.latestVersion,
    this.latestCheckedAt,
  });

  final PluginManifest manifest;
  final bool enabled;
  final DateTime installedAt;
  final DateTime updatedAt;
  final String? latestVersion;
  final DateTime? latestCheckedAt;

  String get id => manifest.id;
  bool get hasUpdate => latestVersion != null && compareSemver(latestVersion!, manifest.version) > 0;

  InstalledPlugin copyWith({bool? enabled, String? latestVersion, DateTime? latestCheckedAt, bool clearLatest = false}) {
    return InstalledPlugin(
      manifest: manifest,
      enabled: enabled ?? this.enabled,
      installedAt: installedAt,
      updatedAt: updatedAt,
      latestVersion: clearLatest ? null : (latestVersion ?? this.latestVersion),
      latestCheckedAt: clearLatest ? null : (latestCheckedAt ?? this.latestCheckedAt),
    );
  }
}

/// Loaded code of a plugin, cached per id.
class PluginCode {
  const PluginCode({required this.mainJs, required this.css, this.workerJs});
  final String mainJs;
  final String css;
  final String? workerJs;
}

/// Compare "x.y.z[-pre]" strings. Returns <0, 0, >0.
int compareSemver(String a, String b) {
  List<int> core(String v) => v.split('+').first.split('-').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final ca = core(a);
  final cb = core(b);
  for (var i = 0; i < 3; i++) {
    final x = i < ca.length ? ca[i] : 0;
    final y = i < cb.length ? cb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  final pa = a.split('+').first.contains('-');
  final pb = b.split('+').first.contains('-');
  if (pa && !pb) return -1;
  if (!pa && pb) return 1;
  return 0;
}

class PluginRepository extends ChangeNotifier {
  PluginRepository(this._db, this._settings, {FlutterSecureStorage? secureStorage})
      : _secure = secureStorage ?? const FlutterSecureStorage();

  final AppDatabase _db;
  final HostSettings _settings;
  final FlutterSecureStorage _secure;

  final Map<String, InstalledPlugin> _plugins = {};
  final Map<String, PluginCode> _code = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<InstalledPlugin> get all => _plugins.values.toList()..sort((a, b) => a.manifest.name.compareTo(b.manifest.name));
  InstalledPlugin? byId(String id) => _plugins[id];

  Future<void> load() async {
    _plugins.clear();
    _code.clear();
    for (final row in await _db.allPlugins()) {
      try {
        final manifest = PluginManifest.parse((row.manifest as Map).cast<String, Object?>());
        _plugins[row.id] = InstalledPlugin(
          manifest: manifest,
          enabled: row.enabled,
          installedAt: row.installedAt,
          updatedAt: row.updatedAt,
          latestVersion: row.latestVersion,
          latestCheckedAt: row.latestCheckedAt,
        );
      } catch (e) {
        debugPrint('plugin ${row.id}: stored manifest is invalid, skipping ($e)');
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Enabled plugins whose domains / paths match [url] (respects the global switch).
  List<InstalledPlugin> forUrl(Uri url) {
    if (!_settings.wsiEnabled) return const [];
    return _plugins.values
        .where((p) => p.enabled && matchesUrl(url, p.manifest.domains, p.manifest.paths))
        .toList();
  }

  /// Plugins declared for [host] regardless of enabled state (list highlight).
  List<InstalledPlugin> forHost(String host) =>
      _plugins.values.where((p) => matchesDomain(host, p.manifest.domains)).toList();

  bool isPluginHost(String host) => _plugins.values.any((p) => p.enabled && matchesDomain(host, p.manifest.domains));

  Future<PluginCode> code(String id) async {
    final cached = _code[id];
    if (cached != null) return cached;
    final p = _plugins[id];
    if (p == null) throw StateError('plugin $id is not installed');
    final main = await readText(id, p.manifest.main) ?? '';
    final css = [for (final s in p.manifest.styles) await readText(id, s) ?? ''].join('\n');
    final worker = p.manifest.background == null ? null : await readText(id, p.manifest.background!);
    final c = PluginCode(mainJs: main, css: css, workerJs: worker);
    _code[id] = c;
    return c;
  }

  Future<Uint8List?> readFile(String id, String path) async {
    final row = await (_db.select(_db.pluginFiles)
          ..where((t) => t.pluginId.equals(id) & t.path.equals(path)))
        .getSingleOrNull();
    return row?.content;
  }

  Future<String?> readText(String id, String path) async {
    final bytes = await readFile(id, path);
    return bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
  }

  Future<List<String>> filePaths(String id) async {
    final rows = await (_db.select(_db.pluginFiles)..where((t) => t.pluginId.equals(id))).get();
    return rows.map((r) => r.path).toList();
  }

  /// Install or overwrite. plugin_data / plugin_settings / button positions
  /// survive an overwrite (F-02-2); installedAt is kept.
  Future<InstalledPlugin> install(ImportPackage pkg) async {
    final id = pkg.manifest.id;
    final existing = _plugins[id];
    final now = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.plugins).insertOnConflictUpdate(PluginsCompanion(
        id: Value(id),
        name: Value(pkg.manifest.name),
        version: Value(pkg.manifest.version),
        manifest: Value(pkg.manifest.raw),
        enabled: Value(existing?.enabled ?? true),
        installedAt: Value(existing?.installedAt ?? now),
        updatedAt: Value(now),
        latestVersion: const Value(null),
        latestCheckedAt: const Value(null),
      ));
      await (_db.delete(_db.pluginFiles)..where((t) => t.pluginId.equals(id))).go();
      for (final e in pkg.files.entries) {
        await _db.into(_db.pluginFiles).insert(PluginFilesCompanion.insert(
          pluginId: id,
          path: e.key,
          content: e.value,
          mime: Value(mimeForPath(e.key)),
        ));
      }
    });
    final installed = InstalledPlugin(
      manifest: pkg.manifest,
      enabled: existing?.enabled ?? true,
      installedAt: existing?.installedAt ?? now,
      updatedAt: now,
    );
    _plugins[id] = installed;
    _code.remove(id);
    notifyListeners();
    return installed;
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final p = _plugins[id];
    if (p == null) return;
    await _db.setPluginEnabled(id, enabled);
    _plugins[id] = p.copyWith(enabled: enabled);
    notifyListeners();
  }

  /// Delete everything about the plugin (F-02-5): rows cascade from plugins,
  /// credentials live in secure storage under `credentials/<id>/`.
  Future<void> delete(String id) async {
    await _db.deletePlugin(id);
    _plugins.remove(id);
    _code.remove(id);
    try {
      final all = await _secure.readAll();
      for (final k in all.keys.where((k) => k.startsWith('credentials/$id/')).toList()) {
        await _secure.delete(key: k);
      }
    } catch (e) {
      debugPrint('secure storage cleanup failed for $id: $e');
    }
    notifyListeners();
  }

  Future<void> recordUpdateCheck(String id, {String? latestVersion}) async {
    final p = _plugins[id];
    if (p == null) return;
    final now = DateTime.now();
    await (_db.update(_db.plugins)..where((t) => t.id.equals(id)))
        .write(PluginsCompanion(latestVersion: Value(latestVersion), latestCheckedAt: Value(now)));
    _plugins[id] = p.copyWith(latestVersion: latestVersion, latestCheckedAt: now, clearLatest: latestVersion == null);
    notifyListeners();
  }

  /// Rebuild the ZIP of an installed plugin (F-02-7 export).
  Future<Map<String, Uint8List>> exportFiles(String id) async {
    final rows = await (_db.select(_db.pluginFiles)..where((t) => t.pluginId.equals(id))).get();
    return {for (final r in rows) r.path: r.content};
  }
}

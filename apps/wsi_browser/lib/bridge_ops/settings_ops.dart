// WSI.settings (P2-14): values of plugin.json settingsSchema, stored in
// plugin_settings, defaults from the schema. Changes are broadcast to every
// live instance of the plugin as 'settings.change'.
import 'package:drift/drift.dart' show Value, BooleanExpressionOperators;

import '../db/database.dart';
import '../runtime/bridge.dart';
import '../runtime/manifest.dart';
import 'registry.dart';

class PluginSettingsStore {
  PluginSettingsStore(this._db);
  final AppDatabase _db;

  Future<Map<String, Object?>> getAll(PluginManifest manifest) async {
    final rows = await (_db.select(_db.pluginSettings)..where((t) => t.pluginId.equals(manifest.id))).get();
    final stored = {for (final r in rows) r.key: r.value};
    return {
      for (final s in manifest.settingsSchema) s.key: stored.containsKey(s.key) ? stored[s.key] : s.defaultValue,
      // values without a schema entry are kept too (plugins may store ad-hoc keys)
      for (final e in stored.entries)
        if (!manifest.settingsSchema.any((s) => s.key == e.key)) e.key: e.value,
    };
  }

  Future<Object?> get(PluginManifest manifest, String key) async {
    final row = await (_db.select(_db.pluginSettings)
          ..where((t) => t.pluginId.equals(manifest.id) & t.key.equals(key)))
        .getSingleOrNull();
    if (row != null) return row.value;
    for (final s in manifest.settingsSchema) {
      if (s.key == key) return s.defaultValue;
    }
    return null;
  }

  /// Validates against the schema type when the key is declared.
  Future<void> set(PluginManifest manifest, String key, Object? value) async {
    for (final s in manifest.settingsSchema) {
      if (s.key != key) continue;
      final ok = switch (s.type) {
        'number' => value is num,
        'boolean' => value is bool,
        'select' => s.options == null || s.options!.contains(value),
        _ => value is String,
      };
      if (!ok && value != null) throw OpError('settings.set: "$key" must be a ${s.type}');
    }
    await _db.into(_db.pluginSettings).insertOnConflictUpdate(
      PluginSettingsCompanion(pluginId: Value(manifest.id), key: Value(key), value: Value(value)),
    );
  }
}

void registerSettingsOps(OpRegistry registry, PluginSettingsStore store, Bridge bridge) {
  registry.register('settings.get', (call) async {
    return store.get(call.plugin.manifest, call.requireString('key'));
  });

  registry.register('settings.getAll', (call) async {
    return store.getAll(call.plugin.manifest);
  });

  registry.register('settings.set', (call) async {
    final key = call.requireString('key');
    final value = call.payload['value'];
    await store.set(call.plugin.manifest, key, value);
    // notify every instance of this plugin, including the caller
    await bridge.broadcast(call.pluginId, 'settings.change', {'key': key, 'value': value});
    return true;
  });
}

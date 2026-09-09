// drift schema for WSI Browser (要件定義「データ設計」). Migration v1.
//
// Every table exists from v1 so later phases (P2 plugins, P4 workers, PB
// policy) only add queries, not schema changes. Credentials are NOT stored
// here (flutter_secure_storage, see F-09).
import 'dart:convert';

import 'package:drift/drift.dart';

part 'database.g.dart';

/// JSON-encoded column helper: stores any json-encodable value as TEXT.
class JsonConverter extends TypeConverter<Object?, String> {
  const JsonConverter();

  @override
  Object? fromSql(String fromDb) => fromDb.isEmpty ? null : jsonDecode(fromDb);

  @override
  String toSql(Object? value) => jsonEncode(value);
}

/// Installed plugins and their update state.
class Plugins extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get version => text()();

  /// The full plugin.json.
  TextColumn get manifest => text().map(const JsonConverter())();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get installedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get latestVersion => text().nullable()();
  DateTimeColumn get latestCheckedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Files extracted from the plugin ZIP (main.js, CSS, pages, assets).
class PluginFiles extends Table {
  TextColumn get pluginId => text().references(Plugins, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text()();
  BlobColumn get content => blob()();
  TextColumn get mime => text().withDefault(const Constant('application/octet-stream'))();

  @override
  Set<Column> get primaryKey => {pluginId, path};
}

/// WSI.storage
class PluginData extends Table {
  TextColumn get pluginId => text().references(Plugins, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get value => text().map(const JsonConverter())();

  @override
  Set<Column> get primaryKey => {pluginId, key};
}

/// WSI.settings (values of plugin.json settingsSchema)
class PluginSettings extends Table {
  TextColumn get pluginId => text().references(Plugins, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get value => text().map(const JsonConverter())();

  @override
  Set<Column> get primaryKey => {pluginId, key};
}

/// WSI.policy cache
class PolicyCache extends Table {
  TextColumn get pluginId => text().references(Plugins, #id, onDelete: KeyAction.cascade)();
  TextColumn get values => text().map(const JsonConverter())();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {pluginId};
}

/// Dragged positions of WSI.addButton buttons.
class ButtonPositions extends Table {
  TextColumn get pluginId => text().references(Plugins, #id, onDelete: KeyAction.cascade)();
  IntColumn get buttonIndex => integer()();
  TextColumn get left => text()();
  TextColumn get top => text()();

  @override
  Set<Column> get primaryKey => {pluginId, buttonIndex};
}

/// Worker supervision (P4).
class WorkerState extends Table {
  TextColumn get pluginId => text().references(Plugins, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get lastStartedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get restartCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get suspendedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {pluginId};
}

/// Host settings and the global toggle (key/value, JSON values).
@DataClassName('HostSettingRow')
class HostSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().map(const JsonConverter())();

  @override
  Set<Column> get primaryKey => {key};
}

/// Log screen (WSI.log, bridge errors, injection results).
class Logs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pluginId => text().nullable()();
  TextColumn get level => text().withDefault(const Constant('log'))();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [
  Plugins,
  PluginFiles,
  PluginData,
  PluginSettings,
  PolicyCache,
  ButtonPositions,
  WorkerState,
  HostSettingsTable,
  Logs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ---- host settings -------------------------------------------------------

  Future<Object?> getSetting(String key) async {
    final row = await (select(hostSettingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, Object?>> getAllSettings() async {
    final rows = await select(hostSettingsTable).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> setSetting(String key, Object? value) {
    return into(hostSettingsTable).insertOnConflictUpdate(HostSettingsTableCompanion.insert(key: key, value: value));
  }

  Future<void> removeSetting(String key) {
    return (delete(hostSettingsTable)..where((t) => t.key.equals(key))).go();
  }

  // ---- plugin data (WSI.storage) ------------------------------------------

  Future<Object?> getPluginData(String pluginId, String key) async {
    final row = await (select(pluginData)
          ..where((t) => t.pluginId.equals(pluginId) & t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, Object?>> getAllPluginData(String pluginId) async {
    final rows = await (select(pluginData)..where((t) => t.pluginId.equals(pluginId))).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> setPluginData(String pluginId, String key, Object? value) {
    return into(pluginData).insertOnConflictUpdate(
      PluginDataCompanion.insert(pluginId: pluginId, key: key, value: value),
    );
  }

  Future<void> removePluginData(String pluginId, String key) {
    return (delete(pluginData)..where((t) => t.pluginId.equals(pluginId) & t.key.equals(key))).go();
  }

  // ---- button positions ----------------------------------------------------

  Future<ButtonPosition?> getButtonPosition(String pluginId, int index) {
    return (select(buttonPositions)
          ..where((t) => t.pluginId.equals(pluginId) & t.buttonIndex.equals(index)))
        .getSingleOrNull();
  }

  Future<void> setButtonPosition(String pluginId, int index, String left, String top) {
    return into(buttonPositions).insertOnConflictUpdate(
      ButtonPositionsCompanion.insert(pluginId: pluginId, buttonIndex: index, left: left, top: top),
    );
  }

  // ---- logs ----------------------------------------------------------------

  Future<int> addLog({String? pluginId, String level = 'log', required String message}) {
    return into(logs).insert(LogsCompanion.insert(
      pluginId: Value(pluginId),
      level: Value(level),
      message: message,
      createdAt: DateTime.now(),
    ));
  }

  /// Keep only the newest [keep] rows.
  Future<int> trimLogs(int keep) async {
    return customUpdate(
      'DELETE FROM logs WHERE id NOT IN (SELECT id FROM logs ORDER BY id DESC LIMIT ?)',
      variables: [Variable.withInt(keep)],
      updates: {logs},
    );
  }

  Future<List<Log>> recentLogs({int limit = 200}) {
    return (select(logs)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(limit))
        .get();
  }

  // ---- plugins (P2 fills these in; the basics are here for tests) --------

  Future<List<Plugin>> allPlugins() => select(plugins).get();

  Future<Plugin?> pluginById(String id) =>
      (select(plugins)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> setPluginEnabled(String id, bool enabled) {
    return (update(plugins)..where((t) => t.id.equals(id)))
        .write(PluginsCompanion(enabled: Value(enabled), updatedAt: Value(DateTime.now())));
  }

  Future<int> deletePlugin(String id) => (delete(plugins)..where((t) => t.id.equals(id))).go();
}

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('migration v1 creates every table of the data design', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'plugins',
        'plugin_files',
        'plugin_data',
        'plugin_settings',
        'policy_cache',
        'button_positions',
        'worker_state',
        'host_settings_table',
        'logs',
      ]),
    );
  });

  test('host settings CRUD keeps JSON types', () async {
    expect(await db.getSetting('tabLimit'), isNull);
    await db.setSetting('tabLimit', 7);
    await db.setSetting('initialUrl', 'https://example.com');
    await db.setSetting('developerMode', true);
    await db.setSetting('nested', {
      'a': [1, 2]
    });
    expect(await db.getSetting('tabLimit'), 7);
    expect(await db.getSetting('developerMode'), true);
    expect(await db.getSetting('nested'), {
      'a': [1, 2]
    });
    await db.setSetting('tabLimit', 3); // upsert
    expect((await db.getAllSettings())['tabLimit'], 3);
    await db.removeSetting('tabLimit');
    expect(await db.getSetting('tabLimit'), isNull);
  });

  Future<void> insertPlugin(String id) => db.into(db.plugins).insert(PluginsCompanion.insert(
        id: id,
        name: id,
        version: '1.0.0',
        manifest: {'id': id},
        installedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

  test('plugin data is namespaced and cascades on plugin delete', () async {
    await insertPlugin('a');
    await insertPlugin('b');
    await db.setPluginData('a', 'k', {'v': 1});
    await db.setPluginData('b', 'k', 'other');
    expect(await db.getPluginData('a', 'k'), {'v': 1});
    expect(await db.getPluginData('b', 'k'), 'other');
    expect(await db.getAllPluginData('a'), {
      'k': {'v': 1}
    });
    await db.removePluginData('a', 'k');
    expect(await db.getPluginData('a', 'k'), isNull);

    await db.setButtonPosition('b', 0, '10px', '20px');
    expect((await db.getButtonPosition('b', 0))!.left, '10px');
    await db.deletePlugin('b');
    expect(await db.getPluginData('b', 'k'), isNull);
    expect(await db.getButtonPosition('b', 0), isNull);
  });

  test('plugin files use a composite key and plugins can be toggled', () async {
    await insertPlugin('p');
    await db.into(db.pluginFiles).insert(PluginFilesCompanion.insert(
        pluginId: 'p', path: 'main.js', content: Uint8List.fromList([1, 2]), mime: const Value('text/javascript')));
    await db
        .into(db.pluginFiles)
        .insert(PluginFilesCompanion.insert(pluginId: 'p', path: 'style.css', content: Uint8List.fromList([3])));
    expect(
      () => db.into(db.pluginFiles).insert(PluginFilesCompanion.insert(pluginId: 'p', path: 'main.js', content: Uint8List(0))),
      throwsA(isA<SqliteException>()),
    );
    await db.setPluginEnabled('p', false);
    expect((await db.pluginById('p'))!.enabled, isFalse);
    expect((await db.allPlugins()).length, 1);
  });

  test('logs are trimmed to the retention count', () async {
    for (var i = 0; i < 30; i++) {
      await db.addLog(pluginId: 'x', message: 'm$i');
    }
    await db.trimLogs(10);
    final recent = await db.recentLogs();
    expect(recent.length, 10);
    expect(recent.first.message, 'm29');
    expect(recent.last.message, 'm20');
  });
}

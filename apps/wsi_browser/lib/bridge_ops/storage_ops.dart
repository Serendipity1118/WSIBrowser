// WSI.storage and button positions (P2-07). Namespaced by pluginId; the id
// comes from the token, never from the payload.
import '../db/database.dart';
import 'registry.dart';

void registerStorageOps(OpRegistry registry, AppDatabase db) {
  registry.register('storage.get', (call) async {
    return db.getPluginData(call.pluginId, call.requireString('key'));
  });

  registry.register('storage.set', (call) async {
    await db.setPluginData(call.pluginId, call.requireString('key'), call.payload['value']);
    return true;
  });

  registry.register('storage.remove', (call) async {
    await db.removePluginData(call.pluginId, call.requireString('key'));
    return true;
  });

  registry.register('storage.getAll', (call) async {
    return db.getAllPluginData(call.pluginId);
  });

  registry.register('buttonPos.get', (call) async {
    final index = call.payload['index'];
    if (index is! num) throw OpError('buttonPos.get: "index" must be a number');
    final row = await db.getButtonPosition(call.pluginId, index.toInt());
    return row == null ? null : {'left': row.left, 'top': row.top};
  });

  registry.register('buttonPos.set', (call) async {
    final index = call.payload['index'];
    final pos = call.payload['position'];
    if (index is! num || pos is! Map) throw OpError('buttonPos.set: "index" and "position" are required');
    await db.setButtonPosition(call.pluginId, index.toInt(), '${pos['left'] ?? '0px'}', '${pos['top'] ?? '0px'}');
    return true;
  });
}

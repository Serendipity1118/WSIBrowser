// WSI.menu.register / update (F-08). Requires the 'menu' permission.
import '../runtime/menu_bus.dart';
import 'registry.dart';

void registerMenuOps(OpRegistry registry, MenuBus menuBus) {
  registry.register('menu.register', permission: 'menu', (call) async {
    final raw = call.payload['items'];
    if (raw is! List) throw OpError('menu.register: "items" must be an array');
    final items = <MenuEntry>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final type = '${item['type'] ?? 'action'}';
      if (type == 'separator') {
        items.add(MenuEntry(id: 'sep-${items.length}', type: 'separator', label: ''));
        continue;
      }
      final id = item['id'];
      if (id is! String || id.isEmpty) throw OpError('menu.register: every item needs an "id"');
      items.add(MenuEntry(
        id: id,
        type: type,
        label: '${item['label'] ?? id}',
        icon: item['icon'] as String?,
        page: item['page'] as String?,
        checked: item['checked'] as bool?,
      ));
    }
    menuBus.register(call.session, items);
    return {'ok': true, 'count': items.length};
  });

  registry.register('menu.update', permission: 'menu', (call) async {
    final id = call.requireString('id');
    final ok = menuBus.update(call.pluginId, id, label: call.arg<String>('label'), checked: call.arg<bool>('checked'));
    if (!ok) throw OpError('menu.update: unknown item "$id"');
    return true;
  });
}

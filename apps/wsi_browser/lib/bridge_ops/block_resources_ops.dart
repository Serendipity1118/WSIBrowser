// WSI.blockResources({ images, media, urls }) (F-09, P5-09).
import '../runtime/resource_blocker.dart';
import 'registry.dart';

void registerBlockResourcesOps(OpRegistry registry, ResourceBlocker blocker) {
  registry.register('blockResources', permission: 'blockResources', (call) async {
    final rules = BlockRules.fromPayload(call.payload);
    blocker.set(call.pluginId, rules);
    return rules.toJson();
  });
}

// WSI.policy.get / getAll / refresh (F-04-4). Requires the 'policy' permission
// and a policy block in plugin.json.
import '../runtime/policy_cache.dart';
import 'registry.dart';

void registerPolicyOps(OpRegistry registry, PolicyStore cache) {
  registry.register('policy.get', permission: 'policy', (call) async {
    if (call.plugin.manifest.policy == null) throw OpError('plugin.json has no policy block');
    return cache.get(call.plugin.manifest, call.requireString('key'));
  });

  registry.register('policy.getAll', permission: 'policy', (call) async {
    if (call.plugin.manifest.policy == null) throw OpError('plugin.json has no policy block');
    return cache.values(call.plugin.manifest);
  });

  registry.register('policy.refresh', permission: 'policy', (call) async {
    if (call.plugin.manifest.policy == null) throw OpError('plugin.json has no policy block');
    return cache.values(call.plugin.manifest, force: true);
  });
}

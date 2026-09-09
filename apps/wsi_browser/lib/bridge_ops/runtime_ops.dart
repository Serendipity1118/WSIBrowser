// WSI.runtime.sendMessage (F-05-3, P3-05): deliver to every other live
// instance of the same plugin (site pages, plugin pages, worker) and return
// the first reply. Suspend / resume events are emitted by the worker manager (P4).
import '../runtime/bridge.dart';
import 'registry.dart';

void registerRuntimeOps(OpRegistry registry, Bridge bridge) {
  registry.register('runtime.sendMessage', (call) async {
    final message = call.payload['message'];
    final sender = {'context': bridgeContextToString(call.session.context), 'origin': call.session.origin?.toString()};
    Object? reply;
    var delivered = 0;
    for (final s in bridge.sessionsForPlugin(call.pluginId).toList()) {
      if (identical(s, call.session)) continue;
      final r = await bridge.emit(s, 'runtime.message', message, sender: sender);
      delivered++;
      reply ??= r;
    }
    return {'delivered': delivered, 'reply': reply};
  });
}

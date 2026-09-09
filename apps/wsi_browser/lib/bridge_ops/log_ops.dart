// WSI.log -> log screen (P2-09).
import '../runtime/log_sink.dart';
import 'registry.dart';

void registerLogOps(OpRegistry registry, LogSink logs) {
  registry.register('log', (call) async {
    final level = call.arg<String>('level') ?? 'log';
    final message = '${call.payload['message'] ?? ''}';
    logs.add(pluginId: call.pluginId, level: level == 'error' ? 'error' : 'log', message: message);
    return true;
  });
}

// Host -> plugin change events for sessions that asked for them
// (WSI.network.onChange, WSI.battery.onChange). The native stream is only
// listened to while at least one live session is subscribed.
import 'dart:async';
import 'dart:convert';

import 'registry.dart';

typedef SessionEmit = Future<Object?> Function(BridgeSession session, String event, Object? payload);

class SessionFanout {
  SessionFanout({required this.event, required this.source, required this.emit});

  final String event;

  /// Payloads to deliver (already converted to JSON-friendly values).
  final Stream<Object?> Function() source;
  final SessionEmit emit;

  final Map<String, BridgeSession> _sessions = {};
  StreamSubscription<Object?>? _sub;
  String? _last;

  int get count => _sessions.values.where((s) => !s.revoked).length;
  bool get listening => _sub != null;

  void add(BridgeSession session) {
    _sessions[session.token] = session;
    _sub ??= source().listen(deliver);
  }

  void remove(BridgeSession session) {
    _sessions.remove(session.token);
    _stopIfIdle();
  }

  /// Send [payload] to every live subscriber; repeated identical payloads are dropped.
  Future<void> deliver(Object? payload) async {
    final encoded = jsonEncode(payload);
    if (encoded == _last) return;
    _last = encoded;
    _sessions.removeWhere((_, s) => s.revoked);
    for (final s in _sessions.values.toList()) {
      await emit(s, event, payload);
    }
    _stopIfIdle();
  }

  void _stopIfIdle() {
    _sessions.removeWhere((_, s) => s.revoked);
    if (_sessions.isNotEmpty) return;
    unawaited(_sub?.cancel());
    _sub = null;
    _last = null;
  }
}

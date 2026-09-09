// Log collection (F-04-5, F-11): WSI.log, bridge errors, injection results.
// Writes to the logs table (trimmed to the retention setting) and keeps a
// small in-memory tail for the log screen.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../db/database.dart';
import '../settings/host_settings.dart';

class LogEntry {
  LogEntry({required this.pluginId, required this.level, required this.message, required this.createdAt});
  final String? pluginId;
  final String level;
  final String message;
  final DateTime createdAt;

  @override
  String toString() => '${createdAt.toIso8601String()} [$level]${pluginId == null ? '' : ' [$pluginId]'} $message';
}

class LogSink extends ChangeNotifier {
  LogSink(this._db, this._settings);

  final AppDatabase _db;
  final HostSettings _settings;
  final List<LogEntry> _tail = [];
  int _sinceTrim = 0;

  static const int tailSize = 500;

  List<LogEntry> get tail => List.unmodifiable(_tail);

  void add({String? pluginId, String level = 'log', required String message}) {
    final entry = LogEntry(pluginId: pluginId, level: level, message: message, createdAt: DateTime.now());
    _tail.add(entry);
    if (_tail.length > tailSize) _tail.removeAt(0);
    debugPrint('[WSI${pluginId == null ? '' : ':$pluginId'}] $level: $message');
    unawaited(_persist(entry));
    notifyListeners();
  }

  Future<void> _persist(LogEntry e) async {
    try {
      await _db.addLog(pluginId: e.pluginId, level: e.level, message: e.message);
      if (++_sinceTrim >= 200) {
        _sinceTrim = 0;
        await _db.trimLogs(_settings.logRetention);
      }
    } catch (err) {
      debugPrint('log persist failed: $err');
    }
  }

  Future<List<LogEntry>> history({int limit = 500, String? pluginId}) async {
    final rows = await _db.recentLogs(limit: limit);
    return [
      for (final r in rows)
        if (pluginId == null || r.pluginId == pluginId)
          LogEntry(pluginId: r.pluginId, level: r.level, message: r.message, createdAt: r.createdAt),
    ];
  }

  Future<void> clear() async {
    _tail.clear();
    await _db.delete(_db.logs).go();
    notifyListeners();
  }
}

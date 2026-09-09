// WSI.policy (F-04-4, PB-08). Fetches plugin.json policy.url at startup and
// whenever the cached values are older than policy.ttlSeconds; on failure
// falls back to the last cached values, then to policy.defaults.
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../db/database.dart';
import 'log_sink.dart';
import 'manifest.dart';
import 'repository.dart';

class PolicyStore {
  PolicyStore(this._db, this._repository, this._logs, {Dio? dio}) : _dio = dio ?? Dio();

  final AppDatabase _db;
  final PluginRepository _repository;
  final LogSink _logs;
  final Dio _dio;

  /// In-memory copy: pluginId -> (values, fetchedAt)
  final Map<String, ({Map<String, Object?> values, DateTime fetchedAt})> _memory = {};
  final Map<String, Future<Map<String, Object?>?>> _inflight = {};

  /// Refresh every plugin that declares a policy (startup).
  Future<void> refreshAll({bool force = false}) async {
    for (final p in _repository.all) {
      if (p.manifest.policy == null) continue;
      await values(p.manifest, force: force);
    }
  }

  /// Effective values: fresh cache, else network, else stale cache, else defaults.
  Future<Map<String, Object?>> values(PluginManifest manifest, {bool force = false}) async {
    final policy = manifest.policy;
    if (policy == null) return const {};
    final cached = await _cached(manifest.id);
    final ttl = Duration(seconds: policy.ttlSeconds);
    if (!force && cached != null && DateTime.now().difference(cached.fetchedAt) < ttl) {
      return _merge(policy.defaults, cached.values);
    }
    final fetched = await _fetch(manifest, policy);
    if (fetched != null) return _merge(policy.defaults, fetched);
    if (cached != null) return _merge(policy.defaults, cached.values);
    return Map.of(policy.defaults);
  }

  Future<Object?> get(PluginManifest manifest, String key) async => (await values(manifest))[key];

  Future<({Map<String, Object?> values, DateTime fetchedAt})?> _cached(String pluginId) async {
    final mem = _memory[pluginId];
    if (mem != null) return mem;
    final row = await (_db.select(_db.policyCache)..where((t) => t.pluginId.equals(pluginId))).getSingleOrNull();
    if (row == null) return null;
    final v = row.values;
    final entry = (values: v is Map ? v.cast<String, Object?>() : <String, Object?>{}, fetchedAt: row.fetchedAt);
    _memory[pluginId] = entry;
    return entry;
  }

  Future<Map<String, Object?>?> _fetch(PluginManifest manifest, PluginPolicy policy) {
    return _inflight.putIfAbsent(manifest.id, () async {
      try {
        final res = await _dio.get<Map<String, dynamic>>(
          policy.url,
          options: Options(responseType: ResponseType.json, receiveTimeout: const Duration(seconds: 15)),
        );
        final data = res.data;
        final raw = data?['values'];
        final values = raw is Map ? raw.cast<String, Object?>() : <String, Object?>{};
        final now = DateTime.now();
        await _db.into(_db.policyCache).insertOnConflictUpdate(
          PolicyCacheCompanion(pluginId: Value(manifest.id), values: Value(values), fetchedAt: Value(now)),
        );
        _memory[manifest.id] = (values: values, fetchedAt: now);
        _logs.add(pluginId: manifest.id, level: 'info', message: 'policy refreshed (${values.length} keys)');
        return values;
      } catch (e) {
        debugPrint('policy fetch failed for ${manifest.id}: $e');
        _logs.add(pluginId: manifest.id, level: 'warn', message: 'policy fetch failed: $e');
        return null;
      } finally {
        _inflight.remove(manifest.id);
      }
    });
  }

  static Map<String, Object?> _merge(Map<String, Object?> defaults, Map<String, Object?> values) => {...defaults, ...values};
}

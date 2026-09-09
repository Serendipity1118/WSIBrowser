// Update check (F-02-6, P2-13). GET updateUrl -> { version, zipUrl, notes }.
// Only records that a newer version exists; the user applies it from the
// plugin list (overwrite import through the normal path). Never automatic.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../settings/host_settings.dart';
import 'repository.dart';

class UpdateInfo {
  const UpdateInfo({required this.version, required this.zipUrl, this.notes});
  final String version;
  final String zipUrl;
  final String? notes;
}

class UpdateChecker {
  UpdateChecker(this._repository, this._settings, {Dio? dio}) : _dio = dio ?? Dio();

  final PluginRepository _repository;
  final HostSettings _settings;
  final Dio _dio;

  static const Duration interval = Duration(hours: 24);

  /// Latest known update per plugin id (in memory; the version is also in the DB).
  final Map<String, UpdateInfo> available = {};

  Future<void> checkAll({bool force = false}) async {
    if (!_settings.updateCheck && !force) return;
    final now = DateTime.now();
    for (final p in _repository.all) {
      final url = p.manifest.updateUrl;
      if (url == null) continue;
      final last = p.latestCheckedAt;
      if (!force && last != null && now.difference(last) < interval) continue;
      await check(p.id);
    }
  }

  Future<UpdateInfo?> check(String id) async {
    final p = _repository.byId(id);
    final url = p?.manifest.updateUrl;
    if (p == null || url == null) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(responseType: ResponseType.json, receiveTimeout: const Duration(seconds: 20)),
      );
      final data = res.data;
      final version = data?['version'];
      final zipUrl = data?['zipUrl'];
      if (version is! String || zipUrl is! String) {
        await _repository.recordUpdateCheck(id);
        return null;
      }
      final newer = compareSemver(version, p.manifest.version) > 0;
      if (newer) {
        available[id] = UpdateInfo(version: version, zipUrl: zipUrl, notes: data?['notes'] as String?);
        await _repository.recordUpdateCheck(id, latestVersion: version);
        return available[id];
      }
      available.remove(id);
      await _repository.recordUpdateCheck(id);
      return null;
    } catch (e) {
      debugPrint('update check failed for $id: $e');
      return null;
    }
  }

  void clear(String id) => available.remove(id);
}

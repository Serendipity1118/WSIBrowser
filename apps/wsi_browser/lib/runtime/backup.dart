// Encrypted backup of plugin data and plugin settings (F-02-7, P5-10).
//
// File format (JSON):
//   { "format": "wsi-backup-1", "kdf": {"name": "pbkdf2-hmac-sha256", "iterations": N, "salt": b64},
//     "cipher": "aes-256-gcm", "nonce": b64, "ciphertext": b64, "mac": b64 }
// Plaintext (JSON): { "version": 1, "createdAt": iso, "plugins": { id: { "version", "data": {}, "settings": {} } } }
// Credentials (secure storage) are never included.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;

import '../db/database.dart';
import 'repository.dart';

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

class BackupService {
  BackupService(this._db, this._repository, {int iterations = 150000}) : _iterations = iterations;

  final AppDatabase _db;
  final PluginRepository _repository;
  final int _iterations;

  static const format = 'wsi-backup-1';

  Future<Map<String, Object?>> collect() async {
    final plugins = <String, Object?>{};
    for (final p in _repository.all) {
      final settingsRows = await (_db.select(_db.pluginSettings)..where((t) => t.pluginId.equals(p.id))).get();
      plugins[p.id] = {
        'version': p.manifest.version,
        'name': p.manifest.name,
        'data': await _db.getAllPluginData(p.id),
        'settings': {for (final r in settingsRows) r.key: r.value},
      };
    }
    return {'version': 1, 'createdAt': DateTime.now().toUtc().toIso8601String(), 'plugins': plugins};
  }

  Future<Uint8List> export(String password) async {
    if (password.length < 4) throw BackupException('password too short');
    final plain = utf8.encode(jsonEncode(await collect()));
    final salt = _random(16);
    final key = await _deriveKey(password, salt);
    final nonce = _random(12);
    final box = await AesGcm.with256bits().encrypt(plain, secretKey: key, nonce: nonce);
    final out = {
      'format': format,
      'kdf': {'name': 'pbkdf2-hmac-sha256', 'iterations': _iterations, 'salt': base64Encode(salt)},
      'cipher': 'aes-256-gcm',
      'nonce': base64Encode(nonce),
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(out)));
  }

  Future<Map<String, Object?>> decrypt(Uint8List file, String password) async {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(file));
    } catch (_) {
      throw BackupException('not a backup file');
    }
    if (json is! Map || json['format'] != format) throw BackupException('unsupported backup format');
    final kdf = json['kdf'] as Map?;
    final iterations = (kdf?['iterations'] as num?)?.toInt() ?? _iterations;
    final salt = base64Decode(kdf?['salt'] as String? ?? '');
    final key = await _deriveKey(password, salt, iterations: iterations);
    try {
      final plain = await AesGcm.with256bits().decrypt(
        SecretBox(base64Decode(json['ciphertext'] as String), nonce: base64Decode(json['nonce'] as String), mac: Mac(base64Decode(json['mac'] as String))),
        secretKey: key,
      );
      final data = jsonDecode(utf8.decode(plain));
      if (data is! Map) throw BackupException('corrupt backup');
      return data.cast<String, Object?>();
    } on SecretBoxAuthenticationError {
      throw BackupException('wrong password or corrupt file');
    }
  }

  /// Restore data + settings for plugins that are installed. Returns the ids restored.
  Future<List<String>> restore(Uint8List file, String password) async {
    final data = await decrypt(file, password);
    final plugins = (data['plugins'] as Map?)?.cast<String, Object?>() ?? const {};
    final restored = <String>[];
    await _db.transaction(() async {
      for (final e in plugins.entries) {
        if (_repository.byId(e.key) == null) continue;
        final entry = (e.value as Map?)?.cast<String, Object?>() ?? const {};
        final pd = (entry['data'] as Map?)?.cast<String, Object?>() ?? const {};
        final ps = (entry['settings'] as Map?)?.cast<String, Object?>() ?? const {};
        await (_db.delete(_db.pluginData)..where((t) => t.pluginId.equals(e.key))).go();
        for (final d in pd.entries) {
          await _db.setPluginData(e.key, d.key, d.value);
        }
        for (final s in ps.entries) {
          await _db.into(_db.pluginSettings).insertOnConflictUpdate(
            PluginSettingsCompanion(pluginId: Value(e.key), key: Value(s.key), value: Value(s.value)),
          );
        }
        restored.add(e.key);
      }
    });
    return restored;
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt, {int? iterations}) {
    final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations ?? _iterations, bits: 256);
    return pbkdf2.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  }

  static Uint8List _random(int n) {
    final r = Random.secure();
    return Uint8List.fromList(List<int>.generate(n, (_) => r.nextInt(256)));
  }
}

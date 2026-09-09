// WSI.credentials (F-09, P5-02): id / password per profile in the OS secure
// storage (Keychain / Keystore) under credentials/<pluginId>/<profile>.
// Values never reach the log.
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'registry.dart';

String credentialKey(String pluginId, String profile) => 'credentials/$pluginId/$profile';

final RegExp _profileRe = RegExp(r'^[a-zA-Z0-9_.-]{1,64}$');

void registerCredentialsOps(OpRegistry registry, {FlutterSecureStorage? storage}) {
  final secure = storage ?? const FlutterSecureStorage();

  String profileOf(BridgeCall call) {
    final p = call.arg<String>('profile') ?? 'default';
    if (!_profileRe.hasMatch(p)) throw OpError('credentials: invalid profile name');
    return p;
  }

  registry.register('credentials.set', permission: 'credentials', (call) async {
    final value = call.payload['value'];
    if (value is! Map) throw OpError('credentials.set: "value" must be an object');
    final id = value['id'];
    final password = value['password'];
    if (id is! String || password is! String) throw OpError('credentials.set: value needs "id" and "password" strings');
    await secure.write(key: credentialKey(call.pluginId, profileOf(call)), value: jsonEncode({'id': id, 'password': password}));
    return true;
  });

  registry.register('credentials.get', permission: 'credentials', (call) async {
    final raw = await secure.read(key: credentialKey(call.pluginId, profileOf(call)));
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw);
      return m is Map ? {'id': m['id'], 'password': m['password']} : null;
    } catch (_) {
      return null;
    }
  });

  registry.register('credentials.remove', permission: 'credentials', (call) async {
    await secure.delete(key: credentialKey(call.pluginId, profileOf(call)));
    return true;
  });

  registry.register('credentials.list', permission: 'credentials', (call) async {
    final all = await secure.readAll();
    final prefix = 'credentials/${call.pluginId}/';
    return [for (final k in all.keys) if (k.startsWith(prefix)) k.substring(prefix.length)];
  });
}

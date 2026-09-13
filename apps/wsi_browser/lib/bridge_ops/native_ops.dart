// Small native features (F-09, P5-03 .. P5-08):
//   device.id / device.info   android_id / identifierForVendor, OS, model
//   device.key                per-plugin device key (HMAC of a device secret)
//   share                     share sheet for text, url, files (base64 or text data)
//   files.save / files.pick   app Downloads directory + share sheet, file picker
//   clipboard.write / read
//   wakeLock.acquire/release  reference counted per plugin (released on stop)
//   pip.enter / exit / isSupported  Android Picture in Picture via MainActivity
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../runtime/importer.dart' show mimeForPath;
import 'registry.dart';

const int kMaxFileBytes = 8 * 1024 * 1024;

String _sanitize(String name) {
  final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
  return cleaned.isEmpty ? 'file' : cleaned;
}

/// Decode { data: string, encoding?: 'base64' | 'text' } into bytes.
Uint8List decodeData(Object? data, String? encoding) {
  if (data is! String) throw OpError('"data" must be a string');
  if (encoding == 'base64') return base64Decode(data);
  return Uint8List.fromList(utf8.encode(data));
}

Future<Directory> _downloadsDir() async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory('${base.path}${Platform.pathSeparator}Downloads');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

Future<File> _writeTemp(String name, Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}${_sanitize(name)}');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

// ---- device ------------------------------------------------------------------

const String kDeviceSecretKey = 'device/secret';

/// WSI.device.key(): HMAC-SHA256(secret, pluginId) as 64 hex chars. The same
/// plugin always gets the same key on one device; different plugins get
/// unrelated keys, so plugins cannot correlate a user through it.
String deviceKeyFor(String secret, String pluginId) =>
    Hmac(sha256, utf8.encode(secret)).convert(utf8.encode('wsi-browser/device-key/v1/$pluginId')).toString();

void registerDeviceOps(OpRegistry registry, {FlutterSecureStorage? storage, Future<String?> Function()? androidId}) {
  final info = DeviceInfoPlugin();
  final secure = storage ?? const FlutterSecureStorage();

  Future<String> deviceId() async {
    if (Platform.isAndroid) return (await const AndroidId().getId()) ?? '';
    if (Platform.isIOS) return (await info.iosInfo).identifierForVendor ?? '';
    return '';
  }

  // Android: android_id (survives reinstall, changes on factory reset).
  // iOS / fallback: a random secret in the Keychain, this device only
  // (usually survives reinstall, unlike identifierForVendor).
  Future<String> deviceSecret() async {
    if (androidId != null || Platform.isAndroid) {
      final id = androidId != null ? await androidId() : await const AndroidId().getId();
      if (id != null && id.isNotEmpty) return id;
    }
    const options = IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device);
    final existing = await secure.read(key: kDeviceSecretKey, iOptions: options);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final secret = base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)));
    await secure.write(key: kDeviceSecretKey, value: secret, iOptions: options);
    return secret;
  }

  registry.register('device.id', permission: 'device', (call) async => deviceId());

  registry.register('device.key', permission: 'device', (call) async => deviceKeyFor(await deviceSecret(), call.pluginId));

  registry.register('device.info', permission: 'device', (call) async {
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return {'id': await deviceId(), 'os': 'android', 'osVersion': a.version.release, 'sdkInt': a.version.sdkInt, 'model': a.model, 'manufacturer': a.manufacturer};
    }
    if (Platform.isIOS) {
      final i = await info.iosInfo;
      return {'id': await deviceId(), 'os': 'ios', 'osVersion': i.systemVersion, 'model': i.utsname.machine, 'name': i.model};
    }
    return {'id': '', 'os': Platform.operatingSystem, 'osVersion': Platform.operatingSystemVersion, 'model': ''};
  });
}

// ---- share -------------------------------------------------------------------

void registerShareOps(OpRegistry registry) {
  registry.register('share', permission: 'share', (call) async {
    final text = call.arg<String>('text');
    final url = call.arg<String>('url');
    final title = call.arg<String>('title');
    final filesRaw = call.payload['files'];
    final files = <XFile>[];
    if (filesRaw is List) {
      for (final f in filesRaw) {
        if (f is! Map) continue;
        final bytes = decodeData(f['data'], f['encoding'] as String?);
        if (bytes.length > kMaxFileBytes) throw OpError('share: file too large');
        final name = '${f['name'] ?? 'file'}';
        final file = await _writeTemp(name, bytes);
        files.add(XFile(file.path, mimeType: f['mime'] as String? ?? mimeForPath(name)));
      }
    }
    final result = await SharePlus.instance.share(ShareParams(
      text: [text, url].whereType<String>().where((s) => s.isNotEmpty).join('\n').let((s) => s.isEmpty ? null : s),
      title: title,
      files: files.isEmpty ? null : files,
    ));
    return {'status': result.status.name};
  });
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

// ---- files -------------------------------------------------------------------

void registerFilesOps(OpRegistry registry) {
  registry.register('files.save', permission: 'files', (call) async {
    final name = _sanitize(call.requireString('name'));
    final bytes = decodeData(call.payload['data'], call.arg<String>('encoding'));
    if (bytes.length > kMaxFileBytes) throw OpError('files.save: file too large (max $kMaxFileBytes bytes)');
    final dir = await _downloadsDir();
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(bytes, flush: true);
    if (call.arg<bool>('share') == true) {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: call.arg<String>('mime') ?? mimeForPath(name))]));
    }
    return {'path': file.path, 'name': name, 'size': bytes.length};
  });

  registry.register('files.pick', permission: 'files', (call) async {
    final accept = call.arg<String>('accept');
    final extensions = accept == null || accept.isEmpty
        ? null
        : accept.split(',').map((e) => e.trim().replaceFirst('.', '')).where((e) => e.isNotEmpty && !e.contains('/')).toList();
    final result = await FilePicker.pickFiles(
      type: extensions == null || extensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: extensions == null || extensions.isEmpty ? null : extensions,
    );
    final file = result.firstOrNull;
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > kMaxFileBytes) throw OpError('files.pick: file too large (max $kMaxFileBytes bytes)');
    return {'name': file.name, 'size': bytes.length, 'mime': mimeForPath(file.name), 'encoding': 'base64', 'data': base64Encode(bytes)};
  });
}

// ---- clipboard ---------------------------------------------------------------

void registerClipboardOps(OpRegistry registry) {
  registry.register('clipboard.write', permission: 'clipboard', (call) async {
    await Clipboard.setData(ClipboardData(text: call.requireString('text')));
    return true;
  });
  registry.register('clipboard.read', permission: 'clipboard', (call) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  });
}

// ---- wake lock ---------------------------------------------------------------

class WakeLockRegistry {
  final Map<String, int> _counts = {};

  Future<void> acquire(String pluginId) async {
    _counts[pluginId] = (_counts[pluginId] ?? 0) + 1;
    await WakelockPlus.enable();
  }

  Future<void> release(String pluginId) async {
    final n = (_counts[pluginId] ?? 0) - 1;
    if (n <= 0) {
      _counts.remove(pluginId);
    } else {
      _counts[pluginId] = n;
    }
    if (_counts.isEmpty) await WakelockPlus.disable();
  }

  /// Plugin stopped / disabled: drop all of its holds.
  Future<void> releaseAll(String pluginId) async {
    _counts.remove(pluginId);
    if (_counts.isEmpty) await WakelockPlus.disable();
  }

  int count(String pluginId) => _counts[pluginId] ?? 0;
  bool get held => _counts.isNotEmpty;
}

void registerWakeLockOps(OpRegistry registry, WakeLockRegistry locks) {
  registry.register('wakeLock.acquire', permission: 'wakeLock', (call) async {
    await locks.acquire(call.pluginId);
    return {'count': locks.count(call.pluginId)};
  });
  registry.register('wakeLock.release', permission: 'wakeLock', (call) async {
    await locks.release(call.pluginId);
    return {'count': locks.count(call.pluginId)};
  });
}

// ---- picture in picture ------------------------------------------------------

class PipChannel {
  static const _channel = MethodChannel('jp.serendipy.wsibrowser/pip');

  Future<bool> isSupported() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> enter({int width = 16, int height = 9}) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('enter', {'width': width, 'height': height}) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> exit() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('exit') ?? false;
    } on MissingPluginException {
      return false;
    }
  }
}

void registerPipOps(OpRegistry registry, PipChannel pip) {
  registry.register('pip.isSupported', permission: 'pip', (call) async => pip.isSupported());
  registry.register('pip.enter', permission: 'pip', (call) async {
    final w = call.payload['width'];
    final h = call.payload['height'];
    return pip.enter(width: w is num ? w.toInt() : 16, height: h is num ? h.toInt() : 9);
  });
  registry.register('pip.exit', permission: 'pip', (call) async => pip.exit());
}

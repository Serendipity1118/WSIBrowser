// Developer live reload (F-11): wsi://dev?url=https://<pc>:8443/plugin.zip[&interval=10]
// Re-downloads the ZIP every [interval] seconds, re-installs when its bytes
// changed and reloads every tab the plugin applies to. Developer mode only.
import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../browser/tab_manager.dart';
import 'importer.dart';
import 'log_sink.dart';
import 'repository.dart';

class DevReloader {
  DevReloader({required this.importer, required this.repository, required this.logs, required this.tabs});

  final ZipImporter importer;
  final PluginRepository repository;
  final LogSink logs;
  final TabManager tabs;

  Timer? _timer;
  Uri? _url;
  String? _hash;
  String? _pluginId;

  bool get isActive => _timer != null;
  Uri? get url => _url;
  String? get pluginId => _pluginId;

  Future<void> start(Uri url, {Duration interval = const Duration(seconds: 10)}) async {
    stop();
    _url = url;
    await _poll(force: true);
    _timer = Timer.periodic(interval, (_) => _poll());
    logs.add(level: 'info', message: 'dev reload started: $url every ${interval.inSeconds}s');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_url != null) logs.add(level: 'info', message: 'dev reload stopped');
    _url = null;
    _hash = null;
  }

  Future<void> _poll({bool force = false}) async {
    final url = _url;
    if (url == null) return;
    try {
      final pkg = await importer.fromUrl(url, allowInsecure: true);
      final hash = _digest(pkg.zipBytes);
      if (!force && hash == _hash) return;
      _hash = hash;
      _pluginId = pkg.manifest.id;
      await repository.install(pkg);
      logs.add(pluginId: pkg.manifest.id, level: 'info', message: 'dev reload: installed v${pkg.manifest.version}');
      for (final tab in tabs.tabs) {
        final uri = Uri.tryParse(tab.url);
        if (uri == null || tab.isStartPage) continue;
        if (repository.forUrl(uri).any((p) => p.id == pkg.manifest.id)) {
          await tab.controller?.reload();
        }
      }
    } catch (e) {
      logs.add(pluginId: _pluginId, level: 'error', message: 'dev reload failed: $e');
    }
  }

  static String _digest(Uint8List bytes) => sha256.convert(bytes).toString();
}

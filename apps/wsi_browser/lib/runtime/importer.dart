// ZIP import (F-02-1, F-02-2). Extracts the archive, validates plugin.json
// against the files that are actually inside, and produces an [ImportPackage]
// the UI previews before the repository installs it.
import 'dart:convert';
import 'dart:typed_data';

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'manifest.dart';

class ImportException implements Exception {
  ImportException(this.message, [this.details = const []]);
  final String message;
  final List<String> details;
  @override
  String toString() => details.isEmpty ? message : '$message\n  - ${details.join('\n  - ')}';
}

class ImportPackage {
  ImportPackage({required this.manifest, required this.files, required this.zipBytes, this.sourceUrl});

  final PluginManifest manifest;

  /// Every file in the ZIP, keyed by its path inside the archive (posix).
  final Map<String, Uint8List> files;
  final Uint8List zipBytes;

  /// Where the ZIP came from (URL import / update), if any.
  final String? sourceUrl;

  String get mainJs => utf8.decode(files[manifest.main]!, allowMalformed: true);

  String get css => manifest.styles
      .map((s) => files[s])
      .whereType<Uint8List>()
      .map((b) => utf8.decode(b, allowMalformed: true))
      .join('\n');

  int get totalBytes => files.values.fold(0, (n, f) => n + f.length);
}

class ZipImporter {
  ZipImporter({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Developer mode: http and self-signed https (wsi-plugin dev-serve).
  late final Dio _insecureDio = () {
    final d = Dio();
    d.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()..badCertificateCallback = (cert, host, port) => true,
    );
    return d;
  }();

  /// Upper bound for a plugin ZIP (F-02: keeps a hostile ZIP from filling the DB).
  static const int maxZipBytes = 20 * 1024 * 1024;
  static const int maxFileBytes = 8 * 1024 * 1024;

  ImportPackage open(Uint8List zipBytes, {String? sourceUrl}) {
    if (zipBytes.length > maxZipBytes) {
      throw ImportException('ZIP is too large (${zipBytes.length} bytes, max $maxZipBytes)');
    }
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes, verify: false);
    } catch (e) {
      throw ImportException('Not a valid ZIP file: $e');
    }

    final files = <String, Uint8List>{};
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final name = _normalize(entry.name);
      if (name == null) continue; // directory entries, hidden metadata, path traversal
      if (entry.size > maxFileBytes) throw ImportException('File too large in ZIP: $name');
      files[name] = Uint8List.fromList(entry.content as List<int>);
    }

    // plugin.json may live in a single top-level folder (zip of a directory)
    String? prefix;
    if (!files.containsKey('plugin.json')) {
      final candidates = files.keys.where((k) => k.endsWith('/plugin.json') && k.split('/').length == 2).toList();
      if (candidates.length == 1) {
        prefix = candidates.first.substring(0, candidates.first.length - 'plugin.json'.length);
      }
    }
    final Map<String, Uint8List> rooted;
    if (prefix != null) {
      rooted = {
        for (final e in files.entries)
          if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
      };
    } else {
      rooted = files;
    }
    final manifestBytes = rooted['plugin.json'];
    if (manifestBytes == null) throw ImportException('plugin.json not found in ZIP');

    final Object? json;
    try {
      json = jsonDecode(utf8.decode(manifestBytes));
    } catch (e) {
      throw ImportException('plugin.json is not valid JSON: $e');
    }
    final errors = validateManifest(json, fileExists: rooted.containsKey);
    if (errors.isNotEmpty) throw ImportException('plugin.json is invalid', errors);
    final manifest = PluginManifest.parse((json as Map).cast<String, Object?>());
    return ImportPackage(manifest: manifest, files: rooted, zipBytes: zipBytes, sourceUrl: sourceUrl);
  }

  /// Download a ZIP (wsi://install?url=..., update check, dev-serve).
  Future<ImportPackage> fromUrl(Uri url, {bool allowInsecure = false}) async {
    if (url.scheme != 'https' && !(allowInsecure && (url.scheme == 'http'))) {
      throw ImportException('Only https URLs can be imported: $url');
    }
    final Response<List<int>> res;
    try {
      res = await (allowInsecure ? _insecureDio : _dio).get<List<int>>(
        url.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
          followRedirects: true,
          validateStatus: (s) => s != null && s < 400,
        ),
      );
    } on DioException catch (e) {
      throw ImportException('Download failed: ${e.message ?? e.error ?? e.type.name}');
    }
    final bytes = res.data;
    if (bytes == null || bytes.isEmpty) throw ImportException('Download returned no data');
    return open(Uint8List.fromList(bytes), sourceUrl: url.toString());
  }

  static String? _normalize(String name) {
    var n = name.replaceAll('\\', '/');
    while (n.startsWith('./')) {
      n = n.substring(2);
    }
    if (n.isEmpty || n.endsWith('/')) return null;
    if (n.startsWith('/') || n.contains('../') || n.startsWith('__MACOSX/')) return null;
    final base = n.split('/').last;
    if (base == '.DS_Store' || base == 'Thumbs.db') return null;
    return n;
  }
}

/// MIME type for a stored plugin file (used when serving plugin pages, P3).
String mimeForPath(String path) {
  final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
  switch (ext) {
    case 'js':
    case 'mjs':
      return 'text/javascript';
    case 'css':
      return 'text/css';
    case 'html':
    case 'htm':
      return 'text/html';
    case 'json':
      return 'application/json';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'svg':
      return 'image/svg+xml';
    case 'webp':
      return 'image/webp';
    case 'txt':
    case 'md':
      return 'text/plain';
    case 'woff':
      return 'font/woff';
    case 'woff2':
      return 'font/woff2';
    default:
      return 'application/octet-stream';
  }
}

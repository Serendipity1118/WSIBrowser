// File selection and downloads (F-01-6).
//
// <input type="file"> is handled natively by flutter_inappwebview on both
// platforms (WebChromeClient.onShowFileChooser / WKWebView document picker);
// nothing to do here beyond the Android manifest entries.
//
// Downloads: onDownloadStartRequest gives us the URL. We fetch it with dio
// (sending the WebView's cookies so authenticated downloads work), store it in
// the app's Downloads directory, and offer the share sheet.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'cookie_store.dart';

class DownloadResult {
  const DownloadResult({required this.file, required this.name, required this.mime});
  final File file;
  final String name;
  final String mime;
}

class Downloader {
  Downloader(this._cookies, {Dio? dio}) : _dio = dio ?? Dio();

  final CookieStore _cookies;
  final Dio _dio;

  /// Directory where downloads are kept (app-private; shared through the share sheet).
  Future<Directory> downloadsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}Downloads');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static String fileNameFor(DownloadStartRequest request) {
    final suggested = request.suggestedFilename;
    if (suggested != null && suggested.isNotEmpty) return _sanitize(suggested);
    final disposition = request.contentDisposition ?? '';
    final m = RegExp(r'''filename\*?=(?:UTF-8'')?"?([^";]+)"?''', caseSensitive: false).firstMatch(disposition);
    if (m != null) return _sanitize(Uri.decodeComponent(m.group(1)!.trim()));
    final last = request.url.pathSegments.isNotEmpty ? request.url.pathSegments.last : '';
    return _sanitize(last.isEmpty ? 'download' : last);
  }

  static String _sanitize(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
    return cleaned.isEmpty ? 'download' : cleaned;
  }

  Future<DownloadResult> download(DownloadStartRequest request, {String? userAgent, void Function(int received, int total)? onProgress}) async {
    final url = request.url.uriValue;
    final name = fileNameFor(request);
    final dir = await downloadsDir();
    var target = File('${dir.path}${Platform.pathSeparator}$name');
    var n = 1;
    while (await target.exists()) {
      final dot = name.lastIndexOf('.');
      final stem = dot > 0 ? name.substring(0, dot) : name;
      final ext = dot > 0 ? name.substring(dot) : '';
      target = File('${dir.path}${Platform.pathSeparator}$stem ($n)$ext');
      n++;
    }
    final cookie = await _cookies.cookieHeaderFor(url);
    await _dio.download(
      url.toString(),
      target.path,
      onReceiveProgress: onProgress,
      options: Options(
        headers: {
          if (cookie.isNotEmpty) 'Cookie': cookie,
          if (userAgent != null && userAgent.isNotEmpty) 'User-Agent': userAgent,
        },
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
    return DownloadResult(file: target, name: target.uri.pathSegments.last, mime: request.mimeType ?? 'application/octet-stream');
  }

  Future<void> share(DownloadResult result) async {
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(result.file.path, mimeType: result.mime)]));
    } catch (e) {
      debugPrint('share failed: $e');
    }
  }
}

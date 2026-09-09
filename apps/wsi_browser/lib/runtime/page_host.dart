// wsi:// scheme (F-07-1, P3-01). wsi://plugin/<id>/<path> serves a file of an
// installed plugin from plugin_files. Path traversal and unknown plugins are
// rejected; a plugin can only reach its own files because the id is part of
// the URL and the WebView that shows a plugin page is created for that id.
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'importer.dart';
import 'repository.dart';

class PageHost {
  PageHost(this._repository);

  final PluginRepository _repository;

  static const scheme = 'wsi';
  static const pluginHost = 'plugin';

  /// `wsi://plugin/<id>/<path>`
  static Uri pageUrl(String pluginId, String path, [Map<String, String>? params]) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return Uri(scheme: scheme, host: pluginHost, path: '/$pluginId/$clean', queryParameters: params == null || params.isEmpty ? null : params);
  }

  /// (pluginId, path) for a wsi://plugin URL, or null when it is not one / is unsafe.
  static ({String pluginId, String path})? parse(Uri url) {
    if (url.scheme != scheme || url.host != pluginHost) return null;
    final segments = url.pathSegments;
    if (segments.length < 2) return null;
    final pluginId = segments.first;
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(pluginId)) return null;
    final rest = segments.sublist(1);
    if (rest.any((s) => s == '..' || s == '.' || s.isEmpty)) return null;
    final path = rest.join('/');
    if (path.contains('\\')) return null;
    return (pluginId: pluginId, path: path);
  }

  /// Resolve a wsi://plugin URL to file bytes + mime. [allowedPluginId]
  /// restricts the WebView to its own plugin (null = any installed plugin).
  Future<({Uint8List bytes, String mime})?> resolve(Uri url, {String? allowedPluginId}) async {
    final parsed = parse(url);
    if (parsed == null) return null;
    if (allowedPluginId != null && parsed.pluginId != allowedPluginId) return null;
    if (_repository.byId(parsed.pluginId) == null) return null;
    final bytes = await _repository.readFile(parsed.pluginId, parsed.path);
    if (bytes == null) return null;
    return (bytes: bytes, mime: mimeForPath(parsed.path));
  }

  /// Handler for InAppWebView.onLoadResourceWithCustomScheme.
  Future<CustomSchemeResponse?> onLoadResource(WebResourceRequest request, {String? allowedPluginId}) async {
    final r = await resolve(request.url.uriValue, allowedPluginId: allowedPluginId);
    if (r == null) return null;
    final mime = r.mime;
    final semi = mime.indexOf(';');
    return CustomSchemeResponse(
      data: r.bytes,
      contentType: semi > 0 ? mime.substring(0, semi) : mime,
      contentEncoding: mime.startsWith('text/') || mime.contains('javascript') || mime.contains('json') ? 'utf-8' : 'binary',
    );
  }
}

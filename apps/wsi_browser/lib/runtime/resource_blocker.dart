// WSI.blockResources (F-09, P5-09): rules per plugin { images, media, urls }.
// Applied to every WebView whose main-frame host matches the plugin's domains:
//   Android  shouldInterceptRequest -> empty response for blocked sub-resources
//   iOS      WKContentRuleList through InAppWebViewSettings.contentBlockers
// Rules live in memory (a plugin sets them on every start) and are cleared
// when the plugin is disabled or removed.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'domain_matcher.dart';
import 'repository.dart';

class BlockRules {
  const BlockRules({this.images = false, this.media = false, this.urls = const []});
  final bool images;
  final bool media;

  /// Substrings or glob-like patterns ('*' wildcard) matched against the resource URL.
  final List<String> urls;

  bool get isEmpty => !images && !media && urls.isEmpty;

  static BlockRules fromPayload(Map<String, Object?> p) => BlockRules(
        images: p['images'] == true,
        media: p['media'] == true,
        urls: [for (final u in (p['urls'] as List?) ?? const []) if (u is String && u.isNotEmpty) u],
      );

  Map<String, Object?> toJson() => {'images': images, 'media': media, 'urls': urls};
}

const _imageExt = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'avif', 'bmp', 'ico'};
const _mediaExt = {'mp4', 'webm', 'm4v', 'mov', 'mp3', 'm4a', 'aac', 'ogg', 'wav', 'm3u8', 'ts'};

class ResourceBlocker extends ChangeNotifier {
  ResourceBlocker(this._repository);

  final PluginRepository _repository;
  final Map<String, BlockRules> _rules = {};

  Map<String, BlockRules> get rules => Map.unmodifiable(_rules);

  void set(String pluginId, BlockRules rules) {
    if (rules.isEmpty) {
      _rules.remove(pluginId);
    } else {
      _rules[pluginId] = rules;
    }
    notifyListeners();
  }

  void clear(String pluginId) {
    if (_rules.remove(pluginId) != null) notifyListeners();
  }

  /// Merged rules of every enabled plugin whose domains match [pageHost].
  BlockRules effectiveFor(String pageHost) {
    var images = false;
    var media = false;
    final urls = <String>[];
    for (final e in _rules.entries) {
      final p = _repository.byId(e.key);
      if (p == null || !p.enabled || !matchesDomain(pageHost, p.manifest.domains)) continue;
      images |= e.value.images;
      media |= e.value.media;
      urls.addAll(e.value.urls);
    }
    return BlockRules(images: images, media: media, urls: urls);
  }

  static bool _matchesPattern(String url, String pattern) {
    if (!pattern.contains('*')) return url.contains(pattern);
    final re = RegExp('^${pattern.split('*').map(RegExp.escape).join('.*')}\$');
    return re.hasMatch(url);
  }

  /// Android: decide for one sub-resource request.
  bool shouldBlock(String pageHost, WebResourceRequest request) {
    final rules = effectiveFor(pageHost);
    if (rules.isEmpty) return false;
    if (request.isForMainFrame == true) return false;
    final url = request.url.toString();
    final ext = _extOf(request.url.uriValue);
    final accept = request.headers?['Accept'] ?? request.headers?['accept'] ?? '';
    if (rules.images && (_imageExt.contains(ext) || accept.startsWith('image/'))) return true;
    if (rules.media && (_mediaExt.contains(ext) || accept.startsWith('video/') || accept.startsWith('audio/'))) return true;
    for (final p in rules.urls) {
      if (_matchesPattern(url, p)) return true;
    }
    return false;
  }

  static String _extOf(Uri url) {
    final last = url.pathSegments.isEmpty ? '' : url.pathSegments.last;
    final dot = last.lastIndexOf('.');
    return dot < 0 ? '' : last.substring(dot + 1).toLowerCase();
  }

  /// Empty 204 response used to satisfy a blocked request on Android.
  static WebResourceResponse blockedResponse() => WebResourceResponse(
        contentType: 'text/plain',
        contentEncoding: 'utf-8',
        data: Uint8List(0),
        statusCode: 204,
        reasonPhrase: 'blocked by WSI plugin',
        headers: const {},
      );

  /// iOS: content blocker rules for the page host.
  List<ContentBlocker> contentBlockersFor(String pageHost) {
    if (!Platform.isIOS) return const [];
    final rules = effectiveFor(pageHost);
    final out = <ContentBlocker>[];
    if (rules.images) {
      out.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: '.*', resourceType: [ContentBlockerTriggerResourceType.IMAGE, ContentBlockerTriggerResourceType.SVG_DOCUMENT]),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      ));
    }
    if (rules.media) {
      out.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: '.*', resourceType: [ContentBlockerTriggerResourceType.MEDIA]),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      ));
    }
    for (final p in rules.urls) {
      final filter = p.contains('*') ? p.split('*').map(RegExp.escape).join('.*') : RegExp.escape(p);
      out.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: filter),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      ));
    }
    return out;
  }
}

// WSI.fetch (P2-08). Same result shape as the Chrome extension:
//   { ok, status, url, redirected, body[, bodyEncoding] } or { error, ok: false, status: 0 }
// Options: method (default HEAD), redirect ('follow' | 'manual' | 'error'),
// headers, body, credentials ('site' sends the shared cookie jar and stores
// Set-Cookie back), responseType ('text' | 'json' | 'arraybuffer' -> base64), timeoutMs.
import 'dart:convert';

import 'package:dio/dio.dart';

import '../browser/cookie_store.dart';
import 'registry.dart';

void registerFetchOps(OpRegistry registry, CookieStore cookies, {Dio? dio}) {
  final client = dio ?? Dio();

  registry.register('fetch', permission: 'fetch', (call) async {
    final url = call.requireString('url');
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
      return {'error': 'invalid url', 'ok': false, 'status': 0};
    }
    final options = call.arg<Map>('options')?.cast<String, Object?>() ?? const <String, Object?>{};
    final method = (options['method'] as String? ?? 'HEAD').toUpperCase();
    final redirect = options['redirect'] as String? ?? 'follow';
    final headers = <String, String>{
      for (final e in (options['headers'] as Map? ?? const {}).entries) e.key.toString(): e.value.toString(),
    };
    final responseType = options['responseType'] as String? ?? 'text';
    final timeoutMs = options['timeoutMs'];
    final timeout = timeoutMs is num && timeoutMs > 0 ? Duration(milliseconds: timeoutMs.toInt()) : const Duration(seconds: 60);
    final sendCookies = options['credentials'] == 'site';

    if (sendCookies) {
      final cookie = await cookies.cookieHeaderFor(uri);
      if (cookie.isNotEmpty) headers['Cookie'] = cookie;
    }

    try {
      final res = await client.request<List<int>>(
        url,
        data: options['body'],
        options: Options(
          method: method,
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: redirect == 'follow',
          maxRedirects: 10,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          validateStatus: (_) => true,
        ),
      );
      if (redirect == 'error' && res.statusCode != null && res.statusCode! >= 300 && res.statusCode! < 400) {
        return {'error': 'redirect', 'ok': false, 'status': 0};
      }
      if (sendCookies) {
        final setCookie = res.headers['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          await cookies.storeSetCookies(res.realUri, setCookie);
        }
      }
      final status = res.statusCode ?? 0;
      final bytes = res.data ?? const <int>[];
      Object? body = '';
      String? bodyEncoding;
      if (method != 'HEAD') {
        switch (responseType) {
          case 'json':
            try {
              body = jsonDecode(utf8.decode(bytes, allowMalformed: true));
            } catch (e) {
              return {'error': 'invalid json: $e', 'ok': false, 'status': status};
            }
          case 'arraybuffer':
            body = base64Encode(bytes);
            bodyEncoding = 'base64';
          default:
            body = utf8.decode(bytes, allowMalformed: true);
        }
      }
      return {
        'ok': status >= 200 && status < 300,
        'status': status,
        'url': res.realUri.toString(),
        'redirected': res.redirects.isNotEmpty || res.realUri.toString() != url,
        'body': body,
        'bodyEncoding': ?bodyEncoding,
      };
    } on DioException catch (e) {
      final message = switch (e.type) {
        DioExceptionType.connectionTimeout || DioExceptionType.receiveTimeout || DioExceptionType.sendTimeout => 'The operation was aborted (timeout)',
        _ => e.message ?? e.type.name,
      };
      return {'error': message, 'ok': false, 'status': 0};
    } catch (e) {
      return {'error': e.toString(), 'ok': false, 'status': 0};
    }
  });
}

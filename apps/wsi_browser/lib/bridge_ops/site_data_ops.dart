// WSI.siteData.clear({ cookies, storage }) (F-09, permission 'siteData').
//
// Clears the session of the plugin's own domains only: cookies of every
// domain listed in plugin.json `domains` ('*.example.com' covers the apex and
// its subdomains through the leading-dot domain), and the web storage of
// those origins where the platform supports per-origin deletion (Android
// WebStorageManager.deleteOrigin; iOS removes the matching data records).
// Used by plugins that switch between accounts (profile switch) and need a
// clean session before logging in again.
import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'registry.dart';

void registerSiteDataOps(OpRegistry registry) {
  registry.register('siteData.clear', permission: 'siteData', (call) async {
    final cookies = call.arg<bool>('cookies') ?? true;
    final storage = call.arg<bool>('storage') ?? true;
    final domains = call.plugin.manifest.domains.where((d) => d != '*').map((d) => d.startsWith('*.') ? d.substring(2) : d).toSet();
    var cookieDomains = 0;
    var storageOrigins = 0;
    if (cookies) {
      final manager = CookieManager.instance();
      for (final d in domains) {
        final url = WebUri('https://$d/');
        try {
          await manager.deleteCookies(url: url);
          await manager.deleteCookies(url: url, domain: d);
          await manager.deleteCookies(url: url, domain: '.$d');
          cookieDomains++;
        } catch (_) {
          // a domain without cookies is not an error
        }
      }
    }
    if (storage) {
      final ws = WebStorageManager.instance();
      try {
        if (Platform.isAndroid) {
          final origins = await ws.getOrigins();
          for (final o in origins) {
            final origin = o.origin;
            final host = origin == null ? '' : (Uri.tryParse(origin)?.host ?? '');
            if (origin == null || host.isEmpty) continue;
            if (domains.any((d) => host == d || host.endsWith('.$d'))) {
              await ws.deleteOrigin(origin: origin);
              storageOrigins++;
            }
          }
        } else if (Platform.isIOS) {
          final types = {WebsiteDataType.WKWebsiteDataTypeLocalStorage, WebsiteDataType.WKWebsiteDataTypeSessionStorage, WebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases};
          final records = await ws.fetchDataRecords(dataTypes: types);
          final matching = records.where((r) => domains.any((d) => r.displayName != null && (r.displayName == d || r.displayName!.endsWith('.$d')))).toList();
          if (matching.isNotEmpty) {
            await ws.removeDataFor(dataTypes: types, dataRecords: matching);
            storageOrigins = matching.length;
          }
        }
      } catch (e) {
        throw OpError('siteData.clear: storage failed: $e');
      }
    }
    return {'cookieDomains': cookieDomains, 'storageOrigins': storageOrigins};
  });
}

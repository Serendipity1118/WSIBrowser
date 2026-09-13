// App and system information that needs no permission:
//   app.info     WSI Browser name, package id, version, build number, OS
//   locale.get   device languages, the language the host UI uses, IANA time zone
import 'dart:io';
import 'dart:ui';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'registry.dart';

/// Host UI languages, first entry is the fallback (same rule as app.dart).
const List<String> kHostLanguages = ['ja', 'en', 'ko', 'zh'];

String hostLanguageFor(List<Locale> locales) {
  for (final l in locales) {
    if (kHostLanguages.contains(l.languageCode)) return l.languageCode;
  }
  return kHostLanguages.first;
}

Map<String, Object?> localePayload(List<Locale> locales, String timeZone, DateTime now) => {
      'languages': [for (final l in locales) l.toLanguageTag()],
      'language': locales.isEmpty ? null : locales.first.languageCode,
      'region': locales.isEmpty ? null : locales.first.countryCode,
      'appLanguage': hostLanguageFor(locales),
      'timeZone': timeZone,
      'timeZoneOffsetMinutes': now.timeZoneOffset.inMinutes,
    };

void registerAppOps(
  OpRegistry registry, {
  Future<PackageInfo> Function()? packageInfo,
  List<Locale> Function()? locales,
  Future<String> Function()? timeZone,
}) {
  registry.register('app.info', (call) async {
    final p = await (packageInfo ?? PackageInfo.fromPlatform)();
    return {
      'name': p.appName,
      'packageName': p.packageName,
      'version': p.version,
      'buildNumber': p.buildNumber,
      'os': Platform.operatingSystem,
    };
  });

  registry.register('locale.get', (call) async {
    final list = (locales ?? () => PlatformDispatcher.instance.locales)();
    String zone;
    try {
      zone = timeZone != null ? await timeZone() : (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      zone = DateTime.now().timeZoneName;
    }
    return localePayload(list, zone, DateTime.now());
  });
}

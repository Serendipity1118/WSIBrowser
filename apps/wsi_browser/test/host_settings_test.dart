import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/settings/host_settings.dart';

void main() {
  test('defaults, persistence and clamping', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = HostSettings(db);
    await s.load();
    expect(s.tabLimit, HostSettings.defaultTabLimit);
    expect(s.initialUrl, '');
    expect(s.externalLinks, ExternalLinkMode.inApp);
    expect(s.developerMode, isFalse);
    expect(s.updateCheck, isTrue);
    expect(s.wsiEnabled, isTrue);

    var n = 0;
    s.addListener(() => n++);
    await s.setTabLimit(99);
    expect(s.tabLimit, HostSettings.maxTabLimit);
    await s.setInitialUrl('  https://example.com ');
    await s.setExternalLinks(ExternalLinkMode.external);
    await s.setDeveloperMode(true);
    await s.setUserAgent('');
    expect(n, 5);

    // a fresh instance reads the persisted values back
    final s2 = HostSettings(db);
    await s2.load();
    expect(s2.tabLimit, HostSettings.maxTabLimit);
    expect(s2.initialUrl, 'https://example.com');
    expect(s2.externalLinks, ExternalLinkMode.external);
    expect(s2.developerMode, isTrue);
    expect(s2.userAgent, '');
    await db.close();
  });
}

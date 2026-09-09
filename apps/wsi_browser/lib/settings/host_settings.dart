// Typed host settings on top of the host_settings table (F-10).
//
// Values are cached in memory and persisted through AppDatabase. Widgets
// listen with ListenableBuilder / AppScope.settingsOf(context).
import 'package:flutter/foundation.dart';

import '../db/database.dart';

enum ExternalLinkMode { inApp, external }

class HostSettingsKeys {
  static const initialUrl = 'initialUrl';
  static const tabLimit = 'tabLimit';
  static const externalLinks = 'externalLinks';
  static const userAgent = 'userAgent';
  static const logRetention = 'logRetention';
  static const developerMode = 'developerMode';
  static const webInspector = 'webInspector';
  static const updateCheck = 'updateCheck';

  /// Global kill switch for plugin injection (WSI's wsiEnabled).
  static const wsiEnabled = 'wsiEnabled';
}

class HostSettings extends ChangeNotifier {
  HostSettings(this._db);

  final AppDatabase _db;
  Map<String, Object?> _values = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  static const defaultTabLimit = 5;
  static const defaultLogRetention = 1000;
  static const minTabLimit = 1;
  static const maxTabLimit = 20;

  Future<void> load() async {
    _values = await _db.getAllSettings();
    _loaded = true;
    notifyListeners();
  }

  // ---- getters -------------------------------------------------------------

  String get initialUrl => (_values[HostSettingsKeys.initialUrl] as String?)?.trim() ?? '';

  int get tabLimit {
    final v = _values[HostSettingsKeys.tabLimit];
    final n = v is num ? v.toInt() : defaultTabLimit;
    return n.clamp(minTabLimit, maxTabLimit);
  }

  ExternalLinkMode get externalLinks =>
      _values[HostSettingsKeys.externalLinks] == 'external' ? ExternalLinkMode.external : ExternalLinkMode.inApp;

  String get userAgent => (_values[HostSettingsKeys.userAgent] as String?)?.trim() ?? '';

  int get logRetention {
    final v = _values[HostSettingsKeys.logRetention];
    return v is num ? v.toInt().clamp(100, 100000) : defaultLogRetention;
  }

  bool get developerMode => _values[HostSettingsKeys.developerMode] == true;
  bool get webInspector => _values[HostSettingsKeys.webInspector] == true;
  bool get updateCheck => _values[HostSettingsKeys.updateCheck] != false;
  bool get wsiEnabled => _values[HostSettingsKeys.wsiEnabled] != false;

  // ---- setters -------------------------------------------------------------

  Future<void> set(String key, Object? value) async {
    if (value == null) {
      _values.remove(key);
      await _db.removeSetting(key);
    } else {
      _values[key] = value;
      await _db.setSetting(key, value);
    }
    notifyListeners();
  }

  Future<void> setInitialUrl(String url) => set(HostSettingsKeys.initialUrl, url.trim().isEmpty ? null : url.trim());
  Future<void> setTabLimit(int n) => set(HostSettingsKeys.tabLimit, n.clamp(minTabLimit, maxTabLimit));
  Future<void> setExternalLinks(ExternalLinkMode m) =>
      set(HostSettingsKeys.externalLinks, m == ExternalLinkMode.external ? 'external' : 'inApp');
  Future<void> setUserAgent(String ua) => set(HostSettingsKeys.userAgent, ua.trim().isEmpty ? null : ua.trim());
  Future<void> setLogRetention(int n) => set(HostSettingsKeys.logRetention, n);
  Future<void> setDeveloperMode(bool v) => set(HostSettingsKeys.developerMode, v);
  Future<void> setWebInspector(bool v) => set(HostSettingsKeys.webInspector, v);
  Future<void> setUpdateCheck(bool v) => set(HostSettingsKeys.updateCheck, v);
  Future<void> setWsiEnabled(bool v) => set(HostSettingsKeys.wsiEnabled, v);
}

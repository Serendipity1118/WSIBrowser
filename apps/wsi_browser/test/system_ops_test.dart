import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wsi_browser/bridge_ops/app_ops.dart';
import 'package:wsi_browser/bridge_ops/biometrics_ops.dart';
import 'package:wsi_browser/bridge_ops/location_ops.dart';
import 'package:wsi_browser/bridge_ops/native_ops.dart';
import 'package:wsi_browser/bridge_ops/network_battery_ops.dart';
import 'package:wsi_browser/bridge_ops/registry.dart';
import 'package:wsi_browser/bridge_ops/session_fanout.dart';
import 'package:wsi_browser/db/database.dart';
import 'package:wsi_browser/runtime/importer.dart';
import 'package:wsi_browser/runtime/manifest.dart';
import 'package:wsi_browser/runtime/repository.dart';
import 'package:wsi_browser/settings/host_settings.dart';

import 'native_ops_test.dart' show manifest, zipOf;

class FakeLocation extends LocationSource {
  FakeLocation({this.enabled = true, this.permission = LocationPermission.denied, this.afterRequest = LocationPermission.whileInUse, this.last});
  bool enabled;
  LocationPermission permission;
  LocationPermission afterRequest;
  Position? last;
  int requests = 0;
  LocationSettings? settings;

  @override
  Future<bool> serviceEnabled() async => enabled;
  @override
  Future<LocationPermission> check() async => permission;
  @override
  Future<LocationPermission> request() async {
    requests++;
    return permission = afterRequest;
  }

  @override
  Future<Position> current(LocationSettings settings) async {
    this.settings = settings;
    return position(35.68, 139.76, DateTime.now());
  }

  @override
  Future<Position?> lastKnown() async => last;
}

Position position(double lat, double lng, DateTime at) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: at,
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  late AppDatabase db;
  late PluginRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = HostSettings(db);
    await settings.load();
    FlutterSecureStorage.setMockInitialValues({});
    repo = PluginRepository(db, settings, secureStorage: const FlutterSecureStorage());
    await repo.load();
    for (final id in ['a', 'b']) {
      await repo.install(ZipImporter().open(zipOf({
        'plugin.json': jsonEncode(manifest(id, permissions: ['device', 'location', 'network', 'battery', 'biometrics'])),
        'main.js': '',
      })));
    }
  });

  tearDown(() => db.close());

  Future<Object?> Function(String op, [Map<String, Object?> payload]) caller(OpRegistry registry, String pluginId,
      {BridgeContext context = BridgeContext.page, BridgeSession? session}) {
    final s = session ?? BridgeSession(token: 't-$pluginId', pluginId: pluginId, context: context, webViewKey: 1);
    return (op, [payload = const {}]) =>
        registry.lookup(op)!.handler(BridgeCall(session: s, plugin: repo.byId(pluginId)!, op: op, payload: payload));
  }

  test('new permissions are known; only location needs consent', () {
    for (final p in ['location', 'network', 'battery', 'biometrics']) {
      expect(kAllPermissions, contains(p));
    }
    expect(kSensitivePermissions, contains('location'));
    expect(kSensitivePermissions, isNot(contains('network')));
  });

  group('device.key', () {
    test('stable per plugin, different between plugins, android_id based', () async {
      final registry = OpRegistry();
      registerDeviceOps(registry, androidId: () async => 'android-1234');
      final a1 = await caller(registry, 'a')('device.key');
      final a2 = await caller(registry, 'a')('device.key');
      final b = await caller(registry, 'b')('device.key');
      expect(a1, a2);
      expect(a1, isNot(b));
      expect(a1, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(a1, deviceKeyFor('android-1234', 'a'));
      expect(registry.lookup('device.key')!.permission, 'device');
    });

    test('without android_id a random secret is created once in secure storage', () async {
      final registry = OpRegistry();
      registerDeviceOps(registry, androidId: () async => null);
      final first = await caller(registry, 'a')('device.key');
      final secret = await const FlutterSecureStorage().read(key: kDeviceSecretKey);
      expect(secret, isNotNull);
      expect(await caller(registry, 'a')('device.key'), first);
      expect(first, deviceKeyFor(secret!, 'a'));
    });
  });

  group('app / locale', () {
    test('app.info and locale.get need no permission', () async {
      final registry = OpRegistry();
      registerAppOps(
        registry,
        packageInfo: () async => PackageInfo(appName: 'WSI Browser', packageName: 'jp.serendipy.wsibrowser', version: '0.1.0', buildNumber: '3'),
        locales: () => const [Locale('fr', 'FR'), Locale('en', 'US')],
        timeZone: () async => 'Asia/Tokyo',
      );
      final info = await caller(registry, 'a')('app.info') as Map;
      expect(info['version'], '0.1.0');
      expect(info['buildNumber'], '3');
      final locale = await caller(registry, 'a')('locale.get') as Map;
      expect(locale['languages'], ['fr-FR', 'en-US']);
      expect(locale['language'], 'fr');
      expect(locale['region'], 'FR');
      expect(locale['appLanguage'], 'en', reason: 'first language the host UI supports');
      expect(locale['timeZone'], 'Asia/Tokyo');
      expect(registry.lookup('app.info')!.permission, isNull);
      expect(registry.lookup('locale.get')!.permission, isNull);
      expect(hostLanguageFor(const [Locale('fr')]), 'ja');
    });
  });

  group('location', () {
    test('asks once when undecided, then returns the position', () async {
      final registry = OpRegistry();
      final source = FakeLocation();
      registerLocationOps(registry, source: source);
      final call = caller(registry, 'a');
      expect(await call('location.permission'), {'status': 'denied', 'serviceEnabled': true});
      final pos = await call('location.getCurrent', {'accuracy': 'low', 'timeout': 3000}) as Map;
      expect(pos['latitude'], 35.68);
      expect(source.requests, 1);
      expect(source.settings!.accuracy, LocationAccuracy.low);
      expect(source.settings!.timeLimit, const Duration(seconds: 3));
      expect(await call('location.request'), {'status': 'granted', 'serviceEnabled': true});
      expect(source.requests, 1, reason: 'already granted');
    });

    test('maxAge uses a recent last known position; errors for off / denied', () async {
      final registry = OpRegistry();
      final source = FakeLocation(permission: LocationPermission.whileInUse, last: position(1, 2, DateTime.now().subtract(const Duration(seconds: 10))));
      registerLocationOps(registry, source: source);
      final call = caller(registry, 'a');
      expect((await call('location.getCurrent', {'maxAge': 60000}) as Map)['latitude'], 1);
      expect((await call('location.getCurrent', {'maxAge': 1000}) as Map)['latitude'], 35.68);

      source.permission = LocationPermission.deniedForever;
      await expectLater(call('location.getCurrent'), throwsA(isA<OpError>().having((e) => e.message, 'message', contains('deniedForever'))));
      source.enabled = false;
      await expectLater(call('location.getCurrent'), throwsA(isA<OpError>().having((e) => e.message, 'message', contains('services are off'))));
      expect(registry.lookup('location.getCurrent')!.permission, 'location');
    });
  });

  group('network / battery', () {
    test('payloads', () {
      expect(networkPayload([ConnectivityResult.none]), {'online': false, 'types': <String>[]});
      expect(networkPayload([ConnectivityResult.wifi, ConnectivityResult.vpn]), {'online': true, 'types': ['wifi', 'vpn']});
      expect(batteryPayload(80, BatteryState.charging, false), {'level': 80, 'state': 'charging', 'lowPowerMode': false});
      expect(batteryPayload(-1, BatteryState.unknown, true)['level'], isNull);
    });

    test('fanout listens only while live sessions subscribe and drops repeats', () async {
      final controller = StreamController<Object?>.broadcast();
      var listens = 0;
      final sent = <String>[];
      final fanout = SessionFanout(
        event: 'network.change',
        source: () {
          listens++;
          return controller.stream;
        },
        emit: (s, event, payload) async => sent.add('${s.token}:$event:${jsonEncode(payload)}'),
      );
      final s1 = BridgeSession(token: 's1', pluginId: 'a', context: BridgeContext.page, webViewKey: 1);
      final s2 = BridgeSession(token: 's2', pluginId: 'b', context: BridgeContext.worker, webViewKey: 2);
      expect(fanout.listening, isFalse);
      fanout.add(s1);
      fanout.add(s2);
      expect(listens, 1);

      await fanout.deliver({'online': true});
      await fanout.deliver({'online': true});
      expect(sent, ['s1:network.change:{"online":true}', 's2:network.change:{"online":true}']);

      s2.revoked = true;
      await fanout.deliver({'online': false});
      expect(sent.last, 's1:network.change:{"online":false}');
      expect(sent, hasLength(3));

      fanout.remove(s1);
      expect(fanout.listening, isFalse);
      fanout.add(s1);
      expect(listens, 2);
      await controller.close();
    });

    test('status / watch / unwatch are guarded by their permissions', () async {
      final registry = OpRegistry();
      registerNetworkOps(registry, (s, e, p) async => null);
      registerBatteryOps(registry, (s, e, p) async => null);
      for (final op in ['network.status', 'network.watch', 'network.unwatch']) {
        expect(registry.lookup(op)!.permission, 'network');
      }
      for (final op in ['battery.status', 'battery.watch', 'battery.unwatch']) {
        expect(registry.lookup(op)!.permission, 'battery');
      }
    });
  });

  group('biometrics', () {
    test('authenticate needs a visible context and a short reason', () async {
      final registry = OpRegistry();
      registerBiometricsOps(registry);
      final entry = registry.lookup('biometrics.authenticate')!;
      expect(entry.permission, 'biometrics');
      expect(entry.contexts, {BridgeContext.page, BridgeContext.pluginPage});
      final call = caller(registry, 'a');
      await expectLater(call('biometrics.authenticate', {'reason': '  '}), throwsA(isA<OpError>()));
      await expectLater(call('biometrics.authenticate', {'reason': 'x' * 201}), throwsA(isA<OpError>()));
      await expectLater(call('biometrics.authenticate', {}), throwsA(isA<OpError>()));
    });
  });
}

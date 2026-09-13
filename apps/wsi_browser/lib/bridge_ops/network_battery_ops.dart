// Connection and battery state:
//   network.status / watch / unwatch   Wi-Fi, mobile, ... (permission: network)
//   battery.status / watch / unwatch   level, charging state, low power mode (permission: battery)
// watch / unwatch are called by the SDK when the first onChange listener is
// added and the last one removed; changes arrive as network.change / battery.change.
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'registry.dart';
import 'session_fanout.dart';

Map<String, Object?> networkPayload(List<ConnectivityResult> results) {
  final types = <String>{
    for (final r in results)
      switch (r) {
        ConnectivityResult.wifi => 'wifi',
        ConnectivityResult.mobile => 'mobile',
        ConnectivityResult.ethernet => 'ethernet',
        ConnectivityResult.vpn => 'vpn',
        ConnectivityResult.bluetooth => 'bluetooth',
        ConnectivityResult.satellite => 'satellite',
        ConnectivityResult.other => 'other',
        ConnectivityResult.none => 'none',
      },
  }..remove('none');
  // "online" means a network interface is up, not that the internet is reachable.
  return {'online': types.isNotEmpty, 'types': types.toList()};
}

Map<String, Object?> batteryPayload(int level, BatteryState state, bool lowPowerMode) => {
      'level': level < 0 ? null : level,
      'state': switch (state) {
        BatteryState.full => 'full',
        BatteryState.charging => 'charging',
        BatteryState.connectedNotCharging => 'connectedNotCharging',
        BatteryState.discharging => 'discharging',
        BatteryState.unknown => 'unknown',
      },
      'lowPowerMode': lowPowerMode,
    };

void registerNetworkOps(OpRegistry registry, SessionEmit emit, {Connectivity? connectivity}) {
  final c = connectivity ?? Connectivity();
  final fanout = SessionFanout(
    event: 'network.change',
    source: () => c.onConnectivityChanged.map(networkPayload),
    emit: emit,
  );
  registry.register('network.status', permission: 'network', (call) async => networkPayload(await c.checkConnectivity()));
  registry.register('network.watch', permission: 'network', (call) async {
    fanout.add(call.session);
    return true;
  });
  registry.register('network.unwatch', permission: 'network', (call) async {
    fanout.remove(call.session);
    return true;
  });
}

void registerBatteryOps(OpRegistry registry, SessionEmit emit, {Battery? battery}) {
  final b = battery ?? Battery();

  Future<Map<String, Object?>> status([BatteryState? known]) async {
    final level = await b.batteryLevel.catchError((_) => -1);
    final state = known ?? await b.batteryState.catchError((_) => BatteryState.unknown);
    final low = await b.isInBatterySaveMode.catchError((_) => false);
    return batteryPayload(level, state, low);
  }

  final fanout = SessionFanout(
    event: 'battery.change',
    source: () => b.onBatteryStateChanged.asyncMap(status),
    emit: emit,
  );
  registry.register('battery.status', permission: 'battery', (call) async => status());
  registry.register('battery.watch', permission: 'battery', (call) async {
    fanout.add(call.session);
    return true;
  });
  registry.register('battery.unwatch', permission: 'battery', (call) async {
    fanout.remove(call.session);
    return true;
  });
}

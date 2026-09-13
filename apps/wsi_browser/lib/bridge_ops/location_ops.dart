// WSI.location (permission: location, while the app is in use only):
//   location.permission   { status, serviceEnabled } without asking
//   location.request      shows the OS permission dialog when still undecided
//   location.getCurrent   { latitude, longitude, accuracy, ... } (asks first if needed)
import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'registry.dart';

/// Geolocator as functions so tests can replace it.
class LocationSource {
  const LocationSource();
  Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();
  Future<LocationPermission> check() => Geolocator.checkPermission();
  Future<LocationPermission> request() => Geolocator.requestPermission();
  Future<Position> current(LocationSettings settings) => Geolocator.getCurrentPosition(locationSettings: settings);
  Future<Position?> lastKnown() => Geolocator.getLastKnownPosition();
}

String permissionStatus(LocationPermission p) => switch (p) {
      LocationPermission.always || LocationPermission.whileInUse => 'granted',
      LocationPermission.denied => 'denied',
      LocationPermission.deniedForever => 'deniedForever',
      LocationPermission.unableToDetermine => 'unknown',
    };

Map<String, Object?> positionPayload(Position p) => {
      'latitude': p.latitude,
      'longitude': p.longitude,
      'accuracy': p.accuracy,
      'altitude': p.altitude,
      'altitudeAccuracy': p.altitudeAccuracy,
      'heading': p.heading,
      'speed': p.speed,
      'timestamp': p.timestamp.millisecondsSinceEpoch,
    };

LocationAccuracy accuracyFor(String? name) => switch (name) {
      'low' => LocationAccuracy.low,
      'balanced' => LocationAccuracy.medium,
      _ => LocationAccuracy.high,
    };

void registerLocationOps(OpRegistry registry, {LocationSource source = const LocationSource()}) {
  Future<Map<String, Object?>> state(LocationPermission p) async =>
      {'status': permissionStatus(p), 'serviceEnabled': await source.serviceEnabled()};

  registry.register('location.permission', permission: 'location', (call) async => state(await source.check()));

  registry.register('location.request', permission: 'location', (call) async {
    var p = await source.check();
    if (p == LocationPermission.denied) p = await source.request();
    return state(p);
  });

  registry.register('location.getCurrent', permission: 'location', (call) async {
    if (!await source.serviceEnabled()) throw OpError('location: location services are off');
    var p = await source.check();
    if (p == LocationPermission.denied) p = await source.request();
    if (p != LocationPermission.whileInUse && p != LocationPermission.always) {
      throw OpError('location: permission ${permissionStatus(p)}');
    }
    final maxAge = call.payload['maxAge'];
    if (maxAge is num && maxAge > 0) {
      final last = await source.lastKnown();
      if (last != null && DateTime.now().difference(last.timestamp).inMilliseconds <= maxAge) return positionPayload(last);
    }
    final timeout = call.payload['timeout'];
    final settings = LocationSettings(
      accuracy: accuracyFor(call.arg<String>('accuracy')),
      timeLimit: Duration(milliseconds: timeout is num && timeout > 0 ? timeout.toInt() : 15000),
    );
    try {
      return positionPayload(await source.current(settings));
    } on TimeoutException {
      throw OpError('location: timeout');
    } catch (e) {
      throw OpError('location: $e');
    }
  });
}

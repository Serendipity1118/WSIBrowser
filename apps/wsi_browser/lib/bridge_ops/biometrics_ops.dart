// WSI.biometrics (permission: biometrics). The plugin only learns whether the
// user passed Face ID / fingerprint / device passcode, never any biometric data.
//   biometrics.status        { supported, enrolled, types }
//   biometrics.authenticate  { success, reason? }; the prompt names the plugin
import 'package:local_auth/local_auth.dart';

import 'registry.dart';

const int kMaxReasonLength = 200;

String biometricTypeName(BiometricType t) => switch (t) {
      BiometricType.face => 'face',
      BiometricType.fingerprint => 'fingerprint',
      BiometricType.iris => 'iris',
      BiometricType.strong => 'strong',
      BiometricType.weak => 'weak',
    };

void registerBiometricsOps(OpRegistry registry, {LocalAuthentication? auth}) {
  final a = auth ?? LocalAuthentication();

  registry.register('biometrics.status', permission: 'biometrics', (call) async {
    final supported = await a.isDeviceSupported();
    final types = supported ? await a.getAvailableBiometrics() : const <BiometricType>[];
    return {'supported': supported, 'enrolled': types.isNotEmpty, 'types': types.map(biometricTypeName).toList()};
  });

  // A prompt needs a visible screen: not from background workers.
  registry.register('biometrics.authenticate', permission: 'biometrics', contexts: {BridgeContext.page, BridgeContext.pluginPage}, (call) async {
    final reason = call.requireString('reason').trim();
    if (reason.isEmpty || reason.length > kMaxReasonLength) {
      throw OpError('biometrics.authenticate: "reason" must be 1-$kMaxReasonLength characters');
    }
    try {
      final ok = await a.authenticate(
        localizedReason: '${call.plugin.manifest.name}: $reason',
        biometricOnly: call.arg<bool>('biometricOnly') ?? false,
      );
      return ok ? {'success': true} : {'success': false, 'reason': 'failed'};
    } on LocalAuthException catch (e) {
      return {'success': false, 'reason': e.code.name};
    }
  });
}

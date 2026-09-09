// Platform database factory. Kept separate from database.dart so unit tests
// can open an in-memory database without drift_flutter / path_provider.
import 'package:drift_flutter/drift_flutter.dart';

import 'database.dart';

AppDatabase openAppDatabase() {
  return AppDatabase(driftDatabase(
    name: 'wsi_browser',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  ));
}

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'app/bootstrap.dart';
import 'db/open_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = AppServices.create(openAppDatabase());
  await bootstrap(services);
  runApp(WsiBrowserApp(services: services));
}

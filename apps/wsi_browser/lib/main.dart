import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_links_handler.dart';
import 'app/app_scope.dart';
import 'app/bootstrap.dart';
import 'db/open_database.dart';
import 'runtime/runtime.dart';
import 'ui/plugin_list_page.dart';
import 'ui/start_plugin_summary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = AppServices.create(openAppDatabase());
  await bootstrap(services);

  // P2: plugin runtime. The browser layer only sees WebViewTabHooks.
  final runtime = PluginRuntime(services);
  services.extras['runtime'] = runtime;
  await runtime.init();

  final navigatorKey = GlobalKey<NavigatorState>();
  final links = AppLinksHandler(navigatorKey: navigatorKey, runtime: runtime, settings: services.settings);
  await links.start();

  runApp(WsiBrowserApp(
    services: services,
    navigatorKey: navigatorKey,
    hooks: runtime.hooks,
    menuSource: runtime.menuBus,
    pluginSummary: const StartPluginSummary(),
    onPlugins: () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PluginListPage()));
      }
    },
  ));
}

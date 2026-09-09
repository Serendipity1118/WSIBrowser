// Startup: load settings, trim logs, open the first tab (initial URL or start page).
import '../browser/navigation_policy.dart';
import '../browser/tab_manager.dart';
import 'app_scope.dart';

Future<void> bootstrap(AppServices services) async {
  await services.settings.load();
  await services.db.trimLogs(services.settings.logRetention);
  if (services.tabs.tabs.isEmpty) {
    services.tabs.open(initialTabUrl(services));
  }
}

/// The URL of the first tab: the host setting when set and valid, else the start page.
String initialTabUrl(AppServices services) {
  final configured = services.settings.initialUrl;
  if (configured.isEmpty) return kStartPageUrl;
  final uri = NavigationPolicy.normalizeInput(configured);
  if (uri.scheme == 'http' || uri.scheme == 'https') return uri.toString();
  return kStartPageUrl;
}

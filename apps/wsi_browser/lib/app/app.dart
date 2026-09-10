// MaterialApp shell: theme, localization (ja default; en / ko / zh), routes.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../browser/app_menu.dart';
import '../browser/browser_screen.dart';
import '../browser/web_view_tab.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_scope.dart';

/// App-wide snack bars (WSI.toast) that do not depend on a screen's context
/// staying alive while plugin pages are pushed and popped.
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class WsiBrowserApp extends StatelessWidget {
  const WsiBrowserApp({super.key, required this.services, this.hooks = const WebViewTabHooks(), this.pluginSummary, this.onPlugins, this.navigatorKey, this.menuSource});

  final AppServices services;
  final GlobalKey<NavigatorState>? navigatorKey;
  final AppMenuSource? menuSource;
  final WebViewTabHooks hooks;
  final Widget? pluginSummary;
  final VoidCallback? onPlugins;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: appScaffoldMessengerKey,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF4688F1), useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF4688F1), brightness: Brightness.dark, useMaterial3: true),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: (locales, supported) {
          for (final locale in locales ?? const <Locale>[]) {
            for (final s in supported) {
              if (s.languageCode == locale.languageCode) return s;
            }
          }
          return const Locale('ja');
        },
        home: BrowserScreen(hooks: hooks, pluginSummary: pluginSummary, onPlugins: onPlugins, menuSource: menuSource),
      ),
    );
  }
}

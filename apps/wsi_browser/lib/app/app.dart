// MaterialApp shell: theme, localization (ja default; en / ko / zh), routes.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../browser/browser_screen.dart';
import '../browser/web_view_tab.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_scope.dart';

class WsiBrowserApp extends StatelessWidget {
  const WsiBrowserApp({super.key, required this.services, this.hooks = const WebViewTabHooks(), this.pluginSummary, this.onPlugins});

  final AppServices services;
  final WebViewTabHooks hooks;
  final Widget? pluginSummary;
  final VoidCallback? onPlugins;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
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
        home: BrowserScreen(hooks: hooks, pluginSummary: pluginSummary, onPlugins: onPlugins),
      ),
    );
  }
}

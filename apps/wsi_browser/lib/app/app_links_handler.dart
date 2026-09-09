// wsi:// links and "open with" file URIs (F-02-1, F-11). Uses app_links for
// both the custom scheme and files handed to the app by the OS.
//
//   wsi://install?url=<https zip url>   -> import preview
//   wsi://dev?url=<zip url>[&interval=s] -> developer live reload (developer mode only)
//   content:// or file:// ...zip         -> import preview
import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../runtime/runtime.dart';
import '../settings/host_settings.dart';
import '../ui/import_page.dart';

class AppLinksHandler {
  AppLinksHandler({required this.navigatorKey, required this.runtime, required this.settings});

  final GlobalKey<NavigatorState> navigatorKey;
  final PluginRuntime runtime;
  final HostSettings settings;
  final AppLinks _links = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> start() async {
    runtime.onAppLink = handle;
    _sub = _links.uriLinkStream.listen((uri) => handle(uri));
  }

  void dispose() {
    _sub?.cancel();
  }

  BuildContext? get _context => navigatorKey.currentContext;

  Future<bool> handle(Uri uri) async {
    final context = _context;
    if (context == null) return false;
    if (uri.scheme == 'wsi') {
      switch (uri.host) {
        case 'install':
          final url = uri.queryParameters['url'];
          if (url == null) return false;
          await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => ImportPage(initialUrl: cleanUrlInput(url))));
          return true;
        case 'dev':
          final url = uri.queryParameters['url'];
          if (url == null) return false;
          if (!settings.developerMode) {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).importInsecureUrl)));
            return true;
          }
          final interval = int.tryParse(uri.queryParameters['interval'] ?? '') ?? 10;
          await runtime.devReloader.start(Uri.parse(url), interval: Duration(seconds: interval.clamp(2, 3600)));
          return true;
        case 'start':
          return true;
        default:
          return false;
      }
    }
    if (uri.scheme == 'file' || uri.scheme == 'content') {
      try {
        final bytes = await File(uri.toFilePath()).readAsBytes();
        if (!context.mounted) return false;
        await importBytes(context, bytes);
        return true;
      } catch (_) {
        // content:// without a file path: app_links on Android resolves most
        // of them to file paths; anything else is left to the file picker.
        return false;
      }
    }
    return false;
  }
}

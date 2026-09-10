// WSI.toast / WSI.dialog (P2-14), WSI.ui.openPage / closePage (P3-03),
// WSI.ui.openUrl (plugin pages open a site URL in a browser tab).
import 'package:flutter/material.dart';

import '../browser/tab_manager.dart';
import '../runtime/menu_bus.dart';
import 'registry.dart';

void registerUiOps(OpRegistry registry, BuildContext? Function() contextProvider, {OpenPage? openPage, TabManager? tabs}) {
  registry.register('toast', (call) async {
    final context = contextProvider();
    if (context == null || !context.mounted) return false;
    final message = '${call.payload['message'] ?? ''}';
    final duration = call.payload['duration'];
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: duration is num && duration > 0 ? duration.toInt() : 3000),
    ));
    return true;
  });

  registry.register('dialog', (call) async {
    final context = contextProvider();
    if (context == null || !context.mounted) throw OpError('no UI available');
    final title = call.arg<String>('title');
    final message = '${call.payload['message'] ?? ''}';
    final buttonsRaw = call.payload['buttons'];
    final buttons = buttonsRaw is List && buttonsRaw.isNotEmpty ? buttonsRaw.map((b) => '$b').toList() : ['OK'];
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: title == null || title.isEmpty ? null : Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          for (var i = 0; i < buttons.length; i++)
            if (i == buttons.length - 1)
              FilledButton(onPressed: () => Navigator.of(ctx).pop(i), child: Text(buttons[i]))
            else
              TextButton(onPressed: () => Navigator.of(ctx).pop(i), child: Text(buttons[i])),
        ],
      ),
    );
    return result ?? -1;
  });

  registry.register('ui.openPage', permission: 'pages', (call) async {
    final name = call.requireString('name');
    final page = call.plugin.manifest.pages.where((p) => p.name == name).firstOrNull;
    if (page == null) throw OpError('ui.openPage: unknown page "$name"');
    if (openPage == null) throw OpError('no UI available');
    final params = call.arg<Map>('params')?.map((k, v) => MapEntry('$k', '$v'));
    // do not await: the page stays open until the user closes it
    unawaitedOpen(openPage(call.plugin, page, params));
    return true;
  });

  // Open an http(s) URL in the active browser tab (newTab: true opens a new one)
  // and close the plugin page that asked, so a bookmarks / results page can
  // hand the user over to the site.
  registry.register('ui.openUrl', permission: 'pages', (call) async {
    final url = Uri.tryParse(call.requireString('url'));
    if (url == null || !(url.scheme == 'https' || url.scheme == 'http')) throw OpError('ui.openUrl: invalid url');
    if (tabs == null) throw OpError('no UI available');
    final newTab = call.arg<bool>('newTab') ?? false;
    final context = contextProvider();
    if (context != null && context.mounted && call.session.context == BridgeContext.pluginPage) closeTopmostPluginPage(context);
    if (newTab || tabs.active == null) {
      final t = tabs.open(url.toString());
      if (t == null) throw OpError('ui.openUrl: tab limit reached');
    } else {
      await tabs.active!.load(url.toString());
    }
    return true;
  });

  registry.register('ui.closePage', permission: 'pages', (call) async {
    final context = contextProvider();
    if (context == null || !context.mounted) return false;
    closeTopmostPluginPage(context);
    return true;
  });
}

void unawaitedOpen(Future<void> f) {
  f.catchError((Object e) => debugPrint('openPage failed: $e'));
}

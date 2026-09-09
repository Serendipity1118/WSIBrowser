// WSI.toast / WSI.dialog (P2-14), WSI.ui.openPage / closePage (P3-03).
import 'package:flutter/material.dart';

import '../runtime/menu_bus.dart';
import 'registry.dart';

void registerUiOps(OpRegistry registry, BuildContext? Function() contextProvider, {OpenPage? openPage}) {
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

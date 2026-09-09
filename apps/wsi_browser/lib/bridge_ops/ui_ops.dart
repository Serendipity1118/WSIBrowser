// WSI.toast / WSI.dialog (P2-14). ui.openPage / closePage arrive in P3.
import 'package:flutter/material.dart';

import 'registry.dart';

void registerUiOps(OpRegistry registry, BuildContext? Function() contextProvider) {
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
}

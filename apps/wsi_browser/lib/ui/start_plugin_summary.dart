// Installed plugins card on the start page (P2). Tapping opens the plugin list.
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../runtime/runtime.dart';
import 'plugin_list_page.dart';

class StartPluginSummary extends StatelessWidget {
  const StartPluginSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final runtime = runtimeOf(context);
    return ListenableBuilder(
      listenable: runtime.repository,
      builder: (context, _) {
        final plugins = runtime.repository.all;
        final enabled = plugins.where((p) => p.enabled).length;
        return Card(
          child: ListTile(
            key: const Key('start-plugins'),
            leading: const Icon(Icons.extension_outlined),
            title: Text(l.startPagePlugins),
            subtitle: Text(plugins.isEmpty
                ? l.startPageNoPlugins
                : plugins.map((p) => p.manifest.name).join(', ') + (enabled == plugins.length ? '' : ' ($enabled/${plugins.length})')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PluginListPage())),
          ),
        );
      },
    );
  }
}

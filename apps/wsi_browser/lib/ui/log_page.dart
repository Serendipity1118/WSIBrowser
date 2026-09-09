// Log screen (F-04-5, F-11, P2-09): filter by plugin, clear, export.
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/generated/app_localizations.dart';
import '../runtime/log_sink.dart';
import '../runtime/runtime.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key, this.pluginId});
  final String? pluginId;

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  String? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.pluginId;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final runtime = runtimeOf(context);
    final ids = runtime.repository.all.map((p) => p.id).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.logsTitle),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            initialValue: _filter,
            onSelected: (v) => setState(() => _filter = v == '' ? null : v),
            itemBuilder: (_) => [
              PopupMenuItem(value: '', child: Text(l.logsFilterAll)),
              for (final id in ids) PopupMenuItem(value: id, child: Text(id)),
            ],
          ),
          IconButton(tooltip: l.logsShare, icon: const Icon(Icons.ios_share), onPressed: () => _share(runtime)),
          IconButton(tooltip: l.logsClear, icon: const Icon(Icons.delete_sweep_outlined), onPressed: () => runtime.logs.clear()),
        ],
      ),
      body: ListenableBuilder(
        listenable: runtime.logs,
        builder: (context, _) {
          final entries = runtime.logs.tail.where((e) => _filter == null || e.pluginId == _filter).toList().reversed.toList();
          if (entries.isEmpty) return Center(child: Text(l.logsEmpty));
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) => _LogTile(entries[i]),
          );
        },
      ),
    );
  }

  Future<void> _share(PluginRuntime runtime) async {
    final history = await runtime.logs.history(limit: 2000, pluginId: _filter);
    final text = history.reversed.map((e) => e.toString()).join('\n');
    await SharePlus.instance.share(ShareParams(text: text, subject: 'WSI Browser logs'));
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile(this.entry);
  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (entry.level) {
      'error' => theme.colorScheme.error,
      'warn' => Colors.orange,
      'info' => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurface,
    };
    final time = entry.createdAt.toLocal();
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return ListTile(
      dense: true,
      leading: Text('$hh:$mm:$ss', style: theme.textTheme.bodySmall),
      title: Text(entry.message, style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 13)),
      subtitle: entry.pluginId == null ? null : Text(entry.pluginId!, style: theme.textTheme.bodySmall),
    );
  }
}

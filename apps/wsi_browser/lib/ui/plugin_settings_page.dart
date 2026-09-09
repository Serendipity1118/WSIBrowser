// Auto-generated settings screen from plugin.json settingsSchema (F-10, P2-14).
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../runtime/manifest.dart';
import '../runtime/repository.dart';
import '../runtime/runtime.dart';

class PluginSettingsPage extends StatefulWidget {
  const PluginSettingsPage({super.key, required this.plugin});
  final InstalledPlugin plugin;

  @override
  State<PluginSettingsPage> createState() => _PluginSettingsPageState();
}

class _PluginSettingsPageState extends State<PluginSettingsPage> {
  Map<String, Object?>? _values;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await runtimeOf(context).settingsStore.getAll(widget.plugin.manifest);
    if (mounted) setState(() => _values = v);
  }

  Future<void> _set(String key, Object? value) async {
    final runtime = runtimeOf(context);
    await runtime.settingsStore.set(widget.plugin.manifest, key, value);
    await runtime.bridge.broadcast(widget.plugin.id, 'settings.change', {'key': key, 'value': value});
    if (mounted) setState(() => _values![key] = value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final schema = widget.plugin.manifest.settingsSchema;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsPluginTitle(widget.plugin.manifest.name))),
      body: _values == null
          ? const Center(child: CircularProgressIndicator())
          : schema.isEmpty
              ? Center(child: Text(l.settingsPluginEmpty))
              : ListView(children: [for (final s in schema) _tile(context, s)]),
    );
  }

  Widget _tile(BuildContext context, PluginSetting s) {
    final l = AppLocalizations.of(context);
    final value = _values![s.key];
    final title = Text(s.label ?? s.key);
    final subtitle = s.description == null ? null : Text(s.description!);
    switch (s.type) {
      case 'boolean':
        return SwitchListTile(
          key: Key('psetting-${s.key}'),
          title: title,
          subtitle: subtitle,
          value: value == true,
          onChanged: (v) => _set(s.key, v),
        );
      case 'select':
        final options = s.options ?? const [];
        return ListTile(
          key: Key('psetting-${s.key}'),
          title: title,
          subtitle: subtitle,
          trailing: DropdownButton<Object?>(
            value: options.contains(value) ? value : null,
            items: [for (final o in options) DropdownMenuItem(value: o, child: Text('$o'))],
            onChanged: (v) => _set(s.key, v),
          ),
        );
      case 'number':
      default:
        return ListTile(
          key: Key('psetting-${s.key}'),
          title: title,
          subtitle: Text([if (s.description != null) s.description!, '${value ?? ''}'].join('\n')),
          onTap: () async {
            final controller = TextEditingController(text: value == null ? '' : '$value');
            final result = await showDialog<String?>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: title,
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: s.type == 'number' ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text(l.dialogCancel)),
                  FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: Text(l.dialogOk)),
                ],
              ),
            );
            controller.dispose();
            if (result == null) return;
            if (s.type == 'number') {
              final n = num.tryParse(result);
              if (n != null) await _set(s.key, n);
            } else {
              await _set(s.key, result);
            }
          },
        );
    }
  }
}

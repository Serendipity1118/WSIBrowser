// Plugin management (F-02-3 .. F-02-6, P2-11): list, per-plugin toggle,
// global switch, current-host highlight, update badge, delete, settings, export.
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../app/app_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../runtime/importer.dart';
import '../runtime/repository.dart';
import '../runtime/runtime.dart';
import 'import_page.dart';
import 'log_page.dart';
import 'permission_labels.dart';
import 'plugin_settings_page.dart';

class PluginListPage extends StatelessWidget {
  const PluginListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final runtime = services.runtime;
    final l = AppLocalizations.of(context);
    final currentHost = services.tabs.active?.host ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.pluginsTitle),
        actions: [
          IconButton(
            tooltip: l.pluginCheckUpdates,
            icon: const Icon(Icons.update),
            onPressed: () => runtime.updateChecker.checkAll(force: true),
          ),
          IconButton(
            tooltip: l.logsTitle,
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LogPage())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('plugins-import'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => const ImportPage())),
        icon: const Icon(Icons.add),
        label: Text(l.pluginsImport),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([runtime.repository, services.settings]),
        builder: (context, _) {
          final plugins = runtime.repository.all;
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              SwitchListTile(
                key: const Key('plugins-global'),
                secondary: const Icon(Icons.power_settings_new),
                title: Text(l.pluginsGlobalToggle),
                subtitle: services.settings.wsiEnabled ? null : Text(l.pluginsGlobalToggleOff),
                value: services.settings.wsiEnabled,
                onChanged: services.settings.setWsiEnabled,
              ),
              if (currentHost.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(l.pluginsCurrentHost(currentHost), style: Theme.of(context).textTheme.labelLarge),
                ),
              if (plugins.isEmpty)
                Padding(padding: const EdgeInsets.all(32), child: Text(l.pluginsEmpty, textAlign: TextAlign.center)),
              for (final p in plugins)
                _PluginTile(plugin: p, highlighted: currentHost.isNotEmpty && runtime.repository.forHost(currentHost).contains(p)),
            ],
          );
        },
      ),
    );
  }
}

class _PluginTile extends StatelessWidget {
  const _PluginTile({required this.plugin, required this.highlighted});
  final InstalledPlugin plugin;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final runtime = runtimeOf(context);
    final theme = Theme.of(context);
    final m = plugin.manifest;
    return Card(
      key: Key('plugin-${m.id}'),
      color: highlighted ? theme.colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.extension),
            title: Row(
              children: [
                Flexible(child: Text(m.name, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Text(l.pluginVersion(m.version), style: theme.textTheme.bodySmall),
                if (plugin.hasUpdate) ...[
                  const SizedBox(width: 8),
                  Badge(label: Text(l.pluginUpdateAvailable(plugin.latestVersion!)), textColor: theme.colorScheme.onError),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.description.isNotEmpty) Text(m.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(m.domains.join(', '), style: theme.textTheme.bodySmall),
              ],
            ),
            trailing: Switch(
              key: Key('plugin-toggle-${m.id}'),
              value: plugin.enabled,
              onChanged: (v) => runtime.repository.setEnabled(m.id, v),
            ),
            onTap: () => _showDetails(context),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              if (plugin.hasUpdate)
                TextButton.icon(
                  icon: const Icon(Icons.system_update_alt),
                  label: Text(l.pluginUpdate),
                  onPressed: () => _update(context),
                ),
              if (m.settingsSchema.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.tune),
                  label: Text(l.pluginSettings),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PluginSettingsPage(plugin: plugin))),
                ),
              TextButton.icon(
                icon: const Icon(Icons.ios_share),
                label: Text(l.pluginExport),
                onPressed: () => _export(context),
              ),
              TextButton.icon(
                key: Key('plugin-delete-${m.id}'),
                icon: const Icon(Icons.delete_outline),
                label: Text(l.pluginDelete),
                onPressed: () => _delete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = plugin.manifest;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(m.name, style: Theme.of(ctx).textTheme.titleLarge),
            Text('${m.id}  ${l.pluginVersion(m.version)}  (format v${m.formatVersion})', style: Theme.of(ctx).textTheme.bodySmall),
            if (m.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(m.description)),
            const Divider(),
            if (m.author.isNotEmpty) ListTile(dense: true, title: Text(l.pluginAuthor), subtitle: Text(m.author)),
            ListTile(dense: true, title: Text(l.pluginDomains), subtitle: Text(m.domains.join(', '))),
            if (m.paths.isNotEmpty) ListTile(dense: true, title: const Text('paths'), subtitle: Text(m.paths.join(', '))),
            ListTile(dense: true, title: Text(l.pluginPermissions), subtitle: Text(m.permissions.map((p) => permissionLabel(l, p)).join('\n'))),
            ListTile(dense: true, title: Text(l.pluginInstalledAt), subtitle: Text(plugin.installedAt.toLocal().toString())),
            if (m.updateUrl != null) ListTile(dense: true, title: const Text('updateUrl'), subtitle: Text(m.updateUrl!)),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final runtime = runtimeOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.pluginDelete),
        content: Text(l.pluginDeleteConfirm(plugin.manifest.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.dialogCancel)),
          FilledButton(key: const Key('plugin-delete-confirm'), onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.pluginDelete)),
        ],
      ),
    );
    if (ok != true) return;
    await runtime.repository.delete(plugin.id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.pluginDeleted)));
  }

  Future<void> _update(BuildContext context) async {
    final runtime = runtimeOf(context);
    final l = AppLocalizations.of(context);
    final info = runtime.updateChecker.available[plugin.id] ?? await runtime.updateChecker.check(plugin.id);
    if (info == null || !context.mounted) return;
    try {
      final pkg = await runtime.importer.fromUrl(Uri.parse(info.zipUrl));
      if (!context.mounted) return;
      await showImportPreview(context, pkg);
    } on ImportException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.importFailed(e.toString()))));
    }
  }

  Future<void> _export(BuildContext context) async {
    final runtime = runtimeOf(context);
    final files = await runtime.repository.exportFiles(plugin.id);
    final archive = Archive();
    for (final e in files.entries) {
      archive.addFile(ArchiveFile(e.key, e.value.length, e.value));
    }
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}${plugin.id}-${plugin.manifest.version}.zip');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/zip')]));
  }
}

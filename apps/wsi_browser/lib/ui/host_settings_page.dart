// Host settings screen (F-10, P1-10).
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app/app_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../settings/host_settings.dart';
import 'backup_page.dart';

class HostSettingsPage extends StatelessWidget {
  const HostSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final settings = services.settings;
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            children: [
              _Section(l.settingsSectionBrowser),
              ListTile(
                key: const Key('setting-initial-url'),
                leading: const Icon(Icons.home_outlined),
                title: Text(l.settingsInitialUrl),
                subtitle: Text(settings.initialUrl.isEmpty ? l.settingsInitialUrlDesc : settings.initialUrl),
                onTap: () => _editText(
                  context,
                  title: l.settingsInitialUrl,
                  value: settings.initialUrl,
                  keyboardType: TextInputType.url,
                  onSave: settings.setInitialUrl,
                ),
              ),
              ListTile(
                key: const Key('setting-tab-limit'),
                leading: const Icon(Icons.tab_outlined),
                title: Text(l.settingsTabLimit),
                subtitle: Text('${settings.tabLimit}'),
                trailing: SizedBox(
                  width: 160,
                  child: Slider(
                    value: settings.tabLimit.toDouble(),
                    min: HostSettings.minTabLimit.toDouble(),
                    max: HostSettings.maxTabLimit.toDouble(),
                    divisions: HostSettings.maxTabLimit - HostSettings.minTabLimit,
                    label: '${settings.tabLimit}',
                    onChanged: (v) => settings.setTabLimit(v.round()),
                  ),
                ),
              ),
              ListTile(
                key: const Key('setting-external-links'),
                leading: const Icon(Icons.open_in_browser),
                title: Text(l.settingsExternalLinks),
                subtitle: Text(l.settingsExternalLinksDesc),
                trailing: DropdownButton<ExternalLinkMode>(
                  value: settings.externalLinks,
                  items: [
                    DropdownMenuItem(value: ExternalLinkMode.inApp, child: Text(l.settingsExternalLinksInApp)),
                    DropdownMenuItem(value: ExternalLinkMode.external, child: Text(l.settingsExternalLinksExternal)),
                  ],
                  onChanged: (v) => v == null ? null : settings.setExternalLinks(v),
                ),
              ),
              ListTile(
                key: const Key('setting-user-agent'),
                leading: const Icon(Icons.devices_outlined),
                title: Text(l.settingsUserAgent),
                subtitle: Text(settings.userAgent.isEmpty ? l.settingsUserAgentDesc : settings.userAgent, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => _editText(
                  context,
                  title: l.settingsUserAgent,
                  value: settings.userAgent,
                  onSave: settings.setUserAgent,
                ),
              ),
              ListTile(
                key: const Key('setting-clear-cookies'),
                leading: const Icon(Icons.cookie_outlined),
                title: Text(l.settingsClearCookies),
                subtitle: Text(l.settingsClearCookiesDesc),
                onTap: () => _clearCookies(context),
              ),
              _Section(l.settingsSectionPlugins),
              ListTile(
                key: const Key('setting-worker-tab-limit'),
                leading: const Icon(Icons.layers_outlined),
                title: Text(l.settingsWorkerTabLimit),
                subtitle: Text('${settings.workerTabLimit}  ${l.settingsWorkerTabLimitDesc}'),
                trailing: SizedBox(
                  width: 160,
                  child: Slider(
                    value: settings.workerTabLimit.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${settings.workerTabLimit}',
                    onChanged: (v) => settings.setWorkerTabLimit(v.round()),
                  ),
                ),
              ),
              SwitchListTile(
                key: const Key('setting-update-check'),
                secondary: const Icon(Icons.update_outlined),
                title: Text(l.settingsUpdateCheck),
                subtitle: Text(l.settingsUpdateCheckDesc),
                value: settings.updateCheck,
                onChanged: settings.setUpdateCheck,
              ),
              ListTile(
                key: const Key('setting-backup'),
                leading: const Icon(Icons.backup_outlined),
                title: Text(l.backupTitle),
                subtitle: Text(l.backupDesc, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BackupPage())),
              ),
              ListTile(
                key: const Key('setting-log-retention'),
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(l.settingsLogRetention),
                subtitle: Text('${settings.logRetention}'),
                onTap: () => _editText(
                  context,
                  title: l.settingsLogRetention,
                  value: '${settings.logRetention}',
                  keyboardType: TextInputType.number,
                  onSave: (v) async {
                    final n = int.tryParse(v);
                    if (n != null) await settings.setLogRetention(n);
                  },
                ),
              ),
              _Section(l.settingsSectionDeveloper),
              SwitchListTile(
                key: const Key('setting-developer-mode'),
                secondary: const Icon(Icons.code),
                title: Text(l.settingsDeveloperMode),
                subtitle: Text(l.settingsDeveloperModeDesc),
                value: settings.developerMode,
                onChanged: settings.setDeveloperMode,
              ),
              SwitchListTile(
                key: const Key('setting-web-inspector'),
                secondary: const Icon(Icons.bug_report_outlined),
                title: Text(l.settingsWebInspector),
                subtitle: Text(l.settingsWebInspectorDesc),
                value: settings.webInspector,
                onChanged: settings.developerMode ? settings.setWebInspector : null,
              ),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) => ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l.settingsAbout),
                  subtitle: Text(snap.hasData ? '${snap.data!.version} (${snap.data!.buildNumber})' : '...'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editText(
    BuildContext context, {
    required String title,
    required String value,
    required Future<void> Function(String) onSave,
    TextInputType? keyboardType,
  }) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: value);
    try {
      final result = await showDialog<String?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(controller: controller, keyboardType: keyboardType, autofocus: true, maxLines: keyboardType == TextInputType.number ? 1 : 3, minLines: 1),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(''), child: Text(l.settingsUseDefault)),
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text(l.dialogCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: Text(l.dialogOk)),
          ],
        ),
      );
      if (result == null) return;
      await onSave(result);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.settingsSaved)));
    } finally {
      controller.dispose();
    }
  }

  Future<void> _clearCookies(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsClearCookies),
        content: Text(l.settingsClearCookiesConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.dialogCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.dialogOk)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await AppScope.of(context).cookies.clearAll();
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.settingsClearCookiesDone)));
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}

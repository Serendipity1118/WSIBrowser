// Start page (F-01-1): URL input plus the way into the plugin list and settings.
// Rendered as a Flutter widget inside the tab (no WebView), so it costs nothing.
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.onOpen, required this.onSettings, this.onPlugins, this.pluginSummary});

  final ValueChanged<String> onOpen;
  final VoidCallback onSettings;
  final VoidCallback? onPlugins;

  /// Optional widget listing installed plugins (P2). Null shows the "no plugins" hint.
  final Widget? pluginSummary;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.extension, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(l.startPageTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(l.startPageSubtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 32),
                TextField(
                  key: const Key('start-url'),
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: l.startPageUrlHint,
                    prefixIcon: const Icon(Icons.public),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: l.startPageOpen,
                      onPressed: () => widget.onOpen(_controller.text),
                    ),
                  ),
                  onSubmitted: widget.onOpen,
                ),
                const SizedBox(height: 32),
                if (widget.pluginSummary != null)
                  widget.pluginSummary!
                else
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.extension_outlined),
                      title: Text(l.startPagePlugins),
                      subtitle: Text(l.startPageNoPlugins),
                      trailing: widget.onPlugins == null ? null : const Icon(Icons.chevron_right),
                      onTap: widget.onPlugins,
                    ),
                  ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l.startPageSettings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: widget.onSettings,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

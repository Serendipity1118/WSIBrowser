// Plugin import (F-02-1, F-02-2): file, URL, QR (share sheet / "open with"
// arrives through app_links as a file URI and lands in [showImportPreview]).
// Preview shows name, version, domains, permissions, asks consent for the
// sensitive ones, and warns before overwriting.
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../app/app_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../runtime/importer.dart';
import '../runtime/manifest.dart';
import '../runtime/runtime.dart';
import 'permission_labels.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key, this.initialUrl});

  /// Pre-filled URL (wsi://install?url=..., QR).
  final String? initialUrl;

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  late final TextEditingController _url = TextEditingController(text: widget.initialUrl ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.importTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            key: const Key('import-file'),
            onPressed: _busy ? null : _pickFile,
            icon: const Icon(Icons.folder_open),
            label: Text(l.importFromFile),
          ),
          const SizedBox(height: 24),
          Text(l.importFromUrl, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            key: const Key('import-url'),
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(hintText: l.importUrlHint, border: const OutlineInputBorder()),
            onSubmitted: (_) => _fromUrl(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('import-url-go'),
                  onPressed: _busy ? null : _fromUrl,
                  icon: const Icon(Icons.download),
                  label: Text(l.importFromUrl),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _scanQr,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.importFromQr),
                ),
              ),
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 24), child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    final file = result.firstOrNull;
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await _preview(() async => runtimeOf(context).importer.open(bytes));
  }

  Future<void> _fromUrl() async {
    final text = _url.text.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text);
    if (uri == null) return;
    await _preview(() => _download(uri));
  }

  Future<ImportPackage> _download(Uri uri) {
    final services = AppScope.of(context);
    var target = uri;
    if (uri.scheme == 'wsi') {
      final inner = uri.queryParameters['url'];
      if (inner == null) throw ImportException('wsi:// link has no url');
      target = Uri.parse(inner);
    }
    return runtimeOf(context).importer.fromUrl(target, allowInsecure: services.settings.developerMode);
  }

  Future<void> _scanQr() async {
    final value = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _QrScanPage()));
    if (value == null || !mounted) return;
    _url.text = value;
    await _fromUrl();
  }

  Future<void> _preview(Future<ImportPackage> Function() load) async {
    setState(() => _busy = true);
    try {
      final pkg = await load();
      if (!mounted) return;
      final installed = await showImportPreview(context, pkg);
      if (installed && mounted) Navigator.of(context).pop(true);
    } on ImportException catch (e) {
      _fail(e.toString());
    } catch (e) {
      _fail(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _fail(String reason) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).importFailed(reason))));
  }
}

/// Preview + consent + install. Returns true when installed.
Future<bool> showImportPreview(BuildContext context, ImportPackage pkg) async {
  final runtime = runtimeOf(context);
  final l = AppLocalizations.of(context);
  final existing = runtime.repository.byId(pkg.manifest.id);
  final sensitive = pkg.manifest.sensitivePermissions;
  var consent = sensitive.isEmpty;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l.importPreviewTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pkg.manifest.name, style: Theme.of(ctx).textTheme.titleLarge),
              Text(l.pluginVersion(pkg.manifest.version), style: Theme.of(ctx).textTheme.bodySmall),
              if (pkg.manifest.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(pkg.manifest.description),
              ],
              const SizedBox(height: 12),
              Text(l.pluginDomains, style: Theme.of(ctx).textTheme.labelLarge),
              Text(pkg.manifest.domains.join(', ')),
              const SizedBox(height: 12),
              Text(l.pluginPermissions, style: Theme.of(ctx).textTheme.labelLarge),
              for (final p in pkg.manifest.permissions) Text('・${permissionLabel(l, p)}'),
              if (existing != null) ...[
                const SizedBox(height: 12),
                Text(l.importOverwrite(existing.manifest.version), style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              ],
              if (sensitive.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l.importSensitive, style: Theme.of(ctx).textTheme.labelLarge),
                for (final p in sensitive) Text('・${permissionLabel(l, p)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  key: const Key('import-consent'),
                  contentPadding: EdgeInsets.zero,
                  value: consent,
                  onChanged: (v) => setState(() => consent = v ?? false),
                  title: Text(l.importConsent),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.dialogCancel)),
          FilledButton(
            key: const Key('import-install'),
            onPressed: consent ? () => Navigator.of(ctx).pop(true) : null,
            child: Text(l.importInstall),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return false;
  await runtime.repository.install(pkg);
  runtime.updateChecker.clear(pkg.manifest.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.importDone(pkg.manifest.name))));
  }
  return true;
}

/// Import from raw bytes (file opened from another app).
Future<bool> importBytes(BuildContext context, Uint8List bytes) async {
  final l = AppLocalizations.of(context);
  try {
    final pkg = runtimeOf(context).importer.open(bytes);
    if (!context.mounted) return false;
    return showImportPreview(context, pkg);
  } on ImportException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.importFailed(e.toString()))));
    return false;
  } on ManifestException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.importFailed(e.toString()))));
    return false;
  }
}

class _QrScanPage extends StatefulWidget {
  const _QrScanPage();

  @override
  State<_QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<_QrScanPage> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.importFromQr)),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                if (_done) return;
                for (final b in capture.barcodes) {
                  final v = b.rawValue;
                  if (v != null && (v.startsWith('wsi://') || v.startsWith('https://') || v.startsWith('http://'))) {
                    _done = true;
                    Navigator.of(context).pop(v);
                    return;
                  }
                }
              },
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: Text(l.qrScanHint, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

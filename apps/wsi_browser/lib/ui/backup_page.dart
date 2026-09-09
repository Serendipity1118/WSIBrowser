// Backup / restore screen (F-02-7, P5-10).
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/generated/app_localizations.dart';
import '../runtime/backup.dart';
import '../runtime/runtime.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.backupDesc),
          const SizedBox(height: 16),
          TextField(
            key: const Key('backup-password'),
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l.backupPassword, helperText: l.backupPasswordHint, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('backup-export'),
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.upload_file),
            label: Text(l.backupExport),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('backup-restore'),
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.download),
            label: Text(l.backupRestore),
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 24), child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await runtimeOf(context).backup.export(_password.text);
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-').substring(0, 19);
      final file = File('${dir.path}${Platform.pathSeparator}wsi-backup-$stamp.json');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')]));
      _snack(l.backupExported);
    } on BackupException catch (e) {
      _snack(l.backupFailed(e.message));
    } catch (e) {
      _snack(l.backupFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.backupRestore),
        content: Text(l.backupRestoreConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.dialogCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.dialogOk)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final picked = await FilePicker.pickFiles(type: FileType.any);
    final file = picked.firstOrNull;
    if (file == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final restored = await runtimeOf(context).backup.restore(bytes, _password.text);
      _snack(l.backupRestored(restored.length));
    } on BackupException catch (e) {
      _snack(l.backupFailed(e.message));
    } catch (e) {
      _snack(l.backupFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

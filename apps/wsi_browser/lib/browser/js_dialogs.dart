// JS dialogs (F-01-4): alert / confirm / prompt rendered as Flutter dialogs.
//
// [JsDialogInterceptor] is the hook P4 uses to forward dialogs of a worker
// tab to WSI.tabs.onDialog: it may answer without showing anything.
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../l10n/generated/app_localizations.dart';

enum JsDialogType { alert, confirm, prompt }

class JsDialogRequest {
  const JsDialogRequest({required this.type, required this.message, this.defaultValue, required this.origin});
  final JsDialogType type;
  final String message;
  final String? defaultValue;
  final String origin;
}

/// accept -> OK (with [value] for prompt), dismiss -> Cancel, show -> let the host show it.
class JsDialogAnswer {
  const JsDialogAnswer.accept([this.value]) : action = 'accept';
  const JsDialogAnswer.dismiss() : action = 'dismiss', value = null;
  const JsDialogAnswer.show() : action = 'show', value = null;
  final String action;
  final String? value;
}

typedef JsDialogInterceptor = Future<JsDialogAnswer> Function(JsDialogRequest request);

class JsDialogs {
  JsDialogs({required this.contextProvider});

  /// The BuildContext used to show dialogs (the browser screen sets it).
  BuildContext? Function() contextProvider;

  /// Set by the worker manager for tabs it owns (P4). Null = always show.
  JsDialogInterceptor? interceptor;

  Future<JsAlertResponse> onAlert(JsAlertRequest request) async {
    final req = JsDialogRequest(type: JsDialogType.alert, message: request.message ?? '', origin: _origin(request.url));
    final answer = await _answer(req);
    if (answer != null) {
      return JsAlertResponse(handledByClient: true, action: JsAlertResponseAction.CONFIRM);
    }
    await _showAlert(req);
    return JsAlertResponse(handledByClient: true, action: JsAlertResponseAction.CONFIRM);
  }

  Future<JsConfirmResponse> onConfirm(JsConfirmRequest request) async {
    final req = JsDialogRequest(type: JsDialogType.confirm, message: request.message ?? '', origin: _origin(request.url));
    final answer = await _answer(req);
    final ok = answer != null ? answer.action == 'accept' : await _showConfirm(req);
    return JsConfirmResponse(
      handledByClient: true,
      action: ok ? JsConfirmResponseAction.CONFIRM : JsConfirmResponseAction.CANCEL,
    );
  }

  Future<JsPromptResponse> onPrompt(JsPromptRequest request) async {
    final req = JsDialogRequest(
      type: JsDialogType.prompt,
      message: request.message ?? '',
      defaultValue: request.defaultValue,
      origin: _origin(request.url),
    );
    final answer = await _answer(req);
    final String? value = answer != null
        ? (answer.action == 'accept' ? (answer.value ?? request.defaultValue ?? '') : null)
        : await _showPrompt(req);
    return JsPromptResponse(
      handledByClient: true,
      action: value == null ? JsPromptResponseAction.CANCEL : JsPromptResponseAction.CONFIRM,
      value: value,
    );
  }

  /// Returns the interceptor's answer, or null when the dialog should be shown.
  Future<JsDialogAnswer?> _answer(JsDialogRequest req) async {
    final i = interceptor;
    if (i == null) return null;
    try {
      final a = await i(req);
      return a.action == 'show' ? null : a;
    } catch (_) {
      return null;
    }
  }

  static String _origin(WebUri? url) => url?.host ?? '';

  Future<void> _showAlert(JsDialogRequest req) async {
    final context = contextProvider();
    if (context == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.jsDialogTitle(req.origin)),
        content: SingleChildScrollView(child: Text(req.message)),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.dialogOk))],
      ),
    );
  }

  Future<bool> _showConfirm(JsDialogRequest req) async {
    final context = contextProvider();
    if (context == null || !context.mounted) return false;
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.jsDialogTitle(req.origin)),
        content: SingleChildScrollView(child: Text(req.message)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.dialogCancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.dialogOk)),
        ],
      ),
    );
    return result ?? false;
  }

  Future<String?> _showPrompt(JsDialogRequest req) async {
    final context = contextProvider();
    if (context == null || !context.mounted) return null;
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: req.defaultValue ?? '');
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.jsDialogTitle(req.origin)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(req.message),
              const SizedBox(height: 12),
              TextField(controller: controller, autofocus: true, onSubmitted: (v) => Navigator.of(ctx).pop(v)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text(l.dialogCancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: Text(l.dialogOk)),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}

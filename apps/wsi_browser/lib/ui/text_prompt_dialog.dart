// A dialog with one text field, used by JS prompt() and the settings pages.
//
// The dialog owns its TextEditingController. Disposing a controller right
// after `showDialog` returns (the old pattern) breaks the widget tree: the
// dialog is still mounted for its pop transition and the TextField touches
// the disposed controller when it loses focus / the keyboard closes, which
// ends in the red "'_dependents.isEmpty': is not true" screen.
import 'package:flutter/material.dart';

/// Shows [TextPromptDialog]; resolves to the entered text, or null on cancel.
Future<String?> showTextPromptDialog(
  BuildContext context, {
  required Widget title,
  String? message,
  String initialValue = '',
  required String okLabel,
  required String cancelLabel,
  TextInputType? keyboardType,
  int minLines = 1,
  int maxLines = 1,
  List<Widget> Function(BuildContext ctx)? leadingActions,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => TextPromptDialog(
      title: title,
      message: message,
      initialValue: initialValue,
      okLabel: okLabel,
      cancelLabel: cancelLabel,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      leadingActions: leadingActions,
    ),
  );
}

class TextPromptDialog extends StatefulWidget {
  const TextPromptDialog({
    super.key,
    required this.title,
    this.message,
    this.initialValue = '',
    required this.okLabel,
    required this.cancelLabel,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.leadingActions,
  });

  final Widget title;
  final String? message;
  final String initialValue;
  final String okLabel;
  final String cancelLabel;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  /// Extra buttons placed before Cancel / OK (e.g. "use default").
  final List<Widget> Function(BuildContext ctx)? leadingActions;

  @override
  State<TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<TextPromptDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      key: const Key('text-prompt-field'),
      controller: _controller,
      autofocus: true,
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
    );
    return AlertDialog(
      title: widget.title,
      content: widget.message == null
          ? field
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(widget.message!), const SizedBox(height: 12), field],
            ),
      actions: [
        ...?widget.leadingActions?.call(context),
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(widget.cancelLabel)),
        FilledButton(key: const Key('text-prompt-ok'), onPressed: _submit, child: Text(widget.okLabel)),
      ],
    );
  }
}

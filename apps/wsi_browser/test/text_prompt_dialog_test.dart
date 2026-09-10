import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wsi_browser/ui/text_prompt_dialog.dart';

void main() {
  Widget host(void Function(BuildContext) onTap) => MaterialApp(
    home: Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => onTap(context), child: const Text('open')))),
  );

  testWidgets('OK returns the edited text and the dialog survives its pop transition', (tester) async {
    String? result;
    bool done = false;
    await tester.pumpWidget(host((context) async {
      result = await showTextPromptDialog(context, title: const Text('t'), message: 'm', initialValue: 'old', okLabel: 'OK', cancelLabel: 'Cancel');
      done = true;
    }));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('m'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('text-prompt-field')), 'new');
    await tester.tap(find.byKey(const Key('text-prompt-ok')));
    await tester.pump(); // the future completes while the dialog is still animating out
    expect(done, isTrue);
    expect(result, 'new');
    // keyboard closes / focus moves while the dialog is still mounted
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('text-prompt-field')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancel returns null; leading actions can pop their own value', (tester) async {
    final results = <String?>[];
    await tester.pumpWidget(host((context) async {
      results.add(await showTextPromptDialog(
        context,
        title: const Text('t'),
        okLabel: 'OK',
        cancelLabel: 'Cancel',
        leadingActions: (ctx) => [TextButton(onPressed: () => Navigator.of(ctx).pop(''), child: const Text('Default'))],
      ));
    }));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    expect(results, [null, '']);
    expect(tester.takeException(), isNull);
  });
}

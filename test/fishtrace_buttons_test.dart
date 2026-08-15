import 'dart:async';

import 'package:fishtrace/core/widgets/buttons/fishtrace_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary button shows progress and blocks duplicate async taps', (
    tester,
  ) async {
    final request = Completer<void>();
    var calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FishTracePrimaryButton(
            label: 'Submit',
            onPressed: () async {
              calls++;
              await request.future;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    request.complete();
    await tester.pump();

    expect(find.text('Submit'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

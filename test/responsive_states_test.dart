import 'package:fishtrace/core/widgets/states/fishtrace_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty state remains usable in a short viewport', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 142,
            child: EmptyState(
              title: 'No records',
              message: 'Try changing the current filters.',
              actionLabel: 'Try again',
              onAction: _noop,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('No records'), findsOneWidget);
  });
}

void _noop() {}

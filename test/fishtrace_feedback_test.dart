import 'package:fishtrace/app/theme/fishtrace_theme.dart';
import 'package:fishtrace/core/widgets/overlays/fishtrace_overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('feedback exposes tone, message, and live-region semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => FishTraceFeedback.success(
                context,
                'Batch saved successfully',
              ),
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Batch saved successfully'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label == 'Success: Batch saved successfully',
      ),
      findsOneWidget,
    );
  });

  testWidgets('new feedback replaces the current message', (tester) async {
    late BuildContext feedbackContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              feedbackContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    FishTraceFeedback.info(feedbackContext, 'First message');
    await tester.pump();
    FishTraceFeedback.error(feedbackContext, 'Second message');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('First message'), findsNothing);
    expect(find.text('Second message'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('feedback action is available and invokes its callback', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => FishTraceFeedback.error(
                context,
                'Upload failed',
                actionLabel: 'Retry',
                onAction: () => retried = true,
              ),
              child: const Text('Upload'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SnackBarAction));

    expect(retried, isTrue);
  });
}

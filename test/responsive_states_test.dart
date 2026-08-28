import 'package:fishtrace/app/theme/fishtrace_theme.dart';
import 'package:fishtrace/core/widgets/states/fishtrace_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/audit_screen_catalog.dart';
import 'helpers/test_dependencies.dart';

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

  // Covers the primary screens at a compact phone width and a tablet width.
  // Flutter reports RenderFlex and text overflows as test exceptions.
  for (final size in <Size>[const Size(320, 568), const Size(768, 1024)]) {
    for (final screen in auditScreens) {
      testWidgets('${screen.name} has no layout overflow at $size', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(Get.reset);
        registerTestDependencies(role: screen.role);

        await tester.pumpWidget(
          MaterialApp(theme: buildFishTraceTheme(), home: screen.builder()),
        );
        await tester.pump(const Duration(milliseconds: 350));

        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final screen in auditScreens.where(
    (screen) => const {
      '06_profile_settings',
      'fisher_dashboard',
      'fisher_batch_details',
      'processor_dashboard',
      'transporter_dashboard',
      'retailer_dashboard',
      'transporter_delivery',
    }.contains(screen.name),
  )) {
    testWidgets('${screen.name} supports 200% text and dark mode', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(Get.reset);
      registerTestDependencies(role: screen.role);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildFishTraceTheme(brightness: Brightness.dark),
          home: screen.builder(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));

      expect(tester.takeException(), isNull);
    });
  }
}

void _noop() {}

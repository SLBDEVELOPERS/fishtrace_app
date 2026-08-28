import 'package:fishtrace/app/theme/fishtrace_theme.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/retailer/presentation/controllers/retailer_controller.dart';
import 'package:fishtrace/features/transporter/presentation/controllers/transporter_controller.dart';
import 'package:fishtrace/features/transporter/presentation/screens/batch_device_vehicle_screens.dart';
import 'package:fishtrace/features/transporter/presentation/screens/checklist_monitoring_delivery_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/test_dependencies.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('incomplete pre-trip checklist is blocked', (tester) async {
    registerTestDependencies(role: UserRole.transporter);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = Get.find<TransporterController>();
    await controller.load();
    controller.selectedTrip.value = controller.trips[1];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: const PreTripChecklistScreen(),
      ),
    );
    await tester.tap(find.text('Complete Checklist'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('mandatory'), findsOneWidget);
  });

  testWidgets('manual batch entry validates and exposes Add to Trip', (
    tester,
  ) async {
    registerTestDependencies(role: UserRole.transporter);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = Get.find<TransporterController>();
    await controller.load();
    controller.selectedTrip.value = controller.trips[1];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: const TransportScanBatchScreen(),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'e.g. FTB-2026-001'),
      'BATCH-BAT-1001',
    );
    await tester.ensureVisible(find.byTooltip('Validate batch code'));
    await tester.tap(find.byTooltip('Validate batch code'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Accept Handover & Add to Trip'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Valid'), findsOneWidget);
    expect(find.text('Accept Handover & Add to Trip'), findsOneWidget);
  });

  test(
    'retail sale cannot exceed stock and valid sale updates stock',
    () async {
      registerTestDependencies(role: UserRole.retailer);
      final controller = Get.find<RetailerController>();
      await controller.load();
      final before = controller.selectedProduct.value!.stockKg;
      expect(
        controller.validateSale(
          controller.selectedProduct.value!.availablePackages + 1,
        ),
        isNotNull,
      );
      await controller.recordSale(1, 20, 'TEST');
      expect(controller.selectedProduct.value!.stockKg, before - .1);
      expect(controller.sales.first.quantityKg, .1);
    },
  );
}

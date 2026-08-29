import 'package:fishtrace/app/theme/fishtrace_theme.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/retailer/presentation/controllers/retailer_controller.dart';
import 'package:fishtrace/features/processor/presentation/controllers/processor_controller.dart';
import 'package:fishtrace/features/processor/presentation/screens/processor_dashboard_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/split_pack_screen.dart';
import 'package:fishtrace/features/transporter/presentation/controllers/transporter_controller.dart';
import 'package:fishtrace/features/transporter/presentation/screens/batch_device_vehicle_screens.dart';
import 'package:fishtrace/features/transporter/presentation/screens/checklist_monitoring_delivery_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets(
    'processor Split / Pack action opens the completed batch picker',
    (tester) async {
      registerTestDependencies(role: UserRole.processor);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final controller = Get.find<ProcessorController>();
      await controller.load();
      controller.selectedBatch.value = null;
      final completed = controller.history.firstWhere(
        (job) => job.status == BatchStatus.completed,
      );
      final router = GoRouter(
        initialLocation: '/processor/dashboard',
        routes: [
          GoRoute(
            path: '/processor/dashboard',
            builder: (_, _) => const ProcessorDashboardScreen(),
          ),
          GoRoute(
            path: '/processor/split-pack',
            builder: (_, _) => const SplitPackScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(theme: buildFishTraceTheme(), routerConfig: router),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Split / Pack'));
      await tester.pumpAndSettle();

      expect(find.text('Select a completed batch'), findsOneWidget);
      expect(find.text(completed.batchLabel), findsOneWidget);

      await tester.tap(find.text(completed.batchLabel));
      await tester.pumpAndSettle();
      expect(controller.selectedBatch.value?.id, completed.batchId);
      expect(find.text('Select a completed batch'), findsNothing);
    },
  );

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

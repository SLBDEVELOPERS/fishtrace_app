import 'package:fishtrace/app/router/app_router.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/authentication/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/test_dependencies.dart';

void main() {
  tearDown(Get.reset);

  const roleRoutes = <UserRole, List<String>>{
    UserRole.fisher: [
      AppRoute.fisher,
      AppRoute.fisherBoats,
      AppRoute.fisherStartTrip,
      AppRoute.fisherActiveTrip,
      AppRoute.fisherAddCatch,
      AppRoute.fisherCatchHistory,
      AppRoute.fisherCreateBatch,
      AppRoute.fisherBatchDetails,
    ],
    UserRole.processor: [
      AppRoute.processor,
      AppRoute.processorScanBatch,
      AppRoute.processorIntake,
      AppRoute.processorProcessing,
      AppRoute.processorInspection,
      AppRoute.processorSplitPack,
      AppRoute.processorProcessedDetails,
      AppRoute.processorHistory,
    ],
    UserRole.transporter: [
      AppRoute.transporter,
      AppRoute.transporterTrips,
      AppRoute.transporterTripDetails,
      AppRoute.transporterAddBatch,
      AppRoute.transporterDevices,
      AppRoute.transporterVehicles,
      AppRoute.transporterChecklist,
      AppRoute.transporterMonitoring,
      AppRoute.transporterDelivery,
      AppRoute.transporterCreateTrip,
      AppRoute.transporterEditTrip,
    ],
    UserRole.retailer: [
      AppRoute.retailer,
      AppRoute.retailerReceive,
      AppRoute.retailerReceivedDetails,
      AppRoute.retailerInventory,
      AppRoute.retailerSales,
      AppRoute.retailerAlerts,
      AppRoute.retailerReports,
    ],
  };

  test('catalogue contains exactly 34 role routes', () {
    expect(roleRoutes.values.expand((routes) => routes), hasLength(34));
  });

  for (final entry in roleRoutes.entries) {
    testWidgets('every ${entry.key.name} route is reachable', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      registerTestDependencies(role: entry.key);
      final router = buildRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(useMaterial3: true),
        ),
      );
      for (final route in entry.value) {
        router.go(route);
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          route,
          reason: '$route did not resolve',
        );
        expect(find.byType(Scaffold), findsWidgets);
        expect(
          tester.takeException(),
          isNull,
          reason: '$route failed to render',
        );
      }
    });
  }

  testWidgets('unauthenticated role routes redirect to login', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    registerTestDependencies();
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go(AppRoute.processorIntake);
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoute.login);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a role cannot enter another role route', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    registerTestDependencies(role: UserRole.fisher);
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go(AppRoute.processorIntake);
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoute.fisher);
    expect(find.text('Batch Intake Details'), findsNothing);
  });
}

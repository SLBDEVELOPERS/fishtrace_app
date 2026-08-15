import 'package:fishtrace/app/theme/fishtrace_theme.dart';
import 'package:fishtrace/core/widgets/fishtrace_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('required domain components render at 390x844', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FishBatchCard(
                batchId: 'BATCH-001',
                species: 'Yellowfin Tuna',
                weight: '125.4 kg',
                status: 'Verified',
              ),
              const CatchCard(
                species: 'Indian Mackerel',
                weight: '25.4 kg',
                metadata: 'May 21 • 08:15 AM',
                status: 'Verified',
              ),
              const TripCard(
                tripId: 'TRIP-001',
                origin: 'Kochi Port',
                destination: 'Salem Hub',
                status: 'In Progress',
                details: {'Batches': '3', 'ETA': '10:30 AM'},
              ),
              const VehicleCard(
                registration: 'TN 07 AB 1234',
                vehicleType: 'Refrigerated truck',
                status: 'Active',
              ),
              const DeviceCard(
                deviceName: 'Reefer Sensor 23',
                deviceCode: 'FT-TH-10023',
                deviceType: 'Temperature & humidity',
                status: 'Connected',
                battery: 98,
              ),
              const InventoryProductCard(
                name: 'Yellowfin Tuna',
                scientificName: 'Thunnus albacares',
                stock: '125.4 kg',
                expiry: 'May 28, 2024',
                status: 'In Stock',
              ),
              const TemperatureCard(current: 2.1, minimum: 1.8, maximum: 2.3),
              const SensorMetricCard(
                label: 'Humidity',
                value: '62%',
                icon: Icons.water_drop_outlined,
                sparkline: [58, 60, 59, 62],
              ),
              const FishTraceCard(
                child: Timeline(
                  entries: [
                    TimelineEntry(title: 'Accepted', subtitle: '08:40 AM'),
                    TimelineEntry(
                      title: 'Delivered',
                      subtitle: 'Pending',
                      completed: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(FishBatchCard), findsOneWidget);
    expect(find.byType(CatchCard), findsOneWidget);
    expect(find.byType(TripCard), findsOneWidget);
    expect(find.byType(VehicleCard), findsOneWidget);
    expect(find.byType(DeviceCard), findsOneWidget);
    expect(find.byType(InventoryProductCard), findsOneWidget);
    expect(find.byType(TemperatureCard), findsOneWidget);
    expect(find.byType(SensorMetricCard), findsOneWidget);
    expect(find.byType(Timeline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('required overlay and recovery components render', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFishTraceTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                FilterBottomSheet(
                  title: 'Filters',
                  onApply: () {},
                  child: const Text('Filter options'),
                ),
                ConfirmationBottomSheet(
                  title: 'Confirm action',
                  message: 'This operation changes the record.',
                  confirmLabel: 'Confirm',
                  onConfirm: () {},
                ),
                const SuccessDialog(
                  title: 'Saved',
                  message: 'The record was queued.',
                ),
                PermissionDialog(
                  permissionName: 'Camera',
                  message: 'Camera access is required.',
                  onOpenSettings: () {},
                ),
                ErrorState(
                  title: 'Could not load',
                  message: 'Check the connection.',
                  onRetry: () {},
                ),
                RetryPanel(message: 'Upload failed.', onRetry: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(FilterBottomSheet), findsOneWidget);
    expect(find.byType(ConfirmationBottomSheet), findsOneWidget);
    expect(find.byType(SuccessDialog), findsOneWidget);
    expect(find.byType(PermissionDialog), findsOneWidget);
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.byType(RetryPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

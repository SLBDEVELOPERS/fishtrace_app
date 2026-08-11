import '../../../../core/models/models.dart';
import '../../domain/entities/transporter_entities.dart';
import '../../domain/repositories/transporter_repository.dart';

class MockTransporterRepository implements TransporterRepository {
  @override
  Future<HandoverBatch?> findHandoverBatch(String scannedValue) async {
    final batches = await getHandoverBatches();
    for (final batch in batches) {
      if (batch.matchesScan(scannedValue)) return batch;
    }
    return null;
  }

  @override
  Future<List<TransporterTripView>> getTrips() async => [
    TransporterTripView(
      id: 'TRP-2024-05-21',
      origin: 'Kochi Port',
      destination: 'Salem Hub',
      status: TripStatus.inProgress,
      eta: DateTime(2024, 5, 21, 10, 30),
      distanceKm: 125.4,
      batchCount: 3,
      productTemperature: 2.1,
      driver: 'Alex Johnson',
      vehicleId: 'TN 07 AB 1234',
    ),
    TransporterTripView(
      id: 'TRP-2024-05-22',
      origin: 'Salem Hub',
      destination: 'Bengaluru',
      status: TripStatus.upcoming,
      eta: DateTime(2024, 5, 22, 8, 45),
      distanceKm: 215,
      batchCount: 2,
      productTemperature: 2.0,
      driver: 'Maya Singh',
      vehicleId: 'TN 09 CD 8421',
    ),
    TransporterTripView(
      id: 'TRP-2024-05-23',
      origin: 'Bengaluru',
      destination: 'Hyderabad',
      status: TripStatus.upcoming,
      eta: DateTime(2024, 5, 23, 9, 30),
      distanceKm: 320.5,
      batchCount: 2,
      productTemperature: 2.2,
      driver: 'Ravi Kumar',
      vehicleId: 'KA 01 MH 5320',
    ),
    TransporterTripView(
      id: 'TRP-2024-05-20',
      origin: 'Chennai Port',
      destination: 'Kochi Port',
      status: TripStatus.completed,
      eta: DateTime(2024, 5, 20, 16),
      distanceKm: 512.6,
      batchCount: 4,
      productTemperature: 2.1,
      driver: 'Alex Johnson',
      vehicleId: 'TN 07 AB 1234',
    ),
  ];

  @override
  Future<List<TransportVehicleView>> getVehicles() async => const [
    TransportVehicleView(
      id: 'VEH-001',
      registration: 'TN 07 AB 1234',
      type: 'Refrigerated Truck',
      refrigerationCategory: 'Category A',
      capacityTonnes: 1.2,
      reeferUnit: 'Carrier Supra 550',
      minTemperature: -20,
      maxTemperature: 20,
      driver: 'Alex Johnson',
    ),
    TransportVehicleView(
      id: 'VEH-002',
      registration: 'TN 09 CD 8421',
      type: 'Refrigerated Van',
      refrigerationCategory: 'Category B',
      capacityTonnes: .8,
      reeferUnit: 'Thermo King V-500',
      minTemperature: -10,
      maxTemperature: 15,
      driver: 'Maya Singh',
    ),
  ];

  @override
  Future<List<TransportDeviceView>> getDevices() async => [
    TransportDeviceView(
      id: 'FT-TH-10023',
      capabilities: const ['Temperature', 'Humidity'],
      status: DeviceStatus.online,
      battery: 98,
      signal: 94,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    TransportDeviceView(
      id: 'FT-TH-10024',
      capabilities: const ['Temperature', 'Humidity'],
      status: DeviceStatus.online,
      battery: 93,
      signal: 88,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    TransportDeviceView(
      id: 'FT-LOC-20011',
      capabilities: const ['GPS'],
      status: DeviceStatus.online,
      battery: 97,
      signal: 91,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    TransportDeviceView(
      id: 'FT-TH-10025',
      capabilities: const ['Temperature', 'Humidity'],
      status: DeviceStatus.assigned,
      battery: 86,
      signal: 82,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
      assignedTripId: 'TRP-OTHER-ACTIVE',
    ),
  ];

  @override
  Future<List<HandoverBatch>> getHandoverBatches() async => const [
    HandoverBatch(
      id: 'BATCH-BAT-1001',
      species: 'Yellowfin Tuna',
      weightKg: 125.4,
    ),
    HandoverBatch(
      id: 'BATCH-BAT-1002',
      species: 'Indian Mackerel',
      weightKg: 98.7,
    ),
    HandoverBatch(id: 'BATCH-BAT-1003', species: 'Seer Fish', weightKg: 76.3),
  ];

  @override
  Future<List<TransportAlertView>> getAlerts(String tripId) async => [
    TransportAlertView(
      id: 'ALERT-TEMP-001',
      type: 'HIGH_TEMPERATURE',
      severity: AlertSeverity.critical,
      status: 'OPEN',
      measuredValue: 4.3,
      thresholdValue: 4,
      lastDetectedAt: DateTime.now().toUtc().subtract(
        const Duration(minutes: 4),
      ),
    ),
    TransportAlertView(
      id: 'ALERT-BATTERY-001',
      type: 'LOW_BATTERY',
      severity: AlertSeverity.warning,
      status: 'OPEN',
      measuredValue: 18,
      thresholdValue: 20,
      lastDetectedAt: DateTime.now().toUtc().subtract(
        const Duration(minutes: 9),
      ),
    ),
  ];
}

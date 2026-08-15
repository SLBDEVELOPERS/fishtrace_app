import '../../../../core/models/models.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/transporter_entities.dart';

class TransportTripDto {
  const TransportTripDto(this.json);
  final Map<String, Object?> json;
  factory TransportTripDto.fromJson(Map<String, Object?> json) =>
      TransportTripDto(json);
  TransporterTripView toDomain() {
    final batches = ApiData.listValue(json, 'batches');
    final assignment = _map(ApiData.value(json, 'activeAssignment'));
    final checklist = _map(ApiData.value(json, 'checklist'));
    final checklistItems = ApiData.listValue(checklist, 'items');
    return TransporterTripView(
      id: ApiData.string(json, 'id'),
      tripCode: ApiData.string(json, 'tripCode'),
      origin: ApiData.string(json, 'origin'),
      destination: ApiData.string(json, 'destination'),
      status: _enum(TripStatus.values, switch (ApiData.string(json, 'status')) {
        'ACTIVE' => TripStatus.inProgress.name,
        'DRAFT' || 'READY' => TripStatus.upcoming.name,
        final value => value,
      }, TripStatus.upcoming),
      eta: ApiData.date(json, 'scheduledAt', ApiData.date(json, 'startedAt')),
      distanceKm: ApiData.number(json, 'estimatedDistanceKm'),
      batchCount: batches.length,
      productTemperature: _nullableNumber(json, 'productTemperatureCelsius'),
      driver: ApiData.string(json, 'driverName'),
      vehicleId: ApiData.string(json, 'vehicleId'),
      batches: batches
          .map(_map)
          .map((batch) => HandoverBatchDto(batch).toDomain())
          .toList(growable: false),
      completedChecklistItems: checklistItems
          .map(_map)
          .where((item) => ApiData.boolean(item, 'isCompleted'))
          .map((item) => _checklistLabel(ApiData.string(item, 'itemKey')))
          .where((label) => label.isNotEmpty)
          .toSet(),
      assignedDeviceId: ApiData.value(assignment, 'iotDeviceId')?.toString(),
      deviceAssignmentSynced:
          ApiData.string(assignment, 'firebaseSyncStatus') == 'SYNCED',
      deliveryConfirmed: ApiData.value(json, 'deliveryConfirmation') != null,
      arrivedAt: _nullableDate(json, 'arrivedAt'),
      originLatitude: _nullableNumber(json, 'originLatitude'),
      originLongitude: _nullableNumber(json, 'originLongitude'),
      destinationLatitude: _nullableNumber(json, 'destinationLatitude'),
      destinationLongitude: _nullableNumber(json, 'destinationLongitude'),
    );
  }
}

String _checklistLabel(String key) =>
    const {
      'vehicle_inspected': 'Vehicle safety inspection',
      'refrigeration_operational': 'Refrigeration system',
      'cargo_secured': 'Cargo and batch seals',
      'device_online': 'IoT device online',
      'doors_sealed': 'Cargo doors sealed',
    }[key] ??
    '';

class VehicleDto {
  const VehicleDto(this.json);
  final Map<String, Object?> json;
  factory VehicleDto.fromJson(Map<String, Object?> json) => VehicleDto(json);
  TransportVehicleView toDomain() => TransportVehicleView(
    id: ApiData.string(json, 'id'),
    name: ApiData.string(json, 'name'),
    registration: ApiData.string(json, 'registrationNumber'),
    type: ApiData.string(json, 'vehicleType'),
    refrigerationCategory: ApiData.string(json, 'refrigerationCategory'),
    capacityTonnes: ApiData.number(json, 'capacityTonnes'),
    reeferUnit: ApiData.string(json, 'reeferUnit'),
    minTemperature: ApiData.number(json, 'minTemperatureCelsius'),
    maxTemperature: ApiData.number(json, 'maxTemperatureCelsius'),
    driver: ApiData.string(json, 'defaultDriverName'),
    active: ApiData.boolean(json, 'isActive', true),
  );
}

class IoTDeviceDto {
  const IoTDeviceDto(this.json);
  final Map<String, Object?> json;
  factory IoTDeviceDto.fromJson(Map<String, Object?> json) =>
      IoTDeviceDto(json);
  TransportDeviceView toDomain() => TransportDeviceView(
    id: ApiData.string(json, 'id'),
    deviceCode: ApiData.string(json, 'deviceCode'),
    displayName: ApiData.string(json, 'displayName'),
    capabilities: [
      if (ApiData.boolean(json, 'supportsProductTemperature')) 'Temperature',
      if (ApiData.boolean(json, 'supportsAirTemperature')) 'Air temperature',
      if (ApiData.boolean(json, 'supportsHumidity')) 'Humidity',
      if (ApiData.boolean(json, 'supportsGps')) 'GPS',
      if (ApiData.boolean(json, 'supportsDoorSensor')) 'Door sensor',
    ],
    status: _enum(DeviceStatus.values, switch (ApiData.string(json, 'status')) {
      'ACTIVE' => DeviceStatus.online.name,
      'INACTIVE' => DeviceStatus.offline.name,
      final value => value,
    }, DeviceStatus.offline),
    battery: ApiData.number(json, 'batteryPercentage'),
    signal: ApiData.number(json, 'signalStrength'),
    lastSeen: ApiData.date(json, 'lastSeen'),
    assignedTripId: ApiData.value(json, 'assignedTripId')?.toString(),
  );
}

class HandoverBatchDto {
  const HandoverBatchDto(this.json);
  final Map<String, Object?> json;
  factory HandoverBatchDto.fromJson(Map<String, Object?> json) =>
      HandoverBatchDto(json);
  HandoverBatch toDomain() {
    final speciesData = json['species'] is Map
        ? (json['species'] as Map).cast<String, Object?>()
        : const <String, Object?>{};
    final qrCode = json['qr_code'] is Map
        ? (json['qr_code'] as Map).cast<String, Object?>()
        : const <String, Object?>{};
    return HandoverBatch(
      id: ApiData.string(json, 'id'),
      batchCode: ApiData.string(json, 'batchCode'),
      traceUrl: ApiData.string(qrCode, 'traceUrl'),
      species: ApiData.string(speciesData, 'commonName'),
      weightKg: ApiData.number(json, 'totalWeightKg'),
    );
  }
}

class TransportAlertDto {
  const TransportAlertDto(this.json);
  final Map<String, Object?> json;
  factory TransportAlertDto.fromJson(Map<String, Object?> json) =>
      TransportAlertDto(json);

  TransportAlertView toDomain() => TransportAlertView(
    id: ApiData.string(json, 'id'),
    type: ApiData.string(json, 'type'),
    severity: _enum(
      AlertSeverity.values,
      ApiData.string(json, 'severity'),
      AlertSeverity.info,
    ),
    status: ApiData.string(json, 'status'),
    measuredValue: _nullableNumber(json, 'measuredValue'),
    thresholdValue: _nullableNumber(json, 'thresholdValue'),
    lastDetectedAt: ApiData.date(json, 'lastDetectedAt'),
  );
}

double? _nullableNumber(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

DateTime? _nullableDate(Map<String, Object?> json, String key) {
  final value = ApiData.value(json, key);
  return value == null ? null : DateTime.tryParse(value.toString());
}

T _enum<T extends Enum>(List<T> values, String raw, T fallback) {
  String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  final normalized = normalize(raw);
  return values.firstWhere(
    (value) => normalize(value.name) == normalized,
    orElse: () => fallback,
  );
}

Map<String, Object?> _map(Object? value) =>
    value is Map ? value.cast<String, Object?>() : const {};

import '../../../../core/models/models.dart';

class TransporterTripView {
  const TransporterTripView({
    required this.id,
    required this.origin,
    required this.destination,
    required this.status,
    required this.eta,
    required this.distanceKm,
    required this.batchCount,
    this.productTemperature,
    required this.driver,
    required this.vehicleId,
    this.batches = const [],
    this.completedChecklistItems = const {},
    this.assignedDeviceId,
    this.deviceAssignmentSynced = false,
    this.deliveryConfirmed = false,
    this.arrivedAt,
  });

  final String id;
  final String origin;
  final String destination;
  final TripStatus status;
  final DateTime eta;
  final double distanceKm;
  final int batchCount;
  final double? productTemperature;
  final String driver;
  final String vehicleId;
  final List<HandoverBatch> batches;
  final Set<String> completedChecklistItems;
  final String? assignedDeviceId;
  final bool deviceAssignmentSynced;
  final bool deliveryConfirmed;
  final DateTime? arrivedAt;

  TransporterTripView copyWith({TripStatus? status, DateTime? arrivedAt}) =>
      TransporterTripView(
        id: id,
        origin: origin,
        destination: destination,
        status: status ?? this.status,
        eta: eta,
        distanceKm: distanceKm,
        batchCount: batchCount,
        productTemperature: productTemperature,
        driver: driver,
        vehicleId: vehicleId,
        batches: batches,
        completedChecklistItems: completedChecklistItems,
        assignedDeviceId: assignedDeviceId,
        deviceAssignmentSynced: deviceAssignmentSynced,
        deliveryConfirmed: deliveryConfirmed,
        arrivedAt: arrivedAt ?? this.arrivedAt,
      );
}

class TransportVehicleView {
  const TransportVehicleView({
    required this.id,
    required this.registration,
    required this.type,
    required this.refrigerationCategory,
    required this.capacityTonnes,
    required this.reeferUnit,
    required this.minTemperature,
    required this.maxTemperature,
    required this.driver,
    this.active = true,
  });

  final String id;
  final String registration;
  final String type;
  final String refrigerationCategory;
  final double capacityTonnes;
  final String reeferUnit;
  final double minTemperature;
  final double maxTemperature;
  final String driver;
  final bool active;
}

class TransportDeviceView {
  const TransportDeviceView({
    required this.id,
    required this.capabilities,
    required this.status,
    required this.battery,
    required this.signal,
    required this.lastSeen,
    this.assignedTripId,
  });

  final String id;
  final List<String> capabilities;
  final DeviceStatus status;
  final double battery;
  final double signal;
  final DateTime lastSeen;
  final String? assignedTripId;
}

class HandoverBatch {
  const HandoverBatch({
    required this.id,
    required this.species,
    required this.weightKg,
    this.batchCode = '',
    this.traceUrl = '',
  });

  final String id;
  final String species;
  final double weightKg;
  final String batchCode;
  final String traceUrl;

  bool matchesScan(String value) {
    final normalized = value.trim().toLowerCase();
    final scannedUri = Uri.tryParse(normalized);
    final scannedToken = scannedUri?.pathSegments.isNotEmpty == true
        ? scannedUri!.pathSegments.last
        : normalized;
    final traceUri = Uri.tryParse(traceUrl);
    final traceToken = traceUri?.pathSegments.isNotEmpty == true
        ? traceUri!.pathSegments.last.toLowerCase()
        : '';
    return id.toLowerCase() == normalized ||
        id.toLowerCase() == scannedToken ||
        batchCode.toLowerCase() == normalized ||
        traceUrl.toLowerCase() == normalized ||
        (traceToken.isNotEmpty && traceToken == scannedToken);
  }
}

class TransportAlertView {
  const TransportAlertView({
    required this.id,
    required this.type,
    required this.severity,
    required this.status,
    required this.lastDetectedAt,
    this.measuredValue,
    this.thresholdValue,
  });

  final String id;
  final String type;
  final AlertSeverity severity;
  final String status;
  final double? measuredValue;
  final double? thresholdValue;
  final DateTime lastDetectedAt;

  TransportAlertView copyWith({String? status}) => TransportAlertView(
    id: id,
    type: type,
    severity: severity,
    status: status ?? this.status,
    measuredValue: measuredValue,
    thresholdValue: thresholdValue,
    lastDetectedAt: lastDetectedAt,
  );
}

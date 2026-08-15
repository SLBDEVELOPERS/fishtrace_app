enum UserRole { fisher, processor, transporter, retailer }

enum SyncStatus { pending, syncing, synced, failed }

enum TripStatus { upcoming, inProgress, completed, cancelled }

enum BatchStatus {
  newBatch,
  inProgress,
  qualityHold,
  completed,
  rejected,
  recalled,
}

enum AlertSeverity { info, warning, critical }

enum AlertType {
  temperature,
  battery,
  sensorOffline,
  doorOpened,
  stock,
  expiry,
  recall,
  system,
}

enum DeviceStatus { online, offline, assigned }

enum InspectionResult { pass, warning, fail }

enum StockMovementType { sale, increase, decrease, quarantine }

enum ProcessingStep { cleaning, grading, freezing, packaging }

enum QualityGrade { a, b, c, rejected }

class UserOrganization {
  const UserOrganization({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.active,
  });

  final String id;
  final String name;
  final String code;
  final String type;
  final bool active;
}

class User {
  const User({
    required this.name,
    required this.email,
    required this.role,
    this.id,
    this.organization,
  });
  final String? id;
  final String name;
  final String email;
  final UserRole role;
  final UserOrganization? organization;
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  bool get isValid => expiresAt.isAfter(DateTime.now());
}

class Fisher {
  const Fisher({required this.id, required this.name, required this.license});
  final String id;
  final String name;
  final String license;
}

class Boat {
  const Boat({
    required this.id,
    required this.name,
    required this.registration,
    required this.lengthMetres,
    required this.homePort,
    this.active = true,
  });
  final String id;
  final String name;
  final String registration;
  final double lengthMetres;
  final String homePort;
  final bool active;
}

class FishingTrip {
  const FishingTrip({
    required this.id,
    required this.boatId,
    required this.startedAt,
    required this.status,
  });
  final String id;
  final String boatId;
  final DateTime startedAt;
  final TripStatus status;
}

class FishSpecies {
  const FishSpecies({
    required this.code,
    required this.commonName,
    required this.scientificName,
  });
  final String code;
  final String commonName;
  final String scientificName;
}

class CatchRecord {
  const CatchRecord({
    required this.localId,
    required this.tripId,
    required this.species,
    required this.weightKg,
    required this.quantity,
    required this.caughtAt,
    required this.latitude,
    required this.longitude,
    this.serverId,
    this.syncStatus = SyncStatus.pending,
  });
  final String localId;
  final String? serverId;
  final String tripId;
  final FishSpecies species;
  final double weightKg;
  final int quantity;
  final DateTime caughtAt;
  final double latitude;
  final double longitude;
  final SyncStatus syncStatus;
}

class FishBatch {
  const FishBatch({
    required this.id,
    required this.species,
    required this.weightKg,
    required this.fishCount,
    required this.grade,
    required this.status,
  });
  final String id;
  final FishSpecies species;
  final double weightKg;
  final int fishCount;
  final QualityGrade grade;
  final BatchStatus status;
}

class TraceabilityEvent {
  const TraceabilityEvent({
    required this.label,
    required this.timestamp,
    required this.actor,
  });
  final String label;
  final DateTime timestamp;
  final String actor;
}

class Supplier {
  const Supplier({required this.id, required this.name});
  final String id;
  final String name;
}

class ProcessingRecord {
  const ProcessingRecord({
    required this.id,
    required this.batchId,
    required this.step,
    required this.startedAt,
    this.completedAt,
  });
  final String id;
  final String batchId;
  final ProcessingStep step;
  final DateTime startedAt;
  final DateTime? completedAt;
}

class QualityInspection {
  const QualityInspection({
    required this.id,
    required this.batchId,
    required this.overall,
    required this.grade,
    this.comments,
  });
  final String id;
  final String batchId;
  final InspectionResult overall;
  final QualityGrade grade;
  final String? comments;
}

class ChildBatch {
  const ChildBatch({
    required this.id,
    required this.parentId,
    required this.weightKg,
  });
  final String id;
  final String parentId;
  final double weightKg;
}

class TransportTrip {
  const TransportTrip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.status,
    required this.eta,
  });
  final String id;
  final String origin;
  final String destination;
  final TripStatus status;
  final DateTime eta;
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.registration,
    required this.capacityKg,
    required this.minTemperature,
    required this.maxTemperature,
  });
  final String id;
  final String registration;
  final double capacityKg;
  final double minTemperature;
  final double maxTemperature;
}

class IoTDevice {
  const IoTDevice({
    required this.id,
    required this.status,
    required this.battery,
    required this.signal,
    this.assignedTripId,
  });
  final String id;
  final DeviceStatus status;
  final double battery;
  final double signal;
  final String? assignedTripId;
}

class SensorReading {
  const SensorReading({
    this.productTemp,
    this.airTemp,
    this.humidity,
    this.battery,
    this.latitude,
    this.longitude,
    this.doorOpen = false,
    this.recordedAt,
    this.temperatureStatus,
  });
  final double? productTemp;
  final double? airTemp;
  final double? humidity;
  final double? battery;
  final double? latitude;
  final double? longitude;
  final bool doorOpen;
  final DateTime? recordedAt;
  final String? temperatureStatus;
}

class ColdChainAlert {
  const ColdChainAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    this.acknowledged = false,
  });
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime createdAt;
  final bool acknowledged;
}

class DeliveryConfirmation {
  const DeliveryConfirmation({
    required this.id,
    required this.tripId,
    required this.receiver,
    required this.signaturePath,
    required this.completedAt,
  });
  final String id;
  final String tripId;
  final String receiver;
  final String signaturePath;
  final DateTime completedAt;
}

class RetailInventoryItem {
  const RetailInventoryItem({
    required this.id,
    required this.name,
    required this.stockKg,
    required this.expiry,
    required this.batchId,
  });
  final String id;
  final String name;
  final double stockKg;
  final DateTime expiry;
  final String batchId;
}

class StockMovement {
  const StockMovement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantityKg,
    required this.createdAt,
  });
  final String id;
  final String itemId;
  final StockMovementType type;
  final double quantityKg;
  final DateTime createdAt;
}

class Sale {
  const Sale({
    required this.id,
    required this.itemId,
    required this.quantityKg,
    required this.unitPrice,
    required this.createdAt,
  });
  final String id;
  final String itemId;
  final double quantityKg;
  final double unitPrice;
  final DateTime createdAt;
  double get total => quantityKg * unitPrice;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
  });
  final String id;
  final String title;
  final String body;
  final AlertType type;
  final DateTime createdAt;
  final bool read;
}

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.label,
    required this.createdAt,
    this.updatedAt,
    this.serverId,
    this.payload = '{}',
    this.status = SyncStatus.pending,
    this.retries = 0,
    this.lastError,
    this.idempotencyKey,
    this.nextAttemptAt,
    this.recordType = 'operation',
    this.clientRecordId,
    this.endpoint = '/sync',
    this.requestMethod = 'POST',
    this.localFileReferences = const [],
  });
  final String id;
  final String label;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? serverId;
  final String payload;
  final SyncStatus status;
  final int retries;
  final String? lastError;
  final String? idempotencyKey;
  final DateTime? nextAttemptAt;
  final String recordType;
  final String? clientRecordId;
  final String endpoint;
  final String requestMethod;
  final List<String> localFileReferences;

  SyncQueueItem copyWith({
    SyncStatus? status,
    int? retries,
    String? lastError,
    String? serverId,
    DateTime? updatedAt,
    DateTime? nextAttemptAt,
    bool clearNextAttemptAt = false,
  }) => SyncQueueItem(
    id: id,
    label: label,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverId: serverId ?? this.serverId,
    payload: payload,
    status: status ?? this.status,
    retries: retries ?? this.retries,
    lastError: lastError,
    idempotencyKey: idempotencyKey,
    recordType: recordType,
    clientRecordId: clientRecordId,
    endpoint: endpoint,
    requestMethod: requestMethod,
    localFileReferences: localFileReferences,
    nextAttemptAt: clearNextAttemptAt
        ? null
        : nextAttemptAt ?? this.nextAttemptAt,
  );
}

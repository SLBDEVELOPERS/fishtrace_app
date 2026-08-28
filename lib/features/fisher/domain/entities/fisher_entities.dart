import '../../../../core/models/models.dart';
import '../../../../core/utils/display_identifier.dart';

class FisherSpeciesReference {
  const FisherSpeciesReference({
    required this.id,
    required this.commonName,
    required this.scientificName,
  });

  final String id;
  final String commonName;
  final String scientificName;
}

class FisherCatchReferenceData {
  const FisherCatchReferenceData({
    required this.species,
    required this.gearTypes,
  });

  const FisherCatchReferenceData.empty()
    : species = const [],
      gearTypes = const [];

  final List<FisherSpeciesReference> species;
  final List<String> gearTypes;
}

class FisherBoat {
  const FisherBoat({
    required this.id,
    required this.name,
    required this.registration,
    required this.lengthMetres,
    required this.engineDetails,
    required this.type,
    required this.homePort,
    this.active = true,
  });

  final String id;
  final String name;
  final String registration;
  final double lengthMetres;
  final String engineDetails;
  final String type;
  final String homePort;
  final bool active;

  FisherBoat copyWith({
    String? name,
    String? registration,
    double? lengthMetres,
    String? engineDetails,
    String? type,
    String? homePort,
    bool? active,
  }) => FisherBoat(
    id: id,
    name: name ?? this.name,
    registration: registration ?? this.registration,
    lengthMetres: lengthMetres ?? this.lengthMetres,
    engineDetails: engineDetails ?? this.engineDetails,
    type: type ?? this.type,
    homePort: homePort ?? this.homePort,
    active: active ?? this.active,
  );
}

class FisherCatch {
  const FisherCatch({
    required this.id,
    required this.tripId,
    required this.species,
    required this.scientificName,
    required this.weightKg,
    required this.quantity,
    required this.caughtAt,
    required this.latitude,
    required this.longitude,
    required this.gear,
    required this.condition,
    required this.verified,
    this.photoPaths = const [],
    this.linkedBatchId,
    this.linkedBatchCode = '',
    this.tripCode = '',
    this.allocatedWeightKg = 0,
  });

  final String id;
  final String tripId;
  final String species;
  final String scientificName;
  final double weightKg;
  final int quantity;
  final DateTime caughtAt;
  final double latitude;
  final double longitude;
  final String gear;
  final String condition;
  final bool verified;
  final List<String> photoPaths;
  final String? linkedBatchId;
  final String linkedBatchCode;
  final String tripCode;
  final double allocatedWeightKg;
  double get availableWeightKg =>
      (weightKg - allocatedWeightKg).clamp(0, weightKg).toDouble();

  String get reference => DisplayIdentifier.resolve(id: id, noun: 'Catch');
  String get tripLabel =>
      DisplayIdentifier.resolve(id: tripId, code: tripCode, noun: 'Trip');
  String? get linkedBatchLabel => linkedBatchId == null
      ? null
      : DisplayIdentifier.resolve(
          id: linkedBatchId!,
          code: linkedBatchCode,
          noun: 'Batch',
        );
}

class FisherBatchSummary {
  const FisherBatchSummary({
    required this.id,
    this.batchCode = '',
    required this.species,
    required this.weightKg,
    required this.fishCount,
    required this.grade,
    required this.status,
    required this.tripId,
    this.tripCode = '',
    required this.createdAt,
  });

  final String id;
  final String batchCode;
  final String species;
  final double weightKg;
  final int fishCount;
  final QualityGrade grade;
  final BatchStatus status;
  final String tripId;
  final String tripCode;
  final DateTime createdAt;

  String get label =>
      DisplayIdentifier.resolve(id: id, code: batchCode, noun: 'Batch');
  String get tripLabel =>
      DisplayIdentifier.resolve(id: tripId, code: tripCode, noun: 'Trip');
}

class FisherBatchDetails {
  const FisherBatchDetails({
    required this.summary,
    required this.batchCode,
    required this.statusLabel,
    required this.boatName,
    required this.tripCode,
    required this.traceUrl,
    required this.events,
    required this.documents,
  });

  final FisherBatchSummary summary;
  final String batchCode;
  final String statusLabel;
  final String boatName;
  final String tripCode;
  final String traceUrl;
  final List<BatchTimelineEvent> events;
  final List<BatchDocument> documents;
}

class BatchTimelineEvent {
  const BatchTimelineEvent({required this.title, required this.occurredAt});

  final String title;
  final DateTime occurredAt;
}

class BatchDocument {
  const BatchDocument({required this.name, required this.downloadUrl});

  final String name;
  final String downloadUrl;
}

class ActiveFishingTrip {
  const ActiveFishingTrip({
    required this.id,
    this.tripCode = '',
    required this.boatId,
    required this.boatName,
    required this.startedAt,
    required this.fishingArea,
    required this.crew,
    required this.catchKg,
    required this.batchCount,
    required this.status,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String tripCode;
  final String boatId;
  final String boatName;
  final DateTime startedAt;
  final String fishingArea;
  final List<String> crew;
  final double catchKg;
  final int batchCount;
  final TripStatus status;
  final double? latitude;
  final double? longitude;

  String get label =>
      DisplayIdentifier.resolve(id: id, code: tripCode, noun: 'Trip');
}

class MarineWeather {
  const MarineWeather({
    required this.observedAt,
    this.waveHeight,
    this.waveDirection,
    this.wavePeriod,
    this.seaSurfaceTemperature,
  });

  final DateTime observedAt;
  final double? waveHeight;
  final double? waveDirection;
  final double? wavePeriod;
  final double? seaSurfaceTemperature;
}

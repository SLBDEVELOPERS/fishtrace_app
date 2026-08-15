import '../../../../core/models/models.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/fisher_entities.dart';

class FisherBoatDto {
  const FisherBoatDto(this.json);
  final Map<String, Object?> json;

  factory FisherBoatDto.fromJson(Map<String, Object?> json) =>
      FisherBoatDto(json);

  FisherBoat toDomain() => FisherBoat(
    id: ApiData.string(json, 'id'),
    name: ApiData.string(json, 'name'),
    registration: ApiData.string(json, 'registration_number'),
    lengthMetres: ApiData.number(json, 'length_meters'),
    engineDetails: ApiData.string(json, 'engine_details'),
    type: ApiData.string(json, 'type'),
    homePort: ApiData.string(json, 'home_port'),
    active: ApiData.boolean(json, 'is_active', true),
  );

  static Map<String, Object?> fromDomain(FisherBoat boat) => {
    'name': boat.name,
    'registration_number': boat.registration,
    'type': boat.type,
    'length_meters': boat.lengthMetres,
    'engine_details': boat.engineDetails,
    'home_port': boat.homePort,
    'is_active': boat.active,
  };
}

class FisherCatchDto {
  const FisherCatchDto(this.json);
  final Map<String, Object?> json;
  factory FisherCatchDto.fromJson(Map<String, Object?> json) =>
      FisherCatchDto(json);

  FisherCatch toDomain() {
    final speciesData = _map(json['species']);
    final gearData = _map(json['gear']);
    final images = ApiData.listValue(json, 'images');
    final batches = ApiData.listValue(json, 'batches');
    return FisherCatch(
      id: ApiData.string(json, 'id'),
      tripId: ApiData.string(json, 'fishingTripId'),
      species: ApiData.string(speciesData, 'commonName'),
      scientificName: ApiData.string(speciesData, 'scientificName'),
      weightKg: ApiData.number(json, 'weightKg'),
      quantity: ApiData.integer(json, 'quantity'),
      caughtAt: ApiData.date(json, 'caughtAt'),
      latitude: ApiData.number(json, 'latitude'),
      longitude: ApiData.number(json, 'longitude'),
      gear: ApiData.string(gearData, 'name'),
      condition: _displayEnum(ApiData.string(json, 'condition')),
      verified: ApiData.boolean(json, 'verified', true),
      photoPaths: images
          .whereType<Map>()
          .map(
            (value) =>
                ApiData.string(value.cast<String, Object?>(), 'download_url'),
          )
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      linkedBatchId: batches.isEmpty
          ? null
          : ApiData.string(
              (batches.first as Map).cast<String, Object?>(),
              'id',
            ),
      allocatedWeightKg: ApiData.number(json, 'allocatedWeightKg'),
    );
  }
}

class FisherBatchDto {
  const FisherBatchDto(this.json);
  final Map<String, Object?> json;
  factory FisherBatchDto.fromJson(Map<String, Object?> json) =>
      FisherBatchDto(json);

  FisherBatchSummary toDomain() {
    final speciesData = _map(json['species']);
    return FisherBatchSummary(
      id: ApiData.string(json, 'id'),
      batchCode: ApiData.string(json, 'batchCode'),
      species: ApiData.string(speciesData, 'commonName'),
      weightKg: ApiData.number(json, 'totalWeightKg'),
      fishCount: ApiData.integer(json, 'fishCount'),
      grade: _qualityGrade(ApiData.string(json, 'quality_grade')),
      status: _batchStatus(ApiData.string(json, 'status')),
      tripId: ApiData.string(json, 'fishing_trip_id'),
      createdAt: ApiData.date(json, 'createdAt'),
    );
  }
}

class FisherBatchDetailsDto {
  const FisherBatchDetailsDto(
    this.json, {
    required this.timeline,
    required this.documents,
  });

  final Map<String, Object?> json;
  final List<Map<String, Object?>> timeline;
  final List<Map<String, Object?>> documents;

  factory FisherBatchDetailsDto.fromJson(
    Map<String, Object?> json, {
    required List<Map<String, Object?>> timeline,
    required List<Map<String, Object?>> documents,
  }) => FisherBatchDetailsDto(json, timeline: timeline, documents: documents);

  FisherBatchDetails toDomain() {
    final trip = _map(json['trip']);
    final boat = _map(trip['boat']);
    final qrCode = _map(json['qr_code']);
    return FisherBatchDetails(
      summary: FisherBatchDto.fromJson(json).toDomain(),
      batchCode: ApiData.string(json, 'batchCode'),
      statusLabel: _displayEnum(ApiData.string(json, 'status')),
      boatName: ApiData.string(boat, 'name'),
      tripCode: ApiData.string(trip, 'tripCode'),
      traceUrl: ApiData.string(qrCode, 'traceUrl'),
      events: timeline
          .map(
            (event) => BatchTimelineEvent(
              title: ApiData.string(event, 'title'),
              occurredAt: ApiData.date(event, 'occurredAt'),
            ),
          )
          .toList(growable: false),
      documents: documents
          .map(
            (document) => BatchDocument(
              name: ApiData.string(document, 'originalName'),
              downloadUrl: ApiData.string(document, 'downloadUrl'),
            ),
          )
          .toList(growable: false),
    );
  }
}

class ActiveFishingTripDto {
  const ActiveFishingTripDto(this.json);
  final Map<String, Object?> json;
  factory ActiveFishingTripDto.fromJson(Map<String, Object?> json) =>
      ActiveFishingTripDto(json);

  ActiveFishingTrip toDomain() {
    final boat = _map(json['boat']);
    return ActiveFishingTrip(
      id: ApiData.string(json, 'id'),
      tripCode: ApiData.string(json, 'tripCode'),
      boatId: ApiData.string(json, 'boatId'),
      boatName: ApiData.string(boat, 'name'),
      startedAt: ApiData.date(json, 'departedAt'),
      fishingArea: ApiData.string(json, 'generalCatchArea'),
      crew: ApiData.strings(json, 'crew'),
      catchKg: ApiData.number(json, 'catchKg'),
      batchCount: ApiData.integer(json, 'batchCount'),
      status: _tripStatus(ApiData.string(json, 'status')),
      latitude: double.tryParse(
        '${ApiData.value(json, 'fishingAreaLatitude')}',
      ),
      longitude: double.tryParse(
        '${ApiData.value(json, 'fishingAreaLongitude')}',
      ),
    );
  }
}

Map<String, Object?> _map(Object? value) =>
    value is Map ? value.cast<String, Object?>() : const {};

String _displayEnum(String raw) {
  if (raw.isEmpty) return '';
  final words = raw.toLowerCase().split('_');
  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

QualityGrade _qualityGrade(String raw) => switch (raw.toUpperCase()) {
  'B' => QualityGrade.b,
  'C' => QualityGrade.c,
  'REJECTED' => QualityGrade.rejected,
  _ => QualityGrade.a,
};

BatchStatus _batchStatus(String raw) => switch (raw.toUpperCase()) {
  'PROCESSING' || 'ACCEPTED_BY_PROCESSOR' => BatchStatus.inProgress,
  'RECALLED' => BatchStatus.recalled,
  'AVAILABLE_FOR_PROCESSING' ||
  'READY_FOR_TRANSPORT' ||
  'SOLD' ||
  'RECEIVED_BY_RETAILER' ||
  'AVAILABLE_FOR_SALE' => BatchStatus.completed,
  _ => BatchStatus.newBatch,
};

TripStatus _tripStatus(String raw) => switch (raw.toUpperCase()) {
  'DRAFT' => TripStatus.upcoming,
  'ACTIVE' => TripStatus.inProgress,
  'COMPLETED' => TripStatus.completed,
  'CANCELLED' => TripStatus.cancelled,
  _ => TripStatus.upcoming,
};

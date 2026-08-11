class CreateFishingTripRequestDto {
  const CreateFishingTripRequestDto({
    required this.boatId,
    required this.tripCode,
    required this.clientRecordId,
    required this.plannedDepartureAt,
    required this.expectedDurationHours,
    required this.fishingAreaLatitude,
    required this.fishingAreaLongitude,
    required this.crew,
    this.landingSiteId,
    this.generalCatchArea,
    this.notes,
  });

  final String boatId;
  final String tripCode;
  final String clientRecordId;
  final String? landingSiteId;
  final String? generalCatchArea;
  final DateTime plannedDepartureAt;
  final double expectedDurationHours;
  final double fishingAreaLatitude;
  final double fishingAreaLongitude;
  final List<String> crew;
  final String? notes;

  Map<String, Object?> toJson() => {
    'boat_id': boatId,
    'trip_code': tripCode,
    'client_record_id': clientRecordId,
    if (landingSiteId != null) 'landing_site_id': landingSiteId,
    if (generalCatchArea != null) 'general_catch_area': generalCatchArea,
    'planned_departure_at': plannedDepartureAt.toUtc().toIso8601String(),
    'expected_duration_hours': expectedDurationHours,
    'fishing_area_latitude': fishingAreaLatitude,
    'fishing_area_longitude': fishingAreaLongitude,
    'crew': crew,
    if (notes?.isNotEmpty ?? false) 'notes': notes,
  };
}

class CreateCatchRequestDto {
  const CreateCatchRequestDto({
    required this.fishingTripId,
    required this.fishSpeciesId,
    required this.weightKg,
    required this.quantity,
    required this.condition,
    required this.latitude,
    required this.longitude,
    required this.caughtAt,
    required this.clientRecordId,
    required this.clientCreatedAt,
    this.fishingGearTypeId,
    this.notes,
  });

  final String fishingTripId;
  final String fishSpeciesId;
  final String? fishingGearTypeId;
  final double weightKg;
  final int quantity;
  final String condition;
  final double latitude;
  final double longitude;
  final DateTime caughtAt;
  final String clientRecordId;
  final DateTime clientCreatedAt;
  final String? notes;

  Map<String, Object?> toJson() => {
    'fishing_trip_id': fishingTripId,
    'fish_species_id': fishSpeciesId,
    if (fishingGearTypeId != null) 'fishing_gear_type_id': fishingGearTypeId,
    'weight_kg': weightKg,
    'quantity': quantity,
    'condition': condition,
    'latitude': latitude,
    'longitude': longitude,
    'caught_at': caughtAt.toUtc().toIso8601String(),
    'client_record_id': clientRecordId,
    'client_created_at': clientCreatedAt.toUtc().toIso8601String(),
    if (notes?.isNotEmpty ?? false) 'notes': notes,
  };
}

class BatchCatchAllocationDto {
  const BatchCatchAllocationDto({
    required this.catchId,
    required this.weightKg,
  });

  final String catchId;
  final double weightKg;

  Map<String, Object?> toJson() => {'catch_id': catchId, 'weight_kg': weightKg};
}

class CreateBatchRequestDto {
  const CreateBatchRequestDto({
    required this.fishSpeciesId,
    required this.productType,
    required this.qualityGrade,
    required this.storageTemperatureCelsius,
    required this.iceType,
    required this.iceAmountKg,
    required this.landingSiteName,
    required this.catches,
    this.notes,
  });

  final String fishSpeciesId;
  final String productType;
  final String qualityGrade;
  final double storageTemperatureCelsius;
  final String iceType;
  final double iceAmountKg;
  final String landingSiteName;
  final List<BatchCatchAllocationDto> catches;
  final String? notes;

  Map<String, Object?> toJson() => {
    'fish_species_id': fishSpeciesId,
    'product_type': productType,
    'quality_grade': qualityGrade,
    'storage_temperature_celsius': storageTemperatureCelsius,
    'ice_type': iceType,
    'ice_amount_kg': iceAmountKg,
    'landing_site_name': landingSiteName,
    if (notes?.isNotEmpty ?? false) 'notes': notes,
    'catches': catches.map((value) => value.toJson()).toList(growable: false),
  };
}

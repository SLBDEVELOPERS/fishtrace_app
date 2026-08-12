import '../../../../core/models/models.dart';
import '../../domain/entities/fisher_entities.dart';
import '../../../../core/network/api_models.dart';
import '../../domain/repositories/fisher_repository.dart';

class MockFisherRepository implements FisherRepository {
  @override
  Future<FisherCatchReferenceData> getCatchReferenceData() async =>
      const FisherCatchReferenceData(
        species: [
          FisherSpeciesReference(
            id: 'species-yellowfin',
            commonName: 'Yellowfin Tuna',
            scientificName: 'Thunnus albacares',
          ),
          FisherSpeciesReference(
            id: 'species-seer',
            commonName: 'Seer Fish',
            scientificName: 'Scomberomorus commerson',
          ),
        ],
        gearTypes: ['Longline', 'Handline'],
      );

  final _boats = <FisherBoat>[
    const FisherBoat(
      id: 'boat-ocean-hunter',
      name: 'Ocean Hunter',
      registration: 'ND-TN-01-MM-2345',
      lengthMetres: 12.5,
      engineDetails: 'Volvo Penta D6',
      type: 'LONG_LINER',
      homePort: 'Kochi Port',
    ),
    const FisherBoat(
      id: 'boat-sea-wanderer',
      name: 'Sea Wanderer',
      registration: 'ND-TN-02-MM-5678',
      lengthMetres: 10.2,
      engineDetails: 'Yanmar 6LY',
      type: 'GILLNETTER',
      homePort: 'Kochi Port',
    ),
    const FisherBoat(
      id: 'boat-blue-horizon',
      name: 'Blue Horizon',
      registration: 'ND-TN-05-MM-9012',
      lengthMetres: 13.8,
      engineDetails: 'Cummins QSB',
      type: 'LONG_LINER',
      homePort: 'Chennai Port',
    ),
    const FisherBoat(
      id: 'boat-wave-rider',
      name: 'Wave Rider',
      registration: 'ND-TN-04-MM-3456',
      lengthMetres: 9.4,
      engineDetails: 'Yanmar 4LV',
      type: 'DAY_BOAT',
      homePort: 'Kochi Port',
      active: false,
    ),
    const FisherBoat(
      id: 'boat-sea-queen',
      name: 'Sea Queen',
      registration: 'ND-TN-05-MM-7890',
      lengthMetres: 11.6,
      engineDetails: 'Volvo Penta D4',
      type: 'GILLNETTER',
      homePort: 'Salem Port',
    ),
  ];

  @override
  Future<List<FisherBoat>> getBoats({PageQuery? query}) async =>
      List.unmodifiable(_boats);

  @override
  Future<PaginatedResponse<FisherBoat>> getBoatsPage(PageQuery query) async {
    final search = query.search?.trim().toLowerCase() ?? '';
    final filtered = _boats
        .where(
          (boat) =>
              search.isEmpty ||
              boat.name.toLowerCase().contains(search) ||
              boat.registration.toLowerCase().contains(search),
        )
        .toList(growable: false);
    final start = ((query.page - 1) * query.perPage).clamp(0, filtered.length);
    final end = (start + query.perPage).clamp(start, filtered.length);
    return PaginatedResponse(
      items: filtered.sublist(start, end),
      currentPage: query.page,
      lastPage: (filtered.length / query.perPage).ceil().clamp(1, 1 << 31),
      total: filtered.length,
    );
  }

  @override
  Future<FisherBoat> saveBoat(FisherBoat boat) async {
    final index = _boats.indexWhere((item) => item.id == boat.id);
    if (index >= 0) {
      _boats[index] = boat;
    } else {
      _boats.add(boat);
    }
    return boat;
  }

  @override
  Future<ActiveFishingTrip?> getActiveTrip() async => ActiveFishingTrip(
    id: 'TRIP-2024-05-21',
    boatId: 'boat-ocean-hunter',
    boatName: 'Ocean Hunter',
    startedAt: DateTime(2024, 5, 21, 6, 30),
    fishingArea: '17.6858° N, 83.2185° E',
    crew: const ['Alex Johnson', 'M. Kumar', 'R. Babu', 'V. Singh'],
    catchKg: 125.4,
    batchCount: 6,
    status: TripStatus.inProgress,
    latitude: 17.6858,
    longitude: 83.2185,
  );

  @override
  Future<List<FisherCatch>> getCatches() async => [
    FisherCatch(
      id: 'CATCH-001',
      tripId: 'TRIP-2024-05-21',
      species: 'Yellowfin Tuna',
      scientificName: 'Thunnus albacares',
      weightKg: 25.4,
      quantity: 3,
      caughtAt: DateTime(2024, 5, 21, 8, 15),
      latitude: 17.6858,
      longitude: 83.2185,
      gear: 'Longline',
      condition: 'Good',
      verified: true,
    ),
    FisherCatch(
      id: 'CATCH-002',
      tripId: 'TRIP-2024-05-21',
      species: 'Indian Mackerel',
      scientificName: 'Rastrelliger kanagurta',
      weightKg: 12.5,
      quantity: 18,
      caughtAt: DateTime(2024, 5, 21, 7, 45),
      latitude: 17.6931,
      longitude: 83.2268,
      gear: 'Gill net',
      condition: 'Excellent',
      verified: true,
    ),
    FisherCatch(
      id: 'CATCH-003',
      tripId: 'TRIP-2024-05-21',
      species: 'Seer Fish',
      scientificName: 'Scomberomorus commerson',
      weightKg: 18.2,
      quantity: 4,
      caughtAt: DateTime(2024, 5, 21, 7, 10),
      latitude: 17.6712,
      longitude: 83.2041,
      gear: 'Longline',
      condition: 'Good',
      verified: true,
    ),
    FisherCatch(
      id: 'CATCH-004',
      tripId: 'TRIP-2024-05-21',
      species: 'Ribbon Fish',
      scientificName: 'Trichiurus lepturus',
      weightKg: 9.8,
      quantity: 11,
      caughtAt: DateTime(2024, 5, 21, 6, 40),
      latitude: 17.6610,
      longitude: 83.1920,
      gear: 'Trawl',
      condition: 'Fair',
      verified: false,
    ),
  ];

  @override
  Future<List<FisherBatchSummary>> getBatches() async => [
    FisherBatchSummary(
      id: 'BATCH-2024-05-21-001',
      species: 'Indian Mackerel',
      weightKg: 125.4,
      fishCount: 25,
      grade: QualityGrade.a,
      status: BatchStatus.completed,
      tripId: 'TRIP-2024-05-21',
      createdAt: DateTime(2024, 5, 21, 8, 35),
    ),
  ];

  @override
  Future<FisherBatchDetails> getBatchDetails(String id) async {
    final batch = (await getBatches()).firstWhere((item) => item.id == id);
    return FisherBatchDetails(
      summary: batch,
      batchCode: batch.id,
      statusLabel: 'Completed',
      boatName: 'Ocean Hunter',
      tripCode: batch.tripId,
      traceUrl: 'https://example.test/trace/$id',
      events: [
        BatchTimelineEvent(title: 'Batch created', occurredAt: batch.createdAt),
      ],
      documents: const [],
    );
  }
}

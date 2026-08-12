import 'package:fishtrace/core/database/fishtrace_database.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/fisher/data/repositories/mock_fisher_repository.dart';
import 'package:fishtrace/features/fisher/data/repositories/offline_first_fisher_repository.dart';
import 'package:fishtrace/features/fisher/domain/entities/fisher_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline trip cache preserves marine forecast coordinates', () async {
    final database = FishTraceDatabase.memory();
    addTearDown(database.close);
    final repository = OfflineFirstFisherRepository(
      remote: MockFisherRepository(),
      database: database,
      isOffline: () => true,
      canUseRemote: () => false,
      queueBoat: (_) async {},
    );
    final trip = ActiveFishingTrip(
      id: 'LOCAL-TRIP',
      boatId: 'BOAT-1',
      boatName: 'Test Boat',
      startedAt: DateTime(2026, 8, 12),
      fishingArea: '6.0329, 80.2168',
      crew: const ['Crew'],
      catchKg: 0,
      batchCount: 0,
      status: TripStatus.inProgress,
      latitude: 6.0329,
      longitude: 80.2168,
    );

    await repository.saveTripDraft(trip);
    final restored = await repository.getActiveTrip();

    expect(restored?.latitude, 6.0329);
    expect(restored?.longitude, 80.2168);
  });

  test(
    'legacy offline trip recovers coordinates from fishing-area text',
    () async {
      final database = FishTraceDatabase.memory();
      addTearDown(database.close);
      final repository = OfflineFirstFisherRepository(
        remote: MockFisherRepository(),
        database: database,
        isOffline: () => true,
        canUseRemote: () => false,
        queueBoat: (_) async {},
      );
      await repository.saveTripDraft(
        ActiveFishingTrip(
          id: 'LEGACY-TRIP',
          boatId: 'BOAT-1',
          boatName: 'Legacy Boat',
          startedAt: DateTime(2026, 8, 12),
          fishingArea: '6.0329° N, 80.2168° E',
          crew: const ['Crew'],
          catchKg: 0,
          batchCount: 0,
          status: TripStatus.inProgress,
        ),
      );

      final restored = await repository.getActiveTrip();

      expect(restored?.latitude, 6.0329);
      expect(restored?.longitude, 80.2168);
    },
  );
}

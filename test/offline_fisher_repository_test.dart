import 'package:fishtrace/core/database/fishtrace_database.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/fisher/data/repositories/mock_fisher_repository.dart';
import 'package:fishtrace/features/fisher/data/repositories/offline_first_fisher_repository.dart';
import 'package:fishtrace/features/fisher/domain/entities/fisher_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FishTraceDatabase database;
  late OfflineFirstFisherRepository repository;

  setUp(() async {
    database = FishTraceDatabase.memory();
    await database.initialize();
    repository = OfflineFirstFisherRepository(
      remote: MockFisherRepository(),
      database: database,
      isOffline: () => true,
    );
  });

  tearDown(() => database.close());

  test('offline fisher drafts persist in typed domain tables', () async {
    final caughtAt = DateTime.utc(2026, 8, 1, 6, 30);
    final catchRecord = FisherCatch(
      id: 'CATCH-LOCAL-1',
      tripId: 'TRIP-LOCAL-1',
      species: 'Yellowfin Tuna',
      scientificName: 'Thunnus albacares',
      weightKg: 25.4,
      quantity: 3,
      caughtAt: caughtAt,
      latitude: 17.68,
      longitude: 83.21,
      gear: 'Longline',
      condition: 'Good',
      verified: false,
      photoPaths: const ['local/photo.jpg'],
    );
    final batch = FisherBatchSummary(
      id: 'BATCH-LOCAL-1',
      species: catchRecord.species,
      weightKg: catchRecord.weightKg,
      fishCount: catchRecord.quantity,
      grade: QualityGrade.a,
      status: BatchStatus.newBatch,
      tripId: 'TRIP-LOCAL-1',
      createdAt: caughtAt,
    );

    await repository.saveCatchDraft(catchRecord, tripId: 'TRIP-LOCAL-1');
    await repository.saveBatchDraft(batch);

    final catchRows = await database.select(database.catchDraftRows).get();
    final photoRows = await database.select(database.catchPhotoRows).get();
    final batchRows = await database.select(database.batchDraftRows).get();
    expect(catchRows.single.syncStatus, SyncStatus.pending.name);
    expect(catchRows.single.tripId, 'TRIP-LOCAL-1');
    expect(photoRows.single.localPath, 'local/photo.jpg');
    expect(batchRows.single.syncStatus, SyncStatus.pending.name);
    expect((await repository.getCatches()).single.id, catchRecord.id);
    expect((await repository.getBatches()).single.id, batch.id);
  });

  test('offline boat write is immediately readable', () async {
    const boat = FisherBoat(
      id: 'LOCAL-BOAT-1',
      name: 'Sea Light',
      registration: 'ND-TN-01-LOCAL',
      lengthMetres: 9.8,
      engineDetails: 'Inboard diesel',
      type: 'Gillnetter',
      homePort: 'Kochi',
    );
    await repository.saveBoat(boat);
    final restored = await repository.getBoats();
    expect(restored.single.registration, boat.registration);
    expect(
      (await database.select(database.boatRows).get()).single.syncStatus,
      SyncStatus.pending.name,
    );
  });

  test('offline boat write is queued for later upload', () async {
    FisherBoat? queued;
    repository = OfflineFirstFisherRepository(
      remote: MockFisherRepository(),
      database: database,
      isOffline: () => true,
      queueBoat: (boat) async => queued = boat,
    );
    const boat = FisherBoat(
      id: 'LOCAL-BOAT-2',
      name: 'Blue Water',
      registration: 'ND-TN-02-LOCAL',
      lengthMetres: 8.5,
      engineDetails: 'Outboard',
      type: 'DAY_BOAT',
      homePort: 'Colombo',
    );

    await repository.saveBoat(boat);

    expect(queued?.id, boat.id);
  });

  test('successful sync persists IDs used after an app restart', () async {
    final now = DateTime.utc(2026, 8, 9);
    await database.saveLocalRecord(
      localId: 'TRIP-LOCAL-1',
      recordType: 'trip',
      payload: '{}',
    );
    await database.markRecordSynced(
      SyncQueueItem(
        id: 'queue-1',
        label: 'Start fishing trip',
        createdAt: now,
        recordType: 'trip',
        clientRecordId: 'TRIP-LOCAL-1',
      ),
      'server-trip-uuid',
    );

    expect(await database.resolveServerId('TRIP-LOCAL-1'), 'server-trip-uuid');
    expect(
      await database.resolveLocalId('trip', 'server-trip-uuid'),
      'TRIP-LOCAL-1',
    );
  });
}

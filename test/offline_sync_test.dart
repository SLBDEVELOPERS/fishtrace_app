import 'package:fishtrace/core/data/repositories.dart';
import 'package:fishtrace/core/database/fishtrace_database.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FishTraceDatabase database;
  late DriftOfflineRepository repository;

  setUp(() async {
    database = FishTraceDatabase.memory();
    await database.initialize();
    repository = DriftOfflineRepository(database);
  });

  tearDown(() => database.close());

  test(
    'offline queue persists complete retry and idempotency metadata',
    () async {
      final createdAt = DateTime.utc(2026, 7, 29);
      const id = 'local-catch-1';
      await repository.put(
        SyncQueueItem(
          id: id,
          label: 'Create catch',
          payload: '{"weightKg":25.4}',
          idempotencyKey: id,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      final restored = await repository.getQueue();

      expect(restored, hasLength(1));
      expect(restored.single.idempotencyKey, id);
      expect(restored.single.status, SyncStatus.pending);
      expect(restored.single.createdAt, createdAt);
    },
  );

  test('successful sync removes durable queue records', () async {
    final controller = AppController(
      auth: MockAuthRepository(),
      offlineRepository: repository,
      syncTransport: MockSyncTransport(),
    );
    await controller.queue(
      'Create catch',
      recordType: 'catch',
      payload: {'weightKg': 25.4},
    );

    await controller.syncNow();

    expect(controller.syncItems, isEmpty);
    expect(await repository.getQueue(), isEmpty);
    expect(controller.lastSuccessfulSync.value, isNotNull);
  });
}

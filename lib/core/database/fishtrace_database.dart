import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';

part 'fishtrace_database.g.dart';

class SyncOperations extends Table {
  @override
  String get tableName => 'sync_queue';
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get label => text()();
  TextColumn get recordType =>
      text().withDefault(const Constant('operation'))();
  TextColumn get clientRecordId => text().nullable()();
  TextColumn get endpoint => text().withDefault(const Constant('/sync'))();
  TextColumn get requestMethod => text().withDefault(const Constant('POST'))();
  TextColumn get localFileReferences =>
      text().withDefault(const Constant('[]'))();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get idempotencyKey => text().unique()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalRecords extends Table {
  @override
  String get tableName => 'local_records';
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get recordType => text()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {localId};
}

class AuthMetadataRows extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  DateTimeColumn get lastLoginAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {userId};
}

class BoatRows extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get registration => text()();
  RealColumn get lengthMetres => real()();
  TextColumn get engine => text()();
  TextColumn get boatType => text()();
  TextColumn get homePort => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {localId};
}

class FishingTripRows extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get boatId => text()();
  TextColumn get boatName => text()();
  DateTimeColumn get startedAt => dateTime()();
  TextColumn get fishingArea => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get crewJson => text().withDefault(const Constant('[]'))();
  RealColumn get catchKg => real().withDefault(const Constant(0))();
  IntColumn get batchCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {localId};
}

class CatchDraftRows extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get tripId => text()();
  TextColumn get species => text()();
  TextColumn get scientificName => text()();
  RealColumn get weightKg => real()();
  IntColumn get quantity => integer()();
  DateTimeColumn get caughtAt => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get gear => text()();
  TextColumn get condition => text()();
  BoolColumn get verified => boolean().withDefault(const Constant(false))();
  TextColumn get linkedBatchId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {localId};
}

class CatchPhotoRows extends Table {
  TextColumn get id => text()();
  TextColumn get catchLocalId => text()();
  TextColumn get localPath => text()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BatchDraftRows extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get tripId => text()();
  TextColumn get species => text()();
  RealColumn get weightKg => real()();
  IntColumn get fishCount => integer()();
  TextColumn get grade => text()();
  TextColumn get status => text()();
  TextColumn get catchIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {localId};
}

class ReferenceDataRows extends Table {
  TextColumn get key => text()();
  TextColumn get category => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    SyncOperations,
    LocalRecords,
    AuthMetadataRows,
    BoatRows,
    FishingTripRows,
    CatchDraftRows,
    CatchPhotoRows,
    BatchDraftRows,
    ReferenceDataRows,
  ],
)
class FishTraceDatabase extends _$FishTraceDatabase {
  FishTraceDatabase(super.executor);

  factory FishTraceDatabase.memory() =>
      FishTraceDatabase(NativeDatabase.memory());

  static Future<FishTraceDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'fishtrace.sqlite'));
    final database = FishTraceDatabase(NativeDatabase.createInBackground(file));
    await database.customSelect('SELECT 1').get();
    return database;
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      Future<void> addColumnSafe(String sql) async {
        try {
          await customStatement(sql);
        } catch (e) {
          if (!e.toString().contains('duplicate column name')) rethrow;
        }
      }

      if (from < 2) {
        await migrator.createTable(authMetadataRows);
        await migrator.createTable(boatRows);
        await migrator.createTable(fishingTripRows);
        await migrator.createTable(catchDraftRows);
        await migrator.createTable(catchPhotoRows);
        await migrator.createTable(batchDraftRows);
        await migrator.createTable(referenceDataRows);
        await addColumnSafe(
          "ALTER TABLE sync_queue ADD COLUMN record_type TEXT NOT NULL DEFAULT 'operation'",
        );
        await addColumnSafe(
          'ALTER TABLE sync_queue ADD COLUMN next_attempt_at INTEGER',
        );
        await addColumnSafe(
          'ALTER TABLE local_records ADD COLUMN version INTEGER NOT NULL DEFAULT 1',
        );
        await addColumnSafe(
          'ALTER TABLE local_records ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 3) {
        await addColumnSafe(
          'ALTER TABLE boat_rows ADD COLUMN retry_count INTEGER NOT NULL DEFAULT 0',
        );
        await addColumnSafe('ALTER TABLE boat_rows ADD COLUMN last_error TEXT');
        await addColumnSafe(
          'ALTER TABLE boat_rows ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
        );
        await addColumnSafe(
          'ALTER TABLE fishing_trip_rows ADD COLUMN retry_count INTEGER NOT NULL DEFAULT 0',
        );
        await addColumnSafe(
          'ALTER TABLE fishing_trip_rows ADD COLUMN last_error TEXT',
        );
        await addColumnSafe(
          'ALTER TABLE fishing_trip_rows ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0',
        );
        await addColumnSafe(
          'ALTER TABLE batch_draft_rows ADD COLUMN retry_count INTEGER NOT NULL DEFAULT 0',
        );
        await addColumnSafe(
          'ALTER TABLE batch_draft_rows ADD COLUMN last_error TEXT',
        );
      }
      if (from < 4) {
        await addColumnSafe(
          'ALTER TABLE sync_queue ADD COLUMN client_record_id TEXT',
        );
        await addColumnSafe(
          "ALTER TABLE sync_queue ADD COLUMN endpoint TEXT NOT NULL DEFAULT '/sync'",
        );
        await addColumnSafe(
          "ALTER TABLE sync_queue ADD COLUMN request_method TEXT NOT NULL DEFAULT 'POST'",
        );
        await addColumnSafe(
          "ALTER TABLE sync_queue ADD COLUMN local_file_references TEXT NOT NULL DEFAULT '[]'",
        );
      }
      if (from < 5) {
        await addColumnSafe(
          'ALTER TABLE fishing_trip_rows ADD COLUMN latitude REAL',
        );
        await addColumnSafe(
          'ALTER TABLE fishing_trip_rows ADD COLUMN longitude REAL',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  Future<void> initialize() async {
    await customSelect('SELECT 1').get();
  }

  Future<void> putQueueItem(SyncQueueItem item) =>
      into(syncOperations).insertOnConflictUpdate(
        SyncOperationsCompanion.insert(
          id: item.id,
          serverId: Value(item.serverId),
          label: item.label,
          recordType: Value(item.recordType),
          clientRecordId: Value(item.clientRecordId),
          endpoint: Value(item.endpoint),
          requestMethod: Value(item.requestMethod),
          localFileReferences: Value(jsonEncode(item.localFileReferences)),
          payload: Value(item.payload),
          status: Value(item.status.name),
          retryCount: Value(item.retries),
          lastError: Value(item.lastError),
          idempotencyKey: item.idempotencyKey ?? item.id,
          nextAttemptAt: Value(item.nextAttemptAt),
          createdAt: item.createdAt,
          updatedAt: item.updatedAt ?? item.createdAt,
        ),
      );

  Future<List<SyncQueueItem>> getQueueItems() async {
    final rows = await (select(
      syncOperations,
    )..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).get();
    return rows
        .map(
          (row) => SyncQueueItem(
            id: row.id,
            serverId: row.serverId,
            label: row.label,
            payload: row.payload,
            status: SyncStatus.values.byName(row.status),
            retries: row.retryCount,
            lastError: row.lastError,
            idempotencyKey: row.idempotencyKey,
            createdAt: row.createdAt.toUtc(),
            updatedAt: row.updatedAt.toUtc(),
            nextAttemptAt: row.nextAttemptAt?.toUtc(),
            recordType: row.recordType,
            clientRecordId: row.clientRecordId,
            endpoint: row.endpoint,
            requestMethod: row.requestMethod,
            localFileReferences: (jsonDecode(row.localFileReferences) as List)
                .map((value) => value.toString())
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  Future<void> updateQueueItem(SyncQueueItem item) => putQueueItem(item);
  Future<void> deleteQueueItem(String id) =>
      (delete(syncOperations)..where((row) => row.id.equals(id))).go();

  Future<void> saveLocalRecord({
    required String localId,
    required String recordType,
    required String payload,
    String? serverId,
    SyncStatus status = SyncStatus.pending,
    DateTime? createdAt,
  }) {
    final now = DateTime.now().toUtc();
    return into(localRecords).insertOnConflictUpdate(
      LocalRecordsCompanion.insert(
        localId: localId,
        serverId: Value(serverId),
        recordType: recordType,
        payload: Value(payload),
        syncStatus: Value(status.name),
        createdAt: createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<List<Map<String, Object?>>> getLocalRecords(String recordType) async {
    final rows =
        await (select(localRecords)
              ..where(
                (row) =>
                    row.recordType.equals(recordType) &
                    row.deleted.equals(false),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows
        .map(
          (row) => <String, Object?>{
            'local_id': row.localId,
            'server_id': row.serverId,
            'record_type': row.recordType,
            'payload': row.payload,
            'sync_status': row.syncStatus,
            'created_at': row.createdAt.millisecondsSinceEpoch,
            'updated_at': row.updatedAt.millisecondsSinceEpoch,
          },
        )
        .toList(growable: false);
  }

  Future<Map<String, String>> getServerIdMappings() async {
    final mappings = <String, String>{};
    final records = await (select(
      localRecords,
    )..where((row) => row.serverId.isNotNull())).get();
    for (final row in records) {
      if (row.serverId != null) mappings[row.localId] = row.serverId!;
    }
    for (final row in await select(boatRows).get()) {
      if (row.serverId != null) mappings[row.localId] = row.serverId!;
    }
    for (final row in await select(fishingTripRows).get()) {
      if (row.serverId != null) mappings[row.localId] = row.serverId!;
    }
    for (final row in await select(catchDraftRows).get()) {
      if (row.serverId != null) mappings[row.localId] = row.serverId!;
    }
    for (final row in await select(batchDraftRows).get()) {
      if (row.serverId != null) mappings[row.localId] = row.serverId!;
    }
    return mappings;
  }

  Future<String?> resolveServerId(String localId) async =>
      (await getServerIdMappings())[localId];

  Future<String?> resolveLocalId(String recordType, String serverId) async {
    final row =
        await (select(localRecords)
              ..where(
                (row) =>
                    row.recordType.equals(recordType) &
                    row.serverId.equals(serverId),
              )
              ..limit(1))
            .getSingleOrNull();
    return row?.localId;
  }

  Future<void> markRecordSynced(SyncQueueItem item, String serverId) async {
    final localId = item.clientRecordId ?? item.id;
    final createsRecord = switch (item.recordType) {
      'boat' || 'catch' || 'batch' => true,
      'trip' => !item.label.toLowerCase().contains('end'),
      _ => false,
    };
    if (!createsRecord) return;

    await transaction(() async {
      await (update(
        localRecords,
      )..where((row) => row.localId.equals(localId))).write(
        LocalRecordsCompanion(
          serverId: Value(serverId),
          syncStatus: Value(SyncStatus.synced.name),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      switch (item.recordType) {
        case 'boat':
          await (update(
            boatRows,
          )..where((row) => row.localId.equals(localId))).write(
            BoatRowsCompanion(
              serverId: Value(serverId),
              syncStatus: Value(SyncStatus.synced.name),
              retryCount: const Value(0),
              lastError: const Value(null),
            ),
          );
          break;
        case 'trip':
          await (update(
            fishingTripRows,
          )..where((row) => row.localId.equals(localId))).write(
            FishingTripRowsCompanion(
              serverId: Value(serverId),
              syncStatus: Value(SyncStatus.synced.name),
              retryCount: const Value(0),
              lastError: const Value(null),
            ),
          );
          break;
        case 'catch':
          await (update(
            catchDraftRows,
          )..where((row) => row.localId.equals(localId))).write(
            CatchDraftRowsCompanion(
              serverId: Value(serverId),
              syncStatus: Value(SyncStatus.synced.name),
              retryCount: const Value(0),
              lastError: const Value(null),
            ),
          );
          await (update(
            catchPhotoRows,
          )..where((row) => row.catchLocalId.equals(localId))).write(
            CatchPhotoRowsCompanion(syncStatus: Value(SyncStatus.synced.name)),
          );
          break;
        case 'batch':
          await (update(
            batchDraftRows,
          )..where((row) => row.localId.equals(localId))).write(
            BatchDraftRowsCompanion(
              serverId: Value(serverId),
              syncStatus: Value(SyncStatus.synced.name),
              retryCount: const Value(0),
              lastError: const Value(null),
            ),
          );
          break;
        default:
          break;
      }
    });
  }

  Future<void> replaceReferenceData(
    String category,
    Map<String, String> records,
  ) => transaction(() async {
    await (delete(
      referenceDataRows,
    )..where((row) => row.category.equals(category))).go();
    final now = DateTime.now().toUtc();
    for (final entry in records.entries) {
      await into(referenceDataRows).insert(
        ReferenceDataRowsCompanion.insert(
          key: entry.key,
          category: category,
          payload: entry.value,
          fetchedAt: now,
        ),
      );
    }
  });

  Future<void> saveAuthMetadata(User user) =>
      into(authMetadataRows).insertOnConflictUpdate(
        AuthMetadataRowsCompanion.insert(
          userId: user.email,
          displayName: user.name,
          email: user.email,
          role: user.role.name,
          lastLoginAt: DateTime.now().toUtc(),
        ),
      );
}

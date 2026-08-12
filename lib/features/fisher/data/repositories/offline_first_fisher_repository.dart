import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/fishtrace_database.dart';
import '../../../../core/models/models.dart';
import '../../../../core/network/api_models.dart';
import '../../domain/entities/fisher_entities.dart';
import '../../domain/repositories/fisher_repository.dart';

class OfflineFirstFisherRepository
    implements FisherRepository, FisherDraftStore {
  OfflineFirstFisherRepository({
    required FisherRepository remote,
    required FishTraceDatabase database,
    required bool Function() isOffline,
    Future<void> Function(FisherBoat boat)? queueBoat,
    bool Function()? canUseRemote,
  }) : _remote = remote,
       _database = database,
       _isOffline = isOffline,
       _queueBoat = queueBoat ?? ((_) async {}),
       _canUseRemote = canUseRemote ?? (() => !isOffline());

  final FisherRepository _remote;
  final FishTraceDatabase _database;
  final bool Function() _isOffline;
  final Future<void> Function(FisherBoat boat) _queueBoat;
  final bool Function() _canUseRemote;

  @override
  Future<List<FisherBoat>> getBoats({PageQuery? query}) => _networkFirst(
    remote: () => _remote.getBoats(query: query),
    cache: _cacheBoats,
    local: _localBoats,
  );

  @override
  Future<PaginatedResponse<FisherBoat>> getBoatsPage(PageQuery query) async {
    if (_canUseRemote()) {
      try {
        final page = await _remote.getBoatsPage(query);
        await _cacheBoats(page.items);
        return page;
      } catch (_) {
        final local = await _localBoatPage(query);
        if (local.items.isNotEmpty) return local;
        rethrow;
      }
    }
    return _localBoatPage(query);
  }

  Future<PaginatedResponse<FisherBoat>> _localBoatPage(PageQuery query) async {
    final search = query.search?.trim().toLowerCase() ?? '';
    final values = (await _localBoats())
        .where(
          (boat) =>
              search.isEmpty ||
              boat.name.toLowerCase().contains(search) ||
              boat.registration.toLowerCase().contains(search),
        )
        .toList(growable: false);
    final start = ((query.page - 1) * query.perPage).clamp(0, values.length);
    final end = (start + query.perPage).clamp(start, values.length);
    return PaginatedResponse(
      items: values.sublist(start, end),
      currentPage: query.page,
      lastPage: (values.length / query.perPage).ceil().clamp(1, 1 << 31),
      total: values.length,
    );
  }

  @override
  Future<List<FisherCatch>> getCatches() => _networkFirst(
    remote: _remote.getCatches,
    cache: _cacheCatches,
    local: _localCatches,
  );

  @override
  Future<FisherCatchReferenceData> getCatchReferenceData() async {
    if (_canUseRemote()) {
      try {
        final data = await _remote.getCatchReferenceData();
        await _cacheCatchReferenceData(data);
        return data;
      } catch (_) {
        final cached = await _localCatchReferenceData();
        if (cached.species.isNotEmpty && cached.gearTypes.isNotEmpty) {
          return cached;
        }
        rethrow;
      }
    }
    return _localCatchReferenceData();
  }

  Future<void> _cacheCatchReferenceData(FisherCatchReferenceData data) =>
      _database.replaceReferenceData('fisher_catch_options', {
        'current': jsonEncode({
          'species': [
            for (final item in data.species)
              {
                'id': item.id,
                'common_name': item.commonName,
                'scientific_name': item.scientificName,
              },
          ],
          'gear_types': data.gearTypes,
        }),
      });

  Future<FisherCatchReferenceData> _localCatchReferenceData() async {
    final row =
        await (_database.select(_database.referenceDataRows)
              ..where(
                (item) =>
                    item.category.equals('fisher_catch_options') &
                    item.key.equals('current'),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return const FisherCatchReferenceData.empty();
    final payload = (jsonDecode(row.payload) as Map).cast<String, Object?>();
    final species = (payload['species'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .map(
          (item) => FisherSpeciesReference(
            id: item['id']?.toString() ?? '',
            commonName: item['common_name']?.toString() ?? '',
            scientificName: item['scientific_name']?.toString() ?? '',
          ),
        )
        .where((item) => item.id.isNotEmpty && item.commonName.isNotEmpty)
        .toList(growable: false);
    final gears = (payload['gear_types'] as List? ?? const [])
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return FisherCatchReferenceData(species: species, gearTypes: gears);
  }

  @override
  Future<List<FisherBatchSummary>> getBatches() => _networkFirst(
    remote: _remote.getBatches,
    cache: _cacheBatches,
    local: _localBatches,
  );

  @override
  Future<FisherBatchDetails> getBatchDetails(String id) =>
      _remote.getBatchDetails(id);

  @override
  Future<ActiveFishingTrip?> getActiveTrip() async {
    if (_canUseRemote()) {
      try {
        final trip = await _remote.getActiveTrip();
        if (trip != null) await _cacheTrip(trip);
        return trip;
      } catch (_) {
        final local = await _localTrip();
        if (local != null) return local;
        rethrow;
      }
    }
    return _localTrip();
  }

  @override
  Future<FisherBoat> saveBoat(FisherBoat boat) async {
    if (_isOffline()) {
      await _cacheBoats([boat], status: SyncStatus.pending);
      await _queueBoat(boat);
      return boat;
    }
    final saved = await _remote.saveBoat(boat);
    await _cacheBoats([saved]);
    return saved;
  }

  Future<List<T>> _networkFirst<T>({
    required Future<List<T>> Function() remote,
    required Future<void> Function(List<T>) cache,
    required Future<List<T>> Function() local,
  }) async {
    if (_canUseRemote()) {
      try {
        final values = await remote();
        await cache(values);
        return values;
      } catch (_) {
        final values = await local();
        if (values.isNotEmpty) return values;
        rethrow;
      }
    }
    return local();
  }

  Future<void> _cacheBoats(
    List<FisherBoat> boats, {
    SyncStatus status = SyncStatus.synced,
  }) async {
    final now = DateTime.now();
    final localIds = <String, String>{};
    for (final boat in boats) {
      localIds[boat.id] = status == SyncStatus.synced
          ? (await _database.resolveLocalId('boat', boat.id) ?? boat.id)
          : boat.id;
    }
    await _database.batch((batch) {
      for (final boat in boats) {
        batch.insert(
          _database.boatRows,
          BoatRowsCompanion.insert(
            localId: localIds[boat.id]!,
            serverId: Value(status == SyncStatus.synced ? boat.id : null),
            name: boat.name,
            registration: boat.registration,
            lengthMetres: boat.lengthMetres,
            engine: boat.engineDetails,
            boatType: boat.type,
            homePort: boat.homePort,
            active: Value(boat.active),
            syncStatus: Value(status.name),
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<FisherBoat>> _localBoats() async =>
      (await _database.select(_database.boatRows).get())
          .map(
            (row) => FisherBoat(
              id: row.serverId ?? row.localId,
              name: row.name,
              registration: row.registration,
              lengthMetres: row.lengthMetres,
              engineDetails: row.engine,
              type: row.boatType,
              homePort: row.homePort,
              active: row.active,
            ),
          )
          .toList(growable: false);

  Future<void> _cacheTrip(
    ActiveFishingTrip trip, {
    SyncStatus status = SyncStatus.synced,
  }) async {
    final mappedId = status == SyncStatus.pending
        ? await _database.resolveServerId(trip.id)
        : trip.id;
    final localId = status == SyncStatus.synced
        ? (await _database.resolveLocalId('trip', trip.id) ?? trip.id)
        : trip.id;
    await _database
        .into(_database.fishingTripRows)
        .insert(
          FishingTripRowsCompanion.insert(
            localId: localId,
            serverId: Value(mappedId),
            boatId: trip.boatId,
            boatName: trip.boatName,
            startedAt: trip.startedAt,
            fishingArea: trip.fishingArea,
            latitude: Value(trip.latitude),
            longitude: Value(trip.longitude),
            crewJson: Value(jsonEncode(trip.crew)),
            catchKg: Value(trip.catchKg),
            batchCount: Value(trip.batchCount),
            status: trip.status.name,
            syncStatus: Value(
              mappedId == null ? status.name : SyncStatus.synced.name,
            ),
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<ActiveFishingTrip?> _localTrip() async {
    final rows =
        await (_database.select(_database.fishingTripRows)
              ..where((row) => row.status.equals(TripStatus.inProgress.name))
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    final row = rows.first;
    final legacyCoordinates = _coordinatesFromText(row.fishingArea);
    return ActiveFishingTrip(
      id: row.serverId ?? row.localId,
      boatId: row.boatId,
      boatName: row.boatName,
      startedAt: row.startedAt,
      fishingArea: row.fishingArea,
      latitude: row.latitude ?? legacyCoordinates?.$1,
      longitude: row.longitude ?? legacyCoordinates?.$2,
      crew: (jsonDecode(row.crewJson) as List).cast<String>(),
      catchKg: row.catchKg,
      batchCount: row.batchCount,
      status: TripStatus.values.byName(row.status),
    );
  }

  static (double, double)? _coordinatesFromText(String value) {
    final matches = RegExp(r'-?\d+(?:\.\d+)?').allMatches(value).toList();
    if (matches.length < 2) return null;
    var latitude = double.tryParse(matches[0].group(0)!);
    var longitude = double.tryParse(matches[1].group(0)!);
    if (latitude == null || longitude == null) return null;
    final upper = value.toUpperCase();
    if (upper.contains('S') && latitude > 0) latitude = -latitude;
    if (upper.contains('W') && longitude > 0) longitude = -longitude;
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }
    return (latitude, longitude);
  }

  Future<void> _cacheCatches(
    List<FisherCatch> catches, {
    SyncStatus syncStatus = SyncStatus.synced,
    String? tripId,
  }) async {
    final now = DateTime.now();
    final serverIds = <String, String?>{};
    final localIds = <String, String>{};
    for (final item in catches) {
      serverIds[item.id] = syncStatus == SyncStatus.pending
          ? await _database.resolveServerId(item.id)
          : item.id;
      localIds[item.id] = syncStatus == SyncStatus.synced
          ? (await _database.resolveLocalId('catch', item.id) ?? item.id)
          : item.id;
    }
    await _database.transaction(() async {
      for (final item in catches) {
        final serverId = serverIds[item.id];
        await _database
            .into(_database.catchDraftRows)
            .insert(
              CatchDraftRowsCompanion.insert(
                localId: localIds[item.id]!,
                serverId: Value(serverId),
                tripId: tripId ?? 'unassigned',
                species: item.species,
                scientificName: item.scientificName,
                weightKg: item.weightKg,
                quantity: item.quantity,
                caughtAt: item.caughtAt,
                latitude: item.latitude,
                longitude: item.longitude,
                gear: item.gear,
                condition: item.condition,
                verified: Value(item.verified),
                linkedBatchId: Value(item.linkedBatchId),
                syncStatus: Value(
                  serverId == null ? syncStatus.name : SyncStatus.synced.name,
                ),
                createdAt: item.caughtAt,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrReplace,
            );
        for (var index = 0; index < item.photoPaths.length; index++) {
          await _database
              .into(_database.catchPhotoRows)
              .insert(
                CatchPhotoRowsCompanion.insert(
                  id: '${localIds[item.id]}-$index',
                  catchLocalId: localIds[item.id]!,
                  localPath: item.photoPaths[index],
                  remoteUrl: Value(item.photoPaths[index]),
                  syncStatus: Value(syncStatus.name),
                  createdAt: now,
                ),
                mode: InsertMode.insertOrReplace,
              );
        }
      }
    });
  }

  Future<List<FisherCatch>> _localCatches() async {
    final rows = await _database.select(_database.catchDraftRows).get();
    final photos = await _database.select(_database.catchPhotoRows).get();
    return rows
        .map(
          (row) => FisherCatch(
            id: row.serverId ?? row.localId,
            tripId: row.tripId,
            species: row.species,
            scientificName: row.scientificName,
            weightKg: row.weightKg,
            quantity: row.quantity,
            caughtAt: row.caughtAt,
            latitude: row.latitude,
            longitude: row.longitude,
            gear: row.gear,
            condition: row.condition,
            verified: row.verified,
            photoPaths: photos
                .where((photo) => photo.catchLocalId == row.localId)
                .map((photo) => photo.localPath)
                .toList(),
            linkedBatchId: row.linkedBatchId,
            allocatedWeightKg: row.linkedBatchId == null ? 0 : row.weightKg,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _cacheBatches(
    List<FisherBatchSummary> batches, {
    SyncStatus syncStatus = SyncStatus.synced,
  }) async {
    final now = DateTime.now();
    final serverIds = <String, String?>{};
    final localIds = <String, String>{};
    for (final item in batches) {
      serverIds[item.id] = syncStatus == SyncStatus.pending
          ? await _database.resolveServerId(item.id)
          : item.id;
      localIds[item.id] = syncStatus == SyncStatus.synced
          ? (await _database.resolveLocalId('batch', item.id) ?? item.id)
          : item.id;
    }
    await _database.batch((batch) {
      for (final item in batches) {
        final serverId = serverIds[item.id];
        batch.insert(
          _database.batchDraftRows,
          BatchDraftRowsCompanion.insert(
            localId: localIds[item.id]!,
            serverId: Value(serverId),
            tripId: item.tripId,
            species: item.species,
            weightKg: item.weightKg,
            fishCount: item.fishCount,
            grade: item.grade.name,
            status: item.status.name,
            syncStatus: Value(
              serverId == null ? syncStatus.name : SyncStatus.synced.name,
            ),
            createdAt: item.createdAt,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<FisherBatchSummary>> _localBatches() async =>
      (await _database.select(_database.batchDraftRows).get())
          .map(
            (row) => FisherBatchSummary(
              id: row.serverId ?? row.localId,
              species: row.species,
              weightKg: row.weightKg,
              fishCount: row.fishCount,
              grade: QualityGrade.values.byName(row.grade),
              status: BatchStatus.values.byName(row.status),
              tripId: row.tripId,
              createdAt: row.createdAt,
            ),
          )
          .toList(growable: false);

  @override
  Future<void> saveCatchDraft(FisherCatch value, {required String tripId}) =>
      _cacheCatches([value], syncStatus: SyncStatus.pending, tripId: tripId);

  @override
  Future<void> saveBatchDraft(FisherBatchSummary value) =>
      _cacheBatches([value], syncStatus: SyncStatus.pending);

  @override
  Future<void> saveTripDraft(ActiveFishingTrip value) =>
      _cacheTrip(value, status: SyncStatus.pending);
}

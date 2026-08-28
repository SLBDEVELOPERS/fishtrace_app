import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/authentication/domain/repositories/firebase_session_repository.dart';
import '../database/fishtrace_database.dart';
import '../errors/app_exceptions.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_support.dart';
import '../network/fisher_request_dtos.dart';
import '../network/processor_request_dtos.dart';
import '../network/retailer_request_dtos.dart';
import '../network/sensor_stream.dart';
import '../network/transporter_request_dtos.dart';
import '../network/user_dto.dart';
import '../storage/secure_token_store.dart';

abstract interface class AuthRepository {
  Future<User> login(String email, String password);

  Future<User> me();

  Future<void> logout({bool allDevices = false});

  Future<void> forgotPassword(String identifier);

  Future<String> verifyOtp(String identifier, String otp);

  Future<void> resetPassword({
    required String identifier,
    required String resetToken,
    required String password,
    required String confirmation,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  });
}

abstract interface class SyncRepository {
  Future<List<SyncQueueItem>> getQueue();

  Future<void> put(SyncQueueItem item);

  Future<void> remove(String id);
}

abstract interface class OfflineRepository implements SyncRepository {
  Future<void> saveDraft({
    required String id,
    required String type,
    required Map<String, Object?> payload,
  });

  Future<void> saveAuthMetadata(User user);

  Future<void> markSynced(SyncQueueItem item, String serverId);
}

abstract interface class SyncTransport {
  Future<String> upload(SyncQueueItem item);
}

class _NoopFirebaseSessionRepository implements FirebaseSessionRepository {
  @override
  bool get isAuthenticated => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> createSession() async {}

  @override
  Future<void> signOut() async {}
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password != 'FishTrace@2026') {
      throw Exception('Use the documented demo password.');
    }
    final normalizedEmail = email.trim().toLowerCase();
    final role = UserRole.values.firstWhere(
      (item) => normalizedEmail.startsWith('${item.name}@'),
      orElse: () => UserRole.fisher,
    );
    final signedIn = User(
      name: 'Alex Johnson',
      email: normalizedEmail,
      role: role,
    );
    _lastUser = signedIn;
    return signedIn;
  }

  User? _lastUser;

  @override
  Future<User> me() async =>
      _lastUser ??
      const User(
        name: 'Alex Johnson',
        email: 'fisher@fishtrace.demo',
        role: UserRole.fisher,
      );

  @override
  Future<void> logout({bool allDevices = false}) async => _lastUser = null;

  @override
  Future<void> forgotPassword(String identifier) async =>
      Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<String> verifyOtp(String identifier, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'mock-reset-token';
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String resetToken,
    required String password,
    required String confirmation,
  }) async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) async {}
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, {required TokenStorage tokenStore})
    : _tokenStore = tokenStore;
  final ApiClient _api;
  final TokenStorage _tokenStore;

  @override
  Future<User> login(String email, String password) async {
    final data = ApiData.map(
      await _api.post(
        ApiEndpoints.login,
        data: {
          'email': email.trim(),
          'password': password,
          'device_name': 'fishtrace-${Platform.operatingSystem}',
        },
      ),
    );
    final payload = data['data'] is Map ? ApiData.map(data['data']) : data;
    final userData = payload['user'] is Map
        ? ApiData.map(payload['user'])
        : payload;
    final accessToken = ApiData.string(
      payload,
      'token',
      ApiData.string(payload, 'access_token'),
    );
    if (accessToken.isNotEmpty) {
      await _tokenStore.save(accessToken: accessToken);
    }
    return _user(userData);
  }

  @override
  Future<User> me() async {
    final data = ApiData.map(await _api.get(ApiEndpoints.me));
    return _user(data['data'] is Map ? ApiData.map(data['data']) : data);
  }

  @override
  Future<void> logout({bool allDevices = false}) async {
    await _api.post(allDevices ? ApiEndpoints.logoutAll : ApiEndpoints.logout);
  }

  @override
  Future<void> forgotPassword(String identifier) async {
    await _api.post(ApiEndpoints.forgotPassword, data: {'email': identifier});
  }

  @override
  Future<String> verifyOtp(String identifier, String otp) async {
    final response = ApiData.map(
      await _api.post(
        ApiEndpoints.verifyOtp,
        data: {'email': identifier, 'otp': otp},
      ),
    );
    final payload = response['data'] is Map
        ? ApiData.map(response['data'])
        : response;
    final token = ApiData.string(payload, 'resetToken');
    if (token.isEmpty) {
      throw const ApiException(
        'The password reset token was missing.',
        code: 'invalid_reset_response',
      );
    }
    return token;
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String resetToken,
    required String password,
    required String confirmation,
  }) async {
    await _api.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': identifier,
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': confirmation,
      },
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) async {
    await _api.post(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': confirmation,
      },
    );
  }

  User _user(Map<String, Object?> json) {
    return UserDto.fromJson(json).toDomain();
  }
}

typedef DioAuthRepository = ApiAuthRepository;

class MemoryOfflineRepository implements OfflineRepository {
  final List<SyncQueueItem> _items = [];

  @override
  Future<List<SyncQueueItem>> getQueue() async => List.unmodifiable(_items);

  @override
  Future<void> put(SyncQueueItem item) async {
    _items.removeWhere((existing) => existing.id == item.id);
    _items.add(item);
  }

  @override
  Future<void> remove(String id) async =>
      _items.removeWhere((item) => item.id == id);

  @override
  Future<void> saveDraft({
    required String id,
    required String type,
    required Map<String, Object?> payload,
  }) async {}

  @override
  Future<void> saveAuthMetadata(User user) async {}

  @override
  Future<void> markSynced(SyncQueueItem item, String serverId) async {}
}

class DriftOfflineRepository implements OfflineRepository {
  DriftOfflineRepository(this._database);

  final FishTraceDatabase _database;

  @override
  Future<List<SyncQueueItem>> getQueue() => _database.getQueueItems();

  @override
  Future<void> put(SyncQueueItem item) => _database.putQueueItem(item);

  @override
  Future<void> remove(String id) => _database.deleteQueueItem(id);

  @override
  Future<void> saveDraft({
    required String id,
    required String type,
    required Map<String, Object?> payload,
  }) => _database.saveLocalRecord(
    localId: id,
    recordType: type,
    payload: jsonEncode(payload),
  );

  @override
  Future<void> saveAuthMetadata(User user) => _database.saveAuthMetadata(user);

  @override
  Future<void> markSynced(SyncQueueItem item, String serverId) =>
      _database.markRecordSynced(item, serverId);
}

class MockSyncTransport implements SyncTransport {
  @override
  Future<String> upload(SyncQueueItem item) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return 'server-${item.id}';
  }
}

class DisabledSyncTransport implements SyncTransport {
  const DisabledSyncTransport();

  @override
  Future<String> upload(SyncQueueItem item) => Future.error(
    const NetworkException('API synchronization is not configured.'),
  );
}

class DioSyncTransport implements SyncTransport {
  DioSyncTransport(this._dio, {FishTraceDatabase? database})
    : _database = database;
  final Dio _dio;
  final FishTraceDatabase? _database;
  final Map<String, String> _serverIds = {};
  bool _mappingsLoaded = false;
  final Map<String, String> _processingRecordIds = {};
  final Map<String, String> _processingStepIds = {};
  Map<String, Object?>? _fisherReferences;

  @override
  Future<String> upload(SyncQueueItem item) async {
    await _loadMappings();
    final source = (jsonDecode(item.payload) as Map).cast<String, Object?>();
    final request = await _prepare(item, source);
    final response = await _dio.request<Object?>(
      request.path,
      data: request.data,
      options: Options(
        method: request.method,
        headers: {'Idempotency-Key': item.idempotencyKey},
      ),
    );
    final responseMap = response.data is Map
        ? (response.data as Map).cast<String, Object?>()
        : const <String, Object?>{};
    final payload = responseMap['data'] is Map
        ? (responseMap['data'] as Map).cast<String, Object?>()
        : responseMap;
    final serverId = payload['id']?.toString() ?? item.id;
    _serverIds[item.id] = serverId;
    if (item.clientRecordId != null) {
      _serverIds[item.clientRecordId!] = serverId;
    }
    final batchId = source['batchId']?.toString();
    if (item.recordType == 'processing' && batchId != null) {
      _processingRecordIds[batchId] = serverId;
      _cacheProcessingSteps(batchId, payload['steps']);
    }
    if (item.recordType == 'trip' &&
        item.label.toLowerCase().contains('start')) {
      await _dio.post<Object?>(ApiEndpoints.fishingTripStart(serverId));
    }
    await _uploadAttachments(item, source, serverId);
    return serverId;
  }

  Future<void> _loadMappings() async {
    if (_mappingsLoaded || _database == null) return;
    _serverIds.addAll(await _database.getServerIdMappings());
    _mappingsLoaded = true;
  }

  Future<void> _uploadAttachments(
    SyncQueueItem item,
    Map<String, Object?> source,
    String serverId,
  ) async {
    if (item.localFileReferences.isEmpty) return;
    final metadata = switch (item.recordType) {
      'catch' => ('CATCH_IMAGE', 'catch_record', serverId),
      'processing' => ('PROCESSING_IMAGE', 'processing_record', serverId),
      'inspection' => ('INSPECTION_IMAGE', 'quality_inspection', serverId),
      'delivery' => (
        'DELIVERY_IMAGE',
        'transport_trip',
        _remoteId(source['tripId']) ?? serverId,
      ),
      _ => null,
    };
    if (metadata == null) return;
    for (final path in item.localFileReferences) {
      final file = File(path);
      if (!await file.exists()) {
        throw NotFoundException(
          'An attachment selected for ${item.label} is no longer available.',
        );
      }
      final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
      await _dio.post<Object?>(
        ApiEndpoints.files,
        data: FormData.fromMap({
          'category':
              item.recordType == 'delivery' &&
                  path == source['signaturePath']?.toString()
              ? 'DELIVERY_SIGNATURE'
              : metadata.$1,
          'entity_type': metadata.$2,
          'entity_id': metadata.$3,
          'file': await MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[/\\]')).last,
            contentType: DioMediaType.parse(mimeType),
          ),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
    }
  }

  Future<_PreparedSyncRequest> _prepare(
    SyncQueueItem item,
    Map<String, Object?> source,
  ) async {
    final type = item.recordType;
    if (type == 'boat') {
      return _PreparedSyncRequest(item.endpoint, item.requestMethod, {
        'name': source['name'],
        'registration_number': source['registration'],
        'type': source['type'],
        'length_meters': source['lengthMetres'],
        'engine_details': source['engineDetails'],
        'home_port': source['homePort'],
        'is_active': source['active'],
      });
    }
    if (type == 'catch') {
      final tripId = _remoteId(source['tripId']);
      if (tripId == null) {
        throw const ApiException(
          'Fishing Trip ID is missing. A catch cannot be synchronized without an active trip.',
          code: 'missing_trip_id',
        );
      }
      final speciesId = await _fisherReferenceId(
        'species',
        source['species'],
        const ['common_name'],
      );
      final gearId = await _fisherReferenceId(
        'gear_types',
        source['gear'],
        const ['name'],
        required: false,
      );
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        CreateCatchRequestDto(
          fishingTripId: tripId,
          fishSpeciesId: speciesId!,
          fishingGearTypeId: gearId,
          weightKg: (source['weightKg'] as num).toDouble(),
          quantity: (source['quantity'] as num).toInt(),
          condition: _apiEnum(source['condition']),
          latitude: (source['latitude'] as num).toDouble(),
          longitude: (source['longitude'] as num).toDouble(),
          caughtAt: DateTime.parse(source['caughtAt'].toString()),
          clientRecordId: item.id,
          clientCreatedAt: item.createdAt,
          notes: source['notes']?.toString(),
        ).toJson(),
      );
    }
    if (type == 'batch') {
      final catches = (source['catches'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (entry) => BatchCatchAllocationDto(
              catchId: _remoteId(entry['catchId'])!,
              weightKg: (entry['weightKg'] as num).toDouble(),
            ),
          )
          .toList();
      final speciesId = await _fisherReferenceId(
        'species',
        source['species'],
        const ['common_name'],
      );
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        CreateBatchRequestDto(
          fishSpeciesId: speciesId!,
          productType: _apiEnum(source['processingType']),
          qualityGrade: _apiEnum(source['qualityGrade']),
          storageTemperatureCelsius: (source['storageTemperature'] as num)
              .toDouble(),
          iceType: _apiEnum(source['iceType']),
          iceAmountKg: (source['iceAmountKg'] as num).toDouble(),
          landingSiteName: source['landingSite'].toString(),
          notes: source['notes']?.toString(),
          catches: catches,
        ).toJson(),
      );
    }
    if (type == 'trip' && !item.label.toLowerCase().contains('end')) {
      final area = (source['fishingArea'] as Map).cast<String, Object?>();
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        CreateFishingTripRequestDto(
          boatId: _remoteId(source['boatId'])!,
          tripCode: source['tripCode'].toString(),
          clientRecordId: item.id,
          landingSiteId: await _firstFisherReferenceId('landing_sites'),
          generalCatchArea: _fishingArea(area),
          plannedDepartureAt: DateTime.parse(source['departure'].toString()),
          expectedDurationHours: (source['expectedHours'] as num).toDouble(),
          fishingAreaLatitude: (area['latitude'] as num).toDouble(),
          fishingAreaLongitude: (area['longitude'] as num).toDouble(),
          crew: (source['crew'] as List)
              .map((value) => value.toString())
              .toList(),
          notes: source['notes']?.toString(),
        ).toJson(),
      );
    }
    if (type == 'trip') {
      return _PreparedSyncRequest(
        ApiEndpoints.fishingTripComplete(_remoteId(source['tripId'])!),
        'POST',
        const {},
      );
    }
    if (type == 'intake') {
      final rejected = source['decision'] == 'rejected';
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        if (rejected) 'rejection_reason': source['reason'],
        'received_weight_kg': source['receivedWeightKg'],
        'notes': source['notes'],
      });
    }
    if (type == 'processing') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        CreateProcessingRecordRequestDto(
          fishBatchId: _remoteId(source['batchId'])!,
          inputWeightKg: (source['inputWeightKg'] as num).toDouble(),
          operatorName: source['operator'].toString(),
          processingArea: source['area'].toString(),
          notes: source['notes']?.toString(),
        ).toJson(),
      );
    }
    if (type == 'processing-step-start' || type == 'processing-step-complete') {
      final batchId = _remoteId(source['batchId'])!;
      final stepType = _apiEnum(source['step']);
      final recordId = await _processingRecordId(batchId);
      final stepId = await _processingStepId(batchId, stepType);
      if (type == 'processing-step-start') {
        return _PreparedSyncRequest(
          ApiEndpoints.processingStepStart(recordId, stepId),
          'POST',
          const {},
        );
      }
      final measurements = source['measurements'] is Map
          ? (source['measurements'] as Map).cast<String, Object?>()
          : const <String, Object?>{};
      return _PreparedSyncRequest(
        ApiEndpoints.processingStepComplete(recordId, stepId),
        'POST',
        CompleteProcessingStepRequestDto(
          measurements: measurements,
          notes: source['notes']?.toString(),
        ).toJson(),
      );
    }
    if (type == 'inspection') {
      final batchId = _remoteId(source['batchId']);
      if (batchId == null || batchId.isEmpty) {
        throw const ApiException(
          'A batch ID is required for quality inspection.',
          code: 'missing_batch_id',
        );
      }
      final processingId = await _processingRecordId(batchId);
      final criteria = source['criteria'] is Map
          ? (source['criteria'] as Map).cast<String, Object?>()
          : const <String, Object?>{};
      final results = criteria.values.map(_apiEnum).toSet();
      final result = results.contains('FAIL')
          ? 'FAILED'
          : results.contains('WARNING')
          ? 'CONDITIONAL'
          : 'PASSED';
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'processing_record_id': processingId,
        'result': result,
        'quality_grade': _apiEnum(source['grade']),
        'product_temperature': source['temperature'],
        'appearance': _criterion(source, 'Appearance'),
        'odor': _criterion(source, 'Odour'),
        'notes': source['comments'],
      });
    }
    if (type == 'child-batches') {
      final packaging = source['packagingType']?.toString();
      final children = (source['children'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (entry) => {
              'weight_kg': entry['weightKg'],
              'product_type': packaging,
              'package_count': 1,
            },
          )
          .toList();
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'children': children,
      });
    }
    if (type == 'trip-batch') {
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'batch_id': _remoteId(source['batchId']),
      });
    }
    if (type == 'transport-trip') {
      return _PreparedSyncRequest(item.endpoint, item.requestMethod, {
        'vehicle_id': _remoteId(source['vehicleId']),
        'driver_name': source['driver'],
        'origin': source['origin'],
        'destination': source['destination'],
        'estimated_distance_km': source['distanceKm'],
        if (source['originLatitude'] != null)
          'origin_latitude': source['originLatitude'],
        if (source['originLongitude'] != null)
          'origin_longitude': source['originLongitude'],
        if (source['destinationLatitude'] != null)
          'destination_latitude': source['destinationLatitude'],
        if (source['destinationLongitude'] != null)
          'destination_longitude': source['destinationLongitude'],
        if (source['scheduledAt'] != null)
          'scheduled_at': DateTime.parse(
            source['scheduledAt'].toString(),
          ).toUtc().toIso8601String(),
      });
    }
    if (type == 'transport-cancel') {
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'reason': source['reason'],
      });
    }
    if (type == 'transport-remove-batch' || type == 'transport-remove-device') {
      return _PreparedSyncRequest(item.endpoint, 'DELETE', const {});
    }
    if (type == 'device-assignment') {
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'iot_device_id': _remoteId(source['deviceId']),
      });
    }
    if (type == 'checklist') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        UpdateTransportChecklistRequestDto(
          completedLabels: (source['completed'] as List? ?? const [])
              .map((value) => value.toString())
              .toSet(),
        ).toJson(),
      );
    }
    if (type == 'delivery') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        StoreDeliveryConfirmationRequestDto(
          receiverName: source['receiver'].toString(),
          receiverContact: source['receiverContact']?.toString(),
          notes: source['notes']?.toString(),
          deliveredAt: DateTime.parse(source['completedAt'].toString()),
        ).toJson(),
      );
    }
    if (type == 'transport-start' ||
        type == 'transport-arrival' ||
        type == 'transport-complete') {
      return _PreparedSyncRequest(item.endpoint, 'POST', const {});
    }
    if (type == 'alert-acknowledgement') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        AcknowledgeTransportAlertRequestDto(
          note: source['note']?.toString(),
        ).toJson(),
      );
    }
    if (type == 'incident') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        StoreTransportIncidentRequestDto(
          type: source['type'].toString(),
          severity: _apiEnum(source['severity']),
          description: source['description'].toString(),
          occurredAt: DateTime.parse(source['occurredAt'].toString()),
        ).toJson(),
      );
    }
    if (type == 'vehicle') {
      final registration = source['registration']?.toString() ?? '';
      return _PreparedSyncRequest(
        item.endpoint,
        item.requestMethod,
        UpsertVehicleRequestDto(
          registrationNumber: registration,
          name: source['name']?.toString() ?? registration,
          capacityTonnes: (source['capacityTonnes'] as num).toDouble(),
          isActive: item.requestMethod == 'PUT' ? true : null,
        ).toJson(),
      );
    }
    if (type == 'receipt') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        StoreRetailReceiptRequestDto(
          packageLabelId: _remoteId(source['packageLabelId'])!,
          retailLocationId: await _retailLocationId(),
          receivedPackageCount:
              (source['receivedPackageCount'] as num?)?.toInt() ?? 1,
          conditionTemperature: (source['conditionTemperature'] as num?)
              ?.toDouble(),
          notes: source['notes']?.toString(),
        ).toJson(),
      );
    }
    if (type == 'sale') {
      final lotId = _remoteId(source['productId']);
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'retail_location_id': await _retailLocationId(lotId: lotId),
        'client_reference': item.id,
        'items': [
          {
            'inventory_lot_id': lotId,
            'quantity': _positiveInteger(source['quantityPackages']),
            'unit_price': source['unitPrice'],
          },
        ],
      });
    }
    if (type == 'stock') {
      final quantity = (source['quantityPackages'] as num?)?.toDouble() ?? 0;
      return _PreparedSyncRequest(item.endpoint, 'POST', {
        'inventory_lot_id': _remoteId(source['productId']),
        'direction': quantity < 0 ? 'REMOVE' : 'ADD',
        'quantity': _positiveInteger(quantity.abs()),
        'reason': 'Manual inventory adjustment from FishTrace mobile',
      });
    }
    if (type == 'recall') {
      final alertId = source['alertId']?.toString();
      if (alertId == null || alertId.isEmpty) {
        throw const ApiException(
          'A recall alert ID is required to quarantine inventory.',
          code: 'missing_recall_alert',
        );
      }
      return _PreparedSyncRequest(
        ApiEndpoints.quarantineRecall(alertId),
        'POST',
        {'reason': source['reason'] ?? 'Quarantined from FishTrace mobile'},
      );
    }
    if (type == 'retail-alert-resolution') {
      return _PreparedSyncRequest(
        item.endpoint,
        'POST',
        ResolveRetailAlertRequestDto(note: source['note'].toString()).toJson(),
      );
    }
    return _PreparedSyncRequest(
      item.endpoint,
      item.requestMethod,
      ApiData.snakeCaseMap(source),
    );
  }

  String _apiEnum(Object? value) => value
      .toString()
      .trim()
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '')
      .toUpperCase();

  String? _remoteId(Object? value) {
    final id = value?.toString();
    if (id == null) return null;
    return _serverIds[id] ?? id;
  }

  Future<Map<String, Object?>> _references() async {
    if (_fisherReferences != null) return _fisherReferences!;
    final response = await _dio.get<Object?>(ApiEndpoints.fisherReferenceData);
    final envelope = ApiData.map(response.data);
    _fisherReferences = envelope['data'] is Map
        ? ApiData.map(envelope['data'])
        : envelope;
    return _fisherReferences!;
  }

  Future<String?> _fisherReferenceId(
    String listKey,
    Object? label,
    List<String> nameKeys, {
    bool required = true,
    bool retriedAfterRefresh = false,
  }) async {
    final wanted = label?.toString().trim().toLowerCase();
    final items = ApiData.listValue(await _references(), listKey);
    for (final value in items) {
      final item = ApiData.map(value);
      if (nameKeys.any(
        (key) => ApiData.string(item, key).trim().toLowerCase() == wanted,
      )) {
        return ApiData.string(item, 'id');
      }
    }
    if (!retriedAfterRefresh) {
      _fisherReferences = null;
      return _fisherReferenceId(
        listKey,
        label,
        nameKeys,
        required: required,
        retriedAfterRefresh: true,
      );
    }
    if (!required) return null;
    throw ApiException(
      'No API reference ID exists for $label.',
      code: 'missing_reference_data',
    );
  }

  Future<String?> _firstFisherReferenceId(String listKey) async {
    final values = ApiData.listValue(await _references(), listKey);
    return values.isEmpty
        ? null
        : ApiData.string(ApiData.map(values.first), 'id');
  }

  String _fishingArea(Object? value) {
    if (value is Map) {
      return '${value['latitude']}, ${value['longitude']}';
    }
    return value?.toString() ?? '';
  }

  String _criterion(Map<String, Object?> source, String key) {
    final criteria = source['criteria'];
    if (criteria is Map) return criteria[key]?.toString() ?? 'Acceptable';
    return 'Acceptable';
  }

  int _positiveInteger(Object? value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    return number.round().clamp(1, 10000);
  }

  Future<String> _processingRecordId(String batchId) async {
    final cached = _processingRecordIds[batchId];
    if (cached != null) return cached;
    final response = await _dio.get<Object?>(ApiEndpoints.processorHistory);
    for (final entry in ApiData.list(response.data)) {
      if (ApiData.string(entry, 'fishBatchId') != batchId) continue;
      final record = entry['processing_record'];
      if (record is Map) {
        final id = ApiData.string(record.cast<String, Object?>(), 'id');
        if (id.isNotEmpty) return _processingRecordIds[batchId] = id;
      }
    }
    throw const ApiException(
      'Create and synchronize the processing record before recording a processing step.',
      code: 'missing_processing_record',
    );
  }

  void _cacheProcessingSteps(String batchId, Object? value) {
    if (value is! List) return;
    for (final entry in value.whereType<Map>()) {
      final step = entry.cast<String, Object?>();
      final type = _apiEnum(step['type']);
      final id = step['id']?.toString() ?? '';
      if (type.isNotEmpty && id.isNotEmpty) {
        _processingStepIds['$batchId:$type'] = id;
      }
    }
  }

  Future<String> _processingStepId(String batchId, String type) async {
    final key = '$batchId:$type';
    final cached = _processingStepIds[key];
    if (cached != null) return cached;
    final recordId = await _processingRecordId(batchId);
    final response = await _dio.get<Object?>(
      ApiEndpoints.processingRecord(recordId),
    );
    final responseMap = response.data is Map
        ? (response.data as Map).cast<String, Object?>()
        : const <String, Object?>{};
    final record = responseMap['data'] is Map
        ? (responseMap['data'] as Map).cast<String, Object?>()
        : responseMap;
    _cacheProcessingSteps(batchId, record['steps']);
    final resolved = _processingStepIds[key];
    if (resolved != null) return resolved;
    throw ApiException(
      'The $type processing step is unavailable for this batch.',
      code: 'missing_processing_step',
    );
  }

  Future<String> _retailLocationId({String? lotId}) async {
    final inventory = await _dio.get<Object?>(ApiEndpoints.inventory);
    final items = ApiData.list(inventory.data);
    Map<String, Object?>? match;
    if (lotId != null) {
      match = items.firstWhereOrNull(
        (item) => ApiData.string(item, 'id') == lotId,
      );
    }
    match ??= items.firstOrNull;
    final id = match == null ? '' : ApiData.string(match, 'retailLocationId');
    if (id.isNotEmpty) return id;
    throw const ApiException(
      'The backend did not provide a retail location ID.',
      code: 'missing_retail_location',
    );
  }
}

class _PreparedSyncRequest {
  const _PreparedSyncRequest(this.path, this.method, this.data);

  final String path;
  final String method;
  final Map<String, Object?> data;
}

class AppController extends GetxController {
  AppController({
    required this.auth,
    OfflineRepository? offlineRepository,
    SyncTransport? syncTransport,
    TokenStorage? tokenStore,
    SensorStream? sensorStream,
    Future<void> Function(SensorReading)? sensorAlertHandler,
    FirebaseSessionRepository? firebaseSession,
    Future<Directory> Function()? attachmentRoot,
    this.autoSync = false,
  }) : _offlineRepository = offlineRepository ?? MemoryOfflineRepository(),
       _syncTransport = syncTransport ?? const DisabledSyncTransport(),
       _tokenStore = tokenStore,
       _sensorStream = sensorStream ?? const DisabledSensorStream(),
       _sensorAlertHandler = sensorAlertHandler,
       _attachmentRoot = attachmentRoot ?? getApplicationSupportDirectory,
       _firebaseSession = firebaseSession ?? _NoopFirebaseSessionRepository();

  final AuthRepository auth;
  final OfflineRepository _offlineRepository;
  final SyncTransport _syncTransport;
  final TokenStorage? _tokenStore;
  final SensorStream _sensorStream;
  final Future<void> Function(SensorReading)? _sensorAlertHandler;
  final Future<Directory> Function() _attachmentRoot;
  final FirebaseSessionRepository _firebaseSession;
  final bool autoSync;
  DateTime? _lastSensorAlertAt;
  final _uuid = const Uuid();

  final user = Rxn<User>();
  final offline = false.obs;
  final syncing = false.obs;
  final lastSuccessfulSync = Rxn<DateTime>();
  final syncItems = <SyncQueueItem>[].obs;
  final sensorHistory = <SensorReading>[].obs;
  final sensor = const SensorReading(
    productTemp: 2.1,
    airTemp: 2.3,
    humidity: 62,
    battery: 68,
  ).obs;
  StreamSubscription<SensorReading>? _sensorSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncRetryTimer;
  final Map<String, SyncQueueItem> _completedSyncResults = {};
  final Set<String> _awaitedSyncIds = {};

  @override
  void onInit() {
    super.onInit();
    unawaited(loadQueue());
  }

  Future<void> loadQueue() async {
    syncItems.assignAll(await _offlineRepository.getQueue());
    _scheduleSyncRetry();
  }

  Future<void> signIn(String email, String password) async {
    final signedIn = await auth.login(email, password);
    try {
      await _firebaseSession.createSession();
    } catch (_) {
      await _tokenStore?.clear();
      rethrow;
    }
    user.value = signedIn;
    await _offlineRepository.saveAuthMetadata(signedIn);
  }

  Future<void> signOut() async {
    try {
      await auth.logout();
    } catch (_) {
      // Local sign-out must succeed even if Laravel is unavailable.
    }
    await expireSession();
  }

  /// Clears local Laravel/Firebase state without another HTTP call. Used by
  /// the 401 interceptor to avoid recursive logout requests and redirect loops.
  Future<void> expireSession() async {
    await _firebaseSession.signOut();
    user.value = null;
    await _tokenStore?.clear();
  }

  Future<bool> restoreSession() async {
    if (_tokenStore == null || await _tokenStore.readAccessToken() == null) {
      return false;
    }
    try {
      final restored = await auth.me();
      await _firebaseSession.createSession();
      user.value = restored;
      await _offlineRepository.saveAuthMetadata(restored);
      return true;
    } catch (_) {
      await _firebaseSession.signOut();
      await _tokenStore.clear();
      user.value = null;
      return false;
    }
  }

  Future<SyncQueueItem> queue(
    String label, {
    Map<String, Object?> payload = const {},
    String? recordType,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final durablePayload = await _persistAttachments(payload, id);
    final item = SyncQueueItem(
      id: id,
      label: label,
      payload: jsonEncode(durablePayload),
      idempotencyKey: id,
      createdAt: now,
      updatedAt: now,
      recordType: recordType ?? 'operation',
      clientRecordId: durablePayload['localId']?.toString() ?? id,
      endpoint: _endpointFor(recordType ?? 'operation', label, durablePayload),
      requestMethod: _methodFor(recordType ?? 'operation', durablePayload),
      localFileReferences: [
        ...(durablePayload['photos'] as List? ?? const []),
        if (durablePayload['signaturePath'] != null)
          durablePayload['signaturePath'],
      ].map((value) => value.toString()).toList(growable: false),
    );
    final clientRecordId = durablePayload['localId']?.toString() ?? id;
    if (recordType != null) {
      await _offlineRepository.saveDraft(
        id: clientRecordId,
        type: recordType,
        payload: durablePayload,
      );
    }
    if (durablePayload['draft'] == true) return item;
    await _offlineRepository.put(item);
    syncItems.add(item);
    if (autoSync && !offline.value) {
      _awaitedSyncIds.add(item.id);
      await syncNow();
    }
    final result =
        syncItems.firstWhereOrNull((queued) => queued.id == item.id) ??
        _completedSyncResults.remove(item.id) ??
        item.copyWith(status: SyncStatus.synced, updatedAt: DateTime.now());
    _awaitedSyncIds.remove(item.id);
    return result;
  }

  Future<Map<String, Object?>> _persistAttachments(
    Map<String, Object?> payload,
    String queueId,
  ) async {
    final photos = (payload['photos'] as List? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false);
    final signature = payload['signaturePath']?.toString();
    if (photos.isEmpty && (signature == null || signature.isEmpty)) {
      return payload;
    }

    final root = await _attachmentRoot();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}pending_uploads'
      '${Platform.pathSeparator}$queueId',
    );
    await directory.create(recursive: true);

    Future<String> persist(String sourcePath, String prefix) async {
      final source = File(sourcePath);
      if (!await source.exists()) {
        throw NotFoundException(
          'A selected attachment is no longer available. Please select it again.',
        );
      }
      final originalName = sourcePath.split(RegExp(r'[/\\]')).last;
      final destination = File(
        '${directory.path}${Platform.pathSeparator}$prefix-$originalName',
      );
      await source.copy(destination.path);
      return destination.path;
    }

    final durablePhotos = <String>[];
    for (var index = 0; index < photos.length; index++) {
      durablePhotos.add(await persist(photos[index], 'photo-$index'));
    }
    final durableSignature = signature == null || signature.isEmpty
        ? null
        : await persist(signature, 'signature');

    return {
      ...payload,
      if (photos.isNotEmpty) 'photos': durablePhotos,
      if (durableSignature != null) 'signaturePath': durableSignature,
    };
  }

  String _endpointFor(String type, String label, Map<String, Object?> payload) {
    final tripId = payload['tripId']?.toString();
    final batchId = payload['batchId']?.toString();
    return switch (type) {
      'boat' when payload['id'] != null => ApiEndpoints.boat(
        payload['id'].toString(),
      ),
      'boat' => ApiEndpoints.boats,
      'catch' => ApiEndpoints.catches,
      'batch' => ApiEndpoints.batches,
      'trip' when label.toLowerCase().contains('end') && tripId != null =>
        ApiEndpoints.fishingTripComplete(tripId),
      'trip' => ApiEndpoints.fishingTrips,
      'intake' when batchId != null =>
        payload['decision'] == 'rejected'
            ? ApiEndpoints.processorReject(batchId)
            : ApiEndpoints.processorAccept(batchId),
      'inspection' => ApiEndpoints.qualityInspections,
      'processing' => ApiEndpoints.processingRecords,
      'processing-step-start' || 'processing-step-complete' => '/sync',
      'child-batches' when payload['parentBatchId'] != null =>
        ApiEndpoints.batchSplit(payload['parentBatchId'].toString()),
      'checklist' when tripId != null => ApiEndpoints.transportTripChecklist(
        tripId,
      ),
      'delivery' when tripId != null => ApiEndpoints.deliveryConfirmation(
        tripId,
      ),
      'transport-start' when tripId != null => ApiEndpoints.transportTripStart(
        tripId,
      ),
      'transport-complete' when tripId != null =>
        ApiEndpoints.transportTripComplete(tripId),
      'transport-arrival' when tripId != null =>
        ApiEndpoints.transportTripArrival(tripId),
      'alert-acknowledgement' when payload['alertId'] != null =>
        ApiEndpoints.acknowledgeTransportAlert(payload['alertId'].toString()),
      'incident' when tripId != null => ApiEndpoints.transportTripIncident(
        tripId,
      ),
      'transport-trip' when tripId != null => ApiEndpoints.transportTrip(
        tripId,
      ),
      'transport-trip' => ApiEndpoints.transportTrips,
      'transport-cancel' when tripId != null =>
        ApiEndpoints.transportTripCancel(tripId),
      'transport-remove-batch' when tripId != null && batchId != null =>
        ApiEndpoints.transportTripBatch(tripId, batchId),
      'transport-remove-device' when tripId != null =>
        ApiEndpoints.transportTripDevice(tripId),
      'trip-batch' when tripId != null => ApiEndpoints.transportTripBatches(
        tripId,
      ),
      'device-assignment' when tripId != null =>
        ApiEndpoints.transportTripDevice(tripId),
      'vehicle' when payload['id'] != null => ApiEndpoints.vehicle(
        payload['id'].toString(),
      ),
      'vehicle' => ApiEndpoints.vehicles,
      'receipt' => ApiEndpoints.receipts,
      'sale' => ApiEndpoints.sales,
      'stock' => ApiEndpoints.stockAdjustments,
      'recall' when batchId != null => ApiEndpoints.quarantineRecall(batchId),
      'retail-alert-resolution' when payload['alertId'] != null =>
        ApiEndpoints.resolveRetailAlert(payload['alertId'].toString()),
      _ => '/sync',
    };
  }

  String _methodFor(String type, Map<String, Object?> payload) =>
      ((type == 'vehicle' || type == 'boat') && payload['id'] != null) ||
          (type == 'transport-trip' && payload['tripId'] != null)
      ? 'PUT'
      : 'POST';

  Future<void> syncNow() async {
    if (offline.value || syncing.value) return;
    syncing.value = true;
    try {
      for (final original in List<SyncQueueItem>.from(syncItems)) {
        if (original.status == SyncStatus.failed) continue;
        if (original.nextAttemptAt?.isAfter(DateTime.now()) ?? false) continue;
        var item = original.copyWith(
          status: SyncStatus.syncing,
          updatedAt: DateTime.now(),
        );
        await _replaceQueueItem(item);
        try {
          final serverId = await _syncTransport.upload(item);
          await _offlineRepository.markSynced(item, serverId);
          item = item.copyWith(
            status: SyncStatus.synced,
            serverId: serverId,
            updatedAt: DateTime.now(),
          );
          await _offlineRepository.remove(item.id);
          syncItems.removeWhere((queued) => queued.id == item.id);
          if (_awaitedSyncIds.contains(item.id)) {
            _completedSyncResults[item.id] = item;
          }
        } catch (failure) {
          final retries = item.retries + 1;
          final transient =
              failure is NetworkException || failure is ServerException;
          final retryAutomatically = transient && retries < 6;
          item = item.copyWith(
            status: retryAutomatically ? SyncStatus.pending : SyncStatus.failed,
            retries: retries,
            lastError: failure.toString(),
            updatedAt: DateTime.now(),
            nextAttemptAt: retryAutomatically
                ? DateTime.now().add(
                    Duration(seconds: 1 << retries.clamp(1, 6)),
                  )
                : null,
            clearNextAttemptAt: !retryAutomatically,
          );
          await _replaceQueueItem(item);
        }
      }
      if (syncItems.isEmpty) lastSuccessfulSync.value = DateTime.now();
    } finally {
      syncing.value = false;
      _scheduleSyncRetry();
    }
  }

  void _scheduleSyncRetry() {
    _syncRetryTimer?.cancel();
    if (offline.value) return;
    final attempts =
        syncItems
            .where(
              (item) =>
                  item.status == SyncStatus.pending &&
                  item.nextAttemptAt != null,
            )
            .map((item) => item.nextAttemptAt!)
            .toList()
          ..sort();
    if (attempts.isEmpty) return;
    final delay = attempts.first.difference(DateTime.now());
    _syncRetryTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => unawaited(syncNow()),
    );
  }

  Future<void> retryFailed() async {
    for (final item in syncItems.where(
      (queued) => queued.status == SyncStatus.failed,
    )) {
      await _replaceQueueItem(
        item.copyWith(
          status: SyncStatus.pending,
          updatedAt: DateTime.now(),
          clearNextAttemptAt: true,
        ),
      );
    }
    await syncNow();
  }

  Future<void> discardFailed(String id) async {
    final item = syncItems.firstWhereOrNull((queued) => queued.id == id);
    if (item == null || item.status != SyncStatus.failed) return;
    await _offlineRepository.remove(id);
    syncItems.removeWhere((queued) => queued.id == id);
  }

  Future<void> _replaceQueueItem(SyncQueueItem item) async {
    final index = syncItems.indexWhere((queued) => queued.id == item.id);
    if (index == -1) {
      syncItems.add(item);
    } else {
      syncItems[index] = item;
    }
    await _offlineRepository.put(item);
  }

  void setOffline(bool value) {
    offline.value = value;
    if (value) {
      _syncRetryTimer?.cancel();
    } else {
      unawaited(syncNow());
    }
  }

  Future<void> startConnectivityMonitoring() async {
    final connectivity = Connectivity();
    void apply(List<ConnectivityResult> results) {
      setOffline(
        results.isEmpty ||
            results.every((result) => result == ConnectivityResult.none),
      );
    }

    apply(await connectivity.checkConnectivity());
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      apply,
    );
  }

  void startSensorStream() {
    _sensorSubscription ??= _sensorStream.watch().listen((reading) {
      sensor.value = reading;
      sensorHistory.add(reading);
      if (sensorHistory.length > 30) sensorHistory.removeAt(0);
      final risky =
          (reading.productTemp ?? double.negativeInfinity) > 4 ||
          (reading.battery ?? double.infinity) < 20 ||
          reading.doorOpen;
      final alertDue =
          _lastSensorAlertAt == null ||
          DateTime.now().difference(_lastSensorAlertAt!) >
              const Duration(minutes: 5);
      if (risky && alertDue && _sensorAlertHandler != null) {
        _lastSensorAlertAt = DateTime.now();
        unawaited(_sensorAlertHandler(reading));
      }
    });
  }

  void stopSensorStream() {
    unawaited(_sensorSubscription?.cancel());
    _sensorSubscription = null;
  }

  @override
  void onClose() {
    stopSensorStream();
    unawaited(_sensorStream.dispose());
    unawaited(_connectivitySubscription?.cancel());
    _syncRetryTimer?.cancel();
    super.onClose();
  }
}

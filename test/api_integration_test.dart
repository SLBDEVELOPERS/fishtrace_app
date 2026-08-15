import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fishtrace/app/bindings/app_bindings.dart';
import 'package:fishtrace/app/configuration/app_environment.dart';
import 'package:fishtrace/core/data/repositories.dart';
import 'package:fishtrace/core/errors/app_exceptions.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/core/network/api_client.dart';
import 'package:fishtrace/core/network/api_models.dart';
import 'package:fishtrace/core/network/error_mapper.dart';
import 'package:fishtrace/core/network/fisher_request_dtos.dart';
import 'package:fishtrace/core/network/api_support.dart';
import 'package:fishtrace/core/storage/secure_token_store.dart';
import 'package:fishtrace/features/authentication/data/repositories/firebase_session_repositories.dart';
import 'package:fishtrace/features/common/data/repositories/dio_common_repository.dart';
import 'package:fishtrace/features/common/data/dtos/notification_dto.dart';
import 'package:fishtrace/features/common/data/repositories/file_repositories.dart';
import 'package:fishtrace/features/common/data/repositories/mock_common_repository.dart';
import 'package:fishtrace/features/common/data/repositories/profile_repositories.dart';
import 'package:fishtrace/features/common/domain/repositories/common_repository.dart';
import 'package:fishtrace/features/fisher/data/dtos/fisher_dtos.dart';
import 'package:fishtrace/features/fisher/data/repositories/dio_fisher_repository.dart';
import 'package:fishtrace/features/fisher/data/repositories/mock_fisher_repository.dart';
import 'package:fishtrace/features/processor/data/dtos/processor_dtos.dart';
import 'package:fishtrace/features/retailer/data/dtos/retailer_dtos.dart';
import 'package:fishtrace/features/retailer/data/repositories/dio_retailer_repository.dart';
import 'package:fishtrace/features/transporter/data/dtos/transporter_dtos.dart';
import 'package:fishtrace/features/transporter/data/repositories/sensor_repositories.dart';
import 'package:fishtrace/features/transporter/domain/repositories/sensor_repositories.dart';
import 'package:fishtrace/features/transporter/presentation/controllers/live_monitoring_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide FormData, Response;

void main() {
  setUp(() {
    Get.testMode = true;
  });
  tearDown(Get.reset);

  test('API mode enables Firebase live monitoring by default', () {
    final config = AppConfig.fromDefines();

    expect(config.dataSourceMode, AppDataSourceMode.api);
    expect(config.firebaseEnabled, isTrue);
  });

  test('Firebase session accepts the canonical Laravel token field', () {
    expect(
      firebaseCustomTokenFromPayload({
        'firebase_custom_token': 'custom-token-value',
      }),
      'custom-token-value',
    );
  });

  test('CommonBinding selects exactly one repository for each mode', () {
    final api = ApiClient(
      Dio()..httpClientAdapter = _JsonAdapter({}),
      const ErrorMapper(),
    );
    CommonBinding(
      const AppConfig(
        dataSourceMode: AppDataSourceMode.mock,
        apiBaseUrl: 'https://example.test/api/v1',
        firebaseEnabled: false,
      ),
      api,
    ).dependencies();
    final mock = Get.find<CommonRepository>();
    expect(mock, isA<MockCommonRepository>());
    expect(Get.find<NotificationRepository>(), same(mock));
    expect(Get.find<SupportRepository>(), same(mock));
    Get.reset();

    CommonBinding(
      const AppConfig(
        dataSourceMode: AppDataSourceMode.api,
        apiBaseUrl: 'https://example.test/api/v1',
        firebaseEnabled: true,
      ),
      api,
    ).dependencies();
    final apiRepository = Get.find<CommonRepository>();
    expect(apiRepository, isA<DioCommonRepository>());
    expect(Get.find<NotificationRepository>(), same(apiRepository));
    expect(Get.find<SupportRepository>(), same(apiRepository));
  });

  test('notification DTO preserves Laravel type, context, and UTC state', () {
    final notification = NotificationDto.fromJson({
      'id': 'notification-1',
      'data': {
        'type': 'HIGH_TEMPERATURE',
        'title': 'Temperature alert',
        'message': 'Cold-chain threshold exceeded.',
        'context': {'transport_trip_id': 'trip-1', 'measured_value': 5.2},
      },
      'read_at': null,
      'created_at': '2026-08-09T08:30:00Z',
    }).toDomain();

    expect(notification.type, 'HIGH_TEMPERATURE');
    expect(notification.category.name, 'alert');
    expect(notification.severity.name, 'warning');
    expect(notification.context['transport_trip_id'], 'trip-1');
    expect(notification.createdAt?.isUtc, isTrue);
    expect(notification.read, isFalse);
  });

  test(
    'notification repository requests a complete page and marks read',
    () async {
      final adapter = _JsonAdapter({
        '/notifications': {
          'data': {
            'current_page': 1,
            'last_page': 1,
            'data': [
              {
                'id': 'notification-1',
                'data': {
                  'type': 'RECALL',
                  'title': 'Recall',
                  'message': 'Quarantine affected stock.',
                  'context': {'batch_id': 'batch-1'},
                },
                'read_at': null,
                'created_at': '2026-08-09T08:30:00Z',
              },
            ],
          },
        },
        '/notifications/notification-1/read': {
          'data': {'id': 'notification-1'},
        },
      });
      final repository = DioCommonRepository(
        ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
      );

      final notifications = await repository.getNotifications();
      expect(notifications.single.type, 'RECALL');
      expect(adapter.lastRequest?.queryParameters, {
        'page': 1,
        'per_page': 100,
      });

      await repository.markNotificationRead('notification-1');
      expect(adapter.lastRequest?.path, '/notifications/notification-1/read');
    },
  );

  test('401 clears token and invokes local session expiry once', () async {
    final tokens = MemoryTokenStorage();
    await tokens.save(accessToken: 'expired-token');
    var expiries = 0;
    final dio = Dio()..httpClientAdapter = _ErrorAdapter(401);
    dio.interceptors.add(
      ApiInterceptor(tokenStore: tokens)
        ..onUnauthorized = () async => expiries++,
    );
    final api = ApiClient(dio, const ErrorMapper());

    await expectLater(
      api.get('/auth/me'),
      throwsA(isA<UnauthorizedException>()),
    );

    expect(await tokens.readAccessToken(), isNull);
    expect(expiries, 1);
  });

  test('API support issue submission uses the Laravel contract', () async {
    final adapter = _JsonAdapter({
      '/support/issues': {
        'data': {'id': 'issue-1', 'subject': 'Sync failed', 'status': 'OPEN'},
      },
    });
    final repository = DioCommonRepository(
      ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
    );

    await repository.submitSupportIssue(
      subject: '  Sync failed  ',
      description: '  Catch upload remains pending.  ',
    );

    expect(adapter.lastRequest?.path, '/support/issues');
    expect(adapter.lastRequest?.data, {
      'subject': 'Sync failed',
      'description': 'Catch upload remains pending.',
    });
  });

  test('Laravel login parses snake_case and persists Sanctum token', () async {
    final adapter = _JsonAdapter({
      '/auth/login': {
        'data': {
          'access_token': 'sanctum-token',
          'user': {
            'id': 'user-1',
            'name': 'Ravi Fisher',
            'email': 'fisher@example.test',
            'role': 'FISHER',
          },
        },
      },
    });
    final dio = Dio()..httpClientAdapter = adapter;
    final tokens = MemoryTokenStorage();
    final repository = ApiAuthRepository(
      ApiClient(dio, const ErrorMapper()),
      tokenStore: tokens,
    );

    final user = await repository.login('fisher@example.test', 'secret123');

    expect(user.role, UserRole.fisher);
    expect(user.id, 'user-1');
    expect(await tokens.readAccessToken(), 'sanctum-token');
    final request = adapter.lastRequest!.data as Map<String, Object?>;
    expect(request['email'], 'fisher@example.test');
    expect(request['device_name'], startsWith('fishtrace-'));
    expect(request, isNot(contains('identifier')));
  });

  test('mobile profile update preserves organization details', () async {
    final adapter = _JsonAdapter({
      '/auth/profile': {
        'data': {
          'id': 'user-1',
          'name': 'Mobile Fisher',
          'email': 'mobile.fisher@example.test',
          'role': 'FISHER',
          'organization': {
            'id': 'organization-1',
            'name': 'Ocean Fisheries Cooperative',
            'code': 'OFC-001',
            'type': 'FISHER',
            'is_active': true,
          },
        },
      },
    });
    final repository = ApiProfileRepository(
      ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
      MockAuthRepository(),
    );

    final user = await repository.updateProfile(
      name: ' Mobile Fisher ',
      email: 'MOBILE.FISHER@EXAMPLE.TEST',
    );

    expect(adapter.lastRequest?.method, 'PUT');
    expect(adapter.lastRequest?.path, '/auth/profile');
    expect(adapter.lastRequest?.data, {
      'name': 'Mobile Fisher',
      'email': 'mobile.fisher@example.test',
    });
    expect(user.organization?.code, 'OFC-001');
    expect(user.organization?.active, isTrue);
  });

  test('password verification returns Laravel reset token', () async {
    final dio = Dio()
      ..httpClientAdapter = _JsonAdapter({
        '/auth/verify-otp': {
          'data': {'reset_token': 'reset-token-1'},
        },
      });
    final repository = ApiAuthRepository(
      ApiClient(dio, const ErrorMapper()),
      tokenStore: MemoryTokenStorage(),
    );

    final token = await repository.verifyOtp('user@example.test', '123456');

    expect(token, 'reset-token-1');
  });

  test('Laravel validation errors map to field-safe exceptions', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/batches'),
      response: Response<Object?>(
        requestOptions: RequestOptions(path: '/batches'),
        statusCode: 422,
        data: {
          'error': {
            'code': 'INVALID_BATCH_WEIGHT',
            'message': 'Batch weight is invalid.',
            'field_errors': {
              'total_weight_kg': ['Available weight is 25.5 kg.'],
            },
          },
        },
      ),
    );
    final mapped = const ErrorMapper().map(error);
    expect(mapped, isA<ValidationException>());
    expect(mapped.code, 'INVALID_BATCH_WEIGHT');
    expect(mapped.fieldErrors['total_weight_kg'], isNotEmpty);
  });

  test('backend 500 unauthenticated compatibility maps to session expiry', () {
    final request = RequestOptions(path: '/notifications');
    final mapped = const ErrorMapper().map(
      DioException(
        requestOptions: request,
        response: Response<Object?>(
          requestOptions: request,
          statusCode: 500,
          data: {
            'error': {'code': 'SERVER_ERROR', 'message': 'Unauthenticated.'},
          },
        ),
      ),
    );
    expect(mapped, isA<UnauthorizedException>());
    expect(mapped.message, 'Your session has expired.');
  });

  test('backend model details are not exposed in user-facing errors', () {
    final request = RequestOptions(path: '/boats/BOAT-LOCAL');
    final mapped = const ErrorMapper().map(
      DioException(
        requestOptions: request,
        response: Response<Object?>(
          requestOptions: request,
          statusCode: 404,
          data: {
            'error': {
              'code': 'NOT_FOUND',
              'message':
                  r'No query results for model [App\Models\Boat] BOAT-LOCAL',
            },
          },
        ),
      ),
    );

    expect(mapped, isA<NotFoundException>());
    expect(mapped.message, 'The requested record was not found.');
  });

  test('DTO parsing is UTC-safe and unknown enums use a safe fallback', () {
    final value = FisherBatchDto.fromJson({
      'id': 'batch-1',
      'species': {'common_name': 'Tuna', 'scientific_name': 'Thunnus'},
      'total_weight_kg': 12.5,
      'fish_count': 2,
      'grade': 'NEW_SERVER_GRADE',
      'status': 'NEW_SERVER_STATUS',
      'trip_id': 'trip-1',
      'created_at': '2026-08-01T04:30:00Z',
    }).toDomain();

    expect(value.grade, QualityGrade.a);
    expect(value.status, BatchStatus.newBatch);
    expect(value.createdAt.isUtc, isTrue);
  });

  test('Fisher create DTOs emit the canonical Laravel write contract', () {
    final trip = CreateFishingTripRequestDto(
      boatId: 'boat-uuid',
      tripCode: 'TRIP-2026-001',
      clientRecordId: '3f93f625-a13b-43db-aae1-06d8b822bf4d',
      plannedDepartureAt: DateTime.parse('2026-08-08T06:30:00+05:30'),
      expectedDurationHours: 12,
      fishingAreaLatitude: 17.6858,
      fishingAreaLongitude: 83.2185,
      crew: const ['Alex Johnson'],
      generalCatchArea: '17.6858, 83.2185',
    ).toJson();
    final batch = CreateBatchRequestDto(
      fishSpeciesId: 'species-uuid',
      productType: 'WHOLE',
      qualityGrade: 'A',
      storageTemperatureCelsius: 2,
      iceType: 'FLAKE_ICE',
      iceAmountKg: 25,
      landingSiteName: 'Kochi Port',
      catches: const [
        BatchCatchAllocationDto(catchId: 'catch-uuid', weightKg: 12.5),
      ],
    ).toJson();

    expect(trip['boat_id'], 'boat-uuid');
    expect(trip['planned_departure_at'], '2026-08-08T01:00:00.000Z');
    expect(trip['crew'], ['Alex Johnson']);
    expect(batch['quality_grade'], 'A');
    expect(batch['storage_temperature_celsius'], 2);
    expect((batch['catches'] as List).single, {
      'catch_id': 'catch-uuid',
      'weight_kg': 12.5,
    });
  });

  test(
    'published Fisher response fixtures parse into matching domains',
    () async {
      Future<Map<String, Object?>> fixture(String name) async {
        final decoded =
            jsonDecode(
                  await File('test/fixtures/api/$name.json').readAsString(),
                )
                as Map;
        return (decoded['data'] as Map).cast<String, Object?>();
      }

      final trip = ActiveFishingTripDto.fromJson(
        await fixture('fishing_trip'),
      ).toDomain();
      final catchRecord = FisherCatchDto.fromJson(
        await fixture('catch_record'),
      ).toDomain();
      final batch = FisherBatchDto.fromJson(
        await fixture('fish_batch'),
      ).toDomain();

      expect(trip.status, TripStatus.inProgress);
      expect(trip.crew, ['Alex Johnson', 'M. Kumar']);
      expect(trip.catchKg, 40);
      expect(catchRecord.condition, 'Good');
      expect(catchRecord.gear, 'Longline');
      expect(catchRecord.tripId, trip.id);
      expect(batch.tripId, trip.id);
      expect(batch.fishCount, 2);
      expect(batch.grade, QualityGrade.a);
      expect(batch.status, BatchStatus.completed);
    },
  );

  test('mock pagination applies page, per-page, and search', () async {
    final repository = MockFisherRepository();
    final first = await repository.getBoatsPage(
      const PageQuery(page: 1, perPage: 2),
    );
    final searched = await repository.getBoatsPage(
      const PageQuery(search: 'wave rider'),
    );

    expect(first.items, hasLength(2));
    expect(first.hasMore, isTrue);
    expect(searched.items.single.name, 'Wave Rider');
  });

  test('Laravel paginator metadata and active-trip query are parsed', () async {
    final adapter = _JsonAdapter({
      '/boats': {
        'data': {
          'current_page': 2,
          'last_page': 3,
          'total': 5,
          'data': [
            {
              'id': 'boat-1',
              'name': 'Ocean Hunter',
              'registration_number': 'REG-1',
              'length_meters': 12.5,
              'engine_details': 'D6',
              'type': 'Longliner',
              'home_port': 'Kochi',
              'is_active': true,
            },
          ],
        },
      },
      '/fishing-trips': {
        'data': {
          'current_page': 1,
          'last_page': 1,
          'total': 1,
          'data': [
            {
              'id': 'trip-1',
              'boat_id': 'boat-1',
              'boat': {'name': 'Ocean Hunter'},
              'departed_at': '2026-08-02T06:30:00Z',
              'general_catch_area': 'FAO 57',
              'crew': ['Alex'],
              'catch_kg': 0,
              'batch_count': 0,
              'status': 'ACTIVE',
            },
          ],
        },
      },
    });
    final repository = DioFisherRepository(
      ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
    );

    final page = await repository.getBoatsPage(
      const PageQuery(page: 2, perPage: 1),
    );
    final trip = await repository.getActiveTrip();

    expect(page.currentPage, 2);
    expect(page.lastPage, 3);
    expect(page.total, 5);
    expect(page.items.single.engineDetails, 'D6');
    expect(trip?.id, 'trip-1');
    expect(adapter.lastRequest?.queryParameters['status'], 'ACTIVE');
  });

  test('offline catch sync emits the published Laravel request body', () async {
    final directory = await Directory.systemTemp.createTemp('fishtrace-catch-');
    final photo = File('${directory.path}/catch.jpg');
    await photo.writeAsBytes([1, 2, 3]);
    addTearDown(() => directory.delete(recursive: true));
    final adapter = _JsonAdapter({
      '/fisher/reference-data': {
        'data': {
          'species': [
            {'id': 'species-uuid', 'common_name': 'Yellowfin Tuna'},
          ],
          'gear_types': [
            {'id': 'gear-uuid', 'name': 'Longline'},
          ],
          'landing_sites': const [],
        },
      },
      '/catches': {
        'data': {'id': 'server-catch-uuid'},
      },
      '/files': {
        'data': {'id': 'file-1'},
      },
    });
    final transport = DioSyncTransport(Dio()..httpClientAdapter = adapter);
    final controller = AppController(
      auth: MockAuthRepository(),
      syncTransport: transport,
      attachmentRoot: () async => directory,
      autoSync: true,
    );

    final item = await controller.queue(
      'Catch - Yellowfin Tuna',
      recordType: 'catch',
      payload: {
        'tripId': 'trip-uuid',
        'species': 'Yellowfin Tuna',
        'gear': 'Longline',
        'weightKg': 12.5,
        'quantity': 2,
        'condition': 'Good',
        'latitude': 17.6858,
        'longitude': 83.2185,
        'notes': 'Line caught',
        'caughtAt': '2026-08-03T08:00:00Z',
        'photos': [photo.path],
      },
    );

    final catchRequest = adapter.requests.firstWhere(
      (request) => request.path == '/catches',
    );
    final body = catchRequest.data as Map<String, Object?>;
    expect(body['fishing_trip_id'], 'trip-uuid');
    expect(body['fish_species_id'], 'species-uuid');
    expect(body['fishing_gear_type_id'], 'gear-uuid');
    expect(body['client_record_id'], item.id);
    expect(body['condition'], 'GOOD');
    expect(body['latitude'], 17.6858);
    expect(body['longitude'], 83.2185);
    expect(body['notes'], 'Line caught');
    expect(body, isNot(contains('species')));
    final upload = adapter.requests.firstWhere(
      (request) => request.path == '/files',
    );
    final uploadData = upload.data as FormData;
    expect(Map.fromEntries(uploadData.fields), {
      'category': 'CATCH_IMAGE',
      'entity_type': 'catch_record',
      'entity_id': 'server-catch-uuid',
    });
    expect(uploadData.files.single.value.contentType?.mimeType, 'image/jpeg');
  });

  test('nested Laravel role payloads map to populated domain models', () {
    final processing = ProcessingJobDto.fromJson({
      'id': 'intake-1',
      'fish_batch_id': 'batch-1',
      'received_at': '2026-08-03T08:00:00Z',
      'batch': {
        'species': {'common_name': 'Yellowfin Tuna'},
      },
      'processing_record': {
        'status': 'COMPLETED',
        'input_weight_kg': '100.0',
        'output_weight_kg': '92.0',
        'started_at': '2026-08-03T09:00:00Z',
        'steps': [
          {
            'type': 'PACKAGING',
            'measurements': {'package_count': 10},
          },
        ],
      },
    }).toDomain();
    final trip = TransportTripDto.fromJson({
      'id': 'trip-1',
      'vehicle_id': 'vehicle-1',
      'driver_name': 'Sunil Kumara',
      'origin': 'Mirissa',
      'destination': 'Colombo',
      'status': 'ACTIVE',
      'estimated_distance_km': '150.25',
      'product_temperature_celsius': '2.10',
      'started_at': '2026-08-03T09:00:00Z',
      'batches': [
        {'id': 'batch-1'},
      ],
    }).toDomain();
    final product = RetailProductDto.fromJson({
      'id': 'lot-1',
      'fish_batch_id': 'batch-1',
      'available_packages': 4,
      'expires_at': '2026-08-24T00:00:00Z',
      'default_unit_price': '18.50',
      'low_stock_threshold_kg': '30.0',
      'label': {'package_weight_kg': '10.0'},
      'batch': {
        'product_type': 'Frozen tuna loin',
        'species': {
          'common_name': 'Yellowfin Tuna',
          'scientific_name': 'Thunnus albacares',
        },
      },
    }).toDomain();

    expect(processing.species, 'Yellowfin Tuna');
    expect(processing.outputWeightKg, 92);
    expect(processing.packageCount, 10);
    expect(trip.status, TripStatus.inProgress);
    expect(trip.driver, 'Sunil Kumara');
    expect(trip.batchCount, 1);
    expect(trip.distanceKm, 150.25);
    expect(trip.productTemperature, 2.1);
    expect(product.name, 'Yellowfin Tuna');
    expect(product.stockKg, 40);
    expect(product.batchId, 'batch-1');
    expect(product.unitPrice, 18.5);
    expect(product.lowStockThreshold, 30);

    final report = RetailReportSummaryDto.fromJson({
      'catch_weight_kg': '125.5',
      'batches': 4,
      'processing_records': 2,
      'transport_trips': 3,
      'open_cold_chain_alerts': 1,
      'available_inventory_packages': 24,
      'sales_total': '1450.25',
      'generated_at': '2026-08-08T08:00:00Z',
    }).toDomain();
    final saleReportRow = RetailSalesReportRowDto.fromJson({
      'receipt_number': 'RS-001',
      'location': 'Colombo Central',
      'status': 'COMPLETED',
      'total': '650.5',
      'sold_at': '2026-08-08T09:00:00Z',
    }).toDomain();
    final inventoryReportRow = RetailInventoryReportRowDto.fromJson({
      'label_code': 'LBL-001',
      'batch_code': 'BATCH-001',
      'location': 'Colombo Central',
      'status': 'IN_STOCK',
      'total_packages': 10,
      'available_packages': 8,
      'reserved_packages': 1,
      'sold_packages': 1,
      'expires_at': '2026-08-20T00:00:00Z',
    }).toDomain();
    expect(report.salesTotal, 1450.25);
    expect(report.availableInventoryPackages, 24);
    expect(saleReportRow.receiptNumber, 'RS-001');
    expect(saleReportRow.soldAt.isUtc, isTrue);
    expect(inventoryReportRow.availablePackages, 8);
  });

  test('accepted intake without a processing record remains resumable', () {
    final intake = ProcessingJobDto.fromJson({
      'id': 'intake-accepted',
      'fish_batch_id': 'batch-accepted',
      'status': 'ACCEPTED',
      'received_at': '2026-08-10T17:18:50Z',
      'batch': {
        'total_weight_kg': '20.000',
        'species': {'common_name': 'Yellowfin Tuna'},
      },
      'processing_record': null,
    }).toDomain();

    expect(intake.hasProcessingRecord, isFalse);
    expect(intake.inputWeightKg, 20);
    expect(intake.status, BatchStatus.newBatch);
  });

  test('quality hold processing records are not shown as in progress', () {
    final job = ProcessingJobDto.fromJson({
      'id': 'intake-hold',
      'fish_batch_id': 'batch-hold',
      'status': 'ACCEPTED',
      'batch': {
        'total_weight_kg': '20.000',
        'species': {'common_name': 'Yellowfin Tuna'},
      },
      'processing_record': {
        'id': 'processing-hold',
        'status': 'QUALITY_HOLD',
        'input_weight_kg': '20.000',
        'output_weight_kg': '10.000',
        'steps': [
          {
            'type': 'PACKAGING',
            'status': 'COMPLETED',
            'measurements': {'package_count': 2},
          },
        ],
      },
    }).toDomain();

    expect(job.status, BatchStatus.qualityHold);
    expect(job.allStepsCompleted, isTrue);
    expect(job.hasProcessingRecord, isTrue);
  });

  test(
    'retail report repository uses canonical endpoints and date keys',
    () async {
      final adapter = _JsonAdapter({
        '/retailer/reports/summary': {
          'data': {
            'sales_total': 250,
            'available_inventory_packages': 8,
            'generated_at': '2026-08-08T08:00:00Z',
          },
        },
        '/retailer/reports/sales': {
          'data': {
            'rows': [
              {
                'receipt_number': 'RS-001',
                'location': 'Colombo Central',
                'status': 'COMPLETED',
                'total': 250,
                'sold_at': '2026-08-08T09:00:00Z',
              },
            ],
          },
        },
        '/retailer/reports/inventory': {
          'data': {
            'rows': [
              {
                'label_code': 'LBL-001',
                'batch_code': 'BATCH-001',
                'location': 'Colombo Central',
                'status': 'IN_STOCK',
                'total_packages': 10,
                'available_packages': 8,
                'reserved_packages': 1,
                'sold_packages': 1,
                'expires_at': '2026-08-20T00:00:00Z',
              },
            ],
          },
        },
      });
      final repository = DioRetailerRepository(
        ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
      );
      final dateFrom = DateTime(2026, 8, 1);
      final dateTo = DateTime(2026, 8, 8);

      final summary = await repository.getReportSummary(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      final sales = await repository.getSalesReport(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      final inventory = await repository.getInventoryReport(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      expect(summary.salesTotal, 250);
      expect(sales.single.receiptNumber, 'RS-001');
      expect(inventory.single.labelCode, 'LBL-001');
      expect(adapter.requests.map((request) => request.path), [
        '/retailer/reports/summary',
        '/retailer/reports/sales',
        '/retailer/reports/inventory',
      ]);
      expect(adapter.requests.first.queryParameters, {
        'date_from': '2026-08-01',
        'date_to': '2026-08-08',
      });
    },
  );

  test(
    'Laravel telemetry keeps nullable readings null instead of inventing zeroes',
    () async {
      final adapter = _JsonAdapter({
        '/transport-trips/trip-1/sensor-readings/latest': {
          'data': {
            'product_temperature': null,
            'air_temperature': '2.3',
            'humidity': null,
            'latitude': null,
            'longitude': null,
            'battery_percentage': null,
            'door_open': false,
            'temperature_status': 'CRITICAL',
            'recorded_at': '2026-08-08T09:00:00Z',
          },
        },
        '/transport-trips/trip-1/sensor-readings': {
          'data': {
            'data': [
              {
                'product_temperature': '2.1',
                'air_temperature': null,
                'humidity': 82,
                'battery_percentage': 88,
                'door_open': false,
                'recorded_at': '2026-08-08T09:00:00Z',
              },
            ],
          },
        },
      });
      final repository = LaravelSensorRepository(
        ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
      );

      final latest = await repository.latest('trip-1');
      final history = await repository.history('trip-1');

      expect(latest?.productTemp, isNull);
      expect(latest?.airTemp, 2.3);
      expect(latest?.battery, isNull);
      expect(latest?.temperatureStatus, 'CRITICAL');
      expect(latest?.recordedAt?.isUtc, isTrue);
      expect(history.single.productTemp, 2.1);
      expect(history.single.humidity, 82);
    },
  );

  test('transport and retail sync bodies follow Postman schemas', () async {
    final adapter = _JsonAdapter({
      '/vehicles': {
        'data': {'id': 'vehicle-1'},
      },
      '/transport-trips/trip-1/checklist': {
        'data': {'id': 'checklist-1'},
      },
      '/transport-trips/trip-1/device': {
        'data': {'id': 'assignment-1'},
      },
      '/transport-trips/trip-1/start': {
        'data': {'id': 'trip-1', 'status': 'IN_TRANSIT'},
      },
      '/transport-trips/trip-1/arrive': {
        'data': {'id': 'trip-1', 'status': 'ACTIVE'},
      },
      '/transport-trips': {
        'data': {'id': 'trip-2', 'status': 'DRAFT'},
      },
      '/transport-trips/trip-1/complete': {
        'data': {'id': 'trip-1', 'status': 'COMPLETED'},
      },
      '/retailer/inventory': {
        'data': {
          'data': [
            {'id': 'lot-1', 'retail_location_id': 'location-1'},
          ],
        },
      },
      '/retailer/receipts': {
        'data': {'id': 'receipt-1'},
      },
      '/retailer/sales': {
        'data': {'id': 'sale-1'},
      },
    });
    final controller = AppController(
      auth: MockAuthRepository(),
      syncTransport: DioSyncTransport(Dio()..httpClientAdapter = adapter),
      autoSync: true,
    );

    await controller.queue(
      'Save vehicle',
      recordType: 'vehicle',
      payload: {
        'registration': 'WP-CAB-2048',
        'name': 'Reefer Truck 01',
        'capacityTonnes': 1.2,
      },
    );
    var body = adapter.lastRequest?.data as Map<String, Object?>;
    expect(body, {
      'registration_number': 'WP-CAB-2048',
      'name': 'Reefer Truck 01',
      'capacity_tonnes': 1.2,
    });

    await controller.queue(
      'Pre-trip checklist',
      recordType: 'checklist',
      payload: {
        'tripId': 'trip-1',
        'completed': [
          'Vehicle safety inspection',
          'Refrigeration system',
          'Cargo and batch seals',
          'IoT device online',
          'Cargo doors sealed',
        ],
      },
    );
    body = adapter.lastRequest?.data as Map<String, Object?>;
    expect((body['items'] as List).length, 5);
    expect(
      (body['items'] as List).every(
        (item) => (item as Map<String, Object?>)['completed'] == true,
      ),
      isTrue,
    );

    await controller.queue(
      'Assign IoT device',
      recordType: 'device-assignment',
      payload: {'tripId': 'trip-1', 'deviceId': 'device-1'},
    );
    body = adapter.lastRequest?.data as Map<String, Object?>;
    expect(body, {'iot_device_id': 'device-1'});

    await controller.queue(
      'Start transport trip',
      recordType: 'transport-start',
      payload: {'tripId': 'trip-1'},
    );
    expect(adapter.lastRequest?.path, '/transport-trips/trip-1/start');

    await controller.queue(
      'Mark transport arrival',
      recordType: 'transport-arrival',
      payload: {'tripId': 'trip-1'},
    );
    expect(adapter.lastRequest?.path, '/transport-trips/trip-1/arrive');

    final createdTrip = await controller.queue(
      'Save transport trip',
      recordType: 'transport-trip',
      payload: {
        'vehicleId': 'vehicle-1',
        'driver': 'Kasun Silva',
        'origin': 'Mirissa',
        'destination': 'Colombo',
        'distanceKm': 150.0,
      },
    );
    body = adapter.lastRequest?.data as Map<String, Object?>;
    expect(body, {
      'vehicle_id': 'vehicle-1',
      'driver_name': 'Kasun Silva',
      'origin': 'Mirissa',
      'destination': 'Colombo',
      'estimated_distance_km': 150.0,
    });
    expect(createdTrip.status, SyncStatus.synced);
    expect(createdTrip.serverId, 'trip-2');

    await controller.queue(
      'Complete transport trip',
      recordType: 'transport-complete',
      payload: {'tripId': 'trip-1'},
    );
    expect(adapter.lastRequest?.path, '/transport-trips/trip-1/complete');

    await controller.queue(
      'Complete retail receipt',
      recordType: 'receipt',
      payload: {'packageLabelId': 'label-1', 'receivedPackageCount': 2},
    );
    body = adapter.lastRequest?.data as Map<String, Object?>;
    expect(body, {
      'package_label_id': 'label-1',
      'retail_location_id': 'location-1',
      'received_package_count': 2,
    });

    final sale = await controller.queue(
      'Record retail sale',
      recordType: 'sale',
      payload: {'productId': 'lot-1', 'quantityPackages': 2, 'unitPrice': 2500},
    );
    body = adapter.lastRequest?.data as Map<String, Object?>;
    expect(body['retail_location_id'], 'location-1');
    expect(body['client_reference'], sale.id);
    expect((body['items'] as List).single, {
      'inventory_lot_id': 'lot-1',
      'quantity': 2,
      'unit_price': 2500,
    });
  });

  test(
    'transport alert acknowledgement and incident sync use Laravel contracts',
    () async {
      final adapter = _JsonAdapter({
        '/alerts/alert-1/acknowledge': {
          'data': {'id': 'alert-1', 'status': 'ACKNOWLEDGED'},
        },
        '/transport-trips/trip-1/incidents': {
          'data': {'id': 'incident-1'},
        },
      });
      final controller = AppController(
        auth: MockAuthRepository(),
        syncTransport: DioSyncTransport(Dio()..httpClientAdapter = adapter),
        autoSync: true,
      );

      await controller.queue(
        'Acknowledge transport alert',
        recordType: 'alert-acknowledgement',
        payload: {'alertId': 'alert-1', 'note': 'Driver notified.'},
      );
      expect(adapter.lastRequest?.path, '/alerts/alert-1/acknowledge');
      expect(adapter.lastRequest?.data, {'note': 'Driver notified.'});

      await controller.queue(
        'Report transport incident',
        recordType: 'incident',
        payload: {
          'tripId': 'trip-1',
          'type': 'DRIVER_REPORTED',
          'severity': 'WARNING',
          'description': 'Road closure delayed the refrigerated vehicle.',
          'occurredAt': '2026-08-08T09:00:00Z',
        },
      );
      expect(adapter.lastRequest?.path, '/transport-trips/trip-1/incidents');
      expect(adapter.lastRequest?.data, {
        'type': 'DRIVER_REPORTED',
        'severity': 'WARNING',
        'description': 'Road closure delayed the refrigerated vehicle.',
        'occurred_at': '2026-08-08T09:00:00.000Z',
      });
    },
  );

  test(
    'published vehicle fixture preserves transporter detail fields',
    () async {
      final envelope =
          (jsonDecode(
                    await File('test/fixtures/api/vehicle.json').readAsString(),
                  )
                  as Map)
              .cast<String, Object?>();
      final vehicle = VehicleDto.fromJson(
        (envelope['data'] as Map).cast<String, Object?>(),
      ).toDomain();

      expect(vehicle.registration, 'WP-CAB-2048');
      expect(vehicle.type, 'Refrigerated Truck');
      expect(vehicle.refrigerationCategory, 'Category A');
      expect(vehicle.capacityTonnes, 1.2);
      expect(vehicle.reeferUnit, 'Carrier Supra 550');
      expect(vehicle.minTemperature, -20);
      expect(vehicle.maxTemperature, 20);
      expect(vehicle.driver, 'Alex Johnson');
    },
  );

  test('retail alert resolution sync uses the required note payload', () async {
    final adapter = _JsonAdapter({
      '/retailer/alerts/alert-1/resolve': {
        'data': {'id': 'alert-1', 'status': 'RESOLVED'},
      },
    });
    final controller = AppController(
      auth: MockAuthRepository(),
      syncTransport: DioSyncTransport(Dio()..httpClientAdapter = adapter),
      autoSync: true,
    );

    await controller.queue(
      'Resolve retail alert',
      recordType: 'retail-alert-resolution',
      payload: {
        'alertId': 'alert-1',
        'note': 'Affected stock was quarantined and checked.',
      },
    );

    expect(adapter.lastRequest?.path, '/retailer/alerts/alert-1/resolve');
    expect(adapter.lastRequest?.data, {
      'note': 'Affected stock was quarantined and checked.',
    });
  });

  test(
    'delivery uploads photos and signature with distinct categories',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'fishtrace-delivery-',
      );
      final photo = File('${directory.path}/delivery.jpg');
      final signature = File('${directory.path}/signature.png');
      await photo.writeAsBytes([1, 2, 3]);
      await signature.writeAsBytes([4, 5, 6]);
      addTearDown(() => directory.delete(recursive: true));
      final adapter = _JsonAdapter({
        '/transport-trips/trip-1/delivery-confirmation': {
          'data': {'id': 'delivery-1'},
        },
        '/files': {
          'data': {'id': 'file-1'},
        },
      });
      final controller = AppController(
        auth: MockAuthRepository(),
        syncTransport: DioSyncTransport(Dio()..httpClientAdapter = adapter),
        attachmentRoot: () async => directory,
        autoSync: true,
      );

      await controller.queue(
        'Delivery confirmation',
        recordType: 'delivery',
        payload: {
          'tripId': 'trip-1',
          'receiver': 'Receiving Officer',
          'completedAt': '2026-08-08T08:30:00Z',
          'photos': [photo.path],
          'signaturePath': signature.path,
        },
      );

      final uploads = adapter.requests
          .where((request) => request.path == '/files')
          .map((request) => request.data as FormData)
          .toList();
      expect(uploads, hasLength(2));
      final categories = uploads
          .map((form) => Map.fromEntries(form.fields)['category'])
          .toSet();
      expect(categories, {'DELIVERY_IMAGE', 'DELIVERY_SIGNATURE'});
    },
  );

  test(
    'quality inspection resolves record and serializes grade code',
    () async {
      final adapter = _JsonAdapter({
        '/processor/history': {
          'data': {
            'data': [
              {
                'fish_batch_id': 'batch-1',
                'processing_record': {'id': 'processing-1'},
              },
            ],
          },
        },
        '/quality-inspections': {
          'data': {'id': 'inspection-1'},
        },
      });
      final controller = AppController(
        auth: MockAuthRepository(),
        syncTransport: DioSyncTransport(Dio()..httpClientAdapter = adapter),
        autoSync: true,
      );

      await controller.queue(
        'Quality inspection',
        recordType: 'inspection',
        payload: {
          'batchId': 'batch-1',
          'criteria': {'Appearance': 'pass', 'Odour': 'warning'},
          'temperature': 2.1,
          'grade': 'a',
          'comments': 'Minor odour warning.',
        },
      );

      final body = adapter.lastRequest?.data as Map<String, Object?>;
      expect(body['processing_record_id'], 'processing-1');
      expect(body['result'], 'CONDITIONAL');
      expect(body['quality_grade'], 'A');
      expect(body['odor'], 'warning');
      expect(body, isNot(contains('quality_grade_id')));
    },
  );

  test(
    'processing workflow serializes record and ordered step calls',
    () async {
      final adapter = _JsonAdapter({
        '/processing-records': {
          'data': {
            'id': 'processing-1',
            'steps': [
              {'id': 'step-cleaning', 'type': 'CLEANING'},
            ],
          },
        },
        '/processing-records/processing-1/steps/step-cleaning/start': {
          'data': {'id': 'step-cleaning', 'status': 'ACTIVE'},
        },
        '/processing-records/processing-1/steps/step-cleaning/complete': {
          'data': {'id': 'step-cleaning', 'status': 'COMPLETED'},
        },
      });
      final controller = AppController(
        auth: MockAuthRepository(),
        syncTransport: DioSyncTransport(Dio()..httpClientAdapter = adapter),
        autoSync: true,
      );

      await controller.queue(
        'Start processing',
        recordType: 'processing',
        payload: {
          'batchId': 'batch-1',
          'inputWeightKg': 48,
          'operator': 'Alex Johnson',
          'area': 'Line 2 – High Care',
          'notes': 'Whole fish line.',
        },
      );
      await controller.queue(
        'Start cleaning',
        recordType: 'processing-step-start',
        payload: {'batchId': 'batch-1', 'step': 'cleaning'},
      );
      await controller.queue(
        'Complete cleaning',
        recordType: 'processing-step-complete',
        payload: {
          'batchId': 'batch-1',
          'step': 'cleaning',
          'measurements': {'cleaned_weight_kg': 47.2},
          'notes': 'Cleaning complete.',
        },
      );

      expect(adapter.requests, hasLength(3));
      expect(adapter.requests[0].path, '/processing-records');
      expect(adapter.requests[0].data, {
        'fish_batch_id': 'batch-1',
        'input_weight_kg': 48.0,
        'operator_name': 'Alex Johnson',
        'processing_area': 'Line 2 – High Care',
        'notes': 'Whole fish line.',
      });
      expect(
        adapter.requests[1].path,
        '/processing-records/processing-1/steps/step-cleaning/start',
      );
      expect(
        adapter.requests[2].path,
        '/processing-records/processing-1/steps/step-cleaning/complete',
      );
      expect(adapter.requests[2].data, {
        'measurements': {'cleaned_weight_kg': 47.2},
        'notes': 'Cleaning complete.',
      });
    },
  );

  test(
    'session restoration recreates Firebase session and user state',
    () async {
      final tokens = MemoryTokenStorage();
      await tokens.save(accessToken: 'persisted-token');
      final firebase = MockFirebaseSessionRepository();
      final controller = AppController(
        auth: MockAuthRepository(),
        tokenStore: tokens,
        firebaseSession: firebase,
      );

      expect(await controller.restoreSession(), isTrue);
      expect(controller.user.value?.role, UserRole.fisher);
      expect(firebase.isAuthenticated, isTrue);
    },
  );

  test(
    'live monitoring bounds samples, falls back, and disposes listener',
    () async {
      final live = _FakeLiveSensorRepository();
      final rest = _FakeSensorRepository();
      final controller = LiveMonitoringController(
        liveSensorRepository: live,
        sensorRepository: rest,
        session: AppController(auth: MockAuthRepository()),
      );
      await controller.start('trip-1');
      for (var index = 0; index < 105; index++) {
        live.add(
          SensorReading(
            productTemp: 2 + index / 100,
            airTemp: 2.3,
            humidity: 60,
            battery: 80,
            recordedAt: DateTime.now().toUtc(),
          ),
        );
      }
      await Future<void>.delayed(Duration.zero);
      expect(controller.chartReadings, hasLength(100));
      await controller.stop();
      expect(live.disposed, isTrue);
    },
  );

  test(
    'queued API operations resolve Laravel endpoint and idempotency',
    () async {
      final transport = _CapturingSyncTransport();
      final controller = AppController(
        auth: MockAuthRepository(),
        syncTransport: transport,
        autoSync: true,
      );
      final item = await controller.queue(
        'Accept processor intake',
        recordType: 'intake',
        payload: {'batchId': 'batch-1', 'decision': 'accepted'},
      );
      expect(item.endpoint, '/processor/batches/batch-1/accept');
      expect(item.clientRecordId, isNotEmpty);
      expect(item.idempotencyKey, item.id);
      expect(transport.uploaded?.endpoint, item.endpoint);
    },
  );

  test('API file upload maps canonical Laravel file metadata', () async {
    final directory = await Directory.systemTemp.createTemp(
      'fishtrace-api-upload-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/catch.jpg');
    await file.writeAsBytes(List<int>.filled(64, 1));
    final adapter = _JsonAdapter({
      '/files': {
        'data': {
          'id': 'file-1',
          'category': 'CATCH_IMAGE',
          'entity_type': 'catch_record',
          'entity_id': 'catch-1',
          'original_name': 'catch.jpg',
          'mime_type': 'image/jpeg',
          'extension': 'jpg',
          'size_bytes': 64,
          'sha256': 'abc123',
          'download_url': 'https://example.test/api/v1/files/file-1',
          'created_at': '2026-08-09T08:30:00Z',
        },
      },
    });
    final repository = ApiFileRepository(
      ApiClient(Dio()..httpClientAdapter = adapter, const ErrorMapper()),
    );

    final result = await repository.upload(
      file.path,
      category: 'CATCH_IMAGE',
      entityType: 'catch_record',
      entityId: 'catch-1',
      cancelToken: CancelToken(),
      onProgress: (_, _) {},
    );

    expect(adapter.lastRequest?.path, '/files');
    final fields = Map.fromEntries(
      (adapter.lastRequest?.data as FormData).fields,
    );
    expect(fields, {
      'category': 'CATCH_IMAGE',
      'entity_type': 'catch_record',
      'entity_id': 'catch-1',
    });
    expect(result.id, 'file-1');
    expect(result.downloadUrl, 'https://example.test/api/v1/files/file-1');
    expect(result.mimeType, 'image/jpeg');
    expect(result.originalName, 'catch.jpg');
    expect(result.sizeBytes, 64);
    expect(result.createdAt, DateTime.parse('2026-08-09T08:30:00Z'));
  });

  test('mock file upload reports matching metadata and progress', () async {
    final directory = await Directory.systemTemp.createTemp(
      'fishtrace-upload-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/catch.jpg');
    await file.writeAsBytes(List<int>.filled(64, 1));
    var progress = 0.0;
    final result = await MockFileRepository().upload(
      file.path,
      category: 'CATCH_IMAGE',
      entityType: 'catch_record',
      entityId: 'catch-1',
      cancelToken: CancelToken(),
      onProgress: (sent, total) => progress = sent / total,
    );
    expect(result.downloadUrl, startsWith('mock://'));
    expect(result.category, 'CATCH_IMAGE');
    expect(result.entityType, 'catch_record');
    expect(result.entityId, 'catch-1');
    expect(result.originalName, 'catch.jpg');
    expect(result.sizeBytes, 64);
    expect(progress, 1);
  });
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.responses);
  final Map<String, Object?> responses;
  RequestOptions? lastRequest;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    requests.add(options);
    await requestStream?.drain<void>();
    return ResponseBody.fromString(
      jsonEncode(responses[options.path] ?? const {}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _ErrorAdapter implements HttpClientAdapter {
  _ErrorAdapter(this.statusCode);
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode({
      'error': {'code': 'UNAUTHENTICATED', 'message': 'Session expired.'},
    }),
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _FakeLiveSensorRepository implements LiveSensorRepository {
  final _controller = StreamController<SensorReading>.broadcast();
  bool disposed = false;
  void add(SensorReading reading) => _controller.add(reading);
  @override
  Stream<SensorReading> watchTrip(String tripId) => _controller.stream;
  @override
  Future<void> dispose() async {
    disposed = true;
    await _controller.close();
  }
}

class _FakeSensorRepository implements SensorRepository {
  final fallback = SensorReading(
    productTemp: 2.1,
    airTemp: 2.3,
    humidity: 62,
    battery: 80,
    recordedAt: DateTime.now().toUtc(),
  );
  @override
  Future<List<SensorReading>> history(String tripId) async => [fallback];
  @override
  Future<SensorReading> latest(String tripId) async => fallback;
}

class _CapturingSyncTransport implements SyncTransport {
  SyncQueueItem? uploaded;
  @override
  Future<String> upload(SyncQueueItem item) async {
    uploaded = item;
    return 'server-${item.id}';
  }
}

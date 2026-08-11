import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../core/data/repositories.dart';
import '../../core/database/fishtrace_database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/error_mapper.dart';
import '../../core/network/sensor_stream.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/storage/secure_token_store.dart';
import '../../core/sync/sync_controller.dart';
import '../../features/authentication/data/repositories/firebase_session_repositories.dart';
import '../../features/authentication/data/repositories/secure_onboarding_repository.dart';
import '../../features/authentication/domain/repositories/firebase_session_repository.dart';
import '../../features/authentication/presentation/controllers/authentication_controller.dart';
import '../../features/common/data/repositories/dio_common_repository.dart';
import '../../features/common/data/repositories/mock_common_repository.dart';
import '../../features/common/data/repositories/profile_repositories.dart';
import '../../features/common/data/repositories/file_repositories.dart';
import '../../features/common/data/repositories/secure_mobile_settings_repository.dart';
import '../../features/common/domain/repositories/file_repository.dart';
import '../../features/common/domain/repositories/common_repository.dart';
import '../../features/common/domain/repositories/mobile_settings_repository.dart';
import '../../features/common/domain/repositories/profile_repository.dart';
import '../../features/common/presentation/controllers/common_controller.dart';
import '../../features/common/presentation/controllers/mobile_settings_controller.dart';
import '../../features/common/presentation/controllers/upload_controller.dart';
import '../../features/fisher/data/repositories/dio_fisher_repository.dart';
import '../../features/fisher/data/repositories/mock_fisher_repository.dart';
import '../../features/fisher/data/repositories/offline_first_fisher_repository.dart';
import '../../features/fisher/domain/repositories/fisher_repository.dart';
import '../../features/fisher/presentation/controllers/fisher_controller.dart';
import '../../features/processor/data/repositories/dio_processor_repository.dart';
import '../../features/processor/data/repositories/mock_processor_repository.dart';
import '../../features/processor/domain/repositories/processor_repository.dart';
import '../../features/processor/presentation/controllers/processor_controller.dart';
import '../../features/retailer/data/repositories/dio_retailer_repository.dart';
import '../../features/retailer/data/repositories/mock_retailer_repository.dart';
import '../../features/retailer/domain/repositories/retailer_repository.dart';
import '../../features/retailer/presentation/controllers/retailer_controller.dart';
import '../../features/retailer/presentation/controllers/retail_reports_controller.dart';
import '../../features/transporter/data/repositories/dio_transporter_repository.dart';
import '../../features/transporter/data/repositories/mock_transporter_repository.dart';
import '../../features/transporter/data/repositories/sensor_repositories.dart';
import '../../features/transporter/domain/repositories/transporter_repository.dart';
import '../../features/transporter/domain/repositories/sensor_repositories.dart';
import '../../features/transporter/presentation/controllers/live_monitoring_controller.dart';
import '../../features/transporter/presentation/controllers/transporter_controller.dart';
import '../configuration/app_environment.dart';

class InitialBinding extends Bindings {
  InitialBinding({
    required this.config,
    required this.database,
    required this.storage,
    required this.dio,
    required this.apiClient,
    required this.tokenStore,
    required this.notificationService,
    required this.apiInterceptor,
  });

  final AppConfig config;
  final FishTraceDatabase database;
  final FlutterSecureStorage storage;
  final Dio dio;
  final ApiClient apiClient;
  final SecureTokenStore tokenStore;
  final NotificationService notificationService;
  final Interceptor apiInterceptor;

  @override
  void dependencies() {
    Get.put(config, permanent: true);
    Get.put(database, permanent: true);
    Get.put(storage, permanent: true);
    Get.put(dio, permanent: true);
    Get.put(apiClient, permanent: true);
    Get.put(const ErrorMapper(), permanent: true);
    Get.put(tokenStore, permanent: true);
    Get.put(notificationService, permanent: true);
    Get.put<Interceptor>(apiInterceptor, permanent: true);
    final mobileSettingsRepository = SecureMobileSettingsRepository(storage);
    final mobileSettings = MobileSettingsController(mobileSettingsRepository);
    Get.put<MobileSettingsRepository>(
      mobileSettingsRepository,
      permanent: true,
    );
    Get.put(mobileSettings, permanent: true);

    final firebaseSession = config.isMock || !config.firebaseEnabled
        ? MockFirebaseSessionRepository()
        : ApiFirebaseSessionRepository(apiClient);
    Get.put<FirebaseSessionRepository>(firebaseSession, permanent: true);

    final auth = config.isMock
        ? MockAuthRepository()
        : ApiAuthRepository(apiClient, tokenStore: tokenStore);
    final offlineRepository = DriftOfflineRepository(database);
    Get.put<OfflineRepository>(offlineRepository, permanent: true);
    Get.put<SyncRepository>(offlineRepository, permanent: true);
    final session = AppController(
      auth: auth,
      offlineRepository: offlineRepository,
      syncTransport: config.isMock
          ? MockSyncTransport()
          : DioSyncTransport(dio, database: database),
      tokenStore: tokenStore,
      sensorStream: MockSensorStream(),
      sensorAlertHandler: (reading) =>
          mobileSettings.settings.value.temperatureAlerts
          ? notificationService.showColdChainAlert(reading)
          : Future<void>.value(),
      firebaseSession: firebaseSession,
      autoSync: !config.isMock,
    );
    Get.put(session, permanent: true);
    Get.put(SyncController(session), permanent: true);

    AuthenticationBinding(storage).dependencies();
    CommonBinding(config, apiClient).dependencies();
    FileBinding(config, apiClient).dependencies();
    FisherBinding(config, database, apiClient, session).dependencies();
    ProcessorBinding(config, apiClient, session).dependencies();
    TransporterBinding(config, apiClient, session).dependencies();
    LiveMonitoringBinding(config, apiClient, session).dependencies();
    RetailerBinding(config, apiClient, session).dependencies();
  }
}

class FileBinding extends Bindings {
  FileBinding(this.config, this.api);
  final AppConfig config;
  final ApiClient api;
  @override
  void dependencies() {
    Get.lazyPut<FileRepository>(
      () => config.isMock ? MockFileRepository() : ApiFileRepository(api),
    );
    Get.lazyPut(
      () => UploadController(Get.find<FileRepository>()),
      fenix: true,
    );
  }
}

class AuthenticationBinding extends Bindings {
  AuthenticationBinding(this.storage);
  final FlutterSecureStorage storage;
  @override
  void dependencies() => Get.lazyPut(
    () => AuthenticationController(
      session: Get.find<AppController>(),
      onboarding: SecureOnboardingRepository(storage),
    ),
    fenix: true,
  );
}

class CommonBinding extends Bindings {
  CommonBinding(this.config, this.api);
  final AppConfig config;
  final ApiClient api;
  @override
  void dependencies() {
    Get.lazyPut<CommonRepository>(
      () => config.isMock ? MockCommonRepository() : DioCommonRepository(api),
    );
    Get.lazyPut<NotificationRepository>(() => Get.find<CommonRepository>());
    Get.lazyPut<SupportRepository>(() => Get.find<CommonRepository>());
    Get.lazyPut<ProfileRepository>(
      () => config.isMock
          ? MockProfileRepository()
          : ApiProfileRepository(api, Get.find<AppController>().auth),
    );
    Get.lazyPut(
      () => CommonController(Get.find<CommonRepository>()),
      fenix: true,
    );
  }
}

class LiveMonitoringBinding extends Bindings {
  LiveMonitoringBinding(this.config, this.api, this.session);
  final AppConfig config;
  final ApiClient api;
  final AppController session;

  @override
  void dependencies() {
    Get.lazyPut<SensorRepository>(
      () => config.isMock
          ? MockSensorRepository(MockSensorStream())
          : LaravelSensorRepository(api),
    );
    Get.lazyPut<LiveSensorRepository>(
      () => config.isMock || !config.firebaseEnabled
          ? MockLiveSensorRepository(MockSensorStream())
          : FirebaseLiveSensorRepository(
              api: api,
              session: Get.find<FirebaseSessionRepository>(),
            ),
    );
    Get.lazyPut(
      () => LiveMonitoringController(
        liveSensorRepository: Get.find<LiveSensorRepository>(),
        sensorRepository: Get.find<SensorRepository>(),
        session: session,
      ),
      fenix: true,
    );
  }
}

class FisherBinding extends Bindings {
  FisherBinding(this.config, this.database, this.api, this.session);
  final AppConfig config;
  final FishTraceDatabase database;
  final ApiClient api;
  final AppController session;
  @override
  void dependencies() {
    Get.lazyPut<FisherRepository>(
      () => OfflineFirstFisherRepository(
        remote: config.isMock
            ? MockFisherRepository()
            : DioFisherRepository(api),
        database: database,
        isOffline: () => session.offline.value,
        queueBoat: (boat) async {
          await session.queue(
            'Create boat',
            recordType: 'boat',
            payload: {
              'localId': boat.id,
              if (!boat.id.startsWith('LOCAL-') && !boat.id.startsWith('BOAT-'))
                'id': boat.id,
              'name': boat.name,
              'registration': boat.registration,
              'lengthMetres': boat.lengthMetres,
              'engineDetails': boat.engineDetails,
              'type': boat.type,
              'homePort': boat.homePort,
              'active': boat.active,
            },
          );
        },
        canUseRemote: () => config.isMock || !session.offline.value,
      ),
    );
    Get.lazyPut<BoatRepository>(() => Get.find<FisherRepository>());
    Get.lazyPut<FishingTripRepository>(() => Get.find<FisherRepository>());
    Get.lazyPut<CatchRepository>(() => Get.find<FisherRepository>());
    Get.lazyPut<BatchRepository>(() => Get.find<FisherRepository>());
    Get.lazyPut(
      () => FisherController(
        repository: Get.find<FisherRepository>(),
        session: session,
      ),
      fenix: true,
    );
  }
}

class ProcessorBinding extends Bindings {
  ProcessorBinding(this.config, this.api, this.session);
  final AppConfig config;
  final ApiClient api;
  final AppController session;
  @override
  void dependencies() {
    Get.lazyPut<ProcessorRepository>(
      () => config.isMock
          ? MockProcessorRepository()
          : DioProcessorRepository(api),
    );
    Get.lazyPut<IncomingBatchRepository>(() => Get.find<ProcessorRepository>());
    Get.lazyPut<ProcessingRepository>(() => Get.find<ProcessorRepository>());
    Get.lazyPut<QualityInspectionRepository>(
      () => Get.find<ProcessorRepository>(),
    );
    Get.lazyPut(
      () => ProcessorController(
        repository: Get.find<ProcessorRepository>(),
        session: session,
      ),
      fenix: true,
    );
  }
}

class TransporterBinding extends Bindings {
  TransporterBinding(this.config, this.api, this.session);
  final AppConfig config;
  final ApiClient api;
  final AppController session;
  @override
  void dependencies() {
    Get.lazyPut<TransporterRepository>(
      () => config.isMock
          ? MockTransporterRepository()
          : DioTransporterRepository(api),
    );
    Get.lazyPut<TransportTripRepository>(
      () => Get.find<TransporterRepository>(),
    );
    Get.lazyPut<VehicleRepository>(() => Get.find<TransporterRepository>());
    Get.lazyPut<IoTDeviceRepository>(() => Get.find<TransporterRepository>());
    Get.lazyPut<DeliveryRepository>(() => Get.find<TransporterRepository>());
    Get.lazyPut<TransportAlertRepository>(
      () => Get.find<TransporterRepository>(),
    );
    Get.lazyPut(
      () => TransporterController(
        repository: Get.find<TransporterRepository>(),
        session: session,
      ),
      fenix: true,
    );
  }
}

class RetailerBinding extends Bindings {
  RetailerBinding(this.config, this.api, this.session);
  final AppConfig config;
  final ApiClient api;
  final AppController session;
  @override
  void dependencies() {
    Get.lazyPut<RetailerRepository>(
      () =>
          config.isMock ? MockRetailerRepository() : DioRetailerRepository(api),
    );
    Get.lazyPut<InventoryRepository>(() => Get.find<RetailerRepository>());
    Get.lazyPut<RetailAlertRepository>(() => Get.find<RetailerRepository>());
    Get.lazyPut<SaleRepository>(() => Get.find<RetailerRepository>());
    Get.lazyPut<ReceiptRepository>(() => Get.find<RetailerRepository>());
    Get.lazyPut<RetailReportRepository>(() => Get.find<RetailerRepository>());
    Get.lazyPut(
      () => RetailerController(
        repository: Get.find<RetailerRepository>(),
        session: session,
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => RetailReportsController(
        repository: Get.find<RetailReportRepository>(),
      ),
      fenix: true,
    );
  }
}

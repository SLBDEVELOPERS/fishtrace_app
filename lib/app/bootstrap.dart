import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../firebase_options.dart';
import '../core/data/repositories.dart';
import '../core/database/fishtrace_database.dart';
import '../core/errors/app_error_handler.dart';
import '../core/network/api_client.dart';
import '../core/network/api_support.dart';
import '../core/network/error_mapper.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/secure_token_store.dart';
import '../features/common/presentation/controllers/mobile_settings_controller.dart';
import 'app.dart';
import 'bindings/app_bindings.dart';
import 'configuration/app_environment.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppErrorHandler.instance.install();
  final config = AppConfig.fromDefines();
  if (config.firebaseEnabled) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final database = await FishTraceDatabase.open();
  const storage = FlutterSecureStorage();
  const tokenStore = SecureTokenStore(storage);
  const errors = ErrorMapper();
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  final apiInterceptor = ApiInterceptor(tokenStore: tokenStore);
  dio.interceptors.add(apiInterceptor);
  final apiClient = ApiClient(dio, errors);
  final notifications = NotificationService();
  await notifications.initialize();

  InitialBinding(
    config: config,
    database: database,
    storage: storage,
    dio: dio,
    apiClient: apiClient,
    tokenStore: tokenStore,
    notificationService: notifications,
    apiInterceptor: apiInterceptor,
  ).dependencies();

  await Get.find<MobileSettingsController>().load();

  final session = Get.find<AppController>();
  apiInterceptor.onUnauthorized = session.expireSession;
  await session.startConnectivityMonitoring();
  await session.restoreSession();

  runApp(const FishTraceApp());
}

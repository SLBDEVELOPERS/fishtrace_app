enum AppDataSourceMode { mock, api }

class AppConfig {
  const AppConfig({
    required this.dataSourceMode,
    required this.apiBaseUrl,
    required this.firebaseEnabled,
  });

  final AppDataSourceMode dataSourceMode;
  final String apiBaseUrl;
  final bool firebaseEnabled;

  bool get isMock => dataSourceMode == AppDataSourceMode.mock;

  static AppConfig fromDefines() {
    const currentMode = String.fromEnvironment('DATA_SOURCE_MODE');
    const legacyMode = String.fromEnvironment('APP_MODE', defaultValue: 'api');
    const mode = currentMode == '' ? legacyMode : currentMode;
    final dataSourceMode = mode.toLowerCase() == 'api'
        ? AppDataSourceMode.api
        : AppDataSourceMode.mock;
    return AppConfig(
      dataSourceMode: dataSourceMode,
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://fishtrace.aicainvestment.com/api/v1',
        //defaultValue: 'http://192.168.1.120:8002/api/v1',
      ),
      firebaseEnabled: const bool.fromEnvironment(
        'FIREBASE_ENABLED',
        defaultValue: false,
      ),
    );
  }
}

typedef Environment = AppConfig;

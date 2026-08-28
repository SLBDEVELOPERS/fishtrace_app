import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.firebaseEnabled});

  final String apiBaseUrl;
  final bool firebaseEnabled;

  static AppConfig fromDefines() => fromValues(
    dataSourceMode: const String.fromEnvironment('DATA_SOURCE_MODE'),
    legacyMode: const String.fromEnvironment('APP_MODE'),
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://fishtrace.aicainvestment.com/api/v1',
    ),
    firebaseEnabled: const bool.fromEnvironment(
      'FIREBASE_ENABLED',
      defaultValue: true,
    ),
  );

  @visibleForTesting
  static AppConfig fromValues({
    String dataSourceMode = '',
    String legacyMode = '',
    required String apiBaseUrl,
    bool firebaseEnabled = true,
    bool releaseMode = kReleaseMode,
  }) {
    final configuredMode = dataSourceMode.trim().isNotEmpty
        ? dataSourceMode.trim()
        : legacyMode.trim();
    if (configuredMode.isNotEmpty && configuredMode.toLowerCase() != 'api') {
      throw StateError(
        'FishTrace is API-only. Remove DATA_SOURCE_MODE/APP_MODE or set it to "api".',
      );
    }

    final normalizedUrl = apiBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalizedUrl);
    final validHttpUrl =
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    if (!validHttpUrl) {
      throw StateError('API_BASE_URL must be an absolute HTTP(S) URL.');
    }
    if (releaseMode && uri.scheme != 'https') {
      throw StateError('Release builds require an HTTPS API_BASE_URL.');
    }

    return AppConfig(
      apiBaseUrl: normalizedUrl,
      firebaseEnabled: firebaseEnabled,
    );
  }
}

typedef Environment = AppConfig;

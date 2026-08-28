import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/mobile_settings.dart';
import '../../domain/repositories/mobile_settings_repository.dart';

class SecureMobileSettingsRepository implements MobileSettingsRepository {
  const SecureMobileSettingsRepository(this._storage);

  static const _storageKey = 'fishtrace.mobile_settings.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<MobileSettings> load() async {
    final encoded = await _storage.read(key: _storageKey);
    if (encoded == null || encoded.isEmpty) return const MobileSettings();
    try {
      final json = (jsonDecode(encoded) as Map).cast<String, Object?>();
      return MobileSettings(
        compactDashboard: json['compact_dashboard'] == true,
        themeMode: AppThemeMode.values.firstWhere(
          (value) => value.name == json['theme_mode'],
          orElse: () => json['use_device_theme'] == false
              ? AppThemeMode.light
              : AppThemeMode.system,
        ),
        measurementSystem: MeasurementSystem.values.firstWhere(
          (value) => value.name == json['measurement_system'],
          orElse: () => MeasurementSystem.metric,
        ),
        language: MobileLanguage.values.firstWhere(
          (value) => value.name == json['language'],
          orElse: () => MobileLanguage.english,
        ),
        temperatureAlerts: json['temperature_alerts'] == true,
        workflowUpdates: json['workflow_updates'] == true,
        systemMessages: json['system_messages'] == true,
      );
    } on FormatException {
      return const MobileSettings();
    } on TypeError {
      return const MobileSettings();
    }
  }

  @override
  Future<void> save(MobileSettings settings) => _storage.write(
    key: _storageKey,
    value: jsonEncode({
      'compact_dashboard': settings.compactDashboard,
      'theme_mode': settings.themeMode.name,
      'measurement_system': settings.measurementSystem.name,
      'language': settings.language.name,
      'temperature_alerts': settings.temperatureAlerts,
      'workflow_updates': settings.workflowUpdates,
      'system_messages': settings.systemMessages,
    }),
  );
}

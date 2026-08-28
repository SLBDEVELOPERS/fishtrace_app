import 'package:fishtrace/features/common/data/repositories/secure_mobile_settings_repository.dart';
import 'package:fishtrace/features/common/domain/entities/mobile_settings.dart';
import 'package:fishtrace/features/common/presentation/controllers/mobile_settings_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('mobile settings persist with canonical typed values', () async {
    const repository = SecureMobileSettingsRepository(FlutterSecureStorage());
    final controller = MobileSettingsController(repository);

    await controller.load();
    await controller.save(
      controller.settings.value.copyWith(
        compactDashboard: true,
        themeMode: AppThemeMode.dark,
        measurementSystem: MeasurementSystem.imperial,
        language: MobileLanguage.tamil,
        temperatureAlerts: false,
        workflowUpdates: false,
      ),
    );

    final restored = await repository.load();
    expect(restored.compactDashboard, isTrue);
    expect(restored.themeMode, AppThemeMode.dark);
    expect(restored.measurementSystem, MeasurementSystem.imperial);
    expect(restored.language, MobileLanguage.tamil);
    expect(restored.temperatureAlerts, isFalse);
    expect(restored.workflowUpdates, isFalse);
    expect(restored.systemMessages, isFalse);
  });

  test('invalid stored settings safely restore canonical defaults', () async {
    FlutterSecureStorage.setMockInitialValues({
      'fishtrace.mobile_settings.v1': '{not-json',
    });
    const repository = SecureMobileSettingsRepository(FlutterSecureStorage());

    final restored = await repository.load();

    expect(restored.measurementSystem, MeasurementSystem.metric);
    expect(restored.language, MobileLanguage.english);
    expect(restored.temperatureAlerts, isFalse);
  });

  test('runtime exposes only the supported English metric contract', () async {
    const repository = SecureMobileSettingsRepository(FlutterSecureStorage());
    await repository.save(
      const MobileSettings(
        measurementSystem: MeasurementSystem.imperial,
        language: MobileLanguage.tamil,
      ),
    );
    final controller = MobileSettingsController(repository);

    await controller.load();

    expect(
      controller.settings.value.measurementSystem,
      MeasurementSystem.metric,
    );
    expect(controller.settings.value.language, MobileLanguage.english);
  });
}

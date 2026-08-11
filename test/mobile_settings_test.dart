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
        useDeviceTheme: false,
        measurementSystem: MeasurementSystem.imperial,
        language: MobileLanguage.tamil,
        temperatureAlerts: false,
        workflowUpdates: false,
      ),
    );

    final restored = await repository.load();
    expect(restored.compactDashboard, isTrue);
    expect(restored.useDeviceTheme, isFalse);
    expect(restored.measurementSystem, MeasurementSystem.imperial);
    expect(restored.language, MobileLanguage.tamil);
    expect(restored.temperatureAlerts, isFalse);
    expect(restored.workflowUpdates, isFalse);
    expect(restored.systemMessages, isTrue);
  });

  test('invalid stored settings safely restore canonical defaults', () async {
    FlutterSecureStorage.setMockInitialValues({
      'fishtrace.mobile_settings.v1': '{not-json',
    });
    const repository = SecureMobileSettingsRepository(FlutterSecureStorage());

    final restored = await repository.load();

    expect(restored.measurementSystem, MeasurementSystem.metric);
    expect(restored.language, MobileLanguage.english);
    expect(restored.temperatureAlerts, isTrue);
  });
}

import '../entities/mobile_settings.dart';

abstract interface class MobileSettingsRepository {
  Future<MobileSettings> load();

  Future<void> save(MobileSettings settings);
}

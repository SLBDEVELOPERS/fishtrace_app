import 'package:get/get.dart';

import '../../domain/entities/mobile_settings.dart';
import '../../domain/repositories/mobile_settings_repository.dart';

class MobileSettingsController extends GetxController {
  MobileSettingsController(this._repository);

  final MobileSettingsRepository _repository;
  final settings = const MobileSettings().obs;

  Future<void> load() async {
    final stored = await _repository.load();
    settings.value = stored.copyWith(
      measurementSystem: MeasurementSystem.metric,
      language: MobileLanguage.english,
    );
  }

  Future<void> save(MobileSettings value) async {
    settings.value = value;
    await _repository.save(value);
  }
}

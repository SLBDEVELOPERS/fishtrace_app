import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/onboarding_repository.dart';

class SecureOnboardingRepository implements OnboardingRepository {
  SecureOnboardingRepository(this._storage);

  static const _key = 'fishtrace.onboarding.complete';
  final FlutterSecureStorage _storage;

  @override
  Future<bool> isComplete() async => await _storage.read(key: _key) == 'true';

  @override
  Future<void> markComplete() => _storage.write(key: _key, value: 'true');
}

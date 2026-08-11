import '../../../../core/models/models.dart';

abstract interface class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({required String name, required String email});
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  });
}

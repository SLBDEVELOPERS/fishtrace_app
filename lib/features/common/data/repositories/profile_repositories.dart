import '../../../../core/data/repositories.dart';
import '../../../../core/models/models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../../../core/network/user_dto.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  User _user = const User(
    name: 'Alex Johnson',
    email: 'fisher@fishtrace.demo',
    role: UserRole.fisher,
  );
  @override
  Future<User> getProfile() async => _user;
  @override
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    _user = User(
      name: name,
      email: email,
      role: _user.role,
      id: _user.id,
      organization: _user.organization,
    );
    return _user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) async {}
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api, this._auth);
  final ApiClient _api;
  final AuthRepository _auth;
  @override
  Future<User> getProfile() => _auth.me();
  @override
  Future<User> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = ApiData.map(
      await _api.put(
        ApiEndpoints.profile,
        data: UpdateProfileRequestDto(name: name, email: email).toJson(),
      ),
    );
    final data = response['data'] is Map
        ? ApiData.map(response['data'])
        : response;
    return UserDto.fromJson(data).toDomain();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) => _auth.changePassword(
    currentPassword: currentPassword,
    password: password,
    confirmation: confirmation,
  );
}

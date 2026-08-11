import '../models/models.dart';
import 'api_support.dart';

class UserDto {
  const UserDto(this.json);
  final Map<String, Object?> json;

  factory UserDto.fromJson(Map<String, Object?> json) => UserDto(json);

  User toDomain() {
    final roleValue = ApiData.string(json, 'role').toLowerCase();
    final organizationJson = json['organization'] is Map
        ? ApiData.map(json['organization'])
        : null;
    return User(
      id: ApiData.value(json, 'id')?.toString(),
      name: ApiData.string(json, 'name'),
      email: ApiData.string(json, 'email'),
      role: UserRole.values.firstWhere(
        (value) => value.name == roleValue,
        orElse: () => UserRole.fisher,
      ),
      organization: organizationJson == null
          ? null
          : UserOrganization(
              id: ApiData.string(organizationJson, 'id'),
              name: ApiData.string(organizationJson, 'name'),
              code: ApiData.string(organizationJson, 'code'),
              type: ApiData.string(organizationJson, 'type'),
              active: ApiData.boolean(organizationJson, 'isActive'),
            ),
    );
  }
}

class UpdateProfileRequestDto {
  const UpdateProfileRequestDto({required this.name, required this.email});
  final String name;
  final String email;

  Map<String, Object?> toJson() => {
    'name': name.trim(),
    'email': email.trim().toLowerCase(),
  };
}

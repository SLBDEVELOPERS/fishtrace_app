import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/common_repository.dart';
import '../dtos/notification_dto.dart';
import 'mock_common_repository.dart';

class DioCommonRepository implements CommonRepository {
  DioCommonRepository(this._api, {MockCommonRepository? localSupport})
    : _localSupport = localSupport ?? MockCommonRepository();
  final ApiClient _api;
  final MockCommonRepository _localSupport;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final notifications = <AppNotification>[];
    var page = 1;
    var lastPage = 1;
    do {
      final response = await _api.get(
        ApiEndpoints.notifications,
        query: {'page': page, 'per_page': 100},
      );
      notifications.addAll(
        ApiData.list(
          response,
        ).map((json) => NotificationDto.fromJson(json).toDomain()),
      );
      final envelope = ApiData.map(response);
      final pagination = envelope['data'] is Map
          ? ApiData.map(envelope['data'])
          : const <String, Object?>{};
      lastPage = ApiData.integer(pagination, 'lastPage', 1);
      page++;
    } while (page <= lastPage);
    return notifications;
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await _api.post(ApiEndpoints.notificationRead(id));
  }

  @override
  Future<List<HelpArticle>> getHelpArticles() async {
    // The Laravel mobile contract intentionally has no help-content endpoint.
    // Keep bundled support content available in API mode instead of issuing a
    // guaranteed 404 request.
    return _localSupport.getHelpArticles();
  }

  @override
  Future<void> submitSupportIssue({
    required String subject,
    required String description,
  }) async {
    await _api.post(
      ApiEndpoints.supportIssues,
      data: {'subject': subject.trim(), 'description': description.trim()},
    );
  }
}

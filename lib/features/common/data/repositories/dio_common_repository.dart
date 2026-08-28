import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_support.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/common_repository.dart';
import '../dtos/notification_dto.dart';

class DioCommonRepository implements CommonRepository {
  DioCommonRepository(this._api);
  final ApiClient _api;

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
    // This is bundled documentation, not simulated server data.
    return const [
      HelpArticle(
        title: 'Getting Started',
        subtitle: 'Learn the basics of FishTrace',
        category: 'Quick Help',
        iconKey: 'start',
      ),
      HelpArticle(
        title: 'FAQs',
        subtitle: 'Find answers to common questions',
        category: 'Quick Help',
        iconKey: 'faq',
      ),
      HelpArticle(
        title: 'Best Practices',
        subtitle: 'Tips for accurate tracking',
        category: 'Quick Help',
        iconKey: 'practice',
      ),
      HelpArticle(
        title: 'Contact Support',
        subtitle: 'Get help from our team',
        category: 'Quick Help',
        iconKey: 'contact',
      ),
      HelpArticle(
        title: 'User Guide',
        subtitle: 'Step-by-step instructions',
        category: 'Resources',
        iconKey: 'guide',
      ),
      HelpArticle(
        title: 'Video Tutorials',
        subtitle: 'Watch and learn',
        category: 'Resources',
        iconKey: 'video',
      ),
    ];
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

import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markNotificationRead(String id);
}

abstract interface class SupportRepository {
  Future<List<HelpArticle>> getHelpArticles();
  Future<void> submitSupportIssue({
    required String subject,
    required String description,
  });
}

/// Aggregate preserved for the completed common-screen controller. The
/// narrower contracts are also registered in GetX for feature-level reuse.
abstract interface class CommonRepository
    implements NotificationRepository, SupportRepository {}

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/common_repository.dart';

class MockCommonRepository implements CommonRepository {
  final _notifications = <AppNotification>[
    const AppNotification(
      id: 'notification-temperature',
      title: 'Temperature Alert',
      message: 'Hold temperature above 4°C for trip #TRP-2024-05-21',
      timeLabel: '07:15 AM',
      category: NotificationCategory.alert,
      severity: NotificationSeverity.critical,
      iconKey: 'temperature',
    ),
    const AppNotification(
      id: 'notification-catch',
      title: 'Catch Logged',
      message: 'New catch of 125.4 kg logged for trip #TRP-2024-05-21',
      timeLabel: '09:30 AM',
      category: NotificationCategory.update,
      iconKey: 'catch',
    ),
    const AppNotification(
      id: 'notification-trip',
      title: 'Trip Completed',
      message: 'Trip #TRP-2024-05-21 completed successfully',
      timeLabel: '10:30 AM',
      category: NotificationCategory.update,
      iconKey: 'trip',
    ),
    const AppNotification(
      id: 'notification-system',
      title: 'System Update',
      message: 'New FishTrace features are now available',
      timeLabel: '09:00 AM',
      category: NotificationCategory.system,
      iconKey: 'system',
      dayLabelOverride: 'Yesterday',
      read: true,
    ),
    const AppNotification(
      id: 'notification-stock',
      title: 'Low Stock',
      message: 'Yellowfin Tuna stock has fallen below its reorder level',
      timeLabel: '06:45 PM',
      category: NotificationCategory.alert,
      severity: NotificationSeverity.warning,
      iconKey: 'stock',
      dayLabelOverride: 'Yesterday',
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications() async =>
      List.unmodifiable(_notifications);

  @override
  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  @override
  Future<List<HelpArticle>> getHelpArticles() async => const [
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

  @override
  Future<void> submitSupportIssue({
    required String subject,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }
}

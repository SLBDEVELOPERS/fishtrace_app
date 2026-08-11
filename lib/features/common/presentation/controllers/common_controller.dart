import 'package:get/get.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/common_repository.dart';

enum NotificationFilter { all, alerts, updates, system }

class CommonController extends GetxController {
  CommonController(this._repository);

  final CommonRepository _repository;

  final notifications = <AppNotification>[].obs;
  final helpArticles = <HelpArticle>[].obs;
  final notificationFilter = NotificationFilter.all.obs;
  final notificationLoading = false.obs;
  final helpLoading = false.obs;
  final supportSubmitting = false.obs;
  final searchQuery = ''.obs;
  final error = Rxn<AppException>();

  List<AppNotification> get filteredNotifications {
    final filter = notificationFilter.value;
    return notifications.where((notification) {
      return switch (filter) {
        NotificationFilter.all => true,
        NotificationFilter.alerts =>
          notification.category == NotificationCategory.alert,
        NotificationFilter.updates =>
          notification.category == NotificationCategory.update,
        NotificationFilter.system =>
          notification.category == NotificationCategory.system,
      };
    }).toList();
  }

  List<HelpArticle> get filteredHelpArticles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return helpArticles;
    return helpArticles
        .where(
          (article) =>
              article.title.toLowerCase().contains(query) ||
              article.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  int get unreadCount => notifications.where((item) => !item.read).length;
  int get unreadAlertCount => notifications
      .where(
        (item) => !item.read && item.category == NotificationCategory.alert,
      )
      .length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadHelp();
  }

  Future<void> loadNotifications() async {
    notificationLoading.value = true;
    error.value = null;
    try {
      notifications.assignAll(await _repository.getNotifications());
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      notificationLoading.value = false;
    }
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    await _repository.markNotificationRead(notification.id);
    final index = notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    if (index >= 0) notifications[index] = notification.copyWith(read: true);
  }

  Future<void> loadHelp() async {
    helpLoading.value = true;
    error.value = null;
    try {
      helpArticles.assignAll(await _repository.getHelpArticles());
    } on AppException catch (failure) {
      error.value = failure;
    } finally {
      helpLoading.value = false;
    }
  }

  Future<bool> submitIssue(String subject, String description) async {
    if (subject.trim().isEmpty || description.trim().length < 10) return false;
    supportSubmitting.value = true;
    error.value = null;
    try {
      await _repository.submitSupportIssue(
        subject: subject.trim(),
        description: description.trim(),
      );
      return true;
    } on AppException catch (failure) {
      error.value = failure;
      return false;
    } finally {
      supportSubmitting.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/data/repositories.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/common_controller.dart';
import '../widgets/role_bottom_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonController>();
    final role = Get.find<AppController>().user.value!.role;
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Notifications', teal: true),
      bottomNavigation: RoleBottomBar(
        role: role,
        selectedIndex: role == UserRole.fisher || role == UserRole.processor
            ? 3
            : 2,
        alertBadge: controller.unreadCount,
      ),
      body: Column(
        children: [
          _NotificationFilters(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.notificationLoading.value) {
                return const LoadingState(message: 'Loading notifications…');
              }
              final items = controller.filteredNotifications;
              if (items.isEmpty) {
                return const EmptyState(
                  title: 'No notifications',
                  message: 'There are no notifications in this category.',
                  icon: Icons.notifications_none,
                );
              }
              final days = items.map((item) => item.dayLabel).toSet();
              return RefreshIndicator(
                onRefresh: controller.loadNotifications,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  children: [
                    for (final day in days) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8),
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      for (final item in items.where(
                        (item) => item.dayLabel == day,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotificationTile(
                            item: item,
                            onTap: () => controller.markRead(item),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NotificationFilters extends StatelessWidget {
  const _NotificationFilters({required this.controller});

  final CommonController controller;

  @override
  Widget build(BuildContext context) => Container(
    color: FishTraceColors.surface,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Obx(
      () => SegmentedButton<NotificationFilter>(
        showSelectedIcon: false,
        segments: [
          const ButtonSegment(
            value: NotificationFilter.all,
            label: Text('All'),
          ),
          ButtonSegment(
            value: NotificationFilter.alerts,
            label: Badge(
              isLabelVisible: controller.unreadAlertCount > 0,
              label: Text('${controller.unreadAlertCount}'),
              child: const Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text('Alerts'),
              ),
            ),
          ),
          const ButtonSegment(
            value: NotificationFilter.updates,
            label: Text('Updates'),
          ),
          const ButtonSegment(
            value: NotificationFilter.system,
            label: Text('System'),
          ),
        ],
        selected: {controller.notificationFilter.value},
        onSelectionChanged: (selection) =>
            controller.notificationFilter.value = selection.first,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.severity) {
      NotificationSeverity.critical => FishTraceColors.error,
      NotificationSeverity.warning => FishTraceColors.warning,
      NotificationSeverity.normal => FishTraceColors.info,
    };
    final icon = item.type.contains('TEMPERATURE')
        ? Icons.thermostat
        : item.type.contains('BATTERY')
        ? Icons.battery_alert_outlined
        : item.type.contains('DEVICE') || item.type.contains('FIREBASE')
        ? Icons.sensors_outlined
        : item.type.contains('BATCH') || item.type == 'RECALL'
        ? Icons.inventory_2_outlined
        : item.type.contains('TRANSPORT') || item.type.contains('DELIVERY')
        ? Icons.route_outlined
        : item.type.contains('REPORT')
        ? Icons.description_outlined
        : Icons.system_update_alt;
    return FishTraceCard(
      onTap: onTap,
      color: item.read
          ? FishTraceColors.surface
          : FishTraceColors.oceanLight.withValues(alpha: .42),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: FishTraceSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      item.timeLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (!item.read)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(left: 6, top: 5),
              decoration: const BoxDecoration(
                color: FishTraceColors.info,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

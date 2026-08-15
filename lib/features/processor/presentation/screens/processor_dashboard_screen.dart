import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/controllers/common_controller.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../../../core/data/repositories.dart';
import '../controllers/processor_controller.dart';

class ProcessorDashboardScreen extends StatelessWidget {
  const ProcessorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessorController>();
    final common = Get.find<CommonController>();
    final appSession = Get.find<AppController>();
    final userName = appSession.user.value?.name ?? 'Processor';
    return FishTraceScaffold(
      safeAreaTop: false,
      systemUiOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      bottomNavigation: RoleBottomBar(
        role: UserRole.processor,
        selectedIndex: 0,
        alertBadge: common.unreadCount,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingState(message: 'Loading processor dashboard…');
        }
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProcessorHeader(
              alerts: common.unreadCount,
              userName: userName,
              organizationName:
                  appSession.user.value?.organization?.name ??
                  'Processor operations',
              onAlerts: () => context.push(AppRoute.notifications),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  _DashboardMetricPanel(
                    title: 'Incoming Batches',
                    value: '${controller.incoming.length}',
                    subtitle: 'Currently available arrivals',
                    icon: Icons.directions_boat_outlined,
                    onTap: () => context.go('/processor/scan-batch'),
                  ),
                  const SizedBox(height: 8),
                  _DashboardMetricPanel(
                    title: 'Today’s Processing Queue',
                    value:
                        '${controller.history.where((job) => job.status == BatchStatus.inProgress).length}',
                    subtitle: 'Batches currently in progress',
                    icon: Icons.schedule,
                    onTap: () {
                      final job = controller.history.firstWhereOrNull(
                        (item) => item.status == BatchStatus.inProgress,
                      );
                      if (job == null) {
                        context.go('/processor/history');
                        return;
                      }
                      controller.selectProcessingJob(job);
                      context.go('/processor/processing');
                    },
                  ),
                  const SizedBox(height: 8),
                  _DashboardMetricPanel(
                    title: 'Cold-Chain Notices',
                    value: '${common.unreadCount}',
                    subtitle: 'Unread operational notices',
                    icon: Icons.warning_amber_rounded,
                    color: FishTraceColors.error,
                    onTap: () => context.push(AppRoute.notifications),
                  ),
                  const SectionHeader(title: 'Quick Actions'),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Batch',
                        onTap: () => context.go('/processor/scan-batch'),
                      ),
                      const SizedBox(width: 7),
                      _QuickAction(
                        icon: Icons.inventory_2_outlined,
                        label: 'New Intake',
                        onTap: () => context.go('/processor/scan-batch'),
                      ),
                      const SizedBox(width: 7),
                      _QuickAction(
                        icon: Icons.call_split,
                        label: 'Split / Pack',
                        onTap: () => context.go('/processor/history'),
                      ),
                      const SizedBox(width: 7),
                      _QuickAction(
                        icon: Icons.bar_chart,
                        label: 'Reports',
                        onTap: () => context.go('/processor/history'),
                      ),
                    ],
                  ),
                  SectionHeader(
                    title: 'Recent Intake',
                    action: 'View all',
                    onAction: () => context.go('/processor/history'),
                  ),
                  for (final batch in controller.incoming)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FishTraceCard(
                        onTap: () {
                          controller.selectedBatch.value = batch;
                          context.go('/processor/intake');
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.set_meal,
                              color: FishTraceColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    batch.id,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${batch.species} · ${batch.weightKg} kg',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: batch.status == BatchStatus.newBatch
                                  ? 'New Intake'
                                  : 'In Progress',
                              color: batch.status == BatchStatus.newBatch
                                  ? FishTraceColors.success
                                  : FishTraceColors.info,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ProcessorHeader extends StatelessWidget {
  const _ProcessorHeader({
    required this.alerts,
    required this.userName,
    required this.organizationName,
    required this.onAlerts,
  });

  final int alerts;
  final String userName;
  final String organizationName;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 10, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [FishTraceColors.primaryDark, FishTraceColors.primary],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
    ),
    child: SafeArea(
      bottom: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, $userName 👋',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  organizationName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: onAlerts,
            icon: Badge(
              isLabelVisible: alerts > 0,
              label: Text('$alerts'),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashboardMetricPanel extends StatelessWidget {
  const _DashboardMetricPanel({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color = FishTraceColors.primary,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 5),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 31),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: FishTraceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
      child: Column(
        children: [
          Icon(icon, color: FishTraceColors.primary, size: 20),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}

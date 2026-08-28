import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/controllers/common_controller.dart';
import '../../../common/presentation/controllers/mobile_settings_controller.dart';
import '../../../common/presentation/formatters/measurement_formatter.dart';
import '../../../common/domain/entities/mobile_settings.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../../../core/data/repositories.dart';
import '../controllers/fisher_controller.dart';
import '../widgets/marine_weather_card.dart';

class FisherDashboardScreen extends StatelessWidget {
  const FisherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FisherController>();
    final common = Get.find<CommonController>();
    final appSession = Get.find<AppController>();
    final mobileSettings = Get.find<MobileSettingsController>();
    final userName = appSession.user.value?.name ?? 'Fisher';
    return FishTraceScaffold(
      safeAreaTop: false,
      systemUiOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      bottomNavigation: RoleBottomBar(
        role: UserRole.fisher,
        selectedIndex: 0,
        alertBadge: common.unreadCount,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingState(message: 'Loading fisher dashboard…');
        }
        final trip = controller.activeTrip.value;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardHeader(
                alertCount: common.unreadCount,
                userName: userName,
                onNotifications: () => context.push(AppRoute.notifications),
                onSync: () => context.push(AppRoute.sync),
                pendingSyncCount: appSession.syncItems.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              sliver: SliverList.list(
                children: [
                  SectionHeader(
                    title: 'Today’s Overview',
                    action: 'See all',
                    onAction: () => context.go('/fisher/catch-history'),
                  ),
                  if (trip != null)
                    FishTraceCard(
                      onTap: () => context.go('/fisher/active-trip'),
                      color: FishTraceColors.primary.withValues(alpha: .045),
                      borderColor: FishTraceColors.primary.withValues(
                        alpha: .18,
                      ),
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Active Trip',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                              const StatusChip(label: 'In Progress'),
                            ],
                          ),
                          const SizedBox(height: FishTraceSpacing.xs),
                          Text(
                            trip.label,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            trip.boatName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: FishTraceSpacing.xs),
                          Text(
                            'Started ${FishTraceTime.format(trip.startedAt, 'hh:mm a')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  else
                    FishTraceCard(
                      onTap: () => context.go('/fisher/start-trip'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Active Trip',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                              const StatusChip(label: 'Not Started'),
                            ],
                          ),
                          const SizedBox(height: FishTraceSpacing.xs),
                          Text(
                            'No active trip',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: FishTraceSpacing.md),
                          FishTracePrimaryButton(
                            label: 'Start New Trip',
                            onPressed: () => context.go('/fisher/start-trip'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: FishTraceSpacing.xs),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(1) >= 1.5
                        ? 140
                        : 112,
                    child: Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            label: 'Total Catch (Today)',
                            value: MeasurementFormatter.weight(
                              controller.totalCatchKg,
                              mobileSettings.settings.value,
                            ),
                            icon: Icons.set_meal_outlined,
                          ),
                        ),
                        const SizedBox(width: FishTraceSpacing.xs),
                        Expanded(
                          child: MetricCard(
                            label: 'Total Batches',
                            value: '${controller.batches.length}',
                            icon: Icons.layers_outlined,
                          ),
                        ),
                        const SizedBox(width: FishTraceSpacing.xs),
                        Expanded(
                          child: MetricCard(
                            label: 'Avg. Catch / hr',
                            value: _averageCatchPerHour(
                              trip?.catchKg ?? 0,
                              trip?.startedAt,
                              mobileSettings.settings.value,
                            ),
                            icon: Icons.speed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Weather'),
                  MarineWeatherCard(controller: controller),
                  SectionHeader(
                    title: 'Recent Activity',
                    action: 'See all',
                    onAction: () => context.go('/fisher/catch-history'),
                  ),
                  FishTraceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (controller.catches.isNotEmpty) ...[
                          _ActivityRow(
                            icon: Icons.location_on_outlined,
                            title: 'Catch Added',
                            subtitle:
                                '${controller.catches.first.species} · ${MeasurementFormatter.weight(controller.catches.first.weightKg, mobileSettings.settings.value)}',
                            time: DateFormat('hh:mm a').format(
                              FishTraceTime.inSriLanka(
                                controller.catches.first.caughtAt,
                              ),
                            ),
                            onTap: () => context.go('/fisher/catch-history'),
                          ),
                        ],
                        if (controller.batches.isNotEmpty) ...[
                          if (controller.catches.isNotEmpty)
                            const Divider(height: 1),
                          _ActivityRow(
                            icon: Icons.layers_outlined,
                            title: 'Batch Created',
                            subtitle: controller.batches.first.label,
                            time: DateFormat('hh:mm a').format(
                              FishTraceTime.inSriLanka(
                                controller.batches.first.createdAt,
                              ),
                            ),
                            onTap: () => context.go(
                              '/fisher/batch-details',
                              extra: controller.batches.first.id,
                            ),
                          ),
                        ],
                        if (trip != null) ...[
                          if (controller.catches.isNotEmpty ||
                              controller.batches.isNotEmpty)
                            const Divider(height: 1),
                          _ActivityRow(
                            icon: Icons.route_outlined,
                            title: 'Trip Started',
                            subtitle: trip.label,
                            time: FishTraceTime.format(
                              trip.startedAt,
                              'hh:mm a',
                            ),
                            onTap: () => context.go('/fisher/active-trip'),
                          ),
                        ],
                        if (controller.catches.isEmpty &&
                            controller.batches.isEmpty &&
                            trip == null)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No recent activity',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Quick Actions'),
                  SizedBox(
                    height: 86,
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.directions_boat_outlined,
                            label: 'Manage boats',
                            onTap: () => context.go('/fisher/boats'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_location_alt_outlined,
                            label: 'Add catch',
                            enabled: trip != null,
                            onTap: trip == null
                                ? null
                                : () => context.go('/fisher/add-catch'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.layers_outlined,
                            label: 'Create batch',
                            enabled: controller.catches.any(
                              (item) => item.availableWeightKg > .001,
                            ),
                            onTap:
                                controller.catches.any(
                                  (item) => item.availableWeightKg > .001,
                                )
                                ? () => context.go('/fisher/create-batch')
                                : null,
                          ),
                        ),
                      ],
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.alertCount,
    required this.userName,
    required this.onNotifications,
    required this.onSync,
    required this.pendingSyncCount,
  });

  final int alertCount;
  final String userName;
  final VoidCallback onNotifications;
  final VoidCallback onSync;
  final int pendingSyncCount;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 20, 10, 22),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [FishTraceColors.primaryDark, FishTraceColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Color(0x26004B5A),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
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
                  'Good morning, $userName',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fisher',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .78),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sync Status',
            onPressed: onSync,
            icon: Badge(
              isLabelVisible: pendingSyncCount > 0,
              label: Text('$pendingSyncCount'),
              backgroundColor: FishTraceColors.warning,
              child: const Icon(Icons.sync, color: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: onNotifications,
            icon: Badge(
              isLabelVisible: alertCount > 0,
              label: Text('$alertCount'),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

String _averageCatchPerHour(
  double catchKg,
  DateTime? startedAt,
  MobileSettings settings,
) {
  if (startedAt == null) return MeasurementFormatter.weight(0, settings);
  final minutes = DateTime.now().difference(startedAt).inMinutes;
  if (minutes < 1) return MeasurementFormatter.weight(catchKg, settings);
  return MeasurementFormatter.weight(catchKg / (minutes / 60), settings);
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 58,
    leading: Icon(icon, color: FishTraceColors.primary, size: 20),
    title: Text(title, style: Theme.of(context).textTheme.labelMedium),
    subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
    onTap: onTap,
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    onTap: onTap,
    color: enabled
        ? FishTraceColors.primary.withValues(alpha: .035)
        : Theme.of(context).colorScheme.surfaceContainerLow,
    borderColor: enabled
        ? FishTraceColors.primary.withValues(alpha: .14)
        : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .4),
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: enabled ? FishTraceColors.primary : FishTraceColors.disabled,
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: enabled ? null : FishTraceColors.disabled,
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/fishtrace_time.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/controllers/common_controller.dart';
import '../../../../core/data/repositories.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../controllers/transporter_controller.dart';

class TransporterDashboardScreen extends StatefulWidget {
  const TransporterDashboardScreen({super.key});

  @override
  State<TransporterDashboardScreen> createState() =>
      _TransporterDashboardScreenState();
}

class _TransporterDashboardScreenState
    extends State<TransporterDashboardScreen> {
  late final TransporterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TransporterController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final common = Get.find<CommonController>();
    final appSession = Get.find<AppController>();
    final userName = appSession.user.value?.name ?? 'Transporter';
    return FishTraceScaffold(
      safeAreaTop: false,
      systemUiOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      bottomNavigation: RoleBottomBar(
        role: UserRole.transporter,
        selectedIndex: 0,
        alertBadge: common.unreadCount,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingState(message: 'Loading transport dashboard…');
        }
        final trip =
            controller.trips.firstWhereOrNull(
              (item) => item.status == TripStatus.inProgress,
            ) ??
            controller.trips.firstWhereOrNull(
              (item) => item.status == TripStatus.upcoming,
            );
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 10, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FishTraceColors.primaryDark,
                      FishTraceColors.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const Text(
                              'Transporter',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(AppRoute.notifications),
                        icon: Badge(
                          isLabelVisible: common.unreadCount > 0,
                          label: Text('${common.unreadCount}'),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  children: [
                    if (trip != null)
                      FishTraceCard(
                        onTap: () {
                          controller.selectTrip(trip);
                          context.go('/transporter/trip-details');
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    trip.status == TripStatus.inProgress
                                        ? 'Active Trip'
                                        : 'Upcoming Trip',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                StatusChip(
                                  label: trip.status == TripStatus.inProgress
                                      ? 'In Progress'
                                      : 'Ready',
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                trip.label,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  trip.origin,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.arrow_forward, size: 16),
                                ),
                                Expanded(
                                  child: Text(
                                    trip.destination,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _TripMetric(
                                    label: 'ETA',
                                    value: FishTraceTime.format(
                                      trip.eta,
                                      'hh:mm a',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _TripMetric(
                                    label: 'Distance Left',
                                    value:
                                        '${trip.distanceKm.toStringAsFixed(1)} km',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SectionHeader(title: 'Live Status'),
                    FishTraceCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _SensorSummary(
                              label: 'Product Temp.',
                              value: trip?.productTemperature == null
                                  ? 'Not reported'
                                  : '${trip!.productTemperature!.toStringAsFixed(1)}°C',
                              icon: Icons.thermostat,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: FishTraceColors.divider,
                          ),
                          Expanded(
                            child: _SensorSummary(
                              label: 'Trip Status',
                              value: trip == null
                                  ? 'No active trip'
                                  : trip.status.name,
                              icon: Icons.local_shipping_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SectionHeader(
                      title: 'Alerts',
                      action: 'View all',
                      onAction: () => context.push(AppRoute.notifications),
                    ),
                    if (controller.alerts.isEmpty)
                      const EmptyState(
                        title: 'No active alerts',
                        message: 'No transport alerts have been reported.',
                        icon: Icons.verified_outlined,
                      )
                    else
                      for (final alert in controller.alerts.take(2)) ...[
                        AlertCard(
                          title: alert.type.replaceAll('_', ' '),
                          message: alert.measuredValue == null
                              ? 'Transport condition requires attention.'
                              : 'Measured value: ${alert.measuredValue!.toStringAsFixed(1)}',
                          severity: switch (alert.severity) {
                            AlertSeverity.critical =>
                              AlertCardSeverity.critical,
                            AlertSeverity.warning => AlertCardSeverity.warning,
                            _ => AlertCardSeverity.info,
                          },
                          trailing: StatusChip(label: alert.status),
                          onTap: () => context.go('/transporter/monitoring'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    const SectionHeader(title: 'Quick Actions'),
                    Row(
                      children: [
                        _Action(
                          label: trip?.status == TripStatus.upcoming
                              ? 'Start Trip'
                              : 'No Trip Ready',
                          icon: Icons.navigation_outlined,
                          onTap: trip?.status == TripStatus.upcoming
                              ? () => context.go('/transporter/checklist')
                              : null,
                        ),
                        const SizedBox(width: 7),
                        _Action(
                          label: trip?.status == TripStatus.upcoming
                              ? 'Add Batch'
                              : 'Trip Not Editable',
                          icon: Icons.qr_code_scanner,
                          onTap: trip?.status == TripStatus.upcoming
                              ? () => context.go('/transporter/add-batch')
                              : null,
                        ),
                        const SizedBox(width: 7),
                        _Action(
                          label: trip?.status == TripStatus.inProgress
                              ? 'Live Tracking'
                              : 'Tracking Inactive',
                          icon: Icons.sensors,
                          onTap: trip?.status == TripStatus.inProgress
                              ? () => context.go('/transporter/monitoring')
                              : null,
                        ),
                        const SizedBox(width: 7),
                        _Action(
                          label: 'Checklist',
                          icon: Icons.checklist,
                          onTap: trip?.status == TripStatus.upcoming
                              ? () => context.go('/transporter/checklist')
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TripMetric extends StatelessWidget {
  const _TripMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class _SensorSummary extends StatelessWidget {
  const _SensorSummary({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: FishTraceColors.info, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: FishTraceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      child: Column(
        children: [
          Icon(
            icon,
            color: onTap == null
                ? FishTraceColors.disabled
                : FishTraceColors.primary,
            size: 20,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: onTap == null ? FishTraceColors.disabled : null,
            ),
          ),
        ],
      ),
    ),
  );
}

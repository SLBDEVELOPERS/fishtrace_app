import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../../core/data/repositories.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../../common/presentation/formatters/currency_formatter.dart';
import '../controllers/retailer_controller.dart';

class RetailerDashboardScreen extends StatelessWidget {
  const RetailerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RetailerController>();
    final appSession = Get.find<AppController>();
    final userName = appSession.user.value?.name ?? 'Retailer';
    return FishTraceScaffold(
      bottomNavigation: RoleBottomBar(
        role: UserRole.retailer,
        selectedIndex: 0,
        alertBadge: controller.alerts.length,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const LoadingState(message: 'Loading retailer dashboard…');
        }
        final lowStock = controller.inventory
            .where((product) => product.lowStock)
            .length;
        return ListView(
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
                          Text(
                            appSession.user.value?.organization?.name ??
                                'Retail operations',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/retailer/alerts'),
                      icon: Badge(
                        isLabelVisible: controller.alerts.isNotEmpty,
                        label: Text('${controller.alerts.length}'),
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
                  SectionHeader(
                    title: 'Today’s Overview',
                    action: 'See all',
                    onAction: () => context.go('/retailer/reports'),
                  ),
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            label: 'Total Stock',
                            value:
                                '${controller.totalStock.toStringAsFixed(1)} kg',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricCard(
                            label: 'Total Batches',
                            value: '${controller.inventory.length}',
                            icon: Icons.layers_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricCard(
                            label: 'Low Stock',
                            value: '$lowStock',
                            icon: Icons.warning_amber,
                            color: FishTraceColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Loaded Activity'),
                  FishTraceCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActivityMetric(
                            icon: Icons.move_to_inbox_outlined,
                            label: 'Incoming',
                            value: '${controller.received.length} batches',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 46,
                          color: FishTraceColors.divider,
                        ),
                        Expanded(
                          child: _ActivityMetric(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Sold units',
                            value: controller.sales
                                .fold<double>(
                                  0,
                                  (total, sale) => total + sale.quantityKg,
                                )
                                .toStringAsFixed(0),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 46,
                          color: FishTraceColors.divider,
                        ),
                        Expanded(
                          child: _ActivityMetric(
                            icon: Icons.payments_outlined,
                            label: 'Sales',
                            value: CurrencyFormatter.lkr(
                              controller.totalSales,
                              showCents: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SectionHeader(
                    title: 'Recent Alerts',
                    action: 'See all',
                    onAction: () => context.go('/retailer/alerts'),
                  ),
                  for (final alert in controller.alerts.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AlertCard(
                        title: alert.title,
                        message: alert.message,
                        severity: alert.severity == AlertSeverity.critical
                            ? AlertCardSeverity.critical
                            : AlertCardSeverity.warning,
                        trailing: Text(
                          alert.timeLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => context.go('/retailer/alerts'),
                      ),
                    ),
                  const SectionHeader(title: 'Quick Actions'),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.qr_code_scanner,
                        label: 'Receive Batch',
                        onTap: () => context.go('/retailer/receive'),
                      ),
                      const SizedBox(width: 7),
                      _QuickAction(
                        icon: Icons.inventory_2_outlined,
                        label: 'Inventory',
                        onTap: () => context.go('/retailer/inventory'),
                      ),
                      const SizedBox(width: 7),
                      _QuickAction(
                        icon: Icons.point_of_sale_outlined,
                        label: 'Sales Update',
                        onTap: () => context.go('/retailer/sales'),
                      ),
                      const SizedBox(width: 7),
                      _QuickAction(
                        icon: Icons.bar_chart,
                        label: 'Reports',
                        onTap: () => context.go('/retailer/reports'),
                      ),
                    ],
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

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: FishTraceColors.primary, size: 20),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      FittedBox(
        child: Text(value, style: Theme.of(context).textTheme.labelMedium),
      ),
    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
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

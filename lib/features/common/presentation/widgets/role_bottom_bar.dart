import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';

class RoleBottomBar extends StatelessWidget {
  const RoleBottomBar({
    super.key,
    required this.role,
    this.selectedIndex = 0,
    this.alertBadge = 0,
  });

  final UserRole role;
  final int selectedIndex;
  final int alertBadge;

  @override
  Widget build(BuildContext context) {
    final config = _config(role, alertBadge);
    return FishTraceBottomNavigation(
      items: config.items,
      selectedIndex: selectedIndex,
      primaryActionLabel: config.primaryActionLabel,
      onPrimaryAction: () => context.go(config.primaryActionRoute),
      onSelected: (index) {
        final route = config.routes[index];
        if (route == AppRoute.profile) {
          context.push(route);
        } else {
          context.go(route);
        }
      },
    );
  }
}

typedef _RoleNavigationConfig = ({
  List<FishTraceNavigationItem> items,
  List<String> routes,
  String primaryActionLabel,
  String primaryActionRoute,
});

_RoleNavigationConfig _config(UserRole role, int alertBadge) {
  final root = '/${role.name}';
  return switch (role) {
    UserRole.fisher => (
      items: const [
        FishTraceNavigationItem(label: 'Home', icon: Icons.home_outlined),
        FishTraceNavigationItem(label: 'Trips', icon: Icons.route_outlined),
        FishTraceNavigationItem(label: 'Batches', icon: Icons.layers_outlined),
        FishTraceNavigationItem(label: 'More', icon: Icons.more_horiz),
      ],
      routes: [root, '$root/active-trip', '$root/batch-list', AppRoute.profile],
      primaryActionLabel: 'Add catch',
      primaryActionRoute: '$root/add-catch',
    ),
    UserRole.processor => (
      items: const [
        FishTraceNavigationItem(label: 'Dashboard', icon: Icons.home_outlined),
        FishTraceNavigationItem(
          label: 'Intake',
          icon: Icons.inventory_2_outlined,
        ),
        FishTraceNavigationItem(label: 'History', icon: Icons.history),
        FishTraceNavigationItem(label: 'More', icon: Icons.more_horiz),
      ],
      routes: [root, '$root/intake', '$root/history', AppRoute.profile],
      primaryActionLabel: 'Scan batch',
      primaryActionRoute: '$root/scan-batch',
    ),
    UserRole.transporter => (
      items: [
        const FishTraceNavigationItem(label: 'Home', icon: Icons.home_outlined),
        const FishTraceNavigationItem(label: 'Trips', icon: Icons.route),
        FishTraceNavigationItem(
          label: 'Alerts',
          icon: Icons.notifications_outlined,
          badge: alertBadge,
        ),
        const FishTraceNavigationItem(label: 'More', icon: Icons.more_horiz),
      ],
      routes: [root, '$root/trips', AppRoute.notifications, AppRoute.profile],
      primaryActionLabel: 'Accept batch',
      primaryActionRoute: '$root/add-batch',
    ),
    UserRole.retailer => (
      items: [
        const FishTraceNavigationItem(label: 'Home', icon: Icons.home_outlined),
        const FishTraceNavigationItem(
          label: 'Inventory',
          icon: Icons.inventory_2_outlined,
        ),
        FishTraceNavigationItem(
          label: 'Alerts',
          icon: Icons.notifications_outlined,
          badge: alertBadge,
        ),
        const FishTraceNavigationItem(label: 'More', icon: Icons.more_horiz),
      ],
      routes: [root, '$root/inventory', '$root/alerts', AppRoute.profile],
      primaryActionLabel: 'Receive batch',
      primaryActionRoute: '$root/receive',
    ),
  };
}

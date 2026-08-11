import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../../common/presentation/widgets/role_bottom_bar.dart';
import '../../domain/entities/retailer_entities.dart';
import '../controllers/retailer_controller.dart';

class RetailAlertsScreen extends StatelessWidget {
  const RetailAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RetailerController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Alerts'),
      bottomNavigation: RoleBottomBar(
        role: UserRole.retailer,
        selectedIndex: 2,
        alertBadge: controller.alerts.length,
      ),
      body: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  for (final filter in RetailAlertFilter.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(
                              _label(filter),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          selected: controller.alertFilter.value == filter,
                          onSelected: (_) =>
                              controller.alertFilter.value = filter,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: controller.filteredAlerts.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'No alerts',
                      message: 'There are no alerts in this category.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: controller.filteredAlerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final alert = controller.filteredAlerts[index];
                        return FishTraceCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _color(alert).withValues(alpha: .12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _icon(alert.type),
                                  color: _color(alert),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            alert.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                        ),
                                        StatusChip(
                                          label: _severity(alert.severity),
                                          color:
                                              alert.severity ==
                                                  AlertSeverity.critical
                                              ? FishTraceColors.error
                                              : alert.severity ==
                                                    AlertSeverity.warning
                                              ? FishTraceColors.warning
                                              : FishTraceColors.info,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(alert.message),
                                    const SizedBox(height: 5),
                                    Text(
                                      alert.timeLabel,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _statusLabel(alert.status),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    if (alert.type == AlertType.recall &&
                                        alert.batchId != null &&
                                        alert.status != 'RESOLVED') ...[
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 36,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _quarantine(
                                            context,
                                            controller,
                                            alert.batchId!,
                                            alert.id,
                                          ),
                                          icon: const Icon(
                                            Icons.block,
                                            size: 17,
                                          ),
                                          label: const Text(
                                            'Quarantine recalled batch',
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (alert.status != 'RESOLVED') ...[
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 36,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _resolve(
                                            context,
                                            controller,
                                            alert,
                                          ),
                                          icon: const Icon(
                                            Icons.task_alt_outlined,
                                            size: 17,
                                          ),
                                          label: const Text('Resolve alert'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(RetailAlertFilter filter) => switch (filter) {
    RetailAlertFilter.all => 'All',
    RetailAlertFilter.critical => 'Critical',
    RetailAlertFilter.info => 'Info',
  };
  String _severity(AlertSeverity severity) => switch (severity) {
    AlertSeverity.critical => 'High Risk',
    AlertSeverity.warning => 'Action',
    AlertSeverity.info => 'Info',
  };
  String _statusLabel(String status) => status
      .toLowerCase()
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
  Color _color(RetailAlertView alert) => switch (alert.severity) {
    AlertSeverity.critical => FishTraceColors.error,
    AlertSeverity.warning => FishTraceColors.warning,
    AlertSeverity.info => FishTraceColors.info,
  };
  IconData _icon(AlertType type) => switch (type) {
    AlertType.recall => Icons.warning_amber,
    AlertType.expiry => Icons.access_time,
    AlertType.stock => Icons.inventory_2_outlined,
    AlertType.temperature => Icons.thermostat,
    AlertType.battery => Icons.battery_alert_outlined,
    AlertType.sensorOffline => Icons.sensors_off_outlined,
    AlertType.doorOpened => Icons.door_sliding_outlined,
    AlertType.system => Icons.settings_outlined,
  };

  Future<void> _quarantine(
    BuildContext context,
    RetailerController controller,
    String batchId,
    String alertId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quarantine batch?'),
        content: Text(
          '$batchId will be blocked from sale and queued for sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quarantine'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.quarantine(batchId, alertId: alertId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch quarantined and queued for sync.')),
      );
    }
  }

  Future<void> _resolve(
    BuildContext context,
    RetailerController controller,
    RetailAlertView alert,
  ) async {
    final note = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resolve alert'),
        content: TextField(
          controller: note,
          minLines: 2,
          maxLines: 4,
          maxLength: 1000,
          decoration: const InputDecoration(
            labelText: 'Resolution note',
            helperText: 'At least 5 characters',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (note.text.trim().length < 5) return;
              await controller.resolveAlert(alert, note: note.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    note.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/data/repositories.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';

class OfflineSyncScreen extends StatelessWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    return FishTraceScaffold(
      appBar: const FishTraceAppBar(title: 'Offline Sync Status'),
      body: Obx(() {
        final items = controller.syncItems;
        final failed = items
            .where((item) => item.status == SyncStatus.failed)
            .length;

        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            _ConnectionHero(
              offline: controller.offline.value,
              pending: items.length,
            ),
            const SizedBox(height: FishTraceSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _SyncMetric(
                    label: 'Pending',
                    value: '${items.length}',
                    icon: Icons.schedule,
                    color: FishTraceColors.warning,
                  ),
                ),
                const SizedBox(width: FishTraceSpacing.xs),
                Expanded(
                  child: _SyncMetric(
                    label: 'Failed',
                    value: '$failed',
                    icon: Icons.sync_problem,
                    color: FishTraceColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FishTraceSpacing.sm),
            FishTraceCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_done_outlined,
                    color: FishTraceColors.primary,
                  ),
                  const SizedBox(width: FishTraceSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last successful sync',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          controller.lastSuccessfulSync.value == null
                              ? 'No completed sync in this session'
                              : DateFormat(
                                  'MMM d, yyyy · hh:mm a',
                                ).format(controller.lastSuccessfulSync.value!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(
              title: 'Record sync details',
              action: items.isEmpty ? null : '${items.length} records',
            ),
            if (items.isNotEmpty && failed == items.length)
              SizedBox(
                height: 190,
                child: ErrorState(
                  title: 'Records could not synchronize',
                  message:
                      'The server rejected every pending record. Review the '
                      'connection and retry.',
                  onRetry: controller.retryFailed,
                ),
              )
            else if (items.isEmpty)
              const SizedBox(
                height: 205,
                child: EmptyState(
                  title: 'Everything is synchronized',
                  message: 'New offline work will appear here until uploaded.',
                  icon: Icons.cloud_done_outlined,
                ),
              )
            else
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QueueTile(item: item, controller: controller),
                ),
            const SizedBox(height: FishTraceSpacing.md),
            FishTracePrimaryButton(
              label: controller.syncing.value ? 'Syncing…' : 'Sync Now',
              icon: Icons.sync,
              loading: controller.syncing.value,
              onPressed: controller.offline.value || items.isEmpty
                  ? null
                  : controller.syncNow,
            ),
            if (failed > 0) ...[
              const SizedBox(height: FishTraceSpacing.xs),
              RetryPanel(
                message: '$failed record${failed == 1 ? '' : 's'} failed.',
                onRetry: controller.offline.value
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reconnect before retrying.'),
                        ),
                      )
                    : controller.retryFailed,
              ),
            ],
            const SizedBox(height: FishTraceSpacing.xs),
            TextButton.icon(
              onPressed: () => controller.setOffline(!controller.offline.value),
              icon: Icon(
                controller.offline.value ? Icons.wifi : Icons.cloud_off,
              ),
              label: Text(
                controller.offline.value ? 'Return Online' : 'Work Offline',
              ),
            ),
            const SizedBox(height: FishTraceSpacing.sm),
            Text(
              'Changes are saved securely on this device. FishTrace uploads them with their original timestamps and idempotency keys when a connection is available.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }),
    );
  }
}

class _ConnectionHero extends StatelessWidget {
  const _ConnectionHero({required this.offline, required this.pending});

  final bool offline;
  final int pending;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(FishTraceSpacing.xl),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [FishTraceColors.primaryDark, FishTraceColors.ocean],
      ),
      borderRadius: BorderRadius.circular(FishTraceRadii.panel),
    ),
    child: Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
            size: 38,
            color: FishTraceColors.primary,
          ),
        ),
        const SizedBox(height: FishTraceSpacing.md),
        Text(
          offline ? 'You’re Offline' : 'You’re Online',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          offline
              ? 'No internet connection. FishTrace is working in offline mode.'
              : pending == 0
              ? 'All local changes are synchronized.'
              : '$pending local changes are ready to synchronize.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: .78),
          ),
        ),
      ],
    ),
  );
}

class _SyncMetric extends StatelessWidget {
  const _SyncMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    child: Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: FishTraceSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    ),
  );
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.item, required this.controller});

  final SyncQueueItem item;
  final AppController controller;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    child: Row(
      children: [
        const Icon(Icons.description_outlined, color: FishTraceColors.primary),
        const SizedBox(width: FishTraceSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: Theme.of(context).textTheme.titleSmall),
              Text(
                DateFormat('MMM d · hh:mm a').format(item.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (item.lastError != null)
                Text(
                  item.lastError!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FishTraceColors.error,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SyncStatusChip(
              state: switch (item.status) {
                SyncStatus.pending => SyncVisualState.pending,
                SyncStatus.syncing => SyncVisualState.syncing,
                SyncStatus.synced => SyncVisualState.synced,
                SyncStatus.failed => SyncVisualState.failed,
              },
            ),
            if (item.status == SyncStatus.failed)
              IconButton(
                tooltip: 'Discard failed record',
                icon: const Icon(Icons.delete_outline),
                color: FishTraceColors.error,
                onPressed: () => _confirmDiscard(context),
              ),
          ],
        ),
      ],
    ),
  );

  Future<void> _confirmDiscard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard failed record?'),
        content: Text(
          '${item.label} was rejected by the server. Discarding removes only '
          'this pending sync attempt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.discardFailed(item.id);
  }
}

import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';
import '../buttons/fishtrace_buttons.dart';
import '../cards/fishtrace_cards.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'Loading…'});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      label: message,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.5),
          const SizedBox(height: FishTraceSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(FishTraceSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: FishTraceColors.oceanLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: FishTraceColors.primary),
          ),
          const SizedBox(height: FishTraceSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: FishTraceSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: FishTraceSpacing.lg),
            FishTracePrimaryButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    title: title,
    message: message,
    icon: Icons.error_outline,
    actionLabel: 'Try again',
    onAction: onRetry,
  );
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.pendingCount, this.onTap});

  final int pendingCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: FishTraceColors.warningSurface,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FishTraceSpacing.md,
          vertical: FishTraceSpacing.xs,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 17,
              color: FishTraceColors.warning,
            ),
            const SizedBox(width: FishTraceSpacing.xs),
            Expanded(
              child: Text(
                pendingCount == 0
                    ? 'Working offline'
                    : 'Working offline · $pendingCount changes pending',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    ),
  );
}

enum SyncVisualState { pending, syncing, synced, failed }

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key, required this.state});

  final SyncVisualState state;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (state) {
      SyncVisualState.pending => (
        'Pending',
        FishTraceColors.warning,
        Icons.schedule,
      ),
      SyncVisualState.syncing => ('Syncing', FishTraceColors.info, Icons.sync),
      SyncVisualState.synced => (
        'Synced',
        FishTraceColors.success,
        Icons.cloud_done_outlined,
      ),
      SyncVisualState.failed => (
        'Failed',
        FishTraceColors.error,
        Icons.sync_problem,
      ),
    };
    return StatusChip(label: label, color: color, icon: icon);
  }
}

class RetryPanel extends StatelessWidget {
  const RetryPanel({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FishTraceCard(
    color: FishTraceColors.errorSurface,
    borderColor: FishTraceColors.error.withValues(alpha: .25),
    child: Row(
      children: [
        const Icon(Icons.sync_problem, color: FishTraceColors.error),
        const SizedBox(width: FishTraceSpacing.sm),
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

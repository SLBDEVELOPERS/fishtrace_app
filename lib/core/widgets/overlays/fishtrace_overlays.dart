import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';
import '../buttons/fishtrace_buttons.dart';

enum FishTraceFeedbackTone { success, info, warning, error }

/// Transient feedback for completed actions and recoverable conditions.
///
/// Field validation remains inline, while blocking or destructive decisions use
/// dialogs/bottom sheets. Calling this API replaces any currently visible
/// feedback so operational messages never stack over one another.
abstract final class FishTraceFeedback {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    tone: FishTraceFeedbackTone.success,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    tone: FishTraceFeedbackTone.info,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    tone: FishTraceFeedbackTone.warning,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    tone: FishTraceFeedbackTone.error,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    BuildContext context,
    String message, {
    FishTraceFeedbackTone tone = FishTraceFeedbackTone.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return null;
    return showForMessenger(
      messenger,
      message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  showForMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    FishTraceFeedbackTone tone = FishTraceFeedbackTone.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'actionLabel and onAction must be supplied together.',
    );
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        content: _FeedbackContent(message: message, tone: tone),
        backgroundColor: _background(tone),
        behavior: SnackBarBehavior.floating,
        duration: _duration(tone),
        dismissDirection: DismissDirection.down,
        showCloseIcon: actionLabel == null,
        closeIconColor: Colors.white.withValues(alpha: .82),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction!,
              ),
      ),
    );
  }

  static Color _background(FishTraceFeedbackTone tone) => switch (tone) {
    FishTraceFeedbackTone.success => const Color(0xFF0B6247),
    FishTraceFeedbackTone.info => FishTraceColors.navy,
    FishTraceFeedbackTone.warning => const Color(0xFF704100),
    FishTraceFeedbackTone.error => const Color(0xFF982C36),
  };

  static Duration _duration(FishTraceFeedbackTone tone) => switch (tone) {
    FishTraceFeedbackTone.success => const Duration(seconds: 3),
    FishTraceFeedbackTone.info => const Duration(seconds: 4),
    FishTraceFeedbackTone.warning => const Duration(seconds: 5),
    FishTraceFeedbackTone.error => const Duration(seconds: 6),
  };
}

class _FeedbackContent extends StatelessWidget {
  const _FeedbackContent({required this.message, required this.tone});

  final String message;
  final FishTraceFeedbackTone tone;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (tone) {
      FishTraceFeedbackTone.success => ('Success', Icons.check_circle_outline),
      FishTraceFeedbackTone.info => ('Information', Icons.info_outline),
      FishTraceFeedbackTone.warning => ('Warning', Icons.warning_amber_rounded),
      FishTraceFeedbackTone.error => ('Error', Icons.error_outline),
    };
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$label: $message',
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: FishTraceSpacing.sm),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onApply,
    this.onReset,
    this.applyLabel = 'Apply Filters',
  });

  final String title;
  final Widget child;
  final VoidCallback onApply;
  final VoidCallback? onReset;
  final String applyLabel;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    required T Function() result,
    VoidCallback? onReset,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => FilterBottomSheet(
      title: title,
      onReset: onReset,
      onApply: () => Navigator.pop(sheetContext, result()),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        FishTraceSpacing.md,
        0,
        FishTraceSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + FishTraceSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (onReset != null)
                TextButton(onPressed: onReset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: FishTraceSpacing.sm),
          child,
          const SizedBox(height: FishTraceSpacing.md),
          FishTracePrimaryButton(label: applyLabel, onPressed: onApply),
        ],
      ),
    ),
  );
}

class ConfirmationBottomSheet extends StatelessWidget {
  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.icon = Icons.help_outline,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final IconData icon;
  final bool destructive;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    IconData icon = Icons.help_outline,
    bool destructive = false,
  }) async =>
      await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => ConfirmationBottomSheet(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          icon: icon,
          destructive: destructive,
          onConfirm: () => Navigator.pop(sheetContext, true),
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  (destructive
                          ? FishTraceColors.error
                          : FishTraceColors.primary)
                      .withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: destructive
                  ? FishTraceColors.error
                  : FishTraceColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (destructive)
            FishTraceDestructiveButton(
              label: confirmLabel,
              onPressed: onConfirm,
            )
          else
            FishTracePrimaryButton(label: confirmLabel, onPressed: onConfirm),
          const SizedBox(height: 8),
          FishTraceSecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    ),
  );
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel = 'Done',
  });

  final String title;
  final String message;
  final String actionLabel;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'Done',
  }) => showDialog<void>(
    context: context,
    builder: (_) =>
        SuccessDialog(title: title, message: message, actionLabel: actionLabel),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const CircleAvatar(
      radius: 27,
      backgroundColor: FishTraceColors.successSurface,
      child: Icon(
        Icons.check_rounded,
        color: FishTraceColors.success,
        size: 30,
      ),
    ),
    title: Text(title, textAlign: TextAlign.center),
    content: Text(message, textAlign: TextAlign.center),
    actions: [
      FishTracePrimaryButton(
        label: actionLabel,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({
    super.key,
    required this.permissionName,
    required this.message,
    required this.onOpenSettings,
    this.permanentlyDenied = false,
  });

  final String permissionName;
  final String message;
  final VoidCallback onOpenSettings;
  final bool permanentlyDenied;

  static Future<bool> show({
    required BuildContext context,
    required String permissionName,
    required String message,
    bool permanentlyDenied = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => PermissionDialog(
          permissionName: permissionName,
          message: message,
          permanentlyDenied: permanentlyDenied,
          onOpenSettings: () => Navigator.pop(dialogContext, true),
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(
      Icons.admin_panel_settings_outlined,
      color: FishTraceColors.primary,
      size: 38,
    ),
    title: Text('$permissionName permission'),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Not Now'),
      ),
      FilledButton(
        onPressed: onOpenSettings,
        child: Text(permanentlyDenied ? 'Open Settings' : 'Continue'),
      ),
    ],
  );
}

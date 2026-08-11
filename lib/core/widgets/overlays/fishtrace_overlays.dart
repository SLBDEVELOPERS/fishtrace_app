import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';
import '../buttons/fishtrace_buttons.dart';

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

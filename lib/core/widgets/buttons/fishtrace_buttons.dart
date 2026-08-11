import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';

class FishTracePrimaryButton extends StatelessWidget {
  const FishTracePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: FishTraceSizes.button,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: FishTraceSizes.compactIcon),
                  const SizedBox(width: FishTraceSpacing.xs),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label, maxLines: 1),
                  ),
                ),
              ],
            ),
    ),
  );
}

class FishTraceSecondaryButton extends StatelessWidget {
  const FishTraceSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: FishTraceSizes.button,
    child: OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: FishTraceSizes.compactIcon),
            const SizedBox(width: FishTraceSpacing.xs),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, maxLines: 1),
            ),
          ),
        ],
      ),
    ),
  );
}

class FishTraceDestructiveButton extends StatelessWidget {
  const FishTraceDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: FishTraceSizes.button,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: FishTraceColors.error,
        side: const BorderSide(color: FishTraceColors.error),
      ),
      icon: Icon(icon ?? Icons.delete_outline, size: 18),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
    ),
  );
}

/// Compatibility wrapper used while legacy feature screens are migrated.
class FishTraceButton extends StatelessWidget {
  const FishTraceButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => secondary
      ? FishTraceSecondaryButton(label: label, onPressed: onPressed, icon: icon)
      : FishTracePrimaryButton(label: label, onPressed: onPressed, icon: icon);
}

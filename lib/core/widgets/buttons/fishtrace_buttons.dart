import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';

class FishTracePrimaryButton extends StatefulWidget {
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
  State<FishTracePrimaryButton> createState() => _FishTracePrimaryButtonState();
}

class _FishTracePrimaryButtonState extends State<FishTracePrimaryButton> {
  bool _running = false;

  Future<void> _handlePressed() async {
    if (_running || widget.onPressed == null) return;
    final callback = widget.onPressed as dynamic;
    final result = callback();
    if (result is! Future) return;
    setState(() => _running = true);
    try {
      await result;
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = widget.loading || _running;
    return SizedBox(
      width: double.infinity,
      height: FishTraceSizes.button,
      child: FilledButton(
        onPressed: loading || widget.onPressed == null ? null : _handlePressed,
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
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: FishTraceSizes.compactIcon),
                    const SizedBox(width: FishTraceSpacing.xs),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(widget.label, maxLines: 1),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FishTraceSecondaryButton extends StatefulWidget {
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
  State<FishTraceSecondaryButton> createState() =>
      _FishTraceSecondaryButtonState();
}

class _FishTraceSecondaryButtonState extends State<FishTraceSecondaryButton> {
  bool _running = false;

  Future<void> _handlePressed() async {
    if (_running || widget.onPressed == null) return;
    final callback = widget.onPressed as dynamic;
    final result = callback();
    if (result is! Future) return;
    setState(() => _running = true);
    try {
      await result;
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: FishTraceSizes.button,
    child: OutlinedButton(
      onPressed: _running || widget.onPressed == null ? null : _handlePressed,
      child: _running
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: FishTraceSizes.compactIcon),
                  const SizedBox(width: FishTraceSpacing.xs),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(widget.label, maxLines: 1),
                  ),
                ),
              ],
            ),
    ),
  );
}

class FishTraceDestructiveButton extends StatefulWidget {
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
  State<FishTraceDestructiveButton> createState() =>
      _FishTraceDestructiveButtonState();
}

class _FishTraceDestructiveButtonState
    extends State<FishTraceDestructiveButton> {
  bool _running = false;

  Future<void> _handlePressed() async {
    if (_running || widget.onPressed == null) return;
    final callback = widget.onPressed as dynamic;
    final result = callback();
    if (result is! Future) return;
    setState(() => _running = true);
    try {
      await result;
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: FishTraceSizes.button,
    child: OutlinedButton.icon(
      onPressed: _running || widget.onPressed == null ? null : _handlePressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: FishTraceColors.error,
        side: const BorderSide(color: FishTraceColors.error),
      ),
      icon: _running
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon ?? Icons.delete_outline, size: 18),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(_running ? 'Please wait...' : widget.label, maxLines: 1),
      ),
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

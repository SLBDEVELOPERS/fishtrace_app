import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';

class FishTraceCard extends StatelessWidget {
  const FishTraceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FishTraceSpacing.sm),
    this.onTap,
    this.color,
    this.borderColor,
    this.elevation = .5,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double elevation;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final effectiveBorder =
        borderColor ??
        theme.colorScheme.outlineVariant.withValues(alpha: dark ? .72 : .58);
    return Material(
      color: color ?? theme.colorScheme.surface,
      elevation: dark ? 0 : elevation,
      shadowColor: FishTraceColors.navy.withValues(alpha: .10),
      shape: RoundedRectangleBorder(
        side: showBorder ? BorderSide(color: effectiveBorder) : BorderSide.none,
        borderRadius: BorderRadius.circular(FishTraceRadii.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = FishTraceColors.primary,
    this.delta,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    if (largeText) {
      return FishTraceCard(
        padding: const EdgeInsets.all(FishTraceSpacing.xs),
        color: color.withValues(alpha: .055),
        borderColor: color.withValues(alpha: .14),
        elevation: 0,
        child: Row(
          children: [
            _MetricIcon(icon: icon, color: color),
            const SizedBox(width: FishTraceSpacing.xs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    delta == null ? label : '$label · $delta',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return FishTraceCard(
      padding: const EdgeInsets.all(FishTraceSpacing.xs),
      color: color.withValues(alpha: .055),
      borderColor: color.withValues(alpha: .14),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _MetricIcon(icon: icon, color: color),
              if (delta != null) ...[
                const Spacer(),
                Text(
                  delta!,
                  style: const TextStyle(
                    color: FishTraceColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(FishTraceRadii.control),
    ),
    child: Icon(icon, color: color, size: 16),
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color = FishTraceColors.success,
    this.icon,
    this.onDark = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final foreground = onDark
        ? Colors.white
        : switch (color) {
            FishTraceColors.success => FishTraceColors.successText,
            FishTraceColors.warning => FishTraceColors.warningText,
            FishTraceColors.error => FishTraceColors.errorText,
            FishTraceColors.info => FishTraceColors.infoText,
            _ => color,
          };
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: onDark ? .24 : .11),
          borderRadius: BorderRadius.circular(FishTraceRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: FishTraceSpacing.lg, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(44, 32),
            ),
            child: Text(action!),
          ),
      ],
    ),
  );
}

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.severity,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String message;
  final AlertCardSeverity severity;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (severity) {
      AlertCardSeverity.info => (FishTraceColors.info, Icons.info_outline),
      AlertCardSeverity.warning => (
        FishTraceColors.warning,
        Icons.warning_amber_rounded,
      ),
      AlertCardSeverity.critical => (
        FishTraceColors.error,
        Icons.report_gmailerrorred,
      ),
    };
    return FishTraceCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: FishTraceSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

enum AlertCardSeverity { info, warning, critical }

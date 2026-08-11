import 'package:flutter/material.dart';

import '../../app/theme/fishtrace_colors.dart';
import '../../app/theme/fishtrace_dimensions.dart';
import '../../app/theme/fishtrace_theme.dart';

/// Compatibility facade while legacy screens are migrated feature by feature.
/// New code imports the semantic files under `app/theme` directly.
abstract final class FishTraceTokens {
  static const primary = FishTraceColors.primary;
  static const primaryDark = FishTraceColors.navy;
  static const oceanDeep = FishTraceColors.ocean;
  static const accent = FishTraceColors.cyan;
  static const aqua = FishTraceColors.aqua;
  static const page = FishTraceColors.page;
  static const mapSurface = FishTraceColors.oceanLight;
  static const text = FishTraceColors.textPrimary;
  static const muted = FishTraceColors.textSecondary;
  static const border = FishTraceColors.border;
  static const success = FishTraceColors.success;
  static const warning = FishTraceColors.warning;
  static const error = FishTraceColors.error;
  static const info = FishTraceColors.info;
  static const rSmall = FishTraceRadii.input;
  static const rCard = FishTraceRadii.card;
  static const s4 = FishTraceSpacing.xxs;
  static const s8 = FishTraceSpacing.xs;
  static const s12 = FishTraceSpacing.sm;
  static const s16 = FishTraceSpacing.md;
  static const s20 = FishTraceSpacing.lg;
  static const s24 = FishTraceSpacing.xl;
  static const s32 = FishTraceSpacing.xxl;
}

ThemeData fishTraceTheme() => buildFishTraceTheme();

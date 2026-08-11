import 'package:flutter/material.dart';

import 'fishtrace_colors.dart';
import 'fishtrace_dimensions.dart';

ThemeData buildFishTraceTheme() {
  const textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 29,
      height: 1.12,
      fontWeight: FontWeight.w800,
      color: FishTraceColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 23,
      height: 1.18,
      fontWeight: FontWeight.w800,
      color: FishTraceColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: FishTraceColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: FishTraceColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: FishTraceColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: FishTraceColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: FishTraceColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.35,
      color: FishTraceColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
  );

  final colorScheme = ColorScheme.fromSeed(
    seedColor: FishTraceColors.primary,
    brightness: Brightness.light,
    primary: FishTraceColors.primary,
    secondary: FishTraceColors.cyan,
    surface: FishTraceColors.surface,
    error: FishTraceColors.error,
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(FishTraceRadii.input),
    borderSide: const BorderSide(color: FishTraceColors.border),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: FishTraceColors.page,
    fontFamily: 'Roboto',
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: FishTraceSizes.appBar,
      backgroundColor: FishTraceColors.surface,
      foregroundColor: FishTraceColors.textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: FishTraceColors.textPrimary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: FishTraceColors.divider,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: FishTraceColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: FishTraceColors.border),
        borderRadius: BorderRadius.circular(FishTraceRadii.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FishTraceColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FishTraceSpacing.sm,
        vertical: 13,
      ),
      labelStyle: const TextStyle(
        color: FishTraceColors.textSecondary,
        fontSize: 12,
      ),
      hintStyle: const TextStyle(
        color: FishTraceColors.textTertiary,
        fontSize: 13,
      ),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(
          color: FishTraceColors.primary,
          width: 1.4,
        ),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: FishTraceColors.error),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(FishTraceSizes.button),
        elevation: 0,
        backgroundColor: FishTraceColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FishTraceRadii.control),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(FishTraceSizes.button),
        foregroundColor: FishTraceColors.primary,
        side: const BorderSide(color: FishTraceColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FishTraceRadii.control),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FishTraceColors.primary,
        minimumSize: const Size(
          FishTraceSizes.touchTarget,
          FishTraceSizes.touchTarget,
        ),
        textStyle: textTheme.labelMedium,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: FishTraceColors.navy,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}

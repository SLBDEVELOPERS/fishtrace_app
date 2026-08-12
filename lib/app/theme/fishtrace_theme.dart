import 'package:flutter/material.dart';

import 'fishtrace_colors.dart';
import 'fishtrace_dimensions.dart';

ThemeData buildFishTraceTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final textPrimary = dark
      ? const Color(0xFFEAF4F6)
      : FishTraceColors.textPrimary;
  final textSecondary = dark
      ? const Color(0xFFAEC2C8)
      : FishTraceColors.textSecondary;
  final surface = dark ? const Color(0xFF102630) : FishTraceColors.surface;
  final page = dark ? const Color(0xFF071A22) : FishTraceColors.page;
  final border = dark ? const Color(0xFF29434D) : FishTraceColors.border;
  final divider = dark ? const Color(0xFF203943) : FishTraceColors.divider;
  final textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 29,
      height: 1.12,
      fontWeight: FontWeight.w800,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 23,
      height: 1.18,
      fontWeight: FontWeight.w800,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: textPrimary,
    ),
    bodySmall: TextStyle(fontSize: 12, height: 1.35, color: textSecondary),
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
    brightness: brightness,
    primary: FishTraceColors.primary,
    secondary: FishTraceColors.cyan,
    surface: surface,
    error: FishTraceColors.error,
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(FishTraceRadii.input),
    borderSide: BorderSide(color: border),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: page,
    fontFamily: 'Roboto',
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: FishTraceSizes.appBar,
      backgroundColor: surface,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border),
        borderRadius: BorderRadius.circular(FishTraceRadii.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FishTraceSpacing.sm,
        vertical: 13,
      ),
      labelStyle: TextStyle(color: textSecondary, fontSize: 12),
      hintStyle: TextStyle(
        color: dark ? const Color(0xFF78909A) : FishTraceColors.textTertiary,
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

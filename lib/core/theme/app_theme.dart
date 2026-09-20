import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the Material [ThemeData] for light and dark mode from the tokens.
/// Widgets should read colours from `context.colors` and text from
/// `context.text`; this class exists so stock Material widgets look right too.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light);
  static ThemeData dark() => _build(AppColors.dark);

  static ThemeData _build(AppColors c) {
    final brightness = c.isDark ? Brightness.dark : Brightness.light;
    final textTheme = AppTypography.textTheme(c.ink);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: c.brandInk,
      secondary: c.accent,
      onSecondary: c.onAccent,
      tertiary: c.rose,
      onTertiary: Colors.white,
      error: const Color(0xFFC94F4F),
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.ink,
      surfaceContainerHighest: c.surface2,
      onSurfaceVariant: c.ink2,
      outline: c.line,
      outlineVariant: c.line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.ground,
      canvasColor: c.ground,
      textTheme: textTheme,
      fontFamily: AppFonts.body,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: c.ink2, size: AppSizes.iconMd),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: c.ink,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: c.ink),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r(AppRadius.card),
          side: BorderSide(color: c.line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.brand,
        side: BorderSide(color: c.line),
        labelStyle: AppTypography.labelMedium.copyWith(color: c.ink2),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: c.brandInk),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        hintStyle: AppTypography.bodyMedium.copyWith(color: c.ink3),
        labelStyle: AppTypography.labelMedium.copyWith(color: c.ink3),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(color: c.brand),
        border: OutlineInputBorder(
          borderRadius: AppRadius.r(AppRadius.xl),
          borderSide: BorderSide(color: c.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r(AppRadius.xl),
          borderSide: BorderSide(color: c.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.r(AppRadius.xl),
          borderSide: BorderSide(color: c.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r(AppRadius.xl),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.brandInk,
          minimumSize: const Size.fromHeight(AppSizes.button),
          textStyle: AppTypography.labelLarge.copyWith(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.r(AppRadius.xl)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          backgroundColor: c.surface,
          minimumSize: const Size.fromHeight(AppSizes.button),
          side: BorderSide(color: c.line, width: 1.5),
          textStyle: AppTypography.labelLarge.copyWith(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.r(AppRadius.xl)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentInk,
          textStyle: AppTypography.labelMedium.copyWith(fontSize: 13),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(c.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent : c.line,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        inactiveTrackColor: c.line,
        thumbColor: c.surface,
        overlayColor: c.accent.withValues(alpha: .15),
        trackHeight: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: c.ground),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.r(AppRadius.md)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Raw brand palette. These are the only hard-coded hex values in the app —
/// change a colour here and every screen follows.
abstract final class AppPalette {
  // Brand
  static const Color teal = Color(0xFF1E5A70); // "Shyam" — headers, primary buttons
  static const Color tealDark = Color(0xFF1A4F63);
  static const Color tealInk = Color(0xFFEEF6F8); // text on teal
  static const Color marigold = Color(0xFFF2B134); // "Kesar" — accent, today, CTA
  static const Color marigoldInk = Color(0xFF8A5A0A);
  static const Color marigoldInkDark = Color(0xFFF5C766);
  static const Color marigoldSoft = Color(0xFFFFF1CF);
  static const Color marigoldSoftDark = Color(0xFF3D2E10);
  static const Color rose = Color(0xFFE4789A); // "Gulabi" — secondary tint, Agiyaras
  static const Color roseSoft = Color(0xFFFCE7EE);
  static const Color roseSoftDark = Color(0xFF3D2430);
  static const Color gold = Color(0xFFE2B33D); // favourites heart
  static const Color onMarigold = Color(0xFF2A1500); // text on marigold

  // Light neutrals
  static const Color groundLight = Color(0xFFF4F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFE8EFF2);
  static const Color inkLight = Color(0xFF1B2A33);
  static const Color ink2Light = Color(0xFF52646D);
  static const Color ink3Light = Color(0xFF85969E);
  static const Color lineLight = Color(0xFFDCE4E8);

  // Dark neutrals
  static const Color groundDark = Color(0xFF0F1A1F);
  static const Color surfaceDark = Color(0xFF182529);
  static const Color surface2Dark = Color(0xFF213036);
  static const Color inkDark = Color(0xFFEAF1F3);
  static const Color ink2Dark = Color(0xFFA9B9C0);
  static const Color ink3Dark = Color(0xFF74868E);
  static const Color lineDark = Color(0xFF2B3B42);

  // Lyrics reader (single-theme, immersive)
  static const Color readerTop = Color(0xFF1E5A70);
  static const Color readerMid = Color(0xFF16465A);
  static const Color readerBottom = Color(0xFF10323F);
  static const Color readerDim = Color(0xFF071A22); // "moon" dim mode
}

/// Semantic colour tokens, available via `context.colors`.
/// Light and dark variants are defined once; widgets never pick a raw hex.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ground,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.brand,
    required this.brandInk,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.rose,
    required this.roseSoft,
    required this.gold,
    required this.onAccent,
    required this.isDark,
  });

  /// Page background.
  final Color ground;

  /// Cards, sheets, nav bar.
  final Color surface;

  /// Tinted tiles, inactive segments.
  final Color surface2;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color ink2;

  /// Tertiary text, placeholders, icons at rest.
  final Color ink3;

  /// Hairlines and borders.
  final Color line;

  /// Teal — headers, primary buttons, raga tile text.
  final Color brand;

  /// Text on [brand].
  final Color brandInk;

  /// Marigold — accent, CTA, "today".
  final Color accent;

  /// Readable marigold for text/icons on light surfaces.
  final Color accentInk;

  /// Marigold tint for chips and icon tiles.
  final Color accentSoft;

  /// Rose — secondary tint, Agiyaras.
  final Color rose;
  final Color roseSoft;

  /// Favourite heart.
  final Color gold;

  /// Text on [accent].
  final Color onAccent;

  final bool isDark;

  static const AppColors light = AppColors(
    ground: AppPalette.groundLight,
    surface: AppPalette.surfaceLight,
    surface2: AppPalette.surface2Light,
    ink: AppPalette.inkLight,
    ink2: AppPalette.ink2Light,
    ink3: AppPalette.ink3Light,
    line: AppPalette.lineLight,
    brand: AppPalette.teal,
    brandInk: AppPalette.tealInk,
    accent: AppPalette.marigold,
    accentInk: AppPalette.marigoldInk,
    accentSoft: AppPalette.marigoldSoft,
    rose: AppPalette.rose,
    roseSoft: AppPalette.roseSoft,
    gold: AppPalette.gold,
    onAccent: AppPalette.onMarigold,
    isDark: false,
  );

  static const AppColors dark = AppColors(
    ground: AppPalette.groundDark,
    surface: AppPalette.surfaceDark,
    surface2: AppPalette.surface2Dark,
    ink: AppPalette.inkDark,
    ink2: AppPalette.ink2Dark,
    ink3: AppPalette.ink3Dark,
    line: AppPalette.lineDark,
    brand: AppPalette.tealDark,
    brandInk: AppPalette.tealInk,
    accent: AppPalette.marigold,
    accentInk: AppPalette.marigoldInkDark,
    accentSoft: AppPalette.marigoldSoftDark,
    rose: AppPalette.rose,
    roseSoft: AppPalette.roseSoftDark,
    gold: AppPalette.gold,
    onAccent: AppPalette.onMarigold,
    isDark: true,
  );

  /// Raga tile / brand-coloured text that must stay legible in dark mode.
  Color get brandText => isDark ? ink : brand;

  @override
  AppColors copyWith({
    Color? ground,
    Color? surface,
    Color? surface2,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? brand,
    Color? brandInk,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? rose,
    Color? roseSoft,
    Color? gold,
    Color? onAccent,
    bool? isDark,
  }) {
    return AppColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      brand: brand ?? this.brand,
      brandInk: brandInk ?? this.brandInk,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      rose: rose ?? this.rose,
      roseSoft: roseSoft ?? this.roseSoft,
      gold: gold ?? this.gold,
      onAccent: onAccent ?? this.onAccent,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      line: Color.lerp(line, other.line, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandInk: Color.lerp(brandInk, other.brandInk, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      roseSoft: Color.lerp(roseSoft, other.roseSoft, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

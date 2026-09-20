import 'package:flutter/material.dart';

/// Font families bundled under `assets/fonts` (declared in pubspec.yaml) —
/// the same three as the design mockups.
///
/// * Yatra One    — display (screen titles, greeting, big numbers)
/// * Mukta Vaani  — body/UI (Latin + Gujarati glyphs)
/// * Hind Vadodara — Gujarati script (bhajan titles, lyrics)
/// * Hind         — Devanagari lyrics (Hindi script)
abstract final class AppFonts {
  static const String display = 'YatraOne';
  static const String body = 'MuktaVaani';
  static const String gujarati = 'HindVadodara';
  static const String devanagari = 'Hind';
}

/// Type scale. Sizes match the mockups; colours are applied by the theme.
/// Use via `AppTypography.<style>` — never construct TextStyle sizes inline.
abstract final class AppTypography {
  static const TextStyle _display = TextStyle(fontFamily: AppFonts.display, height: 1.1);
  static const TextStyle _body = TextStyle(fontFamily: AppFonts.body);
  static const TextStyle _guj = TextStyle(fontFamily: AppFonts.gujarati);

  // ---- Display (Yatra One) ----
  static TextStyle get displayLarge => _display.copyWith(fontSize: 32);
  static TextStyle get displayMedium => _display.copyWith(fontSize: 28);
  static TextStyle get displaySmall => _display.copyWith(fontSize: 24);

  // ---- Titles (Mukta Vaani) ----
  static TextStyle get titleLarge => _body.copyWith(fontSize: 17, fontWeight: FontWeight.w700);
  static TextStyle get titleMedium => _body.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get titleSmall => _body.copyWith(fontSize: 15, fontWeight: FontWeight.w600);

  // ---- Body ----
  static TextStyle get bodyLarge => _body.copyWith(fontSize: 16, height: 1.5);
  static TextStyle get bodyMedium => _body.copyWith(fontSize: 15, height: 1.45);
  static TextStyle get bodySmall => _body.copyWith(fontSize: 13, height: 1.4);

  // ---- Labels ----
  static TextStyle get labelLarge => _body.copyWith(fontSize: 14, fontWeight: FontWeight.w700);
  static TextStyle get labelMedium => _body.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600);
  static TextStyle get labelSmall => _body.copyWith(fontSize: 12, fontWeight: FontWeight.w500);

  /// Uppercase eyebrow — "NOW · RAJBHOG SEVA", settings group titles.
  static TextStyle get overline =>
      _body.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3);

  /// Tiny metadata — line counts, tithi under a date.
  static TextStyle get caption => _body.copyWith(fontSize: 11);

  // ---- Lyrics reader ----
  static TextStyle get lyric => _guj.copyWith(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get lyricHindi => lyric.copyWith(fontFamily: AppFonts.devanagari);
  static TextStyle get lyricEnglish => lyric.copyWith(fontFamily: AppFonts.body);

  // ---- Gujarati variants ----
  /// Apply the Gujarati face to any style while keeping size/weight.
  static TextStyle gujarati(TextStyle base) => base.copyWith(fontFamily: AppFonts.gujarati);

  /// Bhajan title in a list row.
  static TextStyle get gujaratiTitle =>
      _guj.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25);

  /// Builds the Material [TextTheme] the app theme installs.
  static TextTheme textTheme(Color ink) => TextTheme(
        displayLarge: displayLarge.copyWith(color: ink),
        displayMedium: displayMedium.copyWith(color: ink),
        displaySmall: displaySmall.copyWith(color: ink),
        titleLarge: titleLarge.copyWith(color: ink),
        titleMedium: titleMedium.copyWith(color: ink),
        titleSmall: titleSmall.copyWith(color: ink),
        bodyLarge: bodyLarge.copyWith(color: ink),
        bodyMedium: bodyMedium.copyWith(color: ink),
        bodySmall: bodySmall.copyWith(color: ink),
        labelLarge: labelLarge.copyWith(color: ink),
        labelMedium: labelMedium.copyWith(color: ink),
        labelSmall: labelSmall.copyWith(color: ink),
      );
}

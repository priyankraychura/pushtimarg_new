import 'package:flutter/material.dart';

/// Spacing scale (dp). Use these instead of magic numbers in padding/gaps.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page gutter used by every screen.
  static const double page = 20;

  /// Space reserved above the floating nav so lists can scroll past it.
  static const double navClearance = 110;

  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: page);
}

/// Corner radii.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 9;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;
  static const double card = 20;
  static const double sheet = 22;
  static const double pill = 999;

  static BorderRadius r(double radius) => BorderRadius.circular(radius);
}

/// Fixed component sizes.
abstract final class AppSizes {
  static const double avatar = 40;
  static const double avatarLarge = 48;
  static const double iconTile = 46; // category icon tile
  static const double ragaTile = 44;
  static const double settingsIcon = 34;
  static const double input = 58;
  static const double button = 56;
  static const double buttonSmall = 44;
  static const double navHeight = 64;
  static const double sevaCard = 128;
  static const double dayCell = 50;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 24;
}

/// Motion. All animations read their durations/curves from here.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);

  /// Container-transform (card → screen) duration.
  static const Duration container = Duration(milliseconds: 420);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

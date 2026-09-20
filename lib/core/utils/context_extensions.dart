import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Short-hands so widgets read `context.colors.accent` instead of digging
/// through `Theme.of(context).extension<AppColors>()`.
extension BuildContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  bool get isDark => colors.isDark;

  Size get screen => MediaQuery.sizeOf(this);
  EdgeInsets get safe => MediaQuery.paddingOf(this);

  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Convenience gaps: `Gap.h(12)` / `Gap.v(8)` — or the named presets.
class Gap extends StatelessWidget {
  const Gap.h(this.size, {super.key}) : _horizontal = true;
  const Gap.v(this.size, {super.key}) : _horizontal = false;

  final double size;
  final bool _horizontal;

  static const Widget xxs = SizedBox(width: AppSpacing.xxs, height: AppSpacing.xxs);
  static const Widget xs = SizedBox(width: AppSpacing.xs, height: AppSpacing.xs);
  static const Widget sm = SizedBox(width: AppSpacing.sm, height: AppSpacing.sm);
  static const Widget md = SizedBox(width: AppSpacing.md, height: AppSpacing.md);
  static const Widget lg = SizedBox(width: AppSpacing.lg, height: AppSpacing.lg);
  static const Widget xl = SizedBox(width: AppSpacing.xl, height: AppSpacing.xl);
  static const Widget xxl = SizedBox(width: AppSpacing.xxl, height: AppSpacing.xxl);

  @override
  Widget build(BuildContext context) =>
      _horizontal ? SizedBox(width: size) : SizedBox(height: size);
}

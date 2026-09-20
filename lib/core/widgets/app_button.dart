import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

enum AppButtonVariant { primary, accent, outlined, ghost }

/// The one button. Variants map to the mockups:
/// * [AppButtonVariant.primary] — solid teal (Sign in)
/// * [AppButtonVariant.accent]  — solid marigold (Read, Auto-scroll)
/// * [AppButtonVariant.outlined] — white with hairline (Google)
/// * [AppButtonVariant.ghost] — text only
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.trailing,
    this.loading = false,
    this.expand = true,
    this.height = AppSizes.button,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final (Color bg, Color fg, BorderSide side, List<BoxShadow> shadow) = switch (variant) {
      AppButtonVariant.primary => (
          c.brand,
          c.brandInk,
          BorderSide.none,
          [BoxShadow(color: c.brand.withValues(alpha: .45), blurRadius: 28, offset: const Offset(0, 12), spreadRadius: -12)],
        ),
      AppButtonVariant.accent => (
          c.accent,
          c.onAccent,
          BorderSide.none,
          [BoxShadow(color: c.accent.withValues(alpha: .6), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -10)],
        ),
      AppButtonVariant.outlined => (c.surface, c.ink, BorderSide(color: c.line, width: 1.5), const []),
      AppButtonVariant.ghost => (Colors.transparent, c.accentInk, BorderSide.none, const []),
    };

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, Gap.sm],
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        else
          Text(label),
        if (trailing != null) ...[Gap.sm, trailing!],
      ],
    );

    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: onPressed == null && !loading ? .55 : 1,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        decoration: BoxDecoration(borderRadius: AppRadius.r(AppRadius.xl), boxShadow: shadow),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.r(AppRadius.xl), side: side),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: loading ? null : onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: DefaultTextStyle(
                style: AppTypography.labelLarge.copyWith(fontSize: 16, color: fg),
                child: IconTheme(data: IconThemeData(color: fg, size: 20), child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// Plain surface card with hairline border — Settings groups, seva cards,
/// calendar grid. Use [OpenContainerCard] instead when tapping should expand
/// into a full screen.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.card,
    this.color,
    this.borderColor,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.r(radius),
      side: BorderSide(color: borderColor ?? c.line),
    );
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: color ?? c.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Teal gradient card with the rose/marigold glow — header band, "today" card.
class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.xxl,
    this.dotted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Adds the faint pichwai dot lattice used on the Home header.
  final bool dotted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: AppRadius.r(radius),
      child: Stack(
        children: [
          // Base teal first — BoxDecoration ignores `color` when a gradient is
          // set, so the glows are separate layers on top.
          Positioned.fill(child: ColoredBox(color: c.brand)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-.8, -.6),
                  radius: 1.1,
                  colors: [AppPalette.rose.withValues(alpha: .30), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(.9, -1),
                  radius: 1,
                  colors: [AppPalette.marigold.withValues(alpha: .28), Colors.transparent],
                ),
              ),
            ),
          ),
          if (dotted) const Positioned.fill(child: CustomPaint(painter: _DotLatticePainter())),
          Padding(
            padding: padding,
            child: DefaultTextStyle(
              style: AppTypography.bodyMedium.copyWith(color: c.brandInk),
              child: IconTheme(data: IconThemeData(color: c.brandInk), child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotLatticePainter extends CustomPainter {
  const _DotLatticePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const step = 14.0;
    final paint = Paint()..color = Colors.white.withValues(alpha: .10);
    final fade = size.height * .6;
    for (double y = 7; y < size.height; y += step) {
      // fade the lattice out towards the bottom, like the mockup mask
      final alpha = y < fade ? .10 : .10 * (1 - (y - fade) / (size.height - fade));
      paint.color = Colors.white.withValues(alpha: alpha.clamp(0, .10));
      for (double x = 7; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

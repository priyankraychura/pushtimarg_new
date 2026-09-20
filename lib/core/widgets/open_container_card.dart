import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// Material "container transform": the tapped card grows into the destination
/// screen and shrinks back into place on close. Wraps `animations.OpenContainer`
/// with the app's radius, colours and timing so every card animates the same.
///
/// ```dart
/// OpenContainerCard(
///   closedBuilder: (_, open) => BhajanTile(bhajan, onTap: open),
///   openBuilder: (_, close) => LyricsScreen(bhajanId: bhajan.id),
/// )
/// ```
class OpenContainerCard extends StatelessWidget {
  const OpenContainerCard({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.radius = AppRadius.xl,
    this.closedColor,
    this.openColor,
    this.closedElevation = 0,
    this.showBorder = true,
    this.transitionType = ContainerTransitionType.fadeThrough,
    this.onClosed,
    this.tappable = true,
  });

  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<void> openBuilder;
  final double radius;
  final Color? closedColor;
  final Color? openColor;
  final double closedElevation;
  final bool showBorder;
  final ContainerTransitionType transitionType;
  final VoidCallback? onClosed;

  /// Set false when the closed child handles its own tap (e.g. calls `open`).
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OpenContainer<void>(
      transitionDuration: AppMotion.container,
      transitionType: transitionType,
      tappable: tappable,
      // Open above the tab shell so the floating nav doesn't sit on the reader.
      useRootNavigator: true,
      closedElevation: closedElevation,
      openElevation: 0,
      closedColor: closedColor ?? c.surface,
      openColor: openColor ?? c.ground,
      middleColor: c.surface,
      closedShape: RoundedRectangleBorder(
        borderRadius: AppRadius.r(radius),
        side: showBorder ? BorderSide(color: c.line) : BorderSide.none,
      ),
      openShape: const RoundedRectangleBorder(),
      onClosed: (_) => onClosed?.call(),
      closedBuilder: closedBuilder,
      openBuilder: openBuilder,
    );
  }
}

/// Convenience for pushing a screen with the shared-axis / fade-through
/// transition when there's no card to expand from (e.g. from a button).
Route<T> fadeThroughRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: AppMotion.normal,
      reverseTransitionDuration: AppMotion.normal,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, secondary, child) => FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondary,
        child: child,
      ),
    );

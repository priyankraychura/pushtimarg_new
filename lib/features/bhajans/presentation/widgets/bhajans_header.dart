import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';

/// Two-stage collapsing header for the Bhajans screen. Pinned.
///
/// **Rest** — lotus tile, centred title and subtitle stacked above a large
/// search bar that sits on the vertical centre of the screen.
///
/// **Stage A (0 → [snapOffset])** — tile and subtitle fade out, the title
/// slides to the top-left and shrinks to 30px, the bar tucks in directly
/// beneath it. Scroll physics snap to the end of this stage.
///
/// **Stage B (→ fully collapsed)** — the title scrolls off and only the bar
/// stays, pinned under the status bar with a backdrop and hairline.
class BhajansHeader extends SliverPersistentHeaderDelegate {
  BhajansHeader({
    required this.screenHeight,
    required this.topPadding,
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  final double screenHeight;
  final double topPadding;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  // ---- geometry ----
  static const double _tile = 44;
  static const double _titleRest = 32, _titleCompact = 30;
  static const double _titleH = 35; // 32px * 1.1 line height
  static const double _subtitleH = 18;
  static const double _barRest = 56, _barCompact = 52, _barPinned = 48;
  static const double _padBelowRest = 16;

  // Compact (end of stage A)
  double get _titleTopA => topPadding + 12;
  double get _barTopA => _titleTopA + _titleH + 12;
  double get _extentA => _barTopA + _barCompact + 12;

  // Rest (shrinkOffset 0) — bar centred on the screen.
  double get _barTop0 {
    final centred = screenHeight / 2 - _barRest / 2;
    final minimum = _extentA - _barRest - _padBelowRest;
    return centred > minimum ? centred : minimum;
  }

  @override
  double get maxExtent => _barTop0 + _barRest + _padBelowRest;

  @override
  double get minExtent => topPadding + 8 + _barPinned + 8;

  /// Scroll offset where stage A ends — the snap target for the physics.
  double get snapOffset => maxExtent - _extentA;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = context.colors;
    final aRange = snapOffset;
    final bRange = _extentA - minExtent;
    final t1 = aRange <= 0 ? 1.0 : (shrinkOffset / aRange).clamp(0.0, 1.0);
    final t2 = ((shrinkOffset - aRange) / bRange).clamp(0.0, 1.0);
    final e1 = AppMotion.standard.transform(t1);

    // The header's visible height right now. Everything hangs off it so the
    // block moves as one piece — no gap can open between bar and list.
    final extent = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    // Bar: anchored to the header's bottom edge; padding and height ease in
    // per stage (rest 56 → compact 52 → pinned 48).
    final padBelow = t2 > 0 ? lerpDouble(12, 8, t2)! : lerpDouble(_padBelowRest, 12, t1)!;
    final barHeight = t2 > 0 ? lerpDouble(_barCompact, _barPinned, t2)! : lerpDouble(_barRest, _barCompact, t1)!;
    final barTop = extent - padBelow - barHeight;

    // Title rides above the bar: gap closes 38 → 12 as it slides to the left.
    final titleGap = lerpDouble(_subtitleH + 20, 12, e1)!;
    final titleTop = barTop - titleGap - _titleH;
    final titleSize = lerpDouble(_titleRest, _titleCompact, e1)!;
    final titleAlign = Alignment.lerp(Alignment.topCenter, Alignment.topLeft, e1)!;

    // Tile and subtitle stay attached to the title while they fade.
    final tileTop = titleTop - 16 - _tile;
    final subtitleTop = titleTop + _titleH + 6;

    return Container(
      decoration: BoxDecoration(
        color: c.ground,
        border: Border(bottom: BorderSide(color: c.line.withValues(alpha: t2))),
        boxShadow: [
          BoxShadow(color: c.ink.withValues(alpha: .08 * t2), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Lotus tile — fades and drifts up during stage A.
            Positioned(
              left: 0,
              right: 0,
              top: tileTop,
              child: Opacity(
                opacity: 1 - t1,
                child: Center(
                  child: Container(
                    width: _tile,
                    height: _tile,
                    decoration: BoxDecoration(
                      color: c.brand,
                      borderRadius: AppRadius.r(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(color: c.brand.withValues(alpha: .4), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -10),
                      ],
                    ),
                    child: Icon(Icons.spa_outlined, color: c.brandInk, size: 24),
                  ),
                ),
              ),
            ),
            // Subtitle — fades out during stage A.
            Positioned(
              left: AppSpacing.page,
              right: AppSpacing.page,
              top: subtitleTop,
              child: Opacity(
                opacity: 1 - t1,
                child: Text(
                  'Every kirtan, aarti and pad — by title, first line, or poet.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: c.ink2),
                ),
              ),
            ),
            // Title.
            Positioned(
              left: AppSpacing.page,
              right: AppSpacing.page,
              top: titleTop,
              height: _titleH,
              child: Opacity(
                opacity: 1 - t2,
                child: Align(
                  alignment: titleAlign,
                  child: Text('Bhajans', style: AppTypography.displayLarge.copyWith(fontSize: titleSize, color: c.ink)),
                ),
              ),
            ),
            // Search bar.
            Positioned(
              left: AppSpacing.page,
              right: AppSpacing.page,
              top: barTop,
              height: barHeight,
              child: AppSearchBar(controller: controller, focusNode: focusNode, onChanged: onChanged, elevated: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant BhajansHeader old) =>
      old.screenHeight != screenHeight || old.topPadding != topPadding || old.controller != controller;
}

import 'package:flutter/material.dart';

import '../../features/bhajans/domain/bhajan.dart';
import '../theme/theme.dart';
import '../utils/context_extensions.dart';
import 'app_chip.dart';
import 'category_tile.dart';

/// One bhajan row — category tile, title, poet · seva,
/// and a favourite heart.
/// Shared by Home and Bhajans so both lists look identical.
class BhajanTile extends StatelessWidget {
  const BhajanTile({
    super.key,
    required this.bhajan,
    this.onTap,
    this.favourite = false,
    this.onFavourite,
    this.showCategoryTag = false,
    this.showDivider = true,
  });

  final Bhajan bhajan;
  /// Called with the tile's own context so callers can read its on-screen
  /// rect (`ContainerOrigin.of`) — a sliver builder's context is the sliver, not the row.
  final void Function(BuildContext tileContext)? onTap;

  final bool favourite;
  final VoidCallback? onFavourite;
  final bool showCategoryTag;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final trailing = GestureDetector(
      onTap: onFavourite,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            favourite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            key: ValueKey(favourite),
            size: 20,
            color: favourite ? c.gold : c.ink3,
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(context),
        borderRadius: AppRadius.r(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
          decoration: showDivider
              ? BoxDecoration(border: Border(top: BorderSide(color: c.line)))
              : null,
          child: Row(
            children: [
              CategoryTile(bhajan.category),
              Gap.md,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bhajan.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.gujaratiTitle.copyWith(color: c.ink),
                          ),
                        ),
                        if (showCategoryTag) ...[
                          Gap.xs,
                          AppTag(
                            bhajan.category.label,
                            tone: switch (bhajan.category) {
                              BhajanCategory.aarti => AppChipTone.accent,
                              BhajanCategory.pad => AppChipTone.rose,
                              _ => AppChipTone.brand,
                            },
                          ),
                        ],
                      ],
                    ),
                    Text(
                      [if (bhajan.poet.isNotEmpty) bhajan.poet, if (bhajan.seva.isNotEmpty) bhajan.seva].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink2),
                    ),
                  ],
                ),
              ),
              Gap.md,
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

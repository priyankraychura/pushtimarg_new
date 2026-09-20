import 'package:flutter/material.dart';

import '../../features/bhajans/domain/bhajan.dart';
import '../theme/theme.dart';
import '../utils/context_extensions.dart';
import 'app_chip.dart';
import 'raga_tile.dart';

/// One bhajan row — raga tile, Gujarati title + transliteration, poet · seva,
/// and either a progress bar (Continue reading) or a heart + line count.
/// Shared by Home and Bhajans so both lists look identical.
class BhajanTile extends StatelessWidget {
  const BhajanTile({
    super.key,
    required this.bhajan,
    this.onTap,
    this.progress,
    this.currentLine,
    this.favourite = false,
    this.onFavourite,
    this.showCategoryTag = false,
    this.showDivider = true,
  });

  final Bhajan bhajan;
  final VoidCallback? onTap;

  /// 0–1 reading progress. When set, a progress bar replaces the heart.
  final double? progress;
  final int? currentLine;
  final bool favourite;
  final VoidCallback? onFavourite;
  final bool showCategoryTag;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final trailing = progress != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'line ${currentLine ?? 0} / ${bhajan.lineCount}',
                style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3),
              ),
              Gap.xs,
              SizedBox(
                width: 44,
                height: 4,
                child: ClipRRect(
                  borderRadius: AppRadius.r(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: c.line,
                    valueColor: AlwaysStoppedAnimation(c.accent),
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onFavourite,
                behavior: HitTestBehavior.opaque,
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    favourite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    key: ValueKey(favourite),
                    size: 18,
                    color: favourite ? c.gold : c.ink3,
                  ),
                ),
              ),
              Gap.xs,
              Text('${bhajan.lineCount} lines',
                  style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3)),
            ],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
          decoration: showDivider
              ? BoxDecoration(border: Border(top: BorderSide(color: c.line)))
              : null,
          child: Row(
            children: [
              RagaTile(bhajan.raga),
              Gap.md,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bhajan.titleGu,
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
                    Text(bhajan.titleEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3)),
                    Gap.xxs,
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink2),
                        children: [
                          TextSpan(
                            text: bhajan.poet,
                            style: TextStyle(fontWeight: FontWeight.w600, color: c.ink),
                          ),
                          TextSpan(text: '  ·  ', style: TextStyle(color: c.ink3)),
                          TextSpan(text: bhajan.primarySeva),
                        ],
                      ),
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

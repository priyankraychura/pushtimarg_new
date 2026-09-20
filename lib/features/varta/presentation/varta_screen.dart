import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/varta_collection.dart';

/// Landing screen for Varta: pick between the 84 and 252 Vaishnav granths.
class VartaScreen extends StatelessWidget {
  const VartaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: context.safe.top + 8, bottom: AppSpacing.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 20,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Gap.xs,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Varta', style: AppTypography.titleLarge.copyWith(color: c.ink)),
                      Text('Vaishnav ni vartao',
                          style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap.lg,
          Padding(
            padding: AppSpacing.pageH,
            child: Text('Choose a granth', style: AppTypography.displaySmall.copyWith(color: c.ink)),
          ),
          Gap.lg,
          Padding(
            padding: AppSpacing.pageH,
            child: Column(
              children: [
                for (final (i, v) in VartaCollection.values.indexed) ...[
                  _VartaOptionCard(collection: v)
                      .animate()
                      .fadeIn(delay: (80 * i).ms, duration: 300.ms)
                      .slideY(begin: .06, curve: AppMotion.standard),
                  if (v != VartaCollection.values.last) Gap.md,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable card per granth — count badge, title in both scripts, and a
/// one-line description.
class _VartaOptionCard extends StatelessWidget {
  const _VartaOptionCard({required this.collection});
  final VartaCollection collection;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      // TODO: open the varta list for this granth once its data lands.
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${collection.title} — coming soon'))),
      child: Row(
        children: [
          _CountBadge(count: collection.count),
          Gap.lg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.title, style: AppTypography.titleMedium.copyWith(color: c.ink)),
                Gap.xxs,
                Text(collection.titleGu,
                    style: AppTypography.gujarati(AppTypography.bodySmall).copyWith(color: c.ink2)),
                Gap.xs,
                Text(collection.description,
                    style: AppTypography.caption.copyWith(fontSize: 12, height: 1.3, color: c.ink3)),
              ],
            ),
          ),
          Gap.sm,
          Icon(Icons.chevron_right_rounded, color: c.ink3),
        ],
      ),
    );
  }
}

/// Marigold square showing the granth's varta count (84 / 252).
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.accentSoft, borderRadius: AppRadius.r(AppRadius.lg)),
      child: Text(
        '$count',
        style: AppTypography.displaySmall.copyWith(
          fontSize: count > 99 ? 20 : 24,
          color: c.accentInk,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bhajans/domain/bhajan.dart';
import '../../../bhajans/providers/bhajan_providers.dart';
import '../../../varta/domain/varta_collection.dart';

/// Four browse tiles — Aarti, Kirtan, Pad, Varta — with live counts.
/// Tapping sets the filter and switches to the Bhajans tab; Pad and Varta
/// instead open their own screens (the 41 pads of Shri Yamunaji, and the
/// 84 / 252 Vaishnav ni Varta).
class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final all = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];

    return Padding(
      padding: AppSpacing.pageH,
      child: Row(
        children: [
          for (final cat in BhajanCategory.values) ...[
            Expanded(
              child: AppCard(
                radius: AppRadius.xl,
                padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
                onTap: () {
                  if (cat == BhajanCategory.pad) {
                    context.push(AppRoutes.pad);
                    return;
                  }
                  if (cat == BhajanCategory.varta) {
                    context.push(AppRoutes.varta);
                    return;
                  }
                  ref.read(bhajanFilterProvider.notifier).setCategory(cat);
                  context.go(AppRoutes.bhajans);
                },
                child: Column(
                  children: [
                    IconTile(icon: cat.icon, tone: cat.tone),
                    Gap.xs,
                    Text(cat.label, style: AppTypography.labelMedium.copyWith(fontSize: 13, color: c.ink)),
                    Text(
                      // Varta has no bhajan rows; show the two granth sizes instead.
                      cat == BhajanCategory.varta
                          ? VartaCollection.values.map((v) => v.count).join(' · ')
                          : '${all.where((b) => b.category == cat).length}',
                      style: AppTypography.caption.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
            ),
            if (cat != BhajanCategory.values.last) Gap.sm,
          ],
        ],
      ),
    );
  }
}

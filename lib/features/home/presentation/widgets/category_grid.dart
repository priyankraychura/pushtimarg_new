import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bhajans/domain/bhajan.dart';
import '../../../bhajans/providers/bhajan_providers.dart';

/// Four browse tiles — Aarti, Kirtan, Pad, Vasta — with live counts.
/// Tapping sets the filter and switches to the Bhajans tab.
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
                  ref.read(bhajanFilterProvider.notifier).setCategory(cat);
                  context.go(AppRoutes.bhajans);
                },
                child: Column(
                  children: [
                    IconTile(icon: cat.icon, tone: cat.tone),
                    Gap.xs,
                    Text(cat.label, style: AppTypography.labelMedium.copyWith(fontSize: 13, color: c.ink)),
                    Text('${all.where((b) => b.category == cat).length}',
                        style: AppTypography.caption.copyWith(color: c.ink3)),
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

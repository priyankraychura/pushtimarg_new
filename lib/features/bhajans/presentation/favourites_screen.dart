import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../../user/providers/user_data_providers.dart';
import '../domain/bhajan.dart';
import '../providers/bhajan_providers.dart';
import 'widgets/bhajan_list.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final all = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];
    final favs = ref.watch(userDataProvider.select((u) => u.favourites));
    final list = all.where((b) => favs.contains(b.id)).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, context.safe.top + 14, AppSpacing.xl, AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Favourites', style: AppTypography.displayMedium.copyWith(fontSize: 30, color: c.ink)),
                  const Spacer(),
                  Text('${list.length} saved', style: AppTypography.bodySmall.copyWith(color: c.ink3)),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline_rounded, size: 48, color: c.gold),
                    Gap.lg,
                    Text('Nothing saved yet', style: AppTypography.titleLarge.copyWith(color: c.ink)),
                    Gap.sm,
                    Text(
                      'Tap the heart on any bhajan and it will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(color: c.ink2),
                    ),
                    Gap.xl,
                    AppButton(
                      label: 'Browse bhajans',
                      expand: false,
                      height: AppSizes.buttonSmall,
                      onPressed: () => context.go(AppRoutes.bhajans),
                    ),
                    const SizedBox(height: AppSpacing.navClearance),
                  ],
                ),
              ),
            )
          else
            BhajanSliverList(bhajans: list, showCategoryTag: true, keyPrefix: 'fav'),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.navClearance)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/bhajan.dart';
import '../providers/bhajan_providers.dart';
import 'widgets/bhajan_list.dart';

class BhajansScreen extends ConsumerStatefulWidget {
  const BhajansScreen({super.key});

  @override
  ConsumerState<BhajansScreen> createState() => _BhajansScreenState();
}

class _BhajansScreenState extends ConsumerState<BhajansScreen> {
  late final _search = TextEditingController(text: ref.read(bhajanFilterProvider).query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filter = ref.watch(bhajanFilterProvider);
    final all = ref.watch(allBhajansProvider);
    final list = ref.watch(filteredBhajansProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, context.safe.top + 14, AppSpacing.xl, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('Bhajans', style: AppTypography.displayMedium.copyWith(fontSize: 30, color: c.ink)),
                      const Spacer(),
                      Text('${all.value?.length ?? 0} bhajans',
                          style: AppTypography.bodySmall.copyWith(color: c.ink3)),
                    ],
                  ),
                  Gap.lg,
                  AppSearchBar(
                    controller: _search,
                    onChanged: ref.read(bhajanFilterProvider.notifier).setQuery,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                children: [
                  AppChip(
                    label: 'All',
                    selected: filter.category == null,
                    onTap: () => ref.read(bhajanFilterProvider.notifier).setCategory(null),
                  ),
                  for (final cat in BhajanCategory.values) ...[
                    Gap.sm,
                    AppChip(
                      label: cat.label,
                      selected: filter.category == cat,
                      onTap: () => ref.read(bhajanFilterProvider.notifier).setCategory(cat),
                    ),
                  ],
                  Gap.sm,
                  _SortChip(sort: filter.sort),
                ],
              ),
            ),
          ),
          if (all.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('No bhajans match.', style: AppTypography.bodyMedium.copyWith(color: c.ink3)),
              ),
            )
          else
            BhajanSliverList(
              bhajans: list,
              showCategoryTag: true,
              keyPrefix: 'lib',
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.navClearance)),
        ],
      ),
    );
  }
}

class _SortChip extends ConsumerWidget {
  const _SortChip({required this.sort});
  final BhajanSort sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = switch (sort) { BhajanSort.az => 'A–Z', BhajanSort.seva => 'By seva', BhajanSort.poet => 'By poet' };
    return PopupMenuButton<BhajanSort>(
      onSelected: ref.read(bhajanFilterProvider.notifier).setSort,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.r(AppRadius.md)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: BhajanSort.az, child: Text('A–Z')),
        PopupMenuItem(value: BhajanSort.seva, child: Text('By seva')),
        PopupMenuItem(value: BhajanSort.poet, child: Text('By poet')),
      ],
      child: AppChip(label: label, trailing: const Icon(Icons.expand_more_rounded, size: 16)),
    );
  }
}

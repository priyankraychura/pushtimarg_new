import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/snap_header_physics.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/bhajan.dart';
import '../providers/bhajan_providers.dart';
import 'widgets/bhajan_list.dart';
import 'widgets/bhajans_header.dart';

class BhajansScreen extends ConsumerStatefulWidget {
  const BhajansScreen({super.key});

  @override
  ConsumerState<BhajansScreen> createState() => _BhajansScreenState();
}

class _BhajansScreenState extends ConsumerState<BhajansScreen> {
  late final _search = TextEditingController(text: ref.read(bhajanFilterProvider).query);
  final _scroll = ScrollController();
  final _searchFocus = FocusNode();
  double _snapOffset = 0;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocus);
  }

  /// Tapping the centred search bar plays the same snap as a flick up, so the
  /// keyboard rises to a compact header instead of covering the landing.
  void _onSearchFocus() {
    if (!_searchFocus.hasFocus || !_scroll.hasClients) return;
    if (_scroll.offset < _snapOffset) {
      _scroll.animateTo(_snapOffset, duration: AppMotion.slow, curve: AppMotion.standard);
    }
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_onSearchFocus);
    _searchFocus.dispose();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filter = ref.watch(bhajanFilterProvider);
    final all = ref.watch(allBhajansProvider);
    final list = ref.watch(filteredBhajansProvider);

    final header = BhajansHeader(
      screenHeight: context.screen.height,
      topPadding: context.safe.top,
      controller: _search,
      focusNode: _searchFocus,
      onChanged: ref.read(bhajanFilterProvider.notifier).setQuery,
    );
    _snapOffset = header.snapOffset;

    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        // Flicks snap to the compact state (title top-left, bar beneath).
        physics: SnapHeaderScrollPhysics.of(context, snapOffset: header.snapOffset),
        slivers: [
          SliverPersistentHeader(pinned: true, delegate: header),
          SliverToBoxAdapter(
            child: SizedBox(
              // Horizontal ListView children stretch to its height — keep it
              // exactly one chip tall so the pills don't balloon.
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/bhajan.dart';
import '../providers/bhajan_providers.dart';
import 'widgets/bhajan_list.dart';

/// Full-screen search reached from the Home search bar. The bar itself is a
/// [Hero] — it flies up from its Home position into this top bar while the
/// screen fades in, and the field autofocuses so the keyboard rises with it.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Focus after the hero flight lands so the keyboard doesn't fight the animation.
    Future<void>.delayed(AppMotion.normal, () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final all = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];
    final results = all.where((b) => b.matches(_query)).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.sm, context.safe.top + AppSpacing.sm, AppSpacing.lg, 0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 20,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Gap.xs,
                  Expanded(
                    child: AppSearchBar(
                      heroTag: AppSearchBar.homeHeroTag,
                      controller: _controller,
                      focusNode: _focus,
                      onChanged: (q) => setState(() => _query = q),
                      trailing: searching
                          ? GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                              child: Icon(Icons.close_rounded, size: 18, color: c.ink3),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xl, AppSpacing.page, AppSpacing.xxs),
              child: Text(
                searching
                    ? '${results.length} ${results.length == 1 ? 'result' : 'results'}'
                    : 'All bhajans',
                style: AppTypography.overline.copyWith(color: c.ink3),
              ),
            ),
          ),
          if (results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 44, color: c.ink3),
                    Gap.md,
                    Text('Nothing matches "$_query"', style: AppTypography.titleMedium.copyWith(color: c.ink)),
                    Gap.xs,
                    Text(
                      'Try the first line, the poet, or a Gujarati spelling.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: c.ink2),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            )
          else
            BhajanSliverList(bhajans: results, showCategoryTag: true, keyPrefix: 'search'),
          SliverToBoxAdapter(child: SizedBox(height: context.safe.bottom + AppSpacing.xxl)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/varta.dart';
import '../domain/varta_collection.dart';
import '../providers/varta_providers.dart';

/// All vartas of one granth (84 or 252), in order. Tapping opens the reader.
class VartaListScreen extends ConsumerWidget {
  const VartaListScreen({super.key, required this.collection});
  final VartaCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final vartas = ref.watch(vartasProvider(collection));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: context.safe.top + 8, left: AppSpacing.md, right: AppSpacing.md),
            sliver: SliverToBoxAdapter(
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
                        Text(collection.title, style: AppTypography.titleLarge.copyWith(color: c.ink)),
                        Text(
                          collection.titleGu,
                          style: AppTypography.gujarati(AppTypography.caption).copyWith(fontSize: 12, color: c.ink3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Gap.lg),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Vartas',
              subtitle: vartas.hasValue ? '${vartas.value!.length} of ${collection.count}' : null,
            ),
          ),
          const SliverToBoxAdapter(child: Gap.md),
          vartas.when(
            loading: () =>
                const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: AppSpacing.pageH,
                  child: Text(
                    'Could not load.\n\n$e',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: c.ink3),
                  ),
                ),
              ),
            ),
            data: (list) => list.isEmpty
                ? SliverFillRemaining(hasScrollBody: false, child: _Empty(collection: collection))
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxxl),
                    sliver: SliverList.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) => _VartaRow(
                        varta: list[i],
                        showDivider: i > 0,
                      ).animate().fadeIn(delay: (40 * i).clamp(0, 400).ms, duration: 300.ms),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Number badge · name / subtitle · prasang count · chevron.
class _VartaRow extends StatelessWidget {
  const _VartaRow({required this.varta, required this.showDivider});
  final Varta varta;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        if (showDivider) Divider(height: 1, color: c.line, indent: 62),
        InkWell(
          onTap: () => context.push(AppRoutes.vartaReadFor(varta.collection.name, varta.id)),
          borderRadius: AppRadius.r(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: AppSizes.ragaTile,
                  height: AppSizes.ragaTile,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.surface2, borderRadius: AppRadius.r(AppSizes.ragaTile * .3)),
                  child: Text(
                    '${varta.number}',
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 15,
                      color: c.brandText,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Gap.md,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        varta.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.gujaratiTitle.copyWith(color: c.ink),
                      ),
                      Gap.xxs,
                      Text(
                        [varta.subtitle, '${varta.prasangCount} prasang'].where((s) => s.isNotEmpty).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.gujarati(AppTypography.caption).copyWith(fontSize: 12, color: c.ink3),
                      ),
                    ],
                  ),
                ),
                Gap.sm,
                Icon(Icons.chevron_right_rounded, color: c.ink3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.collection});
  final VartaCollection collection;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 40, color: c.ink3),
          Gap.md,
          Text('Vartas coming soon', style: AppTypography.titleMedium.copyWith(color: c.ink2)),
          Gap.xs,
          Text(
            'The ${collection.count} vartas of this granth are being added.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: c.ink3),
          ),
        ],
      ),
    );
  }
}

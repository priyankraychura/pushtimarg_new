import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/gujarati_digits.dart';
import '../../../core/widgets/widgets.dart';
import '../../user/providers/user_data_providers.dart';
import '../data/yamunaji_41_pad_bhajans.dart';
import '../domain/bhajan.dart';
import '../providers/bhajan_providers.dart';

/// શ્રી યમુનાજીનાં ૪૧ પદ — the whole set on one screen, opened from the Pad
/// tile on Home. Rows are numbered ૧–૪૧ in granth order and can be narrowed
/// to one poet; tapping a row opens the lyrics reader.
class PadScreen extends ConsumerStatefulWidget {
  const PadScreen({super.key});

  @override
  ConsumerState<PadScreen> createState() => _PadScreenState();
}

class _PadScreenState extends ConsumerState<PadScreen> {
  /// Selected poet filter; null means every poet.
  String? _poet;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final all = ref.watch(allBhajansProvider);
    final pads = ref.watch(yamunaji41PadsProvider);

    // Poets in the order their pads appear, so the chips read like the granth.
    final poets = <String>{for (final p in pads) if (p.poet.isNotEmpty) p.poet}.toList();
    final selected = poets.contains(_poet) ? _poet : null;
    final list = selected == null ? pads : pads.where((p) => p.poet == selected).toList();

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
                        Text('Pad', style: AppTypography.titleLarge.copyWith(color: c.ink)),
                        Text(
                          'શ્રી યમુનાજીનાં ૪૧ પદ',
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
            child: Padding(
              padding: AppSpacing.pageH,
              child: _PadHeroCard(count: pads.length, poets: poets.length)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: .06, curve: AppMotion.standard),
            ),
          ),
          if (poets.length > 1) ...[
            const SliverToBoxAdapter(child: Gap.md),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
                  children: [
                    AppChip(
                      label: 'All poets',
                      selected: selected == null,
                      onTap: () => setState(() => _poet = null),
                    ),
                    for (final poet in poets) ...[
                      Gap.sm,
                      AppChip(
                        label: poet,
                        selected: selected == poet,
                        onTap: () => setState(() => _poet = poet),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else
            const SliverToBoxAdapter(child: Gap.xl),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Pads',
              subtitle: pads.isEmpty ? null : '${list.length} of ${pads.length}',
            ),
          ),
          const SliverToBoxAdapter(child: Gap.sm),
          if (pads.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: all.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const _Empty(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxxl),
              sliver: SliverList.builder(
                itemCount: list.length,
                itemBuilder: (context, i) => _PadRow(
                  key: ValueKey('pad-${list[i].id}'),
                  pad: list[i],
                  showDivider: i > 0,
                ).animate().fadeIn(delay: (30 * i.clamp(0, 12)).ms, duration: 260.ms),
              ),
            ),
        ],
      ),
    );
  }
}

/// Rose card introducing the set — ૪૧ badge, title in both scripts, and who
/// composed it.
class _PadHeroCard extends StatelessWidget {
  const _PadHeroCard({required this.count, required this.poets});

  final int count;
  final int poets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.roseSoft, borderRadius: AppRadius.r(AppRadius.lg)),
            child: Text(
              gujaratiDigits(count),
              style: AppTypography.gujarati(AppTypography.displaySmall).copyWith(color: c.rose),
            ),
          ),
          Gap.lg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shri Yamunaji na 41 Pad', style: AppTypography.titleMedium.copyWith(color: c.ink)),
                Gap.xxs,
                Text(
                  'શ્રી યમુનાજીનાં ૪૧ પદ',
                  style: AppTypography.gujarati(AppTypography.bodySmall).copyWith(color: c.ink2),
                ),
                Gap.xs,
                Text(
                  'Four pads each by the Ashtachhap poets, Shri Gusainji and '
                  'Rasik Pritam, and a closing forty-first.',
                  style: AppTypography.caption.copyWith(fontSize: 12, height: 1.3, color: c.ink3),
                ),
                if (poets > 0) ...[
                  Gap.xs,
                  Text(
                    '$poets poets',
                    style: AppTypography.labelSmall.copyWith(color: c.ink3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Number badge · pad line · poet · favourite heart. Opens the reader.
class _PadRow extends ConsumerWidget {
  const _PadRow({super.key, required this.pad, required this.showDivider});

  final Bhajan pad;
  final bool showDivider;

  /// Titles read "યમુનાજી પદ ૦૭ – શ્રી યમુના સી નાહી"; the number is already
  /// in the badge, so the row shows only the opening line.
  String get _line {
    const dash = '–';
    final i = pad.title.indexOf(dash);
    return i == -1 ? pad.title : pad.title.substring(i + dash.length).trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final favourite = ref.watch(isFavouriteProvider(pad.id));
    final number = yamunajiPadNumber(pad.id);

    return Column(
      children: [
        if (showDivider) Divider(height: 1, color: c.line, indent: 62),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.lyricsFor(pad.id), extra: ContainerOrigin.of(context)),
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
                      number == 0 ? '–' : gujaratiDigits(number),
                      style: AppTypography.gujarati(AppTypography.labelLarge).copyWith(
                        fontSize: 16,
                        color: c.brandText,
                      ),
                    ),
                  ),
                  Gap.md,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _line,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.gujaratiTitle.copyWith(color: c.ink),
                        ),
                        Gap.xxs,
                        Text(
                          pad.poet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink2),
                        ),
                      ],
                    ),
                  ),
                  Gap.sm,
                  GestureDetector(
                    onTap: () => ref.read(userDataProvider.notifier).toggleFavourite(pad.id),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
          Text('Pads coming soon', style: AppTypography.titleMedium.copyWith(color: c.ink2)),
          Gap.xs,
          Text(
            'The 41 pads of Shri Yamunaji are being added.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: c.ink3),
          ),
        ],
      ),
    );
  }
}

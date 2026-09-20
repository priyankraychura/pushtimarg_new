import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../bhajans/domain/bhajan.dart';
import '../../bhajans/providers/bhajan_providers.dart';
import '../../lyrics/presentation/lyrics_screen.dart';
import '../../user/providers/user_data_providers.dart';
import 'widgets/category_grid.dart';
import 'widgets/home_header.dart';
import 'widgets/poets_row.dart';
import 'widgets/seva_rail.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bhajans = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];
    final userData = ref.watch(userDataProvider);

    // "Continue reading": anything with saved progress, most recent first.
    final continueReading = bhajans.where((b) => userData.progress.containsKey(b.id)).toList();
    final list = continueReading.isEmpty ? bhajans.take(4).toList() : continueReading.take(4).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header + search bar share one box so the bar can overlap the band
          // (slivers paint back-to-front, so a separate sliver would sit under it).
          SliverToBoxAdapter(
            child: Stack(
              children: [
                const Padding(padding: EdgeInsets.only(bottom: 26), child: HomeHeader()),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: 0,
                  child: AppSearchBar(
                    elevated: true,
                    heroTag: AppSearchBar.homeHeroTag,
                    onTap: () => context.push(AppRoutes.search),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          const SliverToBoxAdapter(child: SevaRail()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Browse'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          const SliverToBoxAdapter(child: CategoryGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: continueReading.isEmpty ? 'Popular kirtans' : 'Continue reading',
              actionLabel: 'History',
              onAction: () => context.go(AppRoutes.bhajans),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final b = list[i];
                final line = userData.progress[b.id];
                return OpenContainerCard(
                  radius: AppRadius.lg,
                  showBorder: false,
                  closedColor: Colors.transparent,
                  closedBuilder: (_, open) => BhajanTile(
                    bhajan: b,
                    onTap: open,
                    showDivider: i > 0,
                    progress: line == null ? null : (line / b.lineCount).clamp(0, 1),
                    currentLine: line,
                    favourite: userData.favourites.contains(b.id),
                    onFavourite: () => ref.read(userDataProvider.notifier).toggleFavourite(b.id),
                  ),
                  openBuilder: (_, _) => LyricsScreen(bhajanId: b.id),
                ).animate().fadeIn(delay: (60 * i).ms, duration: 300.ms);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Ashtachhap', subtitle: 'eight poets', actionLabel: 'All poets'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          const SliverToBoxAdapter(child: PoetsRow()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.navClearance)),
        ],
      ),
    );
  }
}

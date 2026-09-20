import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../lyrics/presentation/lyrics_screen.dart';
import '../../../user/providers/user_data_providers.dart';
import '../../domain/bhajan.dart';

/// Sliver list of [BhajanTile]s where every row expands into the reader with
/// the container transform. Shared by Bhajans and Favourites.
class BhajanSliverList extends ConsumerWidget {
  const BhajanSliverList({
    super.key,
    required this.bhajans,
    this.showCategoryTag = false,
    this.keyPrefix = '',
  });

  final List<Bhajan> bhajans;
  final bool showCategoryTag;
  final String keyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(userDataProvider.select((u) => u.favourites));
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      sliver: SliverList.builder(
        itemCount: bhajans.length,
        itemBuilder: (context, i) {
          final b = bhajans[i];
          return OpenContainerCard(
            key: ValueKey('$keyPrefix-${b.id}'),
            radius: AppRadius.lg,
            showBorder: false,
            closedColor: Colors.transparent,
            closedBuilder: (_, open) => BhajanTile(
              bhajan: b,
              onTap: open,
              showDivider: i > 0,
              showCategoryTag: showCategoryTag,
              favourite: favourites.contains(b.id),
              onFavourite: () => ref.read(userDataProvider.notifier).toggleFavourite(b.id),
            ),
            openBuilder: (_, _) => LyricsScreen(bhajanId: b.id),
          ).animate().fadeIn(delay: (30 * i.clamp(0, 12)).ms, duration: 260.ms);
        },
      ),
    );
  }
}

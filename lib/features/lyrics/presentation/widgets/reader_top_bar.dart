import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../user/providers/user_data_providers.dart';

/// Back · title/subtitle (left-aligned) · favourite · share.
class ReaderTopBar extends ConsumerWidget {
  const ReaderTopBar({super.key, required this.title, required this.subtitle, required this.bhajanId});

  final String title;
  final String subtitle;
  final String bhajanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(isFavouriteProvider(bhajanId));
    const white = Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: 20,
            color: white,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Gap.xs,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.gujaratiTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w700, color: white),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 11.5, color: white.withValues(alpha: .72)),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: fav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            color: fav ? AppPalette.marigold : white,
            onTap: () => ref.read(userDataProvider.notifier).toggleFavourite(bhajanId),
          ),
          AppIconButton(icon: Icons.share_outlined, iconSize: 20, color: white, onTap: () {}),
        ],
      ),
    );
  }
}

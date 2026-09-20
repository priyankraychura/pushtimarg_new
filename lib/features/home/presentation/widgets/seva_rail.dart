import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/seva.dart';
import '../../providers/home_providers.dart';

/// Horizontal "Aaj ni seva" cards — done ones dimmed, the live one in marigold.
class SevaRail extends ConsumerStatefulWidget {
  const SevaRail({super.key});

  @override
  ConsumerState<SevaRail> createState() => _SevaRailState();
}

class _SevaRailState extends ConsumerState<SevaRail> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll the live seva into view on first build.
    Future<void>.delayed(AppMotion.normal, () {
      if (!mounted || !_scroll.hasClients) return;
      final schedule = ref.read(sevaScheduleProvider);
      final i = schedule.sevas.indexOf(schedule.current());
      if (i > 1) {
        final target = ((i - 1) * (AppSizes.sevaCard + AppSpacing.sm)).clamp(0.0, _scroll.position.maxScrollExtent);
        _scroll.animateTo(target, duration: AppMotion.slow, curve: AppMotion.standard);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(sevaScheduleProvider);
    ref.watch(currentSevaProvider); // rebuild when the live seva changes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Aaj ni seva', subtitle: 'ashtayam', actionLabel: 'Full timeline'),
        Gap.md,
        SizedBox(
          height: 118,
          child: ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pageH,
            itemCount: schedule.sevas.length,
            separatorBuilder: (_, _) => Gap.sm,
            itemBuilder: (_, i) => _SevaCard(seva: schedule.sevas[i], status: schedule.status(schedule.sevas[i])),
          ),
        ),
      ],
    );
  }
}

class _SevaCard extends ConsumerWidget {
  const _SevaCard({required this.seva, required this.status});
  final Seva seva;
  final SevaStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final live = status == SevaStatus.live;
    final bhajans = ref.watch(bhajansForSevaProvider(seva));
    final bhajan = bhajans.firstOrNull;
    return AnimatedOpacity(
      duration: AppMotion.normal,
      opacity: status == SevaStatus.done ? .6 : 1,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 10),
        radius: AppRadius.xl,
        color: live ? c.accentSoft : null,
        borderColor: live ? c.accent : null,
        // Opens the seva's kirtan, expanding from this card.
        onTap: bhajan == null
            ? null
            : () => context.push(AppRoutes.lyricsFor(bhajan.id), extra: ContainerOrigin.of(context, radius: AppRadius.xl)),
        child: SizedBox(
          width: AppSizes.sevaCard - AppSpacing.md * 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                live ? '${seva.timeLabel} · now' : seva.timeLabel,
                style: AppTypography.caption.copyWith(
                  color: live ? c.accentInk : c.ink3,
                  fontWeight: live ? FontWeight.w600 : FontWeight.w400,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(seva.name, style: AppTypography.titleSmall.copyWith(color: c.ink)),
              Gap.xs,
              Text(bhajan?.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 12, height: 1.3, color: c.ink2)),
              const Spacer(),
              Text('${bhajans.length} kirtans', style: AppTypography.caption.copyWith(color: c.ink3)),
            ],
          ),
        ),
      ),
    );
  }
}

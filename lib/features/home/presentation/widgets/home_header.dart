import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../calendar/providers/calendar_providers.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../providers/home_providers.dart';

/// Teal band: greeting, tithi/date (tap → calendar), avatar, and the
/// "Now · Rajbhog seva" card with a Read button.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final user = ref.watch(currentUserProvider);
    final seva = ref.watch(currentSevaProvider).value;
    final tithi = ref.watch(todayTithiProvider).value;
    final showTithi = ref.watch(settingsProvider.select((s) => s.showTithi));

    final nowBhajan = seva == null ? null : ref.watch(bhajanForSevaProvider(seva));

    final dateLabel = DateFormat('EEEE, d MMM').format(DateTime.now());
    final tithiLabel = showTithi && tithi != null ? '${tithi.fullLabel} · $dateLabel' : dateLabel;

    return BrandCard(
      radius: 0,
      dotted: true,
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, context.safe.top + AppSpacing.md, AppSpacing.xl, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jai Shree Krushna',
                        style: AppTypography.displayMedium.copyWith(color: c.brandInk)),
                    Gap.xxs,
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.calendar),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              tithiLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(color: c.brandInk.withValues(alpha: .78)),
                            ),
                          ),
                          Gap.xxs,
                          Icon(Icons.chevron_right_rounded, size: 16, color: c.brandInk.withValues(alpha: .6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppAvatar(name: user?.name ?? 'V', photoUrl: user?.photoUrl),
            ],
          ),
          Gap.lg,
          _NowCard(
            sevaName: seva?.name ?? '',
            kirtan: seva?.kirtan ?? '',
            onRead: nowBhajan == null ? null : () {},
            bhajanId: nowBhajan?.id,
          ),
        ],
      ),
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({required this.sevaName, required this.kirtan, required this.onRead, this.bhajanId});

  final String sevaName;
  final String kirtan;
  final VoidCallback? onRead;
  final String? bhajanId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
        borderRadius: AppRadius.r(AppRadius.xl),
      ),
      child: Row(
        children: [
          const _Pulse(),
          Gap.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOW · ${sevaName.toUpperCase()} SEVA',
                    style: AppTypography.overline.copyWith(color: c.brandInk.withValues(alpha: .7))),
                Text(kirtan, style: AppTypography.titleSmall.copyWith(color: c.brandInk)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
            decoration: BoxDecoration(color: c.accent, borderRadius: AppRadius.r(AppRadius.pill)),
            child: Text('Read', style: AppTypography.labelMedium.copyWith(fontSize: 13, color: c.onAccent)),
          ),
        ],
      ),
    );

    if (bhajanId == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.r(AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.lyricsFor(bhajanId!), extra: ContainerOrigin.of(context, radius: AppRadius.xl)),
        child: card,
      ),
    );
  }
}

/// Marigold dot with a slow expanding ring.
class _Pulse extends StatefulWidget {
  const _Pulse();

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = Curves.easeOut.transform(_ctrl.value);
        return SizedBox(
          width: 18,
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 10 + 14 * t,
                height: 10 + 14 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent.withValues(alpha: (1 - t) * .5),
                ),
              ),
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: c.accent)),
            ],
          ),
        );
      },
    );
  }
}

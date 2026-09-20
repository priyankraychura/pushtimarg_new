import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/tithi_day.dart';

/// Teal card: today's tithi, seva line, and a countdown to the next Agiyaras.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.today, required this.sevaLine, required this.nextEkadashi});

  final TithiDay? today;
  final String? sevaLine;
  final TithiDay? nextEkadashi;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final daysTo = nextEkadashi == null
        ? null
        : DateTime(nextEkadashi!.date.year, nextEkadashi!.date.month, nextEkadashi!.date.day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
    final utsav = today?.utsav.isNotEmpty == true ? today!.utsav.join(', ') : 'no utsav today';

    return BrandCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 14, AppSpacing.lg, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY · ${DateFormat('EEEE d MMM').format(now).toUpperCase()}',
                    style: AppTypography.overline.copyWith(color: c.brandInk.withValues(alpha: .7))),
                const SizedBox(height: 2),
                Text(today?.fullLabel ?? '—', style: AppTypography.titleLarge.copyWith(fontSize: 18, color: c.brandInk)),
                const SizedBox(height: 2),
                Text(
                  [?sevaLine, utsav].join(' · '),
                  style: AppTypography.bodySmall.copyWith(color: c.brandInk.withValues(alpha: .8)),
                ),
              ],
            ),
          ),
          Gap.md,
          if (daysTo != null)
            Container(
              constraints: const BoxConstraints(minWidth: 74),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                border: Border.all(color: Colors.white.withValues(alpha: .18)),
                borderRadius: AppRadius.r(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Text(daysTo == 0 ? 'Today' : '$daysTo',
                      style: AppTypography.displaySmall.copyWith(fontSize: 22, color: c.brandInk)),
                  Text(
                    daysTo == 0 ? 'AGIYARAS' : 'DAYS TO\nAGIYARAS',
                    textAlign: TextAlign.center,
                    style: AppTypography.overline.copyWith(fontSize: 10.5, letterSpacing: .5, color: c.brandInk.withValues(alpha: .8)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

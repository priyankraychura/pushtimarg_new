import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/providers/home_providers.dart';
import '../providers/calendar_providers.dart';
import 'widgets/ekadashi_tile.dart';
import 'widgets/month_grid.dart';
import 'widgets/today_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final month = ref.watch(visibleMonthProvider);
    final days = ref.watch(monthTithiProvider(month));
    final today = ref.watch(todayTithiProvider).value;
    final upcoming = ref.watch(upcomingEkadashiProvider);
    final seva = ref.watch(currentSevaProvider).value;

    // Gujarati months spanned by this Gregorian month, e.g. "Shravan Vad → Bhadarva Sud".
    final span = (days.value?.values ?? const [])
        .where((d) => d.date.month == month.month)
        .map((d) => '${d.monthGu} ${d.paksha.name[0].toUpperCase()}${d.paksha.name.substring(1)}')
        .toSet()
        .join(' → ');

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: context.safe.top + 8, bottom: AppSpacing.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                      Text('Calendar', style: AppTypography.titleLarge.copyWith(color: c.ink)),
                      Text('Vikram Samvat ${_vikramSamvat(month)}',
                          style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3)),
                    ],
                  ),
                ),
                AppIconButton(icon: Icons.schedule_rounded, onTap: () {}),
              ],
            ),
          ),
          Gap.lg,
          Padding(
            padding: AppSpacing.pageH,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMMM yyyy').format(month),
                          style: AppTypography.displaySmall.copyWith(color: c.ink)),
                      if (span.isNotEmpty)
                        Text(span, style: AppTypography.caption.copyWith(fontSize: 12.5, color: c.ink3)),
                    ],
                  ),
                ),
                _RoundNav(icon: Icons.chevron_left_rounded, onTap: ref.read(visibleMonthProvider.notifier).previous),
                Gap.xs,
                _RoundNav(icon: Icons.chevron_right_rounded, onTap: ref.read(visibleMonthProvider.notifier).next),
              ],
            ),
          ),
          Gap.lg,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: MonthGrid(month: month, days: days.value ?? const {})
                .animate(key: ValueKey(month))
                .fadeIn(duration: 250.ms)
                .slideX(begin: .04, curve: AppMotion.standard),
          ),
          Gap.lg,
          Padding(
            padding: AppSpacing.pageH,
            child: TodayCard(
              today: today,
              sevaLine: seva == null ? null : '${seva.name} seva at ${seva.timeLabel}',
              nextEkadashi: upcoming.value?.firstOrNull,
            ),
          ),
          Gap.xxl,
          const SectionHeader(title: 'Upcoming Agiyaras', actionLabel: 'All'),
          Gap.md,
          Padding(
            padding: AppSpacing.pageH,
            child: upcoming.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (_, _) => Text('Could not load.', style: AppTypography.bodyMedium.copyWith(color: c.ink3)),
              data: (list) => Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    EkadashiTile(day: list[i], highlight: i == 0),
                    if (i < list.length - 1) Gap.sm,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vikram Samvat rolls over after Diwali (Kartak Sud 1), roughly late Oct/Nov.
  static int _vikramSamvat(DateTime d) => d.year + (d.month >= 11 ? 57 : 56);
}

class _RoundNav extends StatelessWidget {
  const _RoundNav({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppIconButton(icon: icon, onTap: onTap, size: 34, iconSize: 18, background: c.surface, color: c.ink2);
  }
}

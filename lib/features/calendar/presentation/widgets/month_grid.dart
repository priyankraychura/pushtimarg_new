import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/tithi_day.dart';
import 'day_cell.dart';

/// 7-column month grid with padding days from the neighbouring months,
/// plus the legend underneath.
class MonthGrid extends StatelessWidget {
  const MonthGrid({super.key, required this.month, required this.days});

  final DateTime month;

  /// Keyed by yyyy-MM-dd; may include days outside [month].
  final Map<String, TithiDay> days;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday % 7; // Sunday-first
    final start = first.subtract(Duration(days: leading));
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final total = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              for (final d in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(d, style: AppTypography.overline.copyWith(letterSpacing: .8, color: c.ink3)),
                    ),
                  ),
                ),
            ],
          ),
          for (var row = 0; row < total ~/ 7; row++)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Builder(builder: (_) {
                      final date = start.add(Duration(days: row * 7 + col));
                      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      return Expanded(
                        child: DayCell(
                          date: date,
                          tithi: days[key],
                          outsideMonth: date.month != month.month,
                          isToday: date.year == today.year && date.month == today.month && date.day == today.day,
                        ),
                      );
                    }),
                ],
              ),
            ),
          Gap.sm,
          _Legend(),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget item(Widget dot, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [dot, const SizedBox(width: 5), Text(label, style: AppTypography.caption.copyWith(color: c.ink3))],
        );
    Widget dot(Color color, {double size = 8, bool hollow = false}) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hollow ? null : color,
            border: hollow ? Border.all(color: color, width: 1.5) : null,
          ),
        );
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        item(dot(c.accent), 'Today'),
        item(dot(c.rose), 'Agiyaras'),
        item(dot(c.brandText), 'Punam'),
        item(dot(c.ink3, hollow: true), 'Amas'),
        item(dot(c.accent, size: 5), 'Utsav'),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../domain/tithi_day.dart';

/// Date number + tithi label; colour encodes today / Agiyaras / Punam / Amas / utsav.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.date,
    required this.tithi,
    required this.outsideMonth,
    required this.isToday,
  });

  final DateTime date;
  final TithiDay? tithi;
  final bool outsideMonth;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = tithi;
    final ek = t?.isEkadashi ?? false;

    final Color bg = isToday
        ? c.accent
        : ek
            ? c.roseSoft
            : Colors.transparent;
    final Color numColor = isToday
        ? c.onAccent
        : ek
            ? c.rose
            : c.ink;
    final Color labelColor = isToday
        ? c.onAccent.withValues(alpha: .8)
        : ek
            ? c.rose
            : c.ink3;

    return Opacity(
      opacity: outsideMonth ? .45 : 1,
      child: Container(
        height: AppSizes.dayCell,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.r(AppRadius.md)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: AppTypography.titleSmall.copyWith(
                    height: 1,
                    color: numColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  t?.shortLabel ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: AppTypography.caption.copyWith(
                    fontSize: 9.5,
                    height: 1,
                    fontWeight: ek ? FontWeight.w700 : FontWeight.w400,
                    color: labelColor,
                  ),
                ),
              ],
            ),
            if (t != null && (t.isPunam || t.isAmas))
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.isPunam ? c.brandText : null,
                    border: t.isAmas ? Border.all(color: c.ink3, width: 1.5) : null,
                  ),
                ),
              ),
            if (t?.hasUtsav ?? false)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? c.onAccent : c.accent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

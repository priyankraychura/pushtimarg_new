import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/tithi_day.dart';

/// Rose date block · Ekadashi name · tithi/weekday · reminder bell.
class EkadashiTile extends StatefulWidget {
  const EkadashiTile({super.key, required this.day, this.highlight = false});
  final TithiDay day;
  final bool highlight;

  @override
  State<EkadashiTile> createState() => _EkadashiTileState();
}

class _EkadashiTileState extends State<EkadashiTile> {
  late bool _remind = widget.highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = widget.day;
    final now = DateTime.now();
    final daysTo = DateTime(d.date.year, d.date.month, d.date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    return AppCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      borderColor: widget.highlight ? c.rose : null,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: c.roseSoft, borderRadius: AppRadius.r(13)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${d.date.day}', style: AppTypography.titleLarge.copyWith(fontSize: 20, height: 1, color: c.rose)),
                const SizedBox(height: 3),
                Text(DateFormat('MMM').format(d.date).toUpperCase(),
                    style: AppTypography.overline.copyWith(fontSize: 10.5, letterSpacing: .8, color: c.rose)),
              ],
            ),
          ),
          Gap.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(d.ekadashiName ?? 'Agiyaras',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(color: c.ink)),
                    ),
                    if (widget.highlight) ...[
                      Gap.sm,
                      AppTag(daysTo == 0 ? 'today' : 'in $daysTo days', tone: AppChipTone.rose),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: AppTypography.caption.copyWith(fontSize: 12.5, color: c.ink2),
                    children: [
                      TextSpan(text: d.fullLabel),
                      TextSpan(text: ' · ${DateFormat('EEEE').format(d.date)}', style: TextStyle(color: c.ink3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap.sm,
          AppIconButton(
            icon: _remind ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
            size: 36,
            iconSize: 17,
            background: _remind ? c.accentSoft : c.surface2,
            color: _remind ? c.accent : c.ink3,
            onTap: () => setState(() => _remind = !_remind),
          ),
        ],
      ),
    );
  }
}

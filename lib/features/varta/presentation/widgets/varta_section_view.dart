import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/gujarati_digits.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/varta.dart';
import '../varta_reader_screen.dart';

/// One vaishnav's varta laid out for reading: heading card, each prasang
/// under a marigold "પ્રસંગ ૧" marker, then the સાર points and notes.
class VartaSectionView extends StatelessWidget {
  const VartaSectionView({
    super.key,
    required this.sectionIndex,
    required this.section,
    required this.textScale,
    required this.prasangKeys,
  });

  final int sectionIndex;
  final VartaSection section;
  final double textScale;

  /// Shared with the screen so the jump strip can find each prasang.
  final Map<PrasangRef, GlobalKey> prasangKeys;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final body = AppTypography.gujarati(AppTypography.bodyLarge)
        .copyWith(fontSize: 17 * textScale, height: 1.75, color: c.ink);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          radius: AppRadius.xl,
          color: c.accentSoft,
          borderColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Text(
            section.title,
            style: AppTypography.gujaratiTitle.copyWith(fontSize: 15 * textScale, height: 1.5, color: c.accentInk),
          ),
        ),
        Gap.xl,
        for (final p in section.prasangs) ...[
          Column(
            key: prasangKeys[PrasangRef(sectionIndex, p.number)],
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'પ્રસંગ ${gujaratiDigits(p.number)}',
                style: AppTypography.gujarati(AppTypography.overline)
                    .copyWith(fontSize: 13, letterSpacing: 1, color: c.accentInk),
              ),
              Gap.sm,
              for (var i = 0; i < p.paragraphs.length; i++) ...[
                Text(p.paragraphs[i], style: body),
                if (i < p.paragraphs.length - 1) Gap.md,
              ],
            ],
          ),
          Gap.xl,
        ],
        if (section.saar.isNotEmpty) ...[
          AppCard(
            radius: AppRadius.card,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'સાર',
                  style: AppTypography.gujaratiTitle.copyWith(fontSize: 17 * textScale, color: c.ink),
                ),
                Gap.md,
                for (var i = 0; i < section.saar.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${gujaratiDigits(i + 1)}.',
                          style: body.copyWith(
                            fontSize: 15 * textScale,
                            color: c.accentInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(section.saar[i], style: body.copyWith(fontSize: 15 * textScale, height: 1.6)),
                      ),
                    ],
                  ),
                  if (i < section.saar.length - 1) Gap.sm,
                ],
              ],
            ),
          ),
          Gap.xl,
        ],
        for (final n in section.notes) ...[
          Text(
            n,
            style: body.copyWith(fontSize: 15 * textScale, height: 1.6, color: c.ink2),
          ),
          Gap.md,
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../providers/home_providers.dart';

/// Ashtachhap poet monograms in a horizontal row.
class PoetsRow extends StatelessWidget {
  const PoetsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.pageH,
        itemCount: ashtachhapPoets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final (mono, name) = ashtachhapPoets[i];
          final warm = i.isOdd;
          return SizedBox(
            width: 64,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2),
                    boxShadow: [BoxShadow(color: c.line, spreadRadius: 1)],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: warm ? [c.accent, c.rose] : [c.brand, c.rose],
                    ),
                  ),
                  child: Text(mono, style: AppTypography.displaySmall.copyWith(fontSize: 20, color: c.brandInk)),
                ),
                Gap.xs,
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTypography.caption.copyWith(height: 1.2, color: c.ink2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

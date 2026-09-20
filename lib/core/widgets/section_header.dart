import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// "Aaj ni seva  ashtayam            Full timeline" — the row above each
/// Home section and the Agiyaras list.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: AppSpacing.pageH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: AppTypography.titleLarge.copyWith(color: c.ink)),
          if (subtitle != null) ...[
            Gap.xs,
            Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: c.ink3)),
          ],
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(fontSize: 13, color: c.accentInk),
              ),
            ),
        ],
      ),
    );
  }
}

/// Uppercase group label used on Settings ("READING", "SEVA").
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.sm),
        child: Text(label.toUpperCase(), style: AppTypography.overline.copyWith(color: context.colors.ink3)),
      );
}

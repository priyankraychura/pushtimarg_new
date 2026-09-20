import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// Pill chip used for filters (Bhajans), script toggles and metadata tags.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.tone = AppChipTone.neutral,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final AppChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final (Color bg, Color fg, Color border) = selected
        ? (c.brand, c.brandInk, c.brand)
        : switch (tone) {
            AppChipTone.neutral => (c.surface, c.ink2, c.line),
            AppChipTone.accent => (c.accentSoft, c.accentInk, Colors.transparent),
            AppChipTone.rose => (c.roseSoft, c.rose, Colors.transparent),
            AppChipTone.brand => (c.surface2, c.brandText, Colors.transparent),
          };

    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.r(AppRadius.pill),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, Gap.xs],
                Text(label, style: AppTypography.labelMedium.copyWith(fontSize: 13, color: fg)),
                if (trailing != null) ...[Gap.xs, trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AppChipTone { neutral, accent, rose, brand }

/// Tiny inline tag ("Aarti", "Pad") shown next to a bhajan title.
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key, this.tone = AppChipTone.brand});

  final String label;
  final AppChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      AppChipTone.accent => (c.accentSoft, c.accentInk),
      AppChipTone.rose => (c.roseSoft, c.rose),
      _ => (c.surface2, c.brandText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.r(AppRadius.xs)),
      child: Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

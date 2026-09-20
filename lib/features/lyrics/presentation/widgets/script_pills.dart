import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../bhajans/domain/bhajan.dart';

/// ગુજરાતી / हिन्दी / English glass pills; active one is solid white.
class ScriptPills extends StatelessWidget {
  const ScriptPills({super.key, required this.available, required this.selected, required this.onSelect});

  final List<Script> available;
  final Script selected;
  final ValueChanged<Script> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        for (final s in available)
          _Pill(label: s.label, on: s == selected, onTap: () => onSelect(s)),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.white.withValues(alpha: .12),
          border: Border.all(color: on ? Colors.white : Colors.white.withValues(alpha: .18)),
          borderRadius: AppRadius.r(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: on ? AppPalette.readerMid : Colors.white.withValues(alpha: .72),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';

/// A group card holding [SettingsRow]s separated by hairlines.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupLabel(label),
          AppCard(
            padding: EdgeInsets.zero,
            radius: AppRadius.xxl,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(color: c.line),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon tile · label (+ optional description) · trailing value/chevron/switch.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.value,
    this.trailing,
    this.onTap,
    this.tone = IconTileTone.brand,
    this.chevron = true,
  });

  /// Switch variant.
  SettingsRow.toggle({
    super.key,
    required this.icon,
    required this.label,
    required bool value,
    required ValueChanged<bool> onChanged,
    this.description,
    this.tone = IconTileTone.brand,
  })  : value = null,
        onTap = (() => onChanged(!value)),
        chevron = false,
        trailing = Switch.adaptive(value: value, onChanged: onChanged);

  final IconData icon;
  final String label;
  final String? description;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final IconTileTone tone;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            IconTile(icon: icon, size: AppSizes.settingsIcon, tone: tone),
            Gap.md,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleSmall.copyWith(color: c.ink)),
                  if (description != null)
                    Text(description!, style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3)),
                ],
              ),
            ),
            Gap.md,
            if (trailing != null)
              trailing!
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null)
                    Text(value!, style: AppTypography.bodySmall.copyWith(fontSize: 13.5, color: c.ink2)),
                  if (chevron) ...[
                    Gap.xxs,
                    Icon(Icons.chevron_right_rounded, size: 18, color: c.ink3),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// Search field used on Home and Bhajans. When [onTap] is given the field is
/// a tappable placeholder (Home) instead of a live input (Bhajans).
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.hint = 'Search by title, first line, or poet',
    this.onTap,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.elevated = false,
    this.trailing,
    this.heroTag,
  });

  /// Shared by Home and the search screen so the bar flies between them.
  static const String homeHeroTag = 'home-search-bar';

  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Adds the drop shadow used when the bar overlaps the header band.
  final bool elevated;
  final Widget? trailing;

  /// When set, the bar is wrapped in a [Hero] with this tag.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final bar = _build(context);
    if (heroTag == null) return bar;
    return Hero(
      tag: heroTag!,
      // Keep text styled during the flight (a Hero flies outside its Scaffold).
      child: Material(type: MaterialType.transparency, child: bar),
    );
  }

  Widget _build(BuildContext context) {
    final c = context.colors;
    final decoration = BoxDecoration(
      color: c.surface,
      borderRadius: AppRadius.r(AppRadius.xl),
      border: Border.all(color: c.line),
      boxShadow: elevated
          ? [BoxShadow(color: c.ink.withValues(alpha: .18), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -12)]
          : const [],
    );

    final scriptToggle = trailing ??
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: c.surface2, borderRadius: AppRadius.r(AppRadius.xs)),
          child: Text('ગુ / EN', style: AppTypography.caption.copyWith(color: c.ink2)),
        );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r(AppRadius.xl),
          child: Container(
            decoration: decoration,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: c.ink3),
                Gap.md,
                Expanded(child: Text(hint, style: AppTypography.bodyMedium.copyWith(color: c.ink3))),
                scriptToggle,
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: c.ink3),
          Gap.md,
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              style: AppTypography.bodyMedium.copyWith(color: c.ink),
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          scriptToggle,
        ],
      ),
    );
  }
}

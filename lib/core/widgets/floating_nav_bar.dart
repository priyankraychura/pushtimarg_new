import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

class NavItem {
  const NavItem({required this.label, required this.icon, required this.activeIcon});
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// The floating pill nav from the mockups. Place it in `Scaffold.bottomNavigationBar`
/// wrapped in a transparent container, or in a Stack over the body.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, context.safe.bottom + 14),
      child: Container(
        height: AppSizes.navHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: AppRadius.r(AppRadius.pill),
          border: Border.all(color: c.line),
          boxShadow: [
            BoxShadow(
              color: c.ink.withValues(alpha: c.isDark ? .6 : .18),
              blurRadius: 28,
              offset: const Offset(0, 12),
              spreadRadius: -10,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / items.length;
            return Stack(
              children: [
                // One highlight pill that slides to the selected tab.
                AnimatedPositioned(
                  duration: AppMotion.slow,
                  curve: AppMotion.emphasized,
                  left: slot * currentIndex,
                  top: 0,
                  bottom: 0,
                  width: slot,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      borderRadius: AppRadius.r(AppRadius.pill),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          selected: i == currentIndex,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.accentInk : c.ink3;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon pops slightly and cross-fades outline → filled.
          AnimatedScale(
            scale: selected ? 1.12 : 1,
            duration: AppMotion.normal,
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.standard,
              switchOutCurve: AppMotion.standard,
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: 22,
                color: selected ? c.accent : fg,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            style: AppTypography.caption.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: fg,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

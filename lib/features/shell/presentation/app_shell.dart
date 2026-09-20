import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';

/// Hosts the four tabs behind the floating nav. The nav sits in a Stack over
/// the body so each tab's scroll view can run underneath it.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    NavItem(label: 'Bhajans', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded),
    NavItem(label: 'Favourites', icon: Icons.favorite_outline_rounded, activeIcon: Icons.favorite_rounded),
    NavItem(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: FloatingNavBar(
        items: _items,
        currentIndex: shell.currentIndex,
        onSelect: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

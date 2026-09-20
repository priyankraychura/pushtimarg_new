import 'package:flutter/material.dart';

import '../../features/bhajans/domain/bhajan.dart';
import '../theme/theme.dart';
import 'app_avatar.dart';

/// One icon + tone per category, so the browse grid and bhajan rows match.
extension BhajanCategoryIcon on BhajanCategory {
  IconData get icon => switch (this) {
        BhajanCategory.aarti => Icons.local_fire_department_outlined,
        BhajanCategory.kirtan => Icons.music_note_outlined,
        BhajanCategory.pad => Icons.auto_stories_outlined,
        BhajanCategory.varta => Icons.spa_outlined,
      };

  IconTileTone get tone => switch (this) {
        BhajanCategory.aarti || BhajanCategory.varta => IconTileTone.accent,
        BhajanCategory.kirtan => IconTileTone.brand,
        BhajanCategory.pad => IconTileTone.rose,
      };
}

/// Tinted square with the category icon — the leading element of a bhajan row.
class CategoryTile extends StatelessWidget {
  const CategoryTile(this.category, {super.key, this.size = AppSizes.ragaTile});

  final BhajanCategory category;
  final double size;

  @override
  Widget build(BuildContext context) => IconTile(icon: category.icon, tone: category.tone, size: size);
}

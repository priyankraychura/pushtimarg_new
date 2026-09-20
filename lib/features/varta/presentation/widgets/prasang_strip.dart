import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/varta.dart';
import '../varta_reader_screen.dart';

/// Pinned row of prasang-number chips ("૧ ૨ ૩ …"). With more than one
/// section the groups are separated by a hairline so the second vaishnav's
/// "૧" is not mistaken for the first's.
class PrasangStripDelegate extends SliverPersistentHeaderDelegate {
  PrasangStripDelegate({required this.sections, required this.refs, required this.onTap, required this.background});

  final List<VartaSection> sections;
  final List<PrasangRef> refs;
  final ValueChanged<PrasangRef> onTap;
  final Color background;

  static const double height = 48;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = context.colors;
    return Container(
      height: height,
      color: background,
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.pageH,
        itemCount: refs.length,
        separatorBuilder: (_, i) => refs[i].section != refs[i + 1].section
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: VerticalDivider(width: 1, indent: 12, endIndent: 12, color: c.line),
              )
            : Gap.xs,
        itemBuilder: (_, i) => Center(
          child: AppChip(
            label: refs[i].label,
            tone: refs[i].section.isEven ? AppChipTone.brand : AppChipTone.accent,
            onTap: () => onTap(refs[i]),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant PrasangStripDelegate old) =>
      old.refs != refs || old.background != background || old.sections != sections;
}

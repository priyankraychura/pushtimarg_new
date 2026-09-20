import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// 44×44 tinted square showing the raga name in the display face — the
/// leading element of every bhajan row.
class RagaTile extends StatelessWidget {
  const RagaTile(this.raga, {super.key, this.size = AppSizes.ragaTile});

  final String raga;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.surface2, borderRadius: AppRadius.r(AppRadius.md)),
      child: Text(
        _split(raga),
        textAlign: TextAlign.center,
        maxLines: 2,
        style: AppTypography.displaySmall.copyWith(fontSize: 12.5, height: 1.05, color: c.brandText),
      ),
    );
  }

  /// "Bhairav" → "Bhai\nrav" so long names fit the square like the mockup.
  static String _split(String s) {
    if (s.length <= 5) return s;
    final cut = (s.length / 2).ceil();
    return '${s.substring(0, cut)}\n${s.substring(cut)}';
  }
}

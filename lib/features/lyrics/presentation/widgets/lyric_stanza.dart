import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../bhajans/domain/bhajan.dart';

/// One shloka: marigold "॥ ૩ ॥" marker + its lines. The current line is
/// white, siblings in the current stanza are soft, everything else faded.
class LyricStanza extends StatelessWidget {
  const LyricStanza({
    super.key,
    required this.index,
    required this.lines,
    required this.firstLineIndex,
    required this.currentLine,
    required this.textScale,
    required this.script,
    required this.lineKeys,
  });

  final int index;
  final List<String> lines;
  final int firstLineIndex;
  final int currentLine;
  final double textScale;
  final Script script;

  /// Shared map so the screen can find a line's RenderBox for scroll tracking.
  final Map<int, GlobalKey> lineKeys;

  static const _white = Colors.white;
  static const _soft = Color(0xB8FFFFFF); // 72%
  static const _dim = Color(0x6BFFFFFF); // 42%

  @override
  Widget build(BuildContext context) {
    final lastLine = firstLineIndex + lines.length - 1;
    final isCurrentStanza = currentLine >= firstLineIndex && currentLine <= lastLine;

    final base = switch (script) {
      Script.gujarati => AppTypography.lyric,
      Script.hindi => AppTypography.lyricHindi,
      Script.english => AppTypography.lyricEnglish,
    };
    final style = base.copyWith(fontSize: AppTypography.lyric.fontSize! * textScale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '॥ ${_gujaratiDigits(index + 1)} ॥',
          style: AppTypography.overline.copyWith(fontSize: 12, letterSpacing: 2, color: AppPalette.marigold),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < lines.length; i++) ...[
          AnimatedDefaultTextStyle(
            key: lineKeys.putIfAbsent(firstLineIndex + i, GlobalKey.new),
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            style: style.copyWith(
              color: firstLineIndex + i == currentLine
                  ? _white
                  : isCurrentStanza
                      ? _soft
                      : _dim,
            ),
            child: Text(lines[i]),
          ),
          if (i < lines.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  static String _gujaratiDigits(int n) {
    const digits = ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'];
    return n.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}

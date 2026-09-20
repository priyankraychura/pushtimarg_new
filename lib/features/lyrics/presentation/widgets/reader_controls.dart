import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Frosted control pill: text size · Auto-scroll. With [onToggleAutoScroll]
/// null (setting off) it collapses to just the text-size button.
class ReaderControls extends StatelessWidget {
  const ReaderControls({
    super.key,
    required this.autoScrolling,
    required this.textScale,
    required this.onToggleAutoScroll,
    required this.onTextScale,
  });

  final bool autoScrolling;
  final double textScale;
  final VoidCallback? onToggleAutoScroll;
  final ValueChanged<double> onTextScale;

  @override
  Widget build(BuildContext context) {
    final pill = ClipRRect(
      borderRadius: AppRadius.r(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPalette.readerBottom.withValues(alpha: .72),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
            borderRadius: AppRadius.r(AppRadius.pill),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .6),
                blurRadius: 36,
                offset: const Offset(0, 16),
                spreadRadius: -14,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GlassButton(icon: Icons.format_size_rounded, onTap: () => _showTextSize(context)),
              if (onToggleAutoScroll != null) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: onToggleAutoScroll,
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      height: 44,
                      decoration: BoxDecoration(
                        color: autoScrolling ? Colors.white : AppPalette.marigold,
                        borderRadius: AppRadius.r(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            autoScrolling ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 20,
                            color: AppPalette.onMarigold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            autoScrolling ? 'Pause' : 'Auto-scroll',
                            style: AppTypography.labelLarge.copyWith(color: AppPalette.onMarigold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    // Full-width pill with Auto-scroll; a compact one floating right without.
    return onToggleAutoScroll != null ? pill : Align(alignment: Alignment.centerRight, child: pill);
  }

  void _showTextSize(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.readerMid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (_) => _TextSizeSheet(value: textScale, onChanged: onTextScale),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22, color: Colors.white)),
      ),
    );
  }
}

class _TextSizeSheet extends StatefulWidget {
  const _TextSizeSheet({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_TextSizeSheet> createState() => _TextSizeSheetState();
}

class _TextSizeSheetState extends State<_TextSizeSheet> {
  late double _v = widget.value;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Text size', style: AppTypography.titleLarge.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              'નમામિ યમુનામહં સકલ સિદ્ધિ હેતું મુદા',
              style: AppTypography.lyric.copyWith(fontSize: AppTypography.lyric.fontSize! * _v, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('A', style: AppTypography.labelMedium.copyWith(color: Colors.white70)),
                Expanded(
                  child: Slider(
                    value: _v,
                    min: .8,
                    max: 1.6,
                    divisions: 8,
                    activeColor: AppPalette.marigold,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      setState(() => _v = v);
                      widget.onChanged(v);
                    },
                  ),
                ),
                Text('A', style: AppTypography.titleLarge.copyWith(fontSize: 20, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

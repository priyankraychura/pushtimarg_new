import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/gujarati_digits.dart';
import '../../../core/utils/keep_awake.dart';
import '../../../core/widgets/widgets.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/varta.dart';
import '../providers/varta_providers.dart';
import 'widgets/prasang_strip.dart';
import 'widgets/varta_section_view.dart';

/// Prose reader for one varta. Unlike the lyrics reader this stays on the
/// light surface — vartas are long paragraphs, not sung lines — with a
/// pinned strip of prasang numbers to jump around.
class VartaReaderScreen extends ConsumerStatefulWidget {
  const VartaReaderScreen({super.key, required this.vartaId});
  final String vartaId;

  @override
  ConsumerState<VartaReaderScreen> createState() => _VartaReaderScreenState();
}

class _VartaReaderScreenState extends ConsumerState<VartaReaderScreen> {
  /// One key per (section, prasang) so the strip can scroll to it.
  final _prasangKeys = <PrasangRef, GlobalKey>{};
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (ref.read(settingsProvider).keepAwake) KeepAwake.set(true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    KeepAwake.set(false);
    super.dispose();
  }

  /// Scrolls so the prasang heading sits just below the pinned strip.
  /// (`Scrollable.ensureVisible` ignores pinned headers and would park the
  /// heading underneath it.)
  void _jumpTo(PrasangRef p) {
    final ctx = _prasangKeys[p]?.currentContext;
    if (ctx == null || !_scroll.hasClients) return;
    final box = ctx.findRenderObject()!;
    final reveal = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset;
    final target = (reveal - PrasangStripDelegate.height - AppSpacing.sm).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(target, duration: AppMotion.slow, curve: AppMotion.standard);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final varta = ref.watch(vartaByIdProvider(widget.vartaId));
    final textScale = ref.watch(settingsProvider.select((s) => s.textScale));
    ref.listen(settingsProvider.select((s) => s.keepAwake), (_, on) => KeepAwake.set(on));

    return Scaffold(
      body: varta.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text('Could not load.', style: AppTypography.bodyMedium.copyWith(color: c.ink3)),
        ),
        data: (v) => v == null
            ? Center(
                child: Text('Varta not found.', style: AppTypography.bodyMedium.copyWith(color: c.ink3)),
              )
            : _reader(v, textScale),
      ),
    );
  }

  Widget _reader(Varta v, double textScale) {
    final c = context.colors;
    final refs = [
      for (var s = 0; s < v.sections.length; s++)
        for (final p in v.sections[s].prasangs) PrasangRef(s, p.number),
    ];
    for (final r in refs) {
      _prasangKeys.putIfAbsent(r, GlobalKey.new);
    }

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: context.safe.top + 8, left: AppSpacing.md, right: AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 20,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Gap.xs,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.gujaratiTitle.copyWith(color: c.ink),
                      ),
                      Text(
                        'Varta ${v.number} · ${v.collection.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(fontSize: 11.5, color: c.ink3),
                      ),
                    ],
                  ),
                ),
                AppIconButton(icon: Icons.format_size_rounded, onTap: () => _showTextSize(context)),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: Gap.sm),
        // Pinned so the jump strip stays reachable deep in a long prasang.
        SliverPersistentHeader(
          pinned: true,
          delegate: PrasangStripDelegate(sections: v.sections, refs: refs, onTap: _jumpTo, background: c.ground),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            context.safe.bottom + AppSpacing.xxxl,
          ),
          // Built eagerly (not a lazy SliverList) so every prasang key has
          // a context and the strip can jump to sections not yet scrolled to.
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var s = 0; s < v.sections.length; s++) ...[
                  VartaSectionView(
                    sectionIndex: s,
                    section: v.sections[s],
                    textScale: textScale,
                    prasangKeys: _prasangKeys,
                  ),
                  if (s < v.sections.length - 1) Gap.xxl,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTextSize(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (_) => const _TextSizeSheet(),
    );
  }
}

/// Slider bound to the same `textScale` setting the lyrics reader uses.
class _TextSizeSheet extends ConsumerWidget {
  const _TextSizeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final v = ref.watch(settingsProvider.select((s) => s.textScale));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Text size', style: AppTypography.titleLarge.copyWith(color: c.ink)),
            Gap.xxs,
            Text('Also applies to lyrics.', style: AppTypography.bodySmall.copyWith(color: c.ink3)),
            Gap.md,
            Row(
              children: [
                Text('અ', style: AppTypography.gujarati(AppTypography.bodySmall).copyWith(color: c.ink3)),
                Expanded(
                  child: Slider(
                    value: v,
                    min: .8,
                    max: 1.6,
                    divisions: 8,
                    activeColor: c.accent,
                    onChanged: ref.read(settingsProvider.notifier).setTextScale,
                  ),
                ),
                Text('અ', style: AppTypography.gujarati(AppTypography.titleLarge).copyWith(fontSize: 22, color: c.ink)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Identifies one prasang inside a varta for keys and the jump strip.
@immutable
class PrasangRef {
  const PrasangRef(this.section, this.number);
  final int section;
  final int number;

  String get label => gujaratiDigits(number);

  @override
  bool operator ==(Object other) => other is PrasangRef && other.section == section && other.number == number;

  @override
  int get hashCode => Object.hash(section, number);
}

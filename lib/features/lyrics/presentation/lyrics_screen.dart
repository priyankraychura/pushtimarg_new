import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/keep_awake.dart';
import '../../bhajans/domain/bhajan.dart';
import '../../bhajans/providers/bhajan_providers.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/providers/settings_providers.dart';
import '../../user/providers/user_data_providers.dart';
import '../providers/lyrics_providers.dart';
import 'widgets/lyric_stanza.dart';
import 'widgets/reader_controls.dart';
import 'widgets/reader_top_bar.dart';
import 'widgets/script_pills.dart';

/// Immersive lyrics view: teal gradient, big lines, current line bright.
/// Pushed from any bhajan row via the lyrics route.
class LyricsScreen extends ConsumerStatefulWidget {
  const LyricsScreen({super.key, required this.bhajanId});
  final String bhajanId;

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  final _scroll = ScrollController();
  final _lineKeys = <int, GlobalKey>{};
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    if (ref.read(settingsProvider).keepAwake) KeepAwake.set(true);

    // Restore last reading position once lyrics are laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(userDataProvider).progress[widget.bhajanId];
      if (saved != null && saved > 0) _jumpToLine(saved);
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _saveDebounce?.cancel();
    _scroll.dispose();
    KeepAwake.set(false);
    super.dispose();
  }

  // ---- auto-scroll -------------------------------------------------------

  void _setAutoScroll(bool on) {
    if (on) {
      _ticker ??= Ticker(_tick);
      _lastTick = Duration.zero;
      _ticker!.start();
    } else {
      _ticker?.stop();
    }
  }

  void _tick(Duration elapsed) {
    if (!_scroll.hasClients) return;
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final speed = ref.read(settingsProvider).autoScroll.pixelsPerSecond;
    final next = _scroll.offset + speed * dt;
    if (next >= _scroll.position.maxScrollExtent) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      ref.read(readerProvider.notifier).stopAutoScroll();
    } else {
      _scroll.jumpTo(next);
    }
  }

  // ---- current line tracking -----------------------------------------------

  void _onScroll() {
    // The "current" line is the first one whose top is below the reading
    // guide (≈35% down the viewport).
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final guide = box.size.height * .35;
    int? current;
    for (final e in _lineKeys.entries) {
      final ctx = e.value.currentContext;
      if (ctx == null) continue;
      final r = ctx.findRenderObject() as RenderBox;
      final y = r.localToGlobal(Offset.zero, ancestor: box).dy;
      if (y <= guide) {
        current = e.key;
      } else {
        break;
      }
    }
    if (current != null) {
      ref.read(readerProvider.notifier).setLine(current);
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: 600), () {
        ref.read(userDataProvider.notifier).setProgress(widget.bhajanId, current!);
      });
    }
  }

  void _jumpToLine(int line) {
    final ctx = _lineKeys[line]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, alignment: .3, duration: AppMotion.slow, curve: AppMotion.standard);
  }

  // ---- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allBhajansProvider);
    final bhajan = ref.watch(bhajanByIdProvider(widget.bhajanId));
    final settings = ref.watch(settingsProvider);
    final reader = ref.watch(readerProvider);

    ref.listen(readerProvider.select((s) => s.autoScrolling), (_, on) => _setAutoScroll(on));
    ref.listen(settingsProvider.select((s) => s.keepAwake), (_, on) => KeepAwake.set(on));

    final script = bhajan != null && !bhajan.has(settings.script) ? Script.gujarati : settings.script;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _background),
        child: Stack(
          children: [
            const Positioned.fill(child: _Glow()),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  ReaderTopBar(
                    title: bhajan?.title ?? '',
                    subtitle: [
                      if (bhajan != null && bhajan.poet.isNotEmpty) bhajan.poet,
                      if (bhajan != null && bhajan.seva.isNotEmpty) bhajan.seva,
                    ].join(' · '),
                    bhajanId: widget.bhajanId,
                  ),
                  Expanded(
                    child: switch ((all, bhajan)) {
                      (AsyncLoading(), _) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                      (AsyncError(), _) => Center(
                          child: Text('Could not load lyrics.', style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
                        ),
                      (_, null) || (_, Bhajan(lyrics: Map(isEmpty: true))) => Center(
                          child: Text('Lyrics coming soon.', style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
                        ),
                      (_, final Bhajan data) => _reader(data, script, settings, reader),
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: context.safe.bottom + 22,
              child: ReaderControls(
                autoScrolling: reader.autoScrolling,
                textScale: settings.textScale,
                onToggleAutoScroll:
                    settings.autoScrollEnabled ? ref.read(readerProvider.notifier).toggleAutoScroll : null,
                onTextScale: ref.read(settingsProvider.notifier).setTextScale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reader(Bhajan data, Script script, AppSettings settings, ReaderState reader) {
    final stanzas = data.stanzasFor(script);
    // Absolute index of each stanza's first line.
    final offsets = <int>[];
    var n = 0;
    for (final s in stanzas) {
      offsets.add(n);
      n += s.length;
    }
    return GestureDetector(
      onTapDown: (_) => ref.read(readerProvider.notifier).stopAutoScroll(),
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 14, AppSpacing.xxl, 200),
        children: [
          ScriptPills(
            available: [for (final s in Script.values) if (data.has(s)) s],
            selected: script,
            onSelect: ref.read(settingsProvider.notifier).setScript,
          ),
          const SizedBox(height: 26),
          for (var i = 0; i < stanzas.length; i++) ...[
            LyricStanza(
              index: i,
              lines: stanzas[i],
              firstLineIndex: offsets[i],
              currentLine: reader.currentLine,
              textScale: settings.textScale,
              script: script,
              lineKeys: _lineKeys,
            ),
            if (i < stanzas.length - 1) const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, .6, 1],
    colors: [AppPalette.readerTop, AppPalette.readerMid, AppPalette.readerBottom],
  );
}

/// Rose + marigold radial glow over the gradient, as on the mockup.
class _Glow extends StatelessWidget {
  const _Glow();

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-.7, -.9),
              radius: 1,
              colors: [AppPalette.rose.withValues(alpha: .32), Colors.transparent],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(1, -.6),
                radius: .9,
                colors: [AppPalette.marigold.withValues(alpha: .22), Colors.transparent],
              ),
            ),
          ),
        ),
      );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../data/lyrics_repository.dart';
import '../domain/lyrics.dart';

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  if (AppConfig.demoMode) return SampleLyricsRepository();
  return FirestoreLyricsRepository(FirebaseFirestore.instance);
});

final lyricsProvider = FutureProvider.family<Lyrics?, String>(
  (ref, id) => ref.watch(lyricsRepositoryProvider).get(id),
);

/// Transient reader state (not persisted): which line is current, whether
/// auto-scroll is running, dim mode.
class ReaderState {
  const ReaderState({this.currentLine = 0, this.autoScrolling = false, this.dim = false});
  final int currentLine;
  final bool autoScrolling;
  final bool dim;

  ReaderState copyWith({int? currentLine, bool? autoScrolling, bool? dim}) => ReaderState(
        currentLine: currentLine ?? this.currentLine,
        autoScrolling: autoScrolling ?? this.autoScrolling,
        dim: dim ?? this.dim,
      );
}

class ReaderNotifier extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  void setLine(int i) {
    if (i != state.currentLine) state = state.copyWith(currentLine: i);
  }

  void toggleAutoScroll() => state = state.copyWith(autoScrolling: !state.autoScrolling);
  void stopAutoScroll() => state = state.copyWith(autoScrolling: false);
  void toggleDim() => state = state.copyWith(dim: !state.dim);
}

final readerProvider = NotifierProvider.autoDispose<ReaderNotifier, ReaderState>(ReaderNotifier.new);

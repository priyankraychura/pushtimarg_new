import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/lyrics_repository.dart';
import '../domain/lyrics.dart';

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  if (ref.watch(useBundledContentProvider)) return SampleLyricsRepository();
  return FirestoreLyricsRepository(FirebaseFirestore.instance);
});

/// Fetched once per bhajan when its reader opens.
final lyricsProvider = FutureProvider.family<Lyrics?, String>(
  (ref, id) => ref.watch(lyricsRepositoryProvider).get(id),
);

/// Transient reader state (not persisted): which line is current, whether
/// auto-scroll is running.
class ReaderState {
  const ReaderState({this.currentLine = 0, this.autoScrolling = false});
  final int currentLine;
  final bool autoScrolling;

  ReaderState copyWith({int? currentLine, bool? autoScrolling}) => ReaderState(
        currentLine: currentLine ?? this.currentLine,
        autoScrolling: autoScrolling ?? this.autoScrolling,
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
}

final readerProvider = NotifierProvider.autoDispose<ReaderNotifier, ReaderState>(ReaderNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transient reader state (not persisted): which line is current, whether
/// auto-scroll is running. Lyrics themselves live on `Bhajan`.
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

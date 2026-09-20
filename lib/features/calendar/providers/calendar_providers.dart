import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../data/tithi_repository.dart';
import '../domain/tithi_day.dart';

final tithiRepositoryProvider = Provider<TithiRepository>((ref) {
  if (AppConfig.demoMode) return SampleTithiRepository();
  return FirestoreTithiRepository(FirebaseFirestore.instance);
});

/// (year, month) currently shown in the calendar.
class VisibleMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void next() => state = DateTime(state.year, state.month + 1);
  void previous() => state = DateTime(state.year, state.month - 1);
  void today() => build();
}

final visibleMonthProvider = NotifierProvider<VisibleMonth, DateTime>(VisibleMonth.new);

final monthTithiProvider = FutureProvider.family<Map<String, TithiDay>, DateTime>((ref, month) async {
  final days = await ref.watch(tithiRepositoryProvider).month(month.year, month.month);
  return {for (final d in days) d.key: d};
});

final todayTithiProvider = FutureProvider<TithiDay?>((ref) async {
  final now = DateTime.now();
  final map = await ref.watch(monthTithiProvider(DateTime(now.year, now.month)).future);
  return map['${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'];
});

final upcomingEkadashiProvider = FutureProvider<List<TithiDay>>(
  (ref) => ref.watch(tithiRepositoryProvider).upcomingEkadashi(DateTime.now()),
);

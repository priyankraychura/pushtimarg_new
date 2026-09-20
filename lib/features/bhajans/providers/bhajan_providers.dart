import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../data/bhajan_repository.dart';
import '../domain/bhajan.dart';

final bhajanRepositoryProvider = Provider<BhajanRepository>((ref) {
  if (AppConfig.demoMode) return SampleBhajanRepository();
  return FirestoreBhajanRepository(FirebaseFirestore.instance);
});

/// Full list, cached for the session. Filtering/sorting happens on-device.
final allBhajansProvider = StreamProvider<List<Bhajan>>(
  (ref) => ref.watch(bhajanRepositoryProvider).watchAll(),
);

final bhajanByIdProvider = Provider.family<Bhajan?, String>((ref, id) {
  final list = ref.watch(allBhajansProvider).value ?? const [];
  for (final b in list) {
    if (b.id == id) return b;
  }
  return null;
});

enum BhajanSort { az, seva, poet }

/// Filter + sort state for the Bhajans screen.
class BhajanFilter {
  const BhajanFilter({this.category, this.query = '', this.sort = BhajanSort.az});
  final BhajanCategory? category;
  final String query;
  final BhajanSort sort;

  BhajanFilter copyWith({
    BhajanCategory? Function()? category,
    String? query,
    BhajanSort? sort,
  }) =>
      BhajanFilter(
        category: category != null ? category() : this.category,
        query: query ?? this.query,
        sort: sort ?? this.sort,
      );
}

class BhajanFilterNotifier extends Notifier<BhajanFilter> {
  @override
  BhajanFilter build() => const BhajanFilter();

  void setCategory(BhajanCategory? c) => state = state.copyWith(category: () => c);
  void setQuery(String q) => state = state.copyWith(query: q);
  void setSort(BhajanSort s) => state = state.copyWith(sort: s);
}

final bhajanFilterProvider =
    NotifierProvider<BhajanFilterNotifier, BhajanFilter>(BhajanFilterNotifier.new);

final filteredBhajansProvider = Provider<List<Bhajan>>((ref) {
  final all = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];
  final f = ref.watch(bhajanFilterProvider);
  final list = all
      .where((b) => f.category == null || b.category == f.category)
      .where((b) => b.matches(f.query))
      .toList();
  switch (f.sort) {
    case BhajanSort.az:
      list.sort((a, b) => a.titleEn.compareTo(b.titleEn));
    case BhajanSort.seva:
      list.sort((a, b) => a.primarySeva.compareTo(b.primarySeva));
    case BhajanSort.poet:
      list.sort((a, b) => a.poet.compareTo(b.poet));
  }
  return list;
});

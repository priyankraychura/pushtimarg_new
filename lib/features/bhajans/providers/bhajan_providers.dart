import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/bhajan_repository.dart';
import '../data/yamunaji_41_pad_bhajans.dart';
import '../domain/bhajan.dart';

final bhajanRepositoryProvider = Provider<BhajanRepository>((ref) {
  if (ref.watch(useBundledContentProvider)) return SampleBhajanRepository();
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

/// શ્રી યમુનાજીનાં ૪૧ પદ, in granth order (pad 1 → 41) — what the Pad screen
/// shows. Empty until [allBhajansProvider] has loaded.
final yamunaji41PadsProvider = Provider<List<Bhajan>>((ref) {
  final all = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];
  return all.where((b) => b.category == BhajanCategory.pad && b.tags.contains(yamunajiPadTag)).toList()
    ..sort((a, b) => yamunajiPadNumber(a.id).compareTo(yamunajiPadNumber(b.id)));
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
      list.sort((a, b) => a.title.compareTo(b.title));
    case BhajanSort.seva:
      list.sort((a, b) => a.seva.compareTo(b.seva));
    case BhajanSort.poet:
      list.sort((a, b) => a.poet.compareTo(b.poet));
  }
  return list;
});

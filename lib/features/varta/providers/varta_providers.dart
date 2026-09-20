import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../data/varta_repository.dart';
import '../domain/varta.dart';
import '../domain/varta_collection.dart';

final vartaRepositoryProvider = Provider<VartaRepository>((ref) {
  if (AppConfig.demoMode) return SampleVartaRepository();
  return FirestoreVartaRepository(FirebaseFirestore.instance);
});

/// All vartas of one granth, cached for the session.
final vartasProvider = StreamProvider.family<List<Varta>, VartaCollection>(
  (ref, collection) => ref.watch(vartaRepositoryProvider).watchCollection(collection),
);

/// One varta by id — from the granth list if it is already loaded, else a
/// single fetch (deep link straight into the reader).
final vartaByIdProvider = FutureProvider.family<Varta?, String>((ref, id) async {
  for (final c in VartaCollection.values) {
    final loaded = ref.watch(vartasProvider(c)).value;
    if (loaded == null) continue;
    for (final v in loaded) {
      if (v.id == id) return v;
    }
  }
  return ref.watch(vartaRepositoryProvider).getById(id);
});

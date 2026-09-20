import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/varta.dart';
import '../domain/varta_collection.dart';
import 'sample_vartas.dart';

/// Read-side contract for vartas: Firestore in production, bundled sample
/// data in demo mode/tests.
abstract interface class VartaRepository {
  /// Vartas of one granth in granth order (by [Varta.number]).
  Stream<List<Varta>> watchCollection(VartaCollection collection);
  Future<Varta?> getById(String id);
}

class FirestoreVartaRepository implements VartaRepository {
  FirestoreVartaRepository(FirebaseFirestore db) : _col = db.collection('vartas');

  final CollectionReference<Map<String, dynamic>> _col;

  // Sorted on-device: `where` + `orderBy('number')` would need a composite
  // index, and a granth is at most 252 docs.
  @override
  Stream<List<Varta>> watchCollection(VartaCollection collection) => _col
      .where('collection', isEqualTo: collection.name)
      .snapshots()
      .map(
        (s) => s.docs.map((d) => Varta.fromMap(d.id, d.data())).toList()..sort((a, b) => a.number.compareTo(b.number)),
      );

  @override
  Future<Varta?> getById(String id) async {
    final doc = await _col.doc(id).get();
    final data = doc.data();
    return data == null ? null : Varta.fromMap(doc.id, data);
  }
}

class SampleVartaRepository implements VartaRepository {
  @override
  Stream<List<Varta>> watchCollection(VartaCollection collection) => Stream.value(
    sampleVartas.where((v) => v.collection == collection).toList()..sort((a, b) => a.number.compareTo(b.number)),
  );

  @override
  Future<Varta?> getById(String id) async {
    for (final v in sampleVartas) {
      if (v.id == id) return v;
    }
    return null;
  }
}

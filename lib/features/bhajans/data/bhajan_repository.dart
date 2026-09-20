import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/bhajan.dart';
import 'sample_bhajans.dart';

/// Read-side contract for bhajan metadata. Two implementations:
/// Firestore for production, in-memory sample data for demo mode/tests.
abstract interface class BhajanRepository {
  Stream<List<Bhajan>> watchAll();
  Future<Bhajan?> getById(String id);
}

class FirestoreBhajanRepository implements BhajanRepository {
  FirestoreBhajanRepository(FirebaseFirestore db) : _col = db.collection('bhajans');

  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Stream<List<Bhajan>> watchAll() => _col.orderBy('title_en').snapshots().map(
        (s) => s.docs.map((d) => Bhajan.fromMap(d.id, d.data())).toList(),
      );

  @override
  Future<Bhajan?> getById(String id) async {
    final doc = await _col.doc(id).get();
    final data = doc.data();
    return data == null ? null : Bhajan.fromMap(doc.id, data);
  }
}

class SampleBhajanRepository implements BhajanRepository {
  @override
  Stream<List<Bhajan>> watchAll() => Stream.value(
        [...sampleBhajans]..sort((a, b) => a.titleEn.compareTo(b.titleEn)),
      );

  @override
  Future<Bhajan?> getById(String id) async {
    for (final b in sampleBhajans) {
      if (b.id == id) return b;
    }
    return null;
  }
}

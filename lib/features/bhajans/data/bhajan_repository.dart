import 'package:cloud_firestore/cloud_firestore.dart';

import '../../lyrics/data/sample_lyrics.dart';
import '../domain/bhajan.dart';
import 'sample_bhajans.dart';
import 'search_index.dart';

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
  Stream<List<Bhajan>> watchAll() => _col.orderBy('title').snapshots().map(
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
  /// Same shape as what the seed writes to Firestore: each bhajan carries its
  /// precomputed search text. Built once, on first use.
  static final List<Bhajan> _indexed = [
    for (final b in sampleBhajans) b.withSearch(buildSearchText(b, sampleLyrics[b.id])),
  ]..sort((a, b) => a.title.compareTo(b.title));

  @override
  Stream<List<Bhajan>> watchAll() => Stream.value(_indexed);

  @override
  Future<Bhajan?> getById(String id) async {
    for (final b in _indexed) {
      if (b.id == id) return b;
    }
    return null;
  }
}

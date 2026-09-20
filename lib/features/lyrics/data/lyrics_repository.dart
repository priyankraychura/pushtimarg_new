import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/lyrics.dart';
import 'sample_lyrics.dart';

/// One read per bhajan, by the same id as its `bhajans/{id}` doc.
abstract interface class LyricsRepository {
  Future<Lyrics?> get(String bhajanId);
}

class FirestoreLyricsRepository implements LyricsRepository {
  FirestoreLyricsRepository(FirebaseFirestore db) : _col = db.collection('lyrics');
  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Future<Lyrics?> get(String bhajanId) async {
    final doc = await _col.doc(bhajanId).get();
    final data = doc.data();
    return data == null ? null : Lyrics.fromMap(doc.id, data);
  }
}

class SampleLyricsRepository implements LyricsRepository {
  @override
  Future<Lyrics?> get(String bhajanId) async => sampleLyrics[bhajanId];
}

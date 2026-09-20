import 'package:cloud_firestore/cloud_firestore.dart';

import '../../lyrics/data/sample_lyrics.dart';
import 'sample_bhajans.dart';

/// Writes the bundled sample content to Firestore (`bhajans/` + `lyrics/`).
/// Debug-only helper, triggered from Settings. Safe to re-run: docs are
/// overwritten by id.
Future<int> seedFirestore([FirebaseFirestore? db]) async {
  final fs = db ?? FirebaseFirestore.instance;
  final batch = fs.batch();
  for (final b in sampleBhajans) {
    batch.set(fs.collection('bhajans').doc(b.id), b.toMap());
  }
  for (final l in sampleLyrics.values) {
    batch.set(fs.collection('lyrics').doc(l.bhajanId), l.toMap());
  }
  await batch.commit();
  return sampleBhajans.length;
}

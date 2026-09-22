import 'package:cloud_firestore/cloud_firestore.dart';

import '../../calendar/data/sample_tithi.dart';
import '../../lyrics/data/sample_lyrics.dart';
import '../../varta/data/sample_vartas.dart';
import 'sample_bhajans.dart';
import 'search_index.dart';

/// Syncs Firestore (`bhajans/`, `lyrics/`, `vartas/`, `tithi/`) to the bundled sample
/// content: upserts every sample doc by id and deletes docs that are no
/// longer in the sample set. Debug-only helper, triggered from Settings.
Future<int> seedFirestore([FirebaseFirestore? db]) async {
  final fs = db ?? FirebaseFirestore.instance;
  final bhajans = fs.collection('bhajans');
  final lyrics = fs.collection('lyrics');
  final vartas = fs.collection('vartas');
  final tithi = fs.collection('tithi');
  final keep = {for (final b in sampleBhajans) b.id};
  final keepVartas = {for (final v in sampleVartas) v.id};
  final keepTithi = {for (final d in sampleTithi) d.key};

  final batch = fs.batch();
  for (final b in sampleBhajans) {
    batch.set(bhajans.doc(b.id), b.withSearch(buildSearchText(b, sampleLyrics[b.id])).toMap());
  }
  for (final l in sampleLyrics.values) {
    batch.set(lyrics.doc(l.bhajanId), l.toMap());
  }
  for (final v in sampleVartas) {
    batch.set(vartas.doc(v.id), v.toMap());
  }
  for (final d in sampleTithi) {
    batch.set(tithi.doc(d.key), d.toMap());
  }
  for (final col in [bhajans, lyrics]) {
    for (final d in (await col.get()).docs) {
      if (!keep.contains(d.id)) batch.delete(d.reference);
    }
  }
  for (final d in (await vartas.get()).docs) {
    if (!keepVartas.contains(d.id)) batch.delete(d.reference);
  }
  for (final d in (await tithi.get()).docs) {
    if (!keepTithi.contains(d.id)) batch.delete(d.reference);
  }
  await batch.commit();
  return sampleBhajans.length;
}

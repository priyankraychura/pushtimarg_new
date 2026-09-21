import 'package:cloud_firestore/cloud_firestore.dart';

import 'sample_tithi.dart';

/// Upserts the generated tithi table into `tithi/{yyyy-MM-dd}`.
///
/// Upsert only, never delete: a curated year already in Firestore that the
/// bundled table does not cover is left untouched. Within the covered range each
/// `set` replaces the whole document, so a stale field — an `ekadashi_name` left
/// on a day that is no longer the vrat day — is cleared rather than merged.
///
/// Firestore caps a batch at 500 writes and the table runs to ~730 days, so the
/// write is chunked. A chunk that fails leaves the earlier chunks committed;
/// re-running is safe because every write is an upsert keyed by date.
///
/// Debug-only helper, triggered from Settings. Regenerate the table first with
/// `cd tools/panchang && npm run generate`.
Future<int> seedTithi([FirebaseFirestore? db]) async {
  final fs = db ?? FirebaseFirestore.instance;
  final col = fs.collection('tithi');
  const chunkSize = 400;

  for (var i = 0; i < sampleTithi.length; i += chunkSize) {
    final batch = fs.batch();
    for (final day in sampleTithi.skip(i).take(chunkSize)) {
      batch.set(col.doc(day.key), day.toMap());
    }
    await batch.commit();
  }
  return sampleTithi.length;
}

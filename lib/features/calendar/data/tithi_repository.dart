import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tithi_day.dart';
import 'sample_tithi.dart';

abstract interface class TithiRepository {
  /// All days in [year]-[month] (1–12), plus padding days around it if known.
  Future<List<TithiDay>> month(int year, int month);

  /// Next [count] Ekadashis on/after [from].
  Future<List<TithiDay>> upcomingEkadashi(DateTime from, {int count = 4});
}

/// Picks the next [count] Ekadashi vrat days on/after [from] out of [days].
///
/// Reading [TithiDay.isEkadashi] here rather than filtering on the stored
/// `ekadashi_vrat` field is deliberate — see [FirestoreTithiRepository].
List<TithiDay> pickUpcomingEkadashi(Iterable<TithiDay> days, DateTime from, int count) {
  final start = DateTime(from.year, from.month, from.day);
  return days.where((d) => d.isEkadashi && !d.date.isBefore(start)).take(count).toList();
}

class FirestoreTithiRepository implements TithiRepository {
  FirestoreTithiRepository(FirebaseFirestore db) : _col = db.collection('tithi');
  final CollectionReference<Map<String, dynamic>> _col;

  /// An Ekadashi vrat falls every 10–20 days, so `count` of them fit in this
  /// many days. The window slides forward if a stretch runs longer.
  static const _daysPerEkadashi = 20;
  static const _maxPasses = 3;

  @override
  Future<List<TithiDay>> month(int year, int month) async {
    final start = DateTime(year, month, 1).subtract(const Duration(days: 7));
    final end = DateTime(year, month + 1, 1).add(const Duration(days: 7));
    return _range(start, end);
  }

  /// Reads a forward window of days and picks the vrat days out of it here,
  /// instead of asking Firestore for `ekadashi_vrat == true`.
  ///
  /// The stored-flag query read as the cheaper one but could not work against
  /// the live collection. It needs a composite `(ekadashi_vrat, date)` index
  /// deployed before it returns anything at all — without it every call fails
  /// with `failed-precondition`, which is what left this list spinning — and
  /// even with the index it matches nothing on documents written before the
  /// flag existed, because Firestore skips documents that lack the field.
  /// [TithiDay.isEkadashi] already falls back to the tithi for those, so the
  /// filter belongs on this side. A plain `date` range is served by the
  /// automatic single-field index, exactly like [month].
  @override
  Future<List<TithiDay>> upcomingEkadashi(DateTime from, {int count = 4}) async {
    final found = <TithiDay>[];
    var cursor = DateTime(from.year, from.month, from.day);

    for (var pass = 0; pass < _maxPasses && found.length < count; pass++) {
      final span = count * _daysPerEkadashi;
      final end = cursor.add(Duration(days: span));
      final window = await _range(cursor, end, limit: span);
      if (window.isEmpty) break; // Past the end of the stored table.
      found.addAll(pickUpcomingEkadashi(window, cursor, count - found.length));
      cursor = end;
    }
    return found;
  }

  /// `[start, end)` ordered by date. Single field, so no composite index.
  Future<List<TithiDay>> _range(DateTime start, DateTime end, {int? limit}) async {
    var q = _col
        .where('date', isGreaterThanOrEqualTo: _k(start))
        .where('date', isLessThan: _k(end))
        .orderBy('date');
    if (limit != null) q = q.limit(limit);
    final snap = await q.get();
    return snap.docs.map((d) => TithiDay.fromMap(d.data())).toList();
  }

  static String _k(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class SampleTithiRepository implements TithiRepository {
  @override
  Future<List<TithiDay>> month(int year, int month) async => sampleTithi
      .where((d) =>
          (d.date.year == year && d.date.month == month) ||
          d.date.difference(DateTime(year, month, 1)).inDays.abs() <= 7 ||
          d.date.difference(DateTime(year, month + 1, 0)).inDays.abs() <= 7)
      .toList();

  @override
  Future<List<TithiDay>> upcomingEkadashi(DateTime from, {int count = 4}) async =>
      pickUpcomingEkadashi(sampleTithi, from, count);
}

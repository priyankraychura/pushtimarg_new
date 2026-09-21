import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tithi_day.dart';
import 'sample_tithi.dart';

abstract interface class TithiRepository {
  /// All days in [year]-[month] (1–12), plus padding days around it if known.
  Future<List<TithiDay>> month(int year, int month);

  /// Next [count] Ekadashis on/after [from].
  Future<List<TithiDay>> upcomingEkadashi(DateTime from, {int count = 4});
}

class FirestoreTithiRepository implements TithiRepository {
  FirestoreTithiRepository(FirebaseFirestore db) : _col = db.collection('tithi');
  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Future<List<TithiDay>> month(int year, int month) async {
    final start = DateTime(year, month, 1).subtract(const Duration(days: 7));
    final end = DateTime(year, month + 1, 1).add(const Duration(days: 7));
    final q = await _col
        .where('date', isGreaterThanOrEqualTo: _k(start))
        .where('date', isLessThan: _k(end))
        .orderBy('date')
        .get();
    return q.docs.map((d) => TithiDay.fromMap(d.data())).toList();
  }

  @override
  Future<List<TithiDay>> upcomingEkadashi(DateTime from, {int count = 4}) async {
    // Queries the stored observance flag, not `tithi == 11`: a kshaya Ekadashi
    // is observed on the Dwadashi day, so filtering on the tithi drops a fast.
    final q = await _col
        .where('ekadashi_vrat', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: _k(from))
        .orderBy('date')
        .limit(count)
        .get();
    return q.docs.map((d) => TithiDay.fromMap(d.data())).toList();
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
  Future<List<TithiDay>> upcomingEkadashi(DateTime from, {int count = 4}) async {
    final day = DateTime(from.year, from.month, from.day);
    return sampleTithi
        .where((d) => d.isEkadashi && !d.date.isBefore(day))
        .take(count)
        .toList();
  }
}

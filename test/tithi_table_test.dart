import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/features/calendar/data/sample_tithi.dart';
import 'package:pushti_kirtan/features/calendar/data/tithi_repository.dart';
import 'package:pushti_kirtan/features/calendar/domain/tithi_day.dart';

/// Guards the generated tithi table (`tools/panchang/generate.js`). The generator
/// self-checks before writing, but these tests keep the Dart side honest: the
/// table is parsed from a packed string, and `TithiDay` now stores the Ekadashi
/// observance day instead of deriving it from `tithi == 11`.
void main() {
  group('sample tithi table', () {
    test('parses every row', () {
      expect(sampleTithi, isNotEmpty);
      expect(sampleTithi.length, greaterThan(700));
      for (final d in sampleTithi) {
        expect(d.tithi, inInclusiveRange(1, 15), reason: d.key);
        expect(d.monthGu, isNotEmpty, reason: d.key);
      }
    });

    test('covers consecutive days with no gaps or duplicates', () {
      for (var i = 1; i < sampleTithi.length; i++) {
        expect(
          sampleTithi[i].date.difference(sampleTithi[i - 1].date).inDays,
          1,
          reason: 'gap before ${sampleTithi[i].key}',
        );
      }
    });

    test('names every Ekadashi vrat day, and only vrat days', () {
      for (final d in sampleTithi) {
        expect(d.isEkadashi, d.ekadashiName != null, reason: d.key);
      }
    });

    test('has one Ekadashi vrat every 10-20 days', () {
      final vrats = sampleTithi.where((d) => d.isEkadashi).toList();
      expect(vrats.length, greaterThanOrEqualTo(48));
      for (var i = 1; i < vrats.length; i++) {
        final gap = vrats[i].date.difference(vrats[i - 1].date).inDays;
        expect(gap, inInclusiveRange(10, 20), reason: 'before ${vrats[i].key}');
      }
    });

    test('defers a kshaya Ekadashi to the Dwadashi day', () {
      // Kartak Sud 11 2026 begins after sunrise on 20 Nov and ends before
      // sunrise on 21 Nov, so it never runs at a sunrise that fortnight.
      final fortnight = sampleTithi.where((d) =>
          d.date.year == 2026 && d.monthGu == 'Kartak' && d.paksha == Paksha.sud);
      expect(fortnight, isNotEmpty);
      expect(fortnight.any((d) => d.tithi == 11), isFalse);
      final vrat = sampleTithi.firstWhere((d) => d.ekadashiName == 'Prabodhini');
      expect(vrat.key, '2026-11-21');
      expect(vrat.tithi, 12);
      expect(vrat.isEkadashiTithi, isFalse);
      expect(vrat.isEkadashi, isTrue);
    });

    test('marks Adhik Ashadh 2026 and keeps its Ekadashis', () {
      final adhik = sampleTithi.where((d) => d.monthGu.startsWith('Adhik ')).toList();
      expect(adhik, isNotEmpty);
      expect(adhik.map((d) => d.monthGu).toSet(), {'Adhik Ashadh'});
      // An adhik maas has its own pair of Ekadashis, named Padmini and Parama.
      expect(
        adhik.where((d) => d.isEkadashi).map((d) => d.ekadashiName).toSet(),
        {'Padmini', 'Parama'},
      );
      // Utsavs belong to the nij maas, never the adhik one.
      expect(adhik.every((d) => d.utsav.isEmpty), isTrue);
    });

    test('rolls the Gujarati month over at Amas', () {
      for (var i = 1; i < sampleTithi.length; i++) {
        final prev = sampleTithi[i - 1];
        final cur = sampleTithi[i];
        if (cur.monthGu != prev.monthGu) {
          expect(cur.paksha, Paksha.sud,
              reason: '${cur.key} starts ${cur.monthGu} mid-fortnight');
        }
      }
    });

    test('keeps the known 2026 anchors', () {
      final byKey = {for (final d in sampleTithi) d.key: d};
      expect(byKey['2026-09-04']!.fullLabel, 'Shravan Vad 8');
      expect(byKey['2026-09-04']!.utsav, contains('Janmashtami'));
      expect(byKey['2026-09-22']!.ekadashiName, 'Jal Jhilani');
      expect(byKey['2026-10-22']!.ekadashiName, 'Pashankusha');
      // Panchang-confirmed. These two pinned down the month-naming bug: deriving
      // the month from MoonMasa.ino put Mohini a month late, on 27 May.
      expect(byKey['2026-04-27']!.fullLabel, 'Vaishakh Sud 11');
      expect(byKey['2026-04-27']!.ekadashiName, 'Mohini');
      expect(byKey['2026-05-27']!.fullLabel, 'Jeth Sud 11');
      expect(byKey['2026-05-27']!.ekadashiName, 'Nirjala');
      expect(byKey['2026-03-03']!.fullLabel, 'Fagan Punam');
      expect(byKey['2026-11-09']!.isAmas, isTrue);
    });
  });

  group('TithiDay', () {
    test('falls back to tithi == 11 when the vrat flag is absent', () {
      // Docs written before `ekadashi_vrat` existed must still list Ekadashis.
      final legacy = TithiDay.fromMap({
        'date': '2026-09-22',
        'month_gu': 'Bhadarva',
        'paksha': 'sud',
        'tithi': 11,
      });
      expect(legacy.isEkadashi, isTrue);
      expect(legacy.isEkadashiTithi, isTrue);
    });

    test('round-trips the vrat flag through toMap/fromMap', () {
      final kshaya = TithiDay(
        date: DateTime.parse('2026-11-21'),
        monthGu: 'Kartak',
        paksha: Paksha.sud,
        tithi: 12,
        ekadashiName: 'Prabodhini',
        ekadashiVrat: true,
      );
      final back = TithiDay.fromMap(kshaya.toMap());
      expect(back.isEkadashi, isTrue);
      expect(back.isEkadashiTithi, isFalse);
      expect(back.ekadashiName, 'Prabodhini');
    });
  });

  group('pickUpcomingEkadashi', () {
    test('returns the next vrat days on/after the given date', () {
      final next = pickUpcomingEkadashi(sampleTithi, DateTime(2026, 9, 22), 4);
      expect(next.map((d) => d.key), ['2026-09-22', '2026-10-06', '2026-10-22', '2026-11-05']);
      expect(next.first.ekadashiName, 'Jal Jhilani');
    });

    test('counts a vrat day that is still today', () {
      // The 22nd is itself an Ekadashi: it belongs in the list, not behind it.
      expect(pickUpcomingEkadashi(sampleTithi, DateTime(2026, 9, 22, 23, 59), 1).single.key,
          '2026-09-22');
      expect(pickUpcomingEkadashi(sampleTithi, DateTime(2026, 9, 23), 1).single.key,
          '2026-10-06');
    });

    test('finds vrat days in documents written before ekadashi_vrat existed', () {
      // The live `tithi` collection predates the flag, so Firestore's own
      // `where('ekadashi_vrat', isEqualTo: true)` matched none of these docs.
      // Filtering here goes through TithiDay.isEkadashi, which falls back to
      // the tithi, so the list fills either way.
      final legacy = sampleTithi
          .map((d) => TithiDay.fromMap({...d.toMap()}..remove('ekadashi_vrat')))
          .toList();
      expect(legacy.every((d) => d.ekadashiVrat == null), isTrue);
      expect(pickUpcomingEkadashi(legacy, DateTime(2026, 9, 22), 4).map((d) => d.key),
          ['2026-09-22', '2026-10-06', '2026-10-22', '2026-11-05']);
    });

    test('a 20-day-per-vrat window always holds enough days', () {
      // FirestoreTithiRepository reads `count * 20` days and filters them here.
      final vrats = sampleTithi.where((d) => d.isEkadashi).toList();
      for (final d in sampleTithi) {
        final ahead = vrats.where((v) => !v.date.isBefore(d.date)).take(4).toList();
        if (ahead.length < 4) break; // Near the end of the table.
        expect(ahead.last.date.difference(d.date).inDays, lessThan(4 * 20),
            reason: 'window starting ${d.key} misses ${ahead.last.key}');
      }
    });
  });
}

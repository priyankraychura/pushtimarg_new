import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/features/bhajans/domain/bhajan.dart';
import 'package:pushti_kirtan/features/home/domain/seva.dart';
import 'package:pushti_kirtan/features/lyrics/domain/lyrics.dart';

void main() {
  group('Bhajan.matches', () {
    const b = Bhajan(
      id: 'x',
      title: 'શ્રી યમુનાષ્ટક',
      category: BhajanCategory.kirtan,
      poet: 'Shri Vallabhacharya',
      seva: 'Rajbhog',
      tags: ['janmashtami'],
    );

    test('matches title, poet, tags and Gujarati', () {
      expect(b.matches('vallabh'), isTrue);
      expect(b.matches('યમુના'), isTrue);
      expect(b.matches('janma'), isTrue);
      expect(b.matches('surdas'), isFalse);
    });
  });

  group('Lyrics.stanzasFor', () {
    test('splits on empty lines', () {
      const l = Lyrics(
        bhajanId: 'x',
        byScript: {Script.gujarati: ['a', 'b', '', 'c', '', '']},
      );
      expect(l.stanzasFor(Script.gujarati), [['a', 'b'], ['c']]);
      expect(l.has(Script.hindi), isFalse);
      expect(l.linesFor(Script.hindi), ['a', 'b', '', 'c', '', '']); // falls back to what exists
      expect(l.resolve(Script.english), Script.gujarati);
    });
  });

  group('SevaSchedule.current', () {
    final s = SevaSchedule(const {'Mangala': '05:30', 'Rajbhog': '11:30', 'Shayan': '20:00'});

    test('picks the last seva that has started', () {
      expect(s.current(DateTime(2026, 9, 20, 12)).name, 'Rajbhog');
      expect(s.current(DateTime(2026, 9, 20, 6)).name, 'Mangala');
    });

    test('before Mangala is still last night\'s Shayan', () {
      expect(s.current(DateTime(2026, 9, 20, 3)).name, 'Shayan');
    });
  });
}

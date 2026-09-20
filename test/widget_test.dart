import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/features/bhajans/domain/bhajan.dart';
import 'package:pushti_kirtan/features/home/domain/seva.dart';

void main() {
  group('Bhajan.matches', () {
    const b = Bhajan(
      id: 'x',
      titleGu: 'શ્રી યમુનાષ્ટક',
      titleEn: 'Shri Yamunashtak',
      poet: 'Shri Vallabhacharya',
      raga: 'Bhairav',
      category: BhajanCategory.kirtan,
      sevas: ['Rajbhog'],
      lineCount: 36,
    );

    test('matches title, poet and Gujarati', () {
      expect(b.matches('yamuna'), isTrue);
      expect(b.matches('vallabh'), isTrue);
      expect(b.matches('યમુના'), isTrue);
      expect(b.matches('surdas'), isFalse);
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

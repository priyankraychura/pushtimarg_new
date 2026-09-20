import '../domain/tithi_day.dart';

/// Approximate tithi table for Aug–Nov 2026 used in demo mode. Generate the
/// real table from a panchang source and load it into `tithi/{date}`.
final List<TithiDay> sampleTithi = _build();

List<TithiDay> _build() {
  final days = <TithiDay>[];

  // Each tuple: start date, month, paksha, first tithi on that date, length.
  void run(DateTime start, String month, Paksha p, int fromTithi, int length) {
    for (var i = 0; i < length; i++) {
      final t = fromTithi + i;
      if (t > 15) break;
      days.add(TithiDay(date: start.add(Duration(days: i)), monthGu: month, paksha: p, tithi: t));
    }
  }

  run(DateTime(2026, 8, 28), 'Shravan', Paksha.vad, 1, 15); // 28 Aug – 11 Sep (Amas 11 Sep)
  run(DateTime(2026, 9, 12), 'Bhadarva', Paksha.sud, 1, 15); // 12 – 26 Sep (Punam 26 Sep)
  run(DateTime(2026, 9, 27), 'Bhadarva', Paksha.vad, 1, 15); // 27 Sep – 11 Oct
  run(DateTime(2026, 10, 12), 'Aaso', Paksha.sud, 1, 15); // 12 – 26 Oct
  run(DateTime(2026, 10, 27), 'Aaso', Paksha.vad, 1, 15); // 27 Oct – 10 Nov (Diwali ≈ 8 Nov)
  run(DateTime(2026, 11, 11), 'Kartak', Paksha.sud, 1, 15);

  // Ekadashi names + utsav overlay (sample values).
  const ekadashi = {
    '2026-09-07': 'Aja',
    '2026-09-22': 'Jal Jhilani',
    '2026-10-06': 'Indira',
    '2026-10-21': 'Pashankusha',
    '2026-11-05': 'Rama',
    '2026-11-21': 'Prabodhini',
  };
  const utsav = {
    '2026-09-04': ['Janmashtami'],
    '2026-09-05': ['Nandotsav'],
    '2026-09-15': ['Ganesh Chaturthi'],
    '2026-11-08': ['Diwali'],
    '2026-11-09': ['Annakut'],
  };

  return days.map((d) {
    final k = d.key;
    if (ekadashi.containsKey(k) || utsav.containsKey(k)) {
      return TithiDay(
        date: d.date,
        monthGu: d.monthGu,
        paksha: d.paksha,
        tithi: d.tithi,
        ekadashiName: ekadashi[k],
        utsav: utsav[k] ?? const [],
      );
    }
    return d;
  }).toList();
}

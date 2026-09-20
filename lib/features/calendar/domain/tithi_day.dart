import 'package:flutter/foundation.dart';

enum Paksha { sud, vad }

/// One Gregorian date with its Hindu lunar tithi. Shipped as a per-year table
/// (`tithi/{yyyy-MM-dd}`) rather than computed on-device.
@immutable
class TithiDay {
  const TithiDay({
    required this.date,
    required this.monthGu,
    required this.paksha,
    required this.tithi,
    this.utsav = const [],
    this.ekadashiName,
  });

  final DateTime date;

  /// Gujarati month, e.g. "Bhadarva".
  final String monthGu;
  final Paksha paksha;

  /// 1–15. 15 in Sud = Punam, 15 in Vad = Amas.
  final int tithi;
  final List<String> utsav;

  /// Name of the Ekadashi when [tithi] == 11 ("Jal Jhilani").
  final String? ekadashiName;

  bool get isEkadashi => tithi == 11;
  bool get isPunam => paksha == Paksha.sud && tithi == 15;
  bool get isAmas => paksha == Paksha.vad && tithi == 15;
  bool get hasUtsav => utsav.isNotEmpty;

  /// "Sud 9", "Punam", "Amas" — the short label under a date.
  String get shortLabel {
    if (isPunam) return 'Punam';
    if (isAmas) return 'Amas';
    return '${paksha == Paksha.sud ? 'Sud' : 'Vad'} $tithi';
  }

  /// "Bhadarva Sud 9"
  String get fullLabel => '$monthGu $shortLabel';

  String get key => _key(date);
  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  factory TithiDay.fromMap(Map<String, dynamic> m) => TithiDay(
        date: DateTime.parse(m['date'] as String),
        monthGu: m['month_gu'] as String,
        paksha: m['paksha'] == 'vad' ? Paksha.vad : Paksha.sud,
        tithi: (m['tithi'] as num).toInt(),
        utsav: List<String>.from(m['utsav'] as List? ?? const []),
        ekadashiName: m['ekadashi_name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'date': key,
        'month_gu': monthGu,
        'paksha': paksha.name,
        'tithi': tithi,
        'utsav': utsav,
        if (ekadashiName != null) 'ekadashi_name': ekadashiName,
      };
}

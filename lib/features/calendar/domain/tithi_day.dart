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
    this.ekadashiVrat,
  });

  final DateTime date;

  /// Gujarati month, e.g. "Bhadarva".
  final String monthGu;
  final Paksha paksha;

  /// 1–15. 15 in Sud = Punam, 15 in Vad = Amas.
  final int tithi;
  final List<String> utsav;

  /// Name of the Ekadashi on the vrat day ("Jal Jhilani").
  final String? ekadashiName;

  /// Whether the Ekadashi vrat is observed on this date, as shipped in the
  /// table. Null in docs written before the field existed — read [isEkadashi]
  /// rather than this.
  final bool? ekadashiVrat;

  /// The Ekadashi *tithi* runs at sunrise on this date — an astronomical fact.
  bool get isEkadashiTithi => tithi == 11;

  /// The day the Ekadashi vrat is observed.
  ///
  /// Usually the same day as [isEkadashiTithi], but the tithi does not map
  /// one-to-one onto civil days: it can span two sunrises (vriddhi) or none at
  /// all (kshaya). The Vaishnav convention defers the fast in both cases — to
  /// the second day, and to the following Dwadashi — so a fortnight can have an
  /// Ekadashi vrat with no Ekadashi tithi at sunrise. The flag is therefore part
  /// of the shipped table; the fallback keeps pre-existing docs working.
  bool get isEkadashi => ekadashiVrat ?? isEkadashiTithi;
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
        ekadashiVrat: m['ekadashi_vrat'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'date': key,
        'month_gu': monthGu,
        'paksha': paksha.name,
        'tithi': tithi,
        'utsav': utsav,
        'ekadashi_vrat': isEkadashi,
        if (ekadashiName != null) 'ekadashi_name': ekadashiName,
      };
}

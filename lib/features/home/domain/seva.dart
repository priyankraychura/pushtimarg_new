import 'package:flutter/material.dart';

/// One of the eight daily sevas (ashtayam) with its start time and the
/// kirtan traditionally sung then.
@immutable
class Seva {
  const Seva({required this.name, required this.time, required this.kirtan, required this.kirtanCount});

  final String name;
  final TimeOfDay time;
  final String kirtan;
  final int kirtanCount;

  /// Sample kirtan per seva. In production this comes from a `sevas` doc.
  static const Map<String, (String, int)> defaultKirtans = {
    'Mangala': ('Jago Mohan Pyare', 4),
    'Shringar': ('Banayo Shringar', 6),
    'Gwal': ('Chalo Sakhi Yamuna Tat', 3),
    'Rajbhog': ('Shri Yamunashtak', 8),
    'Utthapan': ('Jago Jago Nandkumar', 2),
    'Bhog': ('Bhog Dharyo Rasik', 3),
    'Sandhya Aarti': ('Aarti Shri Yamunaji', 5),
    'Shayan': ('Podho Shrinathji', 4),
  };

  static TimeOfDay parse(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String get timeLabel {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '$h:${time.minute.toString().padLeft(2, '0')}';
  }

  int get minutes => time.hour * 60 + time.minute;
}

enum SevaStatus { done, live, upcoming }

/// Builds today's schedule and works out which seva is current.
class SevaSchedule {
  SevaSchedule(Map<String, String> times)
      : sevas = times.entries
            .map((e) => Seva(
                  name: e.key,
                  time: Seva.parse(e.value),
                  kirtan: Seva.defaultKirtans[e.key]?.$1 ?? '',
                  kirtanCount: Seva.defaultKirtans[e.key]?.$2 ?? 0,
                ))
            .toList()
          ..sort((a, b) => a.minutes.compareTo(b.minutes));

  final List<Seva> sevas;

  /// The seva whose window we're in (last one that has started).
  Seva current([DateTime? at]) {
    final now = at ?? DateTime.now();
    final mins = now.hour * 60 + now.minute;
    Seva result = sevas.last; // before Mangala → still "Shayan" from last night
    for (final s in sevas) {
      if (s.minutes <= mins) result = s;
    }
    return result;
  }

  SevaStatus status(Seva s, [DateTime? at]) {
    final cur = current(at);
    if (s == cur) return SevaStatus.live;
    return s.minutes < cur.minutes ? SevaStatus.done : SevaStatus.upcoming;
  }
}

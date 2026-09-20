import 'package:flutter/material.dart';

/// One of the eight daily sevas (ashtayam) with its start time. The kirtans
/// sung at it come from bhajans whose `seva` matches [name].
@immutable
class Seva {
  const Seva({required this.name, required this.time});

  final String name;
  final TimeOfDay time;

  // Value equality so it can key a provider family.
  @override
  bool operator ==(Object other) => other is Seva && other.name == name && other.time == time;

  @override
  int get hashCode => Object.hash(name, time);

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
      : sevas = times.entries.map((e) => Seva(name: e.key, time: Seva.parse(e.value))).toList()
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

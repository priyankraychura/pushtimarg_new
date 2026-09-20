import '../../lyrics/domain/lyrics.dart';
import '../domain/bhajan.dart';

final _ws = RegExp(r'\s+');

/// Folds what people actually type when looking for a bhajan — title, poet,
/// tags and the opening line (mukhda) of every script — into one lowercased,
/// whitespace-collapsed string. Stored as `bhajans/{id}.search` so the search
/// screen never has to load `lyrics/{id}`, and kept to the first line only so
/// list docs stay a few hundred bytes as the collection grows.
String buildSearchText(Bhajan b, Lyrics? l) {
  final parts = <String>[
    b.title,
    b.poet,
    ...b.tags,
    if (l != null)
      for (final lines in l.byScript.values)
        if (lines.isNotEmpty) lines.first,
  ];
  return parts.join(' ').toLowerCase().replaceAll(_ws, ' ').trim();
}

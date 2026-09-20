import 'package:flutter/foundation.dart';

/// The four kinds of bhajan shown on Home and used as filters on Bhajans.
enum BhajanCategory {
  pad('Pad'),
  aarti('Aarti'),
  kirtan('Kirtan'),
  varta('Varta');

  const BhajanCategory(this.label);
  final String label;

  static BhajanCategory fromKey(String? key) => values.firstWhere(
        (v) => v.name == key,
        orElse: () => BhajanCategory.kirtan,
      );
}

/// Which script the reader shows. [key] is the field name under `lyrics`.
enum Script {
  gujarati('ગુજરાતી', 'gu'),
  hindi('हिन्दी', 'hi'),
  english('English', 'en');

  const Script(this.label, this.key);
  final String label;
  final String key;

  static Script fromKey(String? k) =>
      values.firstWhere((s) => s.key == k, orElse: () => Script.gujarati);
}

/// One bhajan: metadata plus its lyrics in each script.
///
/// Firestore doc `bhajans/{id}`:
/// ```
/// title, category (pad|aarti|kirtan|varta), poet, seva, video?, tags[],
/// lyrics: { gu: [line, ...], hi: [...], en: [...] }
/// ```
/// Lyrics are one string per line; an empty string marks a stanza break.
@immutable
class Bhajan {
  const Bhajan({
    required this.id,
    required this.title,
    required this.category,
    required this.poet,
    required this.seva,
    this.video,
    this.tags = const [],
    this.lyrics = const {},
  });

  final String id;
  final String title;
  final BhajanCategory category;
  final String poet;

  /// Daily seva it is sung at ("Rajbhog", "Mangala"...).
  final String seva;

  /// YouTube video id, if there is a recording.
  final String? video;

  /// Free-form labels ("janmashtami", "holi") for linking to calendar days.
  final List<String> tags;

  final Map<Script, List<String>> lyrics;

  bool has(Script s) => lyrics[s]?.isNotEmpty ?? false;

  List<String> linesFor(Script s) => lyrics[s] ?? lyrics[Script.gujarati] ?? const [];

  /// Lines grouped into stanzas, split on empty strings.
  List<List<String>> stanzasFor(Script s) {
    final out = <List<String>>[];
    var cur = <String>[];
    for (final line in linesFor(s)) {
      if (line.trim().isEmpty) {
        if (cur.isNotEmpty) out.add(cur);
        cur = <String>[];
      } else {
        cur.add(line);
      }
    }
    if (cur.isNotEmpty) out.add(cur);
    return out;
  }

  int get lineCount => linesFor(Script.gujarati).where((l) => l.trim().isNotEmpty).length;

  String? get firstLine {
    for (final l in linesFor(Script.gujarati)) {
      if (l.trim().isNotEmpty) return l;
    }
    return null;
  }

  factory Bhajan.fromMap(String id, Map<String, dynamic> m) {
    final raw = m['lyrics'] as Map? ?? const {};
    return Bhajan(
      id: id,
      title: m['title'] as String? ?? '',
      category: BhajanCategory.fromKey(m['category'] as String?),
      poet: m['poet'] as String? ?? '',
      seva: m['seva'] as String? ?? '',
      video: m['video'] as String?,
      tags: List<String>.from(m['tags'] as List? ?? const []),
      lyrics: {
        for (final s in Script.values)
          if (raw[s.key] != null) s: List<String>.from(raw[s.key] as List),
      },
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category.name,
        'poet': poet,
        'seva': seva,
        if (video != null) 'video': video,
        'tags': tags,
        'lyrics': {for (final e in lyrics.entries) e.key.key: e.value},
      };

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (title.toLowerCase().contains(q) || poet.toLowerCase().contains(q)) return true;
    for (final lines in lyrics.values) {
      for (final l in lines) {
        if (l.toLowerCase().contains(q)) return true;
      }
    }
    return false;
  }
}

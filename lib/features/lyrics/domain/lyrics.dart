import 'package:flutter/foundation.dart';

/// Which script the reader shows. [key] is the field name in the lyrics doc.
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

/// Lyrics for one bhajan, loaded only by the reader.
///
/// Firestore doc `lyrics/{bhajanId}` (same id as `bhajans/{id}`):
/// ```
/// { gu: [line, ...], hi: [...], en: [...] }
/// ```
/// One string per line; an empty string marks a stanza break.
@immutable
class Lyrics {
  const Lyrics({required this.bhajanId, required this.byScript});

  final String bhajanId;
  final Map<Script, List<String>> byScript;

  bool has(Script s) => byScript[s]?.isNotEmpty ?? false;

  /// Scripts with text, in [Script] order.
  List<Script> get available => [for (final s in Script.values) if (has(s)) s];

  /// [preferred] if we have it, else the first script we do have.
  Script resolve(Script preferred) => has(preferred) ? preferred : (available.firstOrNull ?? preferred);

  List<String> linesFor(Script s) => byScript[resolve(s)] ?? const [];

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

  factory Lyrics.fromMap(String id, Map<String, dynamic> m) => Lyrics(
        bhajanId: id,
        byScript: {
          for (final s in Script.values)
            if (m[s.key] != null) s: List<String>.from(m[s.key] as List),
        },
      );

  Map<String, dynamic> toMap() => {for (final e in byScript.entries) e.key.key: e.value};
}

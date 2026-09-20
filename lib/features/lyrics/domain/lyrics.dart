import 'package:flutter/foundation.dart';

/// Which script the reader shows.
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

/// A stanza (shloka / antara) is a group of lines that are sung together.
/// Stored as `{lines: [...]}` because Firestore forbids nested arrays.
@immutable
class Stanza {
  const Stanza(this.lines);
  final List<String> lines;

  factory Stanza.fromMap(Map<String, dynamic> m) =>
      Stanza(List<String>.from(m['lines'] as List? ?? const []));

  Map<String, dynamic> toMap() => {'lines': lines};
}

/// Full lyrics for one bhajan, per script. Loaded only by the reader screen.
@immutable
class Lyrics {
  const Lyrics({required this.bhajanId, required this.byScript});

  final String bhajanId;
  final Map<Script, List<Stanza>> byScript;

  List<Stanza> stanzasFor(Script s) =>
      byScript[s] ?? byScript[Script.gujarati] ?? const [];

  bool has(Script s) => byScript[s]?.isNotEmpty ?? false;

  int lineCount(Script s) => stanzasFor(s).fold(0, (n, st) => n + st.lines.length);

  factory Lyrics.fromMap(String id, Map<String, dynamic> m) => Lyrics(
        bhajanId: id,
        byScript: {
          for (final s in Script.values)
            if (m[s.key] != null)
              s: (m[s.key] as List)
                  .map((e) => Stanza.fromMap(Map<String, dynamic>.from(e as Map)))
                  .toList(),
        },
      );

  Map<String, dynamic> toMap() => {
        for (final e in byScript.entries) e.key.key: e.value.map((s) => s.toMap()).toList(),
      };
}

import 'package:flutter/foundation.dart';

import 'varta_collection.dart';

/// One numbered episode ("પ્રસંગ ૧") of a varta. Most are a single
/// paragraph; a few open with a shloka followed by its commentary.
@immutable
class VartaPrasang {
  const VartaPrasang({required this.number, required this.paragraphs});

  final int number;
  final List<String> paragraphs;

  factory VartaPrasang.fromMap(Map<String, dynamic> m) => VartaPrasang(
        number: (m['number'] as num?)?.toInt() ?? 0,
        paragraphs: List<String>.from(m['paragraphs'] as List? ?? const []),
      );

  Map<String, dynamic> toMap() => {'number': number, 'paragraphs': paragraphs};
}

/// The varta of one vaishnav: heading, prasangs, the "સાર" points that
/// follow them, and any closing notes (a dhol, where the sevya swaroop is
/// today). A varta usually has one section; some bundle a relative's varta
/// after the main one (Govindswami → his sister Kanhbai).
@immutable
class VartaSection {
  const VartaSection({
    required this.title,
    this.prasangs = const [],
    this.saar = const [],
    this.notes = const [],
  });

  /// Heading line, e.g. "શ્રી ગુસાંઈજીના સેવક ગોવિંદસ્વામી … તેમની વાર્તા".
  final String title;
  final List<VartaPrasang> prasangs;

  /// Summary points ("સાર"), one string each; numbered by the reader.
  final List<String> saar;
  final List<String> notes;

  factory VartaSection.fromMap(Map<String, dynamic> m) => VartaSection(
        title: m['title'] as String? ?? '',
        prasangs: [
          for (final p in m['prasangs'] as List? ?? const []) VartaPrasang.fromMap(Map<String, dynamic>.from(p as Map)),
        ],
        saar: List<String>.from(m['saar'] as List? ?? const []),
        notes: List<String>.from(m['notes'] as List? ?? const []),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'prasangs': [for (final p in prasangs) p.toMap()],
        'saar': saar,
        'notes': notes,
      };
}

/// One varta of the 84 or 252 granth. Whole text is bundled in the doc since
/// it is only ever read as a unit.
///
/// Firestore doc `vartas/{id}`:
/// ```
/// collection (chaurasi|doSauBavan), number, name, nameEn, subtitle, sections[]
/// ```
@immutable
class Varta {
  const Varta({
    required this.id,
    required this.collection,
    required this.number,
    required this.name,
    required this.nameEn,
    this.subtitle = '',
    this.sections = const [],
  });

  final String id;
  final VartaCollection collection;

  /// Position in the granth (1-based).
  final int number;

  /// Vaishnav's name in Gujarati, e.g. "ગોવિંદસ્વામી".
  final String name;
  final String nameEn;

  /// Caste / place line shown under the name, e.g. "સાનોડીયા બ્રાહ્મણ · મહાવન".
  final String subtitle;
  final List<VartaSection> sections;

  int get prasangCount => sections.fold(0, (n, s) => n + s.prasangs.length);

  factory Varta.fromMap(String id, Map<String, dynamic> m) => Varta(
        id: id,
        collection: VartaCollection.fromKey(m['collection'] as String?),
        number: (m['number'] as num?)?.toInt() ?? 0,
        name: m['name'] as String? ?? '',
        nameEn: m['nameEn'] as String? ?? '',
        subtitle: m['subtitle'] as String? ?? '',
        sections: [
          for (final s in m['sections'] as List? ?? const []) VartaSection.fromMap(Map<String, dynamic>.from(s as Map)),
        ],
      );

  Map<String, dynamic> toMap() => {
        'collection': collection.name,
        'number': number,
        'name': name,
        'nameEn': nameEn,
        'subtitle': subtitle,
        'sections': [for (final s in sections) s.toMap()],
      };

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.contains(q) || nameEn.toLowerCase().contains(q) || subtitle.contains(q) || '$number' == q;
  }
}

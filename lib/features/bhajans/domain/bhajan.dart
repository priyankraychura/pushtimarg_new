import 'package:flutter/foundation.dart';

/// The four browse types shown on Home and used as filters on Bhajans.
enum BhajanCategory {
  aarti('Aarti'),
  kirtan('Kirtan'),
  pad('Pad'),
  vasta('Vasta');

  const BhajanCategory(this.label);
  final String label;

  static BhajanCategory fromKey(String? key) => values.firstWhere(
        (v) => v.name == key,
        orElse: () => BhajanCategory.kirtan,
      );
}

/// List-level bhajan metadata. Lyrics live in a separate document so list
/// queries stay tiny (see `Lyrics`).
@immutable
class Bhajan {
  const Bhajan({
    required this.id,
    required this.titleGu,
    required this.titleEn,
    required this.poet,
    required this.raga,
    required this.category,
    required this.sevas,
    required this.lineCount,
    this.firstLineGu,
  });

  final String id;
  final String titleGu;
  final String titleEn;
  final String poet;
  final String raga;
  final BhajanCategory category;

  /// Sevas this kirtan is sung at ("Rajbhog", "Mangala"...).
  final List<String> sevas;
  final int lineCount;
  final String? firstLineGu;

  String get primarySeva => sevas.isEmpty ? '' : sevas.first;

  factory Bhajan.fromMap(String id, Map<String, dynamic> m) => Bhajan(
        id: id,
        titleGu: m['title_gu'] as String? ?? '',
        titleEn: m['title_en'] as String? ?? '',
        poet: m['poet'] as String? ?? '',
        raga: m['raga'] as String? ?? '',
        category: BhajanCategory.fromKey(m['category'] as String?),
        sevas: List<String>.from(m['seva'] as List? ?? const []),
        lineCount: (m['line_count'] as num?)?.toInt() ?? 0,
        firstLineGu: m['first_line_gu'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'title_gu': titleGu,
        'title_en': titleEn,
        'poet': poet,
        'raga': raga,
        'category': category.name,
        'seva': sevas,
        'line_count': lineCount,
        if (firstLineGu != null) 'first_line_gu': firstLineGu,
      };

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return titleEn.toLowerCase().contains(q) ||
        titleGu.contains(q) ||
        poet.toLowerCase().contains(q) ||
        (firstLineGu?.contains(q) ?? false);
  }
}

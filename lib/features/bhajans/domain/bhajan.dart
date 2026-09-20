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

/// List-level bhajan metadata — what a card shows. Lyrics live in
/// `lyrics/{id}` (same id) and are fetched only when the bhajan is opened.
///
/// Firestore doc `bhajans/{id}`:
/// ```
/// title, category (pad|aarti|kirtan|varta), poet, seva, video?, tags[]
/// ```
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

  factory Bhajan.fromMap(String id, Map<String, dynamic> m) => Bhajan(
        id: id,
        title: m['title'] as String? ?? '',
        category: BhajanCategory.fromKey(m['category'] as String?),
        poet: m['poet'] as String? ?? '',
        seva: m['seva'] as String? ?? '',
        video: m['video'] as String?,
        tags: List<String>.from(m['tags'] as List? ?? const []),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category.name,
        'poet': poet,
        'seva': seva,
        if (video != null) 'video': video,
        'tags': tags,
      };

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        poet.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}

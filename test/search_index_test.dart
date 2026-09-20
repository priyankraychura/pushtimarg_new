import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/features/bhajans/data/bhajan_repository.dart';

void main() {
  test('english title and lyric lines find yamunashtak', () async {
    final all = await SampleBhajanRepository().watchAll().first;
    for (final q in ['yamunashtak', 'Namami Yamuna', 'નમામિ યમુના', 'vallabh']) {
      final hits = all.where((b) => b.matches(q)).map((b) => b.id).toList();
      expect(hits, contains('yamunashtak'), reason: q);
    }
    // Only the opening line is indexed, so verse 2 must not match.
    expect(all.where((b) => b.matches('kalinda giri')), isEmpty);
    expect(all.where((b) => b.matches('zzzz')), isEmpty);
  });
}

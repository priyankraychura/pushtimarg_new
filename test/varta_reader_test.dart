import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/core/theme/theme.dart';
import 'package:pushti_kirtan/features/settings/providers/settings_providers.dart';
import 'package:pushti_kirtan/features/varta/data/sample_vartas.dart';
import 'package:pushti_kirtan/features/varta/data/varta_repository.dart';
import 'package:pushti_kirtan/features/varta/domain/varta.dart';
import 'package:pushti_kirtan/features/varta/domain/varta_collection.dart';
import 'package:pushti_kirtan/features/varta/presentation/varta_reader_screen.dart';
import 'package:pushti_kirtan/features/varta/providers/varta_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Varta data', () {
    test('varta 1 of 252 has Govindswami (19 prasang) + Kanhbai (5 prasang)', () {
      final v = sampleVartas.singleWhere((v) => v.id == 'varta-252-001');
      expect(v.collection, VartaCollection.doSauBavan);
      expect(v.number, 1);
      expect(v.sections, hasLength(2));
      expect(v.sections[0].prasangs.map((p) => p.number), List.generate(19, (i) => i + 1));
      expect(v.sections[1].prasangs.map((p) => p.number), [1, 2, 3, 4, 5]);
      expect(v.prasangCount, 24);
      expect(v.sections[0].saar, isNotEmpty);
      expect(v.sections[1].saar, hasLength(2));
      // Prefixes were stripped into `number`, not left in the text.
      for (final s in v.sections) {
        for (final p in s.prasangs) {
          expect(p.paragraphs.first, isNot(startsWith('પ્રસંગ')));
          expect(p.paragraphs.every((t) => t.trim().isNotEmpty), isTrue);
        }
      }
    });

    test('round-trips through Firestore map', () {
      final v = sampleVartas.first;
      final back = Varta.fromMap(v.id, v.toMap());
      expect(back.toMap(), v.toMap());
      expect(back.sections[0].prasangs[4].paragraphs, v.sections[0].prasangs[4].paragraphs);
    });
  });

  testWidgets('reader shows both sections and jumps to a prasang from the strip', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          vartaRepositoryProvider.overrideWithValue(SampleVartaRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const VartaReaderScreen(vartaId: 'varta-252-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ગોવિંદસ્વામી'), findsOneWidget);
    expect(find.text('Varta 1 · 252 Vaishnav ni Varta'), findsOneWidget);
    expect(find.text('પ્રસંગ ૧').hitTestable(), findsOneWidget);
    // Kanhbai's varta is far below the fold.
    const kanhbai = 'ગોવિંદદાસનાં બહેન કાન્હબાઈ હતાં તેમની વાર્તા';
    expect(find.text(kanhbai).hitTestable(), findsNothing);

    // Strip: 19 chips for section 0, then 5 for section 1. Chip "૫" appears
    // twice (one per section); scroll the strip so section 1's is visible.
    final strip = find.byType(ListView).first;
    for (var i = 0; i < 2; i++) {
      await tester.drag(strip, const Offset(-800, 0));
      await tester.pumpAndSettle();
    }
    final fives = find.descendant(of: strip, matching: find.text('૫'));
    await tester.tap(fives.last);
    await tester.pumpAndSettle();

    // Kanhbai's prasang 5 is now on screen; Govindswami's prasang 1 is not.
    expect(find.text('પ્રસંગ ૫').hitTestable(), findsOneWidget);
    expect(find.text('પ્રસંગ ૧').hitTestable(), findsNothing);
  });
}

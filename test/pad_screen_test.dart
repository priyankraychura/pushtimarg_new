import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/core/theme/theme.dart';
import 'package:pushti_kirtan/features/bhajans/data/bhajan_repository.dart';
import 'package:pushti_kirtan/features/bhajans/data/yamunaji_41_pad_bhajans.dart';
import 'package:pushti_kirtan/features/bhajans/domain/bhajan.dart';
import 'package:pushti_kirtan/features/bhajans/presentation/pad_screen.dart';
import 'package:pushti_kirtan/features/bhajans/providers/bhajan_providers.dart';
import 'package:pushti_kirtan/features/lyrics/data/sample_lyrics.dart';
import 'package:pushti_kirtan/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Yamunaji 41 pad data', () {
    test('41 pads, numbered 1–41, all tagged and readable', () {
      expect(yamunaji41PadBhajans, hasLength(41));
      expect(
        yamunaji41PadBhajans.map((b) => yamunajiPadNumber(b.id)),
        List.generate(41, (i) => i + 1),
      );
      for (final pad in yamunaji41PadBhajans) {
        expect(pad.category, BhajanCategory.pad);
        expect(pad.tags, contains(yamunajiPadTag));
        expect(pad.poet, isNotEmpty);
        expect(sampleLyrics[pad.id], isNotNull, reason: '${pad.id} has no lyrics');
      }
    });

    test('provider returns them in granth order', () async {
      final container = ProviderContainer(
        overrides: [bhajanRepositoryProvider.overrideWithValue(SampleBhajanRepository())],
      );
      addTearDown(container.dispose);
      // The bhajan list arrives as a stream; subscribe, then let its first
      // event land before reading the derived provider.
      container.listen(allBhajansProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final pads = container.read(yamunaji41PadsProvider);
      expect(pads, hasLength(41));
      expect(pads.first.id, 'yamunaji-41-pad-01');
      expect(pads.last.id, 'yamunaji-41-pad-41');
    });
  });

  testWidgets('Pad screen lists all 41 and filters by poet', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bhajanRepositoryProvider.overrideWithValue(SampleBhajanRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const PadScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('શ્રી યમુનાજીનાં ૪૧ પદ'), findsWidgets);
    expect(find.text('41 of 41'), findsOneWidget);
    // Pad 1's opening line, with the "યમુનાજી પદ ૦૧ – " prefix dropped.
    expect(find.text('પિય સંગ રંગ ભરિ'), findsOneWidget);

    // Rasik Pritam opens the granth with four pads.
    await tester.tap(find.text('Rasik Pritam').first);
    await tester.pumpAndSettle();
    expect(find.text('4 of 41'), findsOneWidget);

    await tester.tap(find.text('All poets'));
    await tester.pumpAndSettle();
    expect(find.text('41 of 41'), findsOneWidget);
  });
}

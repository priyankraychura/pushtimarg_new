import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/core/widgets/container_transform_page.dart';

void main() {
  testWidgets('grows from the card rect, settles full-screen, shrinks back on pop', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    final cardKey = GlobalKey();
    ContainerOrigin? origin;

    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => SizedBox(
              key: cardKey,
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  origin = ContainerOrigin.of(context);
                  nav.currentState!.push(ContainerTransformPage<void>(
                    origin: origin,
                    color: Colors.teal,
                    child: const Scaffold(body: Center(child: Text('reader'))),
                  ).createRoute(context));
                },
                child: const Text('card'),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    // Early in the transition the reader is clipped to roughly the card rect.
    final early = tester.getRect(find.byType(ClipRRect).last);
    expect(origin, isNotNull);
    expect((early.left - origin!.rect.left).abs(), lessThan(20));
    expect(early.height, lessThan(200));

    await tester.pumpAndSettle();
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(tester.getRect(find.byType(ClipRRect).last), Offset.zero & size);
    expect(find.text('reader'), findsOneWidget);
    // The list underneath is no longer painted once the route is opaque.
    expect(find.text('card', skipOffstage: true), findsNothing);

    nav.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final closing = tester.getRect(find.byType(ClipRRect).last);
    expect(closing.height, lessThan(size.height));
    expect(closing.height, greaterThan(origin!.rect.height));

    await tester.pumpAndSettle();
    expect(find.text('reader'), findsNothing);
    expect(find.text('card'), findsOneWidget);
  });
}

@TestOn('vm')
library;

import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../utils.dart';

void main() {
  group('router', () {
    setUpAll(() {
      mockPlatform();
    });

    testComponents('should push route', (tester) async {
      tester.pumpComponent(Router(routes: [homeRoute(), route('/a')]));

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);

      await tester.router.push('/');
      await pumpEventQueue();

      expect(find.text('home'), findsOneComponent);

      tester.router.back();
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);
    });

    testComponents('should replace route', (tester) async {
      tester.pumpComponent(Router(routes: [homeRoute(), route('/a'), route('/b')]));

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);

      await tester.router.replace('/b');
      await pumpEventQueue();

      expect(find.text('b'), findsOneComponent);

      tester.router.back();
      await pumpEventQueue();

      expect(find.text('home'), findsOneComponent);
    });

    testComponents('should build shell route', (tester) async {
      tester.pumpComponent(
        Router(
          routes: [
            homeRoute(),
            route('/a', [
              shellRoute('b', [route('c')]),
            ]),
          ],
        ),
      );

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);
      expect(find.text('b'), findsNothing);
      expect(find.text('a/c'), findsNothing);

      await tester.router.push('/a/c');
      await pumpEventQueue();

      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneComponent);
      expect(find.text('a/c'), findsOneComponent);
    });
  });
}

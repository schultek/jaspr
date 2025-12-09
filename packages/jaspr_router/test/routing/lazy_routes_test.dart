@TestOn('vm')
library;

import 'dart:async';

import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../utils.dart';

void main() {
  group('router', () {
    setUpAll(() {
      mockPlatform();
    });

    testComponents('should push lazy route', (tester) async {
      final bCompleter = Completer<void>.sync();

      tester.pumpComponent(Router(routes: [homeRoute(), route('/a'), lazyRoute('/b', bCompleter.future)]));

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);

      await tester.router.push('/b');
      await pumpEventQueue();

      expect(find.text('b'), findsNothing);

      bCompleter.complete();
      await pumpEventQueue();

      expect(find.text('b'), findsOneComponent);
    });

    testComponents('should push lazy shell route', (tester) async {
      final bCompleter = Completer<void>.sync();

      tester.pumpComponent(
        Router(
          routes: [
            homeRoute(),
            route('/a'),
            lazyShellRoute('b', bCompleter.future, [route('/c')]),
          ],
        ),
      );

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);

      await tester.router.push('/c');
      await pumpEventQueue();

      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsNothing);
      expect(find.text('c'), findsNothing);

      bCompleter.complete();
      await pumpEventQueue();

      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneComponent);
      expect(find.text('c'), findsOneComponent);
    });
  });
}

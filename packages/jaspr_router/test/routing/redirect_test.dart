@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../utils.dart';

void main() {
  group('router', () {
    setUpAll(() {
      mockPlatform();
    });

    testComponents('should redirect toplevel', (tester) async {
      tester.pumpComponent(
        Router(
          routes: [homeRoute(), route('/b')],
          redirect: (_, s) {
            if (s.location == '/a') {
              return '/b';
            }
            return null;
          },
        ),
      );

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('b'), findsOneComponent);
      expect(tester.routeOf(find.text('b')).location, equals('/b'));
    });

    testComponents('should redirect on route', (tester) async {
      var blocked = true;

      tester.pumpComponent(
        Router(
          routes: [
            homeRoute(),
            route('/a'),
            route('/b', [], null, (_, s) {
              if (blocked) {
                return '/a';
              }
              return null;
            }),
          ],
        ),
      );

      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/b');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);
      expect(tester.routeOf(find.text('a')).location, equals('/a'));

      blocked = false;

      await tester.router.push('/b');
      await pumpEventQueue();

      expect(find.text('b'), findsOneComponent);
      expect(tester.routeOf(find.text('b')).location, equals('/b'));
    });

    testComponents('should redirect on async update', (tester) async {
      var blocked = false;
      late void Function(VoidCallback) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, cb) {
            setState = cb;
            return Router(
              routes: [homeRoute(), route('/a')],
              redirect: (_, s) async {
                await Future(() async {});
                if (s.location == '/a' && blocked) {
                  return '/';
                }
                return null;
              },
            );
          },
        ),
      );

      await pumpEventQueue();
      expect(find.text('home'), findsOneComponent);

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);
      expect(tester.routeOf(find.text('a')).location, equals('/a'));

      setState(() {
        blocked = true;
      });
      await pumpEventQueue();

      expect(find.text('home'), findsOneComponent);
      expect(tester.routeOf(find.text('home')).location, equals('/'));
    });
  });
}

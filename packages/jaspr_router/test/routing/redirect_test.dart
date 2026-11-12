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

    testComponents('should not run redirects on preload', (tester) async {
      var topRedirectCalls = 0;
      var routeRedirectCalls = 0;

      tester.pumpComponent(
        Router(
          routes: [
            homeRoute(),
            route('/a'),
            route('/b', [], null, (_, s) {
              routeRedirectCalls++;
              return '/a';
            }),
          ],
          redirect: (_, s) {
            topRedirectCalls++;
            return null;
          },
        ),
      );

      expect(find.text('home'), findsOneComponent);

      // Route resolution for the initial location may run the top-level
      // redirect, so only compare against the counts from here on.
      final topRedirectCallsAfterInit = topRedirectCalls;
      expect(routeRedirectCalls, equals(0));

      await tester.router.preload('/a');
      await tester.router.preload('/b');
      await pumpEventQueue();

      // Preloading a route (e.g. when hovering a Link) is not a navigation
      // and must not run any redirect.
      expect(topRedirectCalls, equals(topRedirectCallsAfterInit));
      expect(routeRedirectCalls, equals(0));
      expect(find.text('home'), findsOneComponent);

      // An actual navigation still runs the redirects.
      await tester.router.push('/b');
      await pumpEventQueue();

      expect(routeRedirectCalls, equals(1));
      expect(find.text('a'), findsOneComponent);
      expect(tester.routeOf(find.text('a')).location, equals('/a'));
    });
  });
}

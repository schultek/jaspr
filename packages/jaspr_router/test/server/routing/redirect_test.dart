@TestOn('vm')
library;

import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/server_test.dart';

import '../../utils.dart';

void main() {
  group('router', () {
    testServer('should redirect toplevel', (tester) async {
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

      var response = await tester.request('/');
      expect(response.body, contains('<span>home</span>'));

      response = await tester.request('/a');
      expect(response.statusCode, equals(302));
      expect(response.headers['location'], equals('/b'));

      response = await tester.request('/b');
      expect(response.body, contains('<span>b</span>'));
    });

    testServer('should redirect on route', (tester) async {
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

      var response = await tester.request('/');
      expect(response.body, contains('<span>home</span>'));

      response = await tester.request('/b');

      expect(response.statusCode, equals(302));
      expect(response.headers['location'], equals('/a'));

      response = await tester.request('/a');
      expect(response.body, contains('<span>a</span>'));

      blocked = false;

      response = await tester.request('/b');
      expect(response.body, contains('<span>b</span>'));
    });

    testServer('should redirect on async update', (tester) async {
      var blocked = false;

      tester.pumpComponent(
        Router(
          routes: [homeRoute(), route('/a')],
          redirect: (_, s) async {
            await Future(() async {});
            if (s.location == '/a' && blocked) {
              return '/';
            }
            return null;
          },
        ),
      );

      var response = await tester.request('/');
      expect(response.body, contains('home'));

      response = await tester.request('/a');
      expect(response.body, contains('<span>a</span>'));

      blocked = true;

      response = await tester.request('/a');
      expect(response.statusCode, equals(302));
      expect(response.headers['location'], equals('/'));
    });
  });
}

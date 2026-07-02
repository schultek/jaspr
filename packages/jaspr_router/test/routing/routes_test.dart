@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_router/src/platform/platform.dart';
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

    testComponents('should push route with basePath', (tester) async {
      tester.pumpComponent(Router(routes: [homeRoute(), route('/a')]));

      final mockHistory = PlatformRouter.instance.history as MockHistoryManager;
      expect(mockHistory.history, equals(['/']));

      await tester.router.push('/a');
      await pumpEventQueue();

      expect(find.text('a'), findsOneComponent);
      expect(mockHistory.history, equals(['/', '/sub/path/a']));
    }, basePath: '/sub/path/');

    testComponents('should render Link with resolved basePath', (tester) async {
      tester.pumpComponent(Link(to: '/a', child: span([Component.text('link')])));

      final spanElement = find.text('link').evaluate().first.parent!;
      final linkElement = spanElement.parent!.parent as DomElement;
      final renderElement = linkElement.renderObject as TestRenderElement;
      expect(renderElement.attributes?['href'], equals('/sub/path/a'));
    }, basePath: '/sub/path/');
  });
}

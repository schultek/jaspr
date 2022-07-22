import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/browser_test.dart';

import 'routing_app.dart';

extension on BrowserTester {
  Future<void> navigate(Function(RouterState) navigate, {bool pump = true}) async {
    RouterState? router;
    findRouter(Element element) {
      if (element is StatefulElement && element.state is RouterState) {
        router = element.state as RouterState;
      } else {
        element.visitChildren(findRouter);
      }
    }

    binding.rootElements.values.first.visitChildren(findRouter);
    if (router != null) {
      navigate(router!);
      if (pump) {
        await pumpEventQueue();
      }
    }
  }
}

void main() {
  group('routing test', () {
    late BrowserTester tester;

    setUp(() async {
      tester = BrowserTester.setUp(onFetchState: (url) {
        if (url == '/contact') return {'contact': 'Tom'};
        return {};
      });
    });

    test('should handle routing', () async {
      await tester.pumpComponent(App());

      expect(find.text('Home'), findsOneComponent);

      await tester.navigate((router) => router.preload('/about'));

      expect(find.text('Home'), findsOneComponent);

      await tester.navigate((router) {
        return Router.of(router.context).replace('/about');
      });

      expect(find.text('About'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Contact'), findsOneComponent);
      expect(find.text('Tom'), findsOneComponent);

      await tester.navigate((router) => router.push('/unknown'));

      expect(find.text('No route specified for path /unknown.'), findsOneComponent);

      await tester.navigate((router) => router.back());

      expect(find.text('Contact'), findsOneComponent);
      expect(find.text('Tom'), findsOneComponent);
    });
  });
}

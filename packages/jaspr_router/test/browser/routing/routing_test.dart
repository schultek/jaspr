import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/browser_test.dart';

import '../utils.dart';
import 'routing_app.dart';

void main() {
  group('routing test', () {
    testBrowser('should handle routing', (tester) async {
      await tester.pumpComponent(App());

      expect(find.text('Home'), findsOneComponent);

      await tester.navigate((router) {
        return Router.of(router.context).push('/about');
      });

      expect(find.text('About'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Home'), findsOneComponent);

      await tester.navigate((router) => router.back());

      expect(find.text('About'), findsOneComponent);
    });
  });
}

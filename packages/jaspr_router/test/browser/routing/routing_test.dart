@TestOn('browser')
library;

import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/client_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('router', () {
    testClient('should push route', (tester) async {
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

    testClient('should replace route', (tester) async {
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
  });
}
